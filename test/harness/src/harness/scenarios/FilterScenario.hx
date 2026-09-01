package harness.scenarios;

import openfl.display.Sprite;
import openfl.filters.BlurFilter;
import openfl.filters.DropShadowFilter;
import openfl.filters.GlowFilter;

class FilterScenario {
	public static function run():Dynamic {
		return {
			blurDefaults: captureBlur(new BlurFilter()),
			blurValues: captureBlur(new BlurFilter(8, 12, 3)),
			dropShadow: captureDropShadow(createDropShadow()),
			glow: captureGlow(createGlow()),
			displayObject: testDisplayObjectFilters(),
			clones: testClones()
		};
	}

	private static function createDropShadow():DropShadowFilter {
		return new DropShadowFilter(7, 30, 0x123456, 0.4, 8, 9, 2.5, 3, true, true, true);
	}

	private static function createGlow():GlowFilter {
		return new GlowFilter(0xABCDEF, 0.6, 10, 11, 3.5, 2, true, true);
	}

	private static function testDisplayObjectFilters():Dynamic {
		var sprite = new Sprite();
		var original = new BlurFilter(2, 3, 2);
		sprite.filters = [original];
		var readBack = sprite.filters;
		var applied:BlurFilter = cast readBack[0];
		return {
			count: readBack.length,
			sameReference: applied == original,
			blurX: applied.blurX,
			blurY: applied.blurY,
			quality: applied.quality
		};
	}

	private static function testClones():Dynamic {
		var blur = new BlurFilter(5, 6, 2);
		var blurClone:BlurFilter = cast blur.clone();
		var shadow = createDropShadow();
		var shadowClone:DropShadowFilter = cast shadow.clone();
		var glow = createGlow();
		var glowClone:GlowFilter = cast glow.clone();
		return {
			blurSameReference: blurClone == blur,
			blur: captureBlur(blurClone),
			shadowSameReference: shadowClone == shadow,
			shadow: captureDropShadow(shadowClone),
			glowSameReference: glowClone == glow,
			glow: captureGlow(glowClone)
		};
	}

	private static function captureBlur(filter:BlurFilter):Dynamic {
		return {
			blurX: filter.blurX,
			blurY: filter.blurY,
			quality: filter.quality
		};
	}

	private static function captureDropShadow(filter:DropShadowFilter):Dynamic {
		return {
			distance: filter.distance,
			angle: filter.angle,
			color: filter.color,
			alpha: filter.alpha,
			blurX: filter.blurX,
			blurY: filter.blurY,
			strength: filter.strength,
			quality: filter.quality,
			inner: filter.inner,
			knockout: filter.knockout,
			hideObject: filter.hideObject
		};
	}

	private static function captureGlow(filter:GlowFilter):Dynamic {
		return {
			color: filter.color,
			alpha: filter.alpha,
			blurX: filter.blurX,
			blurY: filter.blurY,
			strength: filter.strength,
			quality: filter.quality,
			inner: filter.inner,
			knockout: filter.knockout
		};
	}
}
