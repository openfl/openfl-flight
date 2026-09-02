package harness.scenarios;

import openfl.errors.ArgumentError;
import openfl.errors.Error;
import openfl.errors.IllegalOperationError;
import openfl.errors.RangeError;
import openfl.errors.SecurityError;
import openfl.errors.TypeError;

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
				isString: Std.isOfType(stackTrace, String),
				isStringOrNull: stackTrace == null || Std.isOfType(stackTrace, String)
			},
			subclasses: {
				argument: describe(new ArgumentError("argument")),
				range: describe(new RangeError("range")),
				type: describe(new TypeError("type")),
				security: describe(new SecurityError("security")),
				illegalOperation: describe(new IllegalOperationError("illegal"))
			}
		};
	}

	private static function describe(error:Error):Dynamic {
		return {
			className: Type.getClassName(Type.getClass(error)),
			isError: Std.isOfType(error, Error),
			name: error.name,
			message: error.message,
			errorID: error.errorID,
			stringValue: error.toString(),
			stringMatchesMessage: error.toString() == error.message
		};
	}
}
