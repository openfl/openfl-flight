package harness.scenarios;

import openfl.errors.ArgumentError;
import openfl.errors.EOFError;
import openfl.errors.Error;
import openfl.errors.IOError;
import openfl.errors.IllegalOperationError;
import openfl.errors.PermissionError;
import openfl.errors.RangeError;
import openfl.errors.SecurityError;
import openfl.errors.TypeError;

class ErrorSubclassesScenario {
	public static function run():Dynamic {
		var eof = new EOFError("ignored message", 91);

		return {
			argument: describe(new ArgumentError("argument")),
			eof: describe(eof),
			eofIsIOError: Std.isOfType(eof, IOError),
			io: describe(new IOError("io")),
			illegalOperation: describe(new IllegalOperationError("illegal")),
			permission: describe(new PermissionError("permission", 44)),
			range: describe(new RangeError("range")),
			security: describe(new SecurityError("security")),
			type: describe(new TypeError("type"))
		};
	}

	private static function describe(error:Error):Dynamic {
		return {
			className: Type.getClassName(Type.getClass(error)),
			isError: Std.isOfType(error, Error),
			name: error.name,
			message: error.message,
			errorID: error.errorID,
			stringValue: error.toString()
		};
	}
}
