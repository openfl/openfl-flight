package harness;

class JsonAssert {
	public static function equals(expected:Dynamic, actual:Dynamic, path:String = "fixture"):Void {
		if (expected == null || actual == null) {
			if (expected != actual) {
				fail(path, expected, actual);
			}

			return;
		}

		if (Std.isOfType(expected, Array)) {
			if (!Std.isOfType(actual, Array)) {
				fail(path, expected, actual);
			}

			var expectedArray:Array<Dynamic> = cast expected;
			var actualArray:Array<Dynamic> = cast actual;

			if (expectedArray.length != actualArray.length) {
				throw '$path: expected ${expectedArray.length} items, got ${actualArray.length}';
			}

			for (index in 0...expectedArray.length) {
				equals(expectedArray[index], actualArray[index], '$path[$index]');
			}

			return;
		}

		if (isString(expected)) {
			if (!isString(actual) || (expected : String) != (actual : String)) {
				fail(path, expected, actual);
			}

			return;
		}

		if (isBool(expected)) {
			if (!isBool(actual) || (expected : Bool) != (actual : Bool)) {
				fail(path, expected, actual);
			}

			return;
		}

		if (isNumber(expected)) {
			if (!isNumber(actual) || expected != actual) {
				fail(path, expected, actual);
			}

			return;
		}

		if (Type.typeof(expected) == TObject) {
			if (Type.typeof(actual) != TObject) {
				fail(path, expected, actual);
			}

			var expectedFields = Reflect.fields(expected);
			var actualFields = Reflect.fields(actual);
			expectedFields.sort(Reflect.compare);
			actualFields.sort(Reflect.compare);

			if (expectedFields.join(",") != actualFields.join(",")) {
				throw '$path: expected fields [${expectedFields.join(", ")}], got [${actualFields.join(", ")}]';
			}

			for (field in expectedFields) {
				equals(Reflect.field(expected, field), Reflect.field(actual, field), '$path.$field');
			}

			return;
		}

		if (Type.typeof(expected) != Type.typeof(actual) || expected != actual) {
			fail(path, expected, actual);
		}
	}

	private static function isString(value:Dynamic):Bool {
		return Std.isOfType(value, String);
	}

	private static function isNumber(value:Dynamic):Bool {
		return switch (Type.typeof(value)) {
			case TInt, TFloat: true;
			default: false;
		};
	}

	private static function isBool(value:Dynamic):Bool {
		return Std.isOfType(value, Bool);
	}

	private static function fail(path:String, expected:Dynamic, actual:Dynamic):Void {
		throw '$path: expected ${Std.string(expected)}, got ${Std.string(actual)}';
	}
}
