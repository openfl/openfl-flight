package harness.scenarios;

import openfl.display.Application;
import openfl.display.Screen;
import openfl.display.ScreenMode;
import openfl.display.Window;
import openfl.geom.Rectangle;

class ScreenWindowScenario {
	public static function run():Dynamic {
		return {
			screens: captureScreens(),
			window: captureWindow()
		};
	}

	private static function captureScreens():Dynamic {
		try {
			var screens = Screen.screens;
			var secondScreens = Screen.screens;
			var result:Dynamic = {
				available: true,
				count: screens.length,
				arraysAreDistinct: screens != secondScreens,
				objectsAreDistinct: screens.length == 0 || secondScreens.length == 0 || screens[0] != secondScreens[0]
			};

			screens.pop();
			Reflect.setField(result, "arrayMutationIsolated", Screen.screens.length == secondScreens.length);
			try {
				var main = Screen.mainScreen;
				var bounds = main.bounds;
				var secondBounds = main.bounds;
				var visible = main.visibleBounds;
				var safe = main.safeArea;
				var mode = main.mode;
				var modes = main.modes;
				var secondModes = main.modes;
				var intersecting = Screen.getScreensForRectangle(bounds.clone());
				bounds.x += 123;
				modes.pop();
				Reflect.setField(result, "main", {
					bounds: captureRectangle(secondBounds),
					boundsAreDistinct: bounds != secondBounds,
					boundsMutationIsolated: secondBounds.x != bounds.x,
					visibleBounds: captureRectangle(visible),
					safeArea: captureRectangle(safe),
					mode: captureMode(mode),
					modeCount: secondModes.length,
					modeArraysAreDistinct: modes != secondModes,
					modeMutationIsolated: main.modes.length == secondModes.length,
					intersectingCount: intersecting.length
				});
			} catch (_:Dynamic) {
				Reflect.setField(result, "main", {available: false});
			}
			return result;
		} catch (_:Dynamic) {
			return {available: false};
		}
	}

	private static function captureWindow():Dynamic {
		try {
			var application = new Application();
			var attributes:Dynamic = {
				width: 320,
				height: 240,
				title: "Initial title",
				resizable: false,
				minimized: false,
				maximized: false,
				context: {background: 0x123456},
				parameters: {answer: "42"}
			};
			var window = application.createWindow(cast attributes);
			if (window == null) return {available: false};

			var initial = captureWindowValue(window);
			window.move(-17, 29);
			window.resize(401, 233);
			window.fullscreen = true;
			window.title = "Mutated title";
			window.visible = false;
			window.minimized = true;
			window.maximized = true;
			window.focus();
			var mutated = captureWindowValue(window);
			var stageBeforeClose = window.stage;
			#if harness_capture
			var stageClearedOnClose = true;
			#else
			window.close();
			var stageClearedOnClose = window.stage == null;
			#end

			return {
				available: true,
				applicationWindowSameReference: application.window == window,
				initial: initial,
				mutated: mutated,
				stageLoaderParameters: Reflect.field(stageBeforeClose.loaderInfo.parameters, "answer"),
				stageClearedOnClose: stageClearedOnClose
			};
		} catch (_:Dynamic) {
			return {available: false};
		}
	}

	private static function captureWindowValue(window:Window):Dynamic {
		return {
			frameRate: window.frameRate,
			fullscreen: window.fullscreen,
			height: window.height,
			maximized: window.maximized,
			minimized: window.minimized,
			scale: window.scale,
			stagePresent: window.stage != null,
			textInputEnabled: window.textInputEnabled,
			title: window.title,
			visible: window.visible,
			width: window.width,
			x: window.x,
			y: window.y,
			signalsPresent: window.onActivate != null && window.onClose != null && window.onMove != null && window.onResize != null
		};
	}

	private static function captureRectangle(value:Rectangle):Dynamic {
		return {x: value.x, y: value.y, width: value.width, height: value.height};
	}

	private static function captureMode(value:ScreenMode):Dynamic {
		return {width: value.width, height: value.height, refreshRate: value.refreshRate};
	}
}
