package harness.scenarios;

import openfl.Lib;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.display.Stage;
import openfl.display.StageScaleMode;
import openfl.display.Window;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.geom.Point;
#if lime
import lime.ui.KeyModifier;
#end

class DisplayEventsIntegrationScenario
{
	public static function run():Dynamic
	{
		return {
			addRemove: testAddRemove(),
			descendantStageEvents: testDescendantStageEvents(),
			reparent: testReparent(),
			mouseTargeting: testMouseTargeting(),
			stageResize: testStageResize(),
			stageDispatchStack: testStageDispatchStack(),
			nativeKeyboardRouter: testNativeKeyboardRouter()
		};
	}

	private static function testAddRemove():Dynamic
	{
		var stage = createStage(320, 240);
		var parent = namedSprite("parent");
		var child = namedSprite("child");
		stage.addChild(parent);
		var events:Array<Dynamic> = [];
		listen(child, Event.ADDED, "child", events);
		listen(child, Event.ADDED_TO_STAGE, "child", events);
		listen(child, Event.REMOVED, "child", events);
		listen(child, Event.REMOVED_FROM_STAGE, "child", events);
		listen(parent, Event.ADDED, "parent", events);
		listen(parent, Event.REMOVED, "parent", events);

		parent.addChild(child);
		var added = events.copy();
		events.resize(0);
		parent.removeChild(child);
		var removed = events.copy();

		return {
			added: added,
			removed: removed,
			stageAfterAdd: added.length > 0,
			childDetached: child.parent == null && child.stage == null
		};
	}

	private static function testDescendantStageEvents():Dynamic
	{
		var stage = createStage(320, 240);
		var container = namedSprite("container");
		var child = namedSprite("child");
		var grandchild = namedSprite("grandchild");
		child.addChild(grandchild);
		container.addChild(child);
		var events:Array<Dynamic> = [];
		listen(container, Event.ADDED_TO_STAGE, "container", events);
		listen(child, Event.ADDED_TO_STAGE, "child", events);
		listen(grandchild, Event.ADDED_TO_STAGE, "grandchild", events);
		stage.addChild(container);

		return {
			events: events,
			allOnStage: container.stage == stage && child.stage == stage && grandchild.stage == stage
		};
	}

	private static function testReparent():Dynamic
	{
		var stage = createStage(320, 240);
		var left = namedSprite("left");
		var right = namedSprite("right");
		var child = namedSprite("child");
		stage.addChild(left);
		stage.addChild(right);
		left.addChild(child);
		var events:Array<Dynamic> = [];
		for (type in [Event.REMOVED, Event.REMOVED_FROM_STAGE, Event.ADDED, Event.ADDED_TO_STAGE]) listen(child, type, "child", events);
		listen(left, Event.REMOVED, "left", events);
		listen(right, Event.ADDED, "right", events);
		right.addChild(child);

		return {
			events: events,
			leftChildren: left.numChildren,
			rightChildren: right.numChildren,
			parentIsRight: child.parent == right,
			remainsOnStage: child.stage == stage
		};
	}

	private static function testMouseTargeting():Dynamic
	{
		var stage = createStage(320, 240);
		var root = namedSprite("root");
		var child = filledSprite("child", 40, 30);
		root.addChild(child);
		stage.addChild(root);
		var point = new Point(10, 10);
		var routes:Array<Dynamic> = [];
		root.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):Void routes.push({listener: "root", target: objectName(event.target)}));
		child.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):Void routes.push({listener: "child", target: objectName(event.target)}));

		var defaultTarget = resolveMouseTarget(root, child, point);
		if (defaultTarget != null) defaultTarget.dispatchEvent(new MouseEvent(MouseEvent.CLICK, true));
		var defaultRoute = routes.copy();
		routes.resize(0);

		child.mouseEnabled = false;
		var disabledChildTarget = resolveMouseTarget(root, child, point);
		if (disabledChildTarget != null) disabledChildTarget.dispatchEvent(new MouseEvent(MouseEvent.CLICK, true));
		var disabledChildRoute = routes.copy();
		routes.resize(0);

		child.mouseEnabled = true;
		root.mouseChildren = false;
		var disabledChildrenTarget = resolveMouseTarget(root, child, point);
		if (disabledChildrenTarget != null) disabledChildrenTarget.dispatchEvent(new MouseEvent(MouseEvent.CLICK, true));
		var disabledChildrenRoute = routes.copy();
		routes.resize(0);

		root.mouseEnabled = false;
		var disabledRootTarget = resolveMouseTarget(root, child, point);

		return {
			defaultTarget: objectName(defaultTarget),
			defaultRoute: defaultRoute,
			disabledChildTarget: objectName(disabledChildTarget),
			disabledChildRoute: disabledChildRoute,
			disabledChildrenTarget: objectName(disabledChildrenTarget),
			disabledChildrenRoute: disabledChildrenRoute,
			disabledRootTarget: objectName(disabledRootTarget)
		};
	}

	private static function testStageResize():Dynamic
	{
		var stage = createStage(320, 240);
		var events = 0;
		stage.addEventListener(Event.RESIZE, function(_:Event):Void events++);
		stage.scaleMode = StageScaleMode.SHOW_ALL;
		@:privateAccess stage.__setLogicalSize(640, 360);
		@:privateAccess stage.__setLogicalSize(640, 360);
		return {
			events: events,
			width: stage.stageWidth,
			height: stage.stageHeight
		};
	}

	private static function testStageDispatchStack():Dynamic
	{
		var stage = createStage(320, 240);
		var parent = namedSprite("parent");
		var target = namedSprite("target");
		stage.addChild(parent);
		parent.addChild(target);
		var log:Array<String> = [];
		stage.addEventListener("strict", function(event:Event):Void {
			log.push("stage-first");
			event.stopPropagation();
		}, true);
		stage.addEventListener("strict", function(_:Event):Void log.push("stage-second"), true);
		parent.addEventListener("strict", function(_:Event):Void log.push("parent"), true);
		target.addEventListener("strict", function(_:Event):Void log.push("target"));
		var event = new Event("strict", true);
		@:privateAccess stage.__dispatchStack(event, [stage, parent, target]);
		return {
			log: log.join(","),
			target: objectName(event.target),
			currentTarget: objectName(event.currentTarget),
			phase: cast event.eventPhase
		};
	}

	private static function testNativeKeyboardRouter():Dynamic
	{
		var stage = createStage(320, 240);
		var parent = namedSprite("parent");
		var target = namedSprite("target");
		stage.addChild(parent);
		parent.addChild(target);
		stage.focus = target;
		var log:Array<String> = [];
		stage.addEventListener(KeyboardEvent.KEY_DOWN, function(event:Event):Void {
			log.push("stage-first");
			event.stopPropagation();
		}, true);
		stage.addEventListener(KeyboardEvent.KEY_DOWN, function(_:Event):Void log.push("stage-second"), true);
		parent.addEventListener(KeyboardEvent.KEY_DOWN, function(_:Event):Void log.push("parent"), true);
		target.addEventListener(KeyboardEvent.KEY_DOWN, function(_:Event):Void log.push("target"));
		#if (harness_compare && lime)
		@:privateAccess stage.__dispatchKeyboardEvent(KeyboardEvent.KEY_DOWN, cast 65, KeyModifier.NONE);
		#else
		@:privateAccess stage.__dispatchStack(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true), [stage, parent, target]);
		#end
		return {
			log: log.join(",")
		};
	}

	private static function resolveMouseTarget(root:Sprite, child:Sprite, point:Point):DisplayObject
	{
		if (!root.mouseChildren) return root.mouseEnabled && root.hitTestPoint(point.x, point.y, true) ? root : null;
		if (child.mouseEnabled && child.hitTestPoint(point.x, point.y, true)) return child;
		return root.mouseEnabled && root.hitTestPoint(point.x, point.y, true) ? root : null;
	}

	private static function listen(object:DisplayObject, type:String, listener:String, events:Array<Dynamic>):Void
	{
		object.addEventListener(type, function(event:Event):Void events.push({
			type: event.type,
			listener: listener,
			target: objectName(event.target),
			currentTarget: objectName(event.currentTarget),
			bubbles: event.bubbles,
			parentAtDispatch: objectName(object.parent),
			onStageAtDispatch: object.stage != null
		}));
	}

	private static function createStage(width:Int, height:Int):Stage
	{
		var window:Dynamic = Type.createEmptyInstance(Window);
		#if harness_capture
		Reflect.setField(window, "__width", width);
		Reflect.setField(window, "__height", height);
		Reflect.setField(window, "__scale", 1.0);
		Reflect.setField(window, "__fullscreen", false);
		#else
		window.width = width;
		window.height = height;
		window.scale = 1.0;
		window.fullscreen = false;
		#end
		var stage = new Stage(cast window, 0);
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
		sprite.graphics.beginFill(0x336699);
		sprite.graphics.drawRect(0, 0, width, height);
		sprite.graphics.endFill();
		return sprite;
	}

	private static function objectName(value:Dynamic):String
	{
		return value == null ? null : (cast value : DisplayObject).name;
	}
}
