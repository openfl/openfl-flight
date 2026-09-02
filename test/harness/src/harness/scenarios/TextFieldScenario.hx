package harness.scenarios;

import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFieldType;
import openfl.text.TextFormat;

class TextFieldScenario {
	public static function run():Dynamic {
		return {
			defaults: testDefaults(),
			text: testText(),
			measurementLifecycle: testMeasurementLifecycle(),
			htmlText: testHtmlText(),
			dimensions: testDimensions(),
			autoSize: testAutoSize(),
			autoSizeMutations: testAutoSizeMutations(),
			layout: testLayout(),
			selection: testSelection(),
			defaultTextFormat: testDefaultTextFormat(),
			type: testType(),
			inputProperties: testInputProperties(),
			colors: testColors()
		};
	}

	private static function testDefaults():Dynamic {
		var field = new TextField();
		return {
			text: field.text,
			width: field.width,
			height: field.height,
			type: field.type,
			autoSize: field.autoSize,
			multiline: field.multiline,
			wordWrap: field.wordWrap,
			selectable: field.selectable,
			scrollV: field.scrollV,
			maxScrollV: field.maxScrollV,
			numLines: field.numLines
		};
	}

	private static function testText():Dynamic {
		var field = new TextField();
		field.text = "plain text";
		return {
			text: field.text,
			length: field.length
		};
	}

	private static function testMeasurementLifecycle():Dynamic {
		var field = new TextField();
		var empty = captureMeasurements(field);
		field.text = "Hello";
		var first = captureMeasurements(field);
		field.multiline = true;
		field.text = "Hello\nworld";
		var multiline = captureMeasurements(field);
		field.setTextFormat(new TextFormat(null, 24, null, true), 0, field.length);
		var formatted = captureMeasurements(field);
		return {
			empty: empty,
			first: first,
			multiline: multiline,
			formatted: formatted
		};
	}

	private static function captureMeasurements(field:TextField):Dynamic {
		return {
			textWidth: field.textWidth,
			textHeight: field.textHeight,
			numLines: field.numLines
		};
	}

	private static function testHtmlText():Dynamic {
		var field = new TextField();
		field.htmlText = "<b>Hello</b> <i>world</i>";
		return {
			htmlText: field.htmlText,
			text: field.text
		};
	}

	private static function testDimensions():Dynamic {
		var field = new TextField();
		field.width = 240;
		field.height = 80;
		return {
			width: field.width,
			height: field.height
		};
	}

	private static function testAutoSize():Dynamic {
		return {
			left: captureAutoSize(TextFieldAutoSize.LEFT),
			right: captureAutoSize(TextFieldAutoSize.RIGHT),
			center: captureAutoSize(TextFieldAutoSize.CENTER)
		};
	}

	private static function captureAutoSize(value:TextFieldAutoSize):Dynamic {
		var field = new TextField();
		field.x = 40;
		field.width = 100;
		field.text = "autosize";
		field.autoSize = value;
		var width = field.width;
		var height = field.height;
		return {
			autoSize: field.autoSize,
			x: field.x,
			width: width,
			height: height
		};
	}

	private static function testAutoSizeMutations():Dynamic {
		return {
			left: captureAutoSizeMutations(TextFieldAutoSize.LEFT),
			right: captureAutoSizeMutations(TextFieldAutoSize.RIGHT),
			center: captureAutoSizeMutations(TextFieldAutoSize.CENTER)
		};
	}

	private static function captureAutoSizeMutations(value:TextFieldAutoSize):Dynamic {
		var field = new TextField();
		field.x = 50;
		field.width = 120;
		field.autoSize = value;
		var empty = {x: field.x, width: field.width, height: field.height};
		field.text = "first";
		var first = {x: field.x, width: field.width, height: field.height};
		field.text = "a much longer value";
		var second = {x: field.x, width: field.width, height: field.height};
		return {empty: empty, first: first, second: second};
	}

	private static function testLayout():Dynamic {
		var field = new TextField();
		field.width = 60;
		field.height = 24;
		field.multiline = true;
		field.wordWrap = true;
		field.text = "one two three four\nfive six";
		return {
			multiline: field.multiline,
			wordWrap: field.wordWrap,
			numLines: field.numLines,
			scrollV: field.scrollV,
			maxScrollV: field.maxScrollV
		};
	}

	private static function testDefaultTextFormat():Dynamic {
		var field = new TextField();
		field.defaultTextFormat = new TextFormat("Verdana", 18, 0x336699, true, true);
		field.text = "formatted";
		var defaultFormat = field.defaultTextFormat;
		var appliedFormat = field.getTextFormat(0, field.length);
		return {
			font: defaultFormat.font,
			size: defaultFormat.size,
			color: defaultFormat.color,
			bold: defaultFormat.bold,
			italic: defaultFormat.italic,
			appliedFont: appliedFormat.font,
			appliedSize: appliedFormat.size,
			appliedColor: appliedFormat.color,
			appliedBold: appliedFormat.bold,
			appliedItalic: appliedFormat.italic
		};
	}

	private static function testSelection():Dynamic {
		var field = new TextField();
		field.text = "abcdef";
		var initial = captureSelection(field);
		field.setSelection(1, 4);
		var forward = captureSelection(field);
		field.setSelection(5, 2);
		var backward = captureSelection(field);
		field.setSelection(-2, 99);
		var outside = captureSelection(field);
		return {initial: initial, forward: forward, backward: backward, outside: outside};
	}

	private static function captureSelection(field:TextField):Dynamic {
		return {
			begin: field.selectionBeginIndex,
			end: field.selectionEndIndex,
			caret: field.caretIndex
		};
	}

	private static function testType():Dynamic {
		var field = new TextField();
		field.type = TextFieldType.INPUT;
		var input = field.type;
		field.type = TextFieldType.DYNAMIC;
		return {
			input: input,
			dynamicValue: field.type
		};
	}

	private static function testInputProperties():Dynamic {
		var field = new TextField();
		field.type = TextFieldType.INPUT;
		field.maxChars = 5;
		field.restrict = "A-Z^Q";
		field.displayAsPassword = true;
		field.passwordChar = "#";
		field.embedFonts = true;
		field.multiline = true;
		return {
			type: field.type,
			maxChars: field.maxChars,
			restrict: field.restrict,
			displayAsPassword: field.displayAsPassword,
			passwordChar: field.passwordChar,
			embedFonts: field.embedFonts,
			multiline: field.multiline,
			tabEnabled: field.tabEnabled
		};
	}

	private static function testColors():Dynamic {
		var field = new TextField();
		field.textColor = 0x123456;
		field.background = true;
		field.backgroundColor = 0xABCDEF;
		field.border = true;
		field.borderColor = 0x654321;
		return {
			textColor: field.textColor,
			background: field.background,
			backgroundColor: field.backgroundColor,
			border: field.border,
			borderColor: field.borderColor
		};
	}
}
