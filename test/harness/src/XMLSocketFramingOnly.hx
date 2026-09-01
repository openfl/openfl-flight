import openfl.events.DataEvent;
import openfl.net.Socket;
import openfl.net.XMLSocket;
import openfl.utils.ByteArray;

@:access(openfl.net.Socket)
@:access(openfl.net.XMLSocket)
class XMLSocketFramingOnly
{
	public static function main():Void
	{
		var xmlSocket = new XMLSocket();
		var transport = new Socket();
		transport.__socket = new sys.net.Socket();
		xmlSocket.__socket = transport;

		var messages:Array<String> = [];
		xmlSocket.addEventListener(DataEvent.DATA, function(event:DataEvent):Void messages.push(event.data));

		feed(xmlSocket, transport, "one");
		assertMessages(messages, []);
		feed(xmlSocket, transport, "\x00two\x00thr");
		assertMessages(messages, ["one", "two"]);
		feed(xmlSocket, transport, "ee\x00\x00");
		assertMessages(messages, ["one", "two", "three", ""]);

		Sys.println("PASS XMLSocket null framing");
	}

	private static function feed(xmlSocket:XMLSocket, transport:Socket, value:String):Void
	{
		transport.__input = new ByteArray();
		transport.__input.writeUTFBytes(value);
		transport.__input.position = 0;
		xmlSocket.__onSocketData(null);
	}

	private static function assertMessages(actual:Array<String>, expected:Array<String>):Void
	{
		if (actual.join("|") != expected.join("|"))
		{
			throw 'Expected ${expected}, received ${actual}';
		}
	}
}
