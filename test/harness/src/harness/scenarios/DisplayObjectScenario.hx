package harness.scenarios;

import openfl.display.BlendMode;
import openfl.display.Sprite;
import openfl.geom.Point;
import openfl.geom.Rectangle;

class DisplayObjectScenario {
	public static function run():Dynamic {
		return {
			construct: testConstruct(),
			defaultProperties: testDefaultProperties(),
			nameAssignment: testNameAssignment(),
			autoNaming: testAutoNaming(),
			alphaProperty: testAlphaProperty(),
			visibleProperty: testVisibleProperty(),
			visibleHitTest: testVisibleHitTest(),
			positionProperties: testPositionProperties(),
			scaleProperties: testScaleProperties(),
			scaleDimensions: testScaleDimensions(),
			rotationProperty: testRotationProperty(),
			blendMode: testBlendMode(),
			cacheAsBitmap: testCacheAsBitmap(),
			loaderInfo: testLoaderInfo(),
			mask: testMask(),
			transformedBounds: testTransformedBounds(),
			coordinateConversion: testCoordinateConversion()
		};
	}

	private static function testConstruct():Dynamic {
		var sprite = new Sprite();
		return {
			notNull: sprite != null,
			parentNull: sprite.parent == null,
			stageNull: sprite.stage == null
		};
	}

	private static function testDefaultProperties():Dynamic {
		var sprite = new Sprite();
		return {
			x: sprite.x,
			y: sprite.y,
			alpha: sprite.alpha,
			visible: sprite.visible,
			scaleX: sprite.scaleX,
			scaleY: sprite.scaleY,
			rotation: sprite.rotation,
			mouseEnabled: sprite.mouseEnabled
		};
	}

	private static function testNameAssignment():Dynamic {
		var sprite = new Sprite();
		sprite.name = "testSprite";
		return {
			name: sprite.name
		};
	}

	private static function testAutoNaming():Dynamic {
		var first = new Sprite();
		var second = new Sprite();
		var firstNumber = autoNameNumber(first.name);
		var secondNumber = autoNameNumber(second.name);
		return {
			firstMatchesPattern: firstNumber != null,
			secondMatchesPattern: secondNumber != null,
			sequential: firstNumber != null && secondNumber == firstNumber + 1
		};
	}

	private static function testAlphaProperty():Dynamic {
		var sprite = new Sprite();
		sprite.alpha = 0.5;
		var halfAlpha = sprite.alpha;
		sprite.alpha = 0;
		var zeroAlpha = sprite.alpha;
		sprite.alpha = 1;
		var fullAlpha = sprite.alpha;
		sprite.alpha = -0.5;
		var negativeAlpha = sprite.alpha;
		sprite.alpha = 1.5;
		var aboveOneAlpha = sprite.alpha;
		return {
			half: halfAlpha,
			zero: zeroAlpha,
			full: fullAlpha,
			negative: negativeAlpha,
			aboveOne: aboveOneAlpha
		};
	}

	private static function testVisibleProperty():Dynamic {
		var sprite = new Sprite();
		var defaultVisible = sprite.visible;
		sprite.visible = false;
		var afterHide = sprite.visible;
		sprite.visible = true;
		var afterShow = sprite.visible;
		return {
			defaultVisible: defaultVisible,
			afterHide: afterHide,
			afterShow: afterShow
		};
	}

	private static function testVisibleHitTest():Dynamic {
		var parent = new Sprite();
		var target = sizedSprite(40, 30);
		var probe = sizedSprite(5, 5);
		probe.x = 10;
		probe.y = 10;
		parent.addChild(target);
		parent.addChild(probe);
		var visible = target.hitTestObject(probe);
		target.visible = false;
		var hidden = target.hitTestObject(probe);
		target.visible = true;
		return {
			visible: visible,
			hidden: hidden,
			shownAgain: target.hitTestObject(probe)
		};
	}

	private static function testPositionProperties():Dynamic {
		var sprite = new Sprite();
		sprite.x = 100;
		sprite.y = 200;
		return {
			x: sprite.x,
			y: sprite.y
		};
	}

	private static function testScaleProperties():Dynamic {
		var sprite = new Sprite();
		sprite.scaleX = 2.0;
		sprite.scaleY = 0.5;
		return {
			scaleX: sprite.scaleX,
			scaleY: sprite.scaleY
		};
	}

	private static function testScaleDimensions():Dynamic {
		var sprite = sizedSprite(40, 20);
		var initialWidth = sprite.width;
		var initialHeight = sprite.height;
		sprite.scaleX = 2;
		sprite.scaleY = 0.5;
		return {
			initialWidth: number(initialWidth),
			initialHeight: number(initialHeight),
			width: number(sprite.width),
			height: number(sprite.height),
			scaleX: number(sprite.scaleX),
			scaleY: number(sprite.scaleY)
		};
	}

	private static function testRotationProperty():Dynamic {
		var sprite = new Sprite();
		sprite.rotation = 0;
		var zero = sprite.rotation;
		sprite.rotation = 90;
		var ninety = sprite.rotation;
		sprite.rotation = 360;
		var fullTurn = sprite.rotation;
		sprite.rotation = -90;
		var negative = sprite.rotation;
		sprite.rotation = 450;
		return {
			zero: number(zero),
			ninety: number(ninety),
			fullTurn: number(fullTurn),
			negative: number(negative),
			aboveFullTurn: number(sprite.rotation)
		};
	}

	private static function testBlendMode():Dynamic {
		var sprite = new Sprite();
		var initial = sprite.blendMode;
		sprite.blendMode = BlendMode.ADD;
		var add = sprite.blendMode;
		sprite.blendMode = BlendMode.MULTIPLY;
		return {
			initial: initial,
			add: add,
			multiply: sprite.blendMode
		};
	}

	private static function testCacheAsBitmap():Dynamic {
		var sprite = new Sprite();
		var initial = sprite.cacheAsBitmap;
		sprite.cacheAsBitmap = true;
		var enabled = sprite.cacheAsBitmap;
		sprite.cacheAsBitmap = false;
		return {
			initial: initial,
			enabled: enabled,
			disabled: sprite.cacheAsBitmap
		};
	}

	private static function testLoaderInfo():Dynamic {
		var sprite = new Sprite();
		return {
			unparentedIsNull: sprite.loaderInfo == null
		};
	}

	private static function testMask():Dynamic {
		var sprite = sizedSprite(40, 20);
		var mask = sizedSprite(10, 10);
		sprite.mask = mask;
		var assigned = sprite.mask == mask;
		sprite.mask = null;
		return {
			assigned: assigned,
			cleared: sprite.mask == null
		};
	}

	private static function testTransformedBounds():Dynamic {
		var parent = new Sprite();
		var sprite = sizedSprite(40, 20);
		sprite.x = 15;
		sprite.y = 25;
		sprite.scaleX = 2;
		sprite.rotation = 90;
		parent.addChild(sprite);
		return {
			selfBounds: rect(sprite.getBounds(sprite)),
			parentBounds: rect(sprite.getBounds(parent)),
			selfRect: rect(sprite.getRect(sprite)),
			parentRect: rect(sprite.getRect(parent))
		};
	}

	private static function testCoordinateConversion():Dynamic {
		var identity = new Sprite();
		var localPoint = new Point(3, 4);
		var identityGlobal = identity.localToGlobal(localPoint);
		var identityLocal = identity.globalToLocal(identityGlobal);

		var parent = new Sprite();
		var child = new Sprite();
		parent.x = 100;
		parent.y = 50;
		parent.scaleX = 2;
		parent.scaleY = 3;
		child.x = 10;
		child.y = 5;
		parent.addChild(child);
		var transformedGlobal = child.localToGlobal(localPoint);
		var transformedLocal = child.globalToLocal(transformedGlobal);
		return {
			identityGlobal: point(identityGlobal),
			identityRoundTrip: point(identityLocal),
			transformedGlobal: point(transformedGlobal),
			transformedRoundTrip: point(transformedLocal)
		};
	}

	private static function sizedSprite(width:Float, height:Float):Sprite {
		var sprite = new Sprite();
		sprite.graphics.beginFill(0x336699);
		sprite.graphics.drawRect(0, 0, width, height);
		sprite.graphics.endFill();
		return sprite;
	}

	private static function autoNameNumber(value:String):Null<Int> {
		if (value == null || !StringTools.startsWith(value, "instance")) return null;
		return Std.parseInt(value.substr("instance".length));
	}

	private static function point(value:Point):Dynamic {
		return {x: number(value.x), y: number(value.y)};
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
