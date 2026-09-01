package harness.scenarios;

import openfl.events.Event;
import openfl.net.DatagramSocket;
import openfl.utils.ByteArray;

class DatagramSocketScenario
{
	public static function run():Dynamic
	{
		var socket:DatagramSocket = null;
		var constructionError:Null<String> = null;
		try
		{
			socket = new DatagramSocket();
		}
		catch (error:Dynamic)
		{
			constructionError = errorName(error);
		}

		if (socket == null)
		{
			return {
				constructionError: constructionError,
				isSupported: DatagramSocket.isSupported
			};
		}

		var defaults = {
			bound: socket.bound,
			connected: socket.connected,
			localAddress: socket.localAddress,
			localPort: socket.localPort,
			remoteAddress: socket.remoteAddress,
			remotePort: socket.remotePort
		};

		var closeEvents:Array<String> = [];
		socket.addEventListener(Event.CLOSE, function(event:Event):Void closeEvents.push(event.type));
		socket.bind(0, "127.0.0.1");
		var bound = {
			bound: socket.bound,
			connected: socket.connected,
			localAddress: socket.localAddress,
			localPortIsEphemeral: socket.localPort > 0
		};
		socket.close();
		var closed = {
			bound: socket.bound,
			events: closeEvents
		};

		var bytes = new ByteArray();
		bytes.writeUTFBytes("abc");
		var errors = {
			bindNegative: socketError(function(value):Void value.bind(-1, "127.0.0.1")),
			bindTooHigh: socketError(function(value):Void value.bind(65536, "127.0.0.1")),
			sendNegativePort: socketError(function(value):Void value.send(bytes, 0, 0, "127.0.0.1", -1)),
			sendOffsetOverflow: socketError(function(value):Void value.send(bytes, 2, 2, "127.0.0.1", 9000)),
			sendTooHighPort: socketError(function(value):Void value.send(bytes, 0, 0, "127.0.0.1", 65536)),
			sendWithoutDestination: socketError(function(value):Void value.send(bytes))
		};

		return {
			defaults: defaults,
			bound: bound,
			closed: closed,
			constructionError: constructionError,
			errors: errors,
			isSupported: DatagramSocket.isSupported
		};
	}

	private static function socketError(operation:DatagramSocket->Void):Null<String>
	{
		var socket = new DatagramSocket();
		try
		{
			operation(socket);
			socket.close();
			return null;
		}
		catch (error:Dynamic)
		{
			socket.close();
			return errorName(error);
		}
	}

	private static function errorName(error:Dynamic):String
	{
		var errorClass = Type.getClass(error);
		return errorClass == null ? Std.string(error) : Type.getClassName(errorClass);
	}
}
