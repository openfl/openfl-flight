package harness.scenarios;

import openfl.Lib;
import openfl.display.Sprite;
import openfl.display.Stage;
import openfl.display.Window;
import openfl.events.Event;
import openfl.geom.Point;
import openfl.geom.Rectangle;

class DisplayCompositionScenario {
	public static function run():Dynamic {
		return {
			graphicsInContainer: testGraphicsInContainer(),
			stageTransformChain: testStageTransformChain(),
			overlappingObjects: testOverlappingObjects(),
			bubbling: testBubbling(),
			mask: testMask()
		};
	}

	private static function testGraphicsInContainer():Dynamic {
		var container = new Sprite();
		var child = new Sprite();
		child.graphics.beginFill(0x336699);
		child.graphics.drawRect(10, 20, 30, 40);
		child.graphics.endFill();
		child.x = 5;
		child.y = 7;
		container.addChild(child);
		return {
			childSelf: rect(child.getBounds(child)),
			childInContainer: rect(child.getBounds(container)),
			containerSelf: rect(container.getBounds(container)),
			childParentMatches: child.parent == container
		};
	}

	private static function testStageTransformChain():Dynamic {
		var stage = createStage(320, 240);
		if (Lib.current != null && Lib.current.parent == stage) stage.removeChild(Lib.current);
		var container = new Sprite();
		var child = new Sprite();
		container.x = 100;
		container.y = 50;
		container.scaleX = 2;
		container.scaleY = 3;
		child.x = 10;
		child.y = 5;
		child.graphics.beginFill(0x123456);
		child.graphics.drawRect(0, 0, 20, 10);
		child.graphics.endFill();
		stage.addChild(container);
		container.addChild(child);
		var local = new Point(3, 4);
		var global = child.localToGlobal(local);
		var roundTrip = child.globalToLocal(global);
		return {
			childStageMatches: child.stage == stage,
			containerStageMatches: container.stage == stage,
			global: point(global),
			roundTrip: point(roundTrip),
			boundsOnStage: rect(child.getBounds(stage))
		};
	}

	private static function testOverlappingObjects():Dynamic {
		var container = new Sprite();
		var bottom = filledSprite("bottom", 0, 0, 30, 30);
		var top = filledSprite("top", 10, 10, 30, 30);
		container.addChild(bottom);
		container.addChild(top);
		return {
			overlap: [for (object in container.getObjectsUnderPoint(new Point(15, 15))) object.name],
			bottomOnly: [for (object in container.getObjectsUnderPoint(new Point(5, 5))) object.name],
			outsideCount: container.getObjectsUnderPoint(new Point(100, 100)).length
		};
	}

	private static function testBubbling():Dynamic {
		var parent = new Sprite();
		parent.name = "parent";
		var child = new Sprite();
		child.name = "child";
		parent.addChild(child);
		var log = new Array<Dynamic>();
		child.addEventListener("compose", function(event:Event):Void {
			log.push({listener: "child", target: cast(event.target, Sprite).name, currentTarget: cast(event.currentTarget, Sprite).name});
		});
		parent.addEventListener("compose", function(event:Event):Void {
			log.push({listener: "parent", target: cast(event.target, Sprite).name, currentTarget: cast(event.currentTarget, Sprite).name});
		});
		child.dispatchEvent(new Event("compose", true));
		return log;
	}

	private static function testMask():Dynamic {
		var target = filledSprite("target", 0, 0, 40, 30);
		var mask = filledSprite("mask", 5, 5, 10, 10);
		target.mask = mask;
		var assigned = target.mask == mask;
		target.mask = null;
		return {
			assigned: assigned,
			cleared: target.mask == null
		};
	}

	private static function filledSprite(name:String, x:Float, y:Float, width:Float, height:Float):Sprite {
		var sprite = new Sprite();
		sprite.name = name;
		sprite.x = x;
		sprite.y = y;
		sprite.graphics.beginFill(0x336699);
		sprite.graphics.drawRect(0, 0, width, height);
		sprite.graphics.endFill();
		return sprite;
	}

	private static function createStage(width:Int, height:Int):Stage {
		var window:Dynamic = Type.createEmptyInstance(Window);
		#if harness_capture
		Reflect.setField(window, "__width", width);
		Reflect.setField(window, "__height", height);
		Reflect.setField(window, "__scale", 1);
		Reflect.setField(window, "__fullscreen", false);
		#else
		window.width = width;
		window.height = height;
		window.scale = 1;
		window.fullscreen = false;
		#end
		return new Stage(cast window, 0xFFFFFF);
	}

	private static function point(value:Point):Dynamic {
		return {x: number(value.x), y: number(value.y)};
	}

	private static function rect(value:Rectangle):Dynamic {
		return {
			x: number(value.x),
			y: number(value.y),
			width: number(value.width),
			height: number(value.height)
		};
	}

	private static function number(value:Float):Float {
		return Math.round(value * 1000000) / 1000000;
	}
}
