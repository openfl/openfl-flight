package harness.scenarios;

import openfl.Vector;
import openfl.desktop.NativeProcess;
import openfl.desktop.NativeProcessStartupInfo;
import openfl.filesystem.File;

class NativeProcessScenario
{
	public static function run():Dynamic
	{
		#if harness_capture
		return expected();
		#else
		var info = new NativeProcessStartupInfo();
		var defaults = {
			argumentsIsNull: info.arguments == null,
			executableIsNull: info.executable == null,
			workingDirectoryIsNull: info.workingDirectory == null
		};

		var arguments = Vector.ofValues("--flight", "value with spaces");
		var executable = new File(Sys.getCwd());
		var workingDirectory = new File(Sys.getCwd());
		info.arguments = arguments;
		info.executable = executable;
		info.workingDirectory = workingDirectory;

		var process = new NativeProcess();
		var runningBeforeStart = process.running;
		var startDidNotThrow = succeeds(function() process.start(info));
		var closeInputDidNotThrow = succeeds(process.closeInput);
		var exitDidNotThrow = succeeds(function() process.exit());

		return {
			startupInfo: {
				defaults: defaults,
				arguments: [for (argument in info.arguments) argument],
				argumentsSameReference: info.arguments == arguments,
				executableSameReference: info.executable == executable,
				workingDirectorySameReference: info.workingDirectory == workingDirectory
			},
			process: {
				closeInputDidNotThrow: closeInputDidNotThrow,
				constructionType: Type.getClassName(Type.getClass(process)),
				exitDidNotThrow: exitDidNotThrow,
				isSupported: NativeProcess.isSupported,
				isSupportedIsBool: Type.typeof(NativeProcess.isSupported) == TBool,
				runningBeforeStart: runningBeforeStart,
				standardErrorAvailable: process.standardError != null,
				standardInputAvailable: process.standardInput != null,
				standardOutputAvailable: process.standardOutput != null,
				startBehavior: {
					didNotThrow: startDidNotThrow,
					runningAfterStart: process.running,
					unsupportedNoOp: !NativeProcess.isSupported && startDidNotThrow && !process.running
				}
			}
		};
		#end
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

	private static function expected():Dynamic
	{
		return {
			startupInfo: {
				defaults: {
					argumentsIsNull: true,
					executableIsNull: true,
					workingDirectoryIsNull: true
				},
				arguments: ["--flight", "value with spaces"],
				argumentsSameReference: true,
				executableSameReference: true,
				workingDirectorySameReference: true
			},
			process: {
				closeInputDidNotThrow: true,
				constructionType: "openfl.desktop.NativeProcess",
				exitDidNotThrow: true,
				isSupported: false,
				isSupportedIsBool: true,
				runningBeforeStart: false,
				standardErrorAvailable: true,
				standardInputAvailable: true,
				standardOutputAvailable: true,
				startBehavior: {
					didNotThrow: true,
					runningAfterStart: false,
					unsupportedNoOp: true
				}
			}
		};
	}
}
