package openfl.net;

#if !flash
import haxe.io.Bytes;
import haxe.Serializer;
import openfl.events.EventDispatcher;
import openfl.utils.Object;

/**
	Provides the OpenFL shared-object API. Values are retained in memory until
	Flight supplies the platform persistence and remote synchronization hooks.
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
	}

	public function close():Void {}

	public function connect(myConnection:NetConnection, params:String = null):Void
	{
		// TODO: Connect remote shared objects through Flight networking.
	}

	public function flush(minDiskSpace:Int = 0):SharedObjectFlushStatus
	{
		// TODO: Persist local shared objects through Flight storage.
		return SharedObjectFlushStatus.PENDING;
	}

	public static function getLocal(name:String, localPath:String = null, secure:Bool = false /* note: unsupported**/):SharedObject
	{
		var key = (localPath == null ? "" : localPath) + "/" + name;
		if (!__sharedObjects.exists(key))
		{
			var sharedObject = new SharedObject();
			sharedObject.__localPath = localPath;
			sharedObject.__name = name;
			__sharedObjects.set(key, sharedObject);
		}
		return __sharedObjects.get(key);
	}

	public static function getRemote(name:String, remotePath:String = null, persistence:Dynamic = false, secure:Bool = false):SharedObject
	{
		// TODO: Distinguish and synchronize remote shared objects through Flight.
		return getLocal(name, remotePath, secure);
	}

	public function send(args:Array<Dynamic>):Void
	{
		// TODO: Send remote shared-object messages through Flight networking.
	}

	public function setDirty(propertyName:String):Void
	{
		// TODO: Track dirty fields for Flight persistence and synchronization.
	}

	public function setProperty(propertyName:String, value:Object = null):Void
	{
		if (data != null) Reflect.setField(data, propertyName, value);
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
