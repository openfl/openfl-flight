package harness.scenarios;

import openfl.display.Bitmap;
import openfl.display.Loader;
import openfl.display.LoaderInfo;
import openfl.system.ApplicationDomain;
import openfl.utils.ByteArray;

class LoaderInfoScenario {
	public static function run():Dynamic {
		var loader = new Loader();
		var info = loader.contentLoaderInfo;
		var parameterFields = Reflect.fields(info.parameters);
		parameterFields.sort(Reflect.compare);

		var defaults = {
			stableReference: info == loader.contentLoaderInfo,
			loaderMatches: info.loader == loader,
			applicationDomainIsCurrent: info.applicationDomain == ApplicationDomain.currentDomain,
			assetLibrary: info.assetLibrary,
			bytes: info.bytes,
			bytesLoaded: info.bytesLoaded,
			bytesTotal: info.bytesTotal,
			childAllowsParent: info.childAllowsParent,
			content: info.content,
			contentType: info.contentType,
			frameRate: info.frameRate,
			height: info.height,
			loaderURL: info.loaderURL,
			parameterFields: parameterFields,
			parentAllowsChild: info.parentAllowsChild,
			sameDomain: info.sameDomain,
			sharedEvents: info.sharedEvents,
			uncaughtErrorEventsExists: info.uncaughtErrorEvents != null,
			url: info.url,
			width: info.width
		};

		var bytes = pngBytes();
		loader.loadBytes(bytes);
		var lookup = Reflect.field(LoaderInfo, "getLoaderInfoByDefinition");
		var definitionLookupMatches = lookup == null
			|| Reflect.callMethod(LoaderInfo, lookup, [Type.getClass(loader.content)]) == info;
		var unknownDefinitionReturnsNull = lookup == null
			|| Reflect.callMethod(LoaderInfo, lookup, [String]) == null;

		return {
			defaults: defaults,
			afterLoadBytes: {
				bytesSameReference: info.bytes == bytes,
				bytesLength: info.bytes == null ? null : info.bytes.length,
				bytesLoaded: info.bytesLoaded,
				bytesTotal: info.bytesTotal,
				contentIsBitmap: Std.isOfType(info.content, Bitmap),
				contentMatchesLoader: info.content == loader.content,
				contentType: info.contentType,
				definitionLookupMatches: definitionLookupMatches,
				frameRate: info.frameRate,
				height: info.height,
				loaderURL: info.loaderURL,
				unknownDefinitionReturnsNull: unknownDefinitionReturnsNull,
				url: info.url,
				width: info.width
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
