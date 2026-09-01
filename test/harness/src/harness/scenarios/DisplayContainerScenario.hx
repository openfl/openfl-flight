package harness.scenarios;

import openfl.display.Sprite;
import openfl.events.Event;

class DisplayContainerScenario {
	public static function run():Dynamic {
		return {
			addChild: testAddChild(),
			addChildAt: testAddChildAt(),
			removeChild: testRemoveChild(),
			getChildAt: testGetChildAt(),
			getChildByName: testGetChildByName(),
			getChildIndex: testGetChildIndex(),
			contains: testContains(),
			reparent: testReparent(),
			addedEvents: testAddedEvents(),
			removedEvents: testRemovedEvents(),
			setChildIndex: testSetChildIndex()
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

		return {
			child0: parent.getChildAt(0).name,
			child1: parent.getChildAt(1).name,
			child2: parent.getChildAt(2).name
		};
	}
}
