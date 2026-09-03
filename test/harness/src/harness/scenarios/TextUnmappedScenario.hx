package harness.scenarios;

import openfl.text.AntiAliasType;
import openfl.text.AutoCapitalize;
import openfl.text.FontStyle;
import openfl.text.FontType;
import openfl.text.GridFitType;
import openfl.text.ReturnKeyLabel;
import openfl.text.SoftKeyboardType;
import openfl.text.StageTextClearButtonMode;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFieldType;
import openfl.text.TextFormatAlign;
import openfl.text.engine.FontPosture;
import openfl.text.engine.FontWeight;

class TextUnmappedScenario
{
	public static function run():Dynamic
	{
		return {
			coreValues: testCoreValues(),
			stageValues: testStageValues(),
			passiveProperties: testPassiveProperties(),
			derivedProperties: testDerivedProperties(),
			condenseAndPassword: testCondenseAndPassword(),
			queryBoundaries: testQueryBoundaries()
		};
	}

	private static function testCoreValues():Dynamic
	{
		return {
			antiAlias: antiAliasValues([AntiAliasType.ADVANCED, AntiAliasType.NORMAL]),
			fontStyle: fontStyleValues([FontStyle.BOLD, FontStyle.BOLD_ITALIC, FontStyle.ITALIC, FontStyle.REGULAR]),
			fontType: fontTypeValues([FontType.DEVICE, FontType.EMBEDDED, FontType.EMBEDDED_CFF]),
			gridFit: gridFitValues([GridFitType.NONE, GridFitType.PIXEL, GridFitType.SUBPIXEL]),
			autoSize: autoSizeValues([TextFieldAutoSize.CENTER, TextFieldAutoSize.LEFT, TextFieldAutoSize.NONE, TextFieldAutoSize.RIGHT]),
			fieldType: fieldTypeValues([TextFieldType.DYNAMIC, TextFieldType.INPUT]),
			align: alignValues([
				TextFormatAlign.CENTER,
				TextFormatAlign.END,
				TextFormatAlign.JUSTIFY,
				TextFormatAlign.LEFT,
				TextFormatAlign.RIGHT,
				TextFormatAlign.START
			])
		};
	}

	private static function testStageValues():Dynamic
	{
		return {
			autoCapitalize: autoCapitalizeValues([AutoCapitalize.ALL, AutoCapitalize.NONE, AutoCapitalize.SENTENCE, AutoCapitalize.WORD]),
			returnKey: returnKeyValues([
				ReturnKeyLabel.DEFAULT,
				ReturnKeyLabel.DONE,
				ReturnKeyLabel.GO,
				ReturnKeyLabel.NEXT,
				ReturnKeyLabel.SEARCH
			]),
			softKeyboard: softKeyboardValues([
				SoftKeyboardType.CONTACT,
				SoftKeyboardType.DECIMAL,
				SoftKeyboardType.DEFAULT,
				SoftKeyboardType.EMAIL,
				SoftKeyboardType.NUMBER,
				SoftKeyboardType.PHONE,
				SoftKeyboardType.PUNCTUATION,
				SoftKeyboardType.URL
			]),
			clearButton: clearButtonValues([
				StageTextClearButtonMode.ALWAYS,
				StageTextClearButtonMode.NEVER,
				StageTextClearButtonMode.UNLESS_EDITING,
				StageTextClearButtonMode.WHILE_EDITING
			]),
			fontPosture: fontPostureValues([FontPosture.ITALIC, FontPosture.NORMAL]),
			fontWeight: fontWeightValues([FontWeight.BOLD, FontWeight.NORMAL])
		};
	}

	private static function testPassiveProperties():Dynamic
	{
		var field = new TextField();
		var defaults = capturePassive(field);
		field.antiAliasType = AntiAliasType.ADVANCED;
		field.background = true;
		field.backgroundColor = 0x123456;
		field.border = true;
		field.borderColor = 0x654321;
		field.condenseWhite = true;
		field.embedFonts = true;
		field.gridFitType = GridFitType.SUBPIXEL;
		field.mouseWheelEnabled = false;
		field.selectable = false;
		field.sharpness = 800;
		field.textColor = 0xABCDEF;
		return {defaults: defaults, mutated: capturePassive(field)};
	}

	private static function capturePassive(field:TextField):Dynamic
	{
		return {
			width: field.width,
			height: field.height,
			antiAliasType: antiAliasValue(field.antiAliasType),
			background: field.background,
			backgroundColor: field.backgroundColor,
			border: field.border,
			borderColor: field.borderColor,
			condenseWhite: field.condenseWhite,
			embedFonts: field.embedFonts,
			gridFitType: gridFitValue(field.gridFitType),
			mouseWheelEnabled: field.mouseWheelEnabled,
			selectable: field.selectable,
			sharpness: field.sharpness,
			textColor: field.textColor
		};
	}

	private static function testDerivedProperties():Dynamic
	{
		var field = new TextField();
		var defaults = captureDerived(field);
		field.multiline = true;
		field.wordWrap = true;
		field.width = 55;
		field.height = 24;
		field.text = "alpha beta\ngamma";
		return {defaults: defaults, populated: captureDerived(field)};
	}

	private static function captureDerived(field:TextField):Dynamic
	{
		return {
			length: field.length,
			numLines: field.numLines,
			textWidth: field.textWidth,
			textHeight: field.textHeight,
			bottomScrollV: field.bottomScrollV,
			maxScrollH: field.maxScrollH,
			maxScrollV: field.maxScrollV,
			scrollH: field.scrollH,
			scrollV: field.scrollV
		};
	}

	private static function testCondenseAndPassword():Dynamic
	{
		var field = new TextField();
		var defaultPasswordChar = field.passwordChar;
		field.condenseWhite = true;
		field.htmlText = "<b>alpha   beta</b>\n gamma";
		var condensed = {htmlText: field.htmlText, text: field.text};
		field.condenseWhite = false;
		var afterFlagChange = {htmlText: field.htmlText, text: field.text};
		field.text = "secret";
		field.displayAsPassword = true;
		field.passwordChar = "##";
		return {
			defaultPasswordChar: defaultPasswordChar,
			condensed: condensed,
			afterFlagChange: afterFlagChange,
			password: {passwordChar: field.passwordChar, text: field.text, length: field.length}
		};
	}

	private static function testQueryBoundaries():Dynamic
	{
		var field = new TextField();
		field.multiline = true;
		field.text = "ab\ncd";
		return {
			emptyParagraphAtEnd: new TextField().getParagraphLength(0),
			charBoundariesNegativeIsNull: field.getCharBoundaries(-1) == null,
			charBoundariesAtLengthIsNull: field.getCharBoundaries(field.length) == null,
			charIndexOutside: field.getCharIndexAtPoint(-10, -10),
			lineIndexOutside: field.getLineIndexAtPoint(-10, -10),
			lineOfCharNegative: field.getLineIndexOfChar(-1),
			lineOfCharPastEnd: field.getLineIndexOfChar(field.length + 1),
			firstParagraphNegative: field.getFirstCharInParagraph(-1),
			firstParagraphPastEnd: field.getFirstCharInParagraph(field.length + 1),
			paragraphNegative: field.getParagraphLength(-1),
			paragraphPastEnd: field.getParagraphLength(field.length + 1),
			paragraphAtEnd: field.getParagraphLength(field.length),
			lineLengthNegative: field.getLineLength(-1),
			lineLengthPastEnd: field.getLineLength(field.numLines),
			lineOffsetNegativeThrows: throws(function():Void field.getLineOffset(-1)),
			lineOffsetPastEnd: field.getLineOffset(field.numLines),
			lineTextNegativeThrows: throws(function():Void field.getLineText(-1)),
			lineTextPastEndIsNull: field.getLineText(field.numLines) == null
		};
	}

	private static function antiAliasValues(input:Array<AntiAliasType>):Array<Dynamic> return [for (item in input) antiAliasValue(item)];
	private static function autoCapitalizeValues(input:Array<AutoCapitalize>):Array<Dynamic> return [for (item in input) value(item, item)];
	private static function fontStyleValues(input:Array<FontStyle>):Array<Dynamic> return [for (item in input) value(item, item)];
	private static function fontTypeValues(input:Array<FontType>):Array<Dynamic> return [for (item in input) value(item, item)];
	private static function gridFitValues(input:Array<GridFitType>):Array<Dynamic> return [for (item in input) gridFitValue(item)];
	private static function autoSizeValues(input:Array<TextFieldAutoSize>):Array<Dynamic> return [for (item in input) value(item, item)];
	private static function fieldTypeValues(input:Array<TextFieldType>):Array<Dynamic> return [for (item in input) value(item, item)];
	private static function alignValues(input:Array<TextFormatAlign>):Array<Dynamic> return [for (item in input) value(item, item)];
	private static function returnKeyValues(input:Array<ReturnKeyLabel>):Array<Dynamic> return [for (item in input) value(item, item)];
	private static function softKeyboardValues(input:Array<SoftKeyboardType>):Array<Dynamic> return [for (item in input) value(item, item)];
	private static function clearButtonValues(input:Array<StageTextClearButtonMode>):Array<Dynamic> return [for (item in input) value(item, item)];
	private static function fontPostureValues(input:Array<FontPosture>):Array<Dynamic> return [for (item in input) value(item, item)];
	private static function fontWeightValues(input:Array<FontWeight>):Array<Dynamic> return [for (item in input) value(item, item)];

	private static function antiAliasValue(input:AntiAliasType):Dynamic return input == null ? null : value(input, input);
	private static function gridFitValue(input:GridFitType):Dynamic return input == null ? null : value(input, input);
	private static function value(raw:Dynamic, string:String):Dynamic return {raw: raw, string: string};

	private static function throws(operation:Void->Void):Bool
	{
		try
		{
			operation();
		}
		catch (_:Dynamic)
		{
			return true;
		}
		return false;
	}
}
