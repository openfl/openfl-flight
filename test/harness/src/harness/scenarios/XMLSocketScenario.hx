package harness.scenarios;

import openfl.net.XMLSocket;

class XMLSocketScenario
{
	public static function run():Dynamic
	{
		var socket = new XMLSocket();
		var defaults = {
			connected: socket.connected,
			timeout: socket.timeout
		};

		var mutation = {
			timeout: socket.timeout = 1250
		};

		var disconnectedErrors = {
			close: errorClass(function():Void new XMLSocket().close()),
			send: errorClass(function():Void new XMLSocket().send("<message/>"))
		};

		var invalidPorts = {
			negative: errorClass(function():Void new XMLSocket().connect("example.invalid", -1)),
			tooHigh: errorClass(function():Void new XMLSocket().connect("example.invalid", 65536))
		};

		return {
			defaults: defaults,
			mutation: mutation,
			disconnectedErrors: disconnectedErrors,
			invalidPorts: invalidPorts
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
			var errorClass = Type.getClass(error);
			return errorClass == null ? Std.string(error) : Type.getClassName(errorClass);
		}
	}
}
