package harness.scenarios;

import openfl.text.Font;
import openfl.text.FontStyle;
import openfl.text.FontType;
import openfl.text.StyleSheet;
import openfl.text.TextFormat;
import openfl.text.TextLineMetrics;
import openfl.utils.ByteArray;
import openfl.utils.Object;

class FontAndStyleScenario {
	public static function run():Dynamic {
		return {
			font: testFont(),
			lineMetrics: testLineMetrics(),
			style: testStyle(),
			css: testCSS()
		};
	}

	private static function testFont():Dynamic {
		var direct = new Font("Direct Font");
		direct.fontName = "Renamed Font";
		direct.fontStyle = FontStyle.BOLD_ITALIC;
		direct.fontType = FontType.DEVICE;

		var before = Font.enumerateFonts().length;
		var classRegistrationError = call(function():Void Font.registerFont(HarnessFont));
		var instanceRegistrationError = call(function():Void Font.registerFont(new HarnessFont()));
		var fonts = Font.enumerateFonts();

		var fromBytesResult:Dynamic = null;
		var fromBytesError = call(function():Void fromBytesResult = Font.fromBytes(new ByteArray()));

		return {
			direct: {
				name: direct.fontName,
				style: direct.fontStyle,
				type: direct.fontType
			},
			registration: {
				before: before,
				after: fonts.length,
				classError: classRegistrationError,
				instanceError: instanceRegistrationError,
				isArray: Std.isOfType(fonts, Array),
				allFonts: allFonts(fonts),
				lastName: fonts[fonts.length - 1].fontName
			},
			factories: {
				fromBytesAvailable: Reflect.isFunction(Reflect.field(Font, "fromBytes")),
				fromFileAvailable: Reflect.isFunction(Reflect.field(Font, "fromFile")),
				loadFromBytesAvailable: Reflect.isFunction(Reflect.field(Font, "loadFromBytes")),
				loadFromFileAvailable: Reflect.isFunction(Reflect.field(Font, "loadFromFile")),
				loadFromNameAvailable: Reflect.isFunction(Reflect.field(Font, "loadFromName")),
				fromBytesError: fromBytesError,
				fromBytesIsFont: fromBytesResult != null && Std.isOfType(fromBytesResult, Font),
				fromFileNull: Font.fromFile(null) == null
			}
		};
	}

	private static function allFonts(fonts:Array<Font>):Bool {
		for (font in fonts) {
			if (!Std.isOfType(font, Font)) return false;
		}
		return true;
	}

	private static function call(operation:Void->Void):Null<String> {
		try {
			operation();
		} catch (error:Dynamic) {
			return Std.string(error);
		}
		return null;
	}

	private static function testLineMetrics():Dynamic {
		var metrics = new TextLineMetrics(1.5, 20.25, 12.75, 9.5, 2.25, -1.0);
		return {
			x: metrics.x,
			width: metrics.width,
			height: metrics.height,
			ascent: metrics.ascent,
			descent: metrics.descent,
			leading: metrics.leading
		};
	}

	private static function testStyle():Dynamic {
		var sheet = new StyleSheet();
		var source:Object = cast {
			fontFamily: "sans-serif",
			fontSize: "18px",
			color: "#336699",
			fontStyle: "italic",
			fontWeight: "bold",
			textAlign: "center",
			textDecoration: "underline",
			textIndent: "4px"
		};
		sheet.setStyle(".Headline", source);
		source.fontSize = "99px";
		var stored = sheet.getStyle(".HEADLINE");
		return {
			names: sheet.styleNames,
			storedFontSize: stored.fontSize,
			format: captureFormat(sheet.transform(stored))
		};
	}

	private static function testCSS():Dynamic {
		var sheet = new StyleSheet();
		sheet.parseCSS("/* fixture */ .body { color: #112233; font-family: \"serif\", Arial; font-size: 14px; margin-right: 9px; leading: -2px; }");
		var style = sheet.getStyle(".BODY");
		return {
			names: sheet.styleNames,
			color: style.color,
			fontFamily: style.fontFamily,
			fontSize: style.fontSize,
			marginRight: Reflect.field(style, "marginRight"),
			dashedMarginRight: Reflect.field(style, "margin-right"),
			leading: style.leading,
			format: captureFormat(sheet.transform(style))
		};
	}

	private static function captureFormat(format:TextFormat):Dynamic {
		return {
			font: format.font,
			size: format.size,
			color: format.color,
			bold: format.bold,
			italic: format.italic,
			underline: format.underline,
			align: format.align,
			blockIndent: format.blockIndent,
			rightMargin: format.rightMargin,
			leading: format.leading
		};
	}
}

private class HarnessFont extends Font {
	public function new() {
		super("Harness Font");
		fontStyle = FontStyle.BOLD;
		fontType = FontType.EMBEDDED;
	}
}
