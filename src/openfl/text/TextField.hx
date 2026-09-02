package openfl.text;

#if !flash
import flight.TextLayout as FlightTextLayout;
import flight.Node as FlightNode;
import flight.Signals as FlightSignals;
import flight.Text as FlightText;
import flight.TextInput as FlightTextInput;
import flight.types.TextFormat as FlightTextFormat;
import flight.types.TextLayoutResult as FlightTextLayoutResult;
import flight.types.TextMeasureFunction;
import flight.types.RichText as FlightRichText;
import openfl.display.InteractiveObject;
import openfl.errors.RangeError;
import openfl.errors.TypeError;
import openfl.events.Event;
import openfl.geom.Rectangle;

/**
	The TextField class is used to create display objects for text display and
	input. This compatibility implementation preserves the OpenFL 9.5.2 public
	API while Flight's renderer-facing text bridge is being completed.
**/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:access(openfl.text.TextFormat)
@:access(openfl.display.DisplayObject)
class TextField extends InteractiveObject
{
	public var antiAliasType(get, set):AntiAliasType;
	public var autoSize(get, set):TextFieldAutoSize;
	public var background(get, set):Bool;
	public var backgroundColor(get, set):Int;
	public var border(get, set):Bool;
	public var borderColor(get, set):Int;
	public var bottomScrollV(get, never):Int;
	public var caretIndex(get, never):Int;
	public var condenseWhite:Bool = false;
	public var defaultTextFormat(get, set):TextFormat;
	public var displayAsPassword(get, set):Bool;
	public var embedFonts(get, set):Bool;
	public var gridFitType(get, set):GridFitType;
	public var htmlText(get, set):String;
	public var length(get, never):Int;
	public var maxChars(get, set):Int;
	public var maxScrollH(get, never):Int;
	public var maxScrollV(get, never):Int;
	public var mouseWheelEnabled(get, set):Bool;
	public var multiline(get, set):Bool;
	public var numLines(get, never):Int;
	public var restrict(get, set):String;
	public var scrollH(get, set):Int;
	public var scrollV(get, set):Int;
	public var selectable(get, set):Bool;
	public var selectionBeginIndex(get, never):Int;
	public var selectionEndIndex(get, never):Int;
	public var sharpness(get, set):Float;
	public var styleSheet(get, set):StyleSheet;
	public var text(get, set):String;
	public var textColor(get, set):Int;
	public var textHeight(get, never):Float;
	public var textWidth(get, never):Float;
	public var type(get, set):TextFieldType;
	public var wordWrap(get, set):Bool;
	public var passwordChar(get, set):String;

	@:noCompletion private var __antiAliasType:AntiAliasType;
	@:noCompletion private var __autoSize:TextFieldAutoSize;
	@:noCompletion private var __background:Bool;
	@:noCompletion private var __backgroundColor:Int;
	@:noCompletion private var __border:Bool;
	@:noCompletion private var __borderColor:Int;
	@:noCompletion private var __caretIndex:Int;
	@:noCompletion private var __displayAsPassword:Bool;
	@:noCompletion private var __embedFonts:Bool;
	@:noCompletion private var __explicitTabEnabled:Null<Bool>;
	@:noCompletion private var __fieldHeight:Float;
	@:noCompletion private var __fieldWidth:Float;
	@:noCompletion private var __formatByCharacter:Array<TextFormat>;
	@:noCompletion private var __flightText:FlightRichText;
	@:noCompletion private var __gridFitType:GridFitType;
	@:noCompletion private var __htmlText:String;
	@:noCompletion private var __isHTML:Bool;
	@:noCompletion private var __maxChars:Int;
	@:noCompletion private var __mouseWheelEnabled:Bool;
	@:noCompletion private var __multiline:Bool;
	@:noCompletion private var __passwordChar:String;
	@:noCompletion private var __restrict:String;
	@:noCompletion private var __scrollH:Int;
	@:noCompletion private var __scrollV:Int;
	@:noCompletion private var __selectable:Bool;
	@:noCompletion private var __selectionIndex:Int;
	@:noCompletion private var __sharpness:Float;
	@:noCompletion private var __styleSheet:StyleSheet;
	@:noCompletion private var __text:String;
	@:noCompletion private var __textFormat:TextFormat;
	@:noCompletion private var __type:TextFieldType;
	@:noCompletion private var __wordWrap:Bool;

	public function new()
	{
		super();

		__antiAliasType = AntiAliasType.NORMAL;
		__autoSize = TextFieldAutoSize.NONE;
		__background = false;
		__backgroundColor = 0xFFFFFF;
		__border = false;
		__borderColor = 0x000000;
		__caretIndex = 0;
		__displayAsPassword = false;
		__embedFonts = false;
		__explicitTabEnabled = null;
		__fieldHeight = 100;
		__fieldWidth = 100;
		__formatByCharacter = [];
		__gridFitType = GridFitType.PIXEL;
		__htmlText = "";
		__isHTML = false;
		__maxChars = 0;
		__mouseWheelEnabled = true;
		__multiline = false;
		__passwordChar = "*";
		__restrict = null;
		__scrollH = 0;
		__scrollV = 1;
		__selectable = true;
		__selectionIndex = 0;
		__sharpness = 0;
		__styleSheet = null;
		__text = "";
		__textFormat = new TextFormat("Times New Roman", 12, 0x000000, false, false, false, "", "", TextFormatAlign.LEFT, 0, 0, 0, 0);
		__textFormat.blockIndent = 0;
		__textFormat.bullet = false;
		__textFormat.letterSpacing = 0;
		__textFormat.kerning = false;
		__type = TextFieldType.DYNAMIC;
		__wordWrap = false;

		__flightText = FlightText.createRichText();
		FlightNode.addNodeChild(__flightNode, __flightText);
		var signals = FlightText.enableTextFieldSignals(__flightText);
		FlightSignals.connectSignal(signals.onTextFieldChange, cast __flight_onTextFieldChange);
		FlightSignals.connectSignal(signals.onTextFieldScroll, cast __flight_onTextFieldScroll);
		FlightTextInput.enableTextInput(__flightText, {
			displayAsPassword: __displayAsPassword,
			passwordCharacter: __passwordChar,
			restrict: __toFlightRestrict(__restrict)
		});
		__syncFlightText();
	}

	public function appendText(text:String):Void
	{
		if (text == null || text == "") return;
		var value = __text + text;
		var added = value.length - __text.length;
		for (_ in 0...added) __formatByCharacter.push(__textFormat.clone());
		__text = value;
		__htmlText = value;
		__isHTML = false;
		__selectionIndex = __caretIndex = __text.length;
		__syncFlightContent();
		__updateAutoSize();
	}

	public function getCharBoundaries(charIndex:Int):Rectangle
	{
		if (charIndex < 0 || charIndex >= __text.length) return null;
		var layout = __createTextLayout();
		var result = new Rectangle();
		if (!FlightTextLayout.getRichTextCharBoundaries(cast result, layout, charIndex)) return null;
		result.x -= __scrollH;
		result.y -= __scrollYOffset(layout);
		return result;
	}

	public function getCharIndexAtPoint(x:Float, y:Float):Int
	{
		if (x <= 2 || y <= 0 || x > __fieldWidth + 4 || y > __fieldHeight + 4) return -1;
		var layout = __createTextLayout();
		return Std.int(FlightTextLayout.computeRichTextCharIndexAtPoint(layout, x + __scrollH, y + __scrollYOffset(layout)));
	}

	public function getFirstCharInParagraph(charIndex:Int):Int
	{
		if (charIndex < 0 || charIndex > __text.length) return -1;
		return Std.int(FlightTextLayout.getRichTextFirstCharInParagraph(__text, charIndex));
	}

	public function getLineIndexAtPoint(x:Float, y:Float):Int
	{
		if (x <= 2 || y <= 0 || x > __fieldWidth + 4 || y > __fieldHeight + 4) return -1;
		var layout = __createTextLayout();
		return Std.int(FlightTextLayout.getRichTextLineIndexAtPoint(layout, y + __scrollYOffset(layout)));
	}

	public function getLineIndexOfChar(charIndex:Int):Int
	{
		if (charIndex < 0 || charIndex > __text.length) return -1;
		return Std.int(FlightTextLayout.getRichTextLineIndexOfChar(__createTextLayout(), charIndex));
	}

	public function getLineLength(lineIndex:Int):Int
	{
		if (lineIndex < 0 || lineIndex >= numLines) return 0;
		return Std.int(FlightTextLayout.getRichTextLineLength(__createTextLayout(), lineIndex));
	}

	public function getLineMetrics(lineIndex:Int):TextLineMetrics
	{
		if (getLineText(lineIndex) == null) throw new RangeError();
		var metrics = FlightTextLayout.computeRichTextLineMetrics(__createTextLayout(), lineIndex);
		if (metrics == null) throw new RangeError();
		return new TextLineMetrics(metrics.x, metrics.width, metrics.height, metrics.ascent, metrics.descent, metrics.leading);
	}

	public function getLineOffset(lineIndex:Int):Int
	{
		if (lineIndex < 0) throw new RangeError();
		if (lineIndex >= numLines) return -1;
		return Std.int(FlightTextLayout.getRichTextLineOffset(__createTextLayout(), lineIndex));
	}

	public function getLineText(lineIndex:Int):String
	{
		if (lineIndex < 0) throw new RangeError();
		if (lineIndex >= numLines) return null;
		return FlightTextLayout.getRichTextLineText(__text, __createTextLayout(), lineIndex);
	}

	public function getParagraphLength(charIndex:Int):Int
	{
		if (charIndex < 0 || charIndex > __text.length) return -1;
		return Std.int(FlightTextLayout.getRichTextParagraphLength(__text, charIndex));
	}

	public function getTextFormat(beginIndex:Int = -1, endIndex:Int = -1):TextFormat
	{
		if (beginIndex < -1 || endIndex < -1 || beginIndex > __text.length || endIndex > __text.length) throw new RangeError("The supplied index is out of bounds");
		if (beginIndex == -1) beginIndex = 0;
		if (endIndex == -1) endIndex = __text.length;
		if (beginIndex >= endIndex || __formatByCharacter.length == 0) return new TextFormat();

		var result = __formatByCharacter[beginIndex].clone();
		for (i in beginIndex + 1...endIndex) __retainCommonFormat(result, __formatByCharacter[i]);
		return result;
	}

	public function replaceSelectedText(value:String):Void
	{
		replaceText(selectionBeginIndex, selectionEndIndex, value);
	}

	public function replaceText(beginIndex:Int, endIndex:Int, newText:String):Void
	{
		if (__styleSheet != null) throw new openfl.errors.Error("This method cannot be used on a text field with a style sheet");
		if (beginIndex < 0) beginIndex = 0;
		if (endIndex < beginIndex) endIndex = beginIndex;
		if (beginIndex > __text.length) beginIndex = __text.length;
		if (endIndex > __text.length) endIndex = __text.length;
		if (newText == null) newText = "";

		var before = __formatByCharacter.slice(0, beginIndex);
		var after = __formatByCharacter.slice(endIndex);
		var inserted = [for (_ in 0...newText.length) __textFormat.clone()];
		__text = __text.substring(0, beginIndex) + newText + __text.substring(endIndex);
		__formatByCharacter = before.concat(inserted).concat(after).slice(0, __text.length);
		__htmlText = __text;
		__isHTML = false;
		__selectionIndex = __caretIndex = Std.int(Math.min(beginIndex + newText.length, __text.length));
		__syncFlightContent();
		__updateAutoSize();
	}

	public function setSelection(beginIndex:Int, endIndex:Int):Void
	{
		__selectionIndex = Std.int(Math.max(0, Math.min(beginIndex, __text.length)));
		__caretIndex = Std.int(Math.max(0, Math.min(endIndex, __text.length)));
		FlightTextInput.setTextInputSelection(__flightText, __selectionIndex, __caretIndex);
	}

	public function setTextFormat(format:TextFormat, beginIndex:Int = -1, endIndex:Int = -1):Void
	{
		var max = __text.length;
		if (beginIndex == -1)
		{
			beginIndex = 0;
			if (endIndex == -1) endIndex = max;
		}
		else if (endIndex == -1)
		{
			endIndex = beginIndex + 1;
		}
		if (beginIndex == endIndex) return;
		if (beginIndex < 0 || endIndex <= 0 || endIndex < beginIndex || beginIndex >= max || endIndex > max) throw new RangeError();
		for (i in beginIndex...endIndex) __formatByCharacter[i].__merge(format);
		__syncFlightFormats();
		__updateAutoSize();
	}

	@:noCompletion private function __flight_onTextFieldChange():Void
	{
		var value = FlightText.getRichTextString(__flightText);
		if (value == __text) return;
		__text = value;
		__htmlText = __text;
		__isHTML = false;
		__formatByCharacter = [];
		for (i in 0...__text.length)
		{
			var flightFormat:FlightTextFormat = {};
			FlightText.getRichTextFormatRangeAt(flightFormat, __flightText, i);
			__formatByCharacter.push(__fromFlightTextFormat(flightFormat));
		}
		__selectionIndex = Std.int(FlightTextInput.getTextInputSelectionBeginIndex(__flightText));
		__caretIndex = Std.int(FlightTextInput.getTextInputSelectionEndIndex(__flightText));
		__updateAutoSize();
		dispatchEvent(new Event(Event.CHANGE));
	}

	@:noCompletion private function __flight_onTextFieldScroll():Void
	{
		__scrollH = Std.int(__flightText.data.scrollH);
		__scrollV = Std.int(__flightText.data.scrollV);
		dispatchEvent(new Event(Event.SCROLL));
	}

	@:noCompletion private function __syncFlightText():Void
	{
		FlightText.setRichTextBackground(__flightText, __background);
		FlightText.setRichTextBackgroundColor(__flightText, __toFlightColor(__backgroundColor));
		FlightText.setRichTextBorder(__flightText, __border);
		FlightText.setRichTextBorderColor(__flightText, __toFlightColor(__borderColor));
		FlightText.setRichTextCondenseWhite(__flightText, condenseWhite);
		FlightText.setRichTextHeight(__flightText, __fieldHeight);
		FlightText.setRichTextMaxChars(__flightText, __maxChars == 0 ? -1 : __maxChars);
		FlightText.setRichTextMouseWheelEnabled(__flightText, __mouseWheelEnabled);
		FlightText.setRichTextMultiline(__flightText, __multiline);
		FlightText.setRichTextSelectable(__flightText, __selectable);
		FlightText.setRichTextTextColor(__flightText, __toFlightColor(textColor));
		FlightText.setRichTextWidth(__flightText, __fieldWidth);
		FlightText.setRichTextWordWrap(__flightText, __wordWrap);
		__syncFlightInputOptions();
		__syncFlightContent();
	}

	@:noCompletion private function __syncFlightContent():Void
	{
		FlightText.setRichTextString(__flightText, __text);
		__syncFlightFormats();
		FlightTextInput.setTextInputSelection(__flightText, __selectionIndex, __caretIndex);
	}

	@:noCompletion private function __syncFlightFormats():Void
	{
		FlightText.setRichTextDefaultTextFormat(__flightText, __toFlightTextFormat(__textFormat));
		FlightText.clearRichTextFormatRanges(__flightText);
		for (i in 0...__text.length)
		{
			var format = i < __formatByCharacter.length ? __formatByCharacter[i] : __textFormat;
			FlightText.setRichTextFormatRange(__flightText, __toFlightTextFormat(format), i, i + 1);
		}
	}

	@:noCompletion private function __syncFlightInputOptions():Void
	{
		FlightTextInput.enableTextInput(__flightText, {
			displayAsPassword: __displayAsPassword,
			passwordCharacter: __passwordChar,
			restrict: __toFlightRestrict(__restrict)
		});
	}

	@:noCompletion private function __scrollYOffset(layout:FlightTextLayoutResult):Float
	{
		var result = 0.0;
		var count = Std.int(Math.min(__scrollV - 1, layout.lineHeights.length));
		for (i in 0...count) result += layout.lineHeights[i];
		return result;
	}

	@:noCompletion private function __toFlightColor(value:Int):Float
	{
		return (value & 0xFFFFFF) * 256.0 + 0xFF;
	}

	@:noCompletion private function __toFlightRestrict(value:String):String
	{
		if (value == null) return "";
		if (value == "") return "^\u0000-\uFFFF";
		return value;
	}

	@:noCompletion private function __createTextLayout():FlightTextLayoutResult
	{
		var layout = FlightTextLayout.createTextLayoutResult();
		var measure:TextMeasureFunction = cast FlightTextLayout.getTextLayoutMeasureProvider();
		if (measure == null)
		{
			measure = function(value:String, format:FlightTextFormat):Float return 0;
		}

		var ranges = [];
		if (__formatByCharacter.length == 0)
		{
			ranges.push(FlightTextLayout.createTextFormatRange(__toFlightTextFormat(__textFormat), 0, __text.length));
		}
		else
		{
			for (i in 0...__text.length)
			{
				var format = i < __formatByCharacter.length ? __formatByCharacter[i] : __textFormat;
				ranges.push(FlightTextLayout.createTextFormatRange(__toFlightTextFormat(format), i, i + 1));
			}
		}

		FlightTextLayout.computeTextLayout(layout, {
			text: __text,
			formatRanges: ranges,
			width: __fieldWidth,
			height: __fieldHeight,
			measure: measure,
			multiline: __multiline,
			wordWrap: __wordWrap
		});
		return layout;
	}

	@:noCompletion private function __toFlightTextFormat(format:TextFormat):FlightTextFormat
	{
		var result:FlightTextFormat = {};
		if (format.align != null)
		{
			result.align = switch (format.align)
			{
				case TextFormatAlign.CENTER: "center";
				case TextFormatAlign.END: "end";
				case TextFormatAlign.JUSTIFY: "justify";
				case TextFormatAlign.RIGHT: "right";
				case TextFormatAlign.START: "start";
				default: "left";
			};
		}
		if (format.blockIndent != null) result.blockIndent = format.blockIndent;
		if (format.bold != null) result.bold = format.bold;
		if (format.bullet != null) result.bullet = format.bullet;
		if (format.color != null) result.color = __toFlightColor(format.color);
		if (format.font != null) result.font = format.font;
		if (format.indent != null) result.indent = format.indent;
		if (format.italic != null) result.italic = format.italic;
		if (format.kerning != null) result.kerning = format.kerning;
		if (format.leading != null) result.leading = format.leading;
		if (format.leftMargin != null) result.leftMargin = format.leftMargin;
		if (format.letterSpacing != null) result.letterSpacing = format.letterSpacing;
		if (format.rightMargin != null) result.rightMargin = format.rightMargin;
		if (format.size != null) result.size = format.size;
		if (format.strikethrough != null) result.strikethrough = format.strikethrough;
		if (format.tabStops != null) result.tabStops = [for (stop in format.tabStops) stop * 1.0];
		if (format.target != null) result.target = format.target;
		if (format.underline != null) result.underline = format.underline;
		if (format.url != null) result.url = format.url;
		return result;
	}

	@:noCompletion private function __fromFlightTextFormat(format:FlightTextFormat):TextFormat
	{
		var result = new TextFormat();
		var value:Dynamic = format;
		if (Reflect.hasField(value, "align"))
		{
			result.align = switch (Reflect.field(value, "align"))
			{
				case "center": TextFormatAlign.CENTER;
				case "end": TextFormatAlign.END;
				case "justify": TextFormatAlign.JUSTIFY;
				case "right": TextFormatAlign.RIGHT;
				case "start": TextFormatAlign.START;
				default: TextFormatAlign.LEFT;
			};
		}
		if (Reflect.hasField(value, "blockIndent")) result.blockIndent = Std.int(Reflect.field(value, "blockIndent"));
		if (Reflect.hasField(value, "bold")) result.bold = Reflect.field(value, "bold");
		if (Reflect.hasField(value, "bullet")) result.bullet = Reflect.field(value, "bullet");
		if (Reflect.hasField(value, "color")) result.color = Std.int(Reflect.field(value, "color") / 256) & 0xFFFFFF;
		if (Reflect.hasField(value, "font")) result.font = Reflect.field(value, "font");
		if (Reflect.hasField(value, "indent")) result.indent = Std.int(Reflect.field(value, "indent"));
		if (Reflect.hasField(value, "italic")) result.italic = Reflect.field(value, "italic");
		if (Reflect.hasField(value, "kerning")) result.kerning = Reflect.field(value, "kerning");
		if (Reflect.hasField(value, "leading")) result.leading = Std.int(Reflect.field(value, "leading"));
		if (Reflect.hasField(value, "leftMargin")) result.leftMargin = Std.int(Reflect.field(value, "leftMargin"));
		if (Reflect.hasField(value, "letterSpacing")) result.letterSpacing = Reflect.field(value, "letterSpacing");
		if (Reflect.hasField(value, "rightMargin")) result.rightMargin = Std.int(Reflect.field(value, "rightMargin"));
		if (Reflect.hasField(value, "size")) result.size = Std.int(Reflect.field(value, "size"));
		if (Reflect.hasField(value, "strikethrough")) result.strikethrough = Reflect.field(value, "strikethrough");
		if (Reflect.hasField(value, "tabStops")) result.tabStops = [for (stop in (cast Reflect.field(value, "tabStops") : Array<Float>)) Std.int(stop)];
		if (Reflect.hasField(value, "target")) result.target = Reflect.field(value, "target");
		if (Reflect.hasField(value, "underline")) result.underline = Reflect.field(value, "underline");
		if (Reflect.hasField(value, "url")) result.url = Reflect.field(value, "url");
		return result;
	}

	@:noCompletion private function __retainCommonFormat(result:TextFormat, other:TextFormat):Void
	{
		if (result.align != other.align) result.align = null;
		if (result.blockIndent != other.blockIndent) result.blockIndent = null;
		if (result.bold != other.bold) result.bold = null;
		if (result.bullet != other.bullet) result.bullet = null;
		if (result.color != other.color) result.color = null;
		if (result.font != other.font) result.font = null;
		if (result.indent != other.indent) result.indent = null;
		if (result.italic != other.italic) result.italic = null;
		if (result.kerning != other.kerning) result.kerning = null;
		if (result.leading != other.leading) result.leading = null;
		if (result.leftMargin != other.leftMargin) result.leftMargin = null;
		if (result.letterSpacing != other.letterSpacing) result.letterSpacing = null;
		if (result.rightMargin != other.rightMargin) result.rightMargin = null;
		if (result.size != other.size) result.size = null;
		if (result.strikethrough != other.strikethrough) result.strikethrough = null;
		if (result.tabStops != other.tabStops) result.tabStops = null;
		if (result.target != other.target) result.target = null;
		if (result.underline != other.underline) result.underline = null;
		if (result.url != other.url) result.url = null;
	}

	@:noCompletion private function __decodeEntities(value:String):String
	{
		var result = value;
		var decimal = ~/&#([0-9]+);/;
		while (decimal.match(result))
		{
			result = decimal.matchedLeft() + String.fromCharCode(Std.parseInt(decimal.matched(1))) + decimal.matchedRight();
		}
		var hexadecimal = ~/&#x([0-9A-Fa-f]+);/;
		while (hexadecimal.match(result))
		{
			result = hexadecimal.matchedLeft() + String.fromCharCode(Std.parseInt("0x" + hexadecimal.matched(1))) + hexadecimal.matchedRight();
		}
		result = StringTools.replace(result, "&lt;", "<");
		result = StringTools.replace(result, "&gt;", ">");
		result = StringTools.replace(result, "&quot;", "\"");
		result = StringTools.replace(result, "&#39;", "'");
		result = StringTools.replace(result, "&amp;", "&");
		result = StringTools.replace(result, "&nbsp;", " ");
		return result;
	}

	@:noCompletion private function __parseHTML(value:String):{text:String, formats:Array<TextFormat>}
	{
		var output = "";
		var formats:Array<TextFormat> = [];
		var current = __textFormat.clone();
		var stack:Array<TextFormat> = [];
		var remaining = value;
		var tag = ~/<([^>]*)>/;

		while (tag.match(remaining))
		{
			var prefix = __decodeEntities(tag.matchedLeft());
			output += prefix;
			for (_ in 0...prefix.length) formats.push(current.clone());

			var markup = StringTools.trim(tag.matched(1));
			var lower = markup.toLowerCase();
			if (StringTools.startsWith(lower, "/"))
			{
				if (stack.length > 0) current = stack.pop();
			}
			else if (lower == "br" || lower == "br/")
			{
				output += "\n";
				formats.push(current.clone());
			}
			else if (StringTools.startsWith(lower, "font") || lower == "b" || lower == "i" || lower == "u")
			{
				stack.push(current);
				current = current.clone();
				if (lower == "b") current.bold = true;
				else if (lower == "i") current.italic = true;
				else if (lower == "u") current.underline = true;
				else
				{
					var color = ~/color\s*=\s*["']?#([0-9A-Fa-f]+)/i;
					if (color.match(markup)) current.color = Std.parseInt("0x" + color.matched(1));
				}
			}

			remaining = tag.matchedRight();
		}

		var suffix = __decodeEntities(remaining);
		output += suffix;
		for (_ in 0...suffix.length) formats.push(current.clone());
		return {text: output, formats: formats};
	}

	@:noCompletion private function __updateAutoSize():Void
	{
		if (__autoSize == TextFieldAutoSize.NONE) return;
		var oldWidth = __fieldWidth;
		var newWidth = textWidth + 4;
		switch (__autoSize)
		{
			case RIGHT: x += oldWidth - newWidth;
			case CENTER: x += (oldWidth - newWidth) * 0.5;
			default:
		}
		__fieldWidth = newWidth;
		__fieldHeight = textHeight + 4;
		FlightText.setRichTextWidth(__flightText, __fieldWidth);
		FlightText.setRichTextHeight(__flightText, __fieldHeight);
	}

	@:noCompletion private function __withoutLineBreak(value:String):String
	{
		return StringTools.endsWith(value, "\n") ? value.substr(0, value.length - 1) : value;
	}

	@:noCompletion private function get_antiAliasType():AntiAliasType return __antiAliasType;
	@:noCompletion private function set_antiAliasType(value:AntiAliasType):AntiAliasType return __antiAliasType = value;
	@:noCompletion private function get_autoSize():TextFieldAutoSize return __autoSize;
	@:noCompletion private function set_autoSize(value:TextFieldAutoSize):TextFieldAutoSize
	{
		__autoSize = value;
		__updateAutoSize();
		return value;
	}
	@:noCompletion private function get_background():Bool return __background;
	@:noCompletion private function set_background(value:Bool):Bool
	{
		FlightText.setRichTextBackground(__flightText, value);
		return __background = value;
	}
	@:noCompletion private function get_backgroundColor():Int return __backgroundColor;
	@:noCompletion private function set_backgroundColor(value:Int):Int
	{
		FlightText.setRichTextBackgroundColor(__flightText, __toFlightColor(value));
		return __backgroundColor = value;
	}
	@:noCompletion private function get_border():Bool return __border;
	@:noCompletion private function set_border(value:Bool):Bool
	{
		FlightText.setRichTextBorder(__flightText, value);
		return __border = value;
	}
	@:noCompletion private function get_borderColor():Int return __borderColor;
	@:noCompletion private function set_borderColor(value:Int):Int
	{
		FlightText.setRichTextBorderColor(__flightText, __toFlightColor(value));
		return __borderColor = value;
	}
	@:noCompletion private function get_bottomScrollV():Int return Std.int(FlightTextLayout.computeRichTextBottomScrollV(__flightText.data, __createTextLayout()));
	@:noCompletion private function get_caretIndex():Int return Std.int(FlightTextInput.getTextInputCaretIndex(__flightText));
	@:noCompletion private function get_defaultTextFormat():TextFormat return __textFormat.clone();
	@:noCompletion private function set_defaultTextFormat(value:TextFormat):TextFormat
	{
		if (value != null) __textFormat.__merge(value);
		__syncFlightFormats();
		__updateAutoSize();
		return value;
	}
	@:noCompletion private function get_displayAsPassword():Bool return __displayAsPassword;
	@:noCompletion private function set_displayAsPassword(value:Bool):Bool
	{
		__displayAsPassword = value;
		__syncFlightInputOptions();
		return value;
	}
	@:noCompletion private function get_embedFonts():Bool return __embedFonts;
	@:noCompletion private function set_embedFonts(value:Bool):Bool return __embedFonts = value;
	@:noCompletion private function get_gridFitType():GridFitType return __gridFitType;
	@:noCompletion private function set_gridFitType(value:GridFitType):GridFitType return __gridFitType = value;
	@:noCompletion private function get_htmlText():String return __isHTML ? __htmlText : __text;
	@:noCompletion private function set_htmlText(value:String):String
	{
		if (value == null) throw new TypeError("Error #2007: Parameter text must be non-null.");
		if (condenseWhite) value = ~/\s+/g.replace(value, " ");
		__htmlText = value;
		__isHTML = true;
		var parsed = __parseHTML(value);
		__text = parsed.text;
		__formatByCharacter = parsed.formats.slice(0, __text.length);
		__selectionIndex = __caretIndex = __text.length;
		FlightText.setRichTextCondenseWhite(__flightText, condenseWhite);
		__syncFlightContent();
		__updateAutoSize();
		return value;
	}
	@:noCompletion private function get_length():Int return __text.length;
	@:noCompletion private function get_maxChars():Int return __maxChars;
	@:noCompletion private function set_maxChars(value:Int):Int
	{
		__maxChars = value;
		FlightText.setRichTextMaxChars(__flightText, value == 0 ? -1 : value);
		return value;
	}
	@:noCompletion private function get_maxScrollH():Int
	{
		return Std.int(FlightTextLayout.computeRichTextMaxScrollH(__flightText.data, __createTextLayout()));
	}
	@:noCompletion private function get_maxScrollV():Int
	{
		return Std.int(FlightTextLayout.computeRichTextMaxScrollV(__flightText.data, __createTextLayout()));
	}
	@:noCompletion private function get_mouseWheelEnabled():Bool return __mouseWheelEnabled;
	@:noCompletion private function set_mouseWheelEnabled(value:Bool):Bool
	{
		FlightText.setRichTextMouseWheelEnabled(__flightText, value);
		return __mouseWheelEnabled = value;
	}
	@:noCompletion private function get_multiline():Bool return __multiline;
	@:noCompletion private function set_multiline(value:Bool):Bool
	{
		FlightText.setRichTextMultiline(__flightText, value);
		return __multiline = value;
	}
	@:noCompletion private function get_numLines():Int return Std.int(FlightTextLayout.computeRichTextLineCount(__createTextLayout()));
	@:noCompletion private function get_restrict():String return __restrict;
	@:noCompletion private function set_restrict(value:String):String
	{
		__restrict = value;
		__syncFlightInputOptions();
		return value;
	}
	@:noCompletion private function get_scrollH():Int return __scrollH;
	@:noCompletion private function set_scrollH(value:Int):Int
	{
		FlightText.setRichTextScrollH(__flightText, value, __createTextLayout());
		return __scrollH;
	}
	@:noCompletion private function get_scrollV():Int return __scrollV;
	@:noCompletion private function set_scrollV(value:Int):Int
	{
		FlightText.setRichTextScrollV(__flightText, value, __createTextLayout());
		return __scrollV;
	}
	@:noCompletion private function get_selectable():Bool return __selectable;
	@:noCompletion private function set_selectable(value:Bool):Bool
	{
		FlightText.setRichTextSelectable(__flightText, value);
		return __selectable = value;
	}
	@:noCompletion private function get_selectionBeginIndex():Int return Std.int(FlightTextInput.getTextInputSelectionBeginIndex(__flightText));
	@:noCompletion private function get_selectionEndIndex():Int return Std.int(FlightTextInput.getTextInputSelectionEndIndex(__flightText));
	@:noCompletion private function get_sharpness():Float return __sharpness;
	@:noCompletion private function set_sharpness(value:Float):Float return __sharpness = value;
	@:noCompletion private function get_styleSheet():StyleSheet return __styleSheet;
	@:noCompletion private function set_styleSheet(value:StyleSheet):StyleSheet
	{
		var changed = value != __styleSheet;
		__styleSheet = value;
		if (value != null) __type = TextFieldType.DYNAMIC;
		if (changed && __isHTML) set_htmlText(__htmlText);
		return value;
	}
	@:noCompletion private override function get_tabEnabled():Bool return __explicitTabEnabled == null ? __type == TextFieldType.INPUT : __explicitTabEnabled;
	@:noCompletion private override function set_tabEnabled(value:Bool):Bool return __explicitTabEnabled = value;
	@:noCompletion private function get_text():String return __text;
	@:noCompletion private function set_text(value:String):String
	{
		if (value == null) throw new TypeError("Error #2007: Parameter text must be non-null.");
		if (__styleSheet != null) return set_htmlText(value);
		__text = value;
		__htmlText = __text;
		__isHTML = false;
		__formatByCharacter = [for (_ in 0...__text.length) __textFormat.clone()];
		__selectionIndex = __caretIndex = 0;
		__syncFlightContent();
		__updateAutoSize();
		return value;
	}
	@:noCompletion private function get_textColor():Int return __textFormat.color == null ? 0 : __textFormat.color;
	@:noCompletion private function set_textColor(value:Int):Int
	{
		__textFormat.color = value;
		for (format in __formatByCharacter) format.color = value;
		FlightText.setRichTextTextColor(__flightText, __toFlightColor(value));
		__syncFlightFormats();
		return value;
	}
	@:noCompletion private function get_textHeight():Float
	{
		return FlightTextLayout.computeRichTextTextHeight(__createTextLayout());
	}
	@:noCompletion private function get_textWidth():Float
	{
		return FlightTextLayout.computeRichTextTextWidth(__createTextLayout());
	}
	@:noCompletion private function get_type():TextFieldType return __type;
	@:noCompletion private function set_type(value:TextFieldType):TextFieldType
	{
		return __type = __styleSheet == null ? value : TextFieldType.DYNAMIC;
	}
	@:noCompletion private override function get_height():Float return __fieldHeight * Math.abs(scaleY);
	@:noCompletion private override function set_height(value:Float):Float
	{
		var scale = Math.abs(scaleY);
		__fieldHeight = scale == 0 ? value : value / scale;
		FlightText.setRichTextHeight(__flightText, __fieldHeight);
		return value;
	}
	@:noCompletion private override function get_width():Float return __fieldWidth * Math.abs(scaleX);
	@:noCompletion private override function set_width(value:Float):Float
	{
		var scale = Math.abs(scaleX);
		__fieldWidth = scale == 0 ? value : value / scale;
		FlightText.setRichTextWidth(__flightText, __fieldWidth);
		return value;
	}
	@:noCompletion private function get_wordWrap():Bool return __wordWrap;
	@:noCompletion private function set_wordWrap(value:Bool):Bool
	{
		FlightText.setRichTextWordWrap(__flightText, value);
		return __wordWrap = value;
	}
	@:noCompletion private function get_passwordChar():String return __passwordChar;
	@:noCompletion private function set_passwordChar(value:String):String
	{
		__passwordChar = value;
		__syncFlightInputOptions();
		return value;
	}
}
#else
typedef TextField = flash.text.TextField;
#end
