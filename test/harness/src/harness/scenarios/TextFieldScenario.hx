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
			htmlText: testHtmlText(),
			dimensions: testDimensions(),
			autoSize: testAutoSize(),
			layout: testLayout(),
			defaultTextFormat: testDefaultTextFormat(),
			type: testType(),
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
