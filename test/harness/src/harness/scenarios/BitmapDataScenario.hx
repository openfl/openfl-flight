package harness.scenarios;

import openfl.display.BitmapData;
import openfl.display.BitmapDataChannel;
import openfl.display.Shape;
import openfl.filters.ColorMatrixFilter;
import openfl.geom.ColorTransform;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.utils.ByteArray;
import openfl.utils.Endian;

class BitmapDataScenario {
	public static function run():Dynamic {
		return {
			construct: testConstruct(),
			getSetPixel: testGetSetPixel(),
			getSetPixel32: testGetSetPixel32(),
			fillRect: testFillRect(),
			floodFill: testFloodFill(),
			dimensions: testDimensions(),
			clone: testClone(),
			rect: testRect(),
			pixelRoundtrip: testPixelRoundtrip(),
			transparencyHandling: testTransparencyHandling(),
			copyPixels: testCopyPixels(),
			copyChannel: testCopyChannel(),
			colorTransformPixels: testColorTransformPixels(),
			scroll: testScroll(),
			colorBounds: testColorBounds(),
			histogram: testHistogram(),
			pixelsBytes: testPixelsBytes(),
			threshold: testThreshold(),
			merge: testMerge(),
			paletteMap: testPaletteMap(),
			applyColorMatrixFilter: testApplyColorMatrixFilter(),
			noise: testNoise(),
			perlinNoise: testPerlinNoise(),
			drawShape: testDrawShape(),
			lockUnlock: testLockUnlock(),
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

	private static function testFloodFill():Dynamic {
		var bmd = new BitmapData(5, 4, true, 0xFF000000);
		for (y in 0...4) bmd.setPixel32(2, y, 0xFFFF0000);
		bmd.floodFill(0, 0, 0xFF0000FF);
		return pixels(bmd);
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
		clone.setPixel32(5, 5, 0xFF0000FF);
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
			height: r.height,
			matchesDimensions: r.width == bmd.width && r.height == bmd.height
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

	private static function testScroll():Dynamic {
		var source = new BitmapData(3, 2, true, 0);
		var colors = [
			0xFF100000, 0xFF200000, 0xFF300000,
			0xFF400000, 0xFF500000, 0xFF600000
		];
		for (i in 0...colors.length) source.setPixel32(i % 3, Std.int(i / 3), colors[i]);

		var positive = source.clone();
		positive.scroll(1, 1);
		var negative = source.clone();
		negative.scroll(-1, -1);
		var outside = source.clone();
		outside.scroll(3, 2);

		return {
			positive: pixels(positive),
			negative: pixels(negative),
			outside: pixels(outside)
		};
	}

	private static function testColorBounds():Dynamic {
		var bmd = new BitmapData(5, 4, true, 0);
		bmd.fillRect(new Rectangle(1, 1, 3, 2), 0xFF336699);
		bmd.setPixel32(4, 0, 0x80336699);
		var exact = bmd.getColorBoundsRect(0xFFFFFFFF, 0xFF336699);
		var alpha = bmd.getColorBoundsRect(0xFF000000, 0, false);
		var absent = bmd.getColorBoundsRect(0xFFFFFFFF, 0xFFABCDEF);

		return {
			exact: rectangle(exact),
			alpha: rectangle(alpha),
			absent: rectangle(absent)
		};
	}

	private static function testHistogram():Dynamic {
		var bmd = new BitmapData(3, 2, true, 0xFF102030);
		bmd.setPixel32(1, 0, 0x80405060);
		bmd.setPixel32(2, 1, 0xFF1020AA);
		var full = bmd.histogram();
		var region = bmd.histogram(new Rectangle(1, 0, 2, 1));

		return {
			full: histogramSummary(full),
			region: histogramSummary(region)
		};
	}

	private static function testPixelsBytes():Dynamic {
		var input = new ByteArray();
		input.endian = Endian.BIG_ENDIAN;
		input.writeUnsignedInt(0xFF102030);
		input.writeUnsignedInt(0x80405060);
		input.writeUnsignedInt(0xFF708090);
		input.position = 0;

		var bmd = new BitmapData(4, 2, true, 0);
		bmd.setPixels(new Rectangle(1, 0, 3, 1), input);
		var output = bmd.getPixels(new Rectangle(1, 0, 3, 1));
		var tooShort = new ByteArray();
		tooShort.writeUnsignedInt(0xFFFFFFFF);
		tooShort.position = 0;
		var eof = false;
		try {
			bmd.setPixels(new Rectangle(0, 1, 2, 1), tooShort);
		} catch (_:Dynamic) {
			eof = true;
		}

		return {
			pixels: pixels(bmd),
			inputPosition: input.position,
			outputLength: output.length,
			outputPosition: output.position,
			outputBigEndian: output.endian == Endian.BIG_ENDIAN,
			eof: eof
		};
	}

	private static function testThreshold():Dynamic {
		var source = new BitmapData(4, 1, true, 0);
		source.setPixel32(0, 0, 0x10203040);
		source.setPixel32(1, 0, 0x7F405060);
		source.setPixel32(2, 0, 0x80607080);
		source.setPixel32(3, 0, 0xFF90A0B0);
		var destination = new BitmapData(5, 1, true, 0xFF010203);
		var changed = destination.threshold(source, source.rect, new Point(1, 0), "<", 0x80000000, 0xFFABCDEF, 0xFF000000, true);

		var equalDestination = new BitmapData(4, 1, true, 0);
		var equalChanged = equalDestination.threshold(source, source.rect, new Point(), "==", 0x00607000, 0x80443322, 0x00FFFF00);
		return {
			changed: changed,
			pixels: pixels(destination),
			equalChanged: equalChanged,
			equalPixels: pixels(equalDestination)
		};
	}

	private static function testMerge():Dynamic {
		var source = new BitmapData(2, 1, true, 0);
		source.setPixel32(0, 0, 0x80412305);
		source.setPixel32(1, 0, 0xFF112233);
		var destination = new BitmapData(3, 1, true, 0x407080FF);
		destination.merge(source, source.rect, new Point(1, 0), 128, 64, 192, 128);

		var endpoints = new BitmapData(2, 1, true, 0xFFABCDEF);
		endpoints.merge(source, source.rect, new Point(), 0, 256, 0, 256);
		return {
			mixed: pixels(destination),
			endpoints: pixels(endpoints)
		};
	}

	private static function testPaletteMap():Dynamic {
		var source = new BitmapData(2, 1, true, 0);
		source.setPixel32(0, 0, 0x80204060);
		source.setPixel32(1, 0, 0xFF102030);
		var destination = new BitmapData(3, 1, true, 0xFF010203);
		var red = [for (value in 0...256) (255 - value) << 16];
		var green = [for (value in 0...256) Std.int(value / 2) << 8];
		var blue = [for (value in 0...256) (value + 1) & 0xFF];
		var alpha = [for (value in 0...256) (255 - value) << 24];
		destination.paletteMap(source, source.rect, new Point(1, 0), red, green, blue, alpha);

		return {
			width: destination.width,
			height: destination.height,
			outside: destination.getPixel32(0, 0)
		};
	}

	private static function testApplyColorMatrixFilter():Dynamic {
		var destination = new BitmapData(2, 1, true, 0);
		destination.setPixel32(0, 0, 0x80402010);
		destination.setPixel32(1, 0, 0xFF102030);
		var filter = new ColorMatrixFilter([
			2, 0, 0, 0, 5,
			0, 0.5, 0, 0, 10,
			0, 0, 1, 0, -8,
			0, 0, 0, 0.5, 16
		]);
		destination.applyFilter(destination, destination.rect, new Point(), filter);
		return pixels(destination);
	}

	private static function testNoise():Dynamic {
		var first = new BitmapData(8, 4, true, 0);
		first.noise(12345, 20, 200, BitmapDataChannel.RED | BitmapDataChannel.ALPHA);
		var same = new BitmapData(8, 4, true, 0);
		same.noise(12345, 20, 200, BitmapDataChannel.RED | BitmapDataChannel.ALPHA);
		var different = new BitmapData(8, 4, true, 0);
		different.noise(54321, 20, 200, BitmapDataChannel.RED | BitmapDataChannel.ALPHA);
		var channelsValid = true;
		for (color in pixels(first)) {
			var alpha = (color >>> 24) & 0xFF;
			var red = (color >>> 16) & 0xFF;
			channelsValid = channelsValid && alpha >= 20 && alpha <= 200 && red >= 20 && red <= 200 && (color & 0xFFFF) == 0;
		}

		var gray = new BitmapData(8, 4, true, 0);
		gray.noise(2468, 10, 100, BitmapDataChannel.RED, true);
		var grayValid = true;
		for (color in pixels(gray)) {
			var red = (color >>> 16) & 0xFF;
			grayValid = grayValid && ((color >>> 24) & 0xFF) == 0xFF && ((color >>> 8) & 0xFF) == red && (color & 0xFF) == red;
		}

		return {
			deterministic: first.compare(same) == 0,
			seedChangesOutput: first.compare(different) != 0,
			channelsValid: channelsValid,
			grayValid: grayValid
		};
	}

	private static function testPerlinNoise():Dynamic {
		var fractal = new BitmapData(8, 6, true, 0);
		fractal.perlinNoise(12, 9, 3, 13579, false, true, BitmapDataChannel.RED);
		var same = new BitmapData(8, 6, true, 0);
		same.perlinNoise(12, 9, 3, 13579, false, true, BitmapDataChannel.RED);
		var turbulenceFlag = new BitmapData(8, 6, true, 0);
		turbulenceFlag.perlinNoise(12, 9, 3, 13579, false, false, BitmapDataChannel.RED);
		var different = new BitmapData(8, 6, true, 0);
		different.perlinNoise(12, 9, 3, 97531, false, true, BitmapDataChannel.RED);
		var channelsValid = true;
		for (color in pixels(fractal)) channelsValid = channelsValid && ((color >>> 24) & 0xFF) == 0xFF && (color & 0xFFFF) == 0;

		var gray = new BitmapData(8, 6, true, 0);
		gray.perlinNoise(12, 9, 2, 2468, false, true, BitmapDataChannel.RED, true);
		var grayValid = true;
		for (color in pixels(gray)) {
			var red = (color >>> 16) & 0xFF;
			grayValid = grayValid && ((color >>> 24) & 0xFF) == 0xFF && ((color >>> 8) & 0xFF) == red && (color & 0xFF) == red;
		}

		return {
			deterministic: fractal.compare(same) == 0,
			fractalFlagIgnored: fractal.compare(turbulenceFlag) == 0,
			seedChangesOutput: fractal.compare(different) != 0,
			channelsValid: channelsValid,
			grayValid: grayValid
		};
	}

	private static function testDrawShape():Dynamic {
		var shape = new Shape();
		shape.graphics.beginFill(0x336699);
		shape.graphics.drawRect(1, 1, 3, 2);
		shape.graphics.endFill();
		var bmd = new BitmapData(6, 5, true, 0);
		bmd.draw(shape);
		return pixels(bmd);
	}

	private static function testLockUnlock():Dynamic {
		var bmd = new BitmapData(3, 2, true, 0);
		bmd.lock();
		bmd.setPixel32(0, 0, 0xFF112233);
		bmd.fillRect(new Rectangle(1, 0, 2, 2), 0x80445566);
		bmd.unlock(new Rectangle(0, 0, 3, 2));
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

	private static function rectangle(value:Rectangle):Dynamic {
		return {
			x: value.x,
			y: value.y,
			width: value.width,
			height: value.height
		};
	}

	private static function histogramSummary(value:Array<Array<Int>>):Dynamic {
		return {
			channels: value.length,
			lengths: [for (channel in value) channel.length],
			totals: [for (channel in value) {
				var total = 0;
				for (count in channel) total += count;
				total;
			}]
		};
	}
}
