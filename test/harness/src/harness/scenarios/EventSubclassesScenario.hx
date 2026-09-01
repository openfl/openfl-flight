package harness.scenarios;

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
		var e = new MouseEvent(MouseEvent.CLICK, true, false, 10.5, 20.3);

		return {
			type: e.type,
			bubbles: e.bubbles,
			cancelable: e.cancelable,
			localX: e.localX,
			localY: e.localY,
			altKey: e.altKey,
			shiftKey: e.shiftKey,
			ctrlKey: e.ctrlKey,
			buttonDown: e.buttonDown,
			delta: e.delta,
			isEvent: Std.isOfType(e, Event),
			className: Type.getClassName(Type.getClass(e))
		};
	}

	private static function testKeyboardEvent():Dynamic {
		var e = new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, false, 65, 65);

		return {
			type: e.type,
			bubbles: e.bubbles,
			charCode: e.charCode,
			keyCode: e.keyCode,
			altKey: e.altKey,
			shiftKey: e.shiftKey,
			ctrlKey: e.ctrlKey,
			isEvent: Std.isOfType(e, Event),
			className: Type.getClassName(Type.getClass(e))
		};
	}

	private static function testFocusEvent():Dynamic {
		var e = new FocusEvent(FocusEvent.FOCUS_IN, true, false);

		return {
			type: e.type,
			bubbles: e.bubbles,
			isEvent: Std.isOfType(e, Event),
			className: Type.getClassName(Type.getClass(e))
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
		var e = new TextEvent(TextEvent.TEXT_INPUT, false, false, "hello");

		return {
			type: e.type,
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
