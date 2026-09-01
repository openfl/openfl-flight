package harness.scenarios;

import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFieldType;

class TextFieldScenario {
	public static function run():Dynamic {
		return {
			defaults: testDefaults(),
			text: testText(),
			htmlText: testHtmlText(),
			dimensions: testDimensions(),
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
			selectable: field.selectable
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
