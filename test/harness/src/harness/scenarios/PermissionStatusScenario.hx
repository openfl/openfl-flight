package harness.scenarios;

import openfl.permissions.PermissionStatus;

class PermissionStatusScenario {
	public static function run():Dynamic {
		var deniedFromString:PermissionStatus = "denied";
		var grantedFromString:PermissionStatus = "granted";
		var onlyWhenInUseFromString:PermissionStatus = "onlyWhenInUse";
		var unknownFromString:PermissionStatus = "unknown";
		var invalidFromString:PermissionStatus = "invalid";

		return {
			denied: Std.string(PermissionStatus.DENIED),
			granted: Std.string(PermissionStatus.GRANTED),
			onlyWhenInUse: Std.string(PermissionStatus.ONLY_WHEN_IN_USE),
			unknown: Std.string(PermissionStatus.UNKNOWN),
			constants: {
				denied: Std.string(PermissionStatus.DENIED),
				granted: Std.string(PermissionStatus.GRANTED),
				onlyWhenInUse: Std.string(PermissionStatus.ONLY_WHEN_IN_USE)
			},
			construction: {
				denied: Std.string(deniedFromString),
				granted: Std.string(grantedFromString),
				onlyWhenInUse: Std.string(onlyWhenInUseFromString),
				unknown: Std.string(unknownFromString),
				invalidIsNull: invalidFromString == null,
				matchesConstants: deniedFromString == PermissionStatus.DENIED
					&& grantedFromString == PermissionStatus.GRANTED
					&& onlyWhenInUseFromString == PermissionStatus.ONLY_WHEN_IN_USE
					&& unknownFromString == PermissionStatus.UNKNOWN
			},
			statusValues: [
				Std.string(PermissionStatus.DENIED),
				Std.string(PermissionStatus.GRANTED),
				Std.string(PermissionStatus.ONLY_WHEN_IN_USE),
				Std.string(PermissionStatus.UNKNOWN)
			],
			allDistinct: PermissionStatus.DENIED != PermissionStatus.GRANTED
				&& PermissionStatus.GRANTED != PermissionStatus.ONLY_WHEN_IN_USE
				&& PermissionStatus.ONLY_WHEN_IN_USE != PermissionStatus.UNKNOWN
		};
	}
}
