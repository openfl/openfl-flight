package harness.scenarios;

#if harness_compare
import flight.Signals as FlightSignals;
#end
import openfl.display.Sprite;
import openfl.events.TouchEvent;
import openfl.ui.Multitouch;
import openfl.ui.MultitouchInputMode;
import openfl.utils.ByteArray;

class MultitouchScenario
{
	public static function run():Dynamic
	{
		var initialMode = Std.string(Multitouch.inputMode);
		var initialSupportsTouchEvents = Multitouch.supportsTouchEvents;
		var capabilitiesReadable = doesNotThrow(function() return Multitouch.maxTouchPoints)
			&& doesNotThrow(function() return Multitouch.supportedGestures)
			&& doesNotThrow(function() return Multitouch.supportsGestureEvents)
			&& doesNotThrow(function() return Multitouch.supportsTouchEvents);

		Multitouch.inputMode = MultitouchInputMode.GESTURE;
		var gestureMode = Std.string(Multitouch.inputMode);
		Multitouch.inputMode = MultitouchInputMode.NONE;
		var noneMode = Std.string(Multitouch.inputMode);
		Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
		var touchPointMode = Std.string(Multitouch.inputMode);

		var related = new Sprite();
		var target = new Sprite();
		target.x = 10;
		target.y = 20;
		target.scaleX = 2;
		target.scaleY = 3;
		var samples = new ByteArray();
		samples.writeByte(42);
		var touchEvent = new TouchEvent(TouchEvent.TOUCH_MOVE, true, true, 17, true, 3.5, -2.25, 8, 9, 0.75, related, true, true, true, true,
			true, 123.5, "pan", samples, true);
		var stageInitiallyNaN = Math.isNaN(touchEvent.stageX) && Math.isNaN(touchEvent.stageY);
		target.dispatchEvent(touchEvent);

		#if harness_compare
		var manager = @:privateAccess Multitouch.__flightInputManager;
		FlightSignals.emitSignal(manager.onPointerDown, pointerData(7, "touch"));
		FlightSignals.emitSignal(manager.onPointerDown, pointerData(8, "touch"));
		FlightSignals.emitSignal(manager.onPointerDown, pointerData(9, "touch"));
		var maxAfterThreeTouches = Multitouch.maxTouchPoints;
		var supportsAfterFlightTouch = Multitouch.supportsTouchEvents;
		FlightSignals.emitSignal(manager.onPointerUp, pointerData(7, "touch"));
		FlightSignals.emitSignal(manager.onPointerUp, pointerData(8, "touch"));
		FlightSignals.emitSignal(manager.onPointerUp, pointerData(9, "touch"));
		#else
		var maxAfterThreeTouches = Multitouch.maxTouchPoints;
		var supportsAfterFlightTouch = Multitouch.supportsTouchEvents;
		#end

		return {
			initial: {
				inputMode: initialMode,
				maxTouchPoints: Multitouch.maxTouchPoints,
				supportedGestures: Multitouch.supportedGestures,
				supportedGesturesIsNull: Multitouch.supportedGestures == null,
				supportsGestureEvents: Multitouch.supportsGestureEvents,
				supportsTouchEvents: initialSupportsTouchEvents,
				capabilitiesReadable: capabilitiesReadable
			},
			modes: {
				gesture: gestureMode,
				none: noneMode,
				touchPoint: touchPointMode
			},
			touchEvent: {
				type: touchEvent.type,
				bubbles: touchEvent.bubbles,
				cancelable: touchEvent.cancelable,
				touchPointID: touchEvent.touchPointID,
				isPrimaryTouchPoint: touchEvent.isPrimaryTouchPoint,
				localX: touchEvent.localX,
				localY: touchEvent.localY,
				stageInitiallyNaN: stageInitiallyNaN,
				stageX: touchEvent.stageX,
				stageY: touchEvent.stageY,
				sizeX: touchEvent.sizeX,
				sizeY: touchEvent.sizeY,
				pressure: touchEvent.pressure,
				relatedObjectMatches: touchEvent.relatedObject == related,
				ctrlKey: touchEvent.ctrlKey,
				altKey: touchEvent.altKey,
				shiftKey: touchEvent.shiftKey,
				commandKey: touchEvent.commandKey,
				controlKey: touchEvent.controlKey
			},
			supportsAfterFlightTouch: supportsAfterFlightTouch,
			maxAfterThreeTouches: maxAfterThreeTouches
		};
	}

	private static function doesNotThrow(operation:Void->Dynamic):Bool
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

	#if harness_compare
	private static function pointerData(pointerId:Int, pointerType:String):Dynamic
	{
		return {
			altKey: false,
			button: 0,
			buttons: 1,
			ctrlKey: false,
			deltaX: 0,
			deltaY: 0,
			height: 1,
			isPrimary: true,
			metaKey: false,
			pointerId: pointerId,
			pointerType: pointerType,
			pressure: 1,
			shiftKey: false,
			tiltX: 0,
			tiltY: 0,
			timeStamp: 1,
			twist: 0,
			wheelMode: "unknown",
			width: 1,
			x: 4,
			y: 5
		};
	}
	#end
}
