package harness.scenarios;

import openfl.external.ExternalInterface;

class ExternalInterfaceScenario {
	public static function run():Dynamic {
		var objectID:String = null;
		var objectIDReadSucceeded = succeeds(function() {
			objectID = ExternalInterface.objectID;
		});
		var callResult:Dynamic = null;
		var callDidNotThrow = succeeds(function() {
			callResult = ExternalInterface.call("org.openfl.missing");
		});
		var nullGapResult:Dynamic = null;
		var nullGapDidNotThrow = succeeds(function() {
			nullGapResult = ExternalInterface.call("org.openfl.missing", "first", null, "ignored");
		});
		var addCallbackDidNotThrow = succeeds(function() {
			ExternalInterface.addCallback("org_openfl_test", function() return 42);
		});
		var removeCallbackDidNotThrow = succeeds(function() {
			ExternalInterface.addCallback("org_openfl_test", null);
		});

		return {
			available: ExternalInterface.available,
			availableIsBool: Type.typeof(ExternalInterface.available) == TBool,
			objectID: objectID,
			objectIDReadSucceeded: objectIDReadSucceeded,
			objectIDIsNull: objectID == null,
			objectIDIsStringOrNull: objectID == null || Std.isOfType(objectID, String),
			callWhenUnavailable: {
				didNotThrow: callDidNotThrow,
				returnedNull: callResult == null
			},
			invocationContract: {
				didNotThrow: nullGapDidNotThrow,
				returnedNull: nullGapResult == null
			},
			callbackContract: {
				addDidNotThrow: addCallbackDidNotThrow,
				removeWithNullDidNotThrow: removeCallbackDidNotThrow
			}
		};
	}

	private static function succeeds(operation:Void->Void):Bool {
		try {
			operation();
			return true;
		} catch (_:Dynamic) {
			return false;
		}
	}
}
