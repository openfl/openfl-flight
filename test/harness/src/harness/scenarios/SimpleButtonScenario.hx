package harness.scenarios;

import openfl.display.SimpleButton;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.media.SoundTransform;

class SimpleButtonScenario {
	public static function run():Dynamic {
		var defaultButton = new SimpleButton();
		var defaults = {
			enabled: defaultButton.enabled,
			useHandCursor: defaultButton.useHandCursor,
			trackAsMenu: defaultButton.trackAsMenu,
			tabEnabled: defaultButton.tabEnabled,
			upStatePresent: defaultButton.upState != null,
			overStatePresent: defaultButton.overState != null,
			downStatePresent: defaultButton.downState != null,
			hitTestStatePresent: defaultButton.hitTestState != null,
			soundVolume: defaultButton.soundTransform.volume,
			soundPan: defaultButton.soundTransform.pan
		};

		var owner = new Sprite();
		var up = createState("up", 10);
		var over = createState("over", 20);
		var down = createState("down", 30);
		var hit = createState("hit", 40);
		owner.addChild(up);
		var button = new SimpleButton(up, over, down, hit);
		var constructor = {
			up: button.upState == up,
			over: button.overState == over,
			down: button.downState == down,
			hit: button.hitTestState == hit,
			upDetachedFromParent: up.parent == null,
			initialWidth: button.width
		};

		var transitions:Array<Float> = [button.width];
		button.dispatchEvent(mouse(MouseEvent.MOUSE_OVER));
		transitions.push(button.width);
		button.dispatchEvent(mouse(MouseEvent.MOUSE_DOWN, true));
		transitions.push(button.width);
		button.dispatchEvent(mouse(MouseEvent.MOUSE_OUT));
		transitions.push(button.width);
		button.dispatchEvent(mouse(MouseEvent.MOUSE_OVER, true));
		transitions.push(button.width);
		button.dispatchEvent(mouse(MouseEvent.MOUSE_UP));
		transitions.push(button.width);

		button.dispatchEvent(mouse(MouseEvent.MOUSE_OUT));
		var replacementUp = createState("replacementUp", 15);
		button.upState = replacementUp;
		var replacedActiveUpWidth = button.width;
		button.dispatchEvent(mouse(MouseEvent.MOUSE_OVER));
		var replacementOver = createState("replacementOver", 25);
		button.overState = replacementOver;
		var replacedActiveOverWidth = button.width;

		button.enabled = false;
		button.dispatchEvent(mouse(MouseEvent.MOUSE_DOWN, true));
		var disabledDownWidth = button.width;
		button.dispatchEvent(mouse(MouseEvent.MOUSE_UP));
		var disabledUpWidth = button.width;
		button.useHandCursor = false;
		button.trackAsMenu = true;

		var sourceTransform = new SoundTransform(0.25, -0.5);
		sourceTransform.leftToLeft = 0.75;
		button.soundTransform = sourceTransform;
		sourceTransform.volume = 1;
		var firstRead = button.soundTransform;
		firstRead.pan = 1;
		var secondRead = button.soundTransform;

		return {
			defaults: defaults,
			constructor: constructor,
			stateAssignments: testStateAssignments(),
			transitions: transitions,
			replacements: {
				activeUpWidth: replacedActiveUpWidth,
				activeOverWidth: replacedActiveOverWidth
			},
			disabled: {
				downWidth: disabledDownWidth,
				upWidth: disabledUpWidth
			},
			values: {
				enabled: button.enabled,
				useHandCursor: button.useHandCursor,
				trackAsMenu: button.trackAsMenu,
				tabEnabled: button.tabEnabled,
				up: button.upState == replacementUp,
				over: button.overState == replacementOver,
				down: button.downState == down,
				hit: button.hitTestState == hit
			},
			soundTransform: {
				setterCopied: firstRead != sourceTransform,
				getterCopied: secondRead != firstRead,
				firstVolume: firstRead.volume,
				firstPanAfterMutation: firstRead.pan,
				secondVolume: secondRead.volume,
				secondPan: secondRead.pan,
				leftToLeft: secondRead.leftToLeft
			}
		};
	}

	private static function testStateAssignments():Dynamic {
		var button = new SimpleButton();
		var up = createState("assignedUp", 11);
		var over = createState("assignedOver", 22);
		var down = createState("assignedDown", 33);
		var hit = createState("assignedHit", 44);

		button.upState = up;
		button.overState = over;
		button.downState = down;
		button.hitTestState = hit;
		var assigned = {
			up: button.upState == up,
			over: button.overState == over,
			down: button.downState == down,
			hit: button.hitTestState == hit,
			upWidth: button.width
		};

		button.dispatchEvent(mouse(MouseEvent.MOUSE_OVER));
		var overWidth = button.width;
		button.dispatchEvent(mouse(MouseEvent.MOUSE_DOWN, true));
		var downWidth = button.width;

		button.downState = null;
		button.dispatchEvent(mouse(MouseEvent.MOUSE_OUT));
		var returnedUpWidth = button.width;
		button.upState = null;
		button.dispatchEvent(mouse(MouseEvent.MOUSE_OVER));
		var returnedOverWidth = button.width;
		button.overState = null;
		button.hitTestState = null;

		var cleared = {
			up: button.upState == null,
			over: button.overState == null,
			down: button.downState == null,
			hit: button.hitTestState == null
		};

		button.upState = up;
		button.overState = over;
		button.downState = down;
		button.hitTestState = hit;
		button.dispatchEvent(mouse(MouseEvent.MOUSE_OUT));

		return {
			assigned: assigned,
			activeWidths: {
				over: overWidth,
				down: downWidth,
				returnedUp: returnedUpWidth,
				returnedOver: returnedOverWidth
			},
			cleared: cleared,
			reassigned: {
				up: button.upState == up,
				over: button.overState == over,
				down: button.downState == down,
				hit: button.hitTestState == hit,
				upWidth: button.width
			}
		};
	}

	private static function createState(name:String, width:Float):Sprite {
		var state = new Sprite();
		state.name = name;
		state.graphics.beginFill(0x336699);
		state.graphics.drawRect(0, 0, width, 10);
		state.graphics.endFill();
		return state;
	}

	private static function mouse(type:String, buttonDown:Bool = false):MouseEvent {
		return new MouseEvent(type, true, false, 0, 0, null, false, false, false, buttonDown);
	}
}
