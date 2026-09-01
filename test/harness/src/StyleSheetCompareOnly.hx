import harness.FixtureStore;
import harness.JsonAssert;
import harness.scenarios.StyleSheetScenario;

class StyleSheetCompareOnly
{
	public static function main():Void
	{
		JsonAssert.equals(FixtureStore.read("text/style-sheet"), StyleSheetScenario.run());
		Sys.println("PASS text/style-sheet");
	}
}
