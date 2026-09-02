package openfl.display;

#if !flash
import flight.Scene2D as FlightScene2D;
import flight.types.Scene2D as FlightScene;
import openfl.display3D.Context3D;
import openfl.errors.IllegalOperationError;
import openfl.events.Event;
import openfl.events.FocusEvent;
import openfl.events.StageOrientationEvent;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.geom.Transform;
import openfl.Vector;
#if lime
import lime.app.Application;
import lime.app.IModule;
import lime.ui.Window;
#end
#if (js && html5)
import js.html.Element;
#elseif js
typedef Element = Dynamic;
#end

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:access(openfl.display.DisplayObject)
@:access(openfl.events.Event)
class Stage extends DisplayObjectContainer #if lime implements IModule #end
{
	/**
		Whether the application supports changes in the stage orientation (and
		device rotation).

		@see `Stage.orientation`
		@see `Stage.deviceOrientation`
		@see `Stage.autoOrients`
		@see `Stage.setOrientation`
		@see `Stage.supportedOrientations`
	**/
	public static var supportsOrientationChange(get, never):Bool;
	/**
		Specifies whether the stage automatically changes orientation when the
		device orientation changes.

		The initial value of this property is derived from the `autoOrients`
		element of the application descriptor and defaults to `false`. When
		changing the property to `false`, the behavior is not guaranteed. On
		some devices, the stage remains in the current orientation. On others,
		the stage orientation changes to a device-defined "standard"
		orientation, after which, no further stage orientation changes occur.

		_OpenFL target support:_ May be set when targeting Adobe AIR only.
		Always returns `false` on all other targets. Orientation may be
		restricted at build-time only in a project.xml file using
		`<app orientation="landscape"/>` or `<app orientation="portrait"/>`.

		_Adobe AIR profile support:_ This feature is supported on mobile
		devices, but it is not supported on desktop operating systems or AIR for
		TV devices. You can test for support at run time using the
		`Stage.supportsOrientationChange` property. See
		[AIR Profile Support](http://help.adobe.com/en_US/air/build/WS144092a96ffef7cc16ddeea2126bb46b82f-8000.html)
		for more information regarding API support across multiple profiles.

		@see `Stage.supportsOrientationChange`
		@see `Stage.orientation`
	**/
	public var autoOrients(get, set):Bool;
	/**
		A value from the StageAlign class that specifies the alignment of the
		stage in Flash Player or the browser. The following are valid values:

		The `align` property is only available to an object that is
		in the same security sandbox as the Stage owner (the main SWF file). To
		avoid this, the Stage owner can grant permission to the domain of the
		calling object by calling the `Security.allowDomain()` method
		or the `Security.alowInsecureDomain()` method. For more
		information, see the "Security" chapter in the _OpenFL
		Developer's Guide_.
	**/
	public var align:StageAlign;
	/**
		Specifies whether this stage allows the use of the full screen mode
	**/
	public var allowsFullScreen(default, null):Bool;
	/**
		Specifies whether this stage allows the use of the full screen with text input mode
	**/
	public var allowsFullScreenInteractive(default, null):Bool;
	/**
		The associated Lime Application instance.
	**/
	public var application(default, null):Application;
	/**
		The window background color.
	**/
	public var color(get, set):Null<Int>;
	/**
		Specifies the effective pixel scaling factor of the stage. This
		value is 1 on standard screens and HiDPI (Retina display)
		screens. When the stage is rendered on HiDPI screens the pixel
		resolution is doubled; even if the stage scaling mode is set to
		`StageScaleMode.NO_SCALE`. `Stage.stageWidth` and `Stage.stageHeight`
		continue to be reported in classic pixel units.
	**/
	public var contentsScaleFactor(get, never):Float;
	/**
		**BETA**

		The current Context3D the default display renderer.

		This property is supported only when using hardware rendering.
	**/
	public var context3D(default, null):Context3D;
	/**
		The physical orientation of the device.

		On devices with slide-out keyboards, the state of the keyboard has a
		higher priority in determining the device orientation than the rotation
		detected by the accelerometer. Thus on a portrait-aspect device with a
		side-mounted keyboard, the `deviceOrientation` property will report
		`ROTATED_LEFT` when the keyboard is open no matter how the user is
		holding the device.

		Use the constants defined in the StageOrientation class when setting or
		comparing values for this property.

		_OpenFL target support:_ This feature is supported on iOS and Android
		mobile devices, but it is not supported on desktop operating systems.
		You can test for support at run time using the
		`Stage.supportsOrientationChange` property.

		_AIR profile support:_ This feature is supported on mobile devices, but
		it is not supported on desktop operating systems or AIR for TV devices.
		You can test for support at run time using the
		`Stage.supportsOrientationChange` property. See
		[AIR Profile Support](http://help.adobe.com/en_US/air/build/WS144092a96ffef7cc16ddeea2126bb46b82f-8000.html)
		for more information regarding API support across multiple profiles.
	**/
	public var deviceOrientation(get, never):StageOrientation;
	/**
		A value from the StageDisplayState class that specifies which display
		state to use. The following are valid values:

		* `StageDisplayState.FULL_SCREEN` Sets the OpenFL application to expand
		the stage over the user's entire screen, with keyboard input disabled.
		* `StageDisplayState.FULL_SCREEN_INTERACTIVE` Sets the OpenFL
		application to expand the stage over the user's entire screen, with
		keyboard input allowed. (Not available for content running in Adobe
		Flash Player.)
		* `StageDisplayState.NORMAL` Sets the OpenFL application back to
		the standard stage display mode.


		The scaling behavior of the movie in full-screen mode is determined by
		the `scaleMode` setting (set using the
		`Stage.scaleMode` property or the SWF file's `embed`
		tag settings in the HTML file). If the `scaleMode` property is
		set to `noScale` while the application transitions to
		full-screen mode, the Stage `width` and `height`
		properties are updated, and the Stage dispatches a `resize`
		event. If any other scale mode is set, the stage and its contents are
		scaled to fill the new screen dimensions. The Stage object retains its
		original `width` and `height` values and does not
		dispatch a `resize` event.

		The following restrictions apply to SWF files that play within an HTML
		page (not those using the stand-alone Flash Player or not running in the
		AIR runtime):


		* To enable full-screen mode, add the `allowFullScreen`
		parameter to the `object` and `embed` tags in the
		HTML page that includes the SWF file, with `allowFullScreen`
		set to `"true"`, as shown in the following example:
		* Full-screen mode is initiated in response to a mouse click or key
		press by the user; the movie cannot change `Stage.displayState`
		without user input. Flash runtimes restrict keyboard input in full-screen
		mode. Acceptable keys include keyboard shortcuts that terminate
		full-screen mode and non-printing keys such as arrows, space, Shift, and
		Tab keys. Keyboard shortcuts that terminate full-screen mode are: Escape
		(Windows, Linux, and Mac), Control+W(Windows), Command+W(Mac), and
		Alt+F4.

		A Flash runtime dialog box appears over the movie when users enter
		full-screen mode to inform the users they are in full-screen mode and that
		they can press the Escape key to end full-screen mode.

		* Starting with Flash Player 9.0.115.0, full-screen works the same in
		windowless mode as it does in window mode. If you set the Window Mode
		(`wmode` in the HTML) to Opaque Windowless
		(`opaque`) or Transparent Windowless
		(`transparent`), full-screen can be initiated, but the
		full-screen window will always be opaque.

		These restrictions are _not_ present for SWF content running in
		the stand-alone Flash Player or in AIR. AIR supports an interactive
		full-screen mode which allows keyboard input.

		For AIR content running in full-screen mode, the system screen saver
		and power saving options are disabled while video content is playing and
		until either the video stops or full-screen mode is exited.

		On Linux, setting `displayState` to
		`StageDisplayState.FULL_SCREEN` or
		`StageDisplayState.FULL_SCREEN_INTERACTIVE` is an asynchronous
		operation.

		@throws SecurityError Calling the `displayState` property of a
							  Stage object throws an exception for any caller that
							  is not in the same security sandbox as the Stage
							  owner (the main SWF file). To avoid this, the Stage
							  owner can grant permission to the domain of the
							  caller by calling the
							  `Security.allowDomain()` method or the
							  `Security.allowInsecureDomain()` method.
							  For more information, see the "Security" chapter in
							  the _OpenFL Developer's Guide_.
							  Trying to set the `displayState` property
							  while the settings dialog is displayed, without a
							  user response, or if the `param` or
							  `embed` HTML tag's
							  `allowFullScreen` attribute is not set to
							  `true` throws a security error.
	**/
	public var displayState(get, set):StageDisplayState;
	#if commonjs
	/**
		The parent HTML element where this Stage is embedded.
	**/
	public var element:Element;
	#end
	/**
		The interactive object with keyboard focus; or `null` if focus
		is not set or if the focused object belongs to a security sandbox to which
		the calling object does not have access.

		@throws Error Throws an error if focus cannot be set to the target.
	**/
	public var focus(get, set):InteractiveObject;
	/**
		Gets and sets the frame rate of the stage. The frame rate is defined as
		frames per second. By default the rate is set to the frame rate of the
		first SWF file loaded. Valid range for the frame rate is from 0.01 to 1000
		frames per second.

		**Note:** An application might not be able to follow high frame rate
		settings, either because the target platform is not fast enough or the
		player is synchronized to the vertical blank timing of the display device
		(usually 60 Hz on LCD devices). In some cases, a target platform might
		also choose to lower the maximum frame rate if it anticipates high CPU
		usage.

		For content running in Adobe AIR, setting the `frameRate`
		property of one Stage object changes the frame rate for all Stage objects
		(used by different NativeWindow objects).

		@throws SecurityError Calling the `frameRate` property of a
							  Stage object throws an exception for any caller that
							  is not in the same security sandbox as the Stage
							  owner (the main SWF file). To avoid this, the Stage
							  owner can grant permission to the domain of the
							  caller by calling the
							  `Security.allowDomain()` method or the
							  `Security.allowInsecureDomain()` method.
							  For more information, see the "Security" chapter in
							  the _OpenFL Developer's Guide_.
	**/
	public var frameRate(get, set):Float;
	/**
		Returns the height of the monitor that will be used when going to full
		screen size, if that state is entered immediately. If the user has
		multiple monitors, the monitor that's used is the monitor that most of
		the stage is on at the time.
		**Note**: If the user has the opportunity to move the browser from one
		monitor to another between retrieving the value and going to full
		screen size, the value could be incorrect. If you retrieve the value
		in an event handler that sets `Stage.displayState` to
		`StageDisplayState.FULL_SCREEN`, the value will be correct.

		This is the pixel height of the monitor and is the same as the stage
		height would be if `Stage.align` is set to `StageAlign.TOP_LEFT` and
		`Stage.scaleMode` is set to `StageScaleMode.NO_SCALE`.
	**/
	public var fullScreenHeight(get, never):UInt;
	/**
		Sets OpenFL to scale a specific region of the stage to
		full-screen mode. If available, the OpenFL scales in hardware,
		which uses the graphics and video card on a user's computer, and
		generally displays content more quickly than software scaling.
		When this property is set to a valid rectangle and the `displayState`
		property is set to full-screen mode, OpenFL scales the
		specified area. The actual Stage size in pixels within Haxe
		does not change. OpenFL enforces a minimum limit for the
		size of the rectangle to accommodate the standard "Press Esc to exit
		full-screen mode" message. This limit is usually around 260 by 30
		pixels but can vary on platform and OpenFL version.

		This property can only be set when the OpenFL is not in
		full-screen mode. To use this property correctly, set this property
		first, then set the `displayState` property to full-screen mode, as
		shown in the code examples.

		To enable scaling, set the `fullScreenSourceRect` property to a
		rectangle object:

		```haxe
		// valid, will enable hardware scaling
		stage.fullScreenSourceRect = new Rectangle(0,0,320,240);
		```

		To disable scaling, set `fullScreenSourceRect=null`.

		```haxe
		stage.fullScreenSourceRect = null;
		```

		The end user also can select within Flash Player Display Settings to
		turn off hardware scaling, which is enabled by default. For more
		information, see <a href="http://www.adobe.com/go/display_settings"
		scope="external">www.adobe.com/go/display_settings</a>.
	**/
	public var fullScreenSourceRect(get, set):Rectangle;
	/**
		Returns the width of the monitor that will be used when going to full
		screen size, if that state is entered immediately. If the user has
		multiple monitors, the monitor that's used is the monitor that most of
		the stage is on at the time.
		**Note**: If the user has the opportunity to move the browser from one
		monitor to another between retrieving the value and going to full
		screen size, the value could be incorrect. If you retrieve the value
		in an event handler that sets `Stage.displayState` to
		`StageDisplayState.FULL_SCREEN`, the value will be correct.

		This is the pixel width of the monitor and is the same as the stage
		width would be if `Stage.align` is set to `StageAlign.TOP_LEFT` and
		`Stage.scaleMode` is set to `StageScaleMode.NO_SCALE`.
	**/
	public var fullScreenWidth(get, never):UInt;
	/**
		The current orientation of the stage. This property is set to one of
		four values, defined as constants in the StageOrientation class:

		| StageOrientation constant        | Stage orientation                                         |
		| -------------------------------- | --------------------------------------------------------- |
		| `StageOrientation.DEFAULT`       | The screen is in the default orientation (right-side up). |
		| `StageOrientation.ROTATED_RIGHT` | The screen is rotated right.                              |
		| `StageOrientation.ROTATED_LEFT`  | The screen is rotated left.                               |
		| `StageOrientation.UPSIDE_DOWN`   | The screen is rotated upside down.                        |
		| `StageOrientation.UNKNOWN`       | The application has not yet determined the initial orientation of the screen. You can add an event listener for the `orientationChange` event |

		To set the stage orientation, use the `setOrientation()` method.
	**/
	public var orientation(get, never):StageOrientation;
	/**
		A value from the StageQuality class that specifies which rendering quality
		is used. The following are valid values:

		* `StageQuality.LOW` - Low rendering quality. Graphics are
		not anti-aliased, and bitmaps are not smoothed, but runtimes still use
		mip-mapping.
		* `StageQuality.MEDIUM` - Medium rendering quality.
		Graphics are anti-aliased using a 2 x 2 pixel grid, bitmap smoothing is
		dependent on the `Bitmap.smoothing` setting. Runtimes use
		mip-mapping. This setting is suitable for movies that do not contain
		text.
		* `StageQuality.HIGH` - High rendering quality. Graphics
		are anti-aliased using a 4 x 4 pixel grid, and bitmap smoothing is
		dependent on the `Bitmap.smoothing` setting. Runtimes use
		mip-mapping. This is the default rendering quality setting that Flash
		Player uses.
		* `StageQuality.BEST` - Very high rendering quality.
		Graphics are anti-aliased using a 4 x 4 pixel grid. If
		`Bitmap.smoothing` is `true` the runtime uses a high
		quality downscale algorithm that produces fewer artifacts (however, using
		`StageQuality.BEST` with `Bitmap.smoothing` set to
		`true` slows performance significantly and is not a recommended
		setting).


		Higher quality settings produce better rendering of scaled bitmaps.
		However, higher quality settings are computationally more expensive. In
		particular, when rendering scaled video, using higher quality settings can
		reduce the frame rate.

		In the desktop profile of Adobe AIR, `quality` can be set to
		`StageQuality.BEST` or `StageQuality.HIGH`(and the
		default value is `StageQuality.HIGH`). Attempting to set it to
		another value has no effect (and the property remains unchanged). In the
		moble profile of AIR, all four quality settings are available. The default
		value on mobile devices is `StageQuality.MEDIUM`.

		For content running in Adobe AIR, setting the `quality`
		property of one Stage object changes the rendering quality for all Stage
		objects (used by different NativeWindow objects).
		**_Note:_** The operating system draws the device fonts, which are
		therefore unaffected by the `quality` property.

		@throws SecurityError Calling the `quality` property of a Stage
							  object throws an exception for any caller that is
							  not in the same security sandbox as the Stage owner
							 (the main SWF file). To avoid this, the Stage owner
							  can grant permission to the domain of the caller by
							  calling the `Security.allowDomain()`
							  method or the
							  `Security.allowInsecureDomain()` method.
							  For more information, see the "Security" chapter in
							  the _OpenFL Developer's Guide_.
	**/
	public var quality(get, set):StageQuality;
	/**
		A value from the StageScaleMode class that specifies which scale mode to
		use. The following are valid values:

		* `StageScaleMode.EXACT_FIT` - The entire application is
		visible in the specified area without trying to preserve the original
		aspect ratio. Distortion can occur, and the application may appear
		stretched or compressed.
		* `StageScaleMode.SHOW_ALL` - The entire application is
		visible in the specified area without distortion while maintaining the
		original aspect ratio of the application. Borders can appear on two sides
		of the application.
		* `StageScaleMode.NO_BORDER` - The entire application fills
		the specified area, without distortion but possibly with some cropping,
		while maintaining the original aspect ratio of the application.
		* `StageScaleMode.NO_SCALE` - The entire application is
		fixed, so that it remains unchanged even as the size of the player window
		changes. Cropping might occur if the player window is smaller than the
		content.


		@throws SecurityError Calling the `scaleMode` property of a
							  Stage object throws an exception for any caller that
							  is not in the same security sandbox as the Stage
							  owner (the main SWF file). To avoid this, the Stage
							  owner can grant permission to the domain of the
							  caller by calling the
							  `Security.allowDomain()` method or the
							  `Security.allowInsecureDomain()` method.
							  For more information, see the "Security" chapter in
							  the _OpenFL Developer's Guide_.
	**/
	public var scaleMode(get, set):StageScaleMode;
	/**
		Specifies whether to show or hide the default items in the Flash
		runtime context menu.
		If the `showDefaultContextMenu` property is set to `true` (the
		default), all context menu items appear. If the
		`showDefaultContextMenu` property is set to `false`, only the Settings
		and About... menu items appear.

		@throws SecurityError Calling the `showDefaultContextMenu` property of
							  a Stage object throws an exception for any
							  caller that is not in the same security sandbox
							  as the Stage owner (the main SWF file). To avoid
							  this, the Stage owner can grant permission to
							  the domain of the caller by calling the
							  `Security.allowDomain()` method or the
							  `Security.allowInsecureDomain()` method. For
							  more information, see the "Security" chapter in
							  the _OpenFL Developer's Guide_.
	**/
	public var showDefaultContextMenu:Bool;
	/**
		The area of the stage that is currently covered by the software
		keyboard.
		The area has a size of zero (0,0,0,0) when the soft keyboard is not
		visible.

		When the keyboard opens, the `softKeyboardRect` is set at the time the
		softKeyboardActivate event is dispatched. If the keyboard changes size
		while open, the runtime updates the `softKeyboardRect` property and
		dispatches an additional softKeyboardActivate event.

		**Note:** On Android, the area covered by the keyboard is estimated
		when the operating system does not provide the information necessary
		to determine the exact area. This problem occurs in fullscreen mode
		and also when the keyboard opens in response to an InteractiveObject
		receiving focus or invoking the `requestSoftKeyboard()` method.
	**/
	public var softKeyboardRect:Rectangle;
	/**
		A list of Stage3D objects available for displaying 3-dimensional content.

		You can use only a limited number of Stage3D objects at a time. The number of
		available Stage3D objects depends on the platform and on the available hardware.

		A Stage3D object draws in front of a StageVideo object and behind the OpenFL
		display list.
	**/
	public var stage3Ds(default, null):Vector<Stage3D>;
	/**
		Specifies whether or not objects display a glowing border when they have
		focus.

		@throws SecurityError Calling the `stageFocusRect` property of
							  a Stage object throws an exception for any caller
							  that is not in the same security sandbox as the
							  Stage owner (the main SWF file). To avoid this, the
							  Stage owner can grant permission to the domain of
							  the caller by calling the
							  `Security.allowDomain()` method or the
							  `Security.allowInsecureDomain()` method.
							  For more information, see the "Security" chapter in
							  the _OpenFL Developer's Guide_.
	**/
	public var stageFocusRect:Bool;
	/**
		The current height, in pixels, of the Stage.

		If the value of the `Stage.scaleMode` property is set to
		`StageScaleMode.NO_SCALE` when the user resizes the window, the
		Stage content maintains its size while the `stageHeight`
		property changes to reflect the new height size of the screen area
		occupied by the SWF file.(In the other scale modes, the
		`stageHeight` property always reflects the original height of
		the SWF file.) You can add an event listener for the `resize`
		event and then use the `stageHeight` property of the Stage
		class to determine the actual pixel dimension of the resized Flash runtime
		window. The event listener allows you to control how the screen content
		adjusts when the user resizes the window.

		Air for TV devices have slightly different behavior than desktop
		devices when you set the `stageHeight` property. If the
		`Stage.scaleMode` property is set to
		`StageScaleMode.NO_SCALE` and you set the
		`stageHeight` property, the stage height does not change until
		the next frame of the SWF.

		**Note:** In an HTML page hosting the SWF file, both the
		`object` and `embed` tags' `height`
		attributes must be set to a percentage (such as `100%`), not
		pixels. If the settings are generated by JavaScript code, the
		`height` parameter of the `AC_FL_RunContent() `
		method must be set to a percentage, too. This percentage is applied to the
		`stageHeight` value.

		@throws SecurityError Calling the `stageHeight` property of a
							  Stage object throws an exception for any caller that
							  is not in the same security sandbox as the Stage
							  owner (the main SWF file). To avoid this, the Stage
							  owner can grant permission to the domain of the
							  caller by calling the
							  `Security.allowDomain()` method or the
							  `Security.allowInsecureDomain()` method.
							  For more information, see the "Security" chapter in
							  the _OpenFL Developer's Guide_.
	**/
	public var stageHeight(default, null):Int;
	/**
		Specifies the current width, in pixels, of the Stage.

		If the value of the `Stage.scaleMode` property is set to
		`StageScaleMode.NO_SCALE` when the user resizes the window, the
		Stage content maintains its defined size while the `stageWidth`
		property changes to reflect the new width size of the screen area occupied
		by the SWF file.(In the other scale modes, the `stageWidth`
		property always reflects the original width of the SWF file.) You can add
		an event listener for the `resize` event and then use the
		`stageWidth` property of the Stage class to determine the
		actual pixel dimension of the resized Flash runtime window. The event
		listener allows you to control how the screen content adjusts when the
		user resizes the window.

		Air for TV devices have slightly different behavior than desktop
		devices when you set the `stageWidth` property. If the
		`Stage.scaleMode` property is set to
		`StageScaleMode.NO_SCALE` and you set the
		`stageWidth` property, the stage width does not change until
		the next frame of the SWF.

		**Note:** In an HTML page hosting the SWF file, both the
		`object` and `embed` tags' `width`
		attributes must be set to a percentage (such as `100%`), not
		pixels. If the settings are generated by JavaScript code, the
		`width` parameter of the `AC_FL_RunContent() `
		method must be set to a percentage, too. This percentage is applied to the
		`stageWidth` value.

		@throws SecurityError Calling the `stageWidth` property of a
							  Stage object throws an exception for any caller that
							  is not in the same security sandbox as the Stage
							  owner (the main SWF file). To avoid this, the Stage
							  owner can grant permission to the domain of the
							  caller by calling the
							  `Security.allowDomain()` method or the
							  `Security.allowInsecureDomain()` method.
							  For more information, see the "Security" chapter in
							  the _OpenFL Developer's Guide_.
	**/
	public var stageWidth(default, null):Int;
	/**
		The orientations supported by the current device.

		You can use the orientation strings included in this list as parameters
		for the `setOrientation()` method. Setting an unsupported orientation
		fails without error.

		The possible orientations include:

		| StageOrientation constant        | Stage orientation                                         |
		| -------------------------------- | --------------------------------------------------------- |
		| `StageOrientation.DEFAULT`       | The screen is in the default orientation (right-side up). |
		| `StageOrientation.ROTATED_RIGHT` | The screen is rotated right.                              |
		| `StageOrientation.ROTATED_LEFT`  | The screen is rotated left.                               |
		| `StageOrientation.UPSIDE_DOWN`   | The screen is rotated upside down.                        |

		_OpenFL target support:_ Returns orientation values when targeting Adobe
		AIR only. On all other targets, returns an empty vector.

		_Adobe AIR profile support:_ This feature is supported on mobile
		devices, but it is not supported on desktop operating systems or AIR for
		TV devices. You can test for support at run time using the
		`Stage.supportsOrientationChange` property. See
		[AIR Profile Support](http://help.adobe.com/en_US/air/build/WS144092a96ffef7cc16ddeea2126bb46b82f-8000.html)
		for more information regarding API support across multiple profiles.

		@see `Stage.setOrientation()`
		@see `Stage.orientation`
	**/
	public var supportedOrientations(get, never):Vector<StageOrientation>;
	/**
		The associated Lime Window instance for this Stage.
	**/
	public var window(default, null):Window;
	#if (sys && (!flash_doc_gen || air_doc_gen))
	/**

	**/
	public var nativeWindow(default, null):openfl.display.NativeWindow;
	#end

	@:noCompletion private var __autoOrients:Bool;
	@:noCompletion private var __color:Null<Int>;
	@:noCompletion private var __contentsScaleFactor:Float;
	@:noCompletion private var __displayState:StageDisplayState;
	@:noCompletion private var __deltaTime:Int;
	@:noCompletion private var __dragBounds:Rectangle;
	@:noCompletion private var __dragObject:Sprite;
	@:noCompletion private var __focus:InteractiveObject;
	@:noCompletion private var __frameRate:Float;
	@:noCompletion private var __fullScreenSourceRect:Rectangle;
	@:noCompletion private var __invalidated:Bool;
	@:noCompletion private var __mouseX:Float;
	@:noCompletion private var __mouseY:Float;
	@:noCompletion private var __orientation:StageOrientation;
	@:noCompletion private var __quality:StageQuality;
	@:noCompletion private var __scaleMode:StageScaleMode;
	@:noCompletion private var __scene:FlightScene;

	public function new(#if commonjs width:Dynamic = 0, height:Dynamic = 0, color:Null<Int> = null, documentClass:Class<Dynamic> = null,
		windowAttributes:Dynamic = null #else window:Window, color:Null<Int> = null #end)
	{
		super();
		this.stage = this;
		this.name = null;
		__autoOrients = false;
		__color = 0xFFFFFFFF;
		__contentsScaleFactor = 1;
		__displayState = StageDisplayState.NORMAL;
		__frameRate = 60;
		__mouseX = 0;
		__mouseY = 0;
		__orientation = StageOrientation.UNKNOWN;
		__quality = StageQuality.HIGH;
		__scaleMode = StageScaleMode.NO_SCALE;
		align = StageAlign.TOP_LEFT;
		allowsFullScreen = true;
		allowsFullScreenInteractive = true;
		showDefaultContextMenu = true;
		softKeyboardRect = new Rectangle();
		stageFocusRect = true;
		stage3Ds = new Vector<Stage3D>();
		for (i in 0...4) stage3Ds.push(new Stage3D(this));

		#if commonjs
		stageWidth = Std.int(width);
		stageHeight = Std.int(height);
		#else
		this.window = window;
		if (window != null)
		{
			application = window.application;
			stageWidth = window.width;
			stageHeight = window.height;
			__contentsScaleFactor = window.scale;
		}
		else
		{
			stageWidth = 0;
			stageHeight = 0;
		}
		#end

		__scene = FlightScene2D.createScene2D();
		__flightNode = __scene.root;
		FlightScene2D.setScene2DSize(__scene, stageWidth, stageHeight);
		this.color = color;

		if (openfl.Lib.current.stage == null)
		{
			addChild(openfl.Lib.current);
		}
	}

	/**
		Calling the `invalidate()` method signals Flash runtimes to
		alert display objects on the next opportunity it has to render the display
		list (for example, when the playhead advances to a new frame). After you
		call the `invalidate()` method, when the display list is next
		rendered, the Flash runtime sends a `render` event to each
		display object that has registered to listen for the `render`
		event. You must call the `invalidate()` method each time you
		want the Flash runtime to send `render` events.

		The `render` event gives you an opportunity to make changes
		to the display list immediately before it is actually rendered. This lets
		you defer updates to the display list until the latest opportunity. This
		can increase performance by eliminating unnecessary screen updates.

		The `render` event is dispatched only to display objects
		that are in the same security domain as the code that calls the
		`stage.invalidate()` method, or to display objects from a
		security domain that has been granted permission via the
		`Security.allowDomain()` method.

	**/
	public override function invalidate():Void
	{
		__invalidated = true;
	}

	public override function localToGlobal(pos:Point):Point return pos.clone();

	/**
		Sets the stage to the specified orientation.

		Set the `newOrientation` parameter to one of the following four values
		defined as constants in the StageOrientation class:

		| StageOrientation constant        | Stage orientation                                         |
		| -------------------------------- | --------------------------------------------------------- |
		| `StageOrientation.DEFAULT`       | The screen is in the default orientation (right-side up). |
		| `StageOrientation.ROTATED_RIGHT` | The screen is rotated right.                              |
		| `StageOrientation.ROTATED_LEFT`  | The screen is rotated left.                               |
		| `StageOrientation.UPSIDE_DOWN`   | The screen is rotated upside down.                        |

		Do not set the parameter to `StageOrientation.UNKNOWN` or any string
		value other than those listed in the table.

		Check the list provided by the `supportedOrientations` property to
		determine which orientations are supported by the current device.

		Setting the orientation is an asynchronous operation. It is not
		guaranteed to be complete immediately after you call the
		`setOrientation()` method. Add an event listener for the
		`orientationChange` event to determine when the orientation change is
		complete.

		**Note:** The `setOrientation()` method does not cause an
		`orientationChanging` event to be dispatched.

		_OpenFL target support:_ May be called when targeting Adobe AIR only.
		Calls to this method are always ignored on all other targets. Orientation
		may be restricted at build-time only in a project.xml file using
		`<app orientation="landscape"/>` or `<app orientation="portrait"/>`.

		_Adobe AIR profile support:_ This feature is supported on mobile
		devices, but it is not supported on desktop operating systems or AIR for
		TV devices. You can test for support at run time using the
		`Stage.supportsOrientationChange` property. See
		[AIR Profile Support](http://help.adobe.com/en_US/air/build/WS144092a96ffef7cc16ddeea2126bb46b82f-8000.html)
		for more information regarding API support across multiple profiles.

		@see `Stage.supportedOrientations`
		@see `Stage.orientation`
	**/
	public function setOrientation(newOrientation:StageOrientation):Void
	{
		// OpenFL ignores orientation requests on non-mobile targets.
	}

	@:noCompletion private function __broadcastEvent(event:Event):Void
	{
		var dispatchers = DisplayObject.__broadcastEvents.get(event.type);
		if (dispatchers == null) return;
		for (dispatcher in dispatchers.copy())
		{
			if (dispatcher.stage == this || dispatcher.stage == null) dispatcher.dispatchEvent(new Event(event.type, event.bubbles, event.cancelable));
		}
	}

	@:noCompletion private function __renderAfterEvent():Void {}

	@:noCompletion private function __advanceFrame():Void
	{
		__broadcastEvent(new Event(Event.ENTER_FRAME));
		__broadcastEvent(new Event(Event.FRAME_CONSTRUCTED));
		__broadcastEvent(new Event(Event.EXIT_FRAME));
		__enterFrame(__deltaTime);
		__deltaTime = 0;
		if (__invalidated)
		{
			__invalidated = false;
			__broadcastEvent(new Event(Event.RENDER));
		}
	}

	@:noCompletion private function __getFlightBackgroundColor():Float
	{
		var color = __color == null ? 0xFF000000 : __color;
		return (color & 0xFFFFFF) * 256.0 + ((color >>> 24) & 0xFF);
	}

	@:noCompletion private function __startDrag(sprite:Sprite, lockCenter:Bool, bounds:Rectangle):Void
	{
		__dragObject = sprite;
		__dragBounds = bounds == null ? null : bounds.clone();
	}

	@:noCompletion private function __stopDrag(sprite:Sprite):Void
	{
		if (__dragObject == sprite)
		{
			__dragObject = null;
			__dragBounds = null;
		}
	}

	#if lime
	@:noCompletion private function __registerLimeModule(application:Application):Void
	{
		this.application = application;
		application.onUpdate.add(__onLimeUpdate);
	}

	@:noCompletion private function __unregisterLimeModule(application:Application):Void
	{
		application.onUpdate.remove(__onLimeUpdate);
	}

	@:noCompletion private function __onLimeUpdate(deltaTime:Int):Void
	{
		__deltaTime = deltaTime;
	}
	#end

	@:noCompletion private static function get_supportsOrientationChange():Bool return false;
	@:noCompletion private function get_autoOrients():Bool return __autoOrients;
	@:noCompletion private function set_autoOrients(value:Bool):Bool return false;
	@:noCompletion private function get_color():Null<Int> return __color;

	@:noCompletion private function set_color(value:Null<Int>):Null<Int>
	{
		var normalized = value == null ? 0xFF000000 : ((0xFF << 24) | (value & 0xFFFFFF));
		__color = normalized;
		if (__scene != null) __scene.color = normalized;
		return value;
	}

	@:noCompletion private function get_contentsScaleFactor():Float return __contentsScaleFactor;
	@:noCompletion private function get_deviceOrientation():StageOrientation return __orientation;
	@:noCompletion private function get_displayState():StageDisplayState return __displayState;

	@:noCompletion private function set_displayState(value:StageDisplayState):StageDisplayState
	{
		__displayState = value;
		#if lime
		if (window != null) window.fullscreen = value != StageDisplayState.NORMAL;
		#end
		return value;
	}

	@:noCompletion private function get_focus():InteractiveObject return __focus;

	@:noCompletion private function set_focus(value:InteractiveObject):InteractiveObject
	{
		if (__focus == value) return value;
		var oldFocus = __focus;
		__focus = value;
		if (oldFocus != null) oldFocus.dispatchEvent(new FocusEvent(FocusEvent.FOCUS_OUT, true, false, value));
		if (value != null) value.dispatchEvent(new FocusEvent(FocusEvent.FOCUS_IN, true, false, oldFocus));
		return value;
	}

	@:noCompletion private function get_frameRate():Float return __frameRate;
	@:noCompletion private function set_frameRate(value:Float):Float return __frameRate = value;
	@:noCompletion private function get_fullScreenHeight():UInt return stageHeight;
	@:noCompletion private function get_fullScreenSourceRect():Rectangle return __fullScreenSourceRect == null ? null : __fullScreenSourceRect.clone();

	@:noCompletion private function set_fullScreenSourceRect(value:Rectangle):Rectangle
	{
		__fullScreenSourceRect = value == null ? null : value.clone();
		return value;
	}

	@:noCompletion private function get_fullScreenWidth():UInt return stageWidth;
	@:noCompletion private override function set_height(value:Float):Float return height;
	@:noCompletion private override function get_mouseX():Float return __mouseX;
	@:noCompletion private override function get_mouseY():Float return __mouseY;
	@:noCompletion private function get_orientation():StageOrientation return __orientation;
	@:noCompletion private function get_quality():StageQuality return __quality;
	@:noCompletion private function set_quality(value:StageQuality):StageQuality return __quality = value;
	@:noCompletion private override function set_rotation(value:Float):Float return 0;
	@:noCompletion private function get_scaleMode():StageScaleMode return __scaleMode;

	@:noCompletion private function set_scaleMode(value:StageScaleMode):StageScaleMode
	{
		__scaleMode = value;
		return value;
	}

	@:noCompletion private override function set_scaleX(value:Float):Float return 0;
	@:noCompletion private override function set_scaleY(value:Float):Float return 0;

	@:noCompletion private function get_supportedOrientations():Vector<StageOrientation>
	{
		return new Vector<StageOrientation>();
	}

	@:noCompletion private override function get_tabEnabled():Bool return false;
	@:noCompletion private override function set_tabEnabled(value:Bool):Bool return __throwStageProperty("tabEnabled");
	@:noCompletion private override function get_tabIndex():Int return -1;
	@:noCompletion private override function set_tabIndex(value:Int):Int return __throwStageProperty("tabIndex");
	@:noCompletion private override function set_transform(value:Transform):Transform return transform;
	@:noCompletion private override function set_width(value:Float):Float return width;
	@:noCompletion private override function set_x(value:Float):Float return 0;
	@:noCompletion private override function set_y(value:Float):Float return 0;

	@:noCompletion private function __throwStageProperty<T>(property:String):T
	{
		throw new IllegalOperationError("The " + property + " property cannot be set on the Stage.");
	}

	@:noCompletion private var __uncaughtErrorEvents:openfl.events.UncaughtErrorEvents;

	@:noCompletion private function __handleError(e:Dynamic):Void {}

	@:noCompletion private function __setLogicalSize(width:Int, height:Int):Void
	{
		if (stageWidth == width && stageHeight == height) return;
		stageWidth = width;
		stageHeight = height;
		FlightScene2D.setScene2DSize(__scene, width, height);
		__setTransformDirty();
		dispatchEvent(new Event(Event.RESIZE));
	}
}
#else
typedef Stage = flash.display.Stage;
#end
