package harness.scenarios;

import openfl.display.Bitmap;
import openfl.display.Loader;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.ProgressEvent;
import openfl.utils.ByteArray;

class LoaderScenario {
	public static function run():Dynamic {
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
			contentLoaderInfoStable: loader.contentLoaderInfo == info,
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

		var closeError:String = null;
		try
		{
			loader.close();
		}
		catch (error:Dynamic)
		{
			closeError = Std.string(error);
		}
		loader.unload();

		return {
			defaults: defaults,
			afterLoad: afterLoad,
			afterUnload: {
				closeError: closeError,
				contentIsNull: loader.content == null,
				numChildren: loader.numChildren,
				events: events
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
}
