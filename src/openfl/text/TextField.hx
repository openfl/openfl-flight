package openfl.text;

#if !flash
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
	@:noCompletion private var __fieldHeight:Float;
	@:noCompletion private var __fieldWidth:Float;
	@:noCompletion private var __formatByCharacter:Array<TextFormat>;
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

		// TODO(Flight): Create and retain a Flight text node once the display
		// bridge exposes a public text-field lifecycle and rendering contract.
	}

	public function appendText(text:String):Void
	{
		if (text == null || text == "") return;
		var value = __limitText(__text + text);
		var added = value.length - __text.length;
		for (_ in 0...added) __formatByCharacter.push(__textFormat.clone());
		__text = value;
		__htmlText = value;
		__isHTML = false;
		__selectionIndex = __caretIndex = __text.length;
		__updateAutoSize();
	}

	public function getCharBoundaries(charIndex:Int):Rectangle
	{
		if (charIndex < 0 || charIndex >= __text.length) return null;
		var line = getLineIndexOfChar(charIndex);
		var offset = getLineOffset(line);
		var size = __fontSize();
		return new Rectangle(2 + (charIndex - offset) * size * 0.6 - __scrollH, 2 + (line - __scrollV + 1) * __lineHeight(), size * 0.6, __lineHeight());
	}

	public function getCharIndexAtPoint(x:Float, y:Float):Int
	{
		if (x < 2 || y < 2 || x > __fieldWidth || y > __fieldHeight) return -1;
		var line = Std.int((y - 2) / __lineHeight()) + __scrollV - 1;
		var offset = getLineOffset(line);
		if (offset < 0) return -1;
		var index = offset + Std.int((x - 2 + __scrollH) / (__fontSize() * 0.6));
		var end = offset + getLineLength(line);
		return index >= offset && index < end ? index : -1;
	}

	public function getFirstCharInParagraph(charIndex:Int):Int
	{
		if (charIndex < 0 || charIndex > __text.length) return -1;
		var start = __text.lastIndexOf("\n", charIndex > 0 ? charIndex - 1 : 0);
		return start < 0 ? 0 : start + 1;
	}

	public function getLineIndexAtPoint(x:Float, y:Float):Int
	{
		if (x < 2 || y < 2 || x > __fieldWidth || y > __fieldHeight) return -1;
		var line = Std.int((y - 2) / __lineHeight()) + __scrollV - 1;
		return line < numLines ? line : -1;
	}

	public function getLineIndexOfChar(charIndex:Int):Int
	{
		if (charIndex < 0 || charIndex > __text.length) return -1;
		var line = 0;
		for (i in 0...charIndex) if (__text.charAt(i) == "\n") line++;
		return line;
	}

	public function getLineLength(lineIndex:Int):Int
	{
		var bounds = __lineBounds(lineIndex);
		return bounds == null ? 0 : bounds.end - bounds.start;
	}

	public function getLineMetrics(lineIndex:Int):TextLineMetrics
	{
		var line = getLineText(lineIndex);
		if (line == null) throw new RangeError();
		var width = __measureLine(__withoutLineBreak(line));
		var height = __lineHeight();
		return new TextLineMetrics(2, width, height, height * 0.8, height * 0.2, __textFormat.leading == null ? 0 : __textFormat.leading);
	}

	public function getLineOffset(lineIndex:Int):Int
	{
		if (lineIndex < 0) throw new RangeError();
		var bounds = __lineBounds(lineIndex);
		return bounds == null ? -1 : bounds.start;
	}

	public function getLineText(lineIndex:Int):String
	{
		if (lineIndex < 0) throw new RangeError();
		var bounds = __lineBounds(lineIndex);
		return bounds == null ? null : __text.substring(bounds.start, bounds.end);
	}

	public function getParagraphLength(charIndex:Int):Int
	{
		if (charIndex < 0 || charIndex > __text.length) return -1;
		var start = getFirstCharInParagraph(charIndex);
		var end = __text.indexOf("\n", charIndex);
		if (end < 0) end = __text.length;
		else end++;
		return end - start;
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
		__text = __limitText(__text.substring(0, beginIndex) + newText + __text.substring(endIndex));
		__formatByCharacter = before.concat(inserted).concat(after).slice(0, __text.length);
		__htmlText = __text;
		__isHTML = false;
		__selectionIndex = __caretIndex = Std.int(Math.min(beginIndex + newText.length, __text.length));
		__updateAutoSize();
	}

	public function setSelection(beginIndex:Int, endIndex:Int):Void
	{
		__selectionIndex = Std.int(Math.max(0, Math.min(beginIndex, __text.length)));
		__caretIndex = Std.int(Math.max(0, Math.min(endIndex, __text.length)));
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
		__updateAutoSize();
	}

	@:noCompletion private function __fontSize():Float
	{
		return __textFormat.size == null ? 12 : __textFormat.size;
	}

	@:noCompletion private function __lineBounds(lineIndex:Int):Null<{start:Int, end:Int}>
	{
		if (lineIndex < 0) return null;
		var start = 0;
		var line = 0;
		while (line < lineIndex)
		{
			var next = __text.indexOf("\n", start);
			if (next < 0) return null;
			start = next + 1;
			line++;
		}
		if (start == __text.length && lineIndex > 0 && StringTools.endsWith(__text, "\n")) return null;
		var newline = __text.indexOf("\n", start);
		return {start: start, end: newline < 0 ? __text.length : newline + 1};
	}

	@:noCompletion private function __lineHeight():Float
	{
		return __fontSize() + (__textFormat.leading == null ? 0 : __textFormat.leading);
	}

	@:noCompletion private function __limitText(value:String):String
	{
		if (__maxChars > 0 && value.length > __maxChars) return value.substr(0, __maxChars);
		return value;
	}

	@:noCompletion private function __measureLine(value:String):Float
	{
		return value.length * __fontSize() * 0.6;
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
	@:noCompletion private function set_background(value:Bool):Bool return __background = value;
	@:noCompletion private function get_backgroundColor():Int return __backgroundColor;
	@:noCompletion private function set_backgroundColor(value:Int):Int return __backgroundColor = value;
	@:noCompletion private function get_border():Bool return __border;
	@:noCompletion private function set_border(value:Bool):Bool return __border = value;
	@:noCompletion private function get_borderColor():Int return __borderColor;
	@:noCompletion private function set_borderColor(value:Int):Int return __borderColor = value;
	@:noCompletion private function get_bottomScrollV():Int return Std.int(Math.min(numLines, __scrollV + Math.max(1, Math.floor((__fieldHeight - 4) / __lineHeight())) - 1));
	@:noCompletion private function get_caretIndex():Int return __caretIndex;
	@:noCompletion private function get_defaultTextFormat():TextFormat return __textFormat.clone();
	@:noCompletion private function set_defaultTextFormat(value:TextFormat):TextFormat
	{
		if (value != null) __textFormat.__merge(value);
		__updateAutoSize();
		return value;
	}
	@:noCompletion private function get_displayAsPassword():Bool return __displayAsPassword;
	@:noCompletion private function set_displayAsPassword(value:Bool):Bool return __displayAsPassword = value;
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
		__text = __limitText(parsed.text);
		__formatByCharacter = parsed.formats.slice(0, __text.length);
		__selectionIndex = __caretIndex = __text.length;
		__updateAutoSize();
		return value;
	}
	@:noCompletion private function get_length():Int return __text.length;
	@:noCompletion private function get_maxChars():Int return __maxChars;
	@:noCompletion private function set_maxChars(value:Int):Int
	{
		__maxChars = value;
		if (value > 0 && __text.length > value) set_text(__text.substr(0, value));
		return value;
	}
	@:noCompletion private function get_maxScrollH():Int
	{
		var widest = 0.0;
		for (line in __text.split("\n")) widest = Math.max(widest, __measureLine(line));
		return Std.int(Math.max(0, Math.ceil(widest - Math.max(0, __fieldWidth - 4))));
	}
	@:noCompletion private function get_maxScrollV():Int
	{
		var visible = Math.max(1, Math.floor((__fieldHeight - 4) / __lineHeight()));
		return Std.int(Math.max(1, numLines - visible + 1));
	}
	@:noCompletion private function get_mouseWheelEnabled():Bool return __mouseWheelEnabled;
	@:noCompletion private function set_mouseWheelEnabled(value:Bool):Bool return __mouseWheelEnabled = value;
	@:noCompletion private function get_multiline():Bool return __multiline;
	@:noCompletion private function set_multiline(value:Bool):Bool return __multiline = value;
	@:noCompletion private function get_numLines():Int return __text == "" ? 1 : __text.split("\n").length;
	@:noCompletion private function get_restrict():String return __restrict;
	@:noCompletion private function set_restrict(value:String):String return __restrict = value;
	@:noCompletion private function get_scrollH():Int return __scrollH;
	@:noCompletion private function set_scrollH(value:Int):Int
	{
		var next = Std.int(Math.max(0, Math.min(value, maxScrollH)));
		if (next != __scrollH)
		{
			__scrollH = next;
			dispatchEvent(new Event(Event.SCROLL));
		}
		return __scrollH;
	}
	@:noCompletion private function get_scrollV():Int return __scrollV;
	@:noCompletion private function set_scrollV(value:Int):Int
	{
		var next = Std.int(Math.max(1, Math.min(value, maxScrollV)));
		if (next != __scrollV)
		{
			__scrollV = next;
			dispatchEvent(new Event(Event.SCROLL));
		}
		return __scrollV;
	}
	@:noCompletion private function get_selectable():Bool return __selectable;
	@:noCompletion private function set_selectable(value:Bool):Bool return __selectable = value;
	@:noCompletion private function get_selectionBeginIndex():Int return Std.int(Math.min(__caretIndex, __selectionIndex));
	@:noCompletion private function get_selectionEndIndex():Int return Std.int(Math.max(__caretIndex, __selectionIndex));
	@:noCompletion private function get_sharpness():Float return __sharpness;
	@:noCompletion private function set_sharpness(value:Float):Float return __sharpness = value;
	@:noCompletion private function get_styleSheet():StyleSheet return __styleSheet;
	@:noCompletion private function set_styleSheet(value:StyleSheet):StyleSheet
	{
		__styleSheet = value;
		if (value != null) __type = TextFieldType.DYNAMIC;
		return value;
	}
	@:noCompletion private override function get_tabEnabled():Bool return __tabEnabled == null ? __type == TextFieldType.INPUT : __tabEnabled;
	@:noCompletion private function get_text():String return __text;
	@:noCompletion private function set_text(value:String):String
	{
		if (value == null) throw new TypeError("Error #2007: Parameter text must be non-null.");
		if (__styleSheet != null) return set_htmlText(value);
		__text = __limitText(value);
		__htmlText = __text;
		__isHTML = false;
		__formatByCharacter = [for (_ in 0...__text.length) __textFormat.clone()];
		__selectionIndex = __caretIndex = 0;
		__updateAutoSize();
		return value;
	}
	@:noCompletion private function get_textColor():Int return __textFormat.color == null ? 0 : __textFormat.color;
	@:noCompletion private function set_textColor(value:Int):Int
	{
		__textFormat.color = value;
		for (format in __formatByCharacter) format.color = value;
		return value;
	}
	@:noCompletion private function get_textHeight():Float
	{
		if (__text == "") return 0;
		var lines = numLines;
		if (__type != TextFieldType.INPUT && StringTools.endsWith(__text, "\n")) lines--;
		return Math.max(1, lines) * __lineHeight();
	}
	@:noCompletion private function get_textWidth():Float
	{
		var widest = 0.0;
		for (line in __text.split("\n")) widest = Math.max(widest, __measureLine(line));
		return widest;
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
		return value;
	}
	@:noCompletion private override function get_width():Float return __fieldWidth * Math.abs(scaleX);
	@:noCompletion private override function set_width(value:Float):Float
	{
		var scale = Math.abs(scaleX);
		__fieldWidth = scale == 0 ? value : value / scale;
		return value;
	}
	@:noCompletion private function get_wordWrap():Bool return __wordWrap;
	@:noCompletion private function set_wordWrap(value:Bool):Bool return __wordWrap = value;
	@:noCompletion private function get_passwordChar():String return __passwordChar;
	@:noCompletion private function set_passwordChar(value:String):String return __passwordChar = value;
}
#else
typedef TextField = flash.text.TextField;
#end
