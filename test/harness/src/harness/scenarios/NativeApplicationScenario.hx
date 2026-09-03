package harness.scenarios;

import openfl.desktop.NativeApplication;
import openfl.desktop.SystemIdleMode;
import openfl.system.System;

@:access(openfl.desktop.NativeApplication)
class NativeApplicationScenario {
	public static function run():Dynamic {
		#if harness_capture
		return expected();
		#else
		var application = NativeApplication.nativeApplication;
		var openedWindows = application.openedWindows;
		openedWindows.push(null);

		var idleBelowMinimumThrows = false;
		try {
			application.idleThreshold = 4;
		} catch (error:Dynamic) {
			idleBelowMinimumThrows = true;
		}

		var idleAboveMaximumThrows = false;
		try {
			application.idleThreshold = 86401;
		} catch (error:Dynamic) {
			idleAboveMaximumThrows = true;
		}

		var invalidIdleModeThrows = false;
		try {
			application.systemIdleMode = cast 99;
		} catch (error:Dynamic) {
			invalidIdleModeThrows = true;
		}

		var activateThrows = false;
		try {
			application.activate();
		} catch (error:Dynamic) {
			activateThrows = true;
		}

		var applicationDescriptor:Xml = null;
		var applicationDescriptorReadable = succeeds(function() {
			applicationDescriptor = application.applicationDescriptor;
		});
		var applicationID:String = null;
		var applicationIDReadable = succeeds(function() {
			applicationID = application.applicationID;
		});
		var publisherID:String = null;
		var publisherIDReadable = succeeds(function() {
			publisherID = application.publisherID;
		});
		var removeAsDefaultApplicationDidNotThrow = succeeds(function() {
			application.removeAsDefaultApplication("flight");
		});
		var setAsDefaultApplicationDidNotThrow = succeeds(function() {
			application.setAsDefaultApplication("flight");
		});
		var systemPauseDidNotThrow = succeeds(System.pause);
		var flightApplicationHandle = application.__flightApplication;
		var systemResumeDidNotThrow = succeeds(System.resume);

		var defaults = {
			activeWindowIsNull: application.activeWindow == null,
			autoExit: application.autoExit,
			iconIsNull: application.icon == null,
			idleThreshold: application.idleThreshold,
			menuIsNull: application.menu == null,
			openedWindowCount: application.openedWindows.length,
			openedWindowsIsCopy: application.openedWindows.length == 0,
			runtimePatchLevel: application.runtimePatchLevel,
			runtimeVersion: application.runtimeVersion,
			startAtLogin: application.startAtLogin,
			systemIdleMode: Std.string(application.systemIdleMode)
		};

		application.autoExit = false;
		application.idleThreshold = 120;
		application.startAtLogin = true;
		application.systemIdleMode = SystemIdleMode.KEEP_AWAKE;

		var result = {
			activateThrows: activateThrows,
			applicationIdentity: {
				applicationDescriptorIsNull: applicationDescriptor == null,
				applicationDescriptorReadable: applicationDescriptorReadable,
				applicationID: applicationID,
				applicationIDReadable: applicationIDReadable,
				publisherID: publisherID,
				publisherIDReadable: publisherIDReadable
			},
			commands: {
				clear: application.clear(),
				copy: application.copy(),
				cut: application.cut(),
				paste: application.paste(),
				selectAll: application.selectAll()
			},
			defaults: defaults,
			defaultApplication: {
				getIsNull: application.getDefaultApplication("flight") == null,
				isSet: application.isSetAsDefaultApplication("flight"),
				removeDidNotThrow: removeAsDefaultApplicationDidNotThrow,
				setDidNotThrow: setAsDefaultApplicationDidNotThrow
			},
			flightApplicationHandle: {
				available: flightApplicationHandle != null,
				sameForSingleton: NativeApplication.nativeApplication.__flightApplication == flightApplicationHandle,
				systemPauseDidNotThrow: systemPauseDidNotThrow,
				systemResumeDidNotThrow: systemResumeDidNotThrow
			},
			idleAboveMaximumThrows: idleAboveMaximumThrows,
			idleBelowMinimumThrows: idleBelowMinimumThrows,
			invalidIdleModeThrows: invalidIdleModeThrows,
			mutated: {
				autoExit: application.autoExit,
				idleThreshold: application.idleThreshold,
				startAtLogin: application.startAtLogin,
				systemIdleMode: Std.string(application.systemIdleMode)
			},
			singletonStable: NativeApplication.nativeApplication == application,
			supports: {
				defaultApplication: NativeApplication.supportsDefaultApplication,
				dockIcon: NativeApplication.supportsDockIcon,
				menu: NativeApplication.supportsMenu,
				startAtLogin: NativeApplication.supportsStartAtLogin,
				systemTrayIcon: NativeApplication.supportsSystemTrayIcon
			}
		};

		application.autoExit = true;
		application.idleThreshold = 300;
		application.startAtLogin = false;
		application.systemIdleMode = SystemIdleMode.NORMAL;
		return result;
		#end
	}

	private static function succeeds(operation:Void->Void):Bool {
		try {
			operation();
			return true;
		} catch (_:Dynamic) {
			return false;
		}
	}

	private static function expected():Dynamic {
		return {
			activateThrows: false,
			applicationIdentity: {
				applicationDescriptorIsNull: true,
				applicationDescriptorReadable: true,
				applicationID: null,
				applicationIDReadable: true,
				publisherID: null,
				publisherIDReadable: true
			},
			commands: {
				clear: false,
				copy: false,
				cut: false,
				paste: false,
				selectAll: false
			},
			defaults: {
				activeWindowIsNull: true,
				autoExit: true,
				iconIsNull: true,
				idleThreshold: 300,
				menuIsNull: true,
				openedWindowCount: 0,
				openedWindowsIsCopy: true,
				runtimePatchLevel: 0,
				runtimeVersion: null,
				startAtLogin: false,
				systemIdleMode: "normal"
			},
			defaultApplication: {
				getIsNull: true,
				isSet: false,
				removeDidNotThrow: true,
				setDidNotThrow: true
			},
			flightApplicationHandle: {
				available: true,
				sameForSingleton: true,
				systemPauseDidNotThrow: true,
				systemResumeDidNotThrow: true
			},
			idleAboveMaximumThrows: true,
			idleBelowMinimumThrows: true,
			invalidIdleModeThrows: true,
			mutated: {
				autoExit: false,
				idleThreshold: 120,
				startAtLogin: true,
				systemIdleMode: "keepAwake"
			},
			singletonStable: true,
			supports: {
				defaultApplication: false,
				dockIcon: false,
				menu: false,
				startAtLogin: false,
				systemTrayIcon: false
			}
		};
	}
}
