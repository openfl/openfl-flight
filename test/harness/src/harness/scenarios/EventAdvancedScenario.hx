package harness.scenarios;

import openfl.Lib;
import openfl.display.DisplayObject;
import openfl.display.InteractiveObject;
import openfl.display.MovieClip;
import openfl.display.Sprite;
import openfl.display.Stage;
import openfl.display.Window;
import openfl.events.Event;
import openfl.events.FocusEvent;

class EventAdvancedScenario
{
	public static function run():Dynamic
	{
		return {
			broadcast: testBroadcast(),
			frameAndRender: testFrameAndRender(),
			windowFocus: testWindowFocus(),
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

	private static function names(objects:Array<InteractiveObject>):Array<String>
	{
		return [for (object in objects) object.name];
	}

	private static function objectName(value:Dynamic):String
	{
		return (value is DisplayObject) ? cast(value, DisplayObject).name : null;
	}
}
