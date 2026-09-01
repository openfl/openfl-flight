package harness.scenarios;

import openfl.system.Capabilities;
import openfl.system.System;

class SystemScenario {
	public static function run():Dynamic {
		var totalMemory = System.totalMemory;
		return {
			capabilities: {
				language: Capabilities.language,
				os: Capabilities.os,
				playerType: Capabilities.playerType,
				version: Capabilities.version,
				screenResolutionX: Capabilities.screenResolutionX,
				screenResolutionY: Capabilities.screenResolutionY
			},
			system: {
				totalMemoryIsInt: Type.typeof(totalMemory) == TInt,
				totalMemoryNonNegative: totalMemory >= 0
			}
		};
	}
}
