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

	private static function filledRect(width:Float, height:Float):Sprite {
		var sprite = new Sprite();
		sprite.graphics.beginFill(0x336699);
		sprite.graphics.drawRect(0, 0, width, height);
		sprite.graphics.endFill();
		return sprite;
	}
}
