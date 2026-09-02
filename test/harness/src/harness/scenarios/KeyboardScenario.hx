package harness.scenarios;

import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;
import openfl.ui.KeyLocation;

class KeyboardScenario
{
	public static function run():Dynamic
	{
		var numbers = [
			Keyboard.NUMBER_0, Keyboard.NUMBER_1, Keyboard.NUMBER_2, Keyboard.NUMBER_3, Keyboard.NUMBER_4,
			Keyboard.NUMBER_5, Keyboard.NUMBER_6, Keyboard.NUMBER_7, Keyboard.NUMBER_8, Keyboard.NUMBER_9
		];
		var letters = [
			Keyboard.A, Keyboard.B, Keyboard.C, Keyboard.D, Keyboard.E, Keyboard.F, Keyboard.G, Keyboard.H, Keyboard.I, Keyboard.J, Keyboard.K,
			Keyboard.L, Keyboard.M, Keyboard.N, Keyboard.O, Keyboard.P, Keyboard.Q, Keyboard.R, Keyboard.S, Keyboard.T, Keyboard.U, Keyboard.V,
			Keyboard.W, Keyboard.X, Keyboard.Y, Keyboard.Z
		];
		var numpadDigits = [
			Keyboard.NUMPAD_0, Keyboard.NUMPAD_1, Keyboard.NUMPAD_2, Keyboard.NUMPAD_3, Keyboard.NUMPAD_4,
			Keyboard.NUMPAD_5, Keyboard.NUMPAD_6, Keyboard.NUMPAD_7, Keyboard.NUMPAD_8, Keyboard.NUMPAD_9
		];
		var numpadOperators = [
			Keyboard.NUMPAD_MULTIPLY, Keyboard.NUMPAD_ADD, Keyboard.NUMPAD_ENTER,
			Keyboard.NUMPAD_SUBTRACT, Keyboard.NUMPAD_DECIMAL, Keyboard.NUMPAD_DIVIDE
		];
		var functionKeys = [
			Keyboard.F1, Keyboard.F2, Keyboard.F3, Keyboard.F4, Keyboard.F5, Keyboard.F6, Keyboard.F7, Keyboard.F8,
			Keyboard.F9, Keyboard.F10, Keyboard.F11, Keyboard.F12, Keyboard.F13, Keyboard.F14, Keyboard.F15
		];
		var controls = [
			Keyboard.BACKSPACE, Keyboard.TAB, Keyboard.ALTERNATE, Keyboard.ENTER, Keyboard.COMMAND, Keyboard.SHIFT, Keyboard.CONTROL,
			Keyboard.BREAK, Keyboard.CAPS_LOCK, Keyboard.NUMPAD, Keyboard.ESCAPE, Keyboard.SPACE, Keyboard.PAGE_UP, Keyboard.PAGE_DOWN,
			Keyboard.END, Keyboard.HOME, Keyboard.LEFT, Keyboard.RIGHT, Keyboard.UP, Keyboard.DOWN, Keyboard.INSERT, Keyboard.DELETE, Keyboard.NUMLOCK
		];
		var punctuation = [
			Keyboard.SEMICOLON, Keyboard.EQUAL, Keyboard.COMMA, Keyboard.MINUS, Keyboard.PERIOD,
			Keyboard.SLASH, Keyboard.BACKQUOTE, Keyboard.LEFTBRACKET, Keyboard.BACKSLASH, Keyboard.RIGHTBRACKET, Keyboard.QUOTE
		];

		var accessibleFirst = Keyboard.isAccessible();
		var accessibleSecond = Keyboard.isAccessible();
		var keyboardEvent = new KeyboardEvent(KeyboardEvent.KEY_UP, true, true, 97, Keyboard.F5, KeyLocation.RIGHT, true, true, true, true, true);

		return {
			keyCodes: {
				numbers: numbers,
				letters: letters,
				numpadDigits: numpadDigits,
				numpadOperators: numpadOperators,
				functionKeys: functionKeys,
				controls: controls,
				punctuation: punctuation
			},
			allKeyCodesMatchExpected: arraysEqual(numbers, range(48, 10))
				&& arraysEqual(letters, range(65, 26))
				&& arraysEqual(numpadDigits, range(96, 10))
				&& arraysEqual(numpadOperators, range(106, 6))
				&& arraysEqual(functionKeys, range(112, 15))
				&& arraysEqual(controls, [8, 9, 18, 13, 15, 16, 17, 19, 20, 21, 27, 32, 33, 34, 35, 36, 37, 39, 38, 40, 45, 46, 144])
				&& arraysEqual(punctuation, [186, 187, 188, 189, 190, 191, 192, 219, 220, 221, 222]),
			locks: {
				capsLock: Keyboard.capsLock,
				numLock: Keyboard.numLock,
				capsLockReadable: doesNotThrow(function() return Keyboard.capsLock),
				numLockReadable: doesNotThrow(function() return Keyboard.numLock),
				capsLockIsBool: Type.typeof(Keyboard.capsLock) == TBool,
				numLockIsBool: Type.typeof(Keyboard.numLock) == TBool
			},
			accessible: {
				first: accessibleFirst,
				second: accessibleSecond,
				stable: accessibleFirst == accessibleSecond,
				readable: Type.typeof(accessibleFirst) == TBool && Type.typeof(accessibleSecond) == TBool
			},
			keyboardEvent: {
				type: keyboardEvent.type,
				bubbles: keyboardEvent.bubbles,
				cancelable: keyboardEvent.cancelable,
				charCode: keyboardEvent.charCode,
				keyCode: keyboardEvent.keyCode,
				keyLocation: keyboardEvent.keyLocation,
				ctrlKey: keyboardEvent.ctrlKey,
				altKey: keyboardEvent.altKey,
				shiftKey: keyboardEvent.shiftKey,
				controlKey: keyboardEvent.controlKey,
				commandKey: keyboardEvent.commandKey
			}
		};
	}

	private static function arraysEqual(actual:Array<Int>, expected:Array<Int>):Bool
	{
		if (actual.length != expected.length) return false;
		for (index in 0...actual.length)
		{
			if (actual[index] != expected[index]) return false;
		}
		return true;
	}

	private static function range(start:Int, length:Int):Array<Int>
	{
		return [for (value in start...start + length) value];
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
