package harness.scenarios;

import openfl.globalization.DateTimeFormatter;
import openfl.globalization.DateTimeNameContext;
import openfl.globalization.DateTimeNameStyle;
import openfl.globalization.DateTimeStyle;
import openfl.globalization.LastOperationStatus;

class DateTimeFormatterScenario {
	public static function run():Dynamic {
		var localDate = new Date(2024, 1, 29, 13, 5, 9);
		var utcDate = Date.fromTime(1709211909000.0);
		var formatter = new DateTimeFormatter("en-US", DateTimeStyle.LONG, DateTimeStyle.SHORT);
		var availableLocaleIDs = [for (locale in DateTimeFormatter.getAvailableLocaleIDNames()) locale];
		var unknownStatus:LastOperationStatus = "not-a-status";

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

		var styleFormatter = new DateTimeFormatter("en-US", DateTimeStyle.LONG, DateTimeStyle.LONG);
		styleFormatter.setDateTimeStyles(DateTimeStyle.CUSTOM, DateTimeStyle.SHORT);
		var customStyleRejected = styleFormatter.lastOperationStatus == LastOperationStatus.ILLEGAL_ARGUMENT_ERROR;
		styleFormatter.setDateTimeStyles(DateTimeStyle.MEDIUM, DateTimeStyle.NONE);
		var changedStyles = {
			customRejected: customStyleRejected,
			dateStyleIsMedium: styleFormatter.getDateStyle() == DateTimeStyle.MEDIUM,
			pattern: styleFormatter.getDateTimePattern(),
			statusIsNoError: styleFormatter.lastOperationStatus == LastOperationStatus.NO_ERROR,
			timeStyleIsNone: styleFormatter.getTimeStyle() == DateTimeStyle.NONE
		};

		var quotedFormatter = new DateTimeFormatter("en-US");
		quotedFormatter.setDateTimePattern("G yyyy 'year' MMMM dd EEEE a K h H k mm ss");
		var quotedCustom = {
			formatted: quotedFormatter.format(localDate),
			statusIsNoError: quotedFormatter.lastOperationStatus == LastOperationStatus.NO_ERROR
		};

		return {
			availableLocaleIDs: availableLocaleIDs,
			changedStyles: changedStyles,
			initial: initial,
			custom: custom,
			quotedCustom: quotedCustom,
			nameLists: {
				firstFullMonth: formatter.getMonthNames(DateTimeNameStyle.FULL, DateTimeNameContext.FORMAT)[0],
				firstLongWeekday: formatter.getWeekdayNames(DateTimeNameStyle.LONG_ABBREVIATION, DateTimeNameContext.STANDALONE)[0],
				firstShortWeekday: formatter.getWeekdayNames(DateTimeNameStyle.SHORT_ABBREVIATION, DateTimeNameContext.FORMAT)[0]
			},
			enumerations: {
				dateTimeNameContexts: [Std.string(DateTimeNameContext.FORMAT), Std.string(DateTimeNameContext.STANDALONE)],
				dateTimeNameStyles: [
					Std.string(DateTimeNameStyle.FULL),
					Std.string(DateTimeNameStyle.LONG_ABBREVIATION),
					Std.string(DateTimeNameStyle.SHORT_ABBREVIATION)
				],
				dateTimeStyles: [
					Std.string(DateTimeStyle.CUSTOM),
					Std.string(DateTimeStyle.LONG),
					Std.string(DateTimeStyle.MEDIUM),
					Std.string(DateTimeStyle.NONE),
					Std.string(DateTimeStyle.SHORT)
				],
				lastOperationStatuses: [
					Std.string(LastOperationStatus.BUFFER_OVERFLOW_ERROR),
					Std.string(LastOperationStatus.ERROR_CODE_UNKNOWN),
					Std.string(LastOperationStatus.ILLEGAL_ARGUMENT_ERROR),
					Std.string(LastOperationStatus.INDEX_OUT_OF_BOUNDS_ERROR),
					Std.string(LastOperationStatus.INVALID_ATTR_VALUE),
					Std.string(LastOperationStatus.INVALID_CHAR_FOUND),
					Std.string(LastOperationStatus.MEMORY_ALLOCATION_ERROR),
					Std.string(LastOperationStatus.NO_ERROR),
					Std.string(LastOperationStatus.NUMBER_OVERFLOW_ERROR),
					Std.string(LastOperationStatus.PARSE_ERROR),
					Std.string(LastOperationStatus.PATTERN_SYNTAX_ERROR),
					Std.string(LastOperationStatus.PLATFORM_API_FAILED),
					Std.string(LastOperationStatus.TRUNCATED_CHAR_FOUND),
					Std.string(LastOperationStatus.UNEXPECTED_TOKEN),
					Std.string(LastOperationStatus.UNSUPPORTED_ERROR),
					Std.string(LastOperationStatus.USING_DEFAULT_WARNING),
					Std.string(LastOperationStatus.USING_FALLBACK_WARNING)
				],
				unknownLastOperationStatusIsNull: unknownStatus == null
			}
		};
	}
}
