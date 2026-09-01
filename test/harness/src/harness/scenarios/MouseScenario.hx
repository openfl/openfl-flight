package harness.scenarios;

import openfl.ui.MouseCursor;

class MouseScenario {
	public static function run():Dynamic {
		return {
			auto: MouseCursor.AUTO,
			arrow: MouseCursor.ARROW,
			button: MouseCursor.BUTTON,
			hand: MouseCursor.HAND,
			ibeam: MouseCursor.IBEAM
		};
	}
}
