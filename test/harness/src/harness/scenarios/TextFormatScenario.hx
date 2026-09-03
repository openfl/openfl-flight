package harness.scenarios;

import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;

class TextFormatScenario {
	public static function run():Dynamic {
		return {
			defaults: capture(new TextFormat()),
			values: capture(createFormat()),
			cloneAliasing: testCloneAliasing(),
			defaultTextFormat: testDefaultTextFormat(),
			partialRange: testPartialRange(),
			nullMerge: testNullMerge()
		};
	}

	private static function testCloneAliasing():Dynamic {
		var source = createFormat();
		var clone = source.clone();
		clone.font = "Clone Font";
		clone.tabStops[0] = 99;
		return {
			distinctFormat: clone != source,
			independentFont: source.font,
			sharedTabStops: source.tabStops,
			sameTabStopsReference: clone.tabStops == source.tabStops
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
		var readBack = field.defaultTextFormat;
		var assigned = capture(readBack);
		field.text = "round trip";
		var textRange = capture(field.getTextFormat(0, field.length));
		readBack.font = "mutated";
		readBack.color = 0xFFFFFF;
		return {
			assigned: assigned,
			textRange: textRange,
			afterReadBackMutation: capture(field.defaultTextFormat)
		};
	}

	private static function testPartialRange():Dynamic {
		var field = new TextField();
		field.defaultTextFormat = createFormat();
		field.text = "abcdef";

		var patch = new TextFormat(null, 24, 0xAA5500, false, null, false, null, null, TextFormatAlign.RIGHT);
		patch.bullet = false;
		patch.kerning = false;
		patch.leading = 9;
		patch.letterSpacing = 2.5;
		patch.strikethrough = false;
		patch.tabStops = [15, 45];
		field.setTextFormat(patch, 1, 4);

		return {
			before: capture(field.getTextFormat(0, 1)),
			range: capture(field.getTextFormat(1, 4)),
			after: capture(field.getTextFormat(4, 6)),
			mixed: capture(field.getTextFormat(0, field.length))
		};
	}

	private static function testNullMerge():Dynamic {
		var field = new TextField();
		field.defaultTextFormat = createFormat();
		var partial = new TextFormat();
		partial.bold = false;
		partial.leading = 0;
		partial.url = "";
		field.defaultTextFormat = partial;
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
