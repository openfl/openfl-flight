package harness.scenarios;

import openfl.Vector;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.display.GradientType;
import openfl.display.GraphicsBitmapFill;
import openfl.display.GraphicsPath;
import openfl.display.GraphicsStroke;
import openfl.display.Sprite;
import openfl.geom.Matrix;
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
			graphicsData: testGraphicsData(),
			bitmapFill: testBitmapFill(),
			bitmapStroke: testBitmapStroke(),
			quads: testQuads(),
			blendOverride: testBlendOverride()
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

	private static function testBitmapFill():Dynamic {
		var bitmap = new BitmapData(3, 2, true, 0xFF336699);
		var matrix = new Matrix(2, 0, 0, 3, 4, 5);
		var sprite = new Sprite();
		sprite.graphics.beginBitmapFill(bitmap, matrix, false, true);
		sprite.graphics.drawRect(2, 3, 20, 10);
		sprite.graphics.endFill();

		return {
			bounds: rect(sprite.getBounds(sprite)),
			insideHit: sprite.hitTestPoint(10, 8, true),
			outsideHit: sprite.hitTestPoint(30, 8, true),
			data: captureBitmapGraphicsData(sprite)
		};
	}

	private static function testBitmapStroke():Dynamic {
		var bitmap = new BitmapData(4, 5, true, 0xFFCC8844);
		var matrix = new Matrix(1, 0, 0, 1, 6, 7);
		var sprite = new Sprite();
		sprite.graphics.lineStyle(6);
		sprite.graphics.lineBitmapStyle(bitmap, matrix, true, false);
		sprite.graphics.moveTo(2, 10);
		sprite.graphics.lineTo(42, 10);

		return {
			bounds: rect(sprite.getBounds(sprite)),
			insideHit: sprite.hitTestPoint(20, 10, true),
			outsideHit: sprite.hitTestPoint(20, 20, true),
			data: captureBitmapGraphicsData(sprite)
		};
	}

	private static function testQuads():Dynamic {
		var rects = Vector.ofArray([10.0, 20, 30, 40, -5, 6, 10, 12]);
		var plain = new Sprite();
		plain.graphics.beginFill(0x336699);
		plain.graphics.drawQuads(rects);
		plain.graphics.endFill();

		var transformed = new Sprite();
		transformed.graphics.beginFill(0x993366);
		transformed.graphics.drawQuads(rects, Vector.ofArray([1, 0]), Vector.ofArray([100.0, 200, -20, 30]));
		transformed.graphics.endFill();

		var matrix = new Sprite();
		matrix.graphics.beginFill(0x669933);
		matrix.graphics.drawQuads(Vector.ofArray([5.0, 7, 8, 6]), null, Vector.ofArray([2.0, 0, 0, 3, -4, 10]));
		matrix.graphics.endFill();

		return {
			plainBounds: rect(plain.getBounds(plain)),
			plainFirstHit: plain.hitTestPoint(20, 30, true),
			plainSecondHit: plain.hitTestPoint(0, 10, true),
			transformedBounds: rect(transformed.getBounds(transformed)),
			transformedFirstHit: transformed.hitTestPoint(105, 205, true),
			transformedSecondHit: transformed.hitTestPoint(-10, 40, true),
			matrixBounds: rect(matrix.getBounds(matrix)),
			matrixHit: matrix.hitTestPoint(0, 20, true)
		};
	}

	private static function testBlendOverride():Dynamic {
		var sprite = new Sprite();
		sprite.graphics.beginFill(0x336699);
		sprite.graphics.overrideBlendMode(BlendMode.ADD);
		sprite.graphics.drawRect(1, 2, 3, 4);
		sprite.graphics.overrideBlendMode(BlendMode.NORMAL);
		sprite.graphics.endFill();
		return {
			bounds: rect(sprite.getBounds(sprite)),
			displayBlendMode: sprite.blendMode
		};
	}

	private static function captureBitmapGraphicsData(sprite:Sprite):Dynamic {
		var data = sprite.graphics.readGraphicsData();
		var bitmapFills:Array<Dynamic> = [];
		var strokeFills:Array<String> = [];
		for (item in data) {
			if ((item is GraphicsBitmapFill)) {
				bitmapFills.push(captureBitmapFill(cast item));
			} else if ((item is GraphicsStroke)) {
				var stroke:GraphicsStroke = cast item;
				strokeFills.push(className(stroke.fill));
				if ((stroke.fill is GraphicsBitmapFill)) bitmapFills.push(captureBitmapFill(cast stroke.fill));
			}
		}
		return {
			types: [for (item in data) className(item)],
			bitmapFills: bitmapFills,
			strokeFills: strokeFills
		};
	}

	private static function captureBitmapFill(fill:GraphicsBitmapFill):Dynamic {
		return {
			width: fill.bitmapData == null ? null : fill.bitmapData.width,
			height: fill.bitmapData == null ? null : fill.bitmapData.height,
			repeat: fill.repeat,
			smooth: fill.smooth,
			matrix: fill.matrix == null ? null : {
				a: fill.matrix.a,
				b: fill.matrix.b,
				c: fill.matrix.c,
				d: fill.matrix.d,
				tx: fill.matrix.tx,
				ty: fill.matrix.ty
			}
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
