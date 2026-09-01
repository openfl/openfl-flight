package harness.scenarios;

import openfl.display.Sprite;
import openfl.filters.BitmapFilter;
import openfl.filters.BlurFilter;

class DisplayObjectPropertyEdgesScenario {
	public static function run():Dynamic {
		return {
			alphaClamping: testAlphaClamping(),
			widthHeightScale: testWidthHeightScale(),
			filtersArrayCopy: testFiltersArrayCopy(),
			filtersCacheAsBitmap: testFiltersCacheAsBitmap(),
			visibleDoesNotAffectBounds: testVisibleDoesNotAffectBounds(),
			parentChildReferences: testParentChildReferences()
		};
	}

	private static function createSizedSprite():Sprite {
		var sprite = new Sprite();
		sprite.graphics.beginFill(0xFF0000);
		sprite.graphics.drawRect(0, 0, 100, 50);
		sprite.graphics.endFill();
		return sprite;
	}

	private static function testAlphaClamping():Dynamic {
		var sprite = new Sprite();
		sprite.alpha = 1.5;
		var above = sprite.alpha;
		sprite.alpha = -0.5;
		return {
			above: above,
			below: sprite.alpha
		};
	}

	private static function testWidthHeightScale():Dynamic {
		var sprite = createSizedSprite();
		var initialWidth = sprite.width;
		var initialHeight = sprite.height;
		sprite.width = 200;
		var widthScale = sprite.scaleX;
		sprite.height = 100;
		return {
			initialWidth: initialWidth,
			initialHeight: initialHeight,
			width: sprite.width,
			height: sprite.height,
			scaleX: widthScale,
			scaleY: sprite.scaleY
		};
	}

	private static function testFiltersArrayCopy():Dynamic {
		var sprite = new Sprite();
		var filters:Array<BitmapFilter> = [new BlurFilter(2, 3, 1)];
		sprite.filters = filters;
		filters.push(new BlurFilter());
		var firstRead = sprite.filters;
		firstRead.push(new BlurFilter());
		var secondRead = sprite.filters;
		return {
			originalCount: filters.length,
			firstReadCount: firstRead.length,
			secondReadCount: secondRead.length,
			sameArrayReference: secondRead == filters
		};
	}

	private static function testFiltersCacheAsBitmap():Dynamic {
		var sprite = new Sprite();
		var before = sprite.cacheAsBitmap;
		var filters:Array<BitmapFilter> = [new BlurFilter()];
		sprite.filters = filters;
		var withFilter = sprite.cacheAsBitmap;
		sprite.filters = [];
		return {
			before: before,
			withFilter: withFilter,
			afterClear: sprite.cacheAsBitmap
		};
	}

	private static function testVisibleDoesNotAffectBounds():Dynamic {
		var sprite = createSizedSprite();
		var before = sprite.getBounds(sprite);
		sprite.visible = false;
		var after = sprite.getBounds(sprite);
		return {
			width: sprite.width,
			height: sprite.height,
			boundsWidthBefore: before.width,
			boundsHeightBefore: before.height,
			boundsWidthAfter: after.width,
			boundsHeightAfter: after.height
		};
	}

	private static function testParentChildReferences():Dynamic {
		var parent = new Sprite();
		var child = new Sprite();
		var unparented = new Sprite();
		parent.addChild(child);
		return {
			childParentIsParent: child.parent == parent,
			unparentedParentIsNull: unparented.parent == null
		};
	}
}
