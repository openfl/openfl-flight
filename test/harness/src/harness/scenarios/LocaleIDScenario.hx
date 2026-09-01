package harness.scenarios;

import openfl.globalization.LastOperationStatus;
import openfl.globalization.LocaleID;

class LocaleIDScenario {
	public static function run():Dynamic {
		return {
			languageAndRegion: describe(new LocaleID("en_US")),
			scriptRegionAndVariant: describe(new LocaleID("zh_Hant_TW_POSIX")),
			rightToLeft: describe(new LocaleID("ar_EG"))
		};
	}

	private static function describe(locale:LocaleID):Dynamic {
		return {
			name: locale.name,
			language: locale.getLanguage(),
			region: locale.getRegion(),
			script: locale.getScript(),
			variant: locale.getVariant(),
			rightToLeft: locale.isRightToLeft(),
			statusIsNoError: locale.lastOperationStatus == LastOperationStatus.NO_ERROR
		};
	}
}
