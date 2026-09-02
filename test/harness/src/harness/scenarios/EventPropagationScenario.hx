package harness.scenarios;

import openfl.display.Sprite;
import openfl.events.Event;

class EventPropagationScenario {
	public static function run():Dynamic {
		var root = namedSprite("root");
		var parent = namedSprite("parent");
		var child = namedSprite("child");
		var grandchild = namedSprite("grandchild");
		root.addChild(parent);
		parent.addChild(child);
		child.addChild(grandchild);

		var route:Array<Dynamic> = [];
		root.addEventListener("route", record(route, "root-capture"), true);
		parent.addEventListener("route", record(route, "parent-capture"), true);
		child.addEventListener("route", record(route, "child-capture"), true);
		grandchild.addEventListener("route", record(route, "grandchild-target"));
		child.addEventListener("route", record(route, "child-bubble"));
		parent.addEventListener("route", record(route, "parent-bubble"));
		root.addEventListener("route", record(route, "root-bubble"));
		grandchild.dispatchEvent(new Event("route", true));

		var stoppedDuringCapture:Array<String> = [];
		root.addEventListener("capture-stop", function(event:Event):Void {
			stoppedDuringCapture.push("root-first");
			event.stopPropagation();
		}, true);
		root.addEventListener("capture-stop", function(event:Event):Void {
			stoppedDuringCapture.push("root-second");
		}, true);
		parent.addEventListener("capture-stop", function(event:Event):Void {
			stoppedDuringCapture.push("parent-capture");
		}, true);
		child.addEventListener("capture-stop", function(event:Event):Void {
			stoppedDuringCapture.push("child-capture");
		}, true);
		grandchild.addEventListener("capture-stop", function(event:Event):Void {
			stoppedDuringCapture.push("target");
		});
		child.addEventListener("capture-stop", function(event:Event):Void {
			stoppedDuringCapture.push("child-bubble");
		});
		grandchild.dispatchEvent(new Event("capture-stop", true));

		var stopped:Array<String> = [];
		grandchild.addEventListener("stop", function(event:Event):Void {
			stopped.push("target");
		});
		child.addEventListener("stop", function(event:Event):Void {
			stopped.push("child-first");
			event.stopPropagation();
		});
		child.addEventListener("stop", function(event:Event):Void {
			stopped.push("child-second");
		});
		parent.addEventListener("stop", function(event:Event):Void {
			stopped.push("parent");
		});
		root.addEventListener("stop", function(event:Event):Void {
			stopped.push("root");
		});
		grandchild.dispatchEvent(new Event("stop", true));

		var stoppedImmediately:Array<String> = [];
		grandchild.addEventListener("immediate", function(event:Event):Void {
			stoppedImmediately.push("target");
		});
		child.addEventListener("immediate", function(event:Event):Void {
			stoppedImmediately.push("child-first");
			event.stopImmediatePropagation();
		});
		child.addEventListener("immediate", function(event:Event):Void {
			stoppedImmediately.push("child-second");
		});
		parent.addEventListener("immediate", function(event:Event):Void {
			stoppedImmediately.push("parent");
		});
		root.addEventListener("immediate", function(event:Event):Void {
			stoppedImmediately.push("root");
		});
		grandchild.dispatchEvent(new Event("immediate", true));

		var immediateAtTarget:Array<String> = [];
		grandchild.addEventListener("target-immediate", function(event:Event):Void {
			immediateAtTarget.push("target-first");
			event.stopImmediatePropagation();
		});
		grandchild.addEventListener("target-immediate", function(event:Event):Void {
			immediateAtTarget.push("target-second");
		});
		child.addEventListener("target-immediate", function(event:Event):Void {
			immediateAtTarget.push("child-bubble");
		});
		grandchild.dispatchEvent(new Event("target-immediate", true));

		var cancelableEvent = new Event("cancelable-default", true, true);
		grandchild.addEventListener("cancelable-default", function(event:Event):Void {
			event.preventDefault();
		});
		var cancelableResult = grandchild.dispatchEvent(cancelableEvent);

		var nonCancelableEvent = new Event("noncancelable-default", true, false);
		grandchild.addEventListener("noncancelable-default", function(event:Event):Void {
			event.preventDefault();
		});
		var nonCancelableResult = grandchild.dispatchEvent(nonCancelableEvent);

		var nonBubbling:Array<String> = [];
		grandchild.addEventListener("local", function(event:Event):Void {
			nonBubbling.push("target");
		});
		child.addEventListener("local", function(event:Event):Void {
			nonBubbling.push("child");
		});
		parent.addEventListener("local", function(event:Event):Void {
			nonBubbling.push("parent");
		});
		root.addEventListener("local", function(event:Event):Void {
			nonBubbling.push("root");
		});
		grandchild.dispatchEvent(new Event("local", false));

		return {
			route: route,
			stopPropagationCapture: stoppedDuringCapture,
			stopPropagation: stopped,
			stopImmediatePropagation: stoppedImmediately,
			stopImmediateAtTarget: immediateAtTarget,
			preventDefault: {
				cancelable: {
					dispatchResult: cancelableResult,
					isDefaultPrevented: cancelableEvent.isDefaultPrevented()
				},
				nonCancelable: {
					dispatchResult: nonCancelableResult,
					isDefaultPrevented: nonCancelableEvent.isDefaultPrevented()
				}
			},
			nonBubbling: nonBubbling
		};
	}

	private static function namedSprite(name:String):Sprite {
		var sprite = new Sprite();
		sprite.name = name;
		return sprite;
	}

	private static function record(log:Array<Dynamic>, listener:String):Event->Void {
		return function(event:Event):Void {
			log.push({
				listener: listener,
				phase: cast event.eventPhase,
				target: objectName(event.target),
				currentTarget: objectName(event.currentTarget)
			});
		};
	}

	private static function objectName(value:Dynamic):String {
		return value == null ? null : cast(value, Sprite).name;
	}
}
