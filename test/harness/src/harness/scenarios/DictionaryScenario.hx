package harness.scenarios;

import openfl.utils.Dictionary;

class DictionaryScenario {
	public static function run():Dynamic {
		return {
			basicUsage: testBasicUsage(),
			objectKeys: testObjectKeys(),
			removeKey: testRemoveKey(),
			exists: testExists(),
			iteration: testIteration()
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
		var dict = new Dictionary<String, String>();
		var key1 = "key1";
		var key2 = "key2";

		dict.set(key1, "first");
		dict.set(key2, "second");
		dict.set(key1, "replaced");

		return {
			getKey1: dict.get(key1),
			getKey2: dict.get(key2),
			overwritten: dict.get(key1) == "replaced"
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

		for (key in dict.iterator()) {
			keys.push(Std.string(key));
		}
		for (val in dict.each()) {
			values.push(Std.string(val));
		}

		keys.sort(Reflect.compare);
		values.sort(Reflect.compare);

		return {
			sortedKeys: keys.join(","),
			sortedValues: values.join(","),
			keyCount: keys.length
		};
	}
}
