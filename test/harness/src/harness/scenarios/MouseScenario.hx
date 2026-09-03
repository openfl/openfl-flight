package harness.scenarios;

import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.ui.Mouse;
import openfl.ui.MouseCursor;

class MouseScenario
{
	public static function run():Dynamic
	{
		var originalCursor = Mouse.cursor;
		var cursorReadBack = {
			auto: setAndReadCursor(MouseCursor.AUTO),
			arrow: setAndReadCursor(MouseCursor.ARROW),
			button: setAndReadCursor(MouseCursor.BUTTON),
			hand: setAndReadCursor(MouseCursor.HAND),
			ibeam: setAndReadCursor(MouseCursor.IBEAM)
		};
		Mouse.cursor = null;
		var nullCursorReadBack = Std.string(Mouse.cursor);
		Mouse.cursor = originalCursor;

		var hideDoesNotThrow = doesNotThrow(function() {
			Mouse.hide();
			return null;
		});
		var showDoesNotThrow = doesNotThrow(function() {
			Mouse.show();
			return null;
		});
		var repeatedVisibilityDoesNotThrow = doesNotThrow(function() {
			Mouse.hide();
			Mouse.hide();
			Mouse.show();
			Mouse.show();
			return null;
		});
		var related = new Sprite();
		var target = new Sprite();
		target.x = 100;
		target.y = -50;
		target.scaleX = 2;
		target.scaleY = 3;
		var mouseEvent = new MouseEvent(MouseEvent.MOUSE_WHEEL, true, true, 10.5, -4.25, related, true, true, true, true, -3, true, true, 2);
		var stageInitiallyNaN = Math.isNaN(mouseEvent.stageX) && Math.isNaN(mouseEvent.stageY);
		target.dispatchEvent(mouseEvent);
		var clone = mouseEvent.clone();
		var updateAfterEventDoesNotThrow = doesNotThrow(function() {
			mouseEvent.updateAfterEvent();
			return null;
		});

		return {
			eventConstants: {
				click: Std.string(MouseEvent.CLICK),
				doubleClick: Std.string(MouseEvent.DOUBLE_CLICK),
				middleClick: Std.string(MouseEvent.MIDDLE_CLICK),
				middleMouseDown: Std.string(MouseEvent.MIDDLE_MOUSE_DOWN),
				middleMouseUp: Std.string(MouseEvent.MIDDLE_MOUSE_UP),
				mouseDown: Std.string(MouseEvent.MOUSE_DOWN),
				mouseMove: Std.string(MouseEvent.MOUSE_MOVE),
				mouseOut: Std.string(MouseEvent.MOUSE_OUT),
				mouseOver: Std.string(MouseEvent.MOUSE_OVER),
				mouseUp: Std.string(MouseEvent.MOUSE_UP),
				mouseWheel: Std.string(MouseEvent.MOUSE_WHEEL),
				releaseOutside: Std.string(MouseEvent.RELEASE_OUTSIDE),
				rightClick: Std.string(MouseEvent.RIGHT_CLICK),
				rightMouseDown: Std.string(MouseEvent.RIGHT_MOUSE_DOWN),
				rightMouseUp: Std.string(MouseEvent.RIGHT_MOUSE_UP),
				rollOut: Std.string(MouseEvent.ROLL_OUT),
				rollOver: Std.string(MouseEvent.ROLL_OVER)
			},
			cursorValues: {
				auto: Std.string(MouseCursor.AUTO),
				arrow: Std.string(MouseCursor.ARROW),
				button: Std.string(MouseCursor.BUTTON),
				hand: Std.string(MouseCursor.HAND),
				ibeam: Std.string(MouseCursor.IBEAM)
			},
			cursorReadBack: cursorReadBack,
			nullCursorReadBack: nullCursorReadBack,
			cursorRestored: Mouse.cursor == originalCursor,
			cursorRegistrationAbsent: !Reflect.hasField(Mouse, "registerCursor") && !Reflect.hasField(Mouse, "unregisterCursor"),
			capabilities: {
				supportsCursor: Mouse.supportsCursor,
				supportsNativeCursor: Mouse.supportsNativeCursor,
				readable: doesNotThrow(function() return Mouse.supportsCursor) && doesNotThrow(function() return Mouse.supportsNativeCursor)
			},
			hideDoesNotThrow: hideDoesNotThrow,
			repeatedVisibilityDoesNotThrow: repeatedVisibilityDoesNotThrow,
			showDoesNotThrow: showDoesNotThrow,
			updateAfterEventDoesNotThrow: updateAfterEventDoesNotThrow,
			mouseEvent: {
				type: mouseEvent.type,
				bubbles: mouseEvent.bubbles,
				cancelable: mouseEvent.cancelable,
				localX: mouseEvent.localX,
				localY: mouseEvent.localY,
				stageInitiallyNaN: stageInitiallyNaN,
				stageX: mouseEvent.stageX,
				stageY: mouseEvent.stageY,
				relatedObjectMatches: mouseEvent.relatedObject == related,
				ctrlKey: mouseEvent.ctrlKey,
				altKey: mouseEvent.altKey,
				shiftKey: mouseEvent.shiftKey,
				buttonDown: mouseEvent.buttonDown,
				delta: mouseEvent.delta,
				commandKey: mouseEvent.commandKey,
				controlKey: mouseEvent.controlKey,
				clickCount: mouseEvent.clickCount,
				isRelatedObjectInaccessible: mouseEvent.isRelatedObjectInaccessible
			},
			mouseEventClone: {
				buttonDown: clone.buttonDown,
				clickCount: clone.clickCount,
				commandKey: clone.commandKey,
				controlKey: clone.controlKey,
				localX: clone.localX,
				localY: clone.localY,
				relatedObjectMatches: clone.relatedObject == related,
				targetMatches: clone.target == target,
				type: clone.type
			}
		};
	}

	private static function setAndReadCursor(cursor:MouseCursor):String
	{
		Mouse.cursor = cursor;
		return Std.string(Mouse.cursor);
	}

	private static function doesNotThrow(operation:Void->Dynamic):Bool
	{
		try
		{
			operation();
			return true;
		}
		catch (_:Dynamic)
		{
			return false;
		}
	}
}
