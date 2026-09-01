package harness.scenarios;

import openfl.display.BitmapData;
import openfl.display.BitmapDataChannel;
import openfl.geom.ColorTransform;
import openfl.geom.Point;
import openfl.geom.Rectangle;

class BitmapDataScenario {
	public static function run():Dynamic {
		return {
			construct: testConstruct(),
			getSetPixel: testGetSetPixel(),
			getSetPixel32: testGetSetPixel32(),
			fillRect: testFillRect(),
			dimensions: testDimensions(),
			clone: testClone(),
			rect: testRect(),
			pixelRoundtrip: testPixelRoundtrip(),
			transparencyHandling: testTransparencyHandling(),
			copyPixels: testCopyPixels(),
			copyChannel: testCopyChannel(),
			colorTransformPixels: testColorTransformPixels(),
			dispose: testDispose(),
			compare: testCompare()
		};
	}

	private static function testConstruct():Dynamic {
		var bmd = new BitmapData(100, 50, true, 0xFFFF0000);
		return {
			width: bmd.width,
			height: bmd.height,
			transparent: bmd.transparent
		};
	}

	private static function testGetSetPixel():Dynamic {
		var bmd = new BitmapData(10, 10, false, 0x000000);
		bmd.setPixel(5, 5, 0xFF8800);
		var pixel = bmd.getPixel(5, 5);
		return {
			pixel: pixel
		};
	}

	private static function testGetSetPixel32():Dynamic {
		var bmd = new BitmapData(10, 10, true, 0x00000000);
		bmd.setPixel32(3, 3, 0x80FF0000);
		var pixel32 = bmd.getPixel32(3, 3);
		return {
			pixel32: pixel32
		};
	}

	private static function testFillRect():Dynamic {
		var bmd = new BitmapData(10, 10, false, 0x000000);
		bmd.fillRect(new Rectangle(2, 2, 5, 5), 0xFFFFFF);
		var inside = bmd.getPixel(4, 4);
		var outside = bmd.getPixel(0, 0);
		return {
			inside: inside,
			outside: outside
		};
	}

	private static function testDimensions():Dynamic {
		var bmd = new BitmapData(200, 100);
		return {
			width: bmd.width,
			height: bmd.height
		};
	}

	private static function testClone():Dynamic {
		var bmd = new BitmapData(10, 10, true, 0xFF00FF00);
		bmd.setPixel32(5, 5, 0xFFFF0000);
		var clone = bmd.clone();
		return {
			cloneWidth: clone.width,
			cloneHeight: clone.height,
			clonePixel: clone.getPixel32(5, 5),
			originalPixel: bmd.getPixel32(5, 5),
			sameRef: bmd == clone
		};
	}

	private static function testRect():Dynamic {
		var bmd = new BitmapData(100, 50);
		var r = bmd.rect;
		return {
			x: r.x,
			y: r.y,
			width: r.width,
			height: r.height
		};
	}

	private static function testPixelRoundtrip():Dynamic {
		var bmd = new BitmapData(4, 1, true, 0);
		var colors = [0x00010203, 0x7F102030, 0x80ABCDEF, 0xFFFFFFFF];
		for (x in 0...colors.length) {
			bmd.setPixel32(x, 0, colors[x]);
		}

		return pixels(bmd);
	}

	private static function testTransparencyHandling():Dynamic {
		var bmd = new BitmapData(1, 1, false, 0);
		bmd.setPixel32(0, 0, 0x12345678);
		return {
			pixel: bmd.getPixel(0, 0),
			pixel32: bmd.getPixel32(0, 0)
		};
	}

	private static function testCopyPixels():Dynamic {
		var source = new BitmapData(3, 2, true, 0);
		source.setPixel32(0, 0, 0xFF110000);
		source.setPixel32(1, 0, 0xFF002200);
		source.setPixel32(2, 0, 0xFF000033);
		source.setPixel32(0, 1, 0x44112233);
		source.setPixel32(1, 1, 0x55445566);
		source.setPixel32(2, 1, 0x66778899);

		var destination = new BitmapData(4, 3, true, 0x01020304);
		destination.copyPixels(source, new Rectangle(1, 0, 2, 2), new Point(1, 1));

		var merged = new BitmapData(1, 1, true, 0x80404040);
		var mergedSource = new BitmapData(1, 1, true, 0x80802040);
		merged.copyPixels(mergedSource, mergedSource.rect, new Point(), null, null, true);

		var opaque = new BitmapData(1, 1, false, 0);
		opaque.copyPixels(mergedSource, mergedSource.rect, new Point());

		return {
			basic: pixels(destination),
			merged: merged.getPixel32(0, 0),
			opaque: opaque.getPixel32(0, 0)
		};
	}

	private static function testCopyChannel():Dynamic {
		var source = new BitmapData(1, 1, true, 0xFFAA2244);
		var destination = new BitmapData(1, 1, true, 0xFF102030);
		destination.copyChannel(source, source.rect, new Point(), BitmapDataChannel.RED, BitmapDataChannel.BLUE);

		var translucentSource = new BitmapData(1, 1, true, 0x80AA2244);
		var translucentDestination = new BitmapData(1, 1, true, 0x60102030);
		translucentDestination.copyChannel(translucentSource, translucentSource.rect, new Point(), BitmapDataChannel.RED, BitmapDataChannel.BLUE);

		return {
			opaque: destination.getPixel32(0, 0),
			translucent: translucentDestination.getPixel32(0, 0)
		};
	}

	private static function testColorTransformPixels():Dynamic {
		var bmd = new BitmapData(2, 1, true, 0);
		bmd.setPixel32(0, 0, 0x80402010);
		bmd.setPixel32(1, 0, 0xFF102030);
		var transform = new ColorTransform(2, 0.5, 1, 0.5, 5, 10, -8, 16);
		bmd.colorTransform(new Rectangle(0, 0, 1, 1), transform);
		return pixels(bmd);
	}

	private static function testDispose():Dynamic {
		var bmd = new BitmapData(3, 2, true, 0xFFFFFFFF);
		bmd.dispose();
		return {
			width: bmd.width,
			height: bmd.height,
			rectIsNull: bmd.rect == null,
			readable: bmd.readable
		};
	}

	private static function testCompare():Dynamic {
		var left = new BitmapData(2, 1, true, 0xFF102030);
		var equal = left.clone();
		var different = left.clone();
		different.setPixel32(1, 0, 0xFF16283A);
		var difference:Dynamic = left.compare(different);
		var alphaLeft = new BitmapData(1, 1, true, 0x80102030);
		var alphaRight = new BitmapData(1, 1, true, 0x40102030);
		var alphaDifference:Dynamic = alphaLeft.compare(alphaRight);
		var disposed = left.clone();
		disposed.dispose();

		return {
			equal: left.compare(equal),
			widthMismatch: left.compare(new BitmapData(3, 1)),
			heightMismatch: left.compare(new BitmapData(2, 2)),
			disposed: left.compare(disposed),
			differenceIsBitmapData: Std.isOfType(difference, BitmapData),
			differencePixels: pixels(cast difference),
			alphaDifferencePixels: pixels(cast alphaDifference)
		};
	}

	private static function pixels(bmd:BitmapData):Array<Int> {
		var result:Array<Int> = [];
		for (y in 0...bmd.height) {
			for (x in 0...bmd.width) {
				result.push(bmd.getPixel32(x, y));
			}
		}
		return result;
	}
}
