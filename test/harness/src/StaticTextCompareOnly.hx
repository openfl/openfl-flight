import harness.FixtureStore;
import harness.JsonAssert;
import harness.scenarios.StaticTextScenario;

class StaticTextCompareOnly
{
	public static function main():Void
	{
		JsonAssert.equals(FixtureStore.read("text/static-text"), StaticTextScenario.run());
		Sys.println("PASS text/static-text");
	}
}
