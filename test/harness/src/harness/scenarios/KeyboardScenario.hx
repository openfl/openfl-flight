package harness.scenarios;

import openfl.ui.Keyboard;

class KeyboardScenario {
	public static function run():Dynamic {
		return {
			keyCodes: {
				backspace: Keyboard.BACKSPACE,
				delete: Keyboard.DELETE,
				space: Keyboard.SPACE,
				enter: Keyboard.ENTER,
				escape: Keyboard.ESCAPE,
				tab: Keyboard.TAB,
				left: Keyboard.LEFT,
				right: Keyboard.RIGHT,
				up: Keyboard.UP,
				down: Keyboard.DOWN,
				home: Keyboard.HOME,
				end: Keyboard.END
			},
			keyCodesMatchFlash: Keyboard.BACKSPACE == 8
				&& Keyboard.DELETE == 46
				&& Keyboard.ENTER == 13
				&& Keyboard.ESCAPE == 27
				&& Keyboard.SPACE == 32
				&& Keyboard.TAB == 9
				&& Keyboard.UP == 38
				&& Keyboard.DOWN == 40
				&& Keyboard.LEFT == 37
				&& Keyboard.RIGHT == 39
				&& Keyboard.HOME == 36
				&& Keyboard.END == 35,
			locks: {
				capsLock: Keyboard.capsLock,
				numLock: Keyboard.numLock,
				capsLockIsBool: Type.typeof(Keyboard.capsLock) == TBool,
				numLockIsBool: Type.typeof(Keyboard.numLock) == TBool
			},
			accessible: Keyboard.isAccessible(),
			accessibleIsBool: Type.typeof(Keyboard.isAccessible()) == TBool
		};
	}
}
