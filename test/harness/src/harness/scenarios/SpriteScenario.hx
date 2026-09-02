package harness.scenarios;

import openfl.display.Sprite;
import openfl.geom.Rectangle;

class SpriteScenario
{
	public static function run():Dynamic
	{
		var sprite = new Sprite();
		var firstGraphics = sprite.graphics;
		var secondGraphics = sprite.graphics;
		var defaults = {
			buttonMode: sprite.buttonMode,
			dropTargetIsNull: sprite.dropTarget == null,
			graphicsIsNonNull: firstGraphics != null,
			graphicsIsStable: firstGraphics == secondGraphics,
			hitAreaIsNull: sprite.hitArea == null,
			useHandCursor: sprite.useHandCursor
		};

		var hitArea = new Sprite();
		sprite.buttonMode = true;
		sprite.hitArea = hitArea;
		sprite.useHandCursor = false;
		var values = {
			buttonMode: sprite.buttonMode,
			hitAreaMatches: sprite.hitArea == hitArea,
			useHandCursor: sprite.useHandCursor
		};

		firstGraphics.beginFill(0x336699);
		firstGraphics.drawRect(10, 20, 30, 40);
		firstGraphics.endFill();
		var bounds = sprite.getBounds(sprite);

		var dragError:Dynamic = null;
		try
		{
			sprite.startDrag();
			sprite.stopDrag();
			sprite.startDrag(true, new Rectangle(-5, -6, 10, 12));
			sprite.stopDrag();
		}
		catch (error:Dynamic)
		{
			dragError = error;
		}

		return {
			defaults: defaults,
			values: values,
			graphicsBounds: {
				x: bounds.x,
				y: bounds.y,
				width: bounds.width,
				height: bounds.height,
				spriteWidth: sprite.width,
				spriteHeight: sprite.height
			},
			detachedDragThrew: dragError != null
		};
	}
}
