package openfl.display;

#if !flash
import flight.Node as FlightNode;
import openfl.errors.RangeError;
import openfl.events.Event;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:access(openfl.display.DisplayObject)
@:access(openfl.display.Graphics)
@:access(openfl.events.Event)
class DisplayObjectContainer extends InteractiveObject
{
	#if (openfl_enable_experimental_update_queue && !dom)
	public var __updateRequired:Bool = true;
	#end

	/**
		Determines whether or not the children of the object are mouse, or user
		input device, enabled. If an object is enabled, a user can interact with
		it by using a mouse or user input device. The default is
		`true`.

		This property is useful when you create a button with an instance of
		the Sprite class (instead of using the SimpleButton class). When you use a
		Sprite instance to create a button, you can choose to decorate the button
		by using the `addChild()` method to add additional Sprite
		instances. This process can cause unexpected behavior with mouse events
		because the Sprite instances you add as children can become the target
		object of a mouse event when you expect the parent instance to be the
		target object. To ensure that the parent instance serves as the target
		objects for mouse events, you can set the `mouseChildren`
		property of the parent instance to `false`.

		 No event is dispatched by setting this property. You must use the
		`addEventListener()` method to create interactive
		functionality.
	**/
	public var mouseChildren:Bool;
	/**
		Returns the number of children of this object.
	**/
	public var numChildren(get, never):Int;
	/**
		Determines whether the children of the object are tab enabled. Enables or
		disables tabbing for the children of the object. The default is
		`true`.

		**Note:** Do not use the `tabChildren` property with
		Flex. Instead, use the
		`mx.core.UIComponent.hasFocusableChildren` property.

		@throws IllegalOperationError Calling this property of the Stage object
									  throws an exception. The Stage object does
									  not implement this property.
	**/
	public var tabChildren(get, set):Bool;

	@:noCompletion private var __tabChildren:Bool;

	@:noCompletion private function new()
	{
		super();
		mouseChildren = true;
		__tabChildren = true;
		__children = [];
	}

	/**
		Adds a child DisplayObject instance to this DisplayObjectContainer
		instance. The child is added to the front (top) of all other children in
		this DisplayObjectContainer instance.(To add a child to a specific index
		position, use the `addChildAt()` method.)

		If you add a child object that already has a different display object
		container as a parent, the object is removed from the child list of the
		other display object container.

		**Note:** The command `stage.addChild()` can cause
		problems with a published SWF file, including security problems and
		conflicts with other loaded SWF files. There is only one Stage within a
		Flash runtime instance, no matter how many SWF files you load into the
		runtime. So, generally, objects should not be added to the Stage,
		directly, at all. The only object the Stage should contain is the root
		object. Create a DisplayObjectContainer to contain all of the items on the
		display list. Then, if necessary, add that DisplayObjectContainer instance
		to the Stage.

		@param child The DisplayObject instance to add as a child of this
					 DisplayObjectContainer instance.
		@return The DisplayObject instance that you pass in the `child`
				parameter.
		@throws ArgumentError Throws if the child is the same as the parent. Also
							  throws if the caller is a child (or grandchild etc.)
							  of the child being added.
		@event added Dispatched when a display object is added to the display
					 list.

		@see [Adding display objects to the display list](https://books.openfl.org/openfl-developers-guide/display-programming/working-with-display-objects/adding-display-objects-to-the-display-list.html)
	**/
	public function addChild(child:DisplayObject):DisplayObject
	{
		return addChildAt(child, numChildren);
	}

	/**
		Adds a child DisplayObject instance to this DisplayObjectContainer
		instance. The child is added at the index position specified. An index of
		0 represents the back (bottom) of the display list for this
		DisplayObjectContainer object.

		For example, the following example shows three display objects, labeled
		a, b, and c, at index positions 0, 2, and 1, respectively:

		![b over c over a](/images/DisplayObjectContainer_layers.jpg)

		If you add a child object that already has a different display object
		container as a parent, the object is removed from the child list of the
		other display object container.

		@param child The DisplayObject instance to add as a child of this
					 DisplayObjectContainer instance.
		@param index The index position to which the child is added. If you
					 specify a currently occupied index position, the child object
					 that exists at that position and all higher positions are
					 moved up one position in the child list.
		@return The DisplayObject instance that you pass in the `child`
				parameter.
		@throws ArgumentError Throws if the child is the same as the parent. Also
							  throws if the caller is a child (or grandchild etc.)
							  of the child being added.
		@throws RangeError    Throws if the index position does not exist in the
							  child list.
		@event added Dispatched when a display object is added to the display
					 list.

		@see [Adding display objects to the display list](https://books.openfl.org/openfl-developers-guide/display-programming/working-with-display-objects/adding-display-objects-to-the-display-list.html)
	**/
	public function addChildAt(child:DisplayObject, index:Int):DisplayObject
	{
		if (child == null) throw "Error #2007: Parameter child must be non-null.";
		if (child == this) throw "Error #2024: An object cannot be added as a child of itself.";
		if ((child is Stage)) throw "Error #3783: A Stage object cannot be added as the child of another object.";
		if ((child is DisplayObjectContainer) && cast(child, DisplayObjectContainer).contains(this))
			throw "Error #2024: An object cannot be added as a child of one of its children.";
		if (index < 0 || index > __children.length) throw "Invalid index position " + index;

		if (child.parent == this)
		{
			var oldIndex = __children.indexOf(child);
			if (oldIndex != index)
			{
				__children.splice(oldIndex, 1);
				if (index > __children.length) index = __children.length;
				__children.insert(index, child);
				FlightNode.setNodeChildIndex(__flightNode, child.__flightNode, index + __flightChildOffset());
			}
			return child;
		}

		if (child.parent != null) child.parent.removeChild(child);
		__children.insert(index, child);
		child.parent = this;
		FlightNode.addNodeChildAt(__flightNode, child.__flightNode, index + __flightChildOffset());

		var addedToStage = stage != null && child.stage == null;
		if (addedToStage) child.__setStageReference(stage);
		var added = new Event(Event.ADDED, true, false);
		added.target = child;
		child.__dispatchWithCapture(added);
		if (addedToStage)
		{
			var onStage = new Event(Event.ADDED_TO_STAGE, false, false);
			child.__dispatchWithCapture(onStage);
			child.__dispatchChildren(onStage);
		}
		return child;
	}

	/**
		Indicates whether the security restrictions would cause any display
		objects to be omitted from the list returned by calling the
		`DisplayObjectContainer.getObjectsUnderPoint()` method with the
		specified `point` point. By default, content from one domain
		cannot access objects from another domain unless they are permitted to do
		so with a call to the `Security.allowDomain()` method. For more
		information, related to security, see the Flash Player Developer Center
		Topic: [Security](http://www.adobe.com/go/devnet_security_en).

		The `point` parameter is in the coordinate space of the
		Stage, which may differ from the coordinate space of the display object
		container (unless the display object container is the Stage). You can use
		the `globalToLocal()` and the `localToGlobal()`
		methods to convert points between these coordinate spaces.

		@param point The point under which to look.
		@return `true` if the point contains child display objects with
				security restrictions.
	**/
	public function areInaccessibleObjectsUnderPoint(point:Point):Bool return false;

	/**
		Determines whether the specified display object is a child of the
		DisplayObjectContainer instance or the instance itself. The search
		includes the entire display list including this DisplayObjectContainer
		instance. Grandchildren, great-grandchildren, and so on each return
		`true`.

		@param child The child object to test.
		@return `true` if the `child` object is a child of
				the DisplayObjectContainer or the container itself; otherwise
				`false`.
	**/
	public function contains(child:DisplayObject):Bool
	{
		while (child != null && child != this) child = child.parent;
		return child == this;
	}

	/**
		Returns the child display object instance that exists at the specified
		index.

		@param index The index position of the child object.
		@return The child display object at the specified index position.
		@throws RangeError    Throws if the index does not exist in the child
							  list.
		@throws SecurityError This child display object belongs to a sandbox to
							  which you do not have access. You can avoid this
							  situation by having the child movie call
							  `Security.allowDomain()`.

		@see [Traversing the display list](https://books.openfl.org/openfl-developers-guide/display-programming/working-with-display-objects/traversing-the-display-list.html)
	**/
	public function getChildAt(index:Int):DisplayObject
	{
		return index >= 0 && index < __children.length ? __children[index] : null;
	}

	/**
		Returns the child display object that exists with the specified name. If
		more that one child display object has the specified name, the method
		returns the first object in the child list.

		The `getChildAt()` method is faster than the
		`getChildByName()` method. The `getChildAt()` method
		accesses a child from a cached array, whereas the
		`getChildByName()` method has to traverse a linked list to
		access a child.

		@param name The name of the child to return.
		@return The child display object with the specified name.
		@throws SecurityError This child display object belongs to a sandbox to
							  which you do not have access. You can avoid this
							  situation by having the child movie call the
							  `Security.allowDomain()` method.

		@see [Traversing the display list](https://books.openfl.org/openfl-developers-guide/display-programming/working-with-display-objects/traversing-the-display-list.html)
		@see `openfl.display.DisplayObject.name`
	**/
	public function getChildByName(name:String):DisplayObject
	{
		for (child in __children) if (child.name == name) return child;
		return null;
	}

	/**
		Returns the index position of a `child` DisplayObject instance.

		@param child The DisplayObject instance to identify.
		@return The index position of the child display object to identify.
		@throws ArgumentError Throws if the child parameter is not a child of this
							  object.
	**/
	public function getChildIndex(child:DisplayObject):Int return __children.indexOf(child);

	/**
		Returns an array of objects that lie under the specified point and are
		children (or grandchildren, and so on) of this DisplayObjectContainer
		instance. Any child objects that are inaccessible for security reasons are
		omitted from the returned array. To determine whether this security
		restriction affects the returned array, call the
		`areInaccessibleObjectsUnderPoint()` method.

		The `point` parameter is in the coordinate space of the
		Stage, which may differ from the coordinate space of the display object
		container (unless the display object container is the Stage). You can use
		the `globalToLocal()` and the `localToGlobal()`
		methods to convert points between these coordinate spaces.

		@param point The point under which to look.
		@return An array of objects that lie under the specified point and are
				children (or grandchildren, and so on) of this
				DisplayObjectContainer instance.
	**/
	public function getObjectsUnderPoint(point:Point):Array<DisplayObject>
	{
		var result:Array<DisplayObject> = [];
		__collectObjectsUnderPoint(point, result);
		result.reverse();
		return result;
	}

	/**
		Removes the specified `child` DisplayObject instance from the
		child list of the DisplayObjectContainer instance. The `parent`
		property of the removed child is set to `null` , and the object
		is garbage collected if no other references to the child exist. The index
		positions of any display objects above the child in the
		DisplayObjectContainer are decreased by 1.

		The garbage collector reallocates unused memory space. When a variable
		or object is no longer actively referenced or stored somewhere, the
		garbage collector sweeps through and wipes out the memory space it used to
		occupy if no other references to it exist.

		@param child The DisplayObject instance to remove.
		@return The DisplayObject instance that you pass in the `child`
				parameter.
		@throws ArgumentError Throws if the child parameter is not a child of this
							  object.
	**/
	public function removeChild(child:DisplayObject):DisplayObject
	{
		if (child == null || child.parent != this) return child;
		child.__dispatchWithCapture(new Event(Event.REMOVED, true, false));
		if (child.stage != null)
		{
			child.__dispatchWithCapture(new Event(Event.REMOVED_FROM_STAGE, false, false));
			child.__dispatchChildren(new Event(Event.REMOVED_FROM_STAGE, false, false));
			child.__setStageReference(null);
		}
		FlightNode.removeNodeChild(__flightNode, child.__flightNode);
		__children.remove(child);
		child.parent = null;
		return child;
	}

	/**
		Removes a child DisplayObject from the specified `index`
		position in the child list of the DisplayObjectContainer. The
		`parent` property of the removed child is set to
		`null`, and the object is garbage collected if no other
		references to the child exist. The index positions of any display objects
		above the child in the DisplayObjectContainer are decreased by 1.

		The garbage collector reallocates unused memory space. When a variable
		or object is no longer actively referenced or stored somewhere, the
		garbage collector sweeps through and wipes out the memory space it used to
		occupy if no other references to it exist.

		@param index The child index of the DisplayObject to remove.
		@return The DisplayObject instance that was removed.
		@throws RangeError    Throws if the index does not exist in the child
							  list.
		@throws SecurityError This child display object belongs to a sandbox to
							  which the calling object does not have access. You
							  can avoid this situation by having the child movie
							  call the `Security.allowDomain()` method.
	**/
	public function removeChildAt(index:Int):DisplayObject
	{
		return index >= 0 && index < __children.length ? removeChild(__children[index]) : null;
	}

	/**
		Removes all `child` DisplayObject instances from the child list of the DisplayObjectContainer
		instance. The `parent` property of the removed children is set to `null`, and the objects are
		garbage collected if no other references to the children exist.

		The garbage collector reallocates unused memory space. When a variable or object is no
		longer actively referenced or stored somewhere, the garbage collector sweeps through and
		wipes out the memory space it used to occupy if no other references to it exist.
		@param	beginIndex	The beginning position. A value smaller than 0 throws a `RangeError`.
		@param	endIndex	The ending position. A value smaller than 0 throws a `RangeError`.
	**/
	public function removeChildren(beginIndex:Int = 0, endIndex:Int = 0x7FFFFFFF):Void
	{
		if (endIndex == 0x7FFFFFFF) endIndex = __children.length - 1;
		if (__children.length == 0 || beginIndex >= __children.length) return;
		if (beginIndex < 0 || endIndex < beginIndex || endIndex >= __children.length) throw new RangeError("The supplied index is out of bounds.");
		var count = endIndex - beginIndex + 1;
		while (count-- > 0) removeChildAt(beginIndex);
	}

	/**
		Changes the position of an existing child in the display object container.
		This affects the layering of child objects. For example, the following
		example shows three display objects, labeled a, b, and c, at index
		positions 0, 1, and 2, respectively:

		![c over b over a](/images/DisplayObjectContainerSetChildIndex1.jpg)

		When you use the `setChildIndex()` method and specify an
		index position that is already occupied, the only positions that change
		are those in between the display object's former and new position. All
		others will stay the same. If a child is moved to an index LOWER than its
		current index, all children in between will INCREASE by 1 for their index
		reference. If a child is moved to an index HIGHER than its current index,
		all children in between will DECREASE by 1 for their index reference. For
		example, if the display object container in the previous example is named
		`container`, you can swap the position of the display objects
		labeled a and b by calling the following code:

		```haxe
		container.setChildIndex(container.getChildAt(1), 0);
		```

		This code results in the following arrangement of objects:

		![c over a over b](/images/DisplayObjectContainerSetChildIndex2.jpg)

		@param child The child DisplayObject instance for which you want to change
					 the index number.
		@param index The resulting index number for the `child` display
					 object.
		@throws ArgumentError Throws if the child parameter is not a child of this
							  object.
		@throws RangeError    Throws if the index does not exist in the child
							  list.
	**/
	public function setChildIndex(child:DisplayObject, index:Int):Void
	{
		if (child == null || child.parent != this || index < 0 || index >= __children.length) return;
		__children.remove(child);
		__children.insert(index, child);
		FlightNode.setNodeChildIndex(__flightNode, child.__flightNode, index + __flightChildOffset());
	}

	/**
		Recursively stops the timeline execution of all MovieClips rooted at this object.

		Child display objects belonging to a sandbox to which the excuting code does not
		have access are ignored.

		**Note:** Streaming media playback controlled via a NetStream object will not be
		stopped.
	**/
	public function stopAllMovieClips():Void __stopAllMovieClips();

	/**
		Swaps the z-order (front-to-back order) of the two specified child
		objects. All other child objects in the display object container remain in
		the same index positions.

		@param child1 The first child object.
		@param child2 The second child object.
		@throws ArgumentError Throws if either child parameter is not a child of
							  this object.
	**/
	public function swapChildren(child1:DisplayObject, child2:DisplayObject):Void
	{
		if (child1 == null || child2 == null || child1.parent != this || child2.parent != this) return;
		var index1 = __children.indexOf(child1);
		var index2 = __children.indexOf(child2);
		__children[index1] = child2;
		__children[index2] = child1;
		FlightNode.swapNodeChildren(__flightNode, child1.__flightNode, child2.__flightNode);
	}

	/**
		Swaps the z-order (front-to-back order) of the child objects at the two
		specified index positions in the child list. All other child objects in
		the display object container remain in the same index positions.

		@param index1 The index position of the first child object.
		@param index2 The index position of the second child object.
		@throws RangeError If either index does not exist in the child list.
	**/
	public function swapChildrenAt(index1:Int, index2:Int):Void
	{
		if (index1 < 0 || index2 < 0 || index1 >= __children.length || index2 >= __children.length) return;
		var child = __children[index1];
		__children[index1] = __children[index2];
		__children[index2] = child;
		var offset = __flightChildOffset();
		FlightNode.swapNodeChildrenAt(__flightNode, index1 + offset, index2 + offset);
	}

	@:noCompletion private function __collectObjectsUnderPoint(point:Point, result:Array<DisplayObject>):Void
	{
		if (!__isPointInScrollRect(point.x, point.y)) return;
		var i = __children.length;
		while (--i >= 0)
		{
			var child = __children[i];
			if (!child.visible) continue;
			if ((child is DisplayObjectContainer)) cast(child, DisplayObjectContainer).__collectObjectsUnderPoint(point, result);
			var ownHit = child.__isPointInScrollRect(point.x, point.y) && child.__graphics != null
				? child.__graphics.__hitTest(point.x, point.y, false)
				: !(child is DisplayObjectContainer) && child.__hitTest(point.x, point.y, false);
			if (ownHit) result.push(child);
		}
	}

	@:noCompletion private inline function __flightChildOffset():Int
	{
		return __graphics == null ? 0 : 1;
	}

	@:noCompletion private override function __dispatchChildren(event:Event):Void
	{
		for (child in __children)
		{
			var childEvent = new Event(event.type, event.bubbles, event.cancelable);
			child.__dispatchWithCapture(childEvent);
			child.__dispatchChildren(childEvent);
		}
	}

	@:noCompletion private override function __getBounds(rect:Rectangle, matrix:Matrix):Void
	{
		super.__getBounds(rect, matrix);
		var hasBounds = !rect.isEmpty();
		for (child in __children)
		{
			var childMatrix = child.__transform.clone();
			childMatrix.concat(matrix);
			var childRect = new Rectangle();
			child.__getBounds(childRect, childMatrix);
			if (child.__hasBoundsContent())
			{
				if (hasBounds) rect.copyFrom(rect.union(childRect)); else rect.copyFrom(childRect);
				hasBounds = true;
			}
		}
	}

	@:noCompletion private override function __hasBoundsContent():Bool
	{
		if (super.__hasBoundsContent()) return true;
		for (child in __children) if (child.__hasBoundsContent()) return true;
		return false;
	}

	@:noCompletion private override function __hasFlightBoundsContent():Bool
	{
		if (super.__hasFlightBoundsContent()) return true;
		for (child in __children) if (child.__hasFlightBoundsContent()) return true;
		return false;
	}

	@:noCompletion private override function __hitTest(x:Float, y:Float, shapeFlag:Bool):Bool
	{
		if (!__isPointInScrollRect(x, y)) return false;
		if (super.__hitTest(x, y, shapeFlag)) return true;
		var i = __children.length;
		while (--i >= 0) if (__children[i].__hitTest(x, y, shapeFlag)) return true;
		return false;
	}

	@:noCompletion private override function __enterFrame(deltaTime:Int):Void
	{
		for (child in __children) child.__enterFrame(deltaTime);
	}

	@:noCompletion private override function __setStageReference(value:Stage):Void
	{
		super.__setStageReference(value);
		for (child in __children) child.__setStageReference(value);
	}

	@:noCompletion private override function __stopAllMovieClips():Void
	{
		for (child in __children) child.__stopAllMovieClips();
	}

	@:noCompletion private function get_numChildren():Int return __children.length;
	@:noCompletion private function get_tabChildren():Bool return __tabChildren;

	@:noCompletion private function set_tabChildren(value:Bool):Bool
	{
		if (__tabChildren != value)
		{
			__tabChildren = value;
			dispatchEvent(new Event(Event.TAB_CHILDREN_CHANGE, true, false));
		}
		return value;
	}
}
#else
typedef DisplayObjectContainer = flash.display.DisplayObjectContainer;
#end
