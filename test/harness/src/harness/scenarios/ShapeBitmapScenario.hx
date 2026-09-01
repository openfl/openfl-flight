package harness.scenarios;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.PixelSnapping;
import openfl.display.Shape;
import openfl.geom.Rectangle;

class ShapeBitmapScenario {
	public static function run():Dynamic {
		var shape = new Shape();
		shape.graphics.beginFill(0x336699);
		shape.graphics.drawRect(-4, 6, 18, 9);
		shape.graphics.endFill();

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
				graphicsStable: shape.graphics == shape.graphics,
				bounds: rect(shape.getBounds(shape)),
				width: number(shape.width),
				height: number(shape.height)
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
