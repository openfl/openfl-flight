package harness.scenarios;

import openfl.events.Event;
import openfl.events.EventPhase;

class EventConstructionScenario {
	public static function run():Dynamic {
		var defaults = new Event("test");
		var bubbling = new Event("test", true);
		var cancelable = new Event("test", false, true);
		var full = new Event("custom", true, true);
		var cloned = full.clone();

		return {
			defaults: describe(defaults),
			bubbling: describe(bubbling),
			cancelable: describe(cancelable),
			full: describe(full),
			cloned: describe(cloned),
			cloneIsNewInstance: cloned != full,
			clonePreservesType: cloned.type == full.type,
			clonePreservesBubbles: cloned.bubbles == full.bubbles,
			clonePreservesCancelable: cloned.cancelable == full.cancelable,
			preventDefault: {
				notCancelable: testPreventDefault(false),
				cancelable: testPreventDefault(true)
			},
			stopPropagation: testStopPropagation(),
			toString: {
				base: new Event("myEvent").toString(),
				withBubbles: new Event("myEvent", true).toString()
			}
		};
	}

	private static function testPreventDefault(cancelable:Bool):Dynamic {
		var e = new Event("test", false, cancelable);
		var beforePrevent = e.isDefaultPrevented();
		e.preventDefault();
		var afterPrevent = e.isDefaultPrevented();

		return {
			beforePrevent: beforePrevent,
			afterPrevent: afterPrevent
		};
	}

	private static function testStopPropagation():Dynamic {
		var e = new Event("test", true);

		return {
			initialPhase: Std.string(e.eventPhase),
			targetIsNull: e.target == null,
			currentTargetIsNull: e.currentTarget == null
		};
	}

	private static function describe(e:Event):Dynamic {
		return {
			type: e.type,
			bubbles: e.bubbles,
			cancelable: e.cancelable,
			targetIsNull: e.target == null,
			currentTargetIsNull: e.currentTarget == null
		};
	}
}
