package harness.scenarios;

import openfl.events.Event;
import openfl.events.EventDispatcher;

class EventDispatcherScenario {
	public static function run():Dynamic {
		return {
			basicDispatch: testBasicDispatch(),
			multipleListeners: testMultipleListeners(),
			removeListener: testRemoveListener(),
			hasEventListener: testHasEventListener(),
			priority: testPriority(),
			duplicateListener: testDuplicateListener(),
			dispatchReturnValue: testDispatchReturnValue(),
			targetAndCurrentTarget: testTargetAndCurrentTarget(),
			listenerDuringDispatch: testListenerDuringDispatch(),
			removeDuringDispatch: testRemoveDuringDispatch(),
			aggregatedTarget: testAggregatedTarget(),
			noListeners: testNoListeners(),
			nestedDispatch: testNestedDispatch(),
			nestedDispatchMutation: testNestedDispatchMutation(),
			toString: new EventDispatcher().toString()
		};
	}

	private static function testBasicDispatch():Dynamic {
		var dispatcher = new EventDispatcher();
		var log = new Array<String>();

		dispatcher.addEventListener("test", function(e:Event):Void {
			log.push("heard");
		});

		dispatcher.dispatchEvent(new Event("test"));
		dispatcher.dispatchEvent(new Event("test"));

		return {
			callCount: log.length
		};
	}

	private static function testMultipleListeners():Dynamic {
		var dispatcher = new EventDispatcher();
		var log = new Array<String>();

		dispatcher.addEventListener("test", function(e:Event):Void {
			log.push("first");
		});
		dispatcher.addEventListener("test", function(e:Event):Void {
			log.push("second");
		});
		dispatcher.addEventListener("other", function(e:Event):Void {
			log.push("other");
		});

		dispatcher.dispatchEvent(new Event("test"));

		return {
			log: log.join(","),
			count: log.length
		};
	}

	private static function testRemoveListener():Dynamic {
		var dispatcher = new EventDispatcher();
		var log = new Array<String>();

		var listener = function(e:Event):Void {
			log.push("heard");
		};

		dispatcher.addEventListener("test", listener);
		dispatcher.dispatchEvent(new Event("test"));
		dispatcher.removeEventListener("test", listener);
		dispatcher.dispatchEvent(new Event("test"));

		return {
			callCount: log.length,
			hasAfterRemove: dispatcher.hasEventListener("test")
		};
	}

	private static function testHasEventListener():Dynamic {
		var dispatcher = new EventDispatcher();
		var before = dispatcher.hasEventListener("test");

		var listener = function(e:Event):Void {};
		dispatcher.addEventListener("test", listener);
		var during = dispatcher.hasEventListener("test");
		var wrongType = dispatcher.hasEventListener("other");

		dispatcher.removeEventListener("test", listener);
		var after = dispatcher.hasEventListener("test");

		return {
			before: before,
			during: during,
			wrongType: wrongType,
			after: after
		};
	}

	private static function testPriority():Dynamic {
		var dispatcher = new EventDispatcher();
		var log = new Array<String>();

		dispatcher.addEventListener("test", function(e:Event):Void {
			log.push("normal");
		}, false, 0);
		dispatcher.addEventListener("test", function(e:Event):Void {
			log.push("high");
		}, false, 10);
		dispatcher.addEventListener("test", function(e:Event):Void {
			log.push("low");
		}, false, -5);
		dispatcher.addEventListener("test", function(e:Event):Void {
			log.push("medium");
		}, false, 5);

		dispatcher.dispatchEvent(new Event("test"));

		return {
			order: log.join(",")
		};
	}

	private static function testDuplicateListener():Dynamic {
		var dispatcher = new EventDispatcher();
		var log = new Array<String>();

		var listener = function(e:Event):Void {
			log.push("heard");
		};

		dispatcher.addEventListener("test", listener);
		dispatcher.addEventListener("test", listener);
		dispatcher.dispatchEvent(new Event("test"));

		return {
			callCount: log.length
		};
	}

	private static function testDispatchReturnValue():Dynamic {
		var dispatcher = new EventDispatcher();

		var noListenerResult = dispatcher.dispatchEvent(new Event("test"));

		dispatcher.addEventListener("test", function(e:Event):Void {});
		var listenerResult = dispatcher.dispatchEvent(new Event("test"));

		dispatcher.addEventListener("cancel", function(e:Event):Void {
			e.preventDefault();
		});
		var cancelableResult = dispatcher.dispatchEvent(new Event("cancel", false, true));
		var nonCancelableResult = dispatcher.dispatchEvent(new Event("test", false, true));

		return {
			noListener: noListenerResult,
			withListener: listenerResult,
			canceledEvent: cancelableResult,
			nonCanceledEvent: nonCancelableResult
		};
	}

	private static function testTargetAndCurrentTarget():Dynamic {
		var dispatcher = new EventDispatcher();
		var targetType:String = null;
		var currentTargetType:String = null;
		var targetIsDispatcher:Bool = false;

		dispatcher.addEventListener("test", function(e:Event):Void {
			targetType = Type.getClassName(Type.getClass(e.target));
			currentTargetType = Type.getClassName(Type.getClass(e.currentTarget));
			targetIsDispatcher = e.target == dispatcher;
		});

		dispatcher.dispatchEvent(new Event("test"));

		return {
			targetIsDispatcher: targetIsDispatcher,
			targetEquals: targetType == currentTargetType
		};
	}

	private static function testListenerDuringDispatch():Dynamic {
		var dispatcher = new EventDispatcher();
		var log = new Array<String>();

		dispatcher.addEventListener("test", function(e:Event):Void {
			log.push("first");
			dispatcher.addEventListener("test", function(e:Event):Void {
				log.push("added-during");
			});
		});

		dispatcher.dispatchEvent(new Event("test"));
		var firstRound = log.join(",");

		log.splice(0, log.length);
		dispatcher.dispatchEvent(new Event("test"));
		var secondRound = log.join(",");

		return {
			firstDispatch: firstRound,
			secondDispatch: secondRound
		};
	}

	private static function testRemoveDuringDispatch():Dynamic {
		var dispatcher = new EventDispatcher();
		var log = new Array<String>();

		var secondListener:Event->Void = null;

		secondListener = function(e:Event):Void {
			log.push("second");
		};

		dispatcher.addEventListener("test", function(e:Event):Void {
			log.push("first");
			dispatcher.removeEventListener("test", secondListener);
		});
		dispatcher.addEventListener("test", secondListener);

		dispatcher.dispatchEvent(new Event("test"));

		return {
			log: log.join(",")
		};
	}

	private static function testAggregatedTarget():Dynamic {
		var outer = new EventDispatcher();
		var inner = new EventDispatcher(outer);
		var capturedTarget:Dynamic = null;

		inner.addEventListener("test", function(e:Event):Void {
			capturedTarget = e.target;
		});

		inner.dispatchEvent(new Event("test"));

		return {
			targetIsOuter: capturedTarget == outer
		};
	}

	private static function testNestedDispatch():Dynamic {
		var o = new EventDispatcher();
		var callCount = 0;

		var listener:Event->Void = null;
		listener = function(e:Event):Void {
			callCount++;
			if (callCount == 1) {
				o.dispatchEvent(new Event("nested"));
			}
		};

		o.addEventListener("nested", listener);
		o.dispatchEvent(new Event("nested"));

		return {
			callCount: callCount
		};
	}

	private static function testNestedDispatchMutation():Dynamic {
		var callCount = 0;
		var sequence = "";
		var o = new EventDispatcher();

		var listenerB:Event->Void = null;
		var listenerC:Event->Void = null;

		listenerB = function(e:Event):Void {
			sequence += "b";
		};

		listenerC = function(e:Event):Void {
			sequence += "c";
		};

		var listenerA:Event->Void = null;
		listenerA = function(e:Event):Void {
			sequence += "a";
			callCount++;
			if (callCount == 1) {
				sequence += "(";
				o.dispatchEvent(new Event("mut"));
				sequence += ")";
				o.removeEventListener("mut", listenerB);
				o.addEventListener("mut", listenerC, false, 4);
				o.addEventListener("mut", listenerB, false, 5);
			}
		};

		o.addEventListener("mut", listenerA, false, 3);
		o.addEventListener("mut", listenerB, false, 2);
		o.addEventListener("mut", listenerC, false, 1);
		o.dispatchEvent(new Event("mut"));

		return {
			sequence: sequence
		};
	}

	private static function testNoListeners():Dynamic {
		var dispatcher = new EventDispatcher();
		var result = dispatcher.dispatchEvent(new Event("nothing"));

		return {
			result: result,
			has: dispatcher.hasEventListener("nothing")
		};
	}
}
