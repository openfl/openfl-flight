package harness.scenarios;

import openfl.Lib;
import openfl.display.DisplayObject;
import openfl.display.InteractiveObject;
import openfl.display.MovieClip;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.display.Stage;
import openfl.display.StageScaleMode;
import openfl.display.Window;
import openfl.events.Event;
import openfl.events.FocusEvent;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.ui.Keyboard;
import openfl.ui.KeyLocation;
import openfl.ui.Mouse;
import openfl.geom.Rectangle;
#if harness_capture
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.MouseWheelMode;
#end

class EventAdvancedScenario
{
	public static function run():Dynamic
	{
		return {
			broadcast: testBroadcast(),
			frameAndRender: testFrameAndRender(),
			windowFocus: testWindowFocus(),
			keyboard: testKeyboard(),
			mouseRoute: testMouseRoute(),
			mouseHitTesting: testMouseHitTesting(),
			mouseTransitions: testMouseTransitions(),
			mousePendingAndWheel: testMousePendingAndWheel(),
			focusRoute: testFocusRoute(),
			tabCandidates: testTabCandidates(),
			lifecycleReuse: testLifecycleReuse(),
			lifecycleMutation: testLifecycleMutation(),
			directFocusRemoval: testDirectFocusRemoval(),
			postDispatchClone: testPostDispatchClone()
		};
	}

	private static function testBroadcast():Dynamic
	{
		var stage = createStage();
		var parent = namedSprite("parent");
		var child = namedSprite("child");
		var first = namedSprite("first");
		var second = namedSprite("second");
		var late = namedSprite("late");
		stage.addChild(parent);
		parent.addChild(child);
		var log:Array<String> = [];
		var shared:Event = null;
		var allShared = true;
		var captureCalls = 0;
		var secondListener:Event->Void = function(_:Event):Void log.push("second");
		var lateListener:Event->Void = function(event:Event):Void {
			log.push("late");
			allShared = allShared && event == shared;
		};
		var firstListener:Event->Void = function(event:Event):Void {
			log.push("first");
			shared = event;
			second.removeEventListener(Event.ENTER_FRAME, secondListener);
			late.addEventListener(Event.ENTER_FRAME, lateListener);
		};
		first.addEventListener(Event.ENTER_FRAME, firstListener);
		second.addEventListener(Event.ENTER_FRAME, secondListener);
		parent.addEventListener(Event.ENTER_FRAME, function(_:Event):Void captureCalls++, true);
		child.addEventListener(Event.ENTER_FRAME, function(event:Event):Void {
			log.push("child");
			allShared = allShared && event == shared;
		});
		var event = new Event(Event.ENTER_FRAME);
		@:privateAccess stage.__broadcastEvent(event);
		var result = {
			log: log.join(","),
			allShared: allShared,
			captureCalls: captureCalls,
			target: objectName(event.target),
			currentTarget: objectName(event.currentTarget),
			phase: cast event.eventPhase
		};
		first.removeEventListener(Event.ENTER_FRAME, firstListener);
		second.removeEventListener(Event.ENTER_FRAME, secondListener);
		late.removeEventListener(Event.ENTER_FRAME, lateListener);
		return result;
	}

	private static function testFrameAndRender():Dynamic
	{
		var stage = createStage();
		var target = new Sprite();
		stage.addChild(target);
		var log:Array<String> = [];
		target.addEventListener(Event.ENTER_FRAME, function(_:Event):Void log.push("enter"));
		target.addEventListener(Event.FRAME_CONSTRUCTED, function(_:Event):Void log.push("constructed"));
		target.addEventListener(Event.EXIT_FRAME, function(_:Event):Void log.push("exit"));
		target.addEventListener(Event.RENDER, function(_:Event):Void log.push("render"));
		stage.invalidate();
		#if harness_capture
		@:privateAccess stage.__broadcastEvent(new Event(Event.ENTER_FRAME));
		@:privateAccess stage.__broadcastEvent(new Event(Event.FRAME_CONSTRUCTED));
		@:privateAccess stage.__broadcastEvent(new Event(Event.EXIT_FRAME));
		var beforeDraw = log.join(",");
		@:privateAccess stage.__broadcastEvent(new Event(Event.RENDER));
		#else
		@:privateAccess stage.__advanceFrame();
		var beforeDraw = log.join(",");
		@:privateAccess stage.__renderBeforeDraw();
		@:privateAccess stage.__renderBeforeDraw();
		#end
		return {
			beforeDraw: beforeDraw,
			afterDraw: log.join(",")
		};
	}

	private static function testFocusRoute():Dynamic
	{
		var stage = createStage();
		var parent = namedSprite("parent");
		var oldFocus = namedSprite("old");
		var newFocus = namedSprite("new");
		stage.addChild(parent);
		parent.addChild(oldFocus);
		parent.addChild(newFocus);
		stage.focus = oldFocus;
		var log:Array<String> = [];
		stage.addEventListener(FocusEvent.FOCUS_OUT, function(event:FocusEvent):Void {
			log.push("stage-first:" + objectName(event.relatedObject));
			event.stopPropagation();
		}, true);
		stage.addEventListener(FocusEvent.FOCUS_OUT, function(_:FocusEvent):Void log.push("stage-second"), true);
		parent.addEventListener(FocusEvent.FOCUS_OUT, function(_:FocusEvent):Void log.push("parent"), true);
		oldFocus.addEventListener(FocusEvent.FOCUS_OUT, function(_:FocusEvent):Void log.push("old"));
		newFocus.addEventListener(FocusEvent.FOCUS_IN, function(event:FocusEvent):Void log.push("new-in:" + objectName(event.relatedObject)));
		stage.focus = newFocus;
		return {
			log: log.join(","),
			focus: objectName(stage.focus)
		};
	}

	private static function testWindowFocus():Dynamic
	{
		var stage = createStage();
		var focused = namedSprite("focused");
		stage.addChild(focused);
		stage.focus = focused;
		var log:Array<String> = [];
		focused.addEventListener(Event.ACTIVATE, function(_:Event):Void log.push("activate"));
		focused.addEventListener(Event.DEACTIVATE, function(_:Event):Void log.push("deactivate"));
		#if harness_capture
		@:privateAccess stage.__broadcastEvent(new Event(Event.DEACTIVATE));
		stage.focus = null;
		@:privateAccess stage.__broadcastEvent(new Event(Event.ACTIVATE));
		var cached = "focused";
		#else
		@:privateAccess stage.__windowFocusOut();
		@:privateAccess stage.__windowFocusIn();
		var cached = objectName(@:privateAccess stage.__cacheFocus);
		#end
		return {
			log: log.join(","),
			focus: objectName(stage.focus),
			cached: cached
		};
	}

	private static function testKeyboard():Dynamic
	{
		var stage = createStage();
		var target = namedSprite("target");
		stage.addChild(target);
		stage.focus = target;
		@:privateAccess stage.__macKeyboard = true;
		var log:Array<String> = [];
		var macFields:Dynamic = null;
		target.addEventListener(KeyboardEvent.KEY_DOWN, function(event:KeyboardEvent):Void {
			log.push("key:" + event.keyCode);
			if (event.keyCode == Keyboard.C)
			{
				macFields = {
					ctrlKey: event.ctrlKey,
					controlKey: event.controlKey,
					commandKey: event.commandKey
				};
			}
			if (event.keyCode == Keyboard.X) event.preventDefault();
		});
		target.addEventListener(Event.COPY, function(_:Event):Void log.push("copy"));
		target.addEventListener(Event.CUT, function(_:Event):Void log.push("cut"));
		var commandCanceled = dispatchKey(stage, KeyboardEvent.KEY_DOWN, 99, Keyboard.C, 99, false, false, false, true);
		var preventedCanceled = dispatchKey(stage, KeyboardEvent.KEY_DOWN, 120, Keyboard.X, 120, false, false, false, true);

		target.buttonMode = true;
		target.focusRect = true;
		target.x = 2;
		target.y = 3;
		@:privateAccess stage.__mouseX = 12;
		@:privateAccess stage.__mouseY = 34;
		var activation:Array<String> = [];
		var clickFields:Dynamic = null;
		target.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):Void {
			activation.push("click");
			clickFields = {
				localX: event.localX,
				localY: event.localY,
				stageX: event.stageX,
				stageY: event.stageY,
				clickCount: event.clickCount
			};
		});
		target.addEventListener(KeyboardEvent.KEY_UP, function(_:KeyboardEvent):Void activation.push("keyUp"));
		dispatchKey(stage, KeyboardEvent.KEY_UP, 32, Keyboard.SPACE, 32, false, false, false, false);

		var tabStage = createStage();
		var first = namedSprite("first");
		var second = namedSprite("second");
		first.tabEnabled = true;
		second.tabEnabled = true;
		tabStage.addChild(first);
		tabStage.addChild(second);
		tabStage.focus = first;
		var veto = true;
		var tabLog:Array<String> = [];
		first.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, function(event:FocusEvent):Void {
			tabLog.push("change:" + objectName(event.relatedObject) + ":" + event.shiftKey);
			if (veto) event.preventDefault();
		});
		var vetoCanceled = dispatchKey(tabStage, KeyboardEvent.KEY_DOWN, 9, Keyboard.TAB, 9, false, false, false, false);
		var afterVeto = objectName(tabStage.focus);
		veto = false;
		var moveCanceled = dispatchKey(tabStage, KeyboardEvent.KEY_DOWN, 9, Keyboard.TAB, 9, false, false, false, false);
		return {
			log: log.join(","),
			macFields: macFields,
			commandCanceled: commandCanceled,
			preventedCanceled: preventedCanceled,
			activation: activation.join(","),
			clickFields: clickFields,
			tab: {
				log: tabLog.join(","),
				vetoCanceled: vetoCanceled,
				afterVeto: afterVeto,
				moveCanceled: moveCanceled,
				afterMove: objectName(tabStage.focus)
			}
		};
	}

	private static function dispatchKey(stage:Stage, type:String, rawKeyCode:Int, keyCode:Int, charCode:Int, control:Bool, alt:Bool, shift:Bool,
		command:Bool):Bool
	{
		#if harness_capture
		var signal = new lime.app.Event<KeyCode->KeyModifier->Void>();
		if (type == KeyboardEvent.KEY_DOWN) Reflect.setField(stage.window, "onKeyDown", signal);
		else Reflect.setField(stage.window, "onKeyUp", signal);
		var modifier:Int = 0;
		if (control) modifier |= cast KeyModifier.LEFT_CTRL;
		if (alt) modifier |= cast KeyModifier.LEFT_ALT;
		if (shift) modifier |= cast KeyModifier.LEFT_SHIFT;
		if (command) modifier |= cast KeyModifier.LEFT_META;
		@:privateAccess stage.__onKey(type, cast(rawKeyCode, KeyCode), cast(modifier, KeyModifier));
		return signal.canceled;
		#else
		var event = @:privateAccess stage.__dispatchKey(type, charCode, keyCode, KeyLocation.STANDARD, control, alt, shift, command);
		return event.isDefaultPrevented() || @:privateAccess stage.__cancelKeySignal;
		#end
	}

	private static function testMouseRoute():Dynamic
	{
		var stage = createStage();
		setWindowSize(stage, 200, 200);
		stage.scaleMode = StageScaleMode.SHOW_ALL;
		@:privateAccess stage.__setLogicalSize(100, 100);
		var parent = namedSprite("parent");
		var target = filledSprite("target", 20, 20);
		var oldFocus = namedSprite("oldFocus");
		target.x = 5;
		target.y = 5;
		target.tabEnabled = true;
		stage.addChild(parent);
		parent.addChild(target);
		stage.addChild(oldFocus);
		stage.focus = oldFocus;
		@:privateAccess MouseEvent.__ctrlKey = true;
		@:privateAccess MouseEvent.__controlKey = true;
		@:privateAccess MouseEvent.__commandKey = false;
		@:privateAccess MouseEvent.__altKey = true;
		@:privateAccess MouseEvent.__shiftKey = true;
		var log:Array<String> = [];
		var downFields:Dynamic = null;
		var parentLocal:Dynamic = null;
		var upCount = -1;
		var clickCount = -1;
		oldFocus.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, function(event:FocusEvent):Void {
			log.push("focus:" + objectName(event.relatedObject));
		});
		target.addEventListener(MouseEvent.MOUSE_DOWN, function(event:MouseEvent):Void {
			log.push("down");
			downFields = mouseFields(event);
		});
		parent.addEventListener(MouseEvent.MOUSE_DOWN, function(event:MouseEvent):Void {
			parentLocal = {x: event.localX, y: event.localY};
		});
		target.addEventListener(MouseEvent.MOUSE_UP, function(event:MouseEvent):Void {
			log.push("up");
			upCount = event.clickCount;
		});
		target.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):Void {
			log.push("click");
			clickCount = event.clickCount;
		});
		stage.addEventListener(MouseEvent.MOUSE_MOVE, function(event:MouseEvent):Void log.push("fallback:" + objectName(event.target)));
		dispatchMouse(stage, MouseEvent.MOUSE_DOWN, 20, 20, 0, 2);
		dispatchMouse(stage, MouseEvent.MOUSE_UP, 20, 20, 0, 2);
		dispatchMouse(stage, MouseEvent.MOUSE_MOVE, 180, 180, 0, 0);
		return {
			log: log.join(","),
			down: downFields,
			parentLocal: parentLocal,
			upClickCount: upCount,
			clickClickCount: clickCount,
			focus: objectName(stage.focus),
			stageMouse: {x: stage.mouseX, y: stage.mouseY}
		};
	}

	private static function testMouseHitTesting():Dynamic
	{
		var stage = createStage();
		var background = filledSprite("background", 200, 100);
		stage.addChild(background);

		var masked = filledSprite("masked", 30, 20);
		var mask = filledSprite("mask", 10, 20);
		masked.mask = mask;
		stage.addChild(masked);
		stage.addChild(mask);

		var scrolled = filledSprite("scrolled", 30, 20);
		scrolled.x = 40;
		scrolled.scrollRect = new Rectangle(0, 0, 10, 20);
		stage.addChild(scrolled);

		var hitOwner = namedSprite("hitOwner");
		var hitArea = filledSprite("hitArea", 20, 20);
		hitArea.x = 80;
		hitArea.mouseEnabled = false;
		hitOwner.hitArea = hitArea;
		stage.addChild(hitOwner);
		stage.addChild(hitArea);

		var shapeOwner = namedSprite("shapeOwner");
		shapeOwner.x = 120;
		var shape = new Shape();
		shape.graphics.beginFill(0xFFFFFF);
		shape.graphics.drawRect(0, 0, 20, 20);
		shapeOwner.addChild(shape);
		stage.addChild(shapeOwner);

		var hidden = filledSprite("hidden", 20, 20);
		hidden.x = 150;
		hidden.visible = false;
		stage.addChild(hidden);

		var targets:Array<String> = [];
		stage.addEventListener(MouseEvent.MOUSE_MOVE, function(event:MouseEvent):Void targets.push(objectName(event.target)));
		for (x in [5, 20, 45, 60, 85, 125, 155]) dispatchMouse(stage, MouseEvent.MOUSE_MOVE, x, 5, 0, 0);
		return targets;
	}

	private static function testMouseTransitions():Dynamic
	{
		var stage = createStage();
		var leftParent = namedSprite("leftParent");
		var rightParent = namedSprite("rightParent");
		var left = filledSprite("left", 20, 20);
		var right = filledSprite("right", 20, 20);
		rightParent.x = 40;
		leftParent.addChild(left);
		rightParent.addChild(right);
		stage.addChild(leftParent);
		stage.addChild(rightParent);
		var log:Array<String> = [];
		var relatedAllNull = true;
		for (object in [stage, leftParent, left, rightParent, right])
		{
			for (type in [MouseEvent.MOUSE_OUT, MouseEvent.ROLL_OUT, MouseEvent.ROLL_OVER, MouseEvent.MOUSE_OVER])
			{
				object.addEventListener(type, function(event:MouseEvent):Void {
					relatedAllNull = relatedAllNull && event.relatedObject == null;
					log.push(type + ":" + objectName(event.currentTarget) + ":" + objectName(event.target) + ":" + event.bubbles + ":"
						+ event.localX + ":" + event.localY);
				});
			}
		}
		dispatchMouse(stage, MouseEvent.MOUSE_MOVE, 5, 5, 0, 0);
		log.resize(0);
		dispatchMouse(stage, MouseEvent.MOUSE_MOVE, 45, 5, 0, 0);
		return {
			log: log,
			relatedAllNull: relatedAllNull
		};
	}

	private static function testMousePendingAndWheel():Dynamic
	{
		var stage = createStage();
		var target = filledSprite("target", 30, 30);
		stage.addChild(target);
		var log:Array<String> = [];
		target.addEventListener(MouseEvent.MOUSE_MOVE, function(event:MouseEvent):Void log.push("move:" + event.stageX + ":" + event.stageY));
		target.addEventListener(MouseEvent.MOUSE_OUT, function(_:MouseEvent):Void log.push("out"));
		target.addEventListener(MouseEvent.ROLL_OUT, function(_:MouseEvent):Void log.push("rollOut"));
		target.addEventListener(MouseEvent.MOUSE_WHEEL, function(event:MouseEvent):Void {
			log.push("wheel:" + event.delta);
			event.preventDefault();
		});
		@:privateAccess stage.__pendingMouseEvent = true;
		@:privateAccess stage.__pendingMouseX = 5;
		@:privateAccess stage.__pendingMouseY = 5;
		@:privateAccess stage.__dispatchPendingMouseEvent();
		target.visible = false;
		@:privateAccess stage.__dispatchPendingMouseEvent();
		target.visible = true;
		dispatchMouse(stage, MouseEvent.MOUSE_MOVE, 5, 5, 0, 0);
		var wheelCanceled = dispatchWheel(stage, 3);
		var leaves = 0;
		stage.addEventListener(Event.MOUSE_LEAVE, function(_:Event):Void leaves++);
		#if harness_capture
		@:privateAccess stage.__dispatchEvent(new Event(Event.MOUSE_LEAVE));
		#else
		@:privateAccess stage.__onWindowLeave();
		#end
		return {
			log: log.join(","),
			wheelCanceled: wheelCanceled,
			leaves: leaves
		};
	}

	private static function dispatchMouse(stage:Stage, type:String, x:Float, y:Float, button:Int, clickCount:Int):Void
	{
		@:privateAccess Mouse.__hidden = true;
		#if harness_capture
		Reflect.setField(stage.window, "clickCount", clickCount);
		#else
		@:privateAccess stage.__mouseClickCount = clickCount;
		#end
		@:privateAccess stage.__onMouse(type, x, y, button);
	}

	private static function dispatchWheel(stage:Stage, delta:Float):Bool
	{
		#if harness_capture
		var signal = new lime.app.Event<Float->Float->MouseWheelMode->Void>();
		Reflect.setField(stage.window, "onMouseWheel", signal);
		@:privateAccess stage.__onMouseWheel(0, delta, MouseWheelMode.LINES);
		return signal.canceled;
		#else
		return @:privateAccess stage.__onMouseWheel(delta).isDefaultPrevented();
		#end
	}

	private static function setWindowSize(stage:Stage, width:Int, height:Int):Void
	{
		#if harness_capture
		Reflect.setField(stage.window, "__width", width);
		Reflect.setField(stage.window, "__height", height);
		#else
		stage.window.width = width;
		stage.window.height = height;
		#end
	}

	private static function mouseFields(event:MouseEvent):Dynamic
	{
		return {
			localX: event.localX,
			localY: event.localY,
			stageX: event.stageX,
			stageY: event.stageY,
			buttonDown: event.buttonDown,
			ctrlKey: event.ctrlKey,
			controlKey: event.controlKey,
			commandKey: event.commandKey,
			altKey: event.altKey,
			shiftKey: event.shiftKey,
			clickCount: event.clickCount
		};
	}

	private static function testTabCandidates():Dynamic
	{
		var stage = createStage();
		var root = namedSprite("root");
		root.tabEnabled = true;
		var first = namedSprite("first");
		first.tabEnabled = true;
		var group = namedSprite("group");
		group.tabEnabled = true;
		group.tabIndex = 2;
		var nested = namedSprite("nested");
		nested.tabEnabled = true;
		nested.tabIndex = 1;
		var closed = namedSprite("closed");
		closed.tabEnabled = true;
		closed.tabChildren = false;
		var excluded = namedSprite("excluded");
		excluded.tabEnabled = true;
		var disabled = new MovieClip();
		disabled.name = "disabled";
		disabled.tabEnabled = true;
		disabled.enabled = false;
		var disabledChild = namedSprite("disabledChild");
		disabledChild.tabEnabled = true;
		root.addChild(first);
		root.addChild(group);
		group.addChild(nested);
		root.addChild(closed);
		closed.addChild(excluded);
		root.addChild(disabled);
		disabled.addChild(disabledChild);
		stage.addChild(root);
		var candidates:Array<InteractiveObject> = [];
		@:privateAccess stage.__tabTest(candidates);
		var raw = names(candidates);
		candidates.sort(function(a:InteractiveObject, b:InteractiveObject):Int return a.tabIndex - b.tabIndex);
		var firstSpecified = 0;
		while (firstSpecified < candidates.length && candidates[firstSpecified].tabIndex == -1) firstSpecified++;
		if (firstSpecified > 0 && firstSpecified < candidates.length) candidates.splice(0, firstSpecified);
		return {
			raw: raw,
			indexed: names(candidates)
		};
	}

	private static function testLifecycleReuse():Dynamic
	{
		var stage = createStage();
		var root = namedSprite("root");
		var child = namedSprite("child");
		var grandchild = namedSprite("grandchild");
		root.addChild(child);
		child.addChild(grandchild);
		var addedEvent:Event = null;
		var removedEvent:Event = null;
		var addedLog:Array<String> = [];
		var removedLog:Array<String> = [];
		for (object in [root, child, grandchild])
		{
			object.addEventListener(Event.ADDED_TO_STAGE, function(event:Event):Void {
				if (addedEvent == null) addedEvent = event;
				addedLog.push(object.name + ":" + (event == addedEvent));
			});
			object.addEventListener(Event.REMOVED_FROM_STAGE, function(event:Event):Void {
				if (removedEvent == null) removedEvent = event;
				removedLog.push(object.name + ":" + (event == removedEvent));
			});
		}
		stage.addChild(root);
		stage.removeChild(root);
		return {
			added: addedLog.join(","),
			addedFinalTarget: objectName(addedEvent.target),
			addedFinalCurrentTarget: objectName(addedEvent.currentTarget),
			removed: removedLog.join(","),
			removedFinalTarget: objectName(removedEvent.target),
			removedFinalCurrentTarget: objectName(removedEvent.currentTarget)
		};
	}

	private static function testLifecycleMutation():Dynamic
	{
		var stage = createStage();
		var root = namedSprite("root");
		var first = namedSprite("first");
		var removed = namedSprite("removed");
		var last = namedSprite("last");
		root.addChild(first);
		root.addChild(removed);
		root.addChild(last);
		var log:Array<String> = [];
		first.addEventListener(Event.ADDED_TO_STAGE, function(_:Event):Void {
			log.push("first");
			root.removeChild(removed);
		});
		removed.addEventListener(Event.ADDED_TO_STAGE, function(_:Event):Void log.push("removed"));
		last.addEventListener(Event.ADDED_TO_STAGE, function(_:Event):Void log.push("last"));
		stage.addChild(root);

		var staleRoot = namedSprite("staleRoot");
		var staleChild = namedSprite("staleChild");
		staleRoot.addChild(staleChild);
		var stale:Array<String> = [];
		staleRoot.addEventListener(Event.ADDED_TO_STAGE, function(_:Event):Void {
			stale.push("root");
			stage.removeChild(staleRoot);
		});
		staleChild.addEventListener(Event.ADDED_TO_STAGE, function(_:Event):Void stale.push("child-stage:" + (staleChild.stage != null)));
		stage.addChild(staleRoot);
		return {
			live: log.join(","),
			removedParentIsNull: removed.parent == null,
			stale: stale.join(","),
			staleParentIsNull: staleRoot.parent == null
		};
	}

	private static function testDirectFocusRemoval():Dynamic
	{
		var stage = createStage();
		var child = new Sprite();
		stage.addChild(child);
		stage.focus = child;
		stage.removeChild(child);
		return {
			focusCleared: stage.focus == null,
			childStageCleared: child.stage == null
		};
	}

	private static function testPostDispatchClone():Dynamic
	{
		var parent = namedSprite("parent");
		var child = namedSprite("child");
		parent.addChild(child);
		parent.addEventListener("clone", function(_:Event):Void {});
		var original = new Event("clone", true, true);
		child.dispatchEvent(original);
		var clone = original.clone();
		return {
			target: objectName(clone.target),
			currentTarget: objectName(clone.currentTarget),
			phase: cast clone.eventPhase
		};
	}

	private static function createStage():Stage
	{
		var window:Dynamic = Type.createEmptyInstance(Window);
		#if harness_capture
		Reflect.setField(window, "__width", 320);
		Reflect.setField(window, "__height", 240);
		Reflect.setField(window, "__scale", 1.0);
		Reflect.setField(window, "__fullscreen", false);
		#else
		window.width = 320;
		window.height = 240;
		window.scale = 1.0;
		window.fullscreen = false;
		#end
		var stage = new Stage(cast window, 0xFFFFFF);
		if (Lib.current != null && Lib.current.parent == stage) stage.removeChild(Lib.current);
		return stage;
	}

	private static function namedSprite(name:String):Sprite
	{
		var sprite = new Sprite();
		sprite.name = name;
		return sprite;
	}

	private static function filledSprite(name:String, width:Float, height:Float):Sprite
	{
		var sprite = namedSprite(name);
		sprite.graphics.beginFill(0xFFFFFF);
		sprite.graphics.drawRect(0, 0, width, height);
		return sprite;
	}

	private static function names(objects:Array<InteractiveObject>):Array<String>
	{
		return [for (object in objects) object.name];
	}

	private static function objectName(value:Dynamic):String
	{
		return (value is DisplayObject) ? cast(value, DisplayObject).name : null;
	}
}
