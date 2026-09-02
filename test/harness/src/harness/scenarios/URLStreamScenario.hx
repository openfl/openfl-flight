package harness.scenarios;

import haxe.io.Bytes;
import openfl.events.Event;
import openfl.events.HTTPStatusEvent;
import openfl.events.IOErrorEvent;
import openfl.events.ProgressEvent;
import openfl.events.SecurityErrorEvent;
import openfl.net.ObjectEncoding;
import openfl.net.URLRequest;
import openfl.net.URLRequestHeader;
import openfl.net.URLRequestMethod;
import openfl.net.URLStream;
import openfl.utils.ByteArray;
import openfl.utils.Endian;

class URLStreamScenario
{
	public static function run():Dynamic
	{
		return {
			close: testClose(),
			defaults: testDefaults(),
			dataInput: testDataInput(),
			loadStart: testLoadStart(),
			completedBody: testCompletedBody(),
			primitiveReads: testPrimitiveReads(),
			requestMapping: testRequestMapping()
		};
	}

	private static function testDefaults():Dynamic
	{
		var stream = new URLStream();
		return {
			bytesAvailable: stream.bytesAvailable,
			connected: stream.connected,
			endianError: errorClass(function():Void
			{
				var value = stream.endian;
			}),
			objectEncoding: stream.objectEncoding
		};
	}

	private static function testDataInput():Dynamic
	{
		var stream = new URLStream();
		var data = new ByteArray();
		data.writeByte(1);
		data.writeByte(2);
		data.writeByte(255);
		data.position = 0;
		@:privateAccess stream.__data = data;
		stream.endian = Endian.BIG_ENDIAN;
		stream.objectEncoding = ObjectEncoding.HXSF;
		var first = stream.readUnsignedShort();
		var availableAfterFirst = stream.bytesAvailable;
		var second = stream.readByte();

		return {
			availableAfterFirst: availableAfterFirst,
			availableAtEnd: stream.bytesAvailable,
			endian: stream.endian,
			first: first,
			objectEncoding: stream.objectEncoding,
			second: second
		};
	}

	private static function testPrimitiveReads():Dynamic
	{
		var stream = new URLStream();
		var data = new ByteArray();
		data.endian = Endian.BIG_ENDIAN;
		for (value in [102, 108, 105, 103, 104, 116])
		{
			data.writeByte(value);
		}
		data.writeFloat(12.5);
		data.writeInt(-123456789);
		data.position = 0;
		@:privateAccess stream.__data = data;
		stream.endian = Endian.BIG_ENDIAN;
		var utf8 = stream.readUTFBytes(6);
		var float = stream.readFloat();
		var int = stream.readInt();

		return {
			availableAtEnd: stream.bytesAvailable,
			float: float,
			int: int,
			utf8: utf8
		};
	}

	private static function testClose():Dynamic
	{
		var stream = new URLStream();
		var data = new ByteArray();
		data.writeByte(7);
		data.position = 0;
		@:privateAccess stream.__data = data;
		var availableBeforeClose = stream.bytesAvailable;
		stream.close();
		var secondCloseError = errorClass(function():Void stream.close());

		return {
			availableAfterClose: stream.bytesAvailable,
			availableBeforeClose: availableBeforeClose,
			connectedAfterClose: stream.connected,
			readAfterCloseError: errorClass(function():Void stream.readByte()),
			secondCloseError: secondCloseError
		};
	}

	private static function testLoadStart():Dynamic
	{
		var stream = new URLStream();
		var events:Array<String> = [];
		var types:Array<String> = [Event.OPEN, ProgressEvent.PROGRESS, Event.COMPLETE, IOErrorEvent.IO_ERROR, SecurityErrorEvent.SECURITY_ERROR];
		for (type in types)
		{
			stream.addEventListener(type, function(event:Event):Void events.push(event.type));
		}

		stream.load(new URLRequest("data:application/octet-stream;base64,AAEC"));
		var connectedAfterLoad = stream.connected;
		stream.close();

		return {
			bytesAvailableAfterClose: stream.bytesAvailable,
			connectedAfterClose: stream.connected,
			connectedAfterLoad: connectedAfterLoad,
			events: events
		};
	}

	private static function testCompletedBody():Dynamic
	{
		var stream = new URLStream();
		var events:Array<String> = [];
		var responseStatus:Dynamic = null;
		var types:Array<String> = [Event.OPEN, HTTPStatusEvent.HTTP_RESPONSE_STATUS, HTTPStatusEvent.HTTP_STATUS, ProgressEvent.PROGRESS, Event.COMPLETE];
		for (type in types)
		{
			stream.addEventListener(type, function(event:Event):Void
			{
				events.push(event.type);
				if (event.type == HTTPStatusEvent.HTTP_RESPONSE_STATUS)
				{
					var status:HTTPStatusEvent = cast event;
					responseStatus = {
						responseHeaderCount: status.responseHeaders.length,
						responseURL: status.responseURL,
						status: status.status
					};
				}
			});
		}
		var request = new URLRequest("data:application/octet-stream;base64,AQL/");
		stream.load(request);

		#if harness_compare
		var generation = @:privateAccess stream.__loadGeneration;
		@:privateAccess stream.__complete(generation, request, {
			body: Bytes.ofHex("0102ff"),
			headers: {},
			ok: true,
			status: 200,
			statusText: "OK",
			url: request.url
		});
		#else
		var data = new ByteArray();
		data.writeByte(1);
		data.writeByte(2);
		data.writeByte(255);
		data.position = 0;
		var loader = @:privateAccess stream.__loader;
		loader.data = data;
		loader.bytesLoaded = 3;
		loader.bytesTotal = 3;
		@:privateAccess stream.loader_onComplete(new Event(Event.COMPLETE));
		#end

		return {
			bytesAvailable: stream.bytesAvailable,
			connected: stream.connected,
			events: events,
			readBack: [stream.readUnsignedByte(), stream.readUnsignedByte(), stream.readUnsignedByte()],
			responseStatus: responseStatus
		};
	}

	private static function testRequestMapping():Dynamic
	{
		var request = new URLRequest("https://example.invalid/stream");
		request.contentType = "application/octet-stream";
		request.data = "flight=true";
		request.followRedirects = false;
		request.idleTimeout = 1250;
		request.manageCookies = false;
		request.method = URLRequestMethod.POST;
		request.requestHeaders = [new URLRequestHeader("X-Flight", "stream")];
		request.userAgent = "openfl-flight-stream";
		request.withCredentials = true;

		#if harness_compare
		var mapped:Dynamic = @:privateAccess new URLStream().__toFlightRequest(request);
		#else
		var mapped:Dynamic = {
			body: "flight=true",
			credentials: "include",
			headers: {
				"Content-Type": "application/octet-stream",
				"User-Agent": "openfl-flight-stream",
				"X-Flight": "stream"
			},
			method: "POST",
			redirect: "manual",
			responseType: "arraybuffer",
			timeoutMs: 1250,
			url: "https://example.invalid/stream"
		};
		#end

		return {
			body: mapped.body,
			contentType: Reflect.field(mapped.headers, "Content-Type"),
			credentials: mapped.credentials,
			header: Reflect.field(mapped.headers, "X-Flight"),
			method: mapped.method,
			redirect: mapped.redirect,
			responseType: mapped.responseType,
			timeoutMs: mapped.timeoutMs,
			url: mapped.url,
			userAgent: Reflect.field(mapped.headers, "User-Agent")
		};
	}

	private static function errorClass(operation:Void->Void):Null<String>
	{
		try
		{
			operation();
			return null;
		}
		catch (error:Dynamic)
		{
			var type = Type.getClass(error);
			return type == null ? Std.string(Type.typeof(error)) : Type.getClassName(type);
		}
	}
}
