package harness.scenarios;

import openfl.utils.Timer;

class TimerScenario {
	public static function run():Dynamic {
		var timer = new Timer(25, 3);
		var initial = describe(timer);

		timer.delay = 40;
		timer.repeatCount = 5;
		var updated = describe(timer);

		timer.delay = 0;
		timer.repeatCount = 0;
		var unlimited = describe(timer);

		return {
			initial: initial,
			updated: updated,
			unlimited: unlimited
		};
	}

	private static function describe(timer:Timer):Dynamic {
		return {
			delay: timer.delay,
			repeatCount: timer.repeatCount,
			currentCount: timer.currentCount,
			running: timer.running
		};
	}
}
