package harness.scenarios;

#if harness_compare
import flight.Signals as FlightSignals;
#end
import openfl.ui.Multitouch;
import openfl.ui.MultitouchInputMode;

class MultitouchScenario
{
	public static function run():Dynamic
	{
		var initialMode = Std.string(Multitouch.inputMode);
		var initialSupportsTouchEvents = Multitouch.supportsTouchEvents;

		Multitouch.inputMode = MultitouchInputMode.GESTURE;
		var gestureMode = Std.string(Multitouch.inputMode);
		Multitouch.inputMode = MultitouchInputMode.NONE;
		var noneMode = Std.string(Multitouch.inputMode);
		Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
		var touchPointMode = Std.string(Multitouch.inputMode);

		#if harness_compare
		@:privateAccess Multitouch.__supportsTouchEvents = false;
		var manager = @:privateAccess Multitouch.__flightInputManager;
		FlightSignals.emitSignal(manager.onPointerDown, pointerData(7, "touch"));
		var supportsAfterFlightTouch = Multitouch.supportsTouchEvents;
		FlightSignals.emitSignal(manager.onPointerUp, pointerData(7, "touch"));
		#else
		var supportsAfterFlightTouch = Multitouch.supportsTouchEvents;
		#end

		return {
			initial: {
				inputMode: initialMode,
				maxTouchPoints: Multitouch.maxTouchPoints,
				supportedGesturesIsNull: Multitouch.supportedGestures == null,
				supportsGestureEvents: Multitouch.supportsGestureEvents,
				supportsTouchEvents: initialSupportsTouchEvents
			},
			modes: {
				gesture: gestureMode,
				none: noneMode,
				touchPoint: touchPointMode
			},
			supportsAfterFlightTouch: supportsAfterFlightTouch
		};
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
