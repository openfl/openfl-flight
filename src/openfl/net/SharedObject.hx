package openfl.net;

#if !flash
import flight.Storage as FlightStorage;
import haxe.io.Bytes;
import haxe.Serializer;
import haxe.Unserializer;
import openfl.errors.Error;
import openfl.events.EventDispatcher;
import openfl.utils.Object;
#if clay
import flight.hostClay.HostClay;
#elseif lime
import flight.hostLime.HostLime;
import lime.app.Application;
#elseif js
import flight.HostWeb as FlightHostWeb;
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
	@:noCompletion private static var __memoryStorageHost:Dynamic = {
		storage: {
			local: {
				clear: function():Dynamic
				{
					__memoryValues.clear();
					return {reason: "ok"};
				},
				getItem: function(key:String):Dynamic
				{
					return {reason: "ok", value: __memoryValues.get(key)};
				},
				keys: function():Dynamic
				{
					return {reason: "ok", value: [for (key in __memoryValues.keys()) key]};
				},
				removeItem: function(key:String):Dynamic
				{
					__memoryValues.remove(key);
					return {reason: "ok"};
				},
				setItem: function(key:String, value:String):Dynamic
				{
					__memoryValues.set(key, value);
					return {reason: "ok"};
				}
			}
		}
	};

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

		try
		{
			__callStorage("removeStorageItem", [__getStorageHost(), __getStorageKey(), null], [__getStorageKey(), null]);
		}
		catch (_:Dynamic) {}
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
			var result:Dynamic = __callStorage("setStorageItem", [__getStorageHost(), __getStorageKey(), encodedData, null],
				[__getStorageKey(), encodedData, null]);
			if (__storageSucceeded(result)) return SharedObjectFlushStatus.FLUSHED;
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

	@:noCompletion private static function __callStorage(methodName:String, hostArguments:Array<Dynamic>, hostlessArguments:Array<Dynamic>):Dynamic
	{
		var owner:Dynamic = FlightStorage;
		var method = Reflect.field(owner, methodName);

		#if js
		var arity:Dynamic = Reflect.field(method, "length");
		return arity != null && Std.int(arity) >= hostArguments.length
			? Reflect.callMethod(owner, method, hostArguments)
			: Reflect.callMethod(owner, method, hostlessArguments);
		#else
		try
		{
			return Reflect.callMethod(owner, method, hostArguments);
		}
		catch (_:Dynamic)
		{
			return Reflect.callMethod(owner, method, hostlessArguments);
		}
		#end
	}

	@:noCompletion private static function __getStorageHost():Dynamic
	{
		#if clay
		return cast HostClay.createClayHost();
		#elseif lime
		if (Application.current != null) return cast HostLime.createLimeHost(Application.current);
		#elseif js
		return cast FlightHostWeb.webStorageHost;
		#end
		return __memoryStorageHost;
	}

	@:noCompletion private function __getStorageKey():String
	{
		return "openfl.shared-object:" + (__localPath == null ? "" : __localPath) + "/" + __name;
	}

	@:noCompletion private function __load():Void
	{
		try
		{
			var result:Dynamic = __callStorage("getStorageItem", [__getStorageHost(), __getStorageKey()], [__getStorageKey()]);
			if (!__storageSucceeded(result)) return;

			var encodedData:Dynamic = Reflect.field(result, "value");
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

	@:noCompletion private static inline function __storageSucceeded(result:Dynamic):Bool
	{
		return result != null && Reflect.field(result, "reason") == "ok";
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
