package harness.scenarios;

import openfl.text.Font;
import openfl.text.FontStyle;
import openfl.text.FontType;
import openfl.text.StyleSheet;
import openfl.text.TextFormat;
import openfl.text.TextLineMetrics;
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
		var before = Font.enumerateFonts().length;
		Font.registerFont(HarnessFont);
		var fonts = Font.enumerateFonts();
		var font = fonts[fonts.length - 1];
		return {
			before: before,
			after: fonts.length,
			name: font.fontName,
			style: font.fontStyle,
			type: font.fontType
		};
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
