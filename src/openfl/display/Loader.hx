package openfl.display;

#if !flash
import openfl.errors.Error;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.UncaughtErrorEvents;
import openfl.net.URLRequest;
import openfl.system.LoaderContext;
import openfl.utils.ByteArray;

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:access(openfl.display.LoaderInfo)
class Loader extends DisplayObjectContainer
{
	@:noCompletion private static var __registeredLoaders:Array<IDisplayObjectLoader>;

	public var content(default, null):DisplayObject;
	public var contentLoaderInfo(default, null):LoaderInfo;
	public var uncaughtErrorEvents(default, null):UncaughtErrorEvents;

	@:noCompletion private var __unloaded:Bool;

	public function new()
	{
		super();
		contentLoaderInfo = LoaderInfo.create(this);
		uncaughtErrorEvents = contentLoaderInfo.uncaughtErrorEvents;
		__unloaded = true;
	}

	public override function addChild(child:DisplayObject):DisplayObject
	{
		throw new Error("Error #2069: The Loader class does not implement this method.", 2069);
	}

	public override function addChildAt(child:DisplayObject, index:Int):DisplayObject
	{
		throw new Error("Error #2069: The Loader class does not implement this method.", 2069);
	}

	#if !openfl_strict
	public function close():Void
	{
		// TODO (Flight): cancel the active display-content load.
	}
	#end

	public function load(request:URLRequest, context:LoaderContext = null):Void
	{
		// TODO (Flight): select a registered loader and load URL content.
		__unloaded = false;
	}

	public function loadBytes(buffer:ByteArray, context:LoaderContext = null):Void
	{
		// TODO (Flight): decode display content from bytes.
		__unloaded = false;
	}

	public static function registerLoader(loader:IDisplayObjectLoader):Void
	{
		if (loader == null) return;
		if (__registeredLoaders == null) __registeredLoaders = [];
		__registeredLoaders.remove(loader);
		__registeredLoaders.push(loader);
	}

	public override function removeChild(child:DisplayObject):DisplayObject
	{
		if (child == content) return super.removeChild(child);
		throw new Error("Error #2069: The Loader class does not implement this method.", 2069);
	}

	public override function removeChildAt(index:Int):DisplayObject
	{
		throw new Error("Error #2069: The Loader class does not implement this method.", 2069);
	}

	public override function setChildIndex(child:DisplayObject, index:Int):Void
	{
		throw new Error("Error #2069: The Loader class does not implement this method.", 2069);
	}

	public function unload():Void
	{
		if (content != null && content.parent == this)
		{
			super.removeChild(content);
		}

		content = null;
		__unloaded = true;
		contentLoaderInfo.dispatchEvent(new Event(Event.UNLOAD));
	}

	public function unloadAndStop(gc:Bool = true):Void
	{
		unload();
	}

	@SuppressWarnings("checkstyle:Dynamic")
	@:noCompletion private function __dispatchError(error:Dynamic):Void
	{
		var event = new IOErrorEvent(IOErrorEvent.IO_ERROR);
		event.text = Std.string(error);
		contentLoaderInfo.dispatchEvent(event);
	}

	@:noCompletion private function Loader_onComplete(content:DisplayObject):Void
	{
		this.content = content;
		if (content != null)
		{
			super.addChildAt(content, 0);
			contentLoaderInfo.dispatchEvent(new Event(Event.COMPLETE));
		}
	}

	@SuppressWarnings("checkstyle:Dynamic")
	@:noCompletion private function Loader_onError(error:Dynamic):Void
	{
		__dispatchError(error);
	}

	@:noCompletion private function Loader_onProgress(bytesLoaded:Int, bytesTotal:Int):Void {}
}
#else
typedef Loader = flash.display.Loader;
#end
