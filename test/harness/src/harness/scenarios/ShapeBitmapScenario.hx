package harness.scenarios;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.PixelSnapping;
import openfl.display.Shape;
import openfl.geom.Rectangle;

class ShapeBitmapScenario {
	public static function run():Dynamic {
		var shape = new Shape();
		var graphics = shape.graphics;
		var emptyShape = shapeState(shape);
		graphics.beginFill(0x336699);
		graphics.drawRect(-4, 6, 18, 9);
		graphics.endFill();
		var rectangleShape = shapeState(shape);
		graphics.clear();
		var clearedShape = shapeState(shape);
		graphics.beginFill(0x993366, 0.5);
		graphics.drawCircle(5, -2, 3);
		graphics.endFill();
		var circleShape = shapeState(shape);

		var initialData = new BitmapData(13, 7, true, 0x80402010);
		var bitmap = new Bitmap(initialData, PixelSnapping.ALWAYS, true);
		var initial = {
			bitmapDataMatches: bitmap.bitmapData == initialData,
			bounds: rect(bitmap.getBounds(bitmap)),
			width: number(bitmap.width),
			height: number(bitmap.height),
			pixelSnappingAlways: bitmap.pixelSnapping == PixelSnapping.ALWAYS,
			smoothing: bitmap.smoothing
		};

		var replacementData = new BitmapData(4, 11, false, 0x123456);
		bitmap.bitmapData = replacementData;
		var replacement = {
			bitmapDataMatches: bitmap.bitmapData == replacementData,
			bounds: rect(bitmap.getBounds(bitmap)),
			width: number(bitmap.width),
			height: number(bitmap.height),
			smoothing: bitmap.smoothing
		};

		bitmap.bitmapData = null;
		var cleared = {
			bitmapDataIsNull: bitmap.bitmapData == null,
			bounds: rect(bitmap.getBounds(bitmap)),
			width: number(bitmap.width),
			height: number(bitmap.height)
		};

		var defaultBitmap = new Bitmap();

		return {
			shape: {
				graphicsStable: shape.graphics == graphics,
				empty: emptyShape,
				rectangle: rectangleShape,
				cleared: clearedShape,
				circle: circleShape
			},
			bitmap: {
				initial: initial,
				replacement: replacement,
				cleared: cleared,
				defaultPixelSnappingAuto: defaultBitmap.pixelSnapping == PixelSnapping.AUTO,
				defaultSmoothing: defaultBitmap.smoothing
			}
		};
	}

	private static function shapeState(shape:Shape):Dynamic {
		return {
			bounds: rect(shape.getBounds(shape)),
			height: number(shape.height),
			width: number(shape.width)
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
