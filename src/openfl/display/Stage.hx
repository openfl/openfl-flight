package openfl.display;

#if !flash
import flight.Scene2D as FlightScene2D;
import flight.Signals as FlightSignals;
import flight.types.Scene2D as FlightScene;
import haxe.ds.ArraySort;
import openfl.display3D.Context3D;
import openfl.errors.IllegalOperationError;
import openfl.events.Event;
import openfl.events.EventPhase;
import openfl.events.FocusEvent;
import openfl.events.FullScreenEvent;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.events.StageOrientationEvent;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.geom.Transform;
import openfl.text.TextField;
import openfl.ui.Keyboard;
import openfl.ui.KeyLocation;
import openfl.ui.Mouse;
import openfl.ui.MouseCursor;
import openfl.Vector;
#if lime
import lime.app.Application;
import lime.app.IModule;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.MouseWheelMode;
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
@:access(openfl.display.Graphics)
@:access(openfl.display.InteractiveObject)
@:access(openfl.events.Event)
@:access(openfl.events.KeyboardEvent)
@:access(openfl.events.MouseEvent)
@:access(openfl.ui.Keyboard)
@:access(openfl.ui.Mouse)
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
	@:noCompletion private var __currentTabOrderIndex:Int;
	@:noCompletion private var __displayState:StageDisplayState;
	@:noCompletion private var __displayMatrix:Matrix;
	@:noCompletion private var __deltaTime:Int;
	@:noCompletion private var __dragBounds:Rectangle;
	@:noCompletion private var __dragObject:Sprite;
	@:noCompletion private var __dragOffsetX:Float;
	@:noCompletion private var __dragOffsetY:Float;
	@:noCompletion private var __focus:InteractiveObject;
	@:noCompletion private var __cacheFocus:InteractiveObject;
	@:noCompletion private var __cancelKeySignal:Bool;
	@:noCompletion private var __frameRate:Float;
	@:noCompletion private var __fullScreenSourceRect:Rectangle;
	@:noCompletion private var __invalidated:Bool;
	@:noCompletion private var __logicalHeight:Int;
	@:noCompletion private var __logicalWidth:Int;
	@:noCompletion private var __macKeyboard:Bool;
	@:noCompletion private var __mouseClickCount:Int;
	@:noCompletion private var __mouseDownLeft:InteractiveObject;
	@:noCompletion private var __mouseDownMiddle:InteractiveObject;
	@:noCompletion private var __mouseDownRight:InteractiveObject;
	@:noCompletion private var __mouseOutStack:Array<DisplayObject>;
	@:noCompletion private var __mouseOverTarget:InteractiveObject;
	@:noCompletion private var __mouseX:Float;
	@:noCompletion private var __mouseY:Float;
	@:noCompletion private var __pendingMouseEvent:Bool;
	@:noCompletion private var __pendingMouseX:Float;
	@:noCompletion private var __pendingMouseY:Float;
	@:noCompletion private var __primaryMouseButtonDown:Bool;
	@:noCompletion private var __orientation:StageOrientation;
	@:noCompletion private var __quality:StageQuality;
	@:noCompletion private var __scaleMode:StageScaleMode;
	@:noCompletion private var __scene:FlightScene;
	@:noCompletion private var __rollOutStack:Array<DisplayObject>;
	@:noCompletion private var __untransformedMouseX:Float;
	@:noCompletion private var __untransformedMouseY:Float;

	public function new(#if commonjs width:Dynamic = 0, height:Dynamic = 0, color:Null<Int> = null, documentClass:Class<Dynamic> = null,
		windowAttributes:Dynamic = null #else window:Window, color:Null<Int> = null #end)
	{
		super();
		this.stage = this;
		this.name = null;
		__autoOrients = false;
		__color = 0xFFFFFFFF;
		__contentsScaleFactor = 1;
		__currentTabOrderIndex = 0;
		__displayState = StageDisplayState.NORMAL;
		__displayMatrix = new Matrix();
		__frameRate = 60;
		__mouseX = 0;
		__mouseY = 0;
		__primaryMouseButtonDown = false;
		__orientation = StageOrientation.UNKNOWN;
		__quality = StageQuality.HIGH;
		__scaleMode = StageScaleMode.NO_SCALE;
		__logicalWidth = 0;
		__logicalHeight = 0;
		__macKeyboard = #if mac true #else false #end;
		__mouseClickCount = 0;
		__mouseOutStack = [];
		__rollOutStack = [];
		__pendingMouseEvent = false;
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
		#if !lime
		if (window != null && window.onFullscreen != null)
		{
			FlightSignals.connectSignal(cast window.onFullscreen, __onFlightWindowFullscreen);
		}
		#end
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
		__renderDirty = true;
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
		for (dispatcher in dispatchers)
		{
			if (dispatcher.stage == this || dispatcher.stage == null) dispatcher.__dispatch(event);
		}
	}

	@:noCompletion private function __renderAfterEvent():Void
	{
		__renderDirty = true;
	}

	@:noCompletion private function __syncWindowFullscreen():Void
	{
		var fullscreen = window != null && window.fullscreen;
		if (fullscreen)
		{
			if (__displayState == StageDisplayState.NORMAL) __displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
		}
		else
		{
			__displayState = StageDisplayState.NORMAL;
		}
		__resize();
		__dispatchEvent(new FullScreenEvent(FullScreenEvent.FULL_SCREEN, false, false, fullscreen, true));
	}

	#if !lime
	@:noCompletion private function __onFlightWindowFullscreen():Void
	{
		__syncWindowFullscreen();
	}
	#end

	@:noCompletion private function __windowFocusIn():Void
	{
		__broadcastEvent(new Event(Event.ACTIVATE));
		#if !desktop
		focus = __cacheFocus;
		#end
	}

	@:noCompletion private function __windowFocusOut():Void
	{
		__broadcastEvent(new Event(Event.DEACTIVATE));
		var currentFocus = focus;
		focus = null;
		__cacheFocus = currentFocus;
	}

	@:noCompletion private function __advanceFrame():Void
	{
		__broadcastEvent(new Event(Event.ENTER_FRAME));
		__broadcastEvent(new Event(Event.FRAME_CONSTRUCTED));
		__broadcastEvent(new Event(Event.EXIT_FRAME));
		__enterFrame(__deltaTime);
		__deltaTime = 0;
	}

	@:noCompletion private function __renderBeforeDraw():Void
	{
		if (__invalidated && __renderDirty)
		{
			__invalidated = false;
			__update(false, true);
			__clearRenderDirty();
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
		if (bounds == null)
		{
			__dragBounds = null;
		}
		else
		{
			var right = bounds.right;
			var bottom = bounds.bottom;
			__dragBounds = new Rectangle(Math.min(bounds.x, right), Math.min(bounds.y, bottom), Math.abs(bounds.width), Math.abs(bounds.height));
		}
		if (sprite != null)
		{
			if (lockCenter)
			{
				__dragOffsetX = 0;
				__dragOffsetY = 0;
			}
			else
			{
				var mouse = new Point(__mouseX, __mouseY);
				if (sprite.parent != null) mouse = sprite.parent.globalToLocal(mouse);
				__dragOffsetX = sprite.x - mouse.x;
				__dragOffsetY = sprite.y - mouse.y;
			}
		}
	}

	@:noCompletion private function __stopDrag(sprite:Sprite):Void
	{
		__dragObject = null;
		__dragBounds = null;
	}

	@:noCompletion private function __updateDrag():Void
	{
		if (__dragObject == null) return;
		var mouse = new Point(__mouseX, __mouseY);
		if (__dragObject.parent != null) mouse = __dragObject.parent.globalToLocal(mouse);
		var x = mouse.x + __dragOffsetX;
		var y = mouse.y + __dragOffsetY;
		if (__dragBounds != null)
		{
			x = Math.max(__dragBounds.x, Math.min(__dragBounds.right, x));
			y = Math.max(__dragBounds.y, Math.min(__dragBounds.bottom, y));
		}
		__dragObject.x = x;
		__dragObject.y = y;
		var mouseEnabled = __dragObject.mouseEnabled;
		var mouseChildren = __dragObject.mouseChildren;
		__dragObject.mouseEnabled = false;
		__dragObject.mouseChildren = false;
		var target = __resolveMouseTarget(__mouseX, __mouseY);
		__dragObject.mouseEnabled = mouseEnabled;
		__dragObject.mouseChildren = mouseChildren;
		__dragObject.dropTarget = target == this ? null : target;
	}

	@:noCompletion private function __dispatchStack(event:Event, stack:Array<DisplayObject>):Void
	{
		var length = stack.length;
		if (length == 0)
		{
			event.eventPhase = EventPhase.AT_TARGET;
			var target:DisplayObject = cast event.target;
			target.__dispatch(event);
			__renderAfterInputEvent(event);
			return;
		}

		event.target = stack[length - 1];
		event.eventPhase = EventPhase.CAPTURING_PHASE;
		for (i in 0...length - 1)
		{
			stack[i].__dispatch(event);
			if (event.__isCanceled)
			{
				__renderAfterInputEvent(event);
				return;
			}
		}

		event.eventPhase = EventPhase.AT_TARGET;
		stack[length - 1].__dispatch(event);
		if (event.__isCanceled || !event.bubbles)
		{
			__renderAfterInputEvent(event);
			return;
		}

		event.eventPhase = EventPhase.BUBBLING_PHASE;
		var i = length - 2;
		while (i >= 0)
		{
			stack[i].__dispatch(event);
			if (event.__isCanceled)
			{
				__renderAfterInputEvent(event);
				return;
			}
			i--;
		}
		__renderAfterInputEvent(event);
	}

	@:noCompletion private function __renderAfterInputEvent(event:Event):Void
	{
		if ((event is MouseEvent) && cast(event, MouseEvent).__updateAfterEventFlag)
		{
			__renderAfterEvent();
		}
		else if ((event is KeyboardEvent) && cast(event, KeyboardEvent).__updateAfterEventFlag)
		{
			__renderAfterEvent();
		}
	}

	@:noCompletion private function __getEventStack(target:DisplayObject):Array<DisplayObject>
	{
		var stack:Array<DisplayObject> = [];
		var current = target;
		while (current != null)
		{
			stack.unshift(current);
			current = current.parent;
		}
		return stack;
	}

	@:noCompletion private function __dispatchKey(type:String, charCode:Int, keyCode:Int, keyLocation:KeyLocation, control:Bool, alt:Bool, shift:Bool,
		command:Bool):KeyboardEvent
	{
		__cancelKeySignal = false;
		var ctrl = __macKeyboard ? (control || command) : control;
		MouseEvent.__altKey = alt;
		MouseEvent.__commandKey = command;
		MouseEvent.__controlKey = control;
		MouseEvent.__ctrlKey = ctrl;
		MouseEvent.__shiftKey = shift;

		var target:InteractiveObject = __focus == null ? this : __focus;
		var stack = __getEventStack(target);
		if (type == KeyboardEvent.KEY_UP && (keyCode == Keyboard.SPACE || keyCode == Keyboard.ENTER) && (__focus is Sprite))
		{
			var sprite:Sprite = cast __focus;
			if (sprite.buttonMode && sprite.focusRect == true)
			{
				var local = sprite.globalToLocal(new Point(__mouseX, __mouseY));
				var clickEvent = new MouseEvent(MouseEvent.CLICK, true, false, local.x, local.y, null, ctrl, alt, shift, __primaryMouseButtonDown, 0,
					command, control, 0);
				clickEvent.stageX = __mouseX;
				clickEvent.stageY = __mouseY;
				__dispatchStack(clickEvent, stack);
			}
		}

		var event = new KeyboardEvent(type, true, true, charCode, keyCode, keyLocation, ctrl, alt, shift, control, command);
		__dispatchStack(event, stack);
		if (!event.isDefaultPrevented())
		{
			if (type == KeyboardEvent.KEY_DOWN && keyCode == Keyboard.TAB)
			{
				__cancelKeySignal = __changeFocusByTab(shift);
			}
			else if (type == KeyboardEvent.KEY_DOWN && focus != null && !(focus is TextField) && ctrl && !alt && !shift)
			{
				var shortcutType:String = switch (keyCode)
				{
					case Keyboard.C: Event.COPY;
					case Keyboard.X: Event.CUT;
					case Keyboard.V: Event.PASTE;
					case Keyboard.A: Event.SELECT_ALL;
					default: null;
				};
				if (shortcutType != null) focus.dispatchEvent(new Event(shortcutType, true, true));
			}
		}
		return event;
	}

	@:noCompletion private function __changeFocusByTab(shift:Bool):Bool
	{
		var tabStack:Array<InteractiveObject> = [];
		__tabTest(tabStack);
		var nextIndex = -1;
		var nextObject:InteractiveObject = null;
		var nextOffset = shift ? -1 : 1;
		if (tabStack.length > 1)
		{
			ArraySort.sort(tabStack, function(a:InteractiveObject, b:InteractiveObject):Int return a.tabIndex - b.tabIndex);
			if (tabStack[tabStack.length - 1].tabIndex != -1)
			{
				var i = 0;
				while (i < tabStack.length && tabStack[i].tabIndex == -1) i++;
				if (i > 0) tabStack.splice(0, i);
			}
			if (focus != null)
			{
				var current:DisplayObject = focus;
				var index = tabStack.indexOf(focus);
				while (index == -1 && current != null)
				{
					var currentParent = current.parent;
					if (currentParent != null && currentParent.tabChildren)
					{
						var currentIndex = currentParent.getChildIndex(current);
						if (currentIndex == -1)
						{
							current = currentParent;
							continue;
						}
						var i = currentIndex + nextOffset;
						while (shift ? i >= 0 : i < currentParent.numChildren)
						{
							var sibling = currentParent.getChildAt(i);
							if ((sibling is InteractiveObject))
							{
								index = tabStack.indexOf(cast sibling);
								if (index != -1)
								{
									nextOffset = 0;
									break;
								}
							}
							i += nextOffset;
						}
					}
					else if (shift)
					{
						index = tabStack.indexOf(currentParent);
						if (index != -1) nextOffset = 0;
					}
					current = currentParent;
				}
				nextIndex = index < 0 ? 0 : index + nextOffset;
			}
			else nextIndex = __currentTabOrderIndex;
		}
		else if (tabStack.length == 1)
		{
			nextObject = tabStack[0];
			if (focus == nextObject) nextObject = null;
		}

		var cancelTab = nextIndex >= 0 && nextIndex < tabStack.length;
		if (tabStack.length == 1 || (tabStack.length == 0 && focus != null)) nextIndex = 0;
		else if (tabStack.length > 1)
		{
			if (nextIndex < 0) nextIndex += tabStack.length;
			nextIndex %= tabStack.length;
			nextObject = tabStack[nextIndex];
			if (nextObject == focus)
			{
				nextIndex += nextOffset;
				if (nextIndex < 0) nextIndex += tabStack.length;
				nextIndex %= tabStack.length;
				nextObject = tabStack[nextIndex];
			}
		}

		var focusEvent:FocusEvent = null;
		if (focus != null)
		{
			focusEvent = new FocusEvent(FocusEvent.KEY_FOCUS_CHANGE, true, true, nextObject, shift, 0);
			__dispatchStack(focusEvent, __getEventStack(focus));
			if (focusEvent.isDefaultPrevented()) return true;
		}
		__currentTabOrderIndex = nextIndex;
		if (nextObject != null) focus = nextObject;
		return cancelTab;
	}

	@:noCompletion private function __mouseHit(object:DisplayObject, stageX:Float, stageY:Float):Dynamic
	{
		if (object == null || !object.visible || object.__maskTarget != null || !object.__isPointInScrollRect(stageX, stageY))
		{
			return {hit: false, target: null};
		}
		if (object.mask != null && !object.mask.__hitTestMask(stageX, stageY)) return {hit: false, target: null};

		var container:DisplayObjectContainer = (object is DisplayObjectContainer) ? cast object : null;
		var sprite:Sprite = (object is Sprite) ? cast object : null;
		var ownHit = sprite != null && sprite.hitArea != null
			? sprite.hitArea.__hitTest(stageX, stageY, true)
			: (container == null ? ((object is SimpleButton) ? cast(object, SimpleButton).__hitTestInteractive(stageX, stageY, true) : object.__hitTest(stageX,
				stageY, true)) : object.__graphics != null && object.__graphics.__hitTest(stageX, stageY, true));

		if (container != null)
		{
			if (!container.mouseChildren)
			{
				var branchHit = ownHit;
				if (!branchHit)
				{
					var i = container.__children.length;
					while (--i >= 0)
					{
						if (__mouseHit(container.__children[i], stageX, stageY).hit)
						{
							branchHit = true;
							break;
						}
					}
				}
				return {
					hit: branchHit,
					target: branchHit && (container is InteractiveObject) && cast(container, InteractiveObject).mouseEnabled ? cast container : null
				};
			}

			var descendantHit = false;
			var i = container.__children.length;
			while (--i >= 0)
			{
				var result = __mouseHit(container.__children[i], stageX, stageY);
				if (result.hit)
				{
					descendantHit = true;
					if (result.target != null) return result;
				}
			}
			ownHit = ownHit || descendantHit;
		}

		var interactive:InteractiveObject = (object is InteractiveObject) ? cast object : null;
		return {hit: ownHit, target: ownHit && interactive != null && interactive.mouseEnabled ? interactive : null};
	}

	@:noCompletion private function __resolveMouseTarget(stageX:Float, stageY:Float):InteractiveObject
	{
		var i = __children.length;
		while (--i >= 0)
		{
			var result = __mouseHit(__children[i], stageX, stageY);
			if (result.hit && result.target != null) return result.target;
		}
		return this;
	}

	@:noCompletion private function __createMouseEvent(type:String, target:InteractiveObject, localTarget:InteractiveObject, bubbles:Bool, cancelable:Bool,
		button:Int, clickCount:Int, delta:Int = 0):MouseEvent
	{
		var local = localTarget.globalToLocal(new Point(__mouseX, __mouseY));
		var event = new MouseEvent(type, bubbles, cancelable, local.x, local.y, null, MouseEvent.__ctrlKey, MouseEvent.__altKey, MouseEvent.__shiftKey,
			MouseEvent.__buttonDown, delta, MouseEvent.__commandKey, MouseEvent.__controlKey, clickCount);
		event.stageX = __mouseX;
		event.stageY = __mouseY;
		event.target = target;
		return event;
	}

	@:noCompletion private function __dispatchMouseTarget(target:DisplayObject, event:MouseEvent):Void
	{
		event.eventPhase = EventPhase.AT_TARGET;
		event.target = target;
		target.__dispatch(event);
	}

	@:noCompletion private function __onMouse(type:String, x:Float, y:Float, button:Int):MouseEvent
	{
		if (button > 2) return null;
		__untransformedMouseX = x;
		__untransformedMouseY = y;
		var inverse = __displayMatrix.clone();
		inverse.invert();
		var stagePoint = inverse.transformPoint(new Point(x, y));
		__mouseX = stagePoint.x;
		__mouseY = stagePoint.y;
		var target = __resolveMouseTarget(__mouseX, __mouseY);
		var stack = __getEventStack(target);
		var clickType:String = null;
		var supportsClickCount = false;

		if (type != null)
		{
			switch (type)
			{
				case MouseEvent.MOUSE_DOWN:
					if (focus != target)
					{
						var allowChange = true;
						if (focus != null)
						{
							var focusEvent = new FocusEvent(FocusEvent.MOUSE_FOCUS_CHANGE, true, true, target, false, 0);
							focus.dispatchEvent(focusEvent);
							allowChange = !focusEvent.isDefaultPrevented();
						}
						if (allowChange) focus = target.__allowMouseFocus() ? target : null;
					}
					__mouseDownLeft = target;
					__primaryMouseButtonDown = true;
					MouseEvent.__buttonDown = true;
					supportsClickCount = true;
				case MouseEvent.MIDDLE_MOUSE_DOWN:
					__mouseDownMiddle = target;
					supportsClickCount = true;
				case MouseEvent.RIGHT_MOUSE_DOWN:
					__mouseDownRight = target;
					supportsClickCount = true;
				case MouseEvent.MOUSE_UP:
					__primaryMouseButtonDown = false;
					MouseEvent.__buttonDown = false;
					if (__mouseDownLeft != null)
					{
						if (__mouseDownLeft == target) clickType = MouseEvent.CLICK;
						else __mouseDownLeft.dispatchEvent(__createMouseEvent(MouseEvent.RELEASE_OUTSIDE, this, this, true, false, button, 0));
						__mouseDownLeft = null;
					}
					supportsClickCount = true;
				case MouseEvent.MIDDLE_MOUSE_UP:
					if (__mouseDownMiddle == target) clickType = MouseEvent.MIDDLE_CLICK;
					__mouseDownMiddle = null;
					supportsClickCount = true;
				case MouseEvent.RIGHT_MOUSE_UP:
					if (__mouseDownRight == target) clickType = MouseEvent.RIGHT_CLICK;
					__mouseDownRight = null;
					supportsClickCount = true;
				default:
			}
		}

		var rawEvent:MouseEvent = null;
		if (type != null)
		{
			rawEvent = __createMouseEvent(type, target, target, true, false, button, supportsClickCount ? __mouseClickCount : 0);
			__dispatchStack(rawEvent, stack);
		}
		if (clickType != null)
		{
			var clickEvent = __createMouseEvent(clickType, target, target, true, false, button, 0);
			__dispatchStack(clickEvent, stack);
		}

		#if lime
		if (Mouse.__cursor == MouseCursor.AUTO && !Mouse.__hidden && window != null)
		{
			var cursor:MouseCursor = __mouseDownLeft == null ? null : __mouseDownLeft.__getCursor();
			if (cursor == null)
			{
				for (item in stack)
				{
					cursor = item.__getCursor();
					if (cursor != null) break;
				}
			}
			window.cursor = cursor == null ? MouseCursor.ARROW : cursor;
		}
		#end

		if (target != __mouseOverTarget && __mouseOverTarget != null)
		{
			__dispatchStack(__createMouseEvent(MouseEvent.MOUSE_OUT, __mouseOverTarget, __mouseOverTarget, true, false, button, 0), __mouseOutStack);
		}
		var i = 0;
		while (i < __rollOutStack.length)
		{
			var item = __rollOutStack[i];
			if (stack.indexOf(item) == -1)
			{
				__rollOutStack.remove(item);
				if (item.hasEventListener(MouseEvent.ROLL_OUT))
				{
					__dispatchMouseTarget(item, __createMouseEvent(MouseEvent.ROLL_OUT, cast item, __mouseOverTarget, false, false, button, 0));
				}
			}
			else i++;
		}

		var newMouseOverTarget:InteractiveObject = null;
		if (target != __mouseOverTarget)
		{
			newMouseOverTarget = target;
			__mouseOverTarget = target;
			__mouseOutStack = stack;
		}
		for (item in stack)
		{
			if (__rollOutStack.indexOf(item) == -1 && __mouseOverTarget != null)
			{
				if (item.hasEventListener(MouseEvent.ROLL_OVER))
				{
					__dispatchMouseTarget(item, __createMouseEvent(MouseEvent.ROLL_OVER, cast item, __mouseOverTarget, false, false, button, 0));
				}
				__rollOutStack.push(item);
			}
		}
		if (newMouseOverTarget != null)
		{
			__dispatchStack(__createMouseEvent(MouseEvent.MOUSE_OVER, newMouseOverTarget, newMouseOverTarget, true, false, button, 0), stack);
		}
		__updateDrag();
		return rawEvent;
	}

	@:noCompletion private function __dispatchPendingMouseEvent():Void
	{
		if (__pendingMouseEvent)
		{
			__pendingMouseEvent = false;
			__onMouse(MouseEvent.MOUSE_MOVE, __pendingMouseX, __pendingMouseY, 0);
		}
		else if (__mouseOverTarget != null)
		{
			__onMouse(null, __untransformedMouseX, __untransformedMouseY, 0);
		}
	}

	@:noCompletion private function __onMouseWheel(deltaY:Float):MouseEvent
	{
		var target = __resolveMouseTarget(__mouseX, __mouseY);
		var event = __createMouseEvent(MouseEvent.MOUSE_WHEEL, target, target, true, true, 0, 0, Std.int(deltaY));
		__dispatchStack(event, __getEventStack(target));
		return event;
	}

	@:noCompletion private function __onWindowLeave():Void
	{
		if (MouseEvent.__buttonDown) return;
		__dispatchPendingMouseEvent();
		__dispatchEvent(new Event(Event.MOUSE_LEAVE));
	}

	#if lime
	@:noCompletion private function __registerLimeModule(application:Application):Void
	{
		this.application = application;
		application.onUpdate.add(__onLimeUpdate);
		if (window != null)
		{
			window.onClose.add(__onLimeWindowClose);
			window.onFocusIn.add(__onLimeWindowFocusIn);
			window.onFocusOut.add(__onLimeWindowFocusOut);
			window.onFullscreen.add(__onLimeWindowFullscreen);
			window.onKeyDown.add(__onLimeKeyDown);
			window.onKeyUp.add(__onLimeKeyUp);
			window.onLeave.add(__onLimeWindowLeave);
			window.onMouseDown.add(__onLimeMouseDown);
			window.onMouseMove.add(__onLimeMouseMove);
			window.onMouseMoveRelative.add(__onLimeMouseMoveRelative);
			window.onMouseUp.add(__onLimeMouseUp);
			window.onMouseWheel.add(__onLimeMouseWheel);
			window.onResize.add(__onLimeWindowResize);
		}
	}

	@:noCompletion private function __unregisterLimeModule(application:Application):Void
	{
		application.onUpdate.remove(__onLimeUpdate);
		if (window != null)
		{
			window.onClose.remove(__onLimeWindowClose);
			window.onFocusIn.remove(__onLimeWindowFocusIn);
			window.onFocusOut.remove(__onLimeWindowFocusOut);
			window.onFullscreen.remove(__onLimeWindowFullscreen);
			window.onKeyDown.remove(__onLimeKeyDown);
			window.onKeyUp.remove(__onLimeKeyUp);
			window.onLeave.remove(__onLimeWindowLeave);
			window.onMouseDown.remove(__onLimeMouseDown);
			window.onMouseMove.remove(__onLimeMouseMove);
			window.onMouseMoveRelative.remove(__onLimeMouseMoveRelative);
			window.onMouseUp.remove(__onLimeMouseUp);
			window.onMouseWheel.remove(__onLimeMouseWheel);
			window.onResize.remove(__onLimeWindowResize);
		}
	}

	@:noCompletion private function __onLimeUpdate(deltaTime:Int):Void
	{
		__deltaTime = deltaTime;
		__dispatchPendingMouseEvent();
	}

	@:noCompletion private function __onLimeWindowClose():Void
	{
		__broadcastEvent(new Event(Event.DEACTIVATE));
	}

	@:noCompletion private function __onLimeWindowFocusIn():Void
	{
		__windowFocusIn();
	}

	@:noCompletion private function __onLimeWindowFocusOut():Void
	{
		__windowFocusOut();
	}

	@:noCompletion private function __onLimeWindowFullscreen():Void
	{
		__syncWindowFullscreen();
	}

	@:noCompletion private function __dispatchKeyboardEvent(type:String, key:KeyCode, modifier:KeyModifier):KeyboardEvent
	{
		var keyCode = Keyboard.__convertKeyCode(key);
		return __dispatchKey(type, Keyboard.__getCharCode(keyCode, modifier.shiftKey, modifier.capsLock), keyCode, Keyboard.__getKeyLocation(key),
			modifier.ctrlKey, modifier.altKey, modifier.shiftKey, modifier.metaKey);
	}

	@:noCompletion private function __onLimeKeyDown(key:KeyCode, modifier:KeyModifier):Void
	{
		if (__dispatchKeyboardEvent(KeyboardEvent.KEY_DOWN, key, modifier).isDefaultPrevented() || __cancelKeySignal) window.onKeyDown.cancel();
	}

	@:noCompletion private function __onLimeKeyUp(key:KeyCode, modifier:KeyModifier):Void
	{
		if (__dispatchKeyboardEvent(KeyboardEvent.KEY_UP, key, modifier).isDefaultPrevented() || __cancelKeySignal) window.onKeyUp.cancel();
	}

	@:noCompletion private function __onLimeMouseDown(x:Float, y:Float, button:Int):Void
	{
		__dispatchPendingMouseEvent();
		var type = switch (button)
		{
			case 1: MouseEvent.MIDDLE_MOUSE_DOWN;
			case 2: MouseEvent.RIGHT_MOUSE_DOWN;
			default: MouseEvent.MOUSE_DOWN;
		};
		__mouseClickCount = window.clickCount;
		__onMouse(type, Std.int(x * window.scale), Std.int(y * window.scale), button);
		if (!showDefaultContextMenu && button == 2) window.onMouseDown.cancel();
	}

	@:noCompletion private function __onLimeMouseMove(x:Float, y:Float):Void
	{
		#if openfl_always_dispatch_mouse_events
		__onMouse(MouseEvent.MOUSE_MOVE, Std.int(x * window.scale), Std.int(y * window.scale), 0);
		#else
		__pendingMouseEvent = true;
		__pendingMouseX = Std.int(x * window.scale);
		__pendingMouseY = Std.int(y * window.scale);
		#end
	}

	@:noCompletion private function __onLimeMouseMoveRelative(x:Float, y:Float):Void {}

	@:noCompletion private function __onLimeMouseUp(x:Float, y:Float, button:Int):Void
	{
		__dispatchPendingMouseEvent();
		var type = switch (button)
		{
			case 1: MouseEvent.MIDDLE_MOUSE_UP;
			case 2: MouseEvent.RIGHT_MOUSE_UP;
			default: MouseEvent.MOUSE_UP;
		};
		__mouseClickCount = window.clickCount;
		__onMouse(type, Std.int(x * window.scale), Std.int(y * window.scale), button);
		if (!showDefaultContextMenu && button == 2) window.onMouseUp.cancel();
	}

	@:noCompletion private function __onLimeMouseWheel(deltaX:Float, deltaY:Float, deltaMode:MouseWheelMode):Void
	{
		__dispatchPendingMouseEvent();
		var delta = deltaMode == MouseWheelMode.PIXELS ? deltaY * window.scale : deltaY;
		if (__onMouseWheel(delta).isDefaultPrevented()) window.onMouseWheel.cancel();
	}

	@:noCompletion private function __onLimeWindowLeave():Void
	{
		__onWindowLeave();
	}

	@:noCompletion private function __onLimeWindowResize(width:Int, height:Int):Void
	{
		__resize();
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
		if (window != null) window.fullscreen = value != StageDisplayState.NORMAL;
		return value;
	}

	@:noCompletion private function get_focus():InteractiveObject return __focus;

	@:noCompletion private function set_focus(value:InteractiveObject):InteractiveObject
	{
		if (__focus == value && (value != null || __cacheFocus == null)) return value;
		var oldFocus = __focus;
		__focus = value;
		__cacheFocus = value;
		if (oldFocus != null)
		{
			__dispatchStack(new FocusEvent(FocusEvent.FOCUS_OUT, true, false, value), __getEventStack(oldFocus));
		}
		if (value != null)
		{
			__dispatchStack(new FocusEvent(FocusEvent.FOCUS_IN, true, false, oldFocus), __getEventStack(value));
		}
		return value;
	}

	@:noCompletion private function get_frameRate():Float return __frameRate;
	@:noCompletion private function set_frameRate(value:Float):Float
	{
		__frameRate = value;
		if (window != null) window.frameRate = value;
		return value;
	}
	@:noCompletion private function get_fullScreenHeight():UInt return stageHeight;
	@:noCompletion private function get_fullScreenSourceRect():Rectangle return __fullScreenSourceRect == null ? null : __fullScreenSourceRect.clone();

	@:noCompletion private function set_fullScreenSourceRect(value:Rectangle):Rectangle
	{
		__fullScreenSourceRect = value == null ? null : value.clone();
		__resize();
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
		__resize();
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

	@:noCompletion private function __applyScaleAndAlign(windowWidth:Float, windowHeight:Float, scaleX:Float, scaleY:Float):Void
	{
		var visibleWidth = __logicalWidth - Math.round((__logicalWidth * scaleX - windowWidth) / scaleX);
		var visibleHeight = __logicalHeight - Math.round((__logicalHeight * scaleY - windowHeight) / scaleY);
		var visibleX = 0.0;
		var visibleY = 0.0;
		switch (align)
		{
			case null:
				visibleX = Math.round((__logicalWidth - visibleWidth) / 2);
				visibleY = Math.round((__logicalHeight - visibleHeight) / 2);
			case StageAlign.BOTTOM_RIGHT:
				visibleX = Math.round(__logicalWidth - visibleWidth);
				visibleY = Math.round(__logicalHeight - visibleHeight);
			case StageAlign.BOTTOM:
				visibleX = Math.round((__logicalWidth - visibleWidth) / 2);
				visibleY = Math.round(__logicalHeight - visibleHeight);
			case StageAlign.BOTTOM_LEFT:
				visibleY = Math.round(__logicalHeight - visibleHeight);
			case StageAlign.RIGHT:
				visibleX = Math.round(__logicalWidth - visibleWidth);
				visibleY = Math.round((__logicalHeight - visibleHeight) / 2);
			case StageAlign.LEFT:
				visibleY = Math.round((__logicalHeight - visibleHeight) / 2);
			case StageAlign.TOP_RIGHT:
				visibleX = Math.round(__logicalWidth - visibleWidth);
			case StageAlign.TOP:
				visibleX = Math.round((__logicalWidth - visibleWidth) / 2);
			default:
		}
		__displayMatrix.translate(-visibleX, -visibleY);
		__displayMatrix.scale(scaleX, scaleY);
	}

	@:noCompletion private function __resize():Void
	{
		if (__displayMatrix == null || __scene == null) return;
		var oldWidth = stageWidth;
		var oldHeight = stageHeight;
		var windowScale = window == null || window.scale <= 0 ? 1.0 : window.scale;
		var windowWidth = window == null ? stageWidth : Math.round(window.width * windowScale);
		var windowHeight = window == null ? stageHeight : Math.round(window.height * windowScale);
		__displayMatrix.identity();
		if (__logicalWidth == 0 || __logicalHeight == 0 || scaleMode == StageScaleMode.NO_SCALE || windowWidth == 0 || windowHeight == 0)
		{
			stageWidth = Math.round(windowWidth / windowScale);
			stageHeight = Math.round(windowHeight / windowScale);
			__displayMatrix.scale(windowScale, windowScale);
		}
		else
		{
			stageWidth = __logicalWidth;
			stageHeight = __logicalHeight;
			switch (scaleMode)
			{
				case StageScaleMode.EXACT_FIT:
					__displayMatrix.scale(windowWidth / __logicalWidth, windowHeight / __logicalHeight);
				case StageScaleMode.NO_BORDER:
					var scale = Math.max(windowWidth / __logicalWidth, windowHeight / __logicalHeight);
					__applyScaleAndAlign(windowWidth, windowHeight, scale, scale);
				default:
					var scale = Math.min(windowWidth / __logicalWidth, windowHeight / __logicalHeight);
					__applyScaleAndAlign(windowWidth, windowHeight, scale, scale);
			}
		}
		FlightScene2D.setScene2DSize(__scene, stageWidth, stageHeight);
		if (oldWidth != stageWidth || oldHeight != stageHeight)
		{
			__setTransformDirty();
			dispatchEvent(new Event(Event.RESIZE));
		}
	}

	@:noCompletion private var __uncaughtErrorEvents:openfl.events.UncaughtErrorEvents;

	@:noCompletion private function __handleError(e:Dynamic):Void {}

	@:noCompletion private function __setLogicalSize(width:Int, height:Int):Void
	{
		__logicalWidth = width;
		__logicalHeight = height;
		__resize();
	}
}
#else
typedef Stage = flash.display.Stage;
#end
