import harness.FixtureStore;
import harness.JsonAssert;
import harness.scenarios.XMLSocketScenario;

class XMLSocketCompareOnly
{
	public static function main():Void
	{
		JsonAssert.equals(FixtureStore.read("net/xml-socket"), XMLSocketScenario.run());
		Sys.println("PASS net/xml-socket");
	}
}
