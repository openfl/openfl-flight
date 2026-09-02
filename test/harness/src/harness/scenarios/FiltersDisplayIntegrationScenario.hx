package harness.scenarios;

import openfl.display.Sprite;
import openfl.filters.BitmapFilter;
import openfl.filters.BlurFilter;
import openfl.filters.ColorMatrixFilter;
import openfl.filters.DropShadowFilter;
import openfl.filters.GlowFilter;
import openfl.geom.Rectangle;

class FiltersDisplayIntegrationScenario
{
	public static function run():Dynamic
	{
		return {
			assignmentClone: testAssignmentClone(),
			multipleFilters: testMultipleFilters(),
			removal: testRemoval(),
			containerBounds: testContainerBounds()
		};
	}

	private static function testAssignmentClone():Dynamic
	{
		var sprite = filledRect(0, 0, 20, 10);
		var originalBlur = new BlurFilter(4, 6, 2);
		var originalGlow = new GlowFilter(0x336699, 0.75, 8, 10, 2.5, 3, true, false);
		var assigned:Array<BitmapFilter> = [originalBlur, originalGlow];
		sprite.filters = assigned;

		originalBlur.blurX = 40;
		originalGlow.color = 0xFFFFFF;
		assigned.pop();

		var firstRead = sprite.filters;
		var storedBlur:BlurFilter = cast firstRead[0];
		var storedGlow:GlowFilter = cast firstRead[1];
		var initialCount = firstRead.length;
		firstRead.shift();
		firstRead[0] = new BlurFilter(99, 99, 1);
		var secondRead = sprite.filters;

		return {
			assignedArrayLengthAfterMutation: assigned.length,
			storedCountBeforeReadArrayMutation: initialCount,
			returnedArraysShareReference: firstRead == secondRead,
			storedCountAfterReadArrayMutation: secondRead.length,
			storedTypesAfterReadArrayMutation: filterTypes(secondRead),
			blurIsAssignmentClone: secondRead[0] != originalBlur,
			glowIsAssignmentClone: secondRead[1] != originalGlow,
			originalBlurAfterMutation: captureBlur(originalBlur),
			storedBlur: captureBlur(storedBlur),
			originalGlowColorAfterMutation: originalGlow.color,
			storedGlowColor: storedGlow.color
		};
	}

	private static function testMultipleFilters():Dynamic
	{
		var matrix = [
			1.0, 0, 0, 0, 12,
			0, 0.5, 0, 0, -8,
			0, 0, 1.5, 0, 4,
			0, 0, 0, 0.8, 0
		];
		var sprite = filledRect(-5, 2, 30, 18);
		sprite.filters = [
			new BlurFilter(8, 12, 2),
			new GlowFilter(0xABCDEF, 0.6, 10, 11, 3.5, 2, true, true),
			new DropShadowFilter(7, 30, 0x123456, 0.4, 8, 9, 2.5, 3, true, true, true),
			new ColorMatrixFilter(matrix)
		];
		var filters = sprite.filters;
		var blur:BlurFilter = cast filters[0];
		var glow:GlowFilter = cast filters[1];
		var shadow:DropShadowFilter = cast filters[2];
		var colorMatrix:ColorMatrixFilter = cast filters[3];

		return {
			count: filters.length,
			order: filterTypes(filters),
			cacheAsBitmap: sprite.cacheAsBitmap,
			blur: captureBlur(blur),
			glow: {
				color: glow.color,
				alpha: number(glow.alpha),
				blurX: number(glow.blurX),
				blurY: number(glow.blurY),
				strength: number(glow.strength),
				quality: glow.quality,
				inner: glow.inner,
				knockout: glow.knockout
			},
			dropShadow: {
				distance: number(shadow.distance),
				angle: number(shadow.angle),
				color: shadow.color,
				alpha: number(shadow.alpha),
				blurX: number(shadow.blurX),
				blurY: number(shadow.blurY),
				strength: number(shadow.strength),
				quality: shadow.quality,
				inner: shadow.inner,
				knockout: shadow.knockout,
				hideObject: shadow.hideObject
			},
			colorMatrix: colorMatrix.matrix
		};
	}

	private static function testRemoval():Dynamic
	{
		var sprite = filledRect(0, 0, 10, 10);
		sprite.filters = [new BlurFilter(5, 7, 1), new GlowFilter()];
		var applied = {count: sprite.filters.length, cacheAsBitmap: sprite.cacheAsBitmap};
		sprite.filters = null;
		var afterNull = {count: sprite.filters.length, cacheAsBitmap: sprite.cacheAsBitmap};
		sprite.filters = [new DropShadowFilter()];
		var reapplied = {count: sprite.filters.length, cacheAsBitmap: sprite.cacheAsBitmap};
		sprite.filters = [];
		var afterEmpty = {count: sprite.filters.length, cacheAsBitmap: sprite.cacheAsBitmap};

		return {
			applied: applied,
			afterNull: afterNull,
			reapplied: reapplied,
			afterEmpty: afterEmpty
		};
	}

	private static function testContainerBounds():Dynamic
	{
		var root = new Sprite();
		var container = new Sprite();
		container.x = 40;
		container.y = -15;
		var child = filledRect(-4, 3, 30, 20);
		child.x = 12;
		child.y = 7;
		child.rotation = 15;
		root.addChild(container);
		container.addChild(child);

		var before = captureBounds(root, container, child);
		container.filters = [new BlurFilter(12, 8, 2), new DropShadowFilter(6, 45, 0, 0.8, 4, 4, 1.5, 1)];
		var after = captureBounds(root, container, child);

		return {
			before: before,
			after: after,
			containerBoundsUnchanged: rectanglesEqual(before.containerSelf, after.containerSelf),
			childBoundsUnchanged: rectanglesEqual(before.childInContainer, after.childInContainer),
			rootBoundsUnchanged: rectanglesEqual(before.containerInRoot, after.containerInRoot)
		};
	}

	private static function captureBounds(root:Sprite, container:Sprite, child:Sprite):Dynamic
	{
		return {
			containerSelf: rectangle(container.getBounds(container)),
			childInContainer: rectangle(child.getBounds(container)),
			containerInRoot: rectangle(container.getBounds(root)),
			containerWidth: number(container.width),
			containerHeight: number(container.height)
		};
	}

	private static function filterTypes(filters:Array<BitmapFilter>):Array<String>
	{
		return [for (filter in filters) filterType(filter)];
	}

	private static function filterType(filter:BitmapFilter):String
	{
		if (Std.isOfType(filter, BlurFilter)) return "BlurFilter";
		if (Std.isOfType(filter, GlowFilter)) return "GlowFilter";
		if (Std.isOfType(filter, DropShadowFilter)) return "DropShadowFilter";
		if (Std.isOfType(filter, ColorMatrixFilter)) return "ColorMatrixFilter";
		return "BitmapFilter";
	}

	private static function filledRect(x:Float, y:Float, width:Float, height:Float):Sprite
	{
		var sprite = new Sprite();
		sprite.graphics.beginFill(0x336699);
		sprite.graphics.drawRect(x, y, width, height);
		sprite.graphics.endFill();
		return sprite;
	}

	private static function captureBlur(filter:BlurFilter):Dynamic
	{
		return {blurX: number(filter.blurX), blurY: number(filter.blurY), quality: filter.quality};
	}

	private static function rectangle(value:Rectangle):Dynamic
	{
		return {x: number(value.x), y: number(value.y), width: number(value.width), height: number(value.height)};
	}

	private static function rectanglesEqual(left:Dynamic, right:Dynamic):Bool
	{
		return left.x == right.x && left.y == right.y && left.width == right.width && left.height == right.height;
	}

	private static function number(value:Float):Float
	{
		return Math.round(value * 1000000) / 1000000;
	}
}
