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
			tabEnabled: sprite.tabEnabled,
			useHandCursor: sprite.useHandCursor
		};

		var hitArea = new Sprite();
		sprite.buttonMode = true;
		var implicitTabWithButtonMode = sprite.tabEnabled;
		sprite.hitArea = hitArea;
		sprite.useHandCursor = false;
		var values = {
			buttonMode: sprite.buttonMode,
			hitAreaMatches: sprite.hitArea == hitArea,
			useHandCursor: sprite.useHandCursor
		};
		sprite.hitArea = null;
		var hitAreaClearedIsNull = sprite.hitArea == null;

		sprite.tabEnabled = false;
		var explicitFalseWithButtonMode = sprite.tabEnabled;
		sprite.buttonMode = false;
		var explicitFalseWithoutButtonMode = sprite.tabEnabled;
		sprite.buttonMode = true;
		var explicitFalseAfterButtonToggle = sprite.tabEnabled;
		var explicitTabSprite = new Sprite();
		explicitTabSprite.tabEnabled = true;

		firstGraphics.beginFill(0x336699);
		firstGraphics.drawRect(10, 20, 30, 40);
		firstGraphics.endFill();
		var bounds = sprite.getBounds(sprite);

		return {
			defaults: defaults,
			values: values,
			hitAreaClearedIsNull: hitAreaClearedIsNull,
			tabEnabled: {
				implicitWithButtonMode: implicitTabWithButtonMode,
				explicitFalseWithButtonMode: explicitFalseWithButtonMode,
				explicitFalseWithoutButtonMode: explicitFalseWithoutButtonMode,
				explicitFalseAfterButtonToggle: explicitFalseAfterButtonToggle,
				explicitTrueWithoutButtonMode: explicitTabSprite.tabEnabled
			},
			graphicsBounds: {
				x: bounds.x,
				y: bounds.y,
				width: bounds.width,
				height: bounds.height,
				spriteWidth: sprite.width,
				spriteHeight: sprite.height,
				graphicsAfterDrawIsSame: sprite.graphics == firstGraphics
			},
			detachedDrag: {
				stageIsNull: sprite.stage == null,
				startDefaultDoesNotThrow: doesNotThrow(function() sprite.startDrag()),
				stopDefaultDoesNotThrow: doesNotThrow(function() sprite.stopDrag()),
				startConstrainedDoesNotThrow: doesNotThrow(function() sprite.startDrag(true, new Rectangle(-5, -6, 10, 12))),
				stopConstrainedDoesNotThrow: doesNotThrow(function() sprite.stopDrag()),
				dropTargetRemainsNull: sprite.dropTarget == null
			}
		};
	}

	private static function doesNotThrow(operation:Void->Void):Bool
	{
		try
		{
			operation();
			return true;
		}
		catch (_:Dynamic)
		{
			return false;
		}
	}
}
