package harness.scenarios;

import openfl.display.CanvasRenderer;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.ErrorEvent;
import openfl.events.FocusEvent;
import openfl.events.FullScreenEvent;
import openfl.events.IOErrorEvent;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.events.ProgressEvent;
import openfl.events.RenderEvent;
import openfl.events.SecurityErrorEvent;
import openfl.events.TextEvent;
import openfl.events.TimerEvent;
import openfl.geom.ColorTransform;
import openfl.geom.Matrix;
import openfl.ui.KeyLocation;

class EventSubclassesScenario {
	public static function run():Dynamic {
		return {
			mouseEvent: testMouseEvent(),
			keyboardEvent: testKeyboardEvent(),
			focusEvent: testFocusEvent(),
			progressEvent: testProgressEvent(),
			errorEvent: testErrorEvent(),
			ioErrorEvent: testIOErrorEvent(),
			securityErrorEvent: testSecurityErrorEvent(),
			textEvent: testTextEvent(),
			timerEvent: testTimerEvent(),
			fullScreenEvent: testFullScreenEvent(),
			renderEvent: testRenderEvent(),
			cloneBehavior: testCloneBehavior()
		};
	}

	private static function testMouseEvent():Dynamic {
		var defaults = new MouseEvent(MouseEvent.CLICK);
		var related = new Sprite();
		var target = new Sprite();
		target.x = 100;
		target.y = -50;
		target.scaleX = 2;
		target.scaleY = 3;
		var e = new MouseEvent(MouseEvent.MOUSE_OUT, true, true, 10.5, -4.25, related, true, true, true, true, -3, true, true, 2);
		target.dispatchEvent(e);

		return {
			defaults: captureMouseEvent(defaults, null),
			values: captureMouseEvent(e, related),
			isEvent: Std.isOfType(e, Event),
			className: Type.getClassName(Type.getClass(e))
		};
	}

	private static function captureMouseEvent(event:MouseEvent, expectedRelated:Sprite):Dynamic {
		return {
			type: event.type,
			bubbles: event.bubbles,
			cancelable: event.cancelable,
			localX: event.localX,
			localY: event.localY,
			stageX: Math.isNaN(event.stageX) ? null : event.stageX,
			stageY: Math.isNaN(event.stageY) ? null : event.stageY,
			relatedObjectMatches: event.relatedObject == expectedRelated,
			ctrlKey: event.ctrlKey,
			altKey: event.altKey,
			shiftKey: event.shiftKey,
			buttonDown: event.buttonDown,
			delta: event.delta,
			commandKey: event.commandKey,
			controlKey: event.controlKey,
			clickCount: event.clickCount,
			isRelatedObjectInaccessible: event.isRelatedObjectInaccessible
		};
	}

	private static function testKeyboardEvent():Dynamic {
		var defaults = new KeyboardEvent(KeyboardEvent.KEY_DOWN);
		var e = new KeyboardEvent(KeyboardEvent.KEY_UP, true, true, 97, 222, KeyLocation.RIGHT, true, true, true, true, true);

		return {
			defaults: captureKeyboardEvent(defaults),
			values: captureKeyboardEvent(e),
			isEvent: Std.isOfType(e, Event),
			className: Type.getClassName(Type.getClass(e))
		};
	}

	private static function captureKeyboardEvent(event:KeyboardEvent):Dynamic {
		return {
			type: event.type,
			bubbles: event.bubbles,
			cancelable: event.cancelable,
			charCode: event.charCode,
			keyCode: event.keyCode,
			keyLocation: event.keyLocation,
			ctrlKey: event.ctrlKey,
			altKey: event.altKey,
			shiftKey: event.shiftKey,
			controlKey: event.controlKey,
			commandKey: event.commandKey
		};
	}

	private static function testFocusEvent():Dynamic {
		var defaults = new FocusEvent(FocusEvent.FOCUS_IN);
		var related = new Sprite();
		var e = new FocusEvent(FocusEvent.KEY_FOCUS_CHANGE, true, true, related, true, 9);

		return {
			defaults: captureFocusEvent(defaults, null),
			values: captureFocusEvent(e, related),
			isEvent: Std.isOfType(e, Event),
			className: Type.getClassName(Type.getClass(e))
		};
	}

	private static function captureFocusEvent(event:FocusEvent, expectedRelated:Sprite):Dynamic {
		var hasInaccessible = Reflect.hasField(event, "isRelatedObjectInaccessible");
		return {
			type: event.type,
			bubbles: event.bubbles,
			cancelable: event.cancelable,
			relatedObjectMatches: event.relatedObject == expectedRelated,
			shiftKey: event.shiftKey,
			keyCode: event.keyCode,
			isRelatedObjectInaccessible: {
				available: hasInaccessible,
				value: hasInaccessible ? Reflect.field(event, "isRelatedObjectInaccessible") : null
			}
		};
	}

	private static function testProgressEvent():Dynamic {
		var e = new ProgressEvent(ProgressEvent.PROGRESS, false, false, 50, 100);

		return {
			type: e.type,
			bytesLoaded: e.bytesLoaded,
			bytesTotal: e.bytesTotal,
			isEvent: Std.isOfType(e, Event),
			className: Type.getClassName(Type.getClass(e))
		};
	}

	private static function testErrorEvent():Dynamic {
		var e = new ErrorEvent(ErrorEvent.ERROR, false, false, "test error", 42);

		return {
			type: e.type,
			text: e.text,
			errorID: e.errorID,
			isEvent: Std.isOfType(e, Event),
			isTextEvent: Std.isOfType(e, TextEvent),
			className: Type.getClassName(Type.getClass(e))
		};
	}

	private static function testIOErrorEvent():Dynamic {
		var e = new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false, "io error");

		return {
			type: e.type,
			text: e.text,
			isErrorEvent: Std.isOfType(e, ErrorEvent),
			isEvent: Std.isOfType(e, Event),
			className: Type.getClassName(Type.getClass(e))
		};
	}

	private static function testSecurityErrorEvent():Dynamic {
		var e = new SecurityErrorEvent(SecurityErrorEvent.SECURITY_ERROR, false, false, "sec error");

		return {
			type: e.type,
			text: e.text,
			isErrorEvent: Std.isOfType(e, ErrorEvent),
			className: Type.getClassName(Type.getClass(e))
		};
	}

	private static function testTextEvent():Dynamic {
		var defaults = new TextEvent(TextEvent.TEXT_INPUT);
		var e = new TextEvent(TextEvent.TEXT_INPUT, false, false, "hello");

		return {
			type: e.type,
			defaultText: defaults.text,
			text: e.text,
			isEvent: Std.isOfType(e, Event),
			className: Type.getClassName(Type.getClass(e))
		};
	}

	private static function testTimerEvent():Dynamic {
		var e = new TimerEvent(TimerEvent.TIMER, false, false);

		return {
			type: e.type,
			isEvent: Std.isOfType(e, Event),
			className: Type.getClassName(Type.getClass(e))
		};
	}

	private static function testFullScreenEvent():Dynamic {
		var event = new FullScreenEvent(FullScreenEvent.FULL_SCREEN_INTERACTIVE_ACCEPTED, true, true, true, true);
		var clone = event.clone();

		return {
			type: event.type,
			bubbles: event.bubbles,
			cancelable: event.cancelable,
			fullScreen: event.fullScreen,
			interactive: event.interactive,
			activating: event.activating,
			cloneFullScreen: clone.fullScreen,
			cloneInteractive: clone.interactive
		};
	}

	private static function testRenderEvent():Dynamic {
		var matrix = new Matrix(2, 3, 4, 5, 6, 7);
		var color = new ColorTransform(0.1, 0.2, 0.3, 0.4, 10, 20, 30, 40);
		var constructed = new RenderEvent(RenderEvent.RENDER_CANVAS, true, true, matrix, color, false);
		var clone = constructed.clone();

		var target = new Sprite();
		target.x = 12;
		target.y = -8;
		target.scaleX = 2;
		target.scaleY = 3;
		target.transform.colorTransform = color;
		var renderer = @:privateAccess new CanvasRenderer(null);
		var rendererMatches = false;
		var dispatchedType:String = null;
		var dispatchedMatrix:Dynamic = null;
		var dispatchedColor:Dynamic = null;
		var dispatchedSmoothing = false;
		target.addEventListener(RenderEvent.RENDER_CANVAS, function(event:RenderEvent):Void {
			rendererMatches = event.renderer == renderer;
			dispatchedType = event.type;
			dispatchedMatrix = describeMatrix(event.objectMatrix);
			dispatchedColor = describeColor(event.objectColorTransform);
			dispatchedSmoothing = event.allowSmoothing;
		});
		#if harness_capture
		@:privateAccess target.__update(false, false);
		#end
		@:privateAccess renderer.__renderEvent(target);

		return {
			constructed: {
				type: constructed.type,
				bubbles: constructed.bubbles,
				cancelable: constructed.cancelable,
				matrixMatches: constructed.objectMatrix == matrix,
				colorMatches: constructed.objectColorTransform == color,
				allowSmoothing: constructed.allowSmoothing,
				rendererIsNull: constructed.renderer == null,
				cloneMatrix: describeMatrix(clone.objectMatrix),
				cloneColor: describeColor(clone.objectColorTransform),
				cloneRendererIsNull: clone.renderer == null
			},
			binding: {
				rendererMatches: rendererMatches,
				type: dispatchedType,
				matrix: dispatchedMatrix,
				color: dispatchedColor,
				allowSmoothing: dispatchedSmoothing
			}
		};
	}

	private static function describeMatrix(value:Matrix):Dynamic {
		return {a: value.a, b: value.b, c: value.c, d: value.d, tx: value.tx, ty: value.ty};
	}

	private static function describeColor(value:ColorTransform):Dynamic {
		return {
			redMultiplier: value.redMultiplier,
			greenMultiplier: value.greenMultiplier,
			blueMultiplier: value.blueMultiplier,
			alphaMultiplier: value.alphaMultiplier,
			redOffset: value.redOffset,
			greenOffset: value.greenOffset,
			blueOffset: value.blueOffset,
			alphaOffset: value.alphaOffset
		};
	}

	private static function testCloneBehavior():Dynamic {
		var mouse = new MouseEvent(MouseEvent.CLICK, true, false, 15.5, 25.3);
		var mouseClone = mouse.clone();

		var keyboard = new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, false, 66, 66);
		var keyClone = keyboard.clone();

		var progress = new ProgressEvent(ProgressEvent.PROGRESS, false, false, 30, 90);
		var progClone = progress.clone();

		return {
			mouseCloneType: mouseClone.type,
			mouseCloneLocalX: (cast mouseClone : MouseEvent).localX,
			mouseCloneLocalY: (cast mouseClone : MouseEvent).localY,
			mouseCloneClassName: Type.getClassName(Type.getClass(mouseClone)),
			keyCloneCharCode: (cast keyClone : KeyboardEvent).charCode,
			keyCloneKeyCode: (cast keyClone : KeyboardEvent).keyCode,
			keyCloneClassName: Type.getClassName(Type.getClass(keyClone)),
			progCloneBytesLoaded: (cast progClone : ProgressEvent).bytesLoaded,
			progCloneBytesTotal: (cast progClone : ProgressEvent).bytesTotal,
			progCloneClassName: Type.getClassName(Type.getClass(progClone))
		};
	}
}
