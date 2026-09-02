package harness.scenarios;

import openfl.display.Sprite;
import openfl.geom.Rectangle;
import openfl.printing.PrintJob;
import openfl.printing.PrintJobOptions;
import openfl.printing.PrintJobOrientation;

class PrintJobScenario
{
	public static function run():Dynamic
	{
		var constructionDidNotThrow = true;
		var printJob:PrintJob = null;
		try
		{
			printJob = new PrintJob();
		}
		catch (_:Dynamic)
		{
			constructionDidNotThrow = false;
		}

		var defaults = {
			orientationIsNull: printJob.orientation == null,
			pageHeight: printJob.pageHeight,
			pageWidth: printJob.pageWidth,
			paperHeight: printJob.paperHeight,
			paperWidth: printJob.paperWidth
		};
		var startResult = false;
		var startDidNotThrow = succeeds(function() {
			startResult = printJob.start();
		});
		var defaultOptions = new PrintJobOptions();
		var bitmapOptions = new PrintJobOptions(true);
		var defaultPrintAsBitmap = defaultOptions.printAsBitmap;
		var addPageDidNotThrow = succeeds(function() {
			printJob.addPage(new Sprite(), new Rectangle(0, 0, 64, 32), bitmapOptions, 1);
		});
		var sendDidNotThrow = succeeds(printJob.send);

		defaultOptions.printAsBitmap = true;
		return {
			constructionDidNotThrow: constructionDidNotThrow,
			constructionType: Type.getClassName(Type.getClass(printJob)),
			defaults: defaults,
			isSupported: PrintJob.isSupported,
			isSupportedIsBool: Type.typeof(PrintJob.isSupported) == TBool,
			lifecycle: {
				addPageDidNotThrow: addPageDidNotThrow,
				sendDidNotThrow: sendDidNotThrow,
				startDidNotThrow: startDidNotThrow,
				startResult: startResult,
				unsupportedNoOp: !PrintJob.isSupported && !startResult && addPageDidNotThrow && sendDidNotThrow
			},
			options: {
				bitmapConstructor: bitmapOptions.printAsBitmap,
				defaultConstructor: defaultPrintAsBitmap,
				mutableRoundTrip: defaultOptions.printAsBitmap
			},
			orientations: {
				landscape: Std.string(PrintJobOrientation.LANDSCAPE),
				portrait: Std.string(PrintJobOrientation.PORTRAIT)
			}
		};
	}

	private static function succeeds(operation:Void->Void):Bool
	{
		try
		{
			operation();
			return true;
		}
		catch (_:Dynamic)
		{
			return false;
		}
	}
}
