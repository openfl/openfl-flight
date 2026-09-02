package harness.scenarios;

import openfl.Lib;
import openfl.display.Sprite;
import openfl.display.Stage;
import openfl.display.StageAlign;
import openfl.display.StageOrientation;
import openfl.display.StageQuality;
import openfl.display.StageScaleMode;
import openfl.display.Window;
import openfl.events.Event;
import openfl.events.FocusEvent;
import openfl.geom.Point;
import openfl.geom.Rectangle;

class StageScenario {
	public static function run():Dynamic {
		var stage = createStage(320, 240, 0x123456);
		if (Lib.current != null && Lib.current.parent == stage) stage.removeChild(Lib.current);

		var global = stage.localToGlobal(new Point(12, 34));
		var defaults = {
			stageIsSelf: stage.stage == stage,
			nameIsNull: stage.name == null,
			parentIsNull: stage.parent == null,
			stageWidth: stage.stageWidth,
			stageHeight: stage.stageHeight,
			width: stage.width,
			height: stage.height,
			color: stage.color,
			contentsScaleFactor: stage.contentsScaleFactor,
			displayState: Std.string(stage.displayState),
			frameRate: captureFrameRate(stage),
			align: Std.string(stage.align),
			scaleMode: Std.string(stage.scaleMode),
			quality: Std.string(stage.quality),
			autoOrients: stage.autoOrients,
			supportsOrientationChange: Stage.supportsOrientationChange,
			supportedOrientationCount: stage.supportedOrientations.length,
			stage3DCount: stage.stage3Ds.length,
			showDefaultContextMenu: stage.showDefaultContextMenu,
			stageFocusRect: stage.stageFocusRect,
			softKeyboardEmpty: stage.softKeyboardRect.equals(new Rectangle()),
			fullScreenSourceRectIsNull: stage.fullScreenSourceRect == null,
			localToGlobalX: global.x,
			localToGlobalY: global.y,
			tabEnabled: stage.tabEnabled,
			tabIndex: stage.tabIndex
		};

		var focusEvents:Array<String> = [];
		var first = new Sprite();
		var second = new Sprite();
		var outside = new Sprite();
		first.addEventListener(FocusEvent.FOCUS_IN, function(_):Void focusEvents.push("firstIn"));
		first.addEventListener(FocusEvent.FOCUS_OUT, function(_):Void focusEvents.push("firstOut"));
		second.addEventListener(FocusEvent.FOCUS_IN, function(_):Void focusEvents.push("secondIn"));
		second.addEventListener(FocusEvent.FOCUS_OUT, function(_):Void focusEvents.push("secondOut"));
		outside.addEventListener(FocusEvent.FOCUS_IN, function(_):Void focusEvents.push("outsideIn"));
		outside.addEventListener(FocusEvent.FOCUS_OUT, function(_):Void focusEvents.push("outsideOut"));
		stage.addChild(first);
		stage.addChild(second);
		stage.focus = first;
		stage.focus = second;
		stage.focus = null;
		stage.focus = outside;
		var acceptsOutsideFocus = stage.focus == outside;
		stage.focus = null;

		stage.align = StageAlign.BOTTOM_RIGHT;
		stage.scaleMode = StageScaleMode.SHOW_ALL;
		stage.quality = StageQuality.LOW;
		#if harness_capture
		var mutatedFrameRate = 24.0;
		#else
		stage.frameRate = 24;
		var mutatedFrameRate = stage.frameRate;
		#end
		stage.autoOrients = true;
		stage.showDefaultContextMenu = false;
		stage.color = 0xABCDEF;
		var colorAfterRgb = stage.color;
		stage.color = null;
		var colorAfterNull = stage.color;

		var suppliedRect = new Rectangle(1, 2, 30, 40);
		stage.fullScreenSourceRect = suppliedRect;
		suppliedRect.x = 99;
		var firstRect = stage.fullScreenSourceRect;
		firstRect.y = 88;
		var secondRect = stage.fullScreenSourceRect;

		var orientationEvents = 0;
		stage.addEventListener(Event.CHANGE, function(_):Void orientationEvents++);
		stage.addEventListener("orientationChange", function(_):Void orientationEvents++);
		stage.setOrientation(StageOrientation.DEFAULT);

		var immutable = testImmutableProperties(stage);
		return {
			defaults: defaults,
			focus: {
				events: focusEvents,
				acceptsOutsideFocus: acceptsOutsideFocus,
				endsNull: stage.focus == null
			},
			mutation: {
				align: Std.string(stage.align),
				scaleMode: Std.string(stage.scaleMode),
				quality: Std.string(stage.quality),
				displayState: Std.string(stage.displayState),
				frameRate: mutatedFrameRate,
				autoOrients: stage.autoOrients,
				showDefaultContextMenu: stage.showDefaultContextMenu,
				colorAfterRgb: colorAfterRgb,
				colorAfterNull: colorAfterNull,
				storedRectX: secondRect.x,
				storedRectY: secondRect.y,
				storedRectWidth: secondRect.width,
				storedRectHeight: secondRect.height,
				orientationEvents: orientationEvents
			},
			immutable: immutable
		};
	}

	private static function createStage(width:Int, height:Int, color:Int):Stage {
		var window:Dynamic = Type.createEmptyInstance(Window);
		#if harness_capture
		Reflect.setField(window, "__width", width);
		Reflect.setField(window, "__height", height);
		Reflect.setField(window, "__scale", 1.5);
		Reflect.setField(window, "__fullscreen", false);
		#else
		window.width = width;
		window.height = height;
		window.scale = 1.5;
		window.fullscreen = false;
		#end
		return new Stage(cast window, color);
	}

	private static function captureFrameRate(stage:Stage):Float {
		#if harness_capture
		// The headless reference Window has no backend, whose frame rate Stage
		// normally proxies. Record OpenFL's documented runtime default instead.
		return 60;
		#else
		return stage.frameRate;
		#end
	}

	private static function testImmutableProperties(stage:Stage):Dynamic {
		var xError = false;
		var yError = false;
		var widthError = false;
		var heightError = false;
		var rotationError = false;
		var scaleXError = false;
		var scaleYError = false;
		var transformError = false;
		var tabEnabledError = false;
		var tabIndexError = false;
		try stage.x = 10 catch (_:Dynamic) xError = true;
		try stage.y = 20 catch (_:Dynamic) yError = true;
		try stage.width = 100 catch (_:Dynamic) widthError = true;
		try stage.height = 100 catch (_:Dynamic) heightError = true;
		try stage.rotation = 45 catch (_:Dynamic) rotationError = true;
		try stage.scaleX = 2 catch (_:Dynamic) scaleXError = true;
		try stage.scaleY = 2 catch (_:Dynamic) scaleYError = true;
		try stage.transform = stage.transform catch (_:Dynamic) transformError = true;
		try stage.tabEnabled = true catch (_:Dynamic) tabEnabledError = true;
		try stage.tabIndex = 4 catch (_:Dynamic) tabIndexError = true;
		return {
			xError: xError,
			yError: yError,
			widthError: widthError,
			heightError: heightError,
			rotationError: rotationError,
			scaleXError: scaleXError,
			scaleYError: scaleYError,
			transformError: transformError,
			tabEnabledError: tabEnabledError,
			tabIndexError: tabIndexError,
			x: stage.x,
			y: stage.y,
			rotation: stage.rotation,
			scaleX: stage.scaleX,
			scaleY: stage.scaleY
		};
	}
}
