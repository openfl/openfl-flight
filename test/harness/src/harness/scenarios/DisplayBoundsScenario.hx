package harness.scenarios;

import openfl.display.Sprite;
import openfl.geom.Rectangle;

class DisplayBoundsScenario {
	public static function run():Dynamic {
		var parent = new Sprite();
		var child = new Sprite();
		child.graphics.lineStyle(10, 0x000000);
		child.graphics.beginFill(0x336699);
		child.graphics.drawRect(0, 0, 100, 50);
		child.graphics.endFill();
		child.x = 20;
		child.y = 30;
		parent.addChild(child);

		var transformed = new Sprite();
		transformed.graphics.beginFill(0xFF0000);
		transformed.graphics.drawRect(0, 0, 100, 50);
		transformed.graphics.endFill();
		transformed.x = 10;
		transformed.y = 20;
		transformed.scaleX = 2;
		transformed.rotation = 90;
		parent.addChild(transformed);

		var sized = new Sprite();
		sized.graphics.beginFill(0x00FF00);
		sized.graphics.drawRect(0, 0, 100, 50);
		sized.graphics.endFill();
		var initialSize = {width: number(sized.width), height: number(sized.height)};
		sized.width = 200;
		sized.height = 25;

		return {
			spaces: {
				self: rect(child.getBounds(child)),
				parent: rect(child.getBounds(parent))
			},
			stroke: {
				bounds: rect(child.getBounds(child)),
				rect: rect(child.getRect(child))
			},
			transformed: {
				self: rect(transformed.getBounds(transformed)),
				parent: rect(transformed.getBounds(parent)),
				width: number(transformed.width),
				height: number(transformed.height)
			},
			sizing: {
				initial: initialSize,
				width: number(sized.width),
				height: number(sized.height),
				scaleX: number(sized.scaleX),
				scaleY: number(sized.scaleY)
			}
		};
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
