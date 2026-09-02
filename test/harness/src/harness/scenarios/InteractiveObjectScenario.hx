package harness.scenarios;

import openfl.display.InteractiveObject;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.geom.Rectangle;

class InteractiveObjectScenario {
	public static function run():Dynamic {
		var object = new InteractiveObject();
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
			contextMenu: {
				available: Reflect.hasField(object, "contextMenu"),
				defaultIsNull: Reflect.field(object, "contextMenu") == null
			},
			spriteTabEnabled: testSpriteTabEnabled(),
			mouseEnabledEvents: testMouseEnabledEvents()
		};
	}

	private static function capture(object:InteractiveObject):Dynamic {
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

	private static function testSpriteTabEnabled():Dynamic {
		var implicit = new Sprite();
		var defaultValue = implicit.tabEnabled;
		implicit.buttonMode = true;
		var buttonModeValue = implicit.tabEnabled;
		implicit.buttonMode = false;

		var explicit = new Sprite();
		explicit.buttonMode = true;
		explicit.tabEnabled = false;
		var explicitFalse = explicit.tabEnabled;
		explicit.buttonMode = false;
		var explicitFalseAfterButtonMode = explicit.tabEnabled;
		explicit.tabEnabled = true;

		return {
			defaultValue: defaultValue,
			buttonModeValue: buttonModeValue,
			afterButtonModeCleared: implicit.tabEnabled,
			explicitFalseWithButtonMode: explicitFalse,
			explicitFalseAfterButtonMode: explicitFalseAfterButtonMode,
			explicitTrue: explicit.tabEnabled
		};
	}

	private static function testMouseEnabledEvents():Dynamic {
		var object = new Sprite();
		var received = 0;
		object.addEventListener(MouseEvent.CLICK, function(_) received++);

		object.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		var enabledCount = received;
		object.mouseEnabled = false;
		object.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		var disabledCount = received;
		object.mouseEnabled = true;
		object.dispatchEvent(new MouseEvent(MouseEvent.CLICK));

		return {
			enabledCount: enabledCount,
			disabledCount: disabledCount,
			reenabledCount: received,
			programmaticDispatchWhileDisabled: disabledCount > enabledCount
		};
	}
}
