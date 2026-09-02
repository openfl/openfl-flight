package harness.scenarios;

import openfl.text.TextField;
import openfl.text.TextFormat;

class TextFieldBehaviorScenario {
	public static function run():Dynamic {
		return {
			metrics: testMetrics(),
			formatMetrics: testFormatMetrics(),
			lines: testLines(),
			lineQueries: testLineQueries(),
			hitQueries: testHitQueries(),
			singleLine: testSingleLine(),
			inputConstraints: testInputConstraints(),
			textFormat: testTextFormat(),
			appendText: testAppendText(),
			scrolling: testScrolling(),
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

	private static function testFormatMetrics():Dynamic {
		var field = new TextField();
		field.text = "format size";
		var before = {width: field.textWidth, height: field.textHeight};
		var format = new TextFormat(null, 26, null, true, true);
		format.leading = 4;
		format.letterSpacing = 2.5;
		field.setTextFormat(format, 0, field.length);
		var after = {width: field.textWidth, height: field.textHeight};
		return {before: before, after: after};
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

	private static function testLineQueries():Dynamic {
		var field = new TextField();
		field.width = 34;
		field.multiline = true;
		field.wordWrap = true;
		field.text = "alpha beta gamma\ndelta epsilon";
		var lines = [];
		for (i in 0...field.numLines) {
			lines.push({
				index: i,
				offset: field.getLineOffset(i),
				length: field.getLineLength(i),
				text: field.getLineText(i)
			});
		}
		return {
			numLines: field.numLines,
			lines: lines,
			firstCharLine: field.getLineIndexOfChar(0),
			middleCharLine: field.getLineIndexOfChar(8),
			lastCharLine: field.getLineIndexOfChar(field.length - 1),
			pastLine: field.getLineText(field.numLines)
		};
	}

	private static function testHitQueries():Dynamic {
		var field = new TextField();
		field.width = 100;
		field.height = 40;
		field.multiline = true;
		field.text = "ab\ncd";
		return {
			firstBoundary: captureRectangle(field.getCharBoundaries(0)),
			secondLineBoundary: captureRectangle(field.getCharBoundaries(3)),
			invalidBoundary: captureRectangle(field.getCharBoundaries(99)),
			firstLineAtPoint: field.getLineIndexAtPoint(3, 3),
			secondLineAtPoint: field.getLineIndexAtPoint(3, 18),
			outsideLineAtPoint: field.getLineIndexAtPoint(-1, -1),
			firstCharAtPoint: field.getCharIndexAtPoint(3, 3)
		};
	}

	private static function captureRectangle(rect:openfl.geom.Rectangle):Dynamic {
		return rect == null ? null : {x: rect.x, y: rect.y, width: rect.width, height: rect.height};
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
		maxChars.type = openfl.text.TextFieldType.INPUT;
		maxChars.maxChars = 4;
		maxChars.text = "abcdef";
		maxChars.appendText("gh");

		var restricted = new TextField();
		restricted.type = openfl.text.TextFieldType.INPUT;
		restricted.restrict = "A-Z";
		restricted.text = "aB3C";
		restricted.replaceText(1, 2, "z9");

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

	private static function testScrolling():Dynamic {
		var field = new TextField();
		field.multiline = true;
		field.height = 19;
		field.text = "one\ntwo\nthree";
		var initial = {
			scrollV: field.scrollV,
			maxScrollV: field.maxScrollV,
			bottomScrollV: field.bottomScrollV
		};
		field.scrollV = field.maxScrollV;
		var atBottom = {
			scrollV: field.scrollV,
			maxScrollV: field.maxScrollV,
			bottomScrollV: field.bottomScrollV
		};
		field.appendText("\nfour\nfive");
		var appended = {
			scrollV: field.scrollV,
			maxScrollV: field.maxScrollV,
			bottomScrollV: field.bottomScrollV,
			caretIndex: field.caretIndex,
			selectionBeginIndex: field.selectionBeginIndex,
			selectionEndIndex: field.selectionEndIndex
		};
		return {initial: initial, atBottom: atBottom, appended: appended};
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
