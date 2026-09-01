package harness.scenarios;

import openfl.net.Socket;
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
			writeByte: errorClass(function():Void socket.writeByte(7))
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
			constructorGuards: {
				portZeroConnected: new Socket("example.invalid", 0).connected,
				port65535Connected: new Socket("example.invalid", 65535).connected
			},
			defaults: defaults,
			disconnectedErrors: disconnectedErrors,
			invalidPorts: invalidPorts,
			mutation: mutation
		};
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
