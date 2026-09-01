package harness.scenarios;

import openfl.external.ExternalInterface;

class ExternalInterfaceScenario {
	public static function run():Dynamic {
		return {
			available: ExternalInterface.available,
			objectID: ExternalInterface.objectID,
			objectIDIsNull: ExternalInterface.objectID == null
		};
	}
}
