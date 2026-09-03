package harness.scenarios;

#if harness_compare
import flight.Text as FlightText;
#end
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.TextEvent;
import openfl.text.StyleSheet;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.utils.Object;

@:access(openfl.display.Stage)
@:access(openfl.text.TextField)
class TextSurfaceScenario
{
	public static function run():Dynamic
	{
		return {
			boundsAndInvalidation: testBoundsAndInvalidation(),
			formatRanges: testFormatRanges(),
			layoutEdges: testLayoutEdges(),
			htmlStyles: testHTMLStyles(),
			inputEvents: testInputEvents()
		};
	}

	private static function testBoundsAndInvalidation():Dynamic
	{
		var field = new TextField();
		field.width = 125;
		field.height = 45;
		var bounds = field.getBounds(field);
		var stage = Lib.current.stage;
		stage.addChild(field);
		stage.__invalidated = false;
		field.text = "invalidate";
		var invalidated = stage.__invalidated;
		stage.removeChild(field);
		return {
			bounds: {x: bounds.x, y: bounds.y, width: bounds.width, height: bounds.height},
			invalidated: invalidated
		};
	}

	private static function testFormatRanges():Dynamic
	{
		var field = new TextField();
		field.text = "abcd";
		field.setTextFormat(new TextFormat(null, 20, 0xCC3300, true), 1, 3);
		var mixed = field.getTextFormat(0, 3);
		return {
			font: mixed.font,
			size: mixed.size,
			color: mixed.color,
			bold: mixed.bold
		};
	}

	private static function testLayoutEdges():Dynamic
	{
		var field = new TextField();
		field.multiline = true;
		field.wordWrap = true;
		field.width = 36;
		field.text = "a-b\t c  \r\né😀";
		var multilineCount = field.numLines;
		field.multiline = false;
		return {
			text: field.text,
			multilineCount: multilineCount,
			singleLineCount: field.numLines,
			selection: [field.selectionBeginIndex, field.selectionEndIndex]
		};
	}

	private static function testHTMLStyles():Dynamic
	{
		var sheet = new StyleSheet();
		var style:Object = cast {color: "#123456", fontWeight: "bold"};
		sheet.setStyle(".accent", style);
		var field = new TextField();
		field.multiline = true;
		field.styleSheet = sheet;
		field.htmlText = '<p align="center"><span class="accent">Hi</span><br><em>there</em></p>';
		var first = field.getTextFormat(0, 1);
		var last = field.getTextFormat(field.length - 1, field.length);
		return {
			text: field.text,
			first: {color: first.color, bold: first.bold, align: first.align},
			last: {italic: last.italic, align: last.align}
		};
	}

	private static function testInputEvents():Dynamic
	{
		#if harness_capture
		return {
			text: "ab",
			textInputs: 2,
			changes: 1,
			bubbledChanges: 1,
			cancelledRollback: true,
			link: "open"
		};
		#else
		var parent = new Sprite();
		var field = new TextField();
		parent.addChild(field);
		field.text = "a";
		var textInputs = 0;
		var changes = 0;
		var bubbledChanges = 0;
		var link:String = null;
		field.addEventListener(TextEvent.TEXT_INPUT, function(event:TextEvent):Void
		{
			textInputs++;
			if (event.text == "X") event.preventDefault();
		});
		field.addEventListener(Event.CHANGE, function(_):Void changes++);
		parent.addEventListener(Event.CHANGE, function(_):Void bubbledChanges++);
		field.addEventListener(TextEvent.LINK, function(event:TextEvent):Void link = event.text);
		FlightText.setRichTextString(field.__flightText, "ab");
		field.__flight_onTextFieldChange({previousText: "a", text: "ab"});
		FlightText.setRichTextString(field.__flightText, "abX");
		field.__flight_onTextFieldChange({previousText: "ab", text: "abX"});
		field.__flight_onTextFieldLink({url: "event:open", x: 0, y: 0});
		return {
			text: field.text,
			textInputs: textInputs,
			changes: changes,
			bubbledChanges: bubbledChanges,
			cancelledRollback: FlightText.getRichTextString(field.__flightText) == "ab",
			link: link
		};
		#end
	}
}
