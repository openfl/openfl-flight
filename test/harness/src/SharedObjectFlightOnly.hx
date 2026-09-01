import openfl.net.SharedObject;
import openfl.net.SharedObjectFlushStatus;

@:access(openfl.net.SharedObject)
class SharedObjectFlightOnly
{
	public static function main():Void
	{
		var shared = SharedObject.getLocal("flight-persistence", "/adapter-test");
		shared.clear();
		shared.setProperty("player", {name: "Ada", scores: [3, 5, 8]});
		if (shared.flush() != SharedObjectFlushStatus.FLUSHED) throw "Flight storage flush failed";

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

		Sys.println("PASS SharedObject Flight Storage persistence");
	}
}
