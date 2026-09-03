package harness.scenarios;

import openfl.events.AccelerometerEvent;
import openfl.events.ActivityEvent;
import openfl.events.AsyncErrorEvent;
import openfl.events.ContextMenuEvent;
import openfl.events.DNSResolverEvent;
import openfl.events.DataEvent;
import openfl.events.DatagramSocketDataEvent;
import openfl.events.DeviceRotationEvent;
import openfl.events.ErrorEvent;
import openfl.events.Event;
import openfl.events.EventPhase;
import openfl.events.EventType;
import openfl.events.FileListEvent;
import openfl.events.FocusEvent;
import openfl.events.FullScreenEvent;
import openfl.events.GameInputEvent;
import openfl.events.GeolocationEvent;
import openfl.events.HTTPStatusEvent;
import openfl.events.IOErrorEvent;
import openfl.events.InvokeEvent;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.events.NativeProcessExitEvent;
import openfl.events.NativeWindowBoundsEvent;
import openfl.events.NativeWindowDisplayStateEvent;
import openfl.events.NetStatusEvent;
import openfl.events.OutputProgressEvent;
import openfl.events.PermissionEvent;
import openfl.events.ProgressEvent;
import openfl.events.RenderEvent;
import openfl.events.SampleDataEvent;
import openfl.events.ScreenMouseEvent;
import openfl.events.SecurityErrorEvent;
import openfl.events.ServerSocketConnectEvent;
import openfl.events.StageOrientationEvent;
import openfl.events.TextEvent;
import openfl.events.TimerEvent;
import openfl.events.TouchEvent;
import openfl.events.UncaughtErrorEvent;
import openfl.events.UncaughtErrorEvents;
import openfl.events.VideoTextureEvent;
import openfl.geom.Rectangle;
import openfl.utils.ByteArray;

private typedef EventInput =
{
	var name:String;
	var clazz:Class<Dynamic>;
	var args:Array<Dynamic>;
	var fields:Array<String>;
}

@:access(openfl.events.KeyboardEvent)
@:access(openfl.events.MouseEvent)
@:access(openfl.events.TimerEvent)
@:access(openfl.events.TouchEvent)
@:access(openfl.events.UncaughtErrorEvents)
class EventPublicSurfaceScenario
{
	public static function run():Dynamic
	{
		return {
			constants: testConstants(),
			constructors: testConstructors(),
			strings: testStrings(),
			updateAfterEvent: testUpdateAfterEvent(),
			uncaughtErrorEvents: testUncaughtErrorEvents()
		};
	}

	private static function testConstants():Dynamic
	{
		var typed:EventType<Event> = Event.CHANGE;
		var asString:String = typed;
		var fromString:EventType<Event> = asString;
		var unusualType:EventType<DeviceRotationEvent> = GeolocationEvent.UPDATE;

		return {
			base: [
				Event.ACTIVATE, Event.ADDED, Event.ADDED_TO_STAGE, Event.CANCEL, Event.CHANGE, Event.CLEAR,
				Event.CLOSING, Event.CLOSE, Event.COMPLETE, Event.CONNECT, Event.CONTEXT3D_CREATE, Event.COPY,
				Event.CUT, Event.DEACTIVATE, Event.ENTER_FRAME, Event.EXIT_FRAME, Event.EXITING,
				Event.FRAME_CONSTRUCTED, Event.FRAME_LABEL, Event.FULLSCREEN, Event.ID3, Event.INIT,
				Event.MOUSE_LEAVE, Event.OPEN, Event.PASTE, Event.REMOVED, Event.REMOVED_FROM_STAGE,
				Event.RENDER, Event.RESIZE, Event.SCROLL, Event.SELECT, Event.SELECT_ALL, Event.SOUND_COMPLETE,
				Event.TAB_CHILDREN_CHANGE, Event.TAB_ENABLED_CHANGE, Event.TAB_INDEX_CHANGE, Event.TEXTURE_READY,
				Event.UNLOAD
			],
			subclasses: {
				accelerometer: [AccelerometerEvent.UPDATE],
				activity: [ActivityEvent.ACTIVITY],
				asyncError: [AsyncErrorEvent.ASYNC_ERROR],
				contextMenu: [ContextMenuEvent.MENU_ITEM_SELECT, ContextMenuEvent.MENU_SELECT],
				data: [DataEvent.DATA, DataEvent.UPLOAD_COMPLETE_DATA],
				datagram: [DatagramSocketDataEvent.DATA],
				deviceRotation: [DeviceRotationEvent.UPDATE],
				dnsResolver: [DNSResolverEvent.LOOKUP],
				error: [ErrorEvent.ERROR],
				fileList: [FileListEvent.DIRECTORY_LISTING, FileListEvent.SELECT_MULTIPLE],
				focus: [FocusEvent.FOCUS_IN, FocusEvent.FOCUS_OUT, FocusEvent.KEY_FOCUS_CHANGE, FocusEvent.MOUSE_FOCUS_CHANGE],
				fullScreen: [FullScreenEvent.FULL_SCREEN, FullScreenEvent.FULL_SCREEN_INTERACTIVE_ACCEPTED],
				gameInput: [GameInputEvent.DEVICE_ADDED, GameInputEvent.DEVICE_REMOVED, GameInputEvent.DEVICE_UNUSABLE],
				geolocation: [GeolocationEvent.UPDATE],
				httpStatus: [HTTPStatusEvent.HTTP_RESPONSE_STATUS, HTTPStatusEvent.HTTP_STATUS],
				ioError: [IOErrorEvent.IO_ERROR, IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, IOErrorEvent.STANDARD_ERROR_IO_ERROR],
				invoke: [InvokeEvent.INVOKE],
				keyboard: [KeyboardEvent.KEY_DOWN, KeyboardEvent.KEY_UP],
				mouse: [
					MouseEvent.CLICK, MouseEvent.DOUBLE_CLICK, MouseEvent.MIDDLE_CLICK, MouseEvent.MIDDLE_MOUSE_DOWN,
					MouseEvent.MIDDLE_MOUSE_UP, MouseEvent.MOUSE_DOWN, MouseEvent.MOUSE_MOVE, MouseEvent.MOUSE_OUT,
					MouseEvent.MOUSE_OVER, MouseEvent.MOUSE_UP, MouseEvent.MOUSE_WHEEL, MouseEvent.RELEASE_OUTSIDE,
					MouseEvent.RIGHT_CLICK, MouseEvent.RIGHT_MOUSE_DOWN, MouseEvent.RIGHT_MOUSE_UP,
					MouseEvent.ROLL_OUT, MouseEvent.ROLL_OVER
				],
				nativeProcessExit: [NativeProcessExitEvent.EXIT],
				nativeWindowBounds: [
					NativeWindowBoundsEvent.MOVING, NativeWindowBoundsEvent.MOVE,
					NativeWindowBoundsEvent.RESIZING, NativeWindowBoundsEvent.RESIZE
				],
				nativeWindowDisplayState: [
					NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING,
					NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE
				],
				netStatus: [NetStatusEvent.NET_STATUS],
				outputProgress: [OutputProgressEvent.OUTPUT_PROGRESS],
				permission: [PermissionEvent.PERMISSION_STATUS],
				progress: [
					ProgressEvent.PROGRESS, ProgressEvent.SOCKET_DATA,
					ProgressEvent.STANDARD_OUTPUT_DATA, ProgressEvent.STANDARD_ERROR_DATA
				],
				render: [
					RenderEvent.CLEAR_DOM, RenderEvent.RENDER_CAIRO, RenderEvent.RENDER_CANVAS,
					RenderEvent.RENDER_DOM, RenderEvent.RENDER_OPENGL
				],
				sampleData: [SampleDataEvent.SAMPLE_DATA],
				screenMouse: [
					ScreenMouseEvent.CLICK, ScreenMouseEvent.MOUSE_DOWN, ScreenMouseEvent.MOUSE_UP,
					ScreenMouseEvent.RIGHT_CLICK, ScreenMouseEvent.RIGHT_MOUSE_DOWN, ScreenMouseEvent.RIGHT_MOUSE_UP
				],
				securityError: [SecurityErrorEvent.SECURITY_ERROR],
				serverSocket: [ServerSocketConnectEvent.CONNECT],
				stageOrientation: [StageOrientationEvent.ORIENTATION_CHANGE, StageOrientationEvent.ORIENTATION_CHANGING],
				text: [TextEvent.LINK, TextEvent.TEXT_INPUT],
				timer: [TimerEvent.TIMER, TimerEvent.TIMER_COMPLETE],
				touch: [
					TouchEvent.TOUCH_BEGIN, TouchEvent.TOUCH_END, TouchEvent.TOUCH_MOVE, TouchEvent.TOUCH_OUT,
					TouchEvent.TOUCH_OVER, TouchEvent.TOUCH_ROLL_OUT, TouchEvent.TOUCH_ROLL_OVER, TouchEvent.TOUCH_TAP
				],
				uncaughtError: [UncaughtErrorEvent.UNCAUGHT_ERROR],
				videoTexture: [VideoTextureEvent.RENDER_STATE]
			},
			phase: [cast EventPhase.CAPTURING_PHASE, cast EventPhase.AT_TARGET, cast EventPhase.BUBBLING_PHASE],
			eventType: {
				toString: asString,
				fromStringEquals: fromString == Event.CHANGE,
				equality: typed == Event.CHANGE,
				inequality: typed != Event.COMPLETE,
				unusualGeolocationType: unusualType
			}
		};
	}

	private static function defaultInputs():Array<EventInput>
	{
		return [
			entry("event", Event, ["default"], []),
			entry("accelerometer", AccelerometerEvent, ["default"], ["timestamp", "accelerationX", "accelerationY", "accelerationZ"]),
			entry("activity", ActivityEvent, ["default"], ["activating"]),
			entry("asyncError", AsyncErrorEvent, ["default"], ["text", "error", "errorID"]),
			entry("contextMenu", ContextMenuEvent, ["default"], ["mouseTarget", "contextMenuOwner", "isMouseTargetInaccessible"]),
			entry("dnsResolver", DNSResolverEvent, ["default"], ["host", "resourceRecords"]),
			entry("data", DataEvent, ["default"], ["data"]),
			entry("datagram", DatagramSocketDataEvent, ["default"], ["srcAddress", "srcPort", "dstAddress", "dstPort", "data"]),
			entry("deviceRotation", DeviceRotationEvent, ["default"], ["timestamp", "roll", "pitch", "yaw", "quaternion"]),
			entry("error", ErrorEvent, ["default"], ["text", "errorID"]),
			entry("fileList", FileListEvent, ["default", []], ["files"]),
			entry("focus", FocusEvent, ["default"], ["relatedObject", "shiftKey", "keyCode", "isRelatedObjectInaccessible"]),
			entry("fullScreen", FullScreenEvent, ["default"], ["fullScreen", "interactive", "activating"]),
			entry("gameInput", GameInputEvent, ["default"], ["device"]),
			entry("geolocation", GeolocationEvent, ["default"], [
				"latitude", "longitude", "altitude", "horizontalAccuracy", "verticalAccuracy", "speed", "heading", "timestamp"
			]),
			entry("httpStatus", HTTPStatusEvent, ["default"], ["status", "redirected", "responseURL", "responseHeaders"]),
			entry("ioError", IOErrorEvent, ["default"], ["text", "errorID"]),
			entry("invoke", InvokeEvent, ["default", false, false, null, []], ["currentDirectory", "arguments", "reason"]),
			entry("keyboard", KeyboardEvent, ["default"], [
				"charCode", "keyCode", "keyLocation", "ctrlKey", "altKey", "shiftKey", "controlKey", "commandKey"
			]),
			entry("mouse", MouseEvent, ["default"], [
				"localX", "localY", "relatedObject", "ctrlKey", "altKey", "shiftKey", "buttonDown", "delta",
				"commandKey", "controlKey", "clickCount", "isRelatedObjectInaccessible"
			]),
			entry("nativeProcessExit", NativeProcessExitEvent, ["default"], ["exitCode"]),
			entry("nativeWindowBounds", NativeWindowBoundsEvent, ["default"], ["beforeBounds", "afterBounds"]),
			entry("nativeWindowDisplayState", NativeWindowDisplayStateEvent, ["default"], ["beforeDisplayState", "afterDisplayState"]),
			entry("netStatus", NetStatusEvent, ["default"], ["info"]),
			entry("outputProgress", OutputProgressEvent, ["default"], ["bytesPending", "bytesTotal"]),
			entry("permission", PermissionEvent, ["default"], ["status"]),
			entry("progress", ProgressEvent, ["default"], ["bytesLoaded", "bytesTotal"]),
			entry("render", RenderEvent, ["default"], ["objectMatrix", "objectColorTransform", "renderer"]),
			entry("sampleData", SampleDataEvent, ["default"], ["data", "position"]),
			entry("screenMouse", ScreenMouseEvent, ["default"], [
				"screenX", "screenY", "ctrlKey", "altKey", "shiftKey", "buttonDown", "commandKey", "controlKey"
			]),
			entry("securityError", SecurityErrorEvent, ["default"], ["text", "errorID"]),
			entry("serverSocket", ServerSocketConnectEvent, ["default"], ["socket"]),
			entry("stageOrientation", StageOrientationEvent, ["default"], ["beforeOrientation", "afterOrientation"]),
			entry("text", TextEvent, ["default"], ["text"]),
			entry("timer", TimerEvent, ["default"], []),
			entry("touch", TouchEvent, ["default"], [
				"touchPointID", "isPrimaryTouchPoint", "localX", "localY", "sizeX", "sizeY", "pressure",
				"relatedObject", "ctrlKey", "altKey", "shiftKey", "commandKey", "controlKey", "timestamp",
				"touchIntent", "samples", "isTouchPointCanceled"
			]),
			entry("uncaughtError", UncaughtErrorEvent, ["default"], ["error"]),
			entry("videoTexture", VideoTextureEvent, ["default"], ["status", "colorSpace"])
		];
	}

	private static function testConstructors():Dynamic
	{
		var result:Dynamic = {};
		for (input in defaultInputs())
		{
			var event:Event = cast Type.createInstance(input.clazz, input.args);
			var fields:Dynamic = {};
			for (field in input.fields) Reflect.setField(fields, field, value(Reflect.field(event, field)));
			Reflect.setField(result, input.name, {
				bubbles: event.bubbles,
				cancelable: event.cancelable,
				fields: fields
			});
		}

		var fileList:Array<Dynamic> = [];
		var fileListEvent = new FileListEvent("files", cast fileList);
		var data = new ByteArray();
		data.writeByte(7);
		var datagram = new DatagramSocketDataEvent("data", false, false, "source", 1, "destination", 2, data);
		var info:Dynamic = {code: "test"};
		var net = new NetStatusEvent("net", false, false, info);
		var sampleA = new SampleDataEvent("sample");
		var sampleB = new SampleDataEvent("sample");
		var httpA = new HTTPStatusEvent("http");
		var httpB = new HTTPStatusEvent("http");
		var mutable = new DataEvent("data");
		mutable.data = "changed";

		Reflect.setField(result, "ownership", {
			fileListRetained: fileListEvent.files == fileList,
			datagramDataRetained: datagram.data == data,
			netInfoRetained: net.info == info,
			sampleDataDistinct: sampleA.data != sampleB.data,
			sampleDataEndian: Std.string(sampleA.data.endian),
			httpHeadersDistinct: httpA.responseHeaders != httpB.responseHeaders,
			httpHeadersInitiallyEmpty: httpA.responseHeaders != null && httpA.responseHeaders.length == 0,
			mutableData: mutable.data
		});
		return result;
	}

	private static function testStrings():Dynamic
	{
		var result:Dynamic = {};
		for (input in defaultInputs())
		{
			var event:Event = cast Type.createInstance(input.clazz, input.args);
			Reflect.setField(result, input.name, event.toString());
		}
		var formatted = new DataEvent("quoted", true, true, "some text");
		Reflect.setField(result, "formatToString", formatted.formatToString("CustomEvent", "type", "bubbles", "cancelable", "data"));
		return result;
	}

	private static function testUpdateAfterEvent():Dynamic
	{
		var keyboard = new KeyboardEvent("keyboard", false, true);
		var mouse = new MouseEvent("mouse", true, true);
		var timer = new TimerEvent("timer", false, true);
		var touch = new TouchEvent("touch", true, true);
		keyboard.preventDefault();
		mouse.preventDefault();
		timer.preventDefault();
		touch.preventDefault();
		var before = updateFlags(keyboard, mouse, timer, touch);
		keyboard.updateAfterEvent();
		mouse.updateAfterEvent();
		timer.updateAfterEvent();
		touch.updateAfterEvent();
		var after = updateFlags(keyboard, mouse, timer, touch);
		var keyboardClone:KeyboardEvent = cast keyboard.clone();
		var mouseClone:MouseEvent = cast mouse.clone();
		var timerClone:TimerEvent = cast timer.clone();
		var touchClone:TouchEvent = cast touch.clone();

		return {
			before: before,
			after: after,
			cancellationPreserved: [
				keyboard.isDefaultPrevented(), mouse.isDefaultPrevented(), timer.isDefaultPrevented(), touch.isDefaultPrevented()
			],
			cloneFlagsReset: [
				!keyboardClone.__updateAfterEventFlag, !mouseClone.__updateAfterEventFlag,
				!timerClone.__updateAfterEventFlag, !touchClone.__updateAfterEventFlag
			]
		};
	}

	private static function testUncaughtErrorEvents():Dynamic
	{
		var events = new UncaughtErrorEvents();
		var listener = function(_:UncaughtErrorEvent):Void {};
		var otherListener = function(_:Event):Void {};
		var initial = events.__enabled;
		events.addEventListener(Event.CHANGE, otherListener);
		var afterOtherAdd = events.__enabled;
		events.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, listener);
		var afterUncaughtAdd = events.__enabled;
		events.removeEventListener(Event.CHANGE, otherListener);
		var afterOtherRemove = events.__enabled;
		var lastRemoveThrows = false;
		try
		{
			events.removeEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, listener);
		}
		catch (_:Dynamic)
		{
			lastRemoveThrows = true;
		}
		var afterUncaughtRemove = events.__enabled;

		return {
			initial: initial,
			afterOtherAdd: afterOtherAdd,
			afterUncaughtAdd: afterUncaughtAdd,
			afterOtherRemove: afterOtherRemove,
			afterUncaughtRemove: afterUncaughtRemove,
			lastRemoveThrows: lastRemoveThrows
		};
	}

	private static function updateFlags(keyboard:KeyboardEvent, mouse:MouseEvent, timer:TimerEvent, touch:TouchEvent):Array<Bool>
	{
		return [
			keyboard.__updateAfterEventFlag, mouse.__updateAfterEventFlag,
			timer.__updateAfterEventFlag, touch.__updateAfterEventFlag
		];
	}

	private static function entry(name:String, clazz:Class<Dynamic>, args:Array<Dynamic>, fields:Array<String>):EventInput
	{
		return {name: name, clazz: clazz, args: args, fields: fields};
	}

	private static function value(input:Dynamic):Dynamic
	{
		if (input == null || (input is String) || (input is Bool) || (input is Int)) return input;
		if ((input is Float)) return Math.isNaN(input) ? "NaN" : input;
		if (Reflect.hasField(input, "endian") && Reflect.hasField(input, "position") && Reflect.hasField(input, "length"))
		{
			var bytes:ByteArray = cast input;
			return {kind: "ByteArray", length: bytes.length, position: bytes.position, endian: Std.string(bytes.endian)};
		}
		if ((input is Array)) return {kind: "Array", length: (cast input : Array<Dynamic>).length};
		if ((input is Rectangle))
		{
			var rectangle:Rectangle = cast input;
			return {kind: "Rectangle", x: rectangle.x, y: rectangle.y, width: rectangle.width, height: rectangle.height};
		}
		return {kind: Type.getClassName(Type.getClass(input))};
	}
}
