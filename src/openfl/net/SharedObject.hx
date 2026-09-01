package openfl.net;

#if !flash
import flight.Storage as FlightStorage;
import haxe.io.Bytes;
import haxe.Serializer;
import haxe.Unserializer;
import openfl.errors.Error;
import openfl.events.EventDispatcher;
import openfl.utils.Object;

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

		FlightStorage.removeStorageItem(__getStorageKey());
		__memoryValues.remove(__getStorageKey());
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
		try
		{
			if (!FlightStorage.setStorageItem(__getStorageKey(), encodedData))
			{
				__memoryValues.set(__getStorageKey(), encodedData);
			}
			return SharedObjectFlushStatus.FLUSHED;
		}
		catch (_:Dynamic) {}

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
		// TODO: Distinguish and synchronize remote shared objects through Flight.
		return getLocal(name, remotePath, secure);
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
			var encodedData = FlightStorage.getStorageItem(__getStorageKey());
			if (encodedData == null) encodedData = __memoryValues.get(__getStorageKey());
			if (encodedData == null || encodedData == "") return;

			var unserializer = new Unserializer(Std.string(encodedData));
			unserializer.setResolver(cast {resolveEnum: Type.resolveEnum, resolveClass: __resolveClass});
			var decoded = unserializer.unserialize();
			if (decoded != null) data = decoded;
		}
		catch (_:Dynamic) {}
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
