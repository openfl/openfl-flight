import flight.Text as FlightText;
import openfl.text.StaticText;

@:access(openfl.display.DisplayObject)
@:access(openfl.text.StaticText)
class StaticTextFlightOnly
{
	public static function main():Void
	{
		var staticText:StaticText = Type.createInstance(StaticText, []);
		if (staticText.text != null) throw "StaticText must preserve its null authored default";
		if (staticText.__flightNode != staticText.__flightText) throw "StaticText must expose its Flight TextLabel to the display bridge";

		staticText.__setText("Flight label");
		if (staticText.text != "Flight label") throw "StaticText did not retain authored text";
		if (FlightText.getTextLabelString(staticText.__flightText) != "Flight label") throw "Flight TextLabel did not receive authored text";

		Sys.println("PASS StaticText Flight TextLabel bridge");
	}
}
