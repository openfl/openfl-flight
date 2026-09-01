package harness.scenarios;

import openfl.permissions.PermissionStatus;

class PermissionStatusScenario {
	public static function run():Dynamic {
		return {
			denied: Std.string(PermissionStatus.DENIED),
			granted: Std.string(PermissionStatus.GRANTED),
			onlyWhenInUse: Std.string(PermissionStatus.ONLY_WHEN_IN_USE),
			unknown: Std.string(PermissionStatus.UNKNOWN),
			allDistinct: PermissionStatus.DENIED != PermissionStatus.GRANTED
				&& PermissionStatus.GRANTED != PermissionStatus.ONLY_WHEN_IN_USE
				&& PermissionStatus.ONLY_WHEN_IN_USE != PermissionStatus.UNKNOWN
		};
	}
}
