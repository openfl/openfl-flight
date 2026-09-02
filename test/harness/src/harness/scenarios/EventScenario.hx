package harness.scenarios;

import openfl.events.Event;

class EventScenario {
	public static function run():Dynamic {
		return {
			construction: testConstruction(),
			clone: testClone(),
			strings: testStrings(),
			constants: testConstants(),
			preventDefault: testPreventDefault(),
			propagationControls: testPropagationControls()
		};
	}

	private static function testConstruction():Dynamic {
		var event = new Event("flightEvent", true, true);
		return describe(event);
	}

	private static function testClone():Dynamic {
		var original = new Event("cloneEvent", true, true);
		var clone = original.clone();
		return {
			isNewInstance: clone != original,
			properties: describe(clone),
			typeMatches: clone.type == original.type,
			bubblesMatch: clone.bubbles == original.bubbles,
			cancelableMatches: clone.cancelable == original.cancelable
		};
	}

	private static function testStrings():Dynamic {
		var event = new Event("stringEvent", true, true);
		return {
			toString: event.toString(),
			formatToString: event.formatToString("CustomEvent", "type", "bubbles", "cancelable")
		};
	}

	private static function testConstants():Dynamic {
		return {
			activate: Std.string(Event.ACTIVATE),
			deactivate: Std.string(Event.DEACTIVATE),
			added: Std.string(Event.ADDED),
			removed: Std.string(Event.REMOVED)
		};
	}

	private static function testPreventDefault():Dynamic {
		var cancelable = new Event("cancelable", false, true);
		var cancelableBefore = cancelable.isDefaultPrevented();
		cancelable.preventDefault();

		var nonCancelable = new Event("nonCancelable");
		var nonCancelableBefore = nonCancelable.isDefaultPrevented();
		nonCancelable.preventDefault();
		var nonCancelableAfter = nonCancelable.isDefaultPrevented();

		return {
			cancelableBefore: cancelableBefore,
			cancelableAfter: cancelable.isDefaultPrevented(),
			nonCancelableBefore: nonCancelableBefore,
			nonCancelableAfter: nonCancelableAfter,
			nonCancelableStaysFalse: nonCancelableAfter == false
		};
	}

	private static function testPropagationControls():Dynamic {
		return {
			stopPropagationDoesNotThrow: doesNotThrow(function():Void new Event("stop").stopPropagation()),
			stopImmediatePropagationDoesNotThrow: doesNotThrow(function():Void new Event("stopImmediate").stopImmediatePropagation())
		};
	}

	private static function describe(event:Event):Dynamic {
		return {
			type: event.type,
			bubbles: event.bubbles,
			cancelable: event.cancelable
		};
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
