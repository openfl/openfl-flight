package openfl.geom;

#if !flash
import flight.Materials;
import flight.types.ColorScaleBias;

/**
	The ColorTransform class lets you adjust the color values in a display
	object. The color adjustment or _color transformation_ can be applied
	to all four channels: red, green, blue, and alpha transparency.

	When a ColorTransform object is applied to a display object, a new value
	for each color channel is calculated like this:


	* New red value = (old red value * `redMultiplier`) +
	`redOffset`
	* New green value = (old green value * `greenMultiplier`) +
	`greenOffset`
	* New blue value = (old blue value * `blueMultiplier`) +
	`blueOffset`
	* New alpha value = (old alpha value * `alphaMultiplier`) +
	`alphaOffset`


	If any of the color channel values is greater than 255 after the
	calculation, it is set to 255. If it is less than 0, it is set to 0.

	You can use ColorTransform objects in the following ways:


	* In the `colorTransform` parameter of the
	`colorTransform()` method of the BitmapData class
	* As the `colorTransform` property of a Transform object
	(which can be used as the `transform` property of a display
	object)


	You must use the `new ColorTransform()` constructor to create
	a ColorTransform object before you can call the methods of the
	ColorTransform object.

	Color transformations do not apply to the background color of a movie
	clip (such as a loaded SWF object). They apply only to graphics and symbols
	that are attached to the movie clip.

	@see [Adjusting display object colors](https://books.openfl.org/openfl-developers-guide/display-programming/manipulating-display-objects/adjusting-displayobject-colors.html)
	@see `openfl.geom.Transform.colorTransform`
	@see `openfl.display.DisplayObject.transform`
**/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
class ColorTransform
{
	/**
		A decimal value that is multiplied with the alpha transparency channel
		value.

		If you set the alpha transparency value of a display object directly by
		using the `alpha` property of the DisplayObject instance, it
		affects the value of the `alphaMultiplier` property of that
		display object's `transform.colorTransform` property.
	**/
	public var alphaMultiplier:Float;

	/**
		A number from -255 to 255 that is added to the alpha transparency channel
		value after it has been multiplied by the `alphaMultiplier`
		value.
	**/
	public var alphaOffset:Float;

	/**
		A decimal value that is multiplied with the blue channel value.
	**/
	public var blueMultiplier:Float;

	/**
		A number from -255 to 255 that is added to the blue channel value after it
		has been multiplied by the `blueMultiplier` value.
	**/
	public var blueOffset:Float;

	/**
		The RGB color value for a ColorTransform object.

		When you set this property, it changes the three color offset values
		(`redOffset`, `greenOffset`, and
		`blueOffset`) accordingly, and it sets the three color
		multiplier values(`redMultiplier`,
		`greenMultiplier`, and `blueMultiplier`) to 0. The
		alpha transparency multiplier and offset values do not change.

		When you pass a value for this property, use the format
		0x_RRGGBB_. _RR_, _GG_, and _BB_ each consist of two
		hexadecimal digits that specify the offset of each color component. The 0x
		tells the Haxe compiler that the number is a hexadecimal
		value.
	**/
	public var color(get, set):Int;

	/**
		A decimal value that is multiplied with the green channel value.
	**/
	public var greenMultiplier:Float;

	/**
		A number from -255 to 255 that is added to the green channel value after
		it has been multiplied by the `greenMultiplier` value.
	**/
	public var greenOffset:Float;

	/**
		A decimal value that is multiplied with the red channel value.
	**/
	public var redMultiplier:Float;

	/**
		A number from -255 to 255 that is added to the red channel value after it
		has been multiplied by the `redMultiplier` value.
	**/
	public var redOffset:Float;

	#if openfljs
	@:noCompletion private static function __init__()
	{
		untyped Object.defineProperty(ColorTransform.prototype, "color", {
			get: untyped #if haxe4 js.Syntax.code #else __js__ #end ("function () { return this.get_color (); }"),
			set: untyped #if haxe4 js.Syntax.code #else __js__ #end ("function (v) { return this.set_color (v); }")
		});
	}
	#end

	/**
		Creates a ColorTransform object for a display object with the specified
		color channel values and alpha values.

		@param redMultiplier   The value for the red multiplier, in the range from
							   0 to 1.
		@param greenMultiplier The value for the green multiplier, in the range
							   from 0 to 1.
		@param blueMultiplier  The value for the blue multiplier, in the range
							   from 0 to 1.
		@param alphaMultiplier The value for the alpha transparency multiplier, in
							   the range from 0 to 1.
		@param redOffset       The offset value for the red color channel, in the
							   range from -255 to 255.
		@param greenOffset     The offset value for the green color channel, in
							   the range from -255 to 255.
		@param blueOffset      The offset for the blue color channel value, in the
							   range from -255 to 255.
		@param alphaOffset     The offset for alpha transparency channel value, in
							   the range from -255 to 255.
	**/
	public function new(redMultiplier:Float = 1, greenMultiplier:Float = 1, blueMultiplier:Float = 1, alphaMultiplier:Float = 1, redOffset:Float = 0,
			greenOffset:Float = 0, blueOffset:Float = 0, alphaOffset:Float = 0):Void
	{
		var value = Materials.createColorScaleBias();
		Materials.setColorScaleBias(value, redMultiplier, greenMultiplier, blueMultiplier, alphaMultiplier, redOffset, greenOffset, blueOffset, alphaOffset);
		__copyFromFlightColorScaleBias(value);
	}

	/**
		Concatenates the ColorTranform object specified by the `second`
		parameter with the current ColorTransform object and sets the current
		object as the result, which is an additive combination of the two color
		transformations. When you apply the concatenated ColorTransform object,
		the effect is the same as applying the `second` color
		transformation after the _original_ color transformation.

		@param second The ColorTransform object to be combined with the current
					  ColorTransform object.
	**/
	public function concat(second:ColorTransform):Void
	{
		var value = __toFlightColorScaleBias();
		Materials.concatColorScaleBias(value, value, second.__toFlightColorScaleBias());
		__copyFromFlightColorScaleBias(value);
	}

	/**
		Formats and returns a string that describes all of the properties of
		the ColorTransform object.

		@return A string that lists all of the properties of the
				ColorTransform object.
	**/
	public function toString():String
	{
		return
			'(redMultiplier=$redMultiplier, greenMultiplier=$greenMultiplier, blueMultiplier=$blueMultiplier, alphaMultiplier=$alphaMultiplier, redOffset=$redOffset, greenOffset=$greenOffset, blueOffset=$blueOffset, alphaOffset=$alphaOffset)';
	}

	@:noCompletion private function __clone():ColorTransform
	{
		var output = new ColorTransform();
		output.__copyFromFlightColorScaleBias(Materials.cloneColorScaleBias(__toFlightColorScaleBias()));
		return output;
	}

	@:noCompletion private function __copyFrom(ct:ColorTransform):Void
	{
		var value = __toFlightColorScaleBias();
		Materials.copyColorScaleBias(value, ct.__toFlightColorScaleBias());
		__copyFromFlightColorScaleBias(value);
	}

	@:noCompletion private function __combine(ct:ColorTransform):Void
	{
		redMultiplier *= ct.redMultiplier;
		greenMultiplier *= ct.greenMultiplier;
		blueMultiplier *= ct.blueMultiplier;
		alphaMultiplier *= ct.alphaMultiplier;

		redOffset += ct.redOffset;
		greenOffset += ct.greenOffset;
		blueOffset += ct.blueOffset;
		alphaOffset += ct.alphaOffset;
	}

	@:noCompletion private function __identity():Void
	{
		var value = __toFlightColorScaleBias();
		Materials.setColorScaleBiasIdentity(value);
		__copyFromFlightColorScaleBias(value);
	}

	@:noCompletion private function __invert():Void
	{
		var value = __toFlightColorScaleBias();
		Materials.invertColorScaleBias(value, value);
		__copyFromFlightColorScaleBias(value);
	}

	@:noCompletion private function __equals(ct:ColorTransform, ignoreAlphaMultiplier:Bool):Bool
	{
		if (ct == null) return false;
		var value = __toFlightColorScaleBias();
		var other = ct.__toFlightColorScaleBias();
		return Materials.equalsColorScaleBiasBiases(value, other)
			&& Materials.equalsColorScaleBiasScales(value, other, !ignoreAlphaMultiplier);
	}

	@:noCompletion private function __isDefault(ignoreAlphaMultiplier:Bool):Bool
	{
		return Materials.isIdentityColorScaleBias(__toFlightColorScaleBias(), !ignoreAlphaMultiplier);
	}

	@:noCompletion private function __setArrays(colorMultipliers:Array<Float>, colorOffsets:Array<Float>):Void
	{
		Materials.copyColorScaleBiasToArrays(colorMultipliers, colorOffsets, __toFlightColorScaleBias());
	}

	// Getters & Setters
	@:noCompletion private function get_color():Int
	{
		return ((Std.int(redOffset) << 16) | (Std.int(greenOffset) << 8) | Std.int(blueOffset));
	}

	@:noCompletion private function set_color(value:Int):Int
	{
		var flightValue = __toFlightColorScaleBias();
		Materials.setColorScaleBiasBiasRgb(flightValue, value);
		redOffset = Math.round(flightValue.redBias * 255);
		greenOffset = Math.round(flightValue.greenBias * 255);
		blueOffset = Math.round(flightValue.blueBias * 255);
		redMultiplier = flightValue.redScale;
		greenMultiplier = flightValue.greenScale;
		blueMultiplier = flightValue.blueScale;

		return color;
	}

	@:noCompletion private function __copyFromFlightColorScaleBias(value:ColorScaleBias):Void
	{
		redMultiplier = value.redScale;
		greenMultiplier = value.greenScale;
		blueMultiplier = value.blueScale;
		alphaMultiplier = value.alphaScale;
		redOffset = value.redBias;
		greenOffset = value.greenBias;
		blueOffset = value.blueBias;
		alphaOffset = value.alphaBias;
	}

	@:noCompletion private function __toFlightColorScaleBias():ColorScaleBias
	{
		return Materials.createColorScaleBias({
			redScale: redMultiplier,
			greenScale: greenMultiplier,
			blueScale: blueMultiplier,
			alphaScale: alphaMultiplier,
			redBias: redOffset,
			greenBias: greenOffset,
			blueBias: blueOffset,
			alphaBias: alphaOffset
		});
	}
}
#else
typedef ColorTransform = flash.geom.ColorTransform;
#end
