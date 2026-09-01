import harness.FixtureStore;
import harness.JsonAssert;
import harness.scenarios.DatagramSocketScenario;

class DatagramSocketCompareOnly
{
	public static function main():Void
	{
		JsonAssert.equals(FixtureStore.read("net/datagram-socket"), DatagramSocketScenario.run());
		Sys.println("PASS net/datagram-socket");
	}
}
