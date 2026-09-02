package harness.scenarios;

import openfl.utils.Dictionary;

class DictionaryScenario {
	public static function run():Dynamic {
		return {
			basicUsage: testBasicUsage(),
			objectKeys: testObjectKeys(),
			removeKey: testRemoveKey(),
			exists: testExists(),
			iteration: testIteration(),
			deleteDuringIteration: testDeleteDuringIteration(),
			nullKey: testNullKey(),
			toStringCollision: testToStringCollision()
		};
	}

	private static function testBasicUsage():Dynamic {
		var dict = new Dictionary<String, Int>();
		dict.set("a", 1);
		dict.set("b", 2);
		dict.set("c", 3);

		return {
			getA: dict.get("a"),
			getB: dict.get("b"),
			getC: dict.get("c"),
			getMissing: dict.get("z")
		};
	}

	private static function testObjectKeys():Dynamic {
		var dict = new Dictionary<{}, String>();
		var key1 = {};
		var key2 = {};

		dict.set(key1, "first");
		dict.set(key2, "second");
		var countAfterAdditions = countObjectStringValues(dict);
		dict.set(key1, "replaced");
		var countAfterOverwrite = countObjectStringValues(dict);
		var existsBeforeRemove = dict.exists(key2);
		var removed = dict.remove(key2);

		return {
			getKey1: dict.get(key1),
			getKey2: dict.get(key2),
			overwritten: dict.get(key1) == "replaced",
			countAfterAdditions: countAfterAdditions,
			countAfterOverwrite: countAfterOverwrite,
			existsBeforeRemove: existsBeforeRemove,
			removed: removed,
			existsAfterRemove: dict.exists(key2),
			countAfterRemove: countObjectStringValues(dict)
		};
	}

	private static function testRemoveKey():Dynamic {
		var dict = new Dictionary<String, Int>();
		dict.set("x", 10);
		var before = dict.exists("x");
		dict.remove("x");
		var after = dict.exists("x");

		return {
			beforeRemove: before,
			afterRemove: after
		};
	}

	private static function testExists():Dynamic {
		var dict = new Dictionary<String, Int>();
		dict.set("present", 42);

		return {
			present: dict.exists("present"),
			absent: dict.exists("absent")
		};
	}

	private static function testIteration():Dynamic {
		var dict = new Dictionary<String, Int>();
		dict.set("a", 1);
		dict.set("b", 2);
		dict.set("c", 3);

		var keys = new Array<String>();
		var values = new Array<String>();
		var directValues = new Array<String>();

		for (key in dict.iterator()) {
			keys.push(Std.string(key));
		}
		for (key in dict) {
			directValues.push(Std.string(dict.get(key)));
		}
		for (val in dict.each()) {
			values.push(Std.string(val));
		}

		keys.sort(Reflect.compare);
		values.sort(Reflect.compare);
		directValues.sort(Reflect.compare);

		return {
			sortedKeys: keys.join(","),
			sortedValues: values.join(","),
			directForInValues: directValues.join(","),
			keyCount: keys.length
		};
	}

	private static function testDeleteDuringIteration():Dynamic {
		var dict = new Dictionary<{}, Int>();
		dict.set({}, 1);
		dict.set({}, 2);
		dict.set({}, 3);
		var visited = 0;
		var removed = 0;
		for (key in dict) {
			visited++;
			if (dict.remove(key)) removed++;
		}
		return {
			visited: visited,
			removed: removed,
			remaining: countObjectIntValues(dict)
		};
	}

	private static function testNullKey():Dynamic {
		var dict = new Dictionary<{}, String>();
		var error:Null<String> = null;
		var exists = false;
		var value:Null<String> = null;
		var removed = false;
		try {
			var key:{} = cast null;
			dict.set(key, "null-value");
			exists = dict.exists(key);
			value = dict.get(key);
			removed = dict.remove(key);
		} catch (caught:Dynamic) {
			var caughtClass = Type.getClass(caught);
			error = caughtClass == null ? Std.string(caught) : Type.getClassName(caughtClass);
		}
		return {
			error: error,
			exists: exists,
			value: value,
			removed: removed,
			count: countObjectStringValues(dict)
		};
	}

	private static function testToStringCollision():Dynamic {
		var first:Dynamic = {toString: function():String return "collision"};
		var second:Dynamic = {toString: function():String return "collision"};
		var dict = new Dictionary<{}, String>();
		dict.set(first, "first");
		dict.set(second, "second");
		return {
			sameString: first.toString() == second.toString(),
			first: dict.get(first),
			second: dict.get(second),
			count: countObjectStringValues(dict)
		};
	}

	private static function countObjectStringValues(dict:Dictionary<{}, String>):Int {
		var result = 0;
		for (_ in dict) result++;
		return result;
	}

	private static function countObjectIntValues(dict:Dictionary<{}, Int>):Int {
		var result = 0;
		for (_ in dict) result++;
		return result;
	}
}
