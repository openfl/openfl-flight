package openfl.display;

#if !flash
import flight.Interaction as FlightInteraction;
import openfl.errors.RangeError;
import openfl.geom.Rectangle;

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:access(openfl.display.DisplayObject)
class InteractiveObject extends DisplayObject
{
	/**
		Specifies whether the object receives `doubleClick` events. The
		default value is `false`, which means that by default an
		InteractiveObject instance does not receive `doubleClick`
		events. If the `doubleClickEnabled` property is set to
		`true`, the instance receives `doubleClick` events
		within its bounds. The `mouseEnabled` property of the
		InteractiveObject instance must also be set to `true` for the
		object to receive `doubleClick` events.

		No event is dispatched by setting this property. You must use the
		`addEventListener()` method to add an event listener for the
		`doubleClick` event.
	**/
	public var doubleClickEnabled:Bool;
	/**
		Specifies whether this object displays a focus rectangle. It can take
		one of three values: `true`, `false`, or `null`. Values of `true` and
		`false` work as expected, specifying whether or not the focus
		rectangle appears. A value of `null` indicates that this object obeys
		the `stageFocusRect` property of the Stage.
	**/
	public var focusRect:Null<Bool>;
	/**
		Specifies whether this object receives mouse, or other user input,
		messages. The default value is `true`, which means that by
		default any InteractiveObject instance that is on the display list
		receives mouse events or other user input events. If
		`mouseEnabled` is set to `false`, the instance does
		not receive any mouse events (or other user input events like keyboard
		events). Any children of this instance on the display list are not
		affected. To change the `mouseEnabled` behavior for all
		children of an object on the display list, use
		`openfl.display.DisplayObjectContainer.mouseChildren`.

		 No event is dispatched by setting this property. You must use the
		`addEventListener()` method to create interactive
		functionality.
	**/
	public var mouseEnabled(get, set):Bool;
	/**
		Specifies whether a virtual keyboard (an on-screen, software keyboard)
		should display when this InteractiveObject instance receives focus.

		By default, the value is `false` and focusing an
		InteractiveObject instance does not raise a soft keyboard. If the
		`needsSoftKeyboard` property is set to `true`, the
		runtime raises a soft keyboard when the InteractiveObject instance is
		ready to accept user input. An InteractiveObject instance is ready to
		accept user input after a programmatic call to set the Stage
		`focus` property or a user interaction, such as a "tap." If the
		client system has a hardware keyboard available or does not support
		virtual keyboards, then the soft keyboard is not raised.

		The InteractiveObject instance dispatches
		`softKeyboardActivating`, `softKeyboardActivate`,
		and `softKeyboardDeactivate` events when the soft keyboard
		raises and lowers.

		**Note:** This property is not supported in AIR applications on
		iOS.
	**/
	public var needsSoftKeyboard:Bool;
	/**
		Defines the area that should remain on-screen when a soft keyboard is
		displayed.
		If the `needsSoftKeyboard` property of this InteractiveObject is
		`true`, then the runtime adjusts the display as needed to keep the
		object in view while the user types. Ordinarily, the runtime uses the
		object bounds obtained from the `DisplayObject.getBounds()` method.
		You can specify a different area using this
		`softKeyboardInputAreaOfInterest` property.

		Specify the `softKeyboardInputAreaOfInterest` in stage coordinates.

		**Note:** On Android, the `softKeyboardInputAreaOfInterest` is not
		respected in landscape orientations.
	**/
	public var softKeyboardInputAreaOfInterest:Rectangle;
	/**
		Specifies whether this object is in the tab order. If this object is
		in the tab order, the value is `true`; otherwise, the value is
		`false`. By default, the value is `false`, except for the following:
		* For a SimpleButton object, the value is `true`.
		* For a TextField object with `type = "input"`, the value is `true`.
		* For a Sprite object or MovieClip object with `buttonMode = true`,
		the value is `true`.
	**/
	public var tabEnabled(get, set):Bool;
	/**
		Specifies the tab ordering of objects in a SWF file. The `tabIndex`
		property is -1 by default, meaning no tab index is set for the object.

		If any currently displayed object in the SWF file contains a
		`tabIndex` property, automatic tab ordering is disabled, and the tab
		ordering is calculated from the `tabIndex` properties of objects in
		the SWF file. The custom tab ordering includes only objects that have
		`tabIndex` properties.

		The `tabIndex` property can be a non-negative integer. The objects are
		ordered according to their `tabIndex` properties, in ascending order.
		An object with a `tabIndex` value of 1 precedes an object with a
		`tabIndex` value of 2. Do not use the same `tabIndex` value for
		multiple objects.

		The custom tab ordering that the `tabIndex` property defines is
		_flat_. This means that no attention is paid to the hierarchical
		relationships of objects in the SWF file. All objects in the SWF file
		with `tabIndex` properties are placed in the tab order, and the tab
		order is determined by the order of the `tabIndex` values.

		**Note:** To set the tab order for TLFTextField instances, cast the
		display object child of the TLFTextField as an InteractiveObject, then
		set the `tabIndex` property. For example:

		```haxe
		cast(tlfInstance.getChildAt(1), InteractiveObject).tabIndex = 3;
		```

		To reverse the tab order from the default setting for three instances of
		a TLFTextField object (`tlfInstance1`, `tlfInstance2` and
		`tlfInstance3`), use:

		```haxe
		cast(tlfInstance1.getChildAt(1), InteractiveObject).tabIndex = 3;
		cast(tlfInstance2.getChildAt(1), InteractiveObject).tabIndex = 2;
		cast(tlfInstance3.getChildAt(1), InteractiveObject).tabIndex = 1;
		```
	**/
	public var tabIndex(get, set):Int;

	@:noCompletion private var __mouseEnabled:Bool;
	@:noCompletion private var __tabEnabled:Null<Bool>;
	@:noCompletion private var __tabIndex:Int;

	/**
		Calling the `new InteractiveObject()` constructor throws an
		`ArgumentError` exception. You can, however, call constructors
		for the following subclasses of InteractiveObject:

		* `new SimpleButton()`
		* `new TextField()`
		* `new Loader()`
		* `new Sprite()`
		* `new MovieClip()`
	**/
	public function new()
	{
		super();
		doubleClickEnabled = false;
		__mouseEnabled = true;
		needsSoftKeyboard = false;
		__tabEnabled = null;
		__tabIndex = -1;
		FlightInteraction.setNodeHitTestEnabled(__flightNode, true);
		FlightInteraction.setNodeFocusable(__flightNode, false);
		FlightInteraction.setNodeTabIndex(__flightNode, -1);
	}

	#if !openfl_strict
	/**
		Raises a virtual keyboard.

		Calling this method focuses the InteractiveObject instance and raises
		the soft keyboard, if necessary. The `needsSoftKeyboard` must
		also be `true`. A keyboard is not raised if a hardware keyboard
		is available, or if the client system does not support virtual
		keyboards.

		**Note:** This method is not supported in AIR applications on
		iOS.

		@return A value of `true` means that the soft keyboard request
				was granted; `false` means that the soft keyboard was
				not raised.
	**/
	public function requestSoftKeyboard():Bool
	{
		return false;
	}
	#end

	@:noCompletion private function __allowMouseFocus():Bool return mouseEnabled && tabEnabled;

	@:noCompletion private function __tabTest(stack:Array<InteractiveObject>):Void
	{
		if (tabEnabled) stack.push(this);
	}

	@:noCompletion private function get_mouseEnabled():Bool return __mouseEnabled;

	@:noCompletion private function set_mouseEnabled(value:Bool):Bool
	{
		__mouseEnabled = value;
		FlightInteraction.setNodeHitTestEnabled(__flightNode, value);
		return value;
	}

	@:noCompletion private function get_tabEnabled():Bool return __tabEnabled == true;

	@:noCompletion private function set_tabEnabled(value:Bool):Bool
	{
		if (__tabEnabled != value)
		{
			__tabEnabled = value;
			FlightInteraction.setNodeFocusable(__flightNode, value);
			dispatchEvent(new openfl.events.Event(openfl.events.Event.TAB_ENABLED_CHANGE, true, false));
		}
		return value;
	}

	@:noCompletion private function get_tabIndex():Int return __tabIndex;

	@:noCompletion private function set_tabIndex(value:Int):Int
	{
		if (__tabIndex != value)
		{
			if (value < -1) throw new RangeError("Parameter tabIndex must be a non-negative number; got " + value);
			__tabIndex = value;
			FlightInteraction.setNodeTabIndex(__flightNode, value);
			dispatchEvent(new openfl.events.Event(openfl.events.Event.TAB_INDEX_CHANGE, true, false));
		}
		return value;
	}
}
#else
typedef InteractiveObject = flash.display.InteractiveObject;
#end
