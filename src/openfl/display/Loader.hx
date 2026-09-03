package openfl.display;

#if !flash
import flight.Image as FlightImage;
import flight.types.ImageResourceReference as FlightImageResourceReference;
import flight._internal._UInt8Array as FlightUInt8Array;
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

	@:noCompletion private var __flightImageReference:FlightImageResourceReference;
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
		__flightImageReference = null;
	}
	#end

	public function load(request:URLRequest, context:LoaderContext = null):Void
	{
		unload();
		if (request == null)
		{
			__dispatchError("URLRequest must not be null");
			return;
		}
		contentLoaderInfo.dispatchEvent(new Event(Event.OPEN));
		contentLoaderInfo.url = request.url;
		__unloaded = false;

		if (__registeredLoaders != null)
		{
			var i = __registeredLoaders.length;
			while (i > 0)
			{
				i--;
				var registeredLoader = __registeredLoaders[i];
				var future = registeredLoader.load(request, context, contentLoaderInfo);
				if (future != null)
				{
					future.onComplete(Loader_onComplete);
					future.onProgress(Loader_onProgress);
					future.onError(Loader_onError);
					return;
				}
			}
		}

		__flightImageReference = FlightImage.createExternalImageResourceReference(request.url);
		contentLoaderInfo.__setFlightResourceReference(__flightImageReference);
	}

	public function loadBytes(buffer:ByteArray, context:LoaderContext = null):Void
	{
		if (buffer == null)
		{
			__dispatchError("ByteArray must not be null");
			return;
		}
		var bytes = new FlightUInt8Array(buffer.length);
		for (i in 0...buffer.length) bytes[i] = buffer[i];
		__flightImageReference = FlightImage.createEmbeddedImageResourceReference(bytes);
		contentLoaderInfo.__setFlightResourceReference(__flightImageReference);
		Loader_onComplete(new Bitmap(new BitmapData(0, 0)));
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
		if (!__unloaded)
		{
			if (content != null && content.parent == this)
			{
				super.removeChild(content);
			}

			content = null;
			__flightImageReference = null;
			contentLoaderInfo.__setFlightResourceReference(null);
			contentLoaderInfo.url = null;
			contentLoaderInfo.contentType = null;
			contentLoaderInfo.content = null;
			contentLoaderInfo.bytes = null;
			contentLoaderInfo.bytesLoaded = 0;
			contentLoaderInfo.bytesTotal = 0;
			contentLoaderInfo.width = 0;
			contentLoaderInfo.height = 0;
			__unloaded = true;
			contentLoaderInfo.dispatchEvent(new Event(Event.UNLOAD));
		}
	}

	public function unloadAndStop(gc:Bool = true):Void
	{
		unload();
	}

	@:noCompletion private function __dispatchError(error:Any):Void
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
			contentLoaderInfo.content = content;
			LoaderInfo.__registerDefinition(content, contentLoaderInfo);
			if (contentLoaderInfo.width == -1 || contentLoaderInfo.height == -1)
			{
				contentLoaderInfo.width = Std.int(content.width);
				contentLoaderInfo.height = Std.int(content.height);
			}
			super.addChildAt(content, 0);
			contentLoaderInfo.dispatchEvent(new Event(Event.COMPLETE));
		}
	}

	@:noCompletion private function Loader_onError(error:Any):Void
	{
		__dispatchError(error);
	}

	@:noCompletion private function Loader_onProgress(bytesLoaded:Int, bytesTotal:Int):Void
	{
		contentLoaderInfo.__update(bytesLoaded, bytesTotal);
	}
}
#else
typedef Loader = flash.display.Loader;
#end
