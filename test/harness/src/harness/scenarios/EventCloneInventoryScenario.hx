package harness.scenarios;

import openfl.display.NativeWindowDisplayState;
import openfl.display.Sprite;
import openfl.display.StageOrientation;
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
import openfl.events.FileListEvent;
import openfl.events.FocusEvent;
import openfl.events.GameInputEvent;
import openfl.events.GeolocationEvent;
import openfl.events.HTTPStatusEvent;
import openfl.events.IOErrorEvent;
import openfl.events.InvokeEvent;
import openfl.events.NativeProcessExitEvent;
import openfl.events.NativeWindowBoundsEvent;
import openfl.events.NativeWindowDisplayStateEvent;
import openfl.events.NetStatusEvent;
import openfl.events.OutputProgressEvent;
import openfl.events.PermissionEvent;
import openfl.events.SampleDataEvent;
import openfl.events.ScreenMouseEvent;
import openfl.events.SecurityErrorEvent;
import openfl.events.ServerSocketConnectEvent;
import openfl.events.StageOrientationEvent;
import openfl.events.TextEvent;
import openfl.events.TimerEvent;
import openfl.events.TouchEvent;
import openfl.events.UncaughtErrorEvent;
import openfl.events.VideoTextureEvent;
import openfl.geom.Rectangle;
import openfl.permissions.PermissionStatus;
import openfl.utils.ByteArray;

private typedef CloneInput =
{
	var name:String;
	var clazz:Class<Dynamic>;
	var args:Array<Dynamic>;
	var fields:Array<String>;
}

class EventCloneInventoryScenario
{
	public static function run():Dynamic
	{
		var related = new Sprite();
		var bytes = new ByteArray();
		bytes.writeByte(7);
		var quaternion:Array<Float> = [1, 2, 3, 4];
		var records:Array<Dynamic> = [{name: "record"}];
		var info:Dynamic = {code: "ok"};
		var before = new Rectangle(1, 2, 3, 4);
		var after = new Rectangle(5, 6, 7, 8);
		var dynamicError:Dynamic = {message: "boom"};
		var cases:Array<CloneInput> = [
			{name: "accelerometer", clazz: AccelerometerEvent, args: ["sample", true, true, 1.5, 2.5, 3.5, 4.5], fields: ["timestamp", "accelerationX", "accelerationY", "accelerationZ"]},
			{name: "activity", clazz: ActivityEvent, args: ["activity", true, true, true], fields: ["activating"]},
			{name: "asyncError", clazz: AsyncErrorEvent, args: ["async", true, true, "text", dynamicError], fields: ["text", "error"]},
			{name: "contextMenu", clazz: ContextMenuEvent, args: ["menu", true, true, related, related], fields: ["mouseTarget", "contextMenuOwner"]},
			{name: "dnsResolver", clazz: DNSResolverEvent, args: ["dns", true, true, "host", records], fields: ["host", "resourceRecords"]},
			{name: "data", clazz: DataEvent, args: ["data", true, true, "payload"], fields: ["data"]},
			{name: "datagram", clazz: DatagramSocketDataEvent, args: ["datagram", true, true, "src", 10, "dst", 20, bytes], fields: ["srcAddress", "srcPort", "dstAddress", "dstPort", "data"]},
			{name: "deviceRotation", clazz: DeviceRotationEvent, args: ["rotation", true, true, 1.5, 2.5, 3.5, 4.5, quaternion], fields: ["timestamp", "roll", "pitch", "yaw", "quaternion"]},
			{name: "error", clazz: ErrorEvent, args: ["error", true, true, "text", 12], fields: ["text", "errorID"]},
			{name: "fileList", clazz: FileListEvent, args: ["files", [], true, true], fields: ["files"]},
			{name: "focus", clazz: FocusEvent, args: ["focus", true, true, related, true, 9], fields: ["relatedObject", "shiftKey", "keyCode"]},
			{name: "gameInput", clazz: GameInputEvent, args: ["game", true, true, null], fields: ["device"]},
			{name: "geolocation", clazz: GeolocationEvent, args: ["geo", true, true, 1, 2, 3, 4, 5, 6, 7, 8], fields: ["latitude", "longitude", "altitude", "horizontalAccuracy", "verticalAccuracy", "speed", "heading", "timestamp"]},
			{name: "httpStatus", clazz: HTTPStatusEvent, args: ["http", true, true, 302, true], fields: ["status", "redirected", "responseURL", "responseHeaders"]},
			{name: "ioError", clazz: IOErrorEvent, args: ["io", true, true, "text", 13], fields: ["text", "errorID"]},
			{name: "invoke", clazz: InvokeEvent, args: ["invoke", true, true, null, ["a", "b"]], fields: ["currentDirectory", "arguments", "reason"]},
			{name: "nativeProcessExit", clazz: NativeProcessExitEvent, args: ["exit", true, true, 14], fields: ["exitCode"]},
			{name: "nativeWindowBounds", clazz: NativeWindowBoundsEvent, args: ["bounds", true, true, before, after], fields: ["beforeBounds", "afterBounds"]},
			{name: "nativeWindowDisplayState", clazz: NativeWindowDisplayStateEvent, args: ["state", true, true, NativeWindowDisplayState.NORMAL, NativeWindowDisplayState.MAXIMIZED], fields: ["beforeDisplayState", "afterDisplayState"]},
			{name: "netStatus", clazz: NetStatusEvent, args: ["net", true, true, info], fields: ["info"]},
			{name: "outputProgress", clazz: OutputProgressEvent, args: ["output", true, true, 15, 16], fields: ["bytesPending", "bytesTotal"]},
			{name: "permission", clazz: PermissionEvent, args: ["permission", true, true, PermissionStatus.GRANTED], fields: ["status"]},
			{name: "sampleData", clazz: SampleDataEvent, args: ["sample", true, true], fields: ["data", "position"]},
			{name: "screenMouse", clazz: ScreenMouseEvent, args: ["screen", true, true, 17, 18, true, true, true, true, true, true], fields: ["screenX", "screenY", "ctrlKey", "altKey", "shiftKey", "buttonDown", "commandKey", "controlKey"]},
			{name: "securityError", clazz: SecurityErrorEvent, args: ["security", true, true, "text", 19], fields: ["text", "errorID"]},
			{name: "serverSocket", clazz: ServerSocketConnectEvent, args: ["server", true, true, null], fields: ["socket"]},
			{name: "stageOrientation", clazz: StageOrientationEvent, args: ["orientation", true, true, StageOrientation.DEFAULT, StageOrientation.ROTATED_LEFT], fields: ["beforeOrientation", "afterOrientation"]},
			{name: "text", clazz: TextEvent, args: ["text", true, true, "payload"], fields: ["text"]},
			{name: "timer", clazz: TimerEvent, args: ["timer", true, true], fields: []},
			{name: "touch", clazz: TouchEvent, args: ["touch", true, true, 20, true, 21, 22, 23, 24, 0.5, related, true, true, true, true, true, 25, "intent", bytes, true], fields: ["touchPointID", "isPrimaryTouchPoint", "localX", "localY", "sizeX", "sizeY", "pressure", "relatedObject", "ctrlKey", "altKey", "shiftKey", "commandKey", "controlKey", "timestamp", "touchIntent", "samples", "isTouchPointCanceled"]},
			{name: "uncaughtError", clazz: UncaughtErrorEvent, args: ["uncaught", true, true, dynamicError], fields: ["error"]},
			{name: "videoTexture", clazz: VideoTextureEvent, args: ["video", true, true, "ready", "bt709"], fields: ["status", "colorSpace"]}
		];

		var result:Dynamic = {};
		for (entry in cases)
		{
			var event:Event = cast Type.createInstance(entry.clazz, entry.args);
			if (entry.name == "sampleData")
			{
				Reflect.setField(event, "data", bytes);
				Reflect.setField(event, "position", 26);
			}
			if (entry.name == "httpStatus")
			{
				Reflect.setField(event, "responseURL", "https://example.test/");
				Reflect.setField(event, "responseHeaders", [{name: "x", value: "y"}]);
			}
			var target = new Sprite();
			var current = new Sprite();
			Reflect.setField(event, "target", target);
			Reflect.setField(event, "currentTarget", current);
			Reflect.setField(event, "eventPhase", 3);
			var clone:Event = event.clone();
			var fields:Dynamic = {};
			for (field in entry.fields)
			{
				Reflect.setField(fields, field, fieldState(Reflect.field(event, field), Reflect.field(clone, field)));
			}
			Reflect.setField(result, entry.name, {
				cloneClass: Type.getClassName(Type.getClass(clone)),
				metadata: {
					targetCopied: clone.target == target,
					currentTargetCopied: clone.currentTarget == current,
					phase: cast clone.eventPhase
				},
				fields: fields
			});
		}
		return result;
	}

	private static function fieldState(original:Dynamic, clone:Dynamic):Dynamic
	{
		if (original == null || (original is String) || (original is Bool) || (original is Int) || (original is Float))
		{
			return {original: original, clone: clone};
		}
		return {
			sameReference: original == clone,
			originalClass: Type.getClassName(Type.getClass(original)),
			cloneClass: Type.getClassName(Type.getClass(clone))
		};
	}
}
