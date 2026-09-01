package harness.scenarios;

import openfl.display.Sprite;
import openfl.geom.ColorTransform;
import openfl.geom.Matrix;

class TransformScenario {
	public static function run():Dynamic {
		return {
			matrixSync: testMatrixSync(),
			rotationMatrixSync: testRotationMatrixSync(),
			scaleMatrixSync: testScaleMatrixSync(),
			concatenatedMatrix: testConcatenatedMatrix(),
			colorTransformAccess: testColorTransformAccess()
		};
	}

	private static function testMatrixSync():Dynamic {
		var sprite = new Sprite();
		sprite.x = 100;
		sprite.y = 50;
		var fromProperties = sprite.transform.matrix;
		sprite.transform.matrix = new Matrix(1, 0, 0, 1, 200, 75);
		return {
			matrixTX: fromProperties.tx,
			matrixTY: fromProperties.ty,
			spriteX: sprite.x,
			spriteY: sprite.y
		};
	}

	private static function testRotationMatrixSync():Dynamic {
		var sprite = new Sprite();
		sprite.rotation = 45;
		var fromProperty = sprite.transform.matrix;
		var radians = Math.PI / 6;
		sprite.transform.matrix = new Matrix(Math.cos(radians), Math.sin(radians), -Math.sin(radians), Math.cos(radians));
		return {
			matrixA: fromProperty.a,
			matrixB: fromProperty.b,
			matrixC: fromProperty.c,
			matrixD: fromProperty.d,
			spriteRotation: sprite.rotation
		};
	}

	private static function testScaleMatrixSync():Dynamic {
		var sprite = new Sprite();
		sprite.scaleX = 2;
		var fromProperty = sprite.transform.matrix;
		sprite.transform.matrix = new Matrix(3, 0, 0, 4);
		return {
			matrixA: fromProperty.a,
			scaleX: sprite.scaleX,
			scaleY: sprite.scaleY
		};
	}

	private static function testConcatenatedMatrix():Dynamic {
		var parent = new Sprite();
		var child = new Sprite();
		parent.x = 100;
		child.x = 50;
		parent.addChild(child);
		var matrix = child.transform.concatenatedMatrix;
		return {
			tx: matrix.tx,
			ty: matrix.ty
		};
	}

	private static function testColorTransformAccess():Dynamic {
		var sprite = new Sprite();
		var value = new ColorTransform(0.5, 0.6, 0.7, 0.8, 10, 20, 30, 40);
		sprite.transform.colorTransform = value;
		var readBack = sprite.transform.colorTransform;
		return {
			sameReference: readBack == value,
			redMultiplier: readBack.redMultiplier,
			greenMultiplier: readBack.greenMultiplier,
			blueMultiplier: readBack.blueMultiplier,
			alphaMultiplier: readBack.alphaMultiplier,
			redOffset: readBack.redOffset,
			greenOffset: readBack.greenOffset,
			blueOffset: readBack.blueOffset,
			alphaOffset: readBack.alphaOffset,
			displayAlpha: sprite.alpha
		};
	}
}
