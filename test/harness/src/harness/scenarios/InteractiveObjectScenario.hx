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
		var values = capture(object);

		object.doubleClickEnabled = false;
		object.focusRect = null;
		object.mouseEnabled = true;
		object.needsSoftKeyboard = false;
		object.softKeyboardInputAreaOfInterest = null;
		object.tabEnabled = false;
		object.tabIndex = -1;

		return {
			defaults: defaults,
			values: values,
			restored: capture(object),
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
