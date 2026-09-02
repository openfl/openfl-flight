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
		Mouse.cursor = originalCursor;

		var hideDoesNotThrow = doesNotThrow(function() {
			Mouse.hide();
			return null;
		});
		var showDoesNotThrow = doesNotThrow(function() {
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

		return {
			cursorValues: {
				auto: Std.string(MouseCursor.AUTO),
				arrow: Std.string(MouseCursor.ARROW),
				button: Std.string(MouseCursor.BUTTON),
				hand: Std.string(MouseCursor.HAND),
				ibeam: Std.string(MouseCursor.IBEAM)
			},
			cursorReadBack: cursorReadBack,
			cursorRestored: Mouse.cursor == originalCursor,
			capabilities: {
				supportsCursor: Mouse.supportsCursor,
				supportsNativeCursor: Mouse.supportsNativeCursor,
				readable: doesNotThrow(function() return Mouse.supportsCursor) && doesNotThrow(function() return Mouse.supportsNativeCursor)
			},
			hideDoesNotThrow: hideDoesNotThrow,
			showDoesNotThrow: showDoesNotThrow,
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
				clickCount: mouseEvent.clickCount
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
