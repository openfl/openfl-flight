package harness.scenarios;

import openfl.Lib;
import openfl.events.Event;
import openfl.events.NetStatusEvent;
import openfl.media.SoundTransform;
import openfl.net.DatagramSocket;
import openfl.net.IDynamicPropertyOutput;
import openfl.net.IDynamicPropertyWriter;
import openfl.net.IPVersion;
import openfl.net.NetConnection;
import openfl.net.NetStream;
import openfl.net.ObjectEncoding;
import openfl.net.Responder;
import openfl.net.SecureSocket;
import openfl.net.ServerSocket;
import openfl.net.URLRequest;
import openfl.net.URLStream;
import openfl.net.XMLSocket;

@:access(openfl.net.Responder)
class NetSurfaceScenario
{
	public static function run():Dynamic
	{
		return {
			requestSurface: testRequestSurface(),
			urlStreamObject: testURLStreamObject(),
			xmlSocketSurface: testXMLSocketSurface(),
			datagramSurface: testDatagramSurface(),
			serverSocketSurface: testServerSocketSurface(),
			serverSocketListeners: testServerSocketListeners(),
			secureSocketSurface: testSecureSocketSurface(),
			secureSocketBoundaries: testSecureSocketBoundaries(),
			netConnection: testNetConnection(),
			responder: testResponder(),
			netStream: testNetStream(),
			encoding: testEncoding(),
			dynamicProperties: testDynamicProperties(),
			ipVersion: testIPVersion()
		};
	}

	private static function testServerSocketListeners():Dynamic
	{
		var socket = new ServerSocket();
		var first = function(_:Event):Void {};
		var second = function(_:Event):Void {};
		var closeEvents = 0;
		socket.addEventListener(Event.CLOSE, function(_:Event):Void closeEvents++);
		socket.addEventListener(Event.CONNECT, first);
		socket.addEventListener(Event.CONNECT, second);
		socket.removeEventListener(Event.CONNECT, first);
		var socketStillHasListener = socket.hasEventListener(Event.CONNECT);
		Lib.current.dispatchEvent(new Event(Event.ENTER_FRAME));
		socket.removeEventListener(Event.CONNECT, second);
		socket.close();
		return {
			isSupported: ServerSocket.isSupported,
			socketStillHasListener: socketStillHasListener,
			closeEventsAfterPollWasRemoved: closeEvents
		};
	}

	private static function testRequestSurface():Dynamic
	{
		var fields = Type.getInstanceFields(URLRequest);
		return {
			authenticateAbsent: fields.indexOf("authenticate") == -1,
			cacheResponseAbsent: fields.indexOf("cacheResponse") == -1,
			digestAbsent: fields.indexOf("digest") == -1,
			useRedirectedURLAbsent: fields.indexOf("useRedirectedURL") == -1
		};
	}

	private static function testURLStreamObject():Dynamic
	{
		var stream = new URLStream();
		stream.objectEncoding = ObjectEncoding.JSON;
		return {
			connected: stream.connected,
			objectEncoding: stream.objectEncoding,
			readObjectIsNull: stream.readObject() == null
		};
	}

	private static function testXMLSocketSurface():Dynamic
	{
		var socket = new XMLSocket();
		var fields = Type.getInstanceFields(XMLSocket);
		return {
			connected: socket.connected,
			timeout: socket.timeout,
			hasClose: fields.indexOf("close") >= 0,
			hasConnect: fields.indexOf("connect") >= 0,
			hasSend: fields.indexOf("send") >= 0
		};
	}

	private static function testDatagramSurface():Dynamic
	{
		var fields = Type.getInstanceFields(DatagramSocket);
		return {
			isSupported: DatagramSocket.isSupported,
			hasConnect: fields.indexOf("connect") >= 0,
			hasReceive: fields.indexOf("receive") >= 0,
			hasSend: fields.indexOf("send") >= 0,
			hasClose: fields.indexOf("close") >= 0
		};
	}

	private static function testServerSocketSurface():Dynamic
	{
		var socket = new ServerSocket();
		return {
			isSupported: ServerSocket.isSupported,
			bound: socket.bound,
			listening: socket.listening,
			localAddress: socket.localAddress,
			localPort: socket.localPort
		};
	}

	private static function testSecureSocketSurface():Dynamic
	{
		var socket = new SecureSocket();
		return {
			isSupported: SecureSocket.isSupported,
			connected: socket.connected,
			certificateStatus: Std.string(socket.serverCertificateStatus)
		};
	}

	private static function testSecureSocketBoundaries():Dynamic
	{
		var socket = new SecureSocket();
		return {
			isSupported: SecureSocket.isSupported,
			initialStatus: Std.string(socket.serverCertificateStatus),
			negativePortThrows: throws(function():Void socket.connect("localhost", -1)),
			oversizePortThrows: throws(function():Void socket.connect("localhost", 65536)),
			statusAfterRejectedPorts: Std.string(socket.serverCertificateStatus)
		};
	}

	private static function throws(operation:Void->Void):Bool
	{
		try
		{
			operation();
		}
		catch (_:Dynamic)
		{
			return true;
		}
		return false;
	}

	private static function testNetConnection():Dynamic
	{
		var connection = new NetConnection();
		var codes:Array<String> = [];
		connection.addEventListener(NetStatusEvent.NET_STATUS, function(event:NetStatusEvent):Void codes.push(Reflect.field(event.info, "code")));
		connection.connect(null);
		var fields = Type.getInstanceFields(NetConnection);
		return {
			codes: codes,
			hasConnect: fields.indexOf("connect") >= 0,
			closeAbsent: fields.indexOf("close") == -1,
			callAbsent: fields.indexOf("call") == -1
		};
	}

	private static function testResponder():Dynamic
	{
		var result = function(_:Dynamic):Void {};
		var status = function(_:Dynamic):Void {};
		var responder = new Responder(result, status);
		return {
			resultStored: responder.__result == result,
			statusStored: responder.__status == status
		};
	}

	private static function testNetStream():Dynamic
	{
		var connection = new NetConnection();
		var stream = new NetStream(connection, "peer");
		var initialTransform = stream.soundTransform;
		var replacement = new SoundTransform(0.4, -0.2);
		stream.soundTransform = replacement;
		replacement.volume = 0.9;
		stream.speed = 1.5;
		stream.play("video.mp4", 1, 2, 3, 4, 5);
		stream.pause();
		stream.resume();
		stream.togglePause();
		stream.requestVideoStatus();
		stream.close();
		var fields = Type.getInstanceFields(NetStream);
		return {
			defaults: {
				bufferTime: stream.bufferTime,
				checkPolicyFile: stream.checkPolicyFile,
				clientIsSelf: stream.client == stream,
				initialVolume: initialTransform.volume,
				initialPan: initialTransform.pan,
				bytesLoaded: stream.bytesLoaded,
				bytesTotal: stream.bytesTotal,
				objectEncoding: stream.objectEncoding
			},
			transform: {
				volume: stream.soundTransform.volume,
				pan: stream.soundTransform.pan,
				copiedInput: stream.soundTransform != replacement
			},
			speed: stream.speed,
			timeAfterClose: stream.time,
			appendBytesAbsent: fields.indexOf("appendBytes") == -1,
			appendBytesActionAbsent: fields.indexOf("appendBytesAction") == -1,
			publishAbsent: fields.indexOf("publish") == -1
		};
	}

	private static function testEncoding():Dynamic
	{
		return {
			amf0: cast(ObjectEncoding.AMF0, Int),
			amf3: cast(ObjectEncoding.AMF3, Int),
			hxsf: cast(ObjectEncoding.HXSF, Int),
			largeHxsf: cast(ObjectEncoding.LARGE_HXSF, Int),
			json: cast(ObjectEncoding.JSON, Int),
			largeJson: cast(ObjectEncoding.LARGE_JSON, Int),
			defaultValue: cast(ObjectEncoding.DEFAULT, Int)
		};
	}

	private static function testDynamicProperties():Dynamic
	{
		var output = new DynamicPropertyOutputProbe();
		var writer:IDynamicPropertyWriter = new DynamicPropertyWriterProbe();
		writer.writeDynamicProperties({value: 7}, output);
		return {name: output.name, value: output.value};
	}

	private static function testIPVersion():Dynamic
	{
		return {
			ipv4: Std.string(IPVersion.IPV4),
			ipv6: Std.string(IPVersion.IPV6)
		};
	}
}

private class DynamicPropertyOutputProbe implements IDynamicPropertyOutput
{
	public var name:String;
	public var value:Dynamic;

	public function new() {}

	public function writeDynamicProperty(name:String, value:Dynamic):Void
	{
		this.name = name;
		this.value = value;
	}
}

private class DynamicPropertyWriterProbe implements IDynamicPropertyWriter
{
	public function new() {}

	public function writeDynamicProperties(object:Dynamic, output:IDynamicPropertyOutput):Void
	{
		output.writeDynamicProperty("value", Reflect.field(object, "value"));
	}
}
