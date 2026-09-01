package harness.scenarios;

import openfl.display.BitmapData;
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
			rect: testRect()
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
}
