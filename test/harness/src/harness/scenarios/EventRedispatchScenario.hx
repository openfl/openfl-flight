package harness.scenarios;

import openfl.display.Sprite;
import openfl.events.Event;

class EventRedispatchScenario {
	public static function run():Dynamic {
		var parent = namedSprite("parent");
		var source = namedSprite("source");
		var redispatcher = namedSprite("redispatcher");
		parent.addChild(source);

		var original = new Event("redispatch", true);
		var nested:Dynamic = null;
		var before:Dynamic = null;
		var after:Dynamic = null;
		var bubbled:Dynamic = null;
		var redispatched = false;

		redispatcher.addEventListener("redispatch", function(event:Event):Void {
			nested = describe(event, original);
		});
		source.addEventListener("redispatch", function(event:Event):Void {
			if (!redispatched) {
				redispatched = true;
				before = describe(event, original);
				redispatcher.dispatchEvent(event);
				after = describe(event, original);
			}
		});
		parent.addEventListener("redispatch", function(event:Event):Void {
			bubbled = describe(event, original);
		});

		source.dispatchEvent(original);

		return {
			before: before,
			nested: nested,
			after: after,
			bubbled: bubbled,
			originalAfterDispatch: describe(original, original)
		};
	}

	private static function namedSprite(name:String):Sprite {
		var sprite = new Sprite();
		sprite.name = name;
		return sprite;
	}

	private static function describe(event:Event, original:Event):Dynamic {
		return {
			sameInstance: event == original,
			phase: cast event.eventPhase,
			target: objectName(event.target),
			currentTarget: objectName(event.currentTarget)
		};
	}

	private static function objectName(value:Dynamic):String {
		return value == null ? null : cast(value, Sprite).name;
	}
}
