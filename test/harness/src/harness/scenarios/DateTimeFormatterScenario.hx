package harness.scenarios;

import openfl.globalization.DateTimeFormatter;
import openfl.globalization.DateTimeStyle;
import openfl.globalization.LastOperationStatus;

class DateTimeFormatterScenario {
	public static function run():Dynamic {
		var localDate = new Date(2024, 1, 29, 13, 5, 9);
		var utcDate = Date.fromTime(1709211909000.0);
		var formatter = new DateTimeFormatter("en-US", DateTimeStyle.LONG, DateTimeStyle.SHORT);

		var initial = {
			requestedLocaleIDName: formatter.requestedLocaleIDName,
			actualLocaleIDName: formatter.actualLocaleIDName,
			dateStyleIsLong: formatter.getDateStyle() == DateTimeStyle.LONG,
			timeStyleIsShort: formatter.getTimeStyle() == DateTimeStyle.SHORT,
			pattern: formatter.getDateTimePattern(),
			local: formatter.format(localDate),
			utc: formatter.formatUTC(utcDate),
			statusIsNoError: formatter.lastOperationStatus == LastOperationStatus.NO_ERROR
		};

		formatter.setDateTimePattern("yyyy-MM-dd HH:mm:ss");

		var custom = {
			dateStyleIsCustom: formatter.getDateStyle() == DateTimeStyle.CUSTOM,
			timeStyleIsCustom: formatter.getTimeStyle() == DateTimeStyle.CUSTOM,
			pattern: formatter.getDateTimePattern(),
			local: formatter.format(localDate),
			utc: formatter.formatUTC(utcDate),
			statusIsNoError: formatter.lastOperationStatus == LastOperationStatus.NO_ERROR
		};

		return {
			initial: initial,
			custom: custom
		};
	}
}
