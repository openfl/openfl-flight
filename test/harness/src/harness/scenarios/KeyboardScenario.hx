package harness.scenarios;

import openfl.ui.Keyboard;

class KeyboardScenario {
	public static function run():Dynamic {
		return {
			keyCodes: {
				a: Keyboard.A,
				space: Keyboard.SPACE,
				enter: Keyboard.ENTER,
				escape: Keyboard.ESCAPE,
				left: Keyboard.LEFT,
				right: Keyboard.RIGHT,
				up: Keyboard.UP,
				down: Keyboard.DOWN
			},
			locks: {
				capsLock: Keyboard.capsLock,
				numLock: Keyboard.numLock,
				capsLockIsBool: Type.typeof(Keyboard.capsLock) == TBool,
				numLockIsBool: Type.typeof(Keyboard.numLock) == TBool
			}
		};
	}
}
