package harness.scenarios;

import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.EventDispatcher;

class EventDispatcherCaptureScenario {
	public static function run():Dynamic {
		return {
			captureVsNormal: testCaptureVsNormal(),
			captureSameListener: testCaptureSameListener(),
			removeCaptureOnly: testRemoveCaptureOnly(),
			removeCaptureFlagMatch: testRemoveCaptureFlagMatch(),
			capturePriority: testCapturePriority(),
			multipleCaptures: testMultipleCaptures(),
			stopPropagationDuringCapture: testStopPropagationDuringCapture(),
			eventPhases: testEventPhases(),
			hasEventListenerCapture: testHasEventListenerCapture(),
			stopImmediatePropagation: testStopImmediate(),
			willTrigger: testWillTrigger(),
			nullListener: testNullListener(),
			nullDispatch: testNullDispatch(),
			weakReferenceFallback: testWeakReferenceFallback(),
			removeReaddDuringDispatch: testRemoveReaddDuringDispatch(),
			reparentDuringCapture: testReparentDuringCapture(),
			postDispatchState: testPostDispatchState(),
			bubblePreventDefault: testBubblePreventDefault()
		};
	}

	private static function testRemoveCaptureFlagMatch():Dynamic {
		var parent = new Sprite();
		var target = new Sprite();
		parent.addChild(target);
		var calls = 0;
		var listener = function(event:Event):Void {
			calls++;
		};

		parent.addEventListener("removeFlag", listener, true);
		parent.removeEventListener("removeFlag", listener, false);
		target.dispatchEvent(new Event("removeFlag", true));
		var afterMismatchedRemove = calls;

		parent.removeEventListener("removeFlag", listener, true);
		target.dispatchEvent(new Event("removeFlag", true));
		return {
			afterMismatchedRemove: afterMismatchedRemove,
			afterMatchingRemove: calls,
			stillHasListener: parent.hasEventListener("removeFlag")
		};
	}

	private static function testCapturePriority():Dynamic {
		var parent = new Sprite();
		var target = new Sprite();
		parent.addChild(target);
		var log = new Array<String>();

		parent.addEventListener("priority", function(event:Event):Void {
			log.push("low");
		}, true, -10);
		parent.addEventListener("priority", function(event:Event):Void {
			log.push("high");
		}, true, 20);
		parent.addEventListener("priority", function(event:Event):Void {
			log.push("middle");
		}, true, 0);

		target.dispatchEvent(new Event("priority", true));
		return {
			log: log.join(","),
			count: log.length
		};
	}

	private static function testMultipleCaptures():Dynamic {
		var parent = new Sprite();
		var target = new Sprite();
		parent.addChild(target);
		var log = new Array<String>();

		parent.addEventListener("multiple", function(event:Event):Void {
			log.push("first");
		}, true);
		parent.addEventListener("multiple", function(event:Event):Void {
			log.push("second");
		}, true);
		parent.addEventListener("multiple", function(event:Event):Void {
			log.push("third");
		}, true);

		target.dispatchEvent(new Event("multiple", true));
		return {
			log: log.join(","),
			count: log.length
		};
	}

	private static function testStopPropagationDuringCapture():Dynamic {
		var root = new Sprite();
		var parent = new Sprite();
		var target = new Sprite();
		root.addChild(parent);
		parent.addChild(target);
		var log = new Array<String>();

		root.addEventListener("captureStop", function(event:Event):Void {
			log.push("root-first");
			event.stopPropagation();
		}, true);
		root.addEventListener("captureStop", function(event:Event):Void {
			log.push("root-second");
		}, true);
		parent.addEventListener("captureStop", function(event:Event):Void {
			log.push("parent-capture");
		}, true);
		target.addEventListener("captureStop", function(event:Event):Void {
			log.push("target");
		});
		parent.addEventListener("captureStop", function(event:Event):Void {
			log.push("parent-bubble");
		});

		target.dispatchEvent(new Event("captureStop", true));
		return {
			log: log.join(","),
			count: log.length
		};
	}

	private static function testEventPhases():Dynamic {
		var root = namedSprite("root");
		var parent = namedSprite("parent");
		var target = namedSprite("target");
		root.addChild(parent);
		parent.addChild(target);
		var log = new Array<Dynamic>();

		root.addEventListener("phases", recordPhase(log, "root-capture"), true);
		parent.addEventListener("phases", recordPhase(log, "parent-capture"), true);
		target.addEventListener("phases", recordPhase(log, "target"));
		parent.addEventListener("phases", recordPhase(log, "parent-bubble"));
		root.addEventListener("phases", recordPhase(log, "root-bubble"));
		target.dispatchEvent(new Event("phases", true));

		return log;
	}

	private static function namedSprite(name:String):Sprite {
		var sprite = new Sprite();
		sprite.name = name;
		return sprite;
	}

	private static function recordPhase(log:Array<Dynamic>, listener:String):Event->Void {
		return function(event:Event):Void {
			log.push({
				listener: listener,
				phase: cast event.eventPhase,
				target: cast(event.target, Sprite).name,
				currentTarget: cast(event.currentTarget, Sprite).name
			});
		};
	}

	private static function testCaptureVsNormal():Dynamic {
		var dispatcher = new EventDispatcher();
		var log = new Array<String>();

		dispatcher.addEventListener("test", function(e:Event):Void {
			log.push("normal");
		}, false);
		dispatcher.addEventListener("test", function(e:Event):Void {
			log.push("capture");
		}, true);

		dispatcher.dispatchEvent(new Event("test"));

		return {
			log: log.join(","),
			count: log.length
		};
	}

	private static function testCaptureSameListener():Dynamic {
		var dispatcher = new EventDispatcher();
		var log = new Array<String>();

		var listener = function(e:Event):Void {
			log.push("heard");
		};

		dispatcher.addEventListener("test", listener, false);
		dispatcher.addEventListener("test", listener, true);
		dispatcher.dispatchEvent(new Event("test"));

		return {
			callCount: log.length,
			hasNormal: dispatcher.hasEventListener("test")
		};
	}

	private static function testRemoveCaptureOnly():Dynamic {
		var dispatcher = new EventDispatcher();
		var log = new Array<String>();

		var listener = function(e:Event):Void {
			log.push("heard");
		};

		dispatcher.addEventListener("test", listener, false);
		dispatcher.addEventListener("test", listener, true);
		dispatcher.removeEventListener("test", listener, true);
		dispatcher.dispatchEvent(new Event("test"));

		return {
			callCount: log.length,
			stillHasListener: dispatcher.hasEventListener("test")
		};
	}

	private static function testHasEventListenerCapture():Dynamic {
		var dispatcher = new EventDispatcher();

		dispatcher.addEventListener("test", function(e:Event):Void {}, true);

		return {
			hasTest: dispatcher.hasEventListener("test")
		};
	}

	private static function testStopImmediate():Dynamic {
		var dispatcher = new EventDispatcher();
		var log = new Array<String>();

		dispatcher.addEventListener("test", function(e:Event):Void {
			log.push("first");
			e.stopImmediatePropagation();
		});
		dispatcher.addEventListener("test", function(e:Event):Void {
			log.push("second");
		});

		dispatcher.dispatchEvent(new Event("test"));

		return {
			log: log.join(",")
		};
	}

	private static function testWillTrigger():Dynamic {
		var dispatcher = new EventDispatcher();
		var genericBefore = dispatcher.willTrigger("test");

		dispatcher.addEventListener("test", function(e:Event):Void {});
		var genericAfter = dispatcher.willTrigger("test");

		var root = new Sprite();
		var parent = new Sprite();
		var target = new Sprite();
		root.addChild(parent);
		parent.addChild(target);
		var ancestorListener = function(e:Event):Void {};
		root.addEventListener("ancestor", ancestorListener);
		var targetHasAncestor = target.hasEventListener("ancestor");
		var targetWillTriggerAncestor = target.willTrigger("ancestor");
		var aggregate = new EventDispatcher(target);
		var aggregateWillTriggerAncestor = aggregate.willTrigger("ancestor");
		root.removeEventListener("ancestor", ancestorListener);
		var afterAncestorRemove = target.willTrigger("ancestor");
		target.addEventListener("local", function(e:Event):Void {});

		return {
			genericBefore: genericBefore,
			genericAfter: genericAfter,
			targetHasAncestor: targetHasAncestor,
			targetWillTriggerAncestor: targetWillTriggerAncestor,
			aggregateWillTriggerAncestor: aggregateWillTriggerAncestor,
			afterAncestorRemove: afterAncestorRemove,
			targetHasLocal: target.hasEventListener("local"),
			targetWillTriggerLocal: target.willTrigger("local")
		};
	}

	private static function testNullListener():Dynamic {
		var dispatcher = new EventDispatcher();
		dispatcher.addEventListener("test", null);
		dispatcher.removeEventListener("test", null);

		return {
			hasListener: dispatcher.hasEventListener("test")
		};
	}

	private static function testNullDispatch():Dynamic {
		return {
			genericError: captureError(function() new EventDispatcher().dispatchEvent(null)),
			displayError: captureError(function() new Sprite().dispatchEvent(null))
		};
	}

	private static function testWeakReferenceFallback():Dynamic {
		var dispatcher = new EventDispatcher();
		var calls = 0;
		var listener = function(_:Event):Void calls++;
		dispatcher.addEventListener("weak", listener, false, 0, true);
		dispatcher.dispatchEvent(new Event("weak"));
		return {
			calls: calls,
			hasListener: dispatcher.hasEventListener("weak")
		};
	}

	private static function testRemoveReaddDuringDispatch():Dynamic {
		var dispatcher = new EventDispatcher();
		var log:Array<String> = [];
		var firstDispatch = true;
		var second:Event->Void = function(_:Event):Void log.push("second");
		dispatcher.addEventListener("mutate", function(_:Event):Void {
			log.push("first");
			if (firstDispatch) {
				firstDispatch = false;
				dispatcher.removeEventListener("mutate", second);
				dispatcher.addEventListener("mutate", second);
			}
		}, false, 10);
		dispatcher.addEventListener("mutate", second);
		dispatcher.dispatchEvent(new Event("mutate"));
		var first = log.join(",");
		log.resize(0);
		dispatcher.dispatchEvent(new Event("mutate"));
		return {
			first: first,
			second: log.join(",")
		};
	}

	private static function testReparentDuringCapture():Dynamic {
		var firstRoot = namedSprite("firstRoot");
		var secondRoot = namedSprite("secondRoot");
		var parent = namedSprite("parent");
		var target = namedSprite("target");
		firstRoot.addChild(parent);
		parent.addChild(target);
		var log:Array<String> = [];
		firstRoot.addEventListener("reparent", function(_:Event):Void {
			log.push("firstRoot-capture");
			secondRoot.addChild(parent);
		}, true);
		parent.addEventListener("reparent", function(_:Event):Void log.push("parent-capture"), true);
		target.addEventListener("reparent", function(_:Event):Void log.push("target"));
		parent.addEventListener("reparent", function(_:Event):Void log.push("parent-bubble"));
		firstRoot.addEventListener("reparent", function(_:Event):Void log.push("firstRoot-bubble"));
		secondRoot.addEventListener("reparent", function(_:Event):Void log.push("secondRoot-bubble"));
		target.dispatchEvent(new Event("reparent", true));
		return {
			log: log.join(","),
			parentIsSecondRoot: parent.parent == secondRoot
		};
	}

	private static function testPostDispatchState():Dynamic {
		var root = namedSprite("root");
		var target = namedSprite("target");
		root.addChild(target);
		root.addEventListener("state", function(_:Event):Void {});
		var event = new Event("state", true);
		target.dispatchEvent(event);
		return {
			target: cast(event.target, Sprite).name,
			currentTarget: cast(event.currentTarget, Sprite).name,
			phase: cast event.eventPhase
		};
	}

	private static function testBubblePreventDefault():Dynamic {
		var parent = new Sprite();
		var target = new Sprite();
		parent.addChild(target);
		parent.addEventListener("bubblePrevent", function(event:Event):Void event.preventDefault());
		var event = new Event("bubblePrevent", true, true);
		var dispatchResult = target.dispatchEvent(event);
		return {
			dispatchResult: dispatchResult,
			defaultPrevented: event.isDefaultPrevented()
		};
	}

	private static function captureError(operation:Void->Void):Null<String> {
		try {
			operation();
			return null;
		} catch (error:Dynamic) {
			var errorClass = Type.getClass(error);
			return errorClass == null ? Std.string(error) : Type.getClassName(errorClass);
		}
	}
}
