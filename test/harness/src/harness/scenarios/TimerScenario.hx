package harness.scenarios;

import openfl.events.TimerEvent;
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
			unlimited: unlimited,
			singleRepeat: testSingleRepeat(),
			infiniteRepeat: testInfiniteRepeat()
		};
	}

	private static function testSingleRepeat():Dynamic {
		var timer = new Timer(1, 1);
		var eventTypes:Array<String> = [];
		var counts:Array<Int> = [];
		var runningDuringTimer:Array<Bool> = [];
		var completeCount = 0;
		timer.addEventListener(TimerEvent.TIMER, function(event:TimerEvent):Void {
			eventTypes.push(event.type);
			counts.push(timer.currentCount);
			runningDuringTimer.push(timer.running);
		});
		timer.addEventListener(TimerEvent.TIMER_COMPLETE, function(event:TimerEvent):Void {
			eventTypes.push(event.type);
			completeCount++;
		});

		var runningBeforeStart = timer.running;
		timer.start();
		var runningAfterStart = timer.running;
		timer.start();
		var runningAfterSecondStart = timer.running;
		pumpUntil(function():Bool return completeCount == 1);
		var afterCompletion = describe(timer);
		timer.reset();

		return {
			delayIsMinimum: timer.delay,
			runningBeforeStart: runningBeforeStart,
			runningAfterStart: runningAfterStart,
			runningAfterSecondStart: runningAfterSecondStart,
			eventTypes: eventTypes,
			counts: counts,
			runningDuringTimer: runningDuringTimer,
			completeCount: completeCount,
			afterCompletion: afterCompletion,
			currentCountAfterReset: timer.currentCount,
			runningAfterReset: timer.running
		};
	}

	private static function testInfiniteRepeat():Dynamic {
		var timer = new Timer(1, 0);
		var eventTypes:Array<String> = [];
		var counts:Array<Int> = [];
		var completeCount = 0;
		timer.addEventListener(TimerEvent.TIMER, function(event:TimerEvent):Void {
			eventTypes.push(event.type);
			counts.push(timer.currentCount);
			if (counts.length == 3) timer.stop();
		});
		timer.addEventListener(TimerEvent.TIMER_COMPLETE, function(_):Void completeCount++);

		timer.start();
		var runningAfterStart = timer.running;
		timer.start();
		var runningAfterSecondStart = timer.running;
		pumpUntil(function():Bool return counts.length == 3);
		var afterStop = describe(timer);
		timer.reset();

		return {
			runningAfterStart: runningAfterStart,
			runningAfterSecondStart: runningAfterSecondStart,
			eventTypes: eventTypes,
			counts: counts,
			completeCount: completeCount,
			afterStop: afterStop,
			currentCountAfterReset: timer.currentCount
		};
	}

	private static function pumpUntil(done:Void->Bool):Void {
		var deadline = haxe.Timer.stamp() + 1;
		while (!done()) {
			if (haxe.Timer.stamp() >= deadline) throw "Timer scenario timed out";
			Sys.sleep(0.002);
			#if target.threaded
			sys.thread.Thread.current().events.progress();
			#else
			@:privateAccess haxe.MainLoop.tick();
			#end
		}
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
