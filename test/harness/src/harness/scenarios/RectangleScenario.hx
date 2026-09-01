package harness.scenarios;

import openfl.geom.Point;
import openfl.geom.Rectangle;

class RectangleScenario {
	public static function run():Dynamic {
		var r = new Rectangle(10, 20, 100, 50);
		var empty = new Rectangle();
		var negSize = new Rectangle(5, 5, -10, -20);

		var inflated = r.clone();
		inflated.inflate(5, 10);

		var deflated = r.clone();
		deflated.inflate(-5, -10);

		var r2 = new Rectangle(50, 30, 80, 40);
		var noOverlap = new Rectangle(200, 200, 10, 10);

		var offsetR = r.clone();
		offsetR.offset(15, -5);

		var offsetPR = r.clone();
		offsetPR.offsetPoint(new Point(-10, 20));

		var setEmptyR = r.clone();
		setEmptyR.setEmpty();

		var setToR = new Rectangle();
		setToR.setTo(1, 2, 3, 4);

		var copyR = new Rectangle();
		copyR.copyFrom(r);

		var bottomRightSet = r.clone();
		bottomRightSet.bottomRight = new Point(200, 100);

		var topLeftSet = r.clone();
		topLeftSet.topLeft = new Point(5, 10);

		var sizeSet = r.clone();
		sizeSet.size = new Point(200, 100);

		var leftSet = r.clone();
		leftSet.left = 50;

		var rightSet = r.clone();
		rightSet.right = 200;

		var topSet = r.clone();
		topSet.top = 5;

		var bottomSet = r.clone();
		bottomSet.bottom = 100;

		return {
			construct: rect(r),
			constructDefault: rect(empty),
			constructNegative: rect(negSize),
			derivedProps: {
				left: r.left,
				right: r.right,
				top: r.top,
				bottom: r.bottom,
				topLeft: coords(r.topLeft),
				bottomRight: coords(r.bottomRight),
				size: coords(r.size)
			},
			contains: {
				inside: r.contains(50, 40),
				onEdge: r.contains(10, 20),
				outside: r.contains(200, 200),
				negSizeInside: negSize.contains(0, 0)
			},
			containsPoint: {
				inside: r.containsPoint(new Point(50, 40)),
				outside: r.containsPoint(new Point(200, 200))
			},
			containsRect: {
				inside: r.containsRect(new Rectangle(20, 30, 10, 10)),
				overlapping: r.containsRect(r2),
				self: r.containsRect(r.clone()),
				empty: r.containsRect(new Rectangle(50, 40, 0, 0))
			},
			equals: {
				same: r.equals(new Rectangle(10, 20, 100, 50)),
				different: r.equals(r2),
				empty: empty.equals(new Rectangle())
			},
			inflate: rect(inflated),
			deflatePastZero: rect(deflated),
			intersection: {
				overlapping: rect(r.intersection(r2)),
				noOverlap: rect(r.intersection(noOverlap)),
				self: rect(r.intersection(r.clone()))
			},
			intersects: {
				overlapping: r.intersects(r2),
				noOverlap: r.intersects(noOverlap),
				adjacent: new Rectangle(0, 0, 10, 10).intersects(new Rectangle(10, 0, 10, 10))
			},
			isEmpty: {
				normal: r.isEmpty(),
				empty: empty.isEmpty(),
				zeroWidth: new Rectangle(0, 0, 0, 10).isEmpty(),
				zeroHeight: new Rectangle(0, 0, 10, 0).isEmpty(),
				negative: negSize.isEmpty()
			},
			offset: rect(offsetR),
			offsetPoint: rect(offsetPR),
			setEmpty: rect(setEmptyR),
			setTo: rect(setToR),
			copyFrom: rect(copyR),
			union: {
				overlapping: rect(r.union(r2)),
				noOverlap: rect(r.union(noOverlap)),
				withEmpty: rect(r.union(empty))
			},
			clone: {
				values: rect(r.clone()),
				notSame: r.clone() != r
			},
			setters: {
				bottomRight: rect(bottomRightSet),
				topLeft: rect(topLeftSet),
				size: rect(sizeSet),
				left: rect(leftSet),
				right: rect(rightSet),
				top: rect(topSet),
				bottom: rect(bottomSet)
			}
		};
	}

	private static function rect(r:Rectangle):Dynamic {
		return {
			x: r.x,
			y: r.y,
			width: r.width,
			height: r.height
		};
	}

	private static function coords(p:Point):Dynamic {
		return {
			x: p.x,
			y: p.y
		};
	}
}
