package openfl.ui;

#if !flash
import flight.Input as FlightInput;
import flight.Signals as FlightSignals;
import flight.types.HasSystemPlatform as FlightPlatformHost;
import flight.types.InputIngressSource as FlightInputSource;
import flight.types.InputManager as FlightInputManager;
import flight.types.InputPointerData as FlightPointerData;
import openfl.Vector;
#if (js && html5)
import flight.HostWeb as FlightHostWeb;
import js.Browser;
#elseif clay
import clay.Clay;
import flight.hostClay.HostClay as FlightHostClay;
#elseif lime
import flight.hostLime.HostLime as FlightHostLime;
import lime.app.Application as LimeApplication;
#end

/**
	The Multitouch class manages and provides information about the current
	environment's support for handling contact from user input devices,
	including contact that has two or more touch points (such as a user's
	fingers on a touch screen). When a user interacts with a device such as a
	mobile phone or tablet with a touch screen, the user typically touches the
	screen with his or her fingers or a pointing device. While there is a broad
	range of pointing devices, such as a mouse or a stylus, many of these
	devices only have a single point of contact with an application. For
	pointing devices with a single point of contact, user interaction events
	can be handled as a mouse event, or using a basic set of touch events
	(called "touch point" events). However, for pointing devices that have
	several points of contact and perform complex movement, such as the human
	hand, Flash runtimes support an additional set of event handling API called
	gesture events. The API for handling user interaction with these gesture
	events includes the following classes:



	* openfl.events.TouchEvent
	* openfl.events.GestureEvent
	* openfl.events.GesturePhase
	* openfl.events.TransformGestureEvent
	* openfl.events.PressAndTapGestureEvent



	Use the listed classes to write code that handles touch events. Use the
	Multitouch class to determine the current environment's support for touch
	interaction, and to manage the support of touch interaction if the current
	environment supports touch input.

	You cannot create a Multitouch object directly from Haxe code.
	If you call `new Multitouch()`, an exception is thrown.

	**Note:** The Multitouch feature is not supported for SWF files
	embedded in HTML running on Mac OS.
**/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:final class Multitouch
{
	/**
		Identifies the multi-touch mode for touch and gesture event handling. Use
		this property to manage whether or not events are dispatched as touch
		events with multiple points of contact and specific events for different
		gestures (such as rotation and pan), or only a single point of contact
		(such as tap), or none at all (contact is handled as a mouse event). To
		set this property, use values from the openfl.ui.MultitouchInputMode class.

		@default gesture
	**/
	public static var inputMode:MultitouchInputMode;

	// @:noCompletion @:dox(hide) public static var mapTouchToMouse:Bool;

	/**
		The maximum number of concurrent touch points supported by the current
		environment.
	**/
	public static var maxTouchPoints(default, null):Int;

	/**
		A Vector array (a typed array of string values) of multi-touch contact
		types supported in the current environment. The array of strings can be
		used as event types to register event listeners. Possible values are
		constants from the GestureEvent, PressAndTapGestureEvent, and
		TransformGestureEvent classes (such as `GESTURE_PAN`).

		If the Flash runtime is in an environment that does not support any
		multi-touch gestures, the value is `null`.

		**Note:** For Mac OS 10.5.3 and later,
		`Multitouch.supportedGestures` returns non-null values
		(possibly indicating incorrectly that gesture events are supported) even
		if the current hardware does not support gesture input.

		Use this property to test for multi-touch gesture support. Then, use
		event handlers for the available multi-touch gestures. For those gestures
		that are not supported in the current evironment, you'll need to create
		alternative event handling.
	**/
	public static var supportedGestures(default, null):Vector<String>;

	/**
		Indicates whether the current environment supports gesture input, such as
		rotating two fingers around a touch screen. Gesture events are listed in
		the TransformGestureEvent, PressAndTapGestureEvent, and GestureEvent
		classes.

		**Note:** For Mac OS 10.5.3 and later, this value is always
		`true`. `Multitouch.supportsGestureEvent` returns
		`true` even if the hardware does not support gesture
		events.
	**/
	public static var supportsGestureEvents(default, null):Bool;

	/**
		Indicates whether the current environment supports basic touch input, such
		as a single finger tap. Touch events are listed in the TouchEvent class.
	**/
	public static var supportsTouchEvents(get, never):Bool;

	@:noCompletion private static var __activeTouchPoints:Map<Int, Bool>;
	@:noCompletion private static var __flightInputManager:FlightInputManager;
	@:noCompletion private static var __flightInputSource:FlightInputSource;
	@:noCompletion private static var __flightInputSourceResolved:Bool;
	@:noCompletion private static var __platformHost:FlightPlatformHost;
	@:noCompletion private static var __platformHostResolved:Bool;

	private static function __init__():Void
	{
		maxTouchPoints = 2;
		supportedGestures = null;
		supportsGestureEvents = false;
		inputMode = MultitouchInputMode.TOUCH_POINT;
		__activeTouchPoints = new Map();
		__flightInputManager = FlightInput.createInputManager();
		FlightSignals.connectSignal(__flightInputManager.onPointerDown, __onFlightPointerDown);
		FlightSignals.connectSignal(__flightInputManager.onPointerMove, __onFlightPointerMove);
		FlightSignals.connectSignal(__flightInputManager.onPointerUp, __onFlightPointerUp);
		FlightSignals.connectSignal(__flightInputManager.onPointerCancel, __onFlightPointerUp);

		var inputSource = __getFlightInputSource();
		if (inputSource != null) FlightInput.attachPointerInput(__flightInputManager, inputSource, {preventDefault: false});

		#if openfljs
		untyped Object.defineProperties(Multitouch, {
			"supportsTouchEvents": {
				get: function()
				{
					return Multitouch.get_supportsTouchEvents();
				}
			}
		});
		#end
	}

	@:noCompletion private static function __getFlightPlatformHost():FlightPlatformHost
	{
		if (__platformHost != null || __platformHostResolved) return __platformHost;

		#if (js && html5)
		__platformHost = cast FlightHostWeb.webHost;
		__platformHostResolved = true;
		#elseif clay
		__platformHost = cast FlightHostClay.createClayHost();
		__platformHostResolved = true;
		#elseif lime
		if (LimeApplication.current != null)
		{
			__platformHost = cast FlightHostLime.createLimeHost(LimeApplication.current);
			__platformHostResolved = true;
		}
		#else
		__platformHostResolved = true;
		#end

		return __platformHost;
	}

	@:noCompletion private static function __getFlightInputSource():FlightInputSource
	{
		if (__flightInputSource != null || __flightInputSourceResolved) return __flightInputSource;

		#if (js && html5)
		if (Browser.supported && Browser.document.documentElement != null)
		{
			__flightInputSource = cast Browser.document.documentElement;
		}
		__flightInputSourceResolved = true;
		#elseif clay
		__getFlightPlatformHost();
		__flightInputSource = cast Clay.app;
		__flightInputSourceResolved = true;
		#elseif lime
		if (LimeApplication.current != null && LimeApplication.current.window != null)
		{
			__getFlightPlatformHost();
			__flightInputSource = cast LimeApplication.current.window;
			__flightInputSourceResolved = true;
		}
		#else
		__flightInputSourceResolved = true;
		#end

		return __flightInputSource;
	}

	// Getters & Setters
	@:noCompletion private static function get_supportsTouchEvents():Bool
	{
		#if (js && html5)
		return Browser.supported && Browser.document != null && Browser.document.documentElement != null
			&& (Reflect.hasField(Browser.document.documentElement, "ontouchstart")
				|| (Reflect.hasField(Browser.window, "DocumentTouch") && Std.isOfType(Browser.document, Reflect.field(Browser.window, "DocumentTouch"))));
		#elseif !mac
		return true;
		#else
		return false;
		#end
	}

	@:noCompletion private static function __onFlightPointerDown(data:FlightPointerData):Void
	{
		if (data.pointerType != "touch") return;

		__activeTouchPoints.set(Std.int(data.pointerId), true);
	}

	@:noCompletion private static function __onFlightPointerMove(data:FlightPointerData):Void
	{
		// OpenFL reports a platform capability rather than learning it from input.
	}

	@:noCompletion private static function __onFlightPointerUp(data:FlightPointerData):Void
	{
		if (data.pointerType != "touch") return;

		__activeTouchPoints.remove(Std.int(data.pointerId));
	}
}
#else
typedef Multitouch = flash.ui.Multitouch;
#end
