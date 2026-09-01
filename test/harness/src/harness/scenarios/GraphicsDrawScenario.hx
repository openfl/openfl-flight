package harness.scenarios;

import openfl.display.Sprite;
import openfl.geom.Rectangle;

class GraphicsDrawScenario {
	public static function run():Dynamic {
		var rectangle = new Sprite();
		rectangle.graphics.beginFill(0x336699);
		rectangle.graphics.drawRect(10, 20, 100, 50);
		rectangle.graphics.endFill();

		var circle = new Sprite();
		circle.graphics.beginFill(0xFF0000);
		circle.graphics.drawCircle(20, 30, 10);
		circle.graphics.endFill();

		var ellipse = new Sprite();
		ellipse.graphics.beginFill(0x00FF00);
		ellipse.graphics.drawEllipse(5, 10, 80, 40);
		ellipse.graphics.endFill();

		var line = new Sprite();
		line.graphics.lineStyle(4, 0x000000);
		line.graphics.moveTo(10, 10);
		line.graphics.lineTo(50, 30);

		var thickLine = new Sprite();
		thickLine.graphics.lineStyle(10, 0x000000);
		thickLine.graphics.moveTo(20, 30);
		thickLine.graphics.lineTo(80, 60);

		var multiple = new Sprite();
		multiple.graphics.beginFill(0x663399);
		multiple.graphics.drawRect(-10, 5, 20, 10);
		multiple.graphics.drawRect(35, 5, 30, 30);
		multiple.graphics.endFill();

		var curve = new Sprite();
		curve.graphics.lineStyle(2, 0x000000);
		curve.graphics.moveTo(0, 0);
		curve.graphics.curveTo(50, 100, 100, 0);
		curve.graphics.cubicCurveTo(125, -50, 175, -50, 200, 0);

		var copySource = new Sprite();
		copySource.graphics.beginFill(0x0099CC);
		copySource.graphics.drawRect(12, -8, 30, 16);
		copySource.graphics.drawCircle(60, 20, 5);
		copySource.graphics.endFill();
		var copied = new Sprite();
		copied.graphics.copyFrom(copySource.graphics);

		var cleared = new Sprite();
		cleared.graphics.beginFill(0x0000FF);
		cleared.graphics.drawRect(0, 0, 25, 15);
		cleared.graphics.endFill();
		var beforeClear = rect(cleared.getBounds(cleared));
		cleared.graphics.clear();

		return {
			rectangle: {
				bounds: rect(rectangle.getBounds(rectangle)),
				width: number(rectangle.width),
				height: number(rectangle.height)
			},
			circle: rect(circle.getBounds(circle)),
			ellipse: rect(ellipse.getBounds(ellipse)),
			line: rect(line.getBounds(line)),
			thickLine: rect(thickLine.getBounds(thickLine)),
			multiple: rect(multiple.getBounds(multiple)),
			curve: rect(curve.getBounds(curve)),
			copyFrom: {
				source: rect(copySource.getBounds(copySource)),
				copy: rect(copied.getBounds(copied))
			},
			clear: {
				before: beforeClear,
				after: rect(cleared.getBounds(cleared)),
				width: number(cleared.width),
				height: number(cleared.height)
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
