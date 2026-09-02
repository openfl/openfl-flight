package harness.scenarios;

import openfl.text.TextField;
import openfl.text.TextFormat;

class TextFieldBehaviorScenario {
	public static function run():Dynamic {
		return {
			metrics: testMetrics(),
			lines: testLines(),
			singleLine: testSingleLine(),
			inputConstraints: testInputConstraints(),
			textFormat: testTextFormat(),
			appendText: testAppendText(),
			replaceText: testReplaceText()
		};
	}

	private static function testMetrics():Dynamic {
		var field = new TextField();
		field.text = "Hello";
		return {
			textWidth: field.textWidth,
			textHeight: field.textHeight
		};
	}

	private static function testLines():Dynamic {
		var field = new TextField();
		field.multiline = true;
		field.text = "Hello\nWorld";
		var metrics = field.getLineMetrics(0);
		return {
			numLines: field.numLines,
			line: {
				x: metrics.x,
				width: metrics.width,
				height: metrics.height,
				ascent: metrics.ascent,
				descent: metrics.descent,
				leading: metrics.leading
			}
		};
	}

	private static function testSingleLine():Dynamic {
		var single = new TextField();
		single.text = "Hello world";

		var multiple = new TextField();
		multiple.multiline = true;
		multiple.text = "First\nSecond\nThird";

		return {
			text: single.getLineText(0),
			offset: single.getLineOffset(0),
			length: single.getLineLength(0),
			numLines: single.numLines,
			multilineNumLines: multiple.numLines,
			caretIndex: single.caretIndex
		};
	}

	private static function testInputConstraints():Dynamic {
		var maxChars = new TextField();
		maxChars.maxChars = 4;
		maxChars.text = "abcdef";

		var restricted = new TextField();
		restricted.restrict = "A-Z";
		restricted.text = "aB3C";

		return {
			maxChars: maxChars.maxChars,
			maxCharsText: maxChars.text,
			maxCharsLength: maxChars.length,
			restrict: restricted.restrict,
			restrictedText: restricted.text
		};
	}

	private static function testTextFormat():Dynamic {
		var field = new TextField();
		field.text = "abcdef";
		var format = new TextFormat("_sans", 18, 0x123456, true, true, true);
		field.setTextFormat(format, 1, 4);
		var readBack = field.getTextFormat(1, 4);
		return {
			font: readBack.font,
			size: readBack.size,
			color: readBack.color,
			bold: readBack.bold,
			italic: readBack.italic,
			underline: readBack.underline
		};
	}

	private static function testAppendText():Dynamic {
		var field = new TextField();
		field.text = "Hello";
		field.appendText(" world");
		return {
			text: field.text,
			length: field.length
		};
	}

	private static function testReplaceText():Dynamic {
		var middle = new TextField();
		middle.text = "abcdef";
		middle.replaceText(2, 4, "XYZ");

		var empty = new TextField();
		empty.text = "abcdef";
		empty.replaceText(1, 5, "");
		return {
			middle: {
				text: middle.text,
				length: middle.length
			},
			empty: {
				text: empty.text,
				length: empty.length
			}
		};
	}
}
