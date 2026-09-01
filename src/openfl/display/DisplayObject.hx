package openfl.display;

#if !flash
import flight.Geometry as FlightGeometry;
import flight.Interaction as FlightInteraction;
import flight.Node as FlightNode;
import flight.Scene2D as FlightScene2D;
import flight.types.Node2D as FlightNode2D;
import openfl.errors.TypeError;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.EventPhase;
import openfl.events.EventType;
import openfl.events.MouseEvent;
import openfl.events.TouchEvent;
import openfl.filters.BitmapFilter;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.geom.Transform;

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:access(openfl.display.DisplayObjectContainer)
@:access(openfl.display.Graphics)
@:access(openfl.display.Stage)
@:access(openfl.events.Event)
@:access(openfl.events.EventDispatcher)
@:access(openfl.geom.Transform)
class DisplayObject extends EventDispatcher implements IBitmapDrawable #if (openfl_dynamic && haxe_ver < "4.0.0") implements Dynamic<DisplayObject> #end
{
	@:noCompletion private static var __broadcastEvents:Map<String, Array<DisplayObject>> = new Map();
	@:noCompletion private static var __initStage:Stage;
	@:noCompletion private static var __instanceCount:Int = 0;

	/**
		Indicates the alpha transparency value of the object specified. Valid
		values are 0 (fully transparent) to 1 (fully opaque). The default value is 1.
		Display objects with `alpha` set to 0 _are_ active, even though they are invisible.

		@see [Fading objects](https://books.openfl.org/openfl-developers-guide/display-programming/manipulating-display-objects/fading-objects.html)
	**/
	@:keep public var alpha(get, set):Float;
	/**
		A value from the BlendMode class that specifies which blend mode to use. A
		bitmap can be drawn internally in two ways. If you have a blend mode
		enabled or an external clipping mask, the bitmap is drawn by adding a
		bitmap-filled square shape to the vector render. If you attempt to set
		this property to an invalid value, Flash runtimes set the value to
		`BlendMode.NORMAL`.

		The `blendMode` property affects each pixel of the display
		object. Each pixel is composed of three constituent colors(red, green,
		and blue), and each constituent color has a value between 0x00 and 0xFF.
		Flash Player or Adobe AIR compares each constituent color of one pixel in
		the movie clip with the corresponding color of the pixel in the
		background. For example, if `blendMode` is set to
		`BlendMode.LIGHTEN`, Flash Player or Adobe AIR compares the red
		value of the display object with the red value of the background, and uses
		the lighter of the two as the value for the red component of the displayed
		color.

		The following table describes the `blendMode` settings. The
		BlendMode class defines string values you can use. The illustrations in
		the table show `blendMode` values applied to a circular display
		object (2) superimposed on another display object (1).

		![Square Number 1](/images/blendMode-0a.jpg)  ![Circle Number 2](/images/blendMode-0b.jpg)

		| BlendMode Constant | Illustration | Description |
		| --- | --- | --- |
		| `BlendMode.NORMAL` | ![blend mode NORMAL](/images/blendMode-1.jpg) | The display object appears in front of the background. Pixel values of the display object override those of the background. Where the display object is transparent, the background is visible. |
		| `BlendMode.LAYER` | ![blend mode LAYER](/images/blendMode-2.jpg) | Forces the creation of a transparency group for the display object. This means that the display object is pre-composed in a temporary buffer before it is processed further. This is done automatically if the display object is pre-cached using bitmap caching or if the display object is a display object container with at least one child object with a `blendMode` setting other than `BlendMode.NORMAL`. Not supported under GPU rendering. |
		| `BlendMode.MULTIPLY` | ![blend mode MULTIPLY](/images/blendMode-3.jpg) | Multiplies the values of the display object constituent colors by the colors of the background color, and then normalizes by dividing by 0xFF, resulting in darker colors. This setting is commonly used for shadows and depth effects.<br>For example, if a constituent color (such as red) of one pixel in the display object and the corresponding color of the pixel in the background both have the value 0x88, the multiplied result is 0x4840. Dividing by 0xFF yields a value of 0x48 for that constituent color, which is a darker shade than the color of the display object or the color of the background. |
		| `BlendMode.SCREEN` | ![blend mode SCREEN](/images/blendMode-4.jpg) | Multiplies the complement (inverse) of the display object color by the complement of the background color, resulting in a bleaching effect. This setting is commonly used for highlights or to remove black areas of the display object. |
		| `BlendMode.LIGHTEN` | ![blend mode LIGHTEN](/images/blendMode-5.jpg) | Selects the lighter of the constituent colors of the display object and the color of the background (the colors with the larger values). This setting is commonly used for superimposing type.<br>For example, if the display object has a pixel with an RGB value of 0xFFCC33, and the background pixel has an RGB value of 0xDDF800, the resulting RGB value for the displayed pixel is 0xFFF833 (because 0xFF > 0xDD, 0xCC < 0xF8, and 0x33 > 0x00 = 33). Not supported under GPU rendering. |
		| `BlendMode.DARKEN` | ![blend mode DARKEN](/images/blendMode-6.jpg) | Selects the darker of the constituent colors of the display object and the colors of the background (the colors with the smaller values). This setting is commonly used for superimposing type.<br>For example, if the display object has a pixel with an RGB value of 0xFFCC33, and the background pixel has an RGB value of 0xDDF800, the resulting RGB value for the displayed pixel is 0xDDCC00 (because 0xFF > 0xDD, 0xCC < 0xF8, and 0x33 > 0x00 = 33). Not supported under GPU rendering. |
		| `BlendMode.DIFFERENCE` | ![blend mode DIFFERENCE](/images/blendMode-7.jpg) | Compares the constituent colors of the display object with the colors of its background, and subtracts the darker of the values of the two constituent colors from the lighter value. This setting is commonly used for more vibrant colors.<br>For example, if the display object has a pixel with an RGB value of 0xFFCC33, and the background pixel has an RGB value of 0xDDF800, the resulting RGB value for the displayed pixel is 0x222C33 (because 0xFF - 0xDD = 0x22, 0xF8 - 0xCC = 0x2C, and 0x33 - 0x00 = 0x33). |
		| `BlendMode.ADD` | ![blend mode ADD](/images/blendMode-8.jpg) | Adds the values of the constituent colors of the display object to the colors of its background, applying a ceiling of 0xFF. This setting is commonly used for animating a lightening dissolve between two objects.<br>For example, if the display object has a pixel with an RGB value of 0xAAA633, and the background pixel has an RGB value of 0xDD2200, the resulting RGB value for the displayed pixel is 0xFFC833 (because 0xAA + 0xDD > 0xFF, 0xA6 + 0x22 = 0xC8, and 0x33 + 0x00 = 0x33). |
		| `BlendMode.SUBTRACT` | ![blend mode SUBTRACT](/images/blendMode-9.jpg) | Subtracts the values of the constituent colors in the display object from the values of the background color, applying a floor of 0. This setting is commonly used for animating a darkening dissolve between two objects.<br>For example, if the display object has a pixel with an RGB value of 0xAA2233, and the background pixel has an RGB value of 0xDDA600, the resulting RGB value for the displayed pixel is 0x338400 (because 0xDD - 0xAA = 0x33, 0xA6 - 0x22 = 0x84, and 0x00 - 0x33 < 0x00). |
		| `BlendMode.INVERT` | ![blend mode INVERT](/images/blendMode-10.jpg) | Inverts the background. |
		| `BlendMode.ALPHA` | ![blend mode ALPHA](/images/blendMode-11.jpg) | Applies the alpha value of each pixel of the display object to the background. This requires the `blendMode` setting of the parent display object to be set to `BlendMode.LAYER`. For example, in the illustration, the parent display object, which is a white background, has `blendMode = BlendMode.LAYER`. Not supported under GPU rendering. |
		| `BlendMode.ERASE` | ![blend mode ERASE](/images/blendMode-12.jpg) | Erases the background based on the alpha value of the display object. This requires the `blendMode` of the parent display object to be set to `BlendMode.LAYER`. For example, in the illustration, the parent display object, which is a white background, has `blendMode = BlendMode.LAYER`. Not supported under GPU rendering. |
		| `BlendMode.OVERLAY` | ![blend mode OVERLAY](/images/blendMode-13.jpg) | Adjusts the color of each pixel based on the darkness of the background. If the background is lighter than 50% gray, the display object and background colors are screened, which results in a lighter color. If the background is darker than 50% gray, the colors are multiplied, which results in a darker color. This setting is commonly used for shading effects. Not supported under GPU rendering. |
		| `BlendMode.HARDLIGHT` | ![blend mode HARDLIGHT](/images/blendMode-14.jpg) | Adjusts the color of each pixel based on the darkness of the display object. If the display object is lighter than 50% gray, the display object and background colors are screened, which results in a lighter color. If the display object is darker than 50% gray, the colors are multiplied, which results in a darker color. This setting is commonly used for shading effects. Not supported under GPU rendering. |
		| `BlendMode.SHADER` | N/A | Adjusts the color using a custom shader routine. The shader that is used is specified as the Shader instance assigned to the blendShader property. Setting the blendShader property of a display object to a Shader instance automatically sets the display object's `blendMode` property to `BlendMode.SHADER`. If the `blendMode` property is set to `BlendMode.SHADER` without first setting the `blendShader` property, the `blendMode` property is set to `BlendMode.NORMAL`. Not supported under GPU rendering. |

		@see [Applying blending modes](https://books.openfl.org/openfl-developers-guide/display-programming/manipulating-display-objects/applying-blending-modes.html)
	**/
	public var blendMode(get, set):BlendMode;
	/**
		All vector data for a display object that has a cached bitmap is drawn
		to the bitmap instead of the main display. If
		`cacheAsBitmapMatrix` is null or unsupported, the bitmap is
		then copied to the main display as unstretched, unrotated pixels snapped
		to the nearest pixel boundaries. Pixels are mapped 1 to 1 with the parent
		object. If the bounds of the bitmap change, the bitmap is recreated
		instead of being stretched.

		If `cacheAsBitmapMatrix` is non-null and supported, the
		object is drawn to the off-screen bitmap using that matrix and the
		stretched and/or rotated results of that rendering are used to draw the
		object to the main display.

		No internal bitmap is created unless the `cacheAsBitmap`
		property is set to `true`.

		After you set the `cacheAsBitmap` property to
		`true`, the rendering does not change, however the display
		object performs pixel snapping automatically. The animation speed can be
		significantly faster depending on the complexity of the vector content.

		The `cacheAsBitmap` property is automatically set to
		`true` whenever you apply a filter to a display object (when
		its `filter` array is not empty), and if a display object has a
		filter applied to it, `cacheAsBitmap` is reported as
		`true` for that display object, even if you set the property to
		`false`. If you clear all filters for a display object, the
		`cacheAsBitmap` setting changes to what it was last set to.

		A display object does not use a bitmap even if the
		`cacheAsBitmap` property is set to `true` and
		instead renders from vector data in the following cases:

		* The bitmap is too large. In AIR 1.5 and Flash Player 10, the maximum
		size for a bitmap image is 8,191 pixels in width or height, and the total
		number of pixels cannot exceed 16,777,215 pixels.(So, if a bitmap image
		is 8,191 pixels wide, it can only be 2,048 pixels high.) In Flash Player 9
		and earlier, the limitation is is 2880 pixels in height and 2,880 pixels
		in width.
		*  The bitmap fails to allocate (out of memory error).

		The `cacheAsBitmap` property is best used with movie clips
		that have mostly static content and that do not scale and rotate
		frequently. With such movie clips, `cacheAsBitmap` can lead to
		performance increases when the movie clip is translated (when its _x_
		and _y_ position is changed).

		@see [Caching display objects](https://books.openfl.org/openfl-developers-guide/display-programming/manipulating-display-objects/caching-display-objects.html)
	**/
	public var cacheAsBitmap(get, set):Bool;
	/**
		If non-null, this Matrix object defines how a display object is rendered when `cacheAsBitmap` is set to
		`true`. The application uses this matrix as a transformation matrix that is applied when rendering the
		bitmap version of the display object.

		_Adobe AIR profile support:_ This feature is supported on mobile devices, but it is not supported on desktop
		operating systems. It also has limited support on AIR for TV devices. Specifically, on AIR for TV devices,
		supported transformations include scaling and translation, but not rotation and skewing. See
		[AIR Profile Support](http://help.adobe.com/en_US/air/build/WS144092a96ffef7cc16ddeea2126bb46b82f-8000.html)
		for more information regarding API support across multiple profiles.

		With `cacheAsBitmapMatrix` set, the application retains a cached bitmap image across various 2D
		transformations, including translation, rotation, and scaling. If the application uses hardware acceleration,
		the object will be stored in video memory as a texture. This allows the GPU to apply the supported
		transformations to the object. The GPU can perform these transformations faster than the CPU.

		To use the hardware acceleration, set Rendering to GPU in the General tab of the iPhone Settings dialog box
		in Flash Professional CS5. Or set the `renderMode` property to gpu in the application descriptor file. Note
		that AIR for TV devices automatically use hardware acceleration if it is available.

		For example, the following code sends an untransformed bitmap representation of the display object to the GPU:

		```haxe
		var matrix:Matrix = new Matrix(); // creates an identity matrix
		mySprite.cacheAsBitmapMatrix = matrix;
		mySprite.cacheAsBitmap = true;
		```

		Usually, the identity matrix (`new Matrix()`) suffices. However, you can use another matrix, such as a
		scaled-down matrix, to upload a different bitmap to the GPU. For example, the following example applies a
		`cacheAsBitmapMatrix` matrix that is scaled by 0.5 on the x and y axes. The bitmap object that the GPU uses
		is smaller, however the GPU adjusts its size to match the `transform.matrix` property of the display object:

		```haxe
		var matrix:Matrix = new Matrix(); // creates an identity matrix
		matrix.scale(0.5, 0.5); // scales the matrix
		mySprite.cacheAsBitmapMatrix = matrix;
		mySprite.cacheAsBitmap = true;
		```

		Generally, you should choose to use a matrix that transforms the display object to the size that it will
		appear in the application. For example, if your application displays the bitmap version of the sprite scaled
		down by a half, use a matrix that scales down by a half. If you application will display the sprite larger
		than its current dimensions, use a matrix that scales up by that factor.

		**Note:** The `cacheAsBitmapMatrix` property is suitable for 2D transformations. If you need to apply
		transformations in 3D, you may do so by setting a 3D property of the object and manipulating its
		`transform.matrix3D` property. If the application is packaged using GPU mode, this allows the 3D transforms
		to be applied to the object by the GPU. The `cacheAsBitmapMatrix` is ignored for 3D objects.

		@see [Caching display objects](https://books.openfl.org/openfl-developers-guide/display-programming/manipulating-display-objects/caching-display-objects.html)
	**/
	public var cacheAsBitmapMatrix(get, set):Matrix;
	/**
		An indexed array that contains each filter object currently associated
		with the display object. The openfl.filters package contains several
		classes that define specific filters you can use.

		Filters can be applied in Flash Professional at design time, or at run
		time by using Haxe code. To apply a filter by using Haxe,
		you must make a temporary copy of the entire `filters` array,
		modify the temporary array, then assign the value of the temporary array
		back to the `filters` array. You cannot directly add a new
		filter object to the `filters` array.

		To add a filter by using Haxe, perform the following steps
		(assume that the target display object is named
		`myDisplayObject`):

		 1. Create a new filter object by using the constructor method of your
		chosen filter class.
		 2. Assign the value of the `myDisplayObject.filters` array
		to a temporary array, such as one named `myFilters`.
		 3. Add the new filter object to the `myFilters` temporary
		array.
		 4. Assign the value of the temporary array to the
		`myDisplayObject.filters` array.

		If the `filters` array is undefined, you do not need to use
		a temporary array. Instead, you can directly assign an array literal that
		contains one or more filter objects that you create. The first example in
		the Examples section adds a drop shadow filter by using code that handles
		both defined and undefined `filters` arrays.

		To modify an existing filter object, you must use the technique of
		modifying a copy of the `filters` array:

		 1. Assign the value of the `filters` array to a temporary
		array, such as one named `myFilters`.
		 2. Modify the property by using the temporary array,
		`myFilters`. For example, to set the quality property of the
		first filter in the array, you could use the following code:
		`myFilters[0].quality = 1;`
		 3. Assign the value of the temporary array to the `filters`
		array.

		At load time, if a display object has an associated filter, it is
		marked to cache itself as a transparent bitmap. From this point forward,
		as long as the display object has a valid filter list, the player caches
		the display object as a bitmap. This source bitmap is used as a source
		image for the filter effects. Each display object usually has two bitmaps:
		one with the original unfiltered source display object and another for the
		final image after filtering. The final image is used when rendering. As
		long as the display object does not change, the final image does not need
		updating.

		The openfl.filters package includes classes for filters. For example, to
		create a DropShadow filter, you would write:

		@throws ArgumentError When `filters` includes a ShaderFilter
							  and the shader output type is not compatible with
							  this operation (the shader must specify a
							  `pixel4` output).
		@throws ArgumentError When `filters` includes a ShaderFilter
							  and the shader doesn't specify any image input or
							  the first input is not an `image4` input.
		@throws ArgumentError When `filters` includes a ShaderFilter
							  and the shader specifies an image input that isn't
							  provided.
		@throws ArgumentError When `filters` includes a ShaderFilter, a
							  ByteArray or Vector<Float> instance as a shader
							  input, and the `width` and
							  `height` properties aren't specified for
							  the ShaderInput object, or the specified values
							  don't match the amount of data in the input data.
							  See the `ShaderInput.input` property for
							  more information.
	**/
	public var filters(get, set):Array<BitmapFilter>;
	/**
		Indicates the height of the display object, in pixels. The height is
		calculated based on the bounds of the content of the display object. When
		you set the `height` property, the `scaleY` property
		is adjusted accordingly, as shown in the following code:

		Except for TextField and Video objects, a display object with no
		content (such as an empty sprite) has a height of 0, even if you try to
		set `height` to a different value.

		@see [Manipulating size and scaling objects](https://books.openfl.org/openfl-developers-guide/display-programming/manipulating-display-objects/manipulating-size-and-scaling-objects.html)
	**/
	@:keep public var height(get, set):Float;
	/**
		Returns a LoaderInfo object containing information about loading the file
		to which this display object belongs. The `loaderInfo` property
		is defined only for the root display object of a SWF file or for a loaded
		Bitmap (not for a Bitmap that is drawn with Haxe). To find the
		`loaderInfo` object associated with the SWF file that contains
		a display object named `myDisplayObject`, use
		`myDisplayObject.root.loaderInfo`.

		A large SWF file can monitor its download by calling
		`this.root.loaderInfo.addEventListener(Event.COMPLETE,
		func)`.
	**/
	public var loaderInfo(get, never):LoaderInfo;
	/**
		The calling display object is masked by the specified `mask`
		object. To ensure that masking works when the Stage is scaled, the
		`mask` display object must be in an active part of the display
		list. The `mask` object itself is not drawn. Set
		`mask` to `null` to remove the mask.

		To be able to scale a mask object, it must be on the display list. To
		be able to drag a mask Sprite object (by calling its
		`startDrag()` method), it must be on the display list. To call
		the `startDrag()` method for a mask sprite based on a
		`mouseDown` event being dispatched by the sprite, set the
		sprite's `buttonMode` property to `true`.

		When display objects are cached by setting the
		`cacheAsBitmap` property to `true` an the
		`cacheAsBitmapMatrix` property to a Matrix object, both the
		mask and the display object being masked must be part of the same cached
		bitmap. Thus, if the display object is cached, then the mask must be a
		child of the display object. If an ancestor of the display object on the
		display list is cached, then the mask must be a child of that ancestor or
		one of its descendents. If more than one ancestor of the masked object is
		cached, then the mask must be a descendent of the cached container closest
		to the masked object in the display list.

		**Note:** A single `mask` object cannot be used to mask
		more than one calling display object. When the `mask` is
		assigned to a second display object, it is removed as the mask of the
		first object, and that object's `mask` property becomes
		`null`.

		@see [Masking display objects](https://books.openfl.org/openfl-developers-guide/display-programming/manipulating-display-objects/masking-display-objects.html)
	**/
	public var mask(get, set):DisplayObject;
	/**
		Obtains the meta data object of the DisplayObject instance if meta data
		was stored alongside the the instance of this DisplayObject in the SWF
		file through a PlaceObject4 tag.
	**/
	public var metaData(get, set):Dynamic;
	/**
		Indicates the x coordinate of the mouse or user input device position, in
		pixels.

		**Note**: For a DisplayObject that has been rotated, the returned x
		coordinate will reflect the non-rotated object.

		@see [Capturing mouse input](https://books.openfl.org/openfl-developers-guide/mouse-input/capturing-mouse-input.html)
	**/
	public var mouseX(get, never):Float;
	/**
		Indicates the y coordinate of the mouse or user input device position, in
		pixels.

		**Note**: For a DisplayObject that has been rotated, the returned y
		coordinate will reflect the non-rotated object.

		@see [Capturing mouse input](https://books.openfl.org/openfl-developers-guide/mouse-input/capturing-mouse-input.html)
	**/
	public var mouseY(get, never):Float;
	/**
		Indicates the instance name of the DisplayObject. The object can be
		identified in the child list of its parent display object container by
		calling the `getChildByName()` method of the display object
		container.

		@throws IllegalOperationError If you are attempting to set this property
									  on an object that was placed on the timeline
									  in the Flash authoring tool.
	**/
	public var name(get, set):String;
	/**
		Specifies whether the display object is opaque with a certain background
		color. A transparent bitmap contains alpha channel data and is drawn
		transparently. An opaque bitmap has no alpha channel (and renders faster
		than a transparent bitmap). If the bitmap is opaque, you specify its own
		background color to use.

		If set to a number value, the surface is opaque (not transparent) with
		the RGB background color that the number specifies. If set to
		`null`(the default value), the display object has a
		transparent background.

		The `opaqueBackground` property is intended mainly for use
		with the `cacheAsBitmap` property, for rendering optimization.
		For display objects in which the `cacheAsBitmap` property is
		set to true, setting `opaqueBackground` can improve rendering
		performance.

		The opaque background region is _not_ matched when calling the
		`hitTestPoint()` method with the `shapeFlag`
		parameter set to `true`.

		The opaque background region does not respond to mouse events.

		@see [Setting an opaque background](https://books.openfl.org/openfl-developers-guide/display-programming/manipulating-display-objects/setting-an-opaque-background.html)
	**/
	public var opaqueBackground:Null<Int>;
	/**
		Indicates the DisplayObjectContainer object that contains this display
		object. Use the `parent` property to specify a relative path to
		display objects that are above the current display object in the display
		list hierarchy.

		You can use `parent` to move up multiple levels in the
		display list as in the following:

		```haxe
		this.parent.parent.alpha = 20;
		```

		@throws SecurityError The parent display object belongs to a security
							  sandbox to which you do not have access. You can
							  avoid this situation by having the parent movie call
							  the `Security.allowDomain()` method.

		@see [Traversing the display list](https://books.openfl.org/openfl-developers-guide/display-programming/working-with-display-objects/traversing-the-display-list.html)
	**/
	public var parent(default, null):DisplayObjectContainer;
	/**
		For a display object in a loaded SWF file, the `root` property
		is the top-most display object in the portion of the display list's tree
		structure represented by that SWF file. For a Bitmap object representing a
		loaded image file, the `root` property is the Bitmap object
		itself. For the instance of the main class of the first SWF file loaded,
		the `root` property is the display object itself. The
		`root` property of the Stage object is the Stage object itself.
		The `root` property is set to `null` for any display
		object that has not been added to the display list, unless it has been
		added to a display object container that is off the display list but that
		is a child of the top-most display object in a loaded SWF file.

		For example, if you create a new Sprite object by calling the
		`Sprite()` constructor method, its `root` property
		is `null` until you add it to the display list (or to a display
		object container that is off the display list but that is a child of the
		top-most display object in a SWF file).

		For a loaded SWF file, even though the Loader object used to load the
		file may not be on the display list, the top-most display object in the
		SWF file has its `root` property set to itself. The Loader
		object does not have its `root` property set until it is added
		as a child of a display object for which the `root` property is
		set.

		@see [Traversing the display list](https://books.openfl.org/openfl-developers-guide/display-programming/working-with-display-objects/traversing-the-display-list.html)
	**/
	public var root(get, never):DisplayObject;
	/**
		Indicates the rotation of the DisplayObject instance, in degrees, from its
		original orientation. Values from 0 to 180 represent clockwise rotation;
		values from 0 to -180 represent counterclockwise rotation. Values outside
		this range are added to or subtracted from 360 to obtain a value within
		the range. For example, the statement `my_video.rotation = 450`
		is the same as ` my_video.rotation = 90`.

		@see [Rotating objects](https://books.openfl.org/openfl-developers-guide/display-programming/manipulating-display-objects/rotating-objects.html)
	**/
	@:keep public var rotation(get, set):Float;
	/**
		The current scaling grid that is in effect. If set to `null`,
		the entire display object is scaled normally when any scale transformation
		is applied.

		When you define the `scale9Grid` property, the display
		object is divided into a grid with nine regions based on the
		`scale9Grid` rectangle, which defines the center region of the
		grid. The eight other regions of the grid are the following areas:

		* The upper-left corner outside of the rectangle
		* The area above the rectangle
		* The upper-right corner outside of the rectangle
		* The area to the left of the rectangle
		* The area to the right of the rectangle
		* The lower-left corner outside of the rectangle
		* The area below the rectangle
		* The lower-right corner outside of the rectangle

		You can think of the eight regions outside of the center (defined by
		the rectangle) as being like a picture frame that has special rules
		applied to it when scaled.

		**Note:** Content that is not rendered through the `graphics` interface
		of a display object will not be affected by the `scale9Grid` property.

		When the `scale9Grid` property is set and a display object
		is scaled, all text and gradients are scaled normally; however, for other
		types of objects the following rules apply:

		* Content in the center region is scaled normally.
		* Content in the corners is not scaled.
		* Content in the top and bottom regions is scaled horizontally only.
		* Content in the left and right regions is scaled vertically only.
		* All fills (including bitmaps, video, and gradients) are stretched to
		fit their shapes.

		If a display object is rotated, all subsequent scaling is normal (and
		the `scale9Grid` property is ignored).

		For example, consider the following display object and a rectangle that
		is applied as the display object's `scale9Grid`:

		| | |
		| --- | --- |
		| ![display object image](/images/scale9Grid-a.jpg)<br>The display object. | ![display object scale 9 region](/images/scale9Grid-b.jpg)<br>The red rectangle shows the scale9Grid. |

		When the display object is scaled or stretched, the objects within the rectangle scale normally, but the
		objects outside of the rectangle scale according to the `scale9Grid` rules:

		| | |
		| --- | --- |
		| Scaled to 75%: | ![display object at 75%](/images/scale9Grid-c.jpg) |
		| Scaled to 50%: | ![display object at 50%](/images/scale9Grid-d.jpg) |
		| Scaled to 25%: | ![display object at 25%](/images/scale9Grid-e.jpg) |
		| Stretched horizontally 150%: | ![display stretched 150%](/images/scale9Grid-f.jpg) |

		A common use for setting `scale9Grid` is to set up a display
		object to be used as a component, in which edge regions retain the same
		width when the component is scaled.

		@throws ArgumentError If you pass an invalid argument to the method.
	**/
	public var scale9Grid(get, set):Rectangle;
	/**
		Indicates the horizontal scale (percentage) of the object as applied from
		the registration point. The default registration point is (0,0). 1.0
		equals 100% scale.

		Scaling the local coordinate system changes the `x` and
		`y` property values, which are defined in whole pixels.

		@see [Manipulating size and scaling objects](https://books.openfl.org/openfl-developers-guide/display-programming/manipulating-display-objects/manipulating-size-and-scaling-objects.html)
	**/
	@:keep public var scaleX(get, set):Float;
	/**
		Indicates the vertical scale (percentage) of an object as applied from the
		registration point of the object. The default registration point is (0,0).
		1.0 is 100% scale.

		Scaling the local coordinate system changes the `x` and
		`y` property values, which are defined in whole pixels.

		@see [Manipulating size and scaling objects](https://books.openfl.org/openfl-developers-guide/display-programming/manipulating-display-objects/manipulating-size-and-scaling-objects.html)
	**/
	@:keep public var scaleY(get, set):Float;
	/**
		The scroll rectangle bounds of the display object. The display object is
		cropped to the size defined by the rectangle, and it scrolls within the
		rectangle when you change the `x` and `y` properties
		of the `scrollRect` object.

		The properties of the `scrollRect` Rectangle object use the
		display object's coordinate space and are scaled just like the overall
		display object. The corner bounds of the cropped window on the scrolling
		display object are the origin of the display object (0,0) and the point
		defined by the width and height of the rectangle. They are not centered
		around the origin, but use the origin to define the upper-left corner of
		the area. A scrolled display object always scrolls in whole pixel
		increments.

		You can scroll an object left and right by setting the `x`
		property of the `scrollRect` Rectangle object. You can scroll
		an object up and down by setting the `y` property of the
		`scrollRect` Rectangle object. If the display object is rotated
		90° and you scroll it left and right, the display object actually scrolls
		up and down.

		@see [Panning and scrolling display objects](https://books.openfl.org/openfl-developers-guide/display-programming/manipulating-display-objects/panning-and-scrolling-display-objects.html)
	**/
	public var scrollRect(get, set):Rectangle;
	/**
		**BETA**

		Applies a custom Shader object to use when rendering this display object (or its children) when using
		hardware rendering. This occurs as a single-pass render on this object only, if visible. In order to
		apply a post-process effect to multiple display objects at once, enable `cacheAsBitmap` or use the
		`filters` property with a ShaderFilter
	**/
	@:beta public var shader(get, set):Shader;
	/**
		The Stage of the display object. A Flash runtime application has only one
		Stage object. For example, you can create and load multiple display
		objects into the display list, and the `stage` property of each
		display object refers to the same Stage object (even if the display object
		belongs to a loaded SWF file).

		If a display object is not added to the display list, its
		`stage` property is set to `null`.

		@see [Traversing the display list](https://books.openfl.org/openfl-developers-guide/display-programming/working-with-display-objects/traversing-the-display-list.html)
	**/
	public var stage(default, null):Stage;
	/**
		An object with properties pertaining to a display object's matrix, color
		transform, and pixel bounds. The specific properties — matrix,
		colorTransform, and three read-only properties
		(`concatenatedMatrix`, `concatenatedColorTransform`,
		and `pixelBounds`) — are described in the entry for the
		Transform class.

		Each of the transform object's properties is itself an object. This
		concept is important because the only way to set new values for the matrix
		or colorTransform objects is to create a new object and copy that object
		into the transform.matrix or transform.colorTransform property.

		For example, to increase the `tx` value of a display
		object's matrix, you must make a copy of the entire matrix object, then
		copy the new object into the matrix property of the transform object:
		` var myMatrix:Matrix =
		myDisplayObject.transform.matrix; myMatrix.tx += 10;
		myDisplayObject.transform.matrix = myMatrix; `

		You cannot directly set the `tx` property. The following
		code has no effect on `myDisplayObject`:
		` myDisplayObject.transform.matrix.tx +=
		10; `

		You can also copy an entire transform object and assign it to another
		display object's transform property. For example, the following code
		copies the entire transform object from `myOldDisplayObj` to
		`myNewDisplayObj`:
		`myNewDisplayObj.transform = myOldDisplayObj.transform;`

		The resulting display object, `myNewDisplayObj`, now has the
		same values for its matrix, color transform, and pixel bounds as the old
		display object, `myOldDisplayObj`.

		Note that AIR for TV devices use hardware acceleration, if it is
		available, for color transforms.
	**/
	@:keep public var transform(get, set):Transform;
	/**
		Whether or not the display object is visible. Display objects that are not
		visible are disabled. For example, if `visible=false` for an
		InteractiveObject instance, it cannot be clicked.
	**/
	public var visible(get, set):Bool;
	/**
		Indicates the width of the display object, in pixels. The width is
		calculated based on the bounds of the content of the display object. When
		you set the `width` property, the `scaleX` property
		is adjusted accordingly, as shown in the following code:

		Except for TextField and Video objects, a display object with no
		content (such as an empty sprite) has a width of 0, even if you try to set
		`width` to a different value.

		@see [Manipulating size and scaling objects](https://books.openfl.org/openfl-developers-guide/display-programming/manipulating-display-objects/manipulating-size-and-scaling-objects.html)
	**/
	@:keep public var width(get, set):Float;
	/**
		Indicates the _x_ coordinate of the DisplayObject instance relative
		to the local coordinates of the parent DisplayObjectContainer. If the
		object is inside a DisplayObjectContainer that has transformations, it is
		in the local coordinate system of the enclosing DisplayObjectContainer.
		Thus, for a DisplayObjectContainer rotated 90° counterclockwise, the
		DisplayObjectContainer's children inherit a coordinate system that is
		rotated 90° counterclockwise. The object's coordinates refer to the
		registration point position.

		@see [Changing position](https://books.openfl.org/openfl-developers-guide/display-programming/manipulating-display-objects/changing-position.html)
	**/
	@:keep public var x(get, set):Float;
	/**
		Indicates the _y_ coordinate of the DisplayObject instance relative
		to the local coordinates of the parent DisplayObjectContainer. If the
		object is inside a DisplayObjectContainer that has transformations, it is
		in the local coordinate system of the enclosing DisplayObjectContainer.
		Thus, for a DisplayObjectContainer rotated 90° counterclockwise, the
		DisplayObjectContainer's children inherit a coordinate system that is
		rotated 90° counterclockwise. The object's coordinates refer to the
		registration point position.

		@see [Changing position](https://books.openfl.org/openfl-developers-guide/display-programming/manipulating-display-objects/changing-position.html)
	**/
	@:keep public var y(get, set):Float;

	@:noCompletion private var __alpha:Float;
	@:noCompletion private var __blendMode:BlendMode;
	@:noCompletion private var __cacheAsBitmap:Bool;
	@:noCompletion private var __cacheAsBitmapMatrix:Matrix;
	@:noCompletion private var __children:Array<DisplayObject>;
	@:noCompletion private var __filters:Array<BitmapFilter>;
	@:noCompletion private var __flightNode:FlightNode2D;
	@:noCompletion private var __graphics:Graphics;
	@:noCompletion private var __loaderInfo:LoaderInfo;
	@:noCompletion private var __localBounds:Rectangle;
	@:noCompletion private var __mask:DisplayObject;
	@:noCompletion private var __maskTarget:DisplayObject;
	@:noCompletion private var __metaData:Dynamic;
	@:noCompletion private var __name:String;
	@:noCompletion private var __objectTransform:Transform;
	@:noCompletion private var __rotation:Float;
	@:noCompletion private var __rotationCosine:Float;
	@:noCompletion private var __rotationSine:Float;
	@:noCompletion private var __scale9Grid:Rectangle;
	@:noCompletion private var __scaleX:Float;
	@:noCompletion private var __scaleY:Float;
	@:noCompletion private var __scrollRect:Rectangle;
	@:noCompletion private var __shader:Shader;
	@:noCompletion private var __transform:Matrix;
	@:noCompletion private var __visible:Bool;

	@:noCompletion private function new()
	{
		super();

		__alpha = 1;
		__blendMode = BlendMode.NORMAL;
		__cacheAsBitmap = false;
		__localBounds = new Rectangle();
		__rotation = 0;
		__rotationCosine = 1;
		__rotationSine = 0;
		__scaleX = 1;
		__scaleY = 1;
		__transform = new Matrix();
		__visible = true;
		__flightNode = FlightScene2D.createSprite();
		name = "instance" + (++__instanceCount);
		__syncFlightNode();

		if (__initStage != null)
		{
			stage = __initStage;
			var targetStage = __initStage;
			__initStage = null;
			targetStage.addChild(this);
		}
	}

	@SuppressWarnings("checkstyle:Dynamic")
	public override function addEventListener<T>(type:EventType<T>, listener:T->Void, useCapture:Bool = false, priority:Int = 0,
		useWeakReference:Bool = false):Void
	{
		switch (type)
		{
			case Event.ACTIVATE, Event.DEACTIVATE, Event.ENTER_FRAME, Event.EXIT_FRAME, Event.FRAME_CONSTRUCTED, Event.RENDER:
				var dispatchers = __broadcastEvents.get(type);
				if (dispatchers == null)
				{
					dispatchers = [];
					__broadcastEvents.set(type, dispatchers);
				}
				if (dispatchers.indexOf(this) == -1) dispatchers.push(this);
			default:
		}
		super.addEventListener(type, listener, useCapture, priority, useWeakReference);
	}

	public override function dispatchEvent(event:Event):Bool
	{
		if (event == null) return false;
		if ((event is MouseEvent))
		{
			var mouseEvent:MouseEvent = cast event;
			var stagePoint = localToGlobal(new Point(mouseEvent.localX, mouseEvent.localY));
			mouseEvent.stageX = stagePoint.x;
			mouseEvent.stageY = stagePoint.y;
		}
		else if ((event is TouchEvent))
		{
			var touchEvent:TouchEvent = cast event;
			var stagePoint = localToGlobal(new Point(touchEvent.localX, touchEvent.localY));
			touchEvent.stageX = stagePoint.x;
			touchEvent.stageY = stagePoint.y;
		}

		event.target = this;
		return __dispatchWithCapture(event);
	}

	/**
		Returns a rectangle that defines the area of the display object relative
		to the coordinate system of the `targetCoordinateSpace` object.
		Consider the following code, which shows how the rectangle returned can
		vary depending on the `targetCoordinateSpace` parameter that
		you pass to the method:

		**Note:** Use the `localToGlobal()` and
		`globalToLocal()` methods to convert the display object's local
		coordinates to display coordinates, or display coordinates to local
		coordinates, respectively.

		The `getBounds()` method is similar to the
		`getRect()` method; however, the Rectangle returned by the
		`getBounds()` method includes any strokes on shapes, whereas
		the Rectangle returned by the `getRect()` method does not. For
		an example, see the description of the `getRect()` method.

		@param targetCoordinateSpace The display object that defines the
									 coordinate system to use.
		@return The rectangle that defines the area of the display object relative
				to the `targetCoordinateSpace` object's coordinate
				system.
	**/
	public function getBounds(targetCoordinateSpace:DisplayObject):Rectangle
	{
		var matrix = __getWorldTransform();
		if (targetCoordinateSpace != null)
		{
			var targetMatrix = targetCoordinateSpace.__getWorldTransform();
			targetMatrix.invert();
			matrix.concat(targetMatrix);
		}
		var bounds = new Rectangle();
		__getBounds(bounds, matrix);
		return bounds;
	}

	/**
		Returns a rectangle that defines the boundary of the display object, based
		on the coordinate system defined by the `targetCoordinateSpace`
		parameter, excluding any strokes on shapes. The values that the
		`getRect()` method returns are the same or smaller than those
		returned by the `getBounds()` method.

		**Note:** Use `localToGlobal()` and
		`globalToLocal()` methods to convert the display object's local
		coordinates to Stage coordinates, or Stage coordinates to local
		coordinates, respectively.

		@param targetCoordinateSpace The display object that defines the
									 coordinate system to use.
		@return The rectangle that defines the area of the display object relative
				to the `targetCoordinateSpace` object's coordinate
				system.
	**/
	public function getRect(targetCoordinateSpace:DisplayObject):Rectangle
	{
		var matrix = __getWorldTransform();
		if (targetCoordinateSpace != null)
		{
			var targetMatrix = targetCoordinateSpace.__getWorldTransform();
			targetMatrix.invert();
			matrix.concat(targetMatrix);
		}
		var bounds = new Rectangle();
		__getRect(bounds, matrix);
		return bounds;
	}

	/**
		Converts the `point` object from the Stage (global) coordinates
		to the display object's (local) coordinates.

		To use this method, first create an instance of the Point class. The
		_x_ and _y_ values that you assign represent global coordinates
		because they relate to the origin (0,0) of the main display area. Then
		pass the Point instance as the parameter to the
		`globalToLocal()` method. The method returns a new Point object
		with _x_ and _y_ values that relate to the origin of the display
		object instead of the origin of the Stage.

		@param point An object created with the Point class. The Point object
					 specifies the _x_ and _y_ coordinates as
					 properties.
		@return A Point object with coordinates relative to the display object.
	**/
	public function globalToLocal(pos:Point):Point
	{
		return __globalToLocal(pos, new Point());
	}

	/**
		Evaluates the bounding box of the display object to see if it overlaps or
		intersects with the bounding box of the `obj` display object.

		@param obj The display object to test against.
		@return `true` if the bounding boxes of the display objects
				intersect; `false` if not.
	**/
	public function hitTestObject(obj:DisplayObject):Bool
	{
		if (obj == null) return false;
		if (__hasFlightBoundsContent() && obj.__hasFlightBoundsContent())
		{
			var overlap = FlightGeometry.createRectangle();
			FlightInteraction.getNode2DOverlapRectangle(__flightNode, obj.__flightNode, overlap);
			return overlap.width > 0 && overlap.height > 0;
		}
		return getBounds(null).intersects(obj.getBounds(null));
	}

	/**
		Evaluates the display object to see if it overlaps or intersects with the
		point specified by the `x` and `y` parameters. The
		`x` and `y` parameters specify a point in the
		coordinate space of the Stage, not the display object container that
		contains the display object (unless that display object container is the
		Stage).

		@param x         The _x_ coordinate to test against this object.
		@param y         The _y_ coordinate to test against this object.
		@param shapeFlag Whether to check against the actual pixels of the object
						(`true`) or the bounding box
						(`false`).
		@return `true` if the display object overlaps or intersects
				with the specified point; `false` otherwise.
	**/
	public function hitTestPoint(x:Float, y:Float, shapeFlag:Bool = false):Bool
	{
		if (!shapeFlag) return getBounds(null).contains(x, y);
		return __hitTest(x, y, true);
	}

	/**
		Calling the `invalidate()` method signals to have the current object
		redrawn the next time the object is eligible to be rendered.
	**/
	public function invalidate():Void
	{
		if (stage != null) stage.__invalidated = true;
	}

	/**
		Converts the `point` object from the display object's (local)
		coordinates to the Stage (global) coordinates.

		This method allows you to convert any given _x_ and _y_
		coordinates from values that are relative to the origin (0,0) of a
		specific display object (local coordinates) to values that are relative to
		the origin of the Stage (global coordinates).

		To use this method, first create an instance of the Point class. The
		_x_ and _y_ values that you assign represent local coordinates
		because they relate to the origin of the display object.

		You then pass the Point instance that you created as the parameter to
		the `localToGlobal()` method. The method returns a new Point
		object with _x_ and _y_ values that relate to the origin of the
		Stage instead of the origin of the display object.

		@param point The name or identifier of a point created with the Point
					 class, specifying the _x_ and _y_ coordinates as
					 properties.
		@return A Point object with coordinates relative to the Stage.
	**/
	public function localToGlobal(point:Point):Point
	{
		var result = new Point();
		FlightNode.convertNodeVector2LocalToGlobal(cast result, __flightNode, cast point);
		return result;
	}

	@SuppressWarnings("checkstyle:Dynamic")
	public override function removeEventListener<T>(type:EventType<T>, listener:T->Void, useCapture:Bool = false):Void
	{
		super.removeEventListener(type, listener, useCapture);
		switch (type)
		{
			case Event.ACTIVATE, Event.DEACTIVATE, Event.ENTER_FRAME, Event.EXIT_FRAME, Event.FRAME_CONSTRUCTED, Event.RENDER:
				if (!hasEventListener(type))
				{
					var dispatchers = __broadcastEvents.get(type);
					if (dispatchers != null) dispatchers.remove(this);
				}
			default:
		}
	}

	@:noCompletion private function __dispatch(event:Event):Bool
	{
		if (hasEventListener(event.type))
		{
			var result = super.__dispatchEvent(event);
			if (event.__isCanceled) return true;
			return result;
		}
		return true;
	}

	@:noCompletion private function __dispatchChildren(event:Event):Void {}
	@:noCompletion private function __enterFrame(deltaTime:Int):Void {}

	@:noCompletion private override function __dispatchEvent(event:Event):Bool
	{
		var bubbleParent = event.bubbles ? parent : null;
		var result = super.__dispatchEvent(event);
		if (event.__isCanceled) return true;
		if (bubbleParent != null && bubbleParent != this)
		{
			event.eventPhase = EventPhase.BUBBLING_PHASE;
			bubbleParent.__dispatchEvent(event);
		}
		return result;
	}

	@:noCompletion private function __dispatchWithCapture(event:Event):Bool
	{
		if (event.target == null) event.target = this;
		if (parent != null)
		{
			event.eventPhase = EventPhase.CAPTURING_PHASE;
			var ancestors:Array<DisplayObject> = [];
			var current:DisplayObject = parent;
			while (current != null)
			{
				ancestors.push(current);
				current = current.parent;
			}
			var i = ancestors.length;
			while (--i >= 0) ancestors[i].__dispatch(event);
		}
		event.eventPhase = EventPhase.AT_TARGET;
		return __dispatchEvent(event);
	}

	@:noCompletion private function __getBounds(rect:Rectangle, matrix:Matrix):Void
	{
		rect.setTo(0, 0, 0, 0);
		var hasBounds = false;
		if (__graphics != null)
		{
			__graphics.__getBounds(rect, matrix);
			hasBounds = !rect.isEmpty();
		}
		if (!__localBounds.isEmpty())
		{
			var transformed = __transformRectangle(__localBounds, matrix);
			if (hasBounds) rect.copyFrom(rect.union(transformed)); else rect.copyFrom(transformed);
			hasBounds = true;
		}
		if (__scrollRect != null)
		{
			var clipped = __transformRectangle(__scrollRect, matrix);
			if (hasBounds) rect.copyFrom(rect.intersection(clipped)); else rect.copyFrom(clipped);
		}
	}

	@:noCompletion private function __getRect(rect:Rectangle, matrix:Matrix):Void
	{
		rect.setTo(0, 0, 0, 0);
		var hasBounds = false;
		if (__graphics != null)
		{
			__graphics.__getBounds(rect, matrix, false);
			hasBounds = !rect.isEmpty();
		}
		if (!__localBounds.isEmpty())
		{
			var transformed = __transformRectangle(__localBounds, matrix);
			if (hasBounds) rect.copyFrom(rect.union(transformed)); else rect.copyFrom(transformed);
			hasBounds = true;
		}
		if (__scrollRect != null)
		{
			var clipped = __transformRectangle(__scrollRect, matrix);
			if (hasBounds) rect.copyFrom(rect.intersection(clipped)); else rect.copyFrom(clipped);
		}
	}

	@:noCompletion private function __getLocalBounds(rect:Rectangle):Void
	{
		__getBounds(rect, __transform);
		rect.x -= __transform.tx;
		rect.y -= __transform.ty;
	}

	@:noCompletion private function __hasBoundsContent():Bool
	{
		return __graphics != null || !__localBounds.isEmpty();
	}

	@:noCompletion private function __hasFlightBoundsContent():Bool
	{
		return __graphics != null;
	}

	@:noCompletion private function __getWorldTransform():Matrix
	{
		var matrix = FlightNode.getNodeWorldMatrix(__flightNode);
		return new Matrix(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
	}

	@:noCompletion private function __getRenderTransform():Matrix
	{
		return __getWorldTransform();
	}

	@:noCompletion private function __globalToLocal(global:Point, local:Point):Point
	{
		FlightNode.convertNodeVector2GlobalToLocal(cast local, __flightNode, cast global);
		return local;
	}

	@:noCompletion private function __hitTest(x:Float, y:Float, shapeFlag:Bool):Bool
	{
		if (__graphics != null && __graphics.__hitTest(x, y, shapeFlag)) return true;
		if (!__localBounds.isEmpty()) return getBounds(null).contains(x, y);
		return false;
	}

	@:noCompletion private function __setLocalBounds(bounds:Rectangle):Void
	{
		if (bounds == null) __localBounds.setTo(0, 0, 0, 0); else __localBounds.copyFrom(bounds);
	}

	@:noCompletion private function __setRenderDirty():Void
	{
		if (stage != null) stage.__invalidated = true;
	}

	@:noCompletion private function __setStageReference(value:Stage):Void
	{
		stage = value;
	}

	@:noCompletion private function __setTransformDirty():Void
	{
		__syncFlightNode();
	}

	@:noCompletion private function __setTransform(a:Float, b:Float, c:Float, d:Float, tx:Float, ty:Float):Void
	{
		__transform.setTo(a, b, c, d, tx, ty);
		__scaleX = b == 0 ? a : Math.sqrt(a * a + b * b);
		__scaleY = c == 0 ? d : Math.sqrt(c * c + d * d);
		__rotation = (180 / Math.PI) * Math.atan2(d, c) - 90;
		var radians = __rotation * Math.PI / 180;
		__rotationSine = Math.sin(radians);
		__rotationCosine = Math.cos(radians);
		__syncFlightNode();
	}

	@:noCompletion private function __stopAllMovieClips():Void {}

	@:noCompletion private function __syncFlightNode():Void
	{
		if (__flightNode == null) return;
		__flightNode.alpha = __alpha;
		__flightNode.blendMode = cast __blendMode;
		__flightNode.name = __name;
		__flightNode.visible = __visible;
		FlightNode.setNodeLocalMatrix(__flightNode, cast __transform);
		FlightNode.invalidateNodeAppearance(__flightNode);
	}

	@:noCompletion private static function __transformRectangle(source:Rectangle, matrix:Matrix):Rectangle
	{
		var p1 = matrix.transformPoint(new Point(source.x, source.y));
		var p2 = matrix.transformPoint(new Point(source.right, source.y));
		var p3 = matrix.transformPoint(new Point(source.x, source.bottom));
		var p4 = matrix.transformPoint(new Point(source.right, source.bottom));
		var minX = Math.min(Math.min(p1.x, p2.x), Math.min(p3.x, p4.x));
		var maxX = Math.max(Math.max(p1.x, p2.x), Math.max(p3.x, p4.x));
		var minY = Math.min(Math.min(p1.y, p2.y), Math.min(p3.y, p4.y));
		var maxY = Math.max(Math.max(p1.y, p2.y), Math.max(p3.y, p4.y));
		return new Rectangle(minX, minY, maxX - minX, maxY - minY);
	}

	@:keep @:noCompletion private function get_alpha():Float return __alpha;
	@:keep @:noCompletion private function set_alpha(value:Float):Float
	{
		if (value < 0) value = 0;
		if (value > 1) value = 1;
		__alpha = value;
		__syncFlightNode();
		return value;
	}

	@:noCompletion private function get_blendMode():BlendMode return __blendMode;
	@:noCompletion private function set_blendMode(value:BlendMode):BlendMode
	{
		__blendMode = value == null ? BlendMode.NORMAL : value;
		__syncFlightNode();
		return value;
	}

	@:noCompletion private function get_cacheAsBitmap():Bool return __filters == null ? __cacheAsBitmap : true;
	@:noCompletion private function set_cacheAsBitmap(value:Bool):Bool return __cacheAsBitmap = value;
	@:noCompletion private function get_cacheAsBitmapMatrix():Matrix return __cacheAsBitmapMatrix == null ? null : __cacheAsBitmapMatrix.clone();
	@:noCompletion private function set_cacheAsBitmapMatrix(value:Matrix):Matrix
	{
		__cacheAsBitmapMatrix = value == null ? null : value.clone();
		return value;
	}

	@:noCompletion private function get_filters():Array<BitmapFilter>
	{
		if (__filters == null) return [];
		return [for (filter in __filters) filter == null ? null : filter.clone()];
	}

	@:noCompletion private function set_filters(value:Array<BitmapFilter>):Array<BitmapFilter>
	{
		__filters = value == null || value.length == 0 ? null : [for (filter in value) filter == null ? null : filter.clone()];
		return value;
	}

	@:keep @:noCompletion private function get_height():Float
	{
		var rect = new Rectangle();
		__getLocalBounds(rect);
		return rect.height;
	}

	@:keep @:noCompletion private function set_height(value:Float):Float
	{
		var current = height;
		if (current != 0) scaleY *= value / current; else scaleY = 0;
		return value;
	}

	@:noCompletion private function get_loaderInfo():LoaderInfo return __loaderInfo;
	@:noCompletion private function get_mask():DisplayObject return __mask;
	@:noCompletion private function set_mask(value:DisplayObject):DisplayObject
	{
		if (__mask != null) __mask.__maskTarget = null;
		if (value != null && value.__maskTarget != null) value.__maskTarget.mask = null;
		__mask = value;
		if (value != null) value.__maskTarget = this;
		return value;
	}

	@:noCompletion private function get_metaData():Dynamic return __metaData;
	@:noCompletion private function set_metaData(value:Dynamic):Dynamic return __metaData = value;
	@:noCompletion private function get_mouseX():Float return globalToLocal(new Point(stage == null ? 0 : stage.__mouseX, stage == null ? 0 : stage.__mouseY)).x;
	@:noCompletion private function get_mouseY():Float return globalToLocal(new Point(stage == null ? 0 : stage.__mouseX, stage == null ? 0 : stage.__mouseY)).y;
	@:noCompletion private function get_name():String return __name;
	@:noCompletion private function set_name(value:String):String
	{
		__name = value;
		if (__flightNode != null) __flightNode.name = value;
		return value;
	}

	@:noCompletion private function get_root():DisplayObject
	{
		if (stage == null) return null;
		var current:DisplayObject = this;
		while (current.parent != null && current.parent != stage) current = current.parent;
		return current == stage ? null : current;
	}

	@:keep @:noCompletion private function get_rotation():Float return __rotation;
	@:keep @:noCompletion private function set_rotation(value:Float):Float
	{
		value %= 360;
		if (value > 180) value -= 360;
		else if (value < -180) value += 360;
		__rotation = value;
		var radians = value * Math.PI / 180;
		__rotationSine = Math.sin(radians);
		__rotationCosine = Math.cos(radians);
		__transform.a = __rotationCosine * __scaleX;
		__transform.b = __rotationSine * __scaleX;
		__transform.c = -__rotationSine * __scaleY;
		__transform.d = __rotationCosine * __scaleY;
		__syncFlightNode();
		return value;
	}

	@:noCompletion private function get_scale9Grid():Rectangle return __scale9Grid == null ? null : __scale9Grid.clone();
	@:noCompletion private function set_scale9Grid(value:Rectangle):Rectangle
	{
		__scale9Grid = value == null ? null : value.clone();
		return value;
	}

	@:keep @:noCompletion private function get_scaleX():Float return __scaleX;
	@:keep @:noCompletion private function set_scaleX(value:Float):Float
	{
		__scaleX = value;
		__transform.a = __rotationCosine * value;
		__transform.b = __rotationSine * value;
		__syncFlightNode();
		return value;
	}

	@:keep @:noCompletion private function get_scaleY():Float return __scaleY;
	@:keep @:noCompletion private function set_scaleY(value:Float):Float
	{
		__scaleY = value;
		__transform.c = -__rotationSine * value;
		__transform.d = __rotationCosine * value;
		__syncFlightNode();
		return value;
	}

	@:noCompletion private function get_scrollRect():Rectangle return __scrollRect == null ? null : __scrollRect.clone();
	@:noCompletion private function set_scrollRect(value:Rectangle):Rectangle
	{
		__scrollRect = value == null ? null : value.clone();
		if (__scrollRect != null)
		{
			if (__scrollRect.width < 0) __scrollRect.width = 0;
			if (__scrollRect.height < 0) __scrollRect.height = 0;
		}
		return value;
	}

	@:noCompletion private function get_shader():Shader return __shader;
	@:noCompletion private function set_shader(value:Shader):Shader return __shader = value;
	@:keep @:noCompletion private function get_transform():Transform
	{
		if (__objectTransform == null) __objectTransform = new Transform(this);
		__objectTransform.__updateConcatenatedColorTransform();
		return __objectTransform;
	}

	@:keep @:noCompletion private function set_transform(value:Transform):Transform
	{
		if (value == null) throw new TypeError("Parameter transform must be non-null.");
		var matrix = value.matrix;
		if (matrix != null) __setTransform(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
		transform.colorTransform = value.colorTransform;
		return transform;
	}

	@:noCompletion private function get_visible():Bool return __visible;
	@:noCompletion private function set_visible(value:Bool):Bool
	{
		__visible = value;
		__syncFlightNode();
		return value;
	}

	@:keep @:noCompletion private function get_width():Float
	{
		var rect = new Rectangle();
		__getLocalBounds(rect);
		return rect.width;
	}

	@:keep @:noCompletion private function set_width(value:Float):Float
	{
		var current = width;
		if (current != 0) scaleX *= value / current; else scaleX = 0;
		return value;
	}

	@:keep @:noCompletion private function get_x():Float return __transform.tx;
	@:keep @:noCompletion private function set_x(value:Float):Float
	{
		__transform.tx = value;
		__syncFlightNode();
		return value;
	}

	@:keep @:noCompletion private function get_y():Float return __transform.ty;
	@:keep @:noCompletion private function set_y(value:Float):Float
	{
		__transform.ty = value;
		__syncFlightNode();
		return value;
	}
}
#else
typedef DisplayObject = flash.display.DisplayObject;
#end
