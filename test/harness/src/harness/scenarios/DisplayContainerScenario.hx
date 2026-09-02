package harness.scenarios;

import openfl.display.Sprite;
import openfl.events.Event;
import openfl.geom.Point;

class DisplayContainerScenario {
	public static function run():Dynamic {
		return {
			addChild: testAddChild(),
			addChildAt: testAddChildAt(),
			removeChild: testRemoveChild(),
			removeNonChild: testRemoveNonChild(),
			getChildAt: testGetChildAt(),
			getChildByName: testGetChildByName(),
			getChildIndex: testGetChildIndex(),
			contains: testContains(),
			reparent: testReparent(),
			addedEvents: testAddedEvents(),
			removedEvents: testRemovedEvents(),
			setChildIndex: testSetChildIndex(),
			swapChildren: testSwapChildren(),
			swapChildrenAt: testSwapChildrenAt(),
			removeChildren: testRemoveChildren(),
			objectsUnderPoint: testObjectsUnderPoint(),
			removeChildAt: testRemoveChildAt(),
			numChildren: testNumChildren(),
			addChildReindex: testAddChildReindex(),
			edges: testEdges()
		};
	}

	private static function testEdges():Dynamic {
		var parent = new Sprite();
		var child = new Sprite();
		child.name = "child";
		var unrelated = new Sprite();
		parent.addChild(child);

		var addNull = captureError(function() parent.addChild(null));
		var addSelf = captureError(function() parent.addChild(parent));
		var addPastEnd = captureError(function() parent.addChildAt(new Sprite(), 2));
		parent.setChildIndex(child, 1);
		parent.setChildIndex(unrelated, 0);

		return {
			addNull: addNull,
			addSelf: addSelf,
			addPastEnd: addPastEnd,
			getNegativeIsNull: parent.getChildAt(-1) == null,
			getPastEndIsNull: parent.getChildAt(parent.numChildren) == null,
			removeNegativeIsNull: parent.removeChildAt(-1) == null,
			removePastEndIsNull: parent.removeChildAt(parent.numChildren) == null,
			orderAfterInvalidSet: childOrder(parent),
			unrelatedStillDetached: unrelated.parent == null
		};
	}

	private static function testRemoveNonChild():Dynamic {
		var parent = new Sprite();
		var child = new Sprite();
		var unrelated = new Sprite();
		parent.addChild(child);
		var error:Dynamic = null;

		try {
			parent.removeChild(unrelated);
		} catch (caught:Dynamic) {
			error = caught;
		}

		return {
			threw: error != null,
			errorClass: errorClass(error),
			numChildren: parent.numChildren,
			childStillParented: child.parent == parent,
			unrelatedStillDetached: unrelated.parent == null
		};
	}

	private static function testAddChild():Dynamic {
		var parent = new Sprite();
		var child = new Sprite();
		parent.addChild(child);
		return {
			numChildren: parent.numChildren,
			childParent: child.parent == parent
		};
	}

	private static function testAddChildAt():Dynamic {
		var parent = new Sprite();
		var a = new Sprite();
		a.name = "a";
		var b = new Sprite();
		b.name = "b";
		var c = new Sprite();
		c.name = "c";

		parent.addChild(a);
		parent.addChild(c);
		parent.addChildAt(b, 1);

		return {
			numChildren: parent.numChildren,
			child0: parent.getChildAt(0).name,
			child1: parent.getChildAt(1).name,
			child2: parent.getChildAt(2).name
		};
	}

	private static function testRemoveChild():Dynamic {
		var parent = new Sprite();
		var child = new Sprite();
		parent.addChild(child);
		parent.removeChild(child);
		return {
			numChildren: parent.numChildren,
			childParent: child.parent == null
		};
	}

	private static function testGetChildAt():Dynamic {
		var parent = new Sprite();
		var a = new Sprite();
		a.name = "first";
		var b = new Sprite();
		b.name = "second";
		parent.addChild(a);
		parent.addChild(b);
		return {
			first: parent.getChildAt(0).name,
			second: parent.getChildAt(1).name
		};
	}

	private static function testGetChildByName():Dynamic {
		var parent = new Sprite();
		var child = new Sprite();
		child.name = "findMe";
		parent.addChild(child);
		var found = parent.getChildByName("findMe");
		var notFound = parent.getChildByName("nope");
		return {
			found: found == child,
			notFound: notFound == null
		};
	}

	private static function testGetChildIndex():Dynamic {
		var parent = new Sprite();
		var a = new Sprite();
		var b = new Sprite();
		parent.addChild(a);
		parent.addChild(b);
		return {
			indexA: parent.getChildIndex(a),
			indexB: parent.getChildIndex(b)
		};
	}

	private static function testContains():Dynamic {
		var parent = new Sprite();
		var child = new Sprite();
		var grandchild = new Sprite();
		var unrelated = new Sprite();
		parent.addChild(child);
		child.addChild(grandchild);
		return {
			containsChild: parent.contains(child),
			containsGrandchild: parent.contains(grandchild),
			containsSelf: parent.contains(parent),
			containsUnrelated: parent.contains(unrelated)
		};
	}

	private static function testReparent():Dynamic {
		var parent1 = new Sprite();
		var parent2 = new Sprite();
		var child = new Sprite();

		parent1.addChild(child);
		var p1Children = parent1.numChildren;
		parent2.addChild(child);

		return {
			parent1Before: p1Children,
			parent1After: parent1.numChildren,
			parent2After: parent2.numChildren,
			childParent: child.parent == parent2
		};
	}

	private static function testAddedEvents():Dynamic {
		var events:Array<String> = [];
		var parent = new Sprite();
		var child = new Sprite();

		child.addEventListener(Event.ADDED, function(e:Event):Void {
			events.push("added");
		});

		parent.addChild(child);

		return {
			eventsLength: events.length,
			firstEvent: events.length > 0 ? events[0] : "none"
		};
	}

	private static function testRemovedEvents():Dynamic {
		var events:Array<String> = [];
		var parent = new Sprite();
		var child = new Sprite();
		parent.addChild(child);

		child.addEventListener(Event.REMOVED, function(e:Event):Void {
			events.push("removed");
		});

		parent.removeChild(child);

		return {
			eventsLength: events.length,
			firstEvent: events.length > 0 ? events[0] : "none"
		};
	}

	private static function testSetChildIndex():Dynamic {
		var parent = new Sprite();
		var a = new Sprite();
		a.name = "a";
		var b = new Sprite();
		b.name = "b";
		var c = new Sprite();
		c.name = "c";

		parent.addChild(a);
		parent.addChild(b);
		parent.addChild(c);

		parent.setChildIndex(a, 2);
		var movedToFront = childOrder(parent);
		parent.setChildIndex(a, 0);
		var movedToBack = childOrder(parent);
		parent.setChildIndex(b, 1);

		return {
			movedToFront: movedToFront,
			movedToBack: movedToBack,
			sameIndex: childOrder(parent)
		};
	}

	private static function testSwapChildren():Dynamic {
		var parent = new Sprite();
		var a = new Sprite();
		a.name = "a";
		var b = new Sprite();
		b.name = "b";
		var c = new Sprite();
		c.name = "c";

		parent.addChild(a);
		parent.addChild(b);
		parent.addChild(c);

		parent.swapChildren(a, c);
		var swapped = childOrder(parent);
		parent.swapChildren(b, b);

		return {
			swapped: swapped,
			sameChild: childOrder(parent)
		};
	}

	private static function testSwapChildrenAt():Dynamic {
		var parent = new Sprite();
		var a = new Sprite();
		a.name = "a";
		var b = new Sprite();
		b.name = "b";
		var c = new Sprite();
		c.name = "c";

		parent.addChild(a);
		parent.addChild(b);
		parent.addChild(c);

		parent.swapChildrenAt(0, 2);
		var swapped = childOrder(parent);
		parent.swapChildrenAt(1, 1);

		return {
			swapped: swapped,
			sameIndex: childOrder(parent)
		};
	}

	private static function testRemoveChildren():Dynamic {
		var parent = new Sprite();
		var a = new Sprite();
		a.name = "a";
		var b = new Sprite();
		b.name = "b";
		var c = new Sprite();
		c.name = "c";
		var d = new Sprite();
		d.name = "d";

		parent.addChild(a);
		parent.addChild(b);
		parent.addChild(c);
		parent.addChild(d);

		parent.removeChildren(1, 2);

		var allParent = new Sprite();
		var first = new Sprite();
		var second = new Sprite();
		allParent.addChild(first);
		allParent.addChild(second);
		allParent.removeChildren();

		return {
			range: {
				numChildren: parent.numChildren,
				child0: parent.getChildAt(0).name,
				child1: parent.getChildAt(1).name,
				bParent: b.parent == null,
				cParent: c.parent == null
			},
			all: {
				numChildren: allParent.numChildren,
				firstDetached: first.parent == null,
				secondDetached: second.parent == null
			}
		};
	}

	private static function testObjectsUnderPoint():Dynamic {
		var container = new Sprite();
		var bottom = filledSprite("bottom", 0, 0, 30, 30);
		var top = filledSprite("top", 10, 10, 30, 30);
		var nested = new Sprite();
		nested.name = "nested";
		nested.x = 5;
		nested.y = 5;
		var nestedChild = filledSprite("nestedChild", 5, 5, 15, 15);
		nested.addChild(nestedChild);
		container.addChild(bottom);
		container.addChild(top);
		container.addChild(nested);

		var overlap = objectNames(container.getObjectsUnderPoint(new Point(15, 15)));
		var outside = objectNames(container.getObjectsUnderPoint(new Point(100, 100)));
		top.visible = false;
		var hiddenTop = objectNames(container.getObjectsUnderPoint(new Point(15, 15)));
		return {
			overlap: overlap,
			outside: outside,
			hiddenTop: hiddenTop
		};
	}

	private static function testRemoveChildAt():Dynamic {
		var parent = new Sprite();
		var a = new Sprite();
		a.name = "a";
		var b = new Sprite();
		b.name = "b";
		var c = new Sprite();
		c.name = "c";

		parent.addChild(a);
		parent.addChild(b);
		parent.addChild(c);

		parent.removeChildAt(1);

		return {
			numChildren: parent.numChildren,
			child0: parent.getChildAt(0).name,
			child1: parent.getChildAt(1).name,
			removedParent: b.parent == null
		};
	}

	private static function testNumChildren():Dynamic {
		var parent = new Sprite();
		var empty = parent.numChildren;
		var first = new Sprite();
		var second = new Sprite();
		parent.addChild(first);
		var one = parent.numChildren;
		parent.addChild(second);
		var two = parent.numChildren;
		parent.removeChild(first);
		var afterRemove = parent.numChildren;
		parent.addChild(first);
		var afterReadd = parent.numChildren;
		parent.removeChildren();
		var afterClear = parent.numChildren;

		return {
			empty: empty,
			one: one,
			two: two,
			afterRemove: afterRemove,
			afterReadd: afterReadd,
			afterClear: afterClear
		};
	}

	private static function testAddChildReindex():Dynamic {
		var parent = new Sprite();
		var a = new Sprite();
		a.name = "a";
		var b = new Sprite();
		b.name = "b";
		var c = new Sprite();
		c.name = "c";

		parent.addChild(a);
		parent.addChild(b);
		parent.addChild(c);

		parent.addChild(a);

		return {
			numChildren: parent.numChildren,
			child0: parent.getChildAt(0).name,
			child1: parent.getChildAt(1).name,
			child2: parent.getChildAt(2).name
		};
	}

	private static function childOrder(parent:Sprite):String {
		return [for (i in 0...parent.numChildren) parent.getChildAt(i).name].join(",");
	}

	private static function captureError(callback:Void->Void):Dynamic {
		var error:Dynamic = null;
		try callback() catch (caught:Dynamic) error = caught;
		var type = error == null ? null : Type.getClass(error);
		return {
			threw: error != null,
			errorClass: type == null ? (error == null ? null : Std.string(Type.typeof(error))) : Type.getClassName(type),
			errorID: error == null ? null : Reflect.field(error, "errorID")
		};
	}

	private static function filledSprite(name:String, x:Float, y:Float, width:Float, height:Float):Sprite {
		var sprite = new Sprite();
		sprite.name = name;
		sprite.x = x;
		sprite.y = y;
		sprite.graphics.beginFill(0x336699);
		sprite.graphics.drawRect(0, 0, width, height);
		sprite.graphics.endFill();
		return sprite;
	}

	private static function objectNames(objects:Array<openfl.display.DisplayObject>):Array<String> {
		return [for (object in objects) object.name];
	}

	private static function errorClass(error:Dynamic):String {
		if (error == null) return null;
		var type = Type.getClass(error);
		return type == null ? Std.string(Type.typeof(error)) : Type.getClassName(type);
	}
}
