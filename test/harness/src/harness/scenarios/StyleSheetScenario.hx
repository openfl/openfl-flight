package harness.scenarios;

import openfl.text.StyleSheet;
import openfl.text.TextFormat;
import openfl.utils.Object;

class StyleSheetScenario
{
	public static function run():Dynamic
	{
		var sheet = new StyleSheet();
		var initialNames = sorted(sheet.styleNames);
		var source:Object = cast {
			color: "#336699",
			fontFamily: "sans-serif, Arial",
			fontSize: "18px",
			fontStyle: "italic",
			fontWeight: "bold",
			leading: "-3px",
			letterSpacing: "2.5px",
			marginLeft: "4px",
			marginRight: "5px",
			textAlign: "right",
			textDecoration: "underline",
			textIndent: "6px"
		};
		sheet.setStyle(".Manual", source);
		source.fontSize = "99px";
		var manual = sheet.getStyle(".MANUAL");
		var namesAfterCachedSet = sorted(sheet.styleNames);

		sheet.parseCSS("/* ignored */ .Body { color: #112233; font-family: \"serif\", Arial; font-size: 14px; margin-left: 7px; margin-right: 8px; } .body { font-weight: bold; text-decoration: underline; } .A, .B { leading: -2px; } .All { color: #0A1B2C; font-family: \"sans-serif\", Arial; font-size: 16px; font-weight: bold; font-style: italic; text-decoration: underline; text-align: justify; margin-left: 7px; margin-right: 8px; text-indent: 9px; leading: -3px; display: block; kerning: true; letter-spacing: 1.5px; }");
		var body = sheet.getStyle(".BODY");
		var combined = sheet.getStyle(".a, .b");
		var splitA = sheet.getStyle(".a");
		var all = sheet.getStyle(".ALL");
		var namesAfterCSS = sorted(sheet.styleNames);

		sheet.parseCSS(".body { color: #AABBCC; text-align: center; }");
		var mergedBody = sheet.getStyle(".body");
		var transformedManual = sheet.transform(manual);
		var transformedBody = sheet.transform(mergedBody);
		var transformedCombined = sheet.transform(combined);
		var transformedAll = sheet.transform(all);

		sheet.setStyle(".manual", null);
		var namesAfterCachedRemoval = sorted(sheet.styleNames);
		var removedIsNull = sheet.getStyle(".manual") == null;
		sheet.parseCSS(null);
		var namesAfterNullCSS = sorted(sheet.styleNames);
		var namesBeforeInvalidCSS = sorted(sheet.styleNames);
		var invalidCSSError = call(function():Void sheet.parseCSS("not css; .broken { color: ; font-size; : value; "));
		var namesAfterInvalidCSS = sorted(sheet.styleNames);
		sheet.clear();

		return {
			initialNames: initialNames,
			missingIsNull: new StyleSheet().getStyle("missing") == null,
			setStyle: {
				namesAfterCachedSet: namesAfterCachedSet,
				storedFontSize: manual.fontSize,
				format: captureFormat(transformedManual)
			},
			css: {
				names: namesAfterCSS,
				bodyColorBeforeMerge: body.color,
				bodyColorAfterMerge: mergedBody.color,
				bodyFontFamily: mergedBody.fontFamily,
				bodyFontSize: mergedBody.fontSize,
				bodyMarginLeft: mergedBody.marginLeft,
				bodyMarginRight: Reflect.field(mergedBody, "marginRight"),
				bodyDashedMarginRight: Reflect.field(mergedBody, "margin-right"),
				combinedExists: combined != null,
				splitSelectorExists: splitA != null,
				bodyFormat: captureFormat(transformedBody),
				combinedFormat: captureFormat(transformedCombined),
				allProperties: {
					color: Reflect.field(all, "color"),
					fontFamily: Reflect.field(all, "fontFamily"),
					fontSize: Reflect.field(all, "fontSize"),
					fontWeight: Reflect.field(all, "fontWeight"),
					fontStyle: Reflect.field(all, "fontStyle"),
					textDecoration: Reflect.field(all, "textDecoration"),
					textAlign: Reflect.field(all, "textAlign"),
					marginLeft: Reflect.field(all, "marginLeft"),
					marginRight: Reflect.field(all, "marginRight"),
					dashedMarginRight: Reflect.field(all, "margin-right"),
					textIndent: Reflect.field(all, "textIndent"),
					leading: Reflect.field(all, "leading"),
					display: Reflect.field(all, "display"),
					kerning: Reflect.field(all, "kerning"),
					letterSpacing: Reflect.field(all, "letterSpacing"),
					format: captureFormat(transformedAll)
				}
			},
			removal: {
				removedIsNull: removedIsNull,
				namesAfterCachedRemoval: namesAfterCachedRemoval,
				namesAfterNullCSS: namesAfterNullCSS
			},
			invalidCSS: {
				error: invalidCSSError,
				namesBefore: namesBeforeInvalidCSS,
				namesAfter: namesAfterInvalidCSS
			},
			clearNames: sorted(sheet.styleNames),
			nullTransform: captureFormat(sheet.transform(null))
		};
	}

	private static function call(operation:Void->Void):Null<String>
	{
		try
		{
			operation();
		}
		catch (error:Dynamic)
		{
			return Std.string(error);
		}
		return null;
	}

	private static function sorted(values:Array<String>):Array<String>
	{
		var result = values.copy();
		result.sort(Reflect.compare);
		return result;
	}

	private static function captureFormat(format:TextFormat):Dynamic
	{
		return {
			font: format.font,
			size: format.size,
			color: format.color,
			bold: format.bold,
			italic: format.italic,
			underline: format.underline,
			align: format.align,
			blockIndent: format.blockIndent,
			leftMargin: format.leftMargin,
			rightMargin: format.rightMargin,
			leading: format.leading,
			letterSpacing: format.letterSpacing,
			kerning: format.kerning
		};
	}
}
