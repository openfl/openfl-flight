package harness.scenarios;

import openfl.display.Sprite;

class DisplayHitTestScenario {
	public static function run():Dynamic {
		var circle = new Sprite();
		circle.graphics.beginFill(0xFF0000);
		circle.graphics.drawCircle(50, 50, 50);
		circle.graphics.endFill();

		var container = new Sprite();
		var first = filledRect(100, 50);
		var second = filledRect(100, 50);
		first.x = 10;
		second.x = 75;
		container.addChild(first);
		container.addChild(second);
		var overlapping = first.hitTestObject(second);
		second.x = 150;
		var separated = first.hitTestObject(second);

		var transformed = filledRect(40, 20);
		transformed.x = 100;
		transformed.y = 100;
		transformed.rotation = 90;
		transformed.scaleX = 2;
		container.addChild(transformed);
		var insideProbe = filledRect(1, 1);
		insideProbe.x = 90;
		insideProbe.y = 150;
		container.addChild(insideProbe);
		var outsideProbe = filledRect(1, 1);
		outsideProbe.x = 110;
		outsideProbe.y = 110;
		container.addChild(outsideProbe);

		return {
			visibility: testVisibility(),
			mouseEnabled: testMouseEnabled(),
			nested: testNestedContainers(),
			point: {
				centerBounds: circle.hitTestPoint(50, 50, false),
				centerShape: circle.hitTestPoint(50, 50, true),
				cornerBounds: circle.hitTestPoint(5, 5, false),
				cornerShape: circle.hitTestPoint(5, 5, true),
				outsideBounds: circle.hitTestPoint(105, 105, false),
				outsideShape: circle.hitTestPoint(105, 105, true)
			},
			objects: {
				overlapping: overlapping,
				separated: separated
			},
			transformed: {
				inside: transformed.hitTestObject(insideProbe),
				outside: transformed.hitTestObject(outsideProbe)
			}
		};
	}

	private static function testVisibility():Dynamic {
		var container = new Sprite();
		var target = filledRect(40, 30);
		var probe = filledRect(5, 5);
		probe.x = 10;
		probe.y = 10;
		target.visible = false;
		container.addChild(target);
		container.addChild(probe);

		return {
			objectOverlap: target.hitTestObject(probe),
			pointBounds: target.hitTestPoint(10, 10, false),
			pointShape: target.hitTestPoint(10, 10, true)
		};
	}

	private static function testMouseEnabled():Dynamic {
		var container = new Sprite();
		var target = filledRect(40, 30);
		var probe = filledRect(5, 5);
		probe.x = 10;
		probe.y = 10;
		target.mouseEnabled = false;
		container.addChild(target);
		container.addChild(probe);

		return {
			objectOverlap: target.hitTestObject(probe),
			pointBounds: target.hitTestPoint(10, 10, false),
			pointShape: target.hitTestPoint(10, 10, true)
		};
	}

	private static function testNestedContainers():Dynamic {
		var root = new Sprite();
		var firstLevel = new Sprite();
		var secondLevel = new Sprite();
		var target = filledRect(30, 20);
		var probe = filledRect(2, 2);

		firstLevel.x = 10;
		firstLevel.y = 20;
		secondLevel.x = 30;
		secondLevel.y = 40;
		target.x = 5;
		target.y = 6;
		probe.x = 50;
		probe.y = 70;

		root.addChild(firstLevel);
		firstLevel.addChild(secondLevel);
		secondLevel.addChild(target);
		root.addChild(probe);

		var targetOverlap = target.hitTestObject(probe);
		var nestedBoundsOverlap = firstLevel.hitTestObject(probe);
		probe.x = 200;
		probe.y = 200;

		return {
			targetOverlap: targetOverlap,
			nestedBoundsOverlap: nestedBoundsOverlap,
			separated: target.hitTestObject(probe)
		};
	}

	private static function filledRect(width:Float, height:Float):Sprite {
		var sprite = new Sprite();
		sprite.graphics.beginFill(0x336699);
		sprite.graphics.drawRect(0, 0, width, height);
		sprite.graphics.endFill();
		return sprite;
	}
}
