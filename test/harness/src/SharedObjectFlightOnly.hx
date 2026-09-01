import flight.types.HasStorageLocal as FlightStorageHost;
import openfl.net.SharedObject;
import openfl.net.SharedObjectFlushStatus;

@:access(openfl.net.SharedObject)
class SharedObjectFlightOnly
{
	public static function main():Void
	{
		var values = new Map<String, String>();
		installHost(createHost(values, false));

		var shared = SharedObject.getLocal("flight-persistence", "/adapter-test");
		shared.clear();
		shared.setProperty("player", {name: "Ada", scores: [3, 5, 8]});
		if (shared.flush() != SharedObjectFlushStatus.FLUSHED) throw "Flight storage flush failed";
		if (!values.iterator().hasNext()) throw "Flight storage backend received no serialized value";

		SharedObject.__sharedObjects = new Map();
		var loaded = SharedObject.getLocal("flight-persistence", "/adapter-test");
		var player:Dynamic = Reflect.field(loaded.data, "player");
		if (player == null || player.name != "Ada" || player.scores.join(",") != "3,5,8") throw "Flight storage reload mismatch";

		loaded.clear();
		SharedObject.__sharedObjects = new Map();
		if (Reflect.fields(SharedObject.getLocal("flight-persistence", "/adapter-test").data).length != 0)
		{
			throw "Flight storage clear did not persist";
		}

		installHost(createHost(new Map(), true));
		var denied = SharedObject.getLocal("flight-denied", "/adapter-test");
		denied.setProperty("value", 7);
		if (denied.flush() != SharedObjectFlushStatus.PENDING) throw "Denied Flight storage write must return pending";

		installHost(null);
		var memory = SharedObject.getLocal("flight-memory", "/adapter-test");
		memory.setProperty("value", 11);
		if (memory.flush() != SharedObjectFlushStatus.FLUSHED) throw "Headless memory flush failed";
		SharedObject.__sharedObjects = new Map();
		if (Reflect.field(SharedObject.getLocal("flight-memory", "/adapter-test").data, "value") != 11)
		{
			throw "Headless memory reload mismatch";
		}

		Sys.println("PASS SharedObject Flight Storage persistence");
	}

	private static function installHost(host:FlightStorageHost):Void
	{
		SharedObject.__storageHost = host;
		SharedObject.__storageHostResolved = true;
		SharedObject.__sharedObjects = new Map();
		SharedObject.__memoryValues = new Map();
	}

	private static function createHost(values:Map<String, String>, denyWrites:Bool):FlightStorageHost
	{
		var backend:Dynamic = {
			clear: function():Dynamic
			{
				values.clear();
				return {reason: "ok"};
			},
			getItem: function(key:String):Dynamic return {reason: "ok", value: values.get(key)},
			keys: function():Dynamic return {reason: "ok", value: [for (key in values.keys()) key]},
			removeItem: function(key:String):Dynamic
			{
				values.remove(key);
				return {reason: "ok"};
			},
			setItem: function(key:String, value:String):Dynamic
			{
				if (denyWrites) return {reason: "storage-unavailable"};
				values.set(key, value);
				return {reason: "ok"};
			}
		};
		return cast {storage: {local: backend}};
	}
}
