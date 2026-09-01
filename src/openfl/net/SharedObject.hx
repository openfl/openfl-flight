package openfl.net;

#if !flash
import flight.Storage as FlightStorage;
import flight.types.HasStorageLocal as FlightStorageHost;
import haxe.io.Bytes;
import haxe.Serializer;
import haxe.Unserializer;
import openfl.errors.Error;
import openfl.events.EventDispatcher;
import openfl.utils.Object;
#if (js && html5)
import flight.HostWeb as FlightHostWeb;
#elseif (clay && sys)
import flight.hostClay.HostClay as FlightHostClay;
#elseif (lime && sys)
import flight.hostLime.HostLime as FlightHostLime;
import lime.app.Application as LimeApplication;
#end

/**
	Provides the OpenFL shared-object API, using Flight Storage for local
	persistence on supported platform hosts.
**/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
class SharedObject extends EventDispatcher
{
	public static var defaultObjectEncoding:ObjectEncoding = ObjectEncoding.DEFAULT;

	public var client:Dynamic;
	public var data(default, null):Dynamic;
	public var fps(null, default):Float;
	public var objectEncoding:ObjectEncoding;
	public var size(get, never):Int;

	@:noCompletion private static var __sharedObjects:Map<String, SharedObject> = new Map();
	@:noCompletion private static var __memoryValues:Map<String, String> = new Map();
	@:noCompletion private static var __storageHost:FlightStorageHost;
	@:noCompletion private static var __storageHostResolved:Bool;

	@:noCompletion private var __localPath:String;
	@:noCompletion private var __name:String;

	@:noCompletion private function new()
	{
		super();
		client = this;
		data = {};
		fps = 0;
		objectEncoding = defaultObjectEncoding;
	}

	public function clear():Void
	{
		data = {};

		var key = __getStorageKey();
		var host = __getStorageHost();
		if (host != null)
		{
			try
			{
				FlightStorage.removeStorageItem(host, key);
			}
			catch (_:Dynamic) {}
		}
		__memoryValues.remove(key);
	}

	public function close():Void {}

	#if !openfl_strict
	public function connect(myConnection:NetConnection, params:String = null):Void
	{
		// TODO: Connect remote shared objects through Flight networking.
	}
	#end

	public function flush(minDiskSpace:Int = 0):SharedObjectFlushStatus
	{
		if (Reflect.fields(data).length == 0) return SharedObjectFlushStatus.FLUSHED;

		var encodedData = Serializer.run(data);
		var key = __getStorageKey();
		var host = __getStorageHost();
		if (host == null)
		{
			__memoryValues.set(key, encodedData);
			return SharedObjectFlushStatus.FLUSHED;
		}

		try
		{
			var result:Dynamic = FlightStorage.setStorageItem(host, key, encodedData);
			if (result != null && Reflect.field(result, "reason") == "ok")
			{
				__memoryValues.remove(key);
				return SharedObjectFlushStatus.FLUSHED;
			}
		}
		catch (_:Dynamic) {}

		__memoryValues.set(key, encodedData);
		return SharedObjectFlushStatus.PENDING;
	}

	public static function getLocal(name:String, localPath:String = null, secure:Bool = false /* note: unsupported**/):SharedObject
	{
		var illegalValues = [" ", "~", "%", "&", "\\", ";", ":", "\"", "'", ",", "<", ">", "?", "#"];
		var allowed = name != null && name != "";
		if (allowed)
		{
			for (value in illegalValues)
			{
				if (name.indexOf(value) != -1)
				{
					allowed = false;
					break;
				}
			}
		}

		if (!allowed) throw new Error("Error #2134: Cannot create SharedObject.");

		var key = (localPath == null ? "" : localPath) + "/" + name;
		if (!__sharedObjects.exists(key))
		{
			var sharedObject = new SharedObject();
			sharedObject.__localPath = localPath;
			sharedObject.__name = name;
			sharedObject.__load();
			__sharedObjects.set(key, sharedObject);
		}
		return __sharedObjects.get(key);
	}

	#if !openfl_strict
	public static function getRemote(name:String, remotePath:String = null, persistence:Dynamic = false, secure:Bool = false):SharedObject
	{
		// Flight has no remote shared-object synchronization protocol.
		return null;
	}

	public function send(args:Array<Dynamic>):Void
	{
		// TODO: Send remote shared-object messages through Flight networking.
	}
	#end

	public function setDirty(propertyName:String):Void
	{
		// TODO: Track dirty fields for Flight persistence and synchronization.
	}

	public function setProperty(propertyName:String, value:Object = null):Void
	{
		if (data != null) Reflect.setField(data, propertyName, value);
	}

	@:noCompletion private function __getStorageKey():String
	{
		return "openfl.shared-object:" + (__localPath == null ? "" : __localPath) + "/" + __name;
	}

	@:noCompletion private function __load():Void
	{
		try
		{
			var key = __getStorageKey();
			var encodedData:String = null;
			var host = __getStorageHost();
			if (host != null)
			{
				var result:Dynamic = FlightStorage.getStorageItem(host, key);
				if (result != null && Reflect.field(result, "reason") == "ok") encodedData = Reflect.field(result, "value");
			}
			if (encodedData == null) encodedData = __memoryValues.get(key);
			if (encodedData == null || encodedData == "") return;

			var unserializer = new Unserializer(Std.string(encodedData));
			unserializer.setResolver(cast {resolveEnum: Type.resolveEnum, resolveClass: __resolveClass});
			var decoded = unserializer.unserialize();
			if (decoded != null) data = decoded;
		}
		catch (_:Dynamic) {}
	}

	@:noCompletion private static function __getStorageHost():FlightStorageHost
	{
		if (__storageHost != null || __storageHostResolved) return __storageHost;

		#if (js && html5)
		__storageHost = cast FlightHostWeb.webStorageHost;
		__storageHostResolved = true;
		#elseif (clay && sys)
		__storageHost = cast FlightHostClay.createClayHost();
		__storageHostResolved = true;
		#elseif (lime && sys)
		if (LimeApplication.current != null)
		{
			__storageHost = cast FlightHostLime.createLimeHost(LimeApplication.current);
			__storageHostResolved = true;
		}
		#else
		__storageHostResolved = true;
		#end

		return __storageHost;
	}

	@:noCompletion private static function __resolveClass(name:String):Class<Dynamic>
	{
		if (name == null) return null;
		if (StringTools.startsWith(name, "neash.")) name = StringTools.replace(name, "neash.", "openfl.");
		if (StringTools.startsWith(name, "native.")) name = StringTools.replace(name, "native.", "openfl.");
		if (StringTools.startsWith(name, "flash.")) name = StringTools.replace(name, "flash.", "openfl.");
		if (StringTools.startsWith(name, "openfl._v2.")) name = StringTools.replace(name, "openfl._v2.", "openfl.");
		if (StringTools.startsWith(name, "openfl._legacy.")) name = StringTools.replace(name, "openfl._legacy.", "openfl.");
		return Type.resolveClass(name);
	}

	@:noCompletion private function get_size():Int
	{
		try
		{
			return Bytes.ofString(Serializer.run(data)).length;
		}
		catch (e:Dynamic)
		{
			return 0;
		}
	}
}
#else
typedef SharedObject = flash.net.SharedObject;
#end
