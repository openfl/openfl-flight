package harness.scenarios;

import openfl.display.GradientType;
import openfl.display.GraphicsPath;
import openfl.display.Sprite;
import openfl.geom.Rectangle;

class GraphicsScenario {
	public static function run():Dynamic {
		return {
			identity: testIdentity(),
			solidRectangle: testSolidRectangle(),
			gradientRectangle: testGradientRectangle(),
			line: testLine(),
			shapes: testShapes(),
			clear: testClear(),
			multipleShapes: testMultipleShapes(),
			graphicsData: testGraphicsData()
		};
	}

	private static function testIdentity():Dynamic {
		var sprite = new Sprite();
		return {
			notNull: sprite.graphics != null,
			stable: sprite.graphics == sprite.graphics
		};
	}

	private static function testSolidRectangle():Dynamic {
		var sprite = new Sprite();
		sprite.graphics.beginFill(0x336699, 0.75);
		sprite.graphics.drawRect(10, 20, 30, 40);
		sprite.graphics.endFill();
		return rect(sprite.getBounds(sprite));
	}

	private static function testGradientRectangle():Dynamic {
		var sprite = new Sprite();
		sprite.graphics.beginGradientFill(GradientType.LINEAR, [0xFF0000, 0x0000FF], [1, 0.5], [0, 255]);
		sprite.graphics.drawRect(5, 6, 50, 25);
		sprite.graphics.endFill();
		return rect(sprite.getBounds(sprite));
	}

	private static function testLine():Dynamic {
		var sprite = new Sprite();
		sprite.graphics.lineStyle(4, 0x123456);
		sprite.graphics.moveTo(10, 15);
		sprite.graphics.lineTo(50, 35);
		return rect(sprite.getBounds(sprite));
	}

	private static function testShapes():Dynamic {
		var circle = new Sprite();
		circle.graphics.beginFill(0xFF0000);
		circle.graphics.drawCircle(20, 30, 10);
		circle.graphics.endFill();

		var ellipse = new Sprite();
		ellipse.graphics.beginFill(0x00FF00);
		ellipse.graphics.drawEllipse(5, 10, 80, 40);
		ellipse.graphics.endFill();

		var roundRect = new Sprite();
		roundRect.graphics.beginFill(0x0000FF);
		roundRect.graphics.drawRoundRect(7, 9, 60, 30, 12, 8);
		roundRect.graphics.endFill();

		return {
			circle: rect(circle.getBounds(circle)),
			ellipse: rect(ellipse.getBounds(ellipse)),
			roundRect: rect(roundRect.getBounds(roundRect))
		};
	}

	private static function testClear():Dynamic {
		var sprite = new Sprite();
		sprite.graphics.beginFill(0x663399);
		sprite.graphics.drawRect(0, 0, 25, 15);
		sprite.graphics.endFill();
		var before = rect(sprite.getBounds(sprite));
		sprite.graphics.clear();
		return {
			before: before,
			after: rect(sprite.getBounds(sprite))
		};
	}

	private static function testMultipleShapes():Dynamic {
		var sprite = new Sprite();
		sprite.graphics.beginFill(0x663399);
		sprite.graphics.drawRect(-10, 5, 20, 10);
		sprite.graphics.drawCircle(50, 20, 15);
		sprite.graphics.drawEllipse(80, -5, 30, 20);
		sprite.graphics.endFill();
		return rect(sprite.getBounds(sprite));
	}

	private static function testGraphicsData():Dynamic {
		var source = new Sprite();
		source.graphics.beginFill(0x336699, 0.5);
		source.graphics.drawRect(10, 20, 30, 40);
		source.graphics.endFill();
		var data = source.graphics.readGraphicsData();
		var target = new Sprite();
		target.graphics.drawGraphicsData(data);
		var pathCommands:Null<Int> = null;
		var pathData:Null<Int> = null;
		for (item in data) {
			if ((item is GraphicsPath)) {
				var path:GraphicsPath = cast item;
				pathCommands = path.commands == null ? null : path.commands.length;
				pathData = path.data == null ? null : path.data.length;
			}
		}
		return {
			count: data.length,
			types: [for (item in data) className(item)],
			pathCommands: pathCommands,
			pathData: pathData,
			sourceBounds: rect(source.getBounds(source)),
			targetBounds: rect(target.getBounds(target))
		};
	}

	private static function className(value:Dynamic):String {
		var name = Type.getClassName(Type.getClass(value));
		return name == null ? null : name.split(".").pop();
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
