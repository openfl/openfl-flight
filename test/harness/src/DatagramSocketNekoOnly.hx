import openfl.Lib;
import openfl.events.DatagramSocketDataEvent;
import openfl.events.Event;
import openfl.net.DatagramSocket;
import openfl.utils.ByteArray;

class DatagramSocketNekoOnly
{
	public static function main():Void
	{
		var receiver = new DatagramSocket();
		var sender = new DatagramSocket();
		var received:Array<String> = [];

		receiver.bind(0, "127.0.0.1");
		receiver.addEventListener(DatagramSocketDataEvent.DATA, function(event:DatagramSocketDataEvent):Void
		{
			received.push(event.data.readUTFBytes(event.data.bytesAvailable));
		});
		receiver.receive();

		var packet = new ByteArray();
		packet.writeUTFBytes("ping");
		sender.send(packet, 0, 0, "127.0.0.1", receiver.localPort);

		for (_ in 0...20)
		{
			Lib.current.dispatchEvent(new Event(Event.ENTER_FRAME));
			if (received.length > 0) break;
			Sys.sleep(0.005);
		}

		if (!receiver.bound || receiver.localAddress != "127.0.0.1" || receiver.localPort <= 0) throw "DatagramSocket bind state mismatch";
		if (received.length != 1 || received[0] != "ping") throw 'DatagramSocket received ${received}';

		receiver.close();
		sender.close();
		Sys.println("PASS DatagramSocket Neko loopback");
	}
}
