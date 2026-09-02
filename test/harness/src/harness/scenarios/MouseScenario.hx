package harness.scenarios;

import openfl.ui.Mouse;
import openfl.ui.MouseCursor;

class MouseScenario {
	public static function run():Dynamic {
		var originalCursor = Mouse.cursor;
		var cursorReadBack = {
			auto: setAndReadCursor(MouseCursor.AUTO),
			arrow: setAndReadCursor(MouseCursor.ARROW),
			button: setAndReadCursor(MouseCursor.BUTTON),
			hand: setAndReadCursor(MouseCursor.HAND),
			ibeam: setAndReadCursor(MouseCursor.IBEAM)
		};
		Mouse.cursor = originalCursor;

		var hideDoesNotThrow = doesNotThrow(Mouse.hide);
		var showDoesNotThrow = doesNotThrow(Mouse.show);

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
			supportsCursor: Mouse.supportsCursor,
			supportsNativeCursor: Mouse.supportsNativeCursor,
			hideDoesNotThrow: hideDoesNotThrow,
			showDoesNotThrow: showDoesNotThrow
		};
	}

	private static function setAndReadCursor(cursor:MouseCursor):String {
		Mouse.cursor = cursor;
		return Std.string(Mouse.cursor);
	}

	private static function doesNotThrow(operation:Void->Void):Bool {
		try {
			operation();
			return true;
		} catch (_:Dynamic) {
			return false;
		}
	}
}
