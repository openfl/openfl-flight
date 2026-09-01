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
		return new TextFormat("Verdana", 18, 0x336699, true, true, true, null, null, TextFormatAlign.CENTER, 12, 14, 3, 5);
	}

	private static function testDefaultTextFormat():Dynamic {
		var field = new TextField();
		field.defaultTextFormat = createFormat();
		return capture(field.defaultTextFormat);
	}

	private static function capture(format:TextFormat):Dynamic {
		return {
			font: format.font,
			size: format.size,
			color: format.color,
			bold: format.bold,
			italic: format.italic,
			underline: format.underline,
			align: format.align,
			leftMargin: format.leftMargin,
			rightMargin: format.rightMargin,
			indent: format.indent,
			leading: format.leading
		};
	}
}
