package harness.scenarios;

import openfl.display.Sprite;
import openfl.events.Event;

class EventPropagationScenario {
	public static function run():Dynamic {
		var parent = namedSprite("parent");
		var child = namedSprite("child");
		var grandchild = namedSprite("grandchild");
		parent.addChild(child);
		child.addChild(grandchild);

		var route:Array<Dynamic> = [];
		parent.addEventListener("route", record(route, "parent-capture"), true);
		child.addEventListener("route", record(route, "child-capture"), true);
		grandchild.addEventListener("route", record(route, "grandchild-target"));
		child.addEventListener("route", record(route, "child-bubble"));
		parent.addEventListener("route", record(route, "parent-bubble"));
		grandchild.dispatchEvent(new Event("route", true));

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
		grandchild.dispatchEvent(new Event("immediate", true));

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
		grandchild.dispatchEvent(new Event("local", false));

		return {
			route: route,
			stopPropagation: stopped,
			stopImmediatePropagation: stoppedImmediately,
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
