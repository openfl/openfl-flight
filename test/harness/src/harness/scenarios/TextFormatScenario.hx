package harness.scenarios;

import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;

class TextFormatScenario {
	public static function run():Dynamic {
		return {
			defaults: capture(new TextFormat()),
			values: capture(createFormat()),
			defaultTextFormat: testDefaultTextFormat()
		};
	}

	private static function createFormat():TextFormat {
		var format = new TextFormat("Verdana", 18, 0x336699, true, true, true, "https://example.test", "_blank", TextFormatAlign.CENTER, 12, 14, 3,
			5);
		format.blockIndent = 7;
		format.bullet = true;
		format.kerning = true;
		format.letterSpacing = 1.75;
		format.tabStops = [20, 40, 80];
		format.strikethrough = true;
		return format;
	}

	private static function testDefaultTextFormat():Dynamic {
		var field = new TextField();
		field.defaultTextFormat = createFormat();
		return capture(field.defaultTextFormat);
	}

	private static function capture(format:TextFormat):Dynamic {
		return {
			align: format.align,
			blockIndent: format.blockIndent,
			bold: format.bold,
			bullet: format.bullet,
			color: format.color,
			font: format.font,
			indent: format.indent,
			italic: format.italic,
			kerning: format.kerning,
			leading: format.leading,
			leftMargin: format.leftMargin,
			letterSpacing: format.letterSpacing,
			rightMargin: format.rightMargin,
			size: format.size,
			strikethrough: format.strikethrough,
			tabStops: format.tabStops,
			target: format.target,
			underline: format.underline,
			url: format.url
		};
	}
}
