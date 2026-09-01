package harness.scenarios;

import openfl.events.Event;
import openfl.events.EventDispatcher;

class EventDispatcherCaptureScenario {
	public static function run():Dynamic {
		return {
			captureVsNormal: testCaptureVsNormal(),
			captureSameListener: testCaptureSameListener(),
			removeCaptureOnly: testRemoveCaptureOnly(),
			hasEventListenerCapture: testHasEventListenerCapture(),
			stopImmediatePropagation: testStopImmediate(),
			willTrigger: testWillTrigger(),
			nullListener: testNullListener()
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
		var before = dispatcher.willTrigger("test");

		dispatcher.addEventListener("test", function(e:Event):Void {});
		var after = dispatcher.willTrigger("test");

		return {
			before: before,
			after: after
		};
	}

	private static function testNullListener():Dynamic {
		var dispatcher = new EventDispatcher();
		dispatcher.addEventListener("test", null);

		return {
			hasListener: dispatcher.hasEventListener("test")
		};
	}
}
