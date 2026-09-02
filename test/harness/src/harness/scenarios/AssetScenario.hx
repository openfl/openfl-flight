package harness.scenarios;

import openfl.display.BitmapData;
import openfl.events.Event;
import openfl.media.Sound;
import openfl.text.Font;
import openfl.utils.AssetCache;
import openfl.utils.AssetLibrary;
import openfl.utils.Assets;
import openfl.utils.AssetType;

class AssetScenario
{
	public static function run():Dynamic
	{
		var defaultLibrary = Assets.getLibrary(null);
		var defaultLibraryState = {
			lookupMatchesNamedDefault: defaultLibrary == Assets.getLibrary("default"),
			hasLibraryMatchesLookup: Assets.hasLibrary(null) == (defaultLibrary != null)
		};

		var libraryName = "harness-assets";
		var imageID = libraryName + ":image";
		var library = new ScenarioAssetLibrary(libraryName);
		var hasBeforeRegister = Assets.hasLibrary(libraryName);
		Assets.registerLibrary(libraryName, library);

		var listedImages = Assets.list(AssetType.IMAGE);
		var scenarioImages = [for (id in listedImages) if (StringTools.startsWith(id, libraryName + ":")) id];
		scenarioImages.sort(Reflect.compare);

		var registeredLibraryState = {
			hasBeforeRegister: hasBeforeRegister,
			hasAfterRegister: Assets.hasLibrary(libraryName),
			lookupMatches: Assets.getLibrary(libraryName) == library,
			listedImages: scenarioImages,
			existsAsImage: Assets.exists(imageID, AssetType.IMAGE),
			existsAsSound: Assets.exists(imageID, AssetType.SOUND),
			isLocal: Assets.isLocal(imageID, AssetType.IMAGE),
			path: Assets.getPath(imageID)
		};

		Assets.unloadLibrary(libraryName);
		var unregisteredLibraryState = {
			hasLibrary: Assets.hasLibrary(libraryName),
			lookupIsNull: Assets.getLibrary(libraryName) == null,
			unloadCalls: library.unloadCalls
		};

		var replacementName = "harness-assets-replacement";
		var firstLibrary = new ScenarioAssetLibrary(replacementName);
		var secondLibrary = new ScenarioAssetLibrary(replacementName);
		Assets.registerLibrary(replacementName, firstLibrary);
		Assets.registerLibrary(replacementName, firstLibrary);
		var sameRegistrationUnloadCalls = firstLibrary.unloadCalls;
		Assets.registerLibrary(replacementName, secondLibrary);
		var lookupMatchesReplacement = Assets.getLibrary(replacementName) == secondLibrary;
		Assets.unloadLibrary(replacementName);
		var replacementLibraryState = {
			sameRegistrationUnloadCalls: sameRegistrationUnloadCalls,
			firstUnloadCalls: firstLibrary.unloadCalls,
			lookupMatchesReplacement: lookupMatchesReplacement,
			secondUnloadCalls: secondLibrary.unloadCalls
		};

		var cache = new AssetCache();
		var bitmapData = new BitmapData(2, 3, true, 0x80402010);
		var font = new Font("HarnessFont");
		var sound = new Sound();
		var enabledByDefault = cache.enabled;
		cache.enabled = false;
		var disabled = !cache.enabled;
		cache.enabled = true;
		cache.setBitmapData("bitmap", bitmapData);
		cache.setFont("font", font);
		cache.setSound("sound", sound);

		var populatedCacheState = {
			enabledByDefault: enabledByDefault,
			disabled: disabled,
			reenabled: cache.enabled,
			hasBitmapData: cache.hasBitmapData("bitmap"),
			bitmapDataMatches: cache.getBitmapData("bitmap") == bitmapData,
			hasFont: cache.hasFont("font"),
			fontMatches: cache.getFont("font") == font,
			hasSound: cache.hasSound("sound"),
			soundMatches: cache.getSound("sound") == sound,
			removeBitmapData: cache.removeBitmapData("bitmap"),
			hasBitmapDataAfterRemove: cache.hasBitmapData("bitmap"),
			removeMissingBitmapData: cache.removeBitmapData("bitmap"),
			removeFont: cache.removeFont("font"),
			hasFontAfterRemove: cache.hasFont("font"),
			removeMissingFont: cache.removeFont("font"),
			removeSound: cache.removeSound("sound"),
			hasSoundAfterRemove: cache.hasSound("sound"),
			removeMissingSound: cache.removeSound("sound")
		};

		cache.setBitmapData("clear-bitmap", bitmapData);
		cache.setFont("clear-font", font);
		cache.setSound("clear-sound", sound);
		cache.setBitmapData("keep-bitmap", bitmapData);
		cache.clear("clear-");
		var clearedCacheState = {
			hasBitmapData: cache.hasBitmapData("clear-bitmap"),
			hasFont: cache.hasFont("clear-font"),
			hasSound: cache.hasSound("clear-sound"),
			keptNonMatchingBitmapData: cache.hasBitmapData("keep-bitmap"),
			bitmapDataIsNull: cache.getBitmapData("clear-bitmap") == null,
			fontIsNull: cache.getFont("clear-font") == null,
			soundIsNull: cache.getSound("clear-sound") == null
		};

		var changeEvents = 0;
		var changeListener = function(_:Event):Void changeEvents++;
		Assets.addEventListener(Event.CHANGE, changeListener);
		var firstDispatch = Assets.dispatchEvent(new Event(Event.CHANGE));
		Assets.removeEventListener(Event.CHANGE, changeListener);
		var secondDispatch = Assets.dispatchEvent(new Event(Event.CHANGE));
		var eventState = {
			changeEvents: changeEvents,
			firstDispatch: firstDispatch,
			secondDispatch: secondDispatch,
			hasListenerAfterRemove: Assets.hasEventListener(Event.CHANGE)
		};

		var originalCache = Assets.cache;
		var globalCache = new AssetCache();
		Assets.cache = globalCache;
		globalCache.setBitmapData("global-bitmap", bitmapData);
		globalCache.setFont("global-font", font);
		globalCache.setSound("global-sound", sound);
		var globalCacheState = {
			bitmapDataMatches: Assets.getBitmapData("global-bitmap") == bitmapData,
			fontMatches: Assets.getFont("global-font") == font,
			soundMatches: Assets.getSound("global-sound") == sound,
			bitmapDataIsLocal: Assets.isLocal("global-bitmap", AssetType.IMAGE),
			fontIsLocal: Assets.isLocal("global-font", AssetType.FONT),
			soundIsLocal: Assets.isLocal("global-sound", AssetType.SOUND),
			musicIsLocal: Assets.isLocal("global-sound", AssetType.MUSIC),
			unknownTypeIsLocal: Assets.isLocal("global-bitmap")
		};
		Assets.cache = originalCache;

		return {
			assetTypes: {
				binary: cast(AssetType.BINARY, String),
				font: cast(AssetType.FONT, String),
				image: cast(AssetType.IMAGE, String),
				movieClip: cast(AssetType.MOVIE_CLIP, String),
				music: cast(AssetType.MUSIC, String),
				sound: cast(AssetType.SOUND, String),
				template: cast(AssetType.TEMPLATE, String),
				text: cast(AssetType.TEXT, String)
			},
			defaultLibrary: defaultLibraryState,
			registeredLibrary: registeredLibraryState,
			unregisteredLibrary: unregisteredLibraryState,
			replacementLibrary: replacementLibraryState,
			populatedCache: populatedCacheState,
			clearedCache: clearedCacheState,
			events: eventState,
			globalCache: globalCacheState
		};
	}
}

private class ScenarioAssetLibrary extends AssetLibrary
{
	public var unloadCalls(default, null):Int = 0;
	private var libraryName:String;

	public function new(libraryName:String)
	{
		super();
		this.libraryName = libraryName;
	}

	public override function exists(id:String, type:String):Bool
	{
		return id == "image"
			&& (type == null || type == cast(AssetType.IMAGE, String) || type == cast(AssetType.BINARY, String));
	}

	public override function getPath(id:String):String
	{
		return id == "image" ? "memory://image.png" : null;
	}

	public override function isLocal(id:String, type:String):Bool
	{
		return exists(id, type);
	}

	public override function list(type:String):Array<String>
	{
		return type == null || type == cast(AssetType.IMAGE, String) ? [libraryName + ":image"] : [];
	}

	public override function unload():Void
	{
		unloadCalls++;
	}
}
