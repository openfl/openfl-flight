package harness.scenarios;

import openfl.display.BitmapData;
import openfl.display.BitmapDataChannel;
import openfl.display.Sprite;
import openfl.filters.BevelFilter;
import openfl.filters.BitmapFilterType;
import openfl.filters.BlurFilter;
import openfl.filters.ColorMatrixFilter;
import openfl.filters.ConvolutionFilter;
import openfl.filters.DisplacementMapFilter;
import openfl.filters.DisplacementMapFilterMode;
import openfl.filters.DropShadowFilter;
import openfl.filters.GlowFilter;
import openfl.geom.Point;

class FilterScenario {
	public static function run():Dynamic {
		var colorMatrixValues = [
			1.0, 2, 3, 4, 5,
			6, 7, 8, 9, 10,
			11, 12, 13, 14, 15,
			16, 17, 18, 19, 20
		];
		var convolutionValues = [1.0, 2, 3, 4, 5, 6, 7, 8, 9];
		var map = new BitmapData(3, 2, true, 0x80402010);

		return {
			defaults: {
				bevel: captureBevel(new BevelFilter()),
				blur: captureBlur(new BlurFilter()),
				colorMatrix: captureColorMatrix(new ColorMatrixFilter()),
				convolution: captureConvolution(new ConvolutionFilter()),
				displacement: captureDisplacement(new DisplacementMapFilter()),
				dropShadow: captureDropShadow(new DropShadowFilter()),
				glow: captureGlow(new GlowFilter())
			},
			values: {
				bevel: captureBevel(createBevel()),
				blur: captureBlur(new BlurFilter(8, 12, 3)),
				colorMatrix: captureColorMatrix(new ColorMatrixFilter(colorMatrixValues)),
				convolution: captureConvolution(new ConvolutionFilter(3, 3, convolutionValues, 45, 0.25, false, false, 0x123456, 0.4)),
				displacement: captureDisplacement(createDisplacement(map)),
				dropShadow: captureDropShadow(createDropShadow()),
				glow: captureGlow(createGlow())
			},
			mutations: testMutations(),
			edges: testEdges(),
			clones: testClones(map),
			displayObject: testDisplayObjectFilters()
		};
	}

	private static function createBevel():BevelFilter {
		return new BevelFilter(7, 30, 0x123456, 0.25, 0x654321, 0.75, 8, 9, 2.5, 3, BitmapFilterType.OUTER, true);
	}

	private static function createDisplacement(map:BitmapData):DisplacementMapFilter {
		return new DisplacementMapFilter(map, new Point(4, 5), BitmapDataChannel.RED, BitmapDataChannel.BLUE, 12, -8,
			DisplacementMapFilterMode.COLOR, 0x123456, 0.4);
	}

	private static function createDropShadow():DropShadowFilter {
		return new DropShadowFilter(7, 30, 0x123456, 0.4, 8, 9, 2.5, 3, true, true, true);
	}

	private static function createGlow():GlowFilter {
		return new GlowFilter(0xABCDEF, 0.6, 10, 11, 3.5, 2, true, true);
	}

	private static function testMutations():Dynamic {
		var bevel = new BevelFilter();
		bevel.distance = -8;
		bevel.angle = -90;
		bevel.highlightColor = 0x123456;
		bevel.highlightAlpha = -0.5;
		bevel.shadowColor = 0x654321;
		bevel.shadowAlpha = 1.5;
		bevel.blurX = -10;
		bevel.blurY = 300;
		bevel.strength = -2;
		bevel.quality = 0;
		bevel.type = BitmapFilterType.FULL;
		bevel.knockout = true;

		var blur = new BlurFilter();
		blur.blurX = -1;
		blur.blurY = 300;
		blur.quality = 20;

		var colorMatrix = new ColorMatrixFilter();
		colorMatrix.matrix = [
			20.0, 19, 18, 17, 16,
			15, 14, 13, 12, 11,
			10, 9, 8, 7, 6,
			5, 4, 3, 2, 1
		];

		var convolution = new ConvolutionFilter();
		convolution.matrixX = -2;
		convolution.matrixY = 0;
		convolution.matrix = [9.0, 8, 7, 6, 5, 4, 3, 2, 1];
		convolution.divisor = -3;
		convolution.bias = -0.25;
		convolution.preserveAlpha = false;
		convolution.clamp = false;
		convolution.color = -12;
		convolution.alpha = 1.5;

		var displacement = new DisplacementMapFilter();
		displacement.mapBitmap = new BitmapData(2, 4, false, 0x112233);
		displacement.mapPoint = new Point(-3, 7);
		displacement.componentX = BitmapDataChannel.GREEN;
		displacement.componentY = BitmapDataChannel.ALPHA;
		displacement.scaleX = -15;
		displacement.scaleY = 22;
		displacement.mode = DisplacementMapFilterMode.IGNORE;
		displacement.color = -20;
		displacement.alpha = 2;

		var shadow = new DropShadowFilter();
		shadow.distance = -10;
		shadow.angle = -45;
		shadow.color = -1;
		shadow.alpha = 1.5;
		shadow.blurX = -2;
		shadow.blurY = 300;
		shadow.strength = -3;
		shadow.quality = 20;
		shadow.inner = true;
		shadow.knockout = true;
		shadow.hideObject = true;

		var glow = new GlowFilter();
		glow.color = -2;
		glow.alpha = -0.5;
		glow.blurX = -3;
		glow.blurY = 301;
		glow.strength = -4;
		glow.quality = 0;
		glow.inner = true;
		glow.knockout = true;

		return {
			bevel: captureBevel(bevel),
			blur: captureBlur(blur),
			colorMatrix: captureColorMatrix(colorMatrix),
			convolution: captureConvolution(convolution),
			displacement: captureDisplacement(displacement),
			dropShadow: captureDropShadow(shadow),
			glow: captureGlow(glow)
		};
	}

	private static function testEdges():Dynamic {
		var zeroKernel = new ConvolutionFilter(0, 0, []);
		var convolutionSetterError:Dynamic = null;
		try {
			zeroKernel.matrix = [];
		} catch (error:Dynamic) {
			convolutionSetterError = Std.string(error);
		}

		var colorMatrix = new ColorMatrixFilter([2.0]);
		colorMatrix.matrix = null;

		var displacement = new DisplacementMapFilter(null, null);
		displacement.mapPoint = null;

		return {
			bevel: captureBevel(new BevelFilter(-4, -720, 0xFFFFFF, -1, 0, 2, -5, 999, -1, -2, null, true)),
			blur: captureBlur(new BlurFilter(-5, 999, -4)),
			colorMatrixNullReset: captureColorMatrix(colorMatrix),
			convolutionZeroKernel: captureConvolution(zeroKernel),
			convolutionSetterError: convolutionSetterError,
			displacementNullPoint: captureDisplacement(displacement),
			dropShadow: captureDropShadow(new DropShadowFilter(-5, -720, -1, -1, -2, 999, -3, -4, true, true, true)),
			glow: captureGlow(new GlowFilter(-1, 2, -3, 999, -4, -5, true, true))
		};
	}

	private static function testDisplayObjectFilters():Dynamic {
		var sprite = new Sprite();
		var original = new BlurFilter(2, 3, 2);
		sprite.filters = [original];
		var firstRead = sprite.filters;
		var secondRead = sprite.filters;
		var applied:BlurFilter = cast firstRead[0];
		applied.blurX = 40;
		var unchanged:BlurFilter = cast sprite.filters[0];
		return {
			count: firstRead.length,
			sameAsAssigned: applied == original,
			readsShareArray: firstRead == secondRead,
			readsShareFilter: firstRead[0] == secondRead[0],
			assigned: captureBlur(original),
			firstReadAfterMutation: captureBlur(applied),
			storedAfterReadMutation: captureBlur(unchanged)
		};
	}

	private static function testClones(map:BitmapData):Dynamic {
		var bevel = createBevel();
		var bevelClone:BevelFilter = cast bevel.clone();
		var blur = new BlurFilter(5, 6, 2);
		var blurClone:BlurFilter = cast blur.clone();
		var colorMatrix = new ColorMatrixFilter([
			1.0, 0, 0, 0, 1,
			0, 1, 0, 0, 2,
			0, 0, 1, 0, 3,
			0, 0, 0, 1, 4
		]);
		var colorMatrixClone:ColorMatrixFilter = cast colorMatrix.clone();
		var convolution = new ConvolutionFilter(3, 3, [1.0, 2, 3, 4, 5, 6, 7, 8, 9]);
		var convolutionClone:ConvolutionFilter = cast convolution.clone();
		var convolutionSharesMatrix = convolution.matrix == convolutionClone.matrix;
		convolution.matrix[0] = 99;
		var displacement = createDisplacement(map);
		var displacementClone:DisplacementMapFilter = cast displacement.clone();
		var shadow = createDropShadow();
		var shadowClone:DropShadowFilter = cast shadow.clone();
		var glow = createGlow();
		var glowClone:GlowFilter = cast glow.clone();

		bevel.distance = 100;
		blur.blurX = 100;
		colorMatrix.matrix = null;
		displacement.mapPoint.x = 100;
		shadow.distance = 100;
		glow.blurX = 100;

		return {
			bevelSameReference: bevelClone == bevel,
			bevel: captureBevel(bevelClone),
			blurSameReference: blurClone == blur,
			blur: captureBlur(blurClone),
			colorMatrixSameReference: colorMatrixClone == colorMatrix,
			colorMatrixMatricesShareReference: colorMatrix.matrix == colorMatrixClone.matrix,
			colorMatrix: captureColorMatrix(colorMatrixClone),
			convolutionSameReference: convolutionClone == convolution,
			convolutionMatricesShareReference: convolutionSharesMatrix,
			convolutionCloneAfterSourceMatrixMutation: captureConvolution(convolutionClone),
			displacementSameReference: displacementClone == displacement,
			displacementSharesBitmap: displacementClone.mapBitmap == displacement.mapBitmap,
			displacementSharesPoint: displacementClone.mapPoint == displacement.mapPoint,
			displacement: captureDisplacement(displacementClone),
			shadowSameReference: shadowClone == shadow,
			shadow: captureDropShadow(shadowClone),
			glowSameReference: glowClone == glow,
			glow: captureGlow(glowClone)
		};
	}

	private static function captureBevel(filter:BevelFilter):Dynamic {
		return {
			distance: filter.distance,
			angle: filter.angle,
			highlightColor: filter.highlightColor,
			highlightAlpha: filter.highlightAlpha,
			shadowColor: filter.shadowColor,
			shadowAlpha: filter.shadowAlpha,
			blurX: filter.blurX,
			blurY: filter.blurY,
			strength: filter.strength,
			quality: filter.quality,
			type: filter.type,
			knockout: filter.knockout
		};
	}

	private static function captureBlur(filter:BlurFilter):Dynamic {
		return {blurX: filter.blurX, blurY: filter.blurY, quality: filter.quality};
	}

	private static function captureColorMatrix(filter:ColorMatrixFilter):Dynamic {
		var first = filter.matrix;
		var second = filter.matrix;
		return {matrix: first, readsShareReference: first == second};
	}

	private static function captureConvolution(filter:ConvolutionFilter):Dynamic {
		return {
			matrixX: filter.matrixX,
			matrixY: filter.matrixY,
			matrix: filter.matrix,
			divisor: filter.divisor,
			bias: filter.bias,
			preserveAlpha: filter.preserveAlpha,
			clamp: filter.clamp,
			color: filter.color,
			alpha: filter.alpha
		};
	}

	private static function captureDisplacement(filter:DisplacementMapFilter):Dynamic {
		return {
			mapWidth: filter.mapBitmap == null ? null : filter.mapBitmap.width,
			mapHeight: filter.mapBitmap == null ? null : filter.mapBitmap.height,
			mapPoint: filter.mapPoint == null ? null : {x: filter.mapPoint.x, y: filter.mapPoint.y},
			componentX: filter.componentX,
			componentY: filter.componentY,
			scaleX: filter.scaleX,
			scaleY: filter.scaleY,
			mode: filter.mode,
			color: filter.color,
			alpha: filter.alpha
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
