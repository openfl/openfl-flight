package harness.scenarios;

import openfl.geom.Rectangle;
import openfl.text.AutoCapitalize;
import openfl.text.ReturnKeyLabel;
import openfl.text.SoftKeyboardType;
import openfl.text.StageText;
import openfl.text.StageTextClearButtonMode;
import openfl.text.StageTextInitOptions;
import openfl.text.TextFormatAlign;
import openfl.text.engine.FontPosture;
import openfl.text.engine.FontWeight;

class StageTextScenario
{
	public static function run():Dynamic
	{
		var defaults = new StageText();
		var defaultsViewPort = defaults.viewPort;
		var defaultValues = {
			autoCapitalize: defaults.autoCapitalize,
			autoCorrect: defaults.autoCorrect,
			clearButtonMode: Std.string(defaults.clearButtonMode),
			color: defaults.color,
			displayAsPassword: defaults.displayAsPassword,
			editable: defaults.editable,
			fontFamily: defaults.fontFamily,
			fontPosture: defaults.fontPosture,
			fontSize: defaults.fontSize,
			fontWeight: defaults.fontWeight,
			locale: defaults.locale,
			maxChars: defaults.maxChars,
			multiline: defaults.multiline,
			restrict: defaults.restrict,
			returnKeyLabel: defaults.returnKeyLabel,
			selectionActiveIndex: defaults.selectionActiveIndex,
			selectionAnchorIndex: defaults.selectionAnchorIndex,
			softKeyboardType: defaults.softKeyboardType,
			stageIsNull: defaults.stage == null,
			text: defaults.text,
			textAlign: defaults.textAlign,
			viewPort: captureRectangle(defaultsViewPort),
			visible: defaults.visible
		};

		defaults.autoCapitalize = AutoCapitalize.WORD;
		defaults.autoCorrect = true;
		defaults.clearButtonMode = StageTextClearButtonMode.ALWAYS;
		defaults.color = 0x336699;
		defaults.displayAsPassword = true;
		defaults.editable = false;
		defaults.fontFamily = "Harness Sans";
		defaults.fontPosture = FontPosture.ITALIC;
		defaults.fontSize = 18;
		defaults.fontWeight = FontWeight.BOLD;
		defaults.locale = "fr-CA";
		defaults.maxChars = 12;
		defaults.restrict = "A-Z0-9";
		defaults.returnKeyLabel = ReturnKeyLabel.SEARCH;
		defaults.softKeyboardType = SoftKeyboardType.EMAIL;
		defaults.text = "ABC123";
		defaults.selectRange(1, 4);
		defaults.textAlign = TextFormatAlign.CENTER;
		var assignedViewPort = new Rectangle(2, 3, 120, 24);
		defaults.viewPort = assignedViewPort;
		defaults.visible = false;

		var nullViewPortThrows = false;
		try
		{
			defaults.viewPort = null;
		}
		catch (_:Dynamic)
		{
			nullViewPortThrows = true;
		}

		var negativeViewPortThrows = false;
		try
		{
			defaults.viewPort = new Rectangle(0, 0, -1, 1);
		}
		catch (_:Dynamic)
		{
			negativeViewPortThrows = true;
		}

		var mutatedValues = {
			autoCapitalize: defaults.autoCapitalize,
			autoCorrect: defaults.autoCorrect,
			clearButtonMode: Std.string(defaults.clearButtonMode),
			color: defaults.color,
			displayAsPassword: defaults.displayAsPassword,
			editable: defaults.editable,
			fontFamily: defaults.fontFamily,
			fontPosture: defaults.fontPosture,
			fontSize: defaults.fontSize,
			fontWeight: defaults.fontWeight,
			locale: defaults.locale,
			maxChars: defaults.maxChars,
			restrict: defaults.restrict,
			returnKeyLabel: defaults.returnKeyLabel,
			selectionActiveIndex: defaults.selectionActiveIndex,
			selectionAnchorIndex: defaults.selectionAnchorIndex,
			softKeyboardType: defaults.softKeyboardType,
			text: defaults.text,
			textAlign: defaults.textAlign,
			viewPort: captureRectangle(defaults.viewPort),
			viewPortRetainsReference: defaults.viewPort == assignedViewPort,
			visible: defaults.visible,
			nullViewPortThrows: nullViewPortThrows,
			negativeViewPortThrows: negativeViewPortThrows
		};

		var defaultOptions = new StageTextInitOptions();
		var multilineOptions = new StageTextInitOptions(true);
		var multiline = new StageText(multilineOptions);
		var multilineBeforeMutation = multiline.multiline;
		multilineOptions.multiline = false;

		return {
			defaults: defaultValues,
			mutated: mutatedValues,
			initOptions: {
				defaultMultiline: defaultOptions.multiline,
				explicitMultiline: multilineBeforeMutation,
				retainsOptionsReference: multiline.multiline == multilineOptions.multiline
			}
		};
	}

	private static function captureRectangle(value:Rectangle):Dynamic
	{
		return {
			x: value.x,
			y: value.y,
			width: value.width,
			height: value.height
		};
	}
}
