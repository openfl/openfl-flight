package harness.scenarios;

import openfl.geom.ColorTransform;

class ColorTransformScenario {
	public static function run():Dynamic {
		var defaults = new ColorTransform();
		var custom = new ColorTransform(0.5, 0.6, 0.7, 0.8, 10, 20, 30, 40);

		var colorGet = new ColorTransform(0, 0, 0, 1, 0xFF, 0x80, 0x40, 0);
		var colorSet = new ColorTransform();
		colorSet.color = 0xFF8040;

		var concatA = new ColorTransform(0.5, 0.6, 0.7, 0.8, 10, 20, 30, 40);
		var concatB = new ColorTransform(0.5, 0.5, 0.5, 0.5, 5, 10, 15, 20);
		concatA.concat(concatB);

		var identity = new ColorTransform(1, 1, 1, 1, 0, 0, 0, 0);

		return {
			defaults: describe(defaults),
			custom: describe(custom),
			colorGet: colorGet.color,
			colorSet: describe(colorSet),
			concat: describe(concatA),
			identity: describe(identity),
			edgeCases: {
				zeroMultipliers: describe(new ColorTransform(0, 0, 0, 0, 128, 128, 128, 128)),
				maxOffsets: describe(new ColorTransform(1, 1, 1, 1, 255, 255, 255, 255)),
				negativeOffsets: describe(new ColorTransform(1, 1, 1, 1, -128, -128, -128, -128))
			}
		};
	}

	private static function describe(ct:ColorTransform):Dynamic {
		return {
			redMultiplier: ct.redMultiplier,
			greenMultiplier: ct.greenMultiplier,
			blueMultiplier: ct.blueMultiplier,
			alphaMultiplier: ct.alphaMultiplier,
			redOffset: ct.redOffset,
			greenOffset: ct.greenOffset,
			blueOffset: ct.blueOffset,
			alphaOffset: ct.alphaOffset
		};
	}
}
