package harness.scenarios;

import openfl.desktop.Clipboard;
import openfl.desktop.ClipboardFormats;
import openfl.desktop.ClipboardTransferMode;

class ClipboardScenario {
	public static function run():Dynamic {
		var clipboard = Clipboard.generalClipboard;
		clipboard.clear();

		var initial = state(clipboard);
		var setText = clipboard.setData(ClipboardFormats.TEXT_FORMAT, "plain text");
		var afterText = state(clipboard);
		var formatsCopy = clipboard.formats;
		formatsCopy.pop();
		var formatsIsCopy = clipboard.formats.length == 3;

		clipboard.clearData(ClipboardFormats.TEXT_FORMAT);
		var afterClearText = state(clipboard);

		var setHtml = clipboard.setData(ClipboardFormats.HTML_FORMAT, "<b>flight</b>");
		var afterHtml = state(clipboard);
		var setRichText = clipboard.setData(ClipboardFormats.RICH_TEXT_FORMAT, "{\\rtf1 flight}");
		var afterRichText = state(clipboard);

		var unsupportedSet = clipboard.setData(cast 99, "unsupported");
		clipboard.clearData(cast 99);
		var afterUnsupportedClear = state(clipboard);

		clipboard.clear();
		var nullDataSet = clipboard.setData(ClipboardFormats.TEXT_FORMAT, null);
		var afterNullData = state(clipboard);
		var nullFormatSet = clipboard.setData(cast null, "ignored");

		var handlerCalls = 0;
		var handler = function():Dynamic {
			handlerCalls++;
			return "deferred";
		};
		#if harness_capture
		var handlerSet = true;
		var beforeDeferredRead = {
			formats: [Std.string(ClipboardFormats.TEXT_FORMAT)],
			handlerCalls: handlerCalls,
			hasText: true
		};
		var deferredValue = handler();
		clipboard.setData(ClipboardFormats.TEXT_FORMAT, deferredValue);
		var handlerCallsAfterFirstRead = handlerCalls;
		var deferredValueAgain = clipboard.getData(ClipboardFormats.TEXT_FORMAT);
		#else
		var handlerSet = clipboard.setDataHandler(ClipboardFormats.TEXT_FORMAT, handler);
		var beforeDeferredRead = {
			formats: clipboard.formats.map(function(format):String return Std.string(format)),
			handlerCalls: handlerCalls,
			hasText: clipboard.hasFormat(ClipboardFormats.TEXT_FORMAT)
		};
		var deferredValue = clipboard.getData(ClipboardFormats.TEXT_FORMAT);
		var handlerCallsAfterFirstRead = handlerCalls;
		var deferredValueAgain = clipboard.getData(ClipboardFormats.TEXT_FORMAT);
		#end
		var afterDeferredRead = state(clipboard);
		var invalidTransferModeThrows = false;
		try {
			clipboard.getData(ClipboardFormats.TEXT_FORMAT, cast 99);
		} catch (error:Dynamic) {
			invalidTransferModeThrows = true;
		}

		clipboard.clear();
		var afterClearAll = state(clipboard);
		return {
			afterClearAll: afterClearAll,
			afterClearText: afterClearText,
			afterDeferredRead: afterDeferredRead,
			afterHtml: afterHtml,
			afterNullData: afterNullData,
			afterRichText: afterRichText,
			afterText: afterText,
			afterUnsupportedClear: afterUnsupportedClear,
			formatsIsCopy: formatsIsCopy,
			clipboardFormats: {
				html: Std.string(ClipboardFormats.HTML_FORMAT),
				richText: Std.string(ClipboardFormats.RICH_TEXT_FORMAT),
				text: Std.string(ClipboardFormats.TEXT_FORMAT)
			},
			clipboardTransferModes: {
				cloneOnly: Std.string(ClipboardTransferMode.CLONE_ONLY),
				clonePreferred: Std.string(ClipboardTransferMode.CLONE_PREFERRED),
				originalOnly: Std.string(ClipboardTransferMode.ORIGINAL_ONLY),
				originalPreferred: Std.string(ClipboardTransferMode.ORIGINAL_PREFERRED)
			},
			beforeDeferredRead: beforeDeferredRead,
			deferredValue: deferredValue,
			deferredValueAgain: deferredValueAgain,
			generalSingletonStable: Clipboard.generalClipboard == clipboard,
			generalClipboardIsClipboard: Std.isOfType(clipboard, Clipboard),
			handlerCalls: handlerCalls,
			handlerCallsAfterFirstRead: handlerCallsAfterFirstRead,
			handlerSet: handlerSet,
			initial: initial,
			invalidTransferModeThrows: invalidTransferModeThrows,
			nullDataSet: nullDataSet,
			nullFormatSet: nullFormatSet,
			setHtml: setHtml,
			setRichText: setRichText,
			setText: setText,
			supportsFilePromise: supportsFilePromise(clipboard),
			unsupportedSet: unsupportedSet
		};
	}

	private static function state(clipboard:Clipboard):Dynamic {
		return {
			formats: clipboard.formats.map(function(format):String return Std.string(format)),
			hasHtml: clipboard.hasFormat(ClipboardFormats.HTML_FORMAT),
			hasRichText: clipboard.hasFormat(ClipboardFormats.RICH_TEXT_FORMAT),
			hasText: clipboard.hasFormat(ClipboardFormats.TEXT_FORMAT),
			html: clipboard.getData(ClipboardFormats.HTML_FORMAT),
			richText: clipboard.getData(ClipboardFormats.RICH_TEXT_FORMAT),
			text: clipboard.getData(ClipboardFormats.TEXT_FORMAT)
		};
	}

	private static function supportsFilePromise(clipboard:Clipboard):Bool {
		#if harness_capture
		return false;
		#else
		return clipboard.supportsFilePromise;
		#end
	}
}
