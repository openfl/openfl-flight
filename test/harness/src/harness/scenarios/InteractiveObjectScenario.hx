package harness.scenarios;

import openfl.display.Sprite;
import openfl.geom.Rectangle;

class InteractiveObjectScenario {
	public static function run():Dynamic {
		var object = new Sprite();
		var defaults = capture(object);

		object.doubleClickEnabled = true;
		object.focusRect = false;
		object.mouseEnabled = false;
		object.needsSoftKeyboard = true;
		object.softKeyboardInputAreaOfInterest = new Rectangle(1.5, 2.5, 30.5, 40.5);
		object.tabEnabled = true;
		object.tabIndex = 7;

		return {
			defaults: defaults,
			values: capture(object),
			requestSoftKeyboard: object.requestSoftKeyboard(),
			contextMenuProperty: Reflect.hasField(object, "contextMenu")
		};
	}

	private static function capture(object:Sprite):Dynamic {
		var area = object.softKeyboardInputAreaOfInterest;
		return {
			doubleClickEnabled: object.doubleClickEnabled,
			focusRect: object.focusRect,
			mouseEnabled: object.mouseEnabled,
			needsSoftKeyboard: object.needsSoftKeyboard,
			softKeyboardInputAreaOfInterest: area == null ? null : {
				x: area.x,
				y: area.y,
				width: area.width,
				height: area.height
			},
			tabEnabled: object.tabEnabled,
			tabIndex: object.tabIndex
		};
	}
}
