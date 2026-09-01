package harness.scenarios;

import openfl.errors.Error;

class ErrorScenario {
	public static function run():Dynamic {
		var populated = new Error("message", 37);
		var empty = new Error();
		var nullMessage = new Error(null, 9);
		var stackTrace = populated.getStackTrace();

		return {
			populated: describe(populated),
			empty: describe(empty),
			nullMessage: describe(nullMessage),
			stackTrace: {
				isNull: stackTrace == null,
				isString: Std.isOfType(stackTrace, String)
			}
		};
	}

	private static function describe(error:Error):Dynamic {
		return {
			className: Type.getClassName(Type.getClass(error)),
			name: error.name,
			message: error.message,
			errorID: error.errorID,
			stringValue: error.toString()
		};
	}
}
