package harness.scenarios;

import openfl.display.Sprite;

class DisplayObjectScenario {
	public static function run():Dynamic {
		return {
			construct: testConstruct(),
			defaultProperties: testDefaultProperties(),
			nameAssignment: testNameAssignment(),
			alphaProperty: testAlphaProperty(),
			visibleProperty: testVisibleProperty(),
			positionProperties: testPositionProperties(),
			scaleProperties: testScaleProperties(),
			rotationProperty: testRotationProperty()
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

	private static function testAlphaProperty():Dynamic {
		var sprite = new Sprite();
		sprite.alpha = 0.5;
		var halfAlpha = sprite.alpha;
		sprite.alpha = 0;
		var zeroAlpha = sprite.alpha;
		sprite.alpha = 1;
		var fullAlpha = sprite.alpha;
		return {
			half: halfAlpha,
			zero: zeroAlpha,
			full: fullAlpha
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

	private static function testRotationProperty():Dynamic {
		var sprite = new Sprite();
		sprite.rotation = 45;
		return {
			rotation: sprite.rotation
		};
	}
}
