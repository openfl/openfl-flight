package harness.scenarios;

import openfl.desktop.NativeApplication;
import openfl.desktop.SystemIdleMode;

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
				isSet: application.isSetAsDefaultApplication("flight")
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

	private static function expected():Dynamic {
		return {
			activateThrows: false,
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
				isSet: false
			},
			idleAboveMaximumThrows: true,
			idleBelowMinimumThrows: true,
			invalidIdleModeThrows: true,
			mutated: {
				autoExit: false,
				idleThreshold: 120,
				startAtLogin: false,
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
