package harness.scenarios;

import openfl.events.Event;
import openfl.net.ObjectEncoding;
import openfl.net.Socket;
import openfl.utils.ByteArray;
import openfl.utils.Endian;

class SocketScenario
{
	public static function run():Dynamic
	{
		var socket = new Socket();
		var defaults = {
			bytesAvailableThrows: didThrow(function():Void
			{
				var value = socket.bytesAvailable;
			}),
			bytesPendingThrows: didThrow(function():Void
			{
				var value = socket.bytesPending;
			}),
			connected: socket.connected,
			endian: socket.endian,
			objectEncoding: socket.objectEncoding,
			secure: socket.secure,
			timeout: socket.timeout
		};

		var disconnectedErrors = {
			close: errorClass(function():Void socket.close()),
			flush: errorClass(function():Void socket.flush()),
			readByte: errorClass(function():Void socket.readByte()),
			readUTFBytes: errorClass(function():Void socket.readUTFBytes(1)),
			writeByte: errorClass(function():Void socket.writeByte(7)),
			writeUTFBytes: errorClass(function():Void socket.writeUTFBytes("flight"))
		};

		socket.endian = Endian.LITTLE_ENDIAN;
		var mutation = {
			endian: socket.endian,
			timeout: socket.timeout = 1250
		};

		var invalidPorts = {
			negative: errorClass(function():Void socket.connect("example.invalid", -1)),
			tooHigh: errorClass(function():Void socket.connect("example.invalid", 65536))
		};

		return {
			amfCompatibility: testAMFCompatibility(),
			constructorGuards: {
				portZeroConnected: new Socket("example.invalid", 0).connected,
				port65535Connected: new Socket("example.invalid", 65535).connected
			},
			defaults: defaults,
			disconnectedErrors: disconnectedErrors,
			invalidPorts: invalidPorts,
			lifecycleAndUTF8: testLifecycleAndUTF8(),
			mutation: mutation
		};
	}

	private static function testLifecycleAndUTF8():Dynamic
	{
		var events:Array<String> = [];
		var socket = prepareSocket();
		socket.addEventListener(Event.CONNECT, function(event:Event):Void events.push(event.type));
		socket.addEventListener(Event.CLOSE, function(event:Event):Void events.push(event.type));

		@:privateAccess socket.socket_onOpen(null);
		var connectedAfterOpen = socket.connected;
		socket.writeUTFBytes("flight socket \u2713");
		var pendingAfterWrite = socket.bytesPending;
		setUTF8Input(socket);
		var emptyFlushError = errorClass(function():Void socket.flush());
		var pendingAfterEmptyFlush = socket.bytesPending;
		var availableBeforeRead = socket.bytesAvailable;
		var readBack = socket.readUTFBytes(availableBeforeRead);

		// This callback represents a peer-initiated transport close. Calling
		// close() below must not add another close event.
		@:privateAccess socket.socket_onClose(null);
		var eventsBeforeLocalClose = events.copy();
		closePreparedSocket(socket);

		return {
			availableAfterRead: socket.bytesAvailable,
			availableBeforeRead: availableBeforeRead,
			connectedAfterClose: socket.connected,
			connectedAfterOpen: connectedAfterOpen,
			emptyFlushError: emptyFlushError,
			eventsAfterLocalClose: events,
			eventsBeforeLocalClose: eventsBeforeLocalClose,
			pendingAfterEmptyFlush: pendingAfterEmptyFlush,
			pendingAfterWrite: pendingAfterWrite,
			readBack: readBack
		};
	}

	private static function testAMFCompatibility():Dynamic
	{
		var socket = prepareSocket();
		socket.objectEncoding = ObjectEncoding.AMF3;
		var writeError = errorClass(function():Void socket.writeObject({value: 7}));
		var readResult = socket.readObject();
		var pending = socket.bytesPending;
		closePreparedSocket(socket);

		return {
			pending: pending,
			readResult: readResult,
			writeError: writeError
		};
	}

	private static function prepareSocket():Socket
	{
		var socket = new Socket();
		@:privateAccess socket.__input = new ByteArray();
		@:privateAccess socket.__output = new ByteArray();
		@:privateAccess socket.__input.endian = socket.endian;
		@:privateAccess socket.__output.endian = socket.endian;
		@:privateAccess socket.__socket = new sys.net.Socket();
		return socket;
	}

	private static function setUTF8Input(socket:Socket):Void
	{
		var input = new ByteArray();
		for (value in [102, 108, 105, 103, 104, 116, 32, 115, 111, 99, 107, 101, 116, 32, 226, 156, 147])
		{
			input.writeByte(value);
		}
		input.position = 0;
		input.endian = socket.endian;
		@:privateAccess socket.__input = input;
		@:privateAccess socket.__output = new ByteArray();
		@:privateAccess socket.__output.endian = socket.endian;
	}

	private static function closePreparedSocket(socket:Socket):Void
	{
		#if harness_capture
		// OpenFL's interpreter cleanup reaches Lib.current after it has already
		// closed the injected native handle and reset the connection state.
		try
		{
			socket.close();
		}
		catch (_:Dynamic) {}
		#else
		socket.close();
		#end
	}

	private static function didThrow(operation:Void->Void):Bool
	{
		try
		{
			operation();
			return false;
		}
		catch (_:Dynamic)
		{
			return true;
		}
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
			var errorClass = Type.getClass(error);
			return errorClass == null ? Std.string(error) : Type.getClassName(errorClass);
		}
	}
}
