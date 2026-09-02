package harness.scenarios;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.IDisplayObjectLoader;
import openfl.display.Loader;
import openfl.display.LoaderInfo;
import openfl.display.Stage;
import openfl.display.Window;
import openfl.errors.Error;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.ProgressEvent;
import openfl.Lib;
import openfl.net.URLRequest;
import openfl.system.LoaderContext;
import openfl.utils.ByteArray;
import openfl.utils.Future;

class LoaderScenario {
	public static function run():Dynamic {
		var idleLoader = new Loader();
		var idleCloseError:String = null;
		try
		{
			idleLoader.close();
		}
		catch (error:Dynamic)
		{
			idleCloseError = Std.string(error);
		}

		var loader = new Loader();
		var info = loader.contentLoaderInfo;
		var events:Array<String> = [];
		info.addEventListener(Event.OPEN, function(_):Void events.push("open"));
		info.addEventListener(Event.INIT, function(_):Void events.push("init"));
		info.addEventListener(Event.COMPLETE, function(_):Void events.push("complete"));
		info.addEventListener(Event.UNLOAD, function(_):Void events.push("unload"));
		info.addEventListener(IOErrorEvent.IO_ERROR, function(_):Void events.push("ioError"));
		info.addEventListener(ProgressEvent.PROGRESS, function(_):Void events.push("progress"));

		var defaults = {
			contentIsNull: loader.content == null,
			contentLoaderInfoExists: loader.contentLoaderInfo != null,
			contentLoaderInfoStable: loader.contentLoaderInfo == info,
			idleCloseError: idleCloseError,
			loaderMatches: info.loader == loader,
			bytesLoaded: info.bytesLoaded,
			bytesTotal: info.bytesTotal,
			contentType: info.contentType,
			width: info.width,
			height: info.height,
			url: info.url,
			loaderURL: info.loaderURL,
			applicationDomainExists: info.applicationDomain != null,
			sharedEventsExists: info.sharedEvents != null,
			uncaughtEventsMatch: loader.uncaughtErrorEvents == info.uncaughtErrorEvents,
			numChildren: loader.numChildren
		};

		var bytes = pngBytes();
		var loadError:String = null;
		try
		{
			loader.loadBytes(bytes);
		}
		catch (error:Dynamic)
		{
			loadError = Std.string(error);
		}

		var afterLoad = {
			loadError: loadError,
			contentIsBitmap: Std.isOfType(loader.content, Bitmap),
			contentParentMatches: loader.content != null && loader.content.parent == loader,
			infoContentMatches: info.content == loader.content,
			bytesLoaded: info.bytesLoaded,
			bytesTotal: info.bytesTotal,
			contentType: info.contentType,
			width: info.width,
			height: info.height,
			numChildren: loader.numChildren,
			events: events.copy()
		};

		var loadedContent = loader.content;
		var removedContent:DisplayObject = null;
		var removeChildError:String = null;
		try
		{
			removedContent = loader.removeChild(loadedContent);
		}
		catch (error:Dynamic)
		{
			removeChildError = Std.string(error);
		}

		var addChildErrorID:Null<Int> = null;
		try
		{
			loader.addChild(loadedContent);
		}
		catch (error:Dynamic)
		{
			addChildErrorID = Std.isOfType(error, Error) ? (cast error : Error).errorID : -1;
		}

		Loader.registerLoader(new MemoryDisplayObjectLoader());
		var rootStage = createRootStage();
		var unloadLoader = new Loader();
		var unloadEvents:Array<String> = [];
		unloadLoader.contentLoaderInfo.addEventListener(Event.OPEN, function(_):Void unloadEvents.push("open"));
		unloadLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(_):Void unloadEvents.push("complete"));
		unloadLoader.contentLoaderInfo.addEventListener(Event.UNLOAD, function(_):Void unloadEvents.push("unload"));
		var memoryLoadError:String = null;
		try
		{
			unloadLoader.load(new URLRequest(MemoryDisplayObjectLoader.URL));
		}
		catch (error:Dynamic)
		{
			memoryLoadError = Std.string(error);
		}
		if (Lib.current.parent == rootStage) rootStage.removeChild(Lib.current);
		var beforeUnload = {
			loadError: memoryLoadError,
			contentIsBitmap: Std.isOfType(unloadLoader.content, Bitmap),
			contentParentMatches: unloadLoader.content != null && unloadLoader.content.parent == unloadLoader,
			numChildren: unloadLoader.numChildren,
			events: unloadEvents.copy()
		};
		unloadLoader.unload();

		return {
			defaults: defaults,
			afterLoadBytes: afterLoad,
			loadedContentInteraction: {
				removedContentMatches: removedContent == loadedContent,
				removeChildError: removeChildError,
				contentStillMatches: loader.content == loadedContent,
				contentParentIsNull: loadedContent != null && loadedContent.parent == null,
				numChildren: loader.numChildren,
				addChildErrorID: addChildErrorID
			},
			beforeUnload: beforeUnload,
			afterUnload: {
				contentIsNull: unloadLoader.content == null,
				infoContentIsNull: unloadLoader.contentLoaderInfo.content == null,
				numChildren: unloadLoader.numChildren,
				events: unloadEvents
			}
		};
	}

	private static function pngBytes():ByteArray {
		var result = new ByteArray();
		var values = [
			137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82,
			0, 0, 0, 1, 0, 0, 0, 1, 8, 6, 0, 0, 0, 31, 21, 196,
			137, 0, 0, 0, 13, 73, 68, 65, 84, 8, 29, 99, 248, 207, 192, 240,
			31, 0, 5, 128, 2, 63, 73, 194, 245, 89, 0, 0, 0, 0, 73, 69,
			78, 68, 174, 66, 96, 130
		];
		for (value in values) result.writeByte(value);
		result.position = 0;
		return result;
	}

	private static function createRootStage():Stage
	{
		var window:Dynamic = Type.createEmptyInstance(Window);
		#if harness_capture
		Reflect.setField(window, "__width", 1);
		Reflect.setField(window, "__height", 1);
		Reflect.setField(window, "__scale", 1);
		Reflect.setField(window, "__fullscreen", false);
		#else
		window.width = 1;
		window.height = 1;
		window.scale = 1;
		window.fullscreen = false;
		#end
		return new Stage(cast window, 0);
	}
}

private class MemoryDisplayObjectLoader implements IDisplayObjectLoader
{
	public static inline var URL = "memory://loader.png";

	public function new() {}

	public function load(request:URLRequest, context:LoaderContext, contentLoaderInfo:LoaderInfo):Future<DisplayObject>
	{
		if (request == null || request.url != URL) return null;
		var content:DisplayObject = new Bitmap(new BitmapData(1, 1, true, 0x80402010));
		return Future.withValue(content);
	}

	public function loadBytes(buffer:ByteArray, context:LoaderContext, contentLoaderInfo:LoaderInfo):Future<DisplayObject>
	{
		return null;
	}
}
