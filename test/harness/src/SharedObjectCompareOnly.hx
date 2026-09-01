import harness.FixtureStore;
import harness.JsonAssert;
import harness.scenarios.SharedObjectScenario;

class SharedObjectCompareOnly
{
	public static function main():Void
	{
		JsonAssert.equals(FixtureStore.read("net/shared-object"), SharedObjectScenario.run());
		Sys.println("PASS net/shared-object");
	}
}
