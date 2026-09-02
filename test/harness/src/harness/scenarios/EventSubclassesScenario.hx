package harness.scenarios;

import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.ErrorEvent;
import openfl.events.FocusEvent;
import openfl.events.IOErrorEvent;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.events.ProgressEvent;
import openfl.events.SecurityErrorEvent;
import openfl.events.TextEvent;
import openfl.events.TimerEvent;
import openfl.ui.KeyLocation;

class EventSubclassesScenario {
	public static function run():Dynamic {
		return {
			mouseEvent: testMouseEvent(),
			keyboardEvent: testKeyboardEvent(),
			focusEvent: testFocusEvent(),
			progressEvent: testProgressEvent(),
			errorEvent: testErrorEvent(),
			ioErrorEvent: testIOErrorEvent(),
			securityErrorEvent: testSecurityErrorEvent(),
			textEvent: testTextEvent(),
			timerEvent: testTimerEvent(),
			cloneBehavior: testCloneBehavior()
		};
	}

	private static function testMouseEvent():Dynamic {
		var defaults = new MouseEvent(MouseEvent.CLICK);
		var related = new Sprite();
		var target = new Sprite();
		target.x = 100;
		target.y = -50;
		target.scaleX = 2;
		target.scaleY = 3;
		var e = new MouseEvent(MouseEvent.MOUSE_OUT, true, true, 10.5, -4.25, related, true, true, true, true, -3, true, true, 2);
		target.dispatchEvent(e);

		return {
			defaults: captureMouseEvent(defaults, null),
			values: captureMouseEvent(e, related),
			isEvent: Std.isOfType(e, Event),
			className: Type.getClassName(Type.getClass(e))
		};
	}

	private static function captureMouseEvent(event:MouseEvent, expectedRelated:Sprite):Dynamic {
		return {
			type: event.type,
			bubbles: event.bubbles,
			cancelable: event.cancelable,
			localX: event.localX,
			localY: event.localY,
			stageX: Math.isNaN(event.stageX) ? null : event.stageX,
			stageY: Math.isNaN(event.stageY) ? null : event.stageY,
			relatedObjectMatches: event.relatedObject == expectedRelated,
			ctrlKey: event.ctrlKey,
			altKey: event.altKey,
			shiftKey: event.shiftKey,
			buttonDown: event.buttonDown,
			delta: event.delta,
			commandKey: event.commandKey,
			controlKey: event.controlKey,
			clickCount: event.clickCount,
			isRelatedObjectInaccessible: event.isRelatedObjectInaccessible
		};
	}

	private static function testKeyboardEvent():Dynamic {
		var defaults = new KeyboardEvent(KeyboardEvent.KEY_DOWN);
		var e = new KeyboardEvent(KeyboardEvent.KEY_UP, true, true, 97, 222, KeyLocation.RIGHT, true, true, true, true, true);

		return {
			defaults: captureKeyboardEvent(defaults),
			values: captureKeyboardEvent(e),
			isEvent: Std.isOfType(e, Event),
			className: Type.getClassName(Type.getClass(e))
		};
	}

	private static function captureKeyboardEvent(event:KeyboardEvent):Dynamic {
		return {
			type: event.type,
			bubbles: event.bubbles,
			cancelable: event.cancelable,
			charCode: event.charCode,
			keyCode: event.keyCode,
			keyLocation: event.keyLocation,
			ctrlKey: event.ctrlKey,
			altKey: event.altKey,
			shiftKey: event.shiftKey,
			controlKey: event.controlKey,
			commandKey: event.commandKey
		};
	}

	private static function testFocusEvent():Dynamic {
		var defaults = new FocusEvent(FocusEvent.FOCUS_IN);
		var related = new Sprite();
		var e = new FocusEvent(FocusEvent.KEY_FOCUS_CHANGE, true, true, related, true, 9);

		return {
			defaults: captureFocusEvent(defaults, null),
			values: captureFocusEvent(e, related),
			isEvent: Std.isOfType(e, Event),
			className: Type.getClassName(Type.getClass(e))
		};
	}

	private static function captureFocusEvent(event:FocusEvent, expectedRelated:Sprite):Dynamic {
		var hasInaccessible = Reflect.hasField(event, "isRelatedObjectInaccessible");
		return {
			type: event.type,
			bubbles: event.bubbles,
			cancelable: event.cancelable,
			relatedObjectMatches: event.relatedObject == expectedRelated,
			shiftKey: event.shiftKey,
			keyCode: event.keyCode,
			isRelatedObjectInaccessible: {
				available: hasInaccessible,
				value: hasInaccessible ? Reflect.field(event, "isRelatedObjectInaccessible") : null
			}
		};
	}

	private static function testProgressEvent():Dynamic {
		var e = new ProgressEvent(ProgressEvent.PROGRESS, false, false, 50, 100);

		return {
			type: e.type,
			bytesLoaded: e.bytesLoaded,
			bytesTotal: e.bytesTotal,
			isEvent: Std.isOfType(e, Event),
			className: Type.getClassName(Type.getClass(e))
		};
	}

	private static function testErrorEvent():Dynamic {
		var e = new ErrorEvent(ErrorEvent.ERROR, false, false, "test error", 42);

		return {
			type: e.type,
			text: e.text,
			errorID: e.errorID,
			isEvent: Std.isOfType(e, Event),
			isTextEvent: Std.isOfType(e, TextEvent),
			className: Type.getClassName(Type.getClass(e))
		};
	}

	private static function testIOErrorEvent():Dynamic {
		var e = new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false, "io error");

		return {
			type: e.type,
			text: e.text,
			isErrorEvent: Std.isOfType(e, ErrorEvent),
			isEvent: Std.isOfType(e, Event),
			className: Type.getClassName(Type.getClass(e))
		};
	}

	private static function testSecurityErrorEvent():Dynamic {
		var e = new SecurityErrorEvent(SecurityErrorEvent.SECURITY_ERROR, false, false, "sec error");

		return {
			type: e.type,
			text: e.text,
			isErrorEvent: Std.isOfType(e, ErrorEvent),
			className: Type.getClassName(Type.getClass(e))
		};
	}

	private static function testTextEvent():Dynamic {
		var defaults = new TextEvent(TextEvent.TEXT_INPUT);
		var e = new TextEvent(TextEvent.TEXT_INPUT, false, false, "hello");

		return {
			type: e.type,
			defaultText: defaults.text,
			text: e.text,
			isEvent: Std.isOfType(e, Event),
			className: Type.getClassName(Type.getClass(e))
		};
	}

	private static function testTimerEvent():Dynamic {
		var e = new TimerEvent(TimerEvent.TIMER, false, false);

		return {
			type: e.type,
			isEvent: Std.isOfType(e, Event),
			className: Type.getClassName(Type.getClass(e))
		};
	}

	private static function testCloneBehavior():Dynamic {
		var mouse = new MouseEvent(MouseEvent.CLICK, true, false, 15.5, 25.3);
		var mouseClone = mouse.clone();

		var keyboard = new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, false, 66, 66);
		var keyClone = keyboard.clone();

		var progress = new ProgressEvent(ProgressEvent.PROGRESS, false, false, 30, 90);
		var progClone = progress.clone();

		return {
			mouseCloneType: mouseClone.type,
			mouseCloneLocalX: (cast mouseClone : MouseEvent).localX,
			mouseCloneLocalY: (cast mouseClone : MouseEvent).localY,
			mouseCloneClassName: Type.getClassName(Type.getClass(mouseClone)),
			keyCloneCharCode: (cast keyClone : KeyboardEvent).charCode,
			keyCloneKeyCode: (cast keyClone : KeyboardEvent).keyCode,
			keyCloneClassName: Type.getClassName(Type.getClass(keyClone)),
			progCloneBytesLoaded: (cast progClone : ProgressEvent).bytesLoaded,
			progCloneBytesTotal: (cast progClone : ProgressEvent).bytesTotal,
			progCloneClassName: Type.getClassName(Type.getClass(progClone))
		};
	}
}
