package harness.scenarios;

import openfl.desktop.Clipboard;
import openfl.desktop.ClipboardFormats;
import openfl.desktop.ClipboardTransferMode;
import openfl.desktop.DockIcon;
import openfl.desktop.Icon;
import openfl.desktop.InteractiveIcon;
import openfl.desktop.InvokeEventReason;
import openfl.desktop.NativeApplication;
import openfl.desktop.NativeProcess;
import openfl.desktop.NativeProcessStartupInfo;
import openfl.desktop.NotificationType;
import openfl.desktop.SystemIdleMode;
import openfl.desktop.SystemTrayIcon;
import openfl.desktop.Updater;
import openfl.display.NativeWindow;
import openfl.display.NativeWindowDisplayState;
import openfl.display.NativeWindowInitOptions;
import openfl.display.NativeWindowSystemChrome;
import openfl.display.NativeWindowType;
import openfl.geom.Point;
import openfl.geom.Rectangle;

class DesktopScenario {
	public static function run():Dynamic {
		var nativeApplication = NativeApplication.nativeApplication;
		var defaultOptions = new NativeWindowInitOptions();
		var icon = new Icon();
		var interactiveIcon = new InteractiveIcon();
		var process = new NativeProcess();
		var processInfo = new NativeProcessStartupInfo();
		var trayIcon = new SystemTrayIcon();
		var updater = new Updater();
		var dockBounceThrows = false;
		var applicationID:String = null;

		try {
			applicationID = nativeApplication.applicationID;
		} catch (error:Dynamic) {}

		try {
			new DockIcon().bounce();
		} catch (error:Dynamic) {
			dockBounceThrows = true;
		}

		return {
			application: {
				singletonStable: NativeApplication.nativeApplication == nativeApplication,
				activeWindowIsNull: nativeApplication.activeWindow == null,
				applicationID: applicationID,
				autoExit: nativeApplication.autoExit,
				iconIsNull: nativeApplication.icon == null,
				isCompiledAOT: nativeApplication.isCompiledAOT,
				openedWindows: nativeApplication.openedWindows.length,
				supportsDefaultApplication: NativeApplication.supportsDefaultApplication,
				supportsDockIcon: NativeApplication.supportsDockIcon,
				supportsMenu: NativeApplication.supportsMenu,
				supportsStartAtLogin: NativeApplication.supportsStartAtLogin,
				supportsSystemTrayIcon: NativeApplication.supportsSystemTrayIcon
			},
			clipboard: {
				generalSingletonStable: Clipboard.generalClipboard == Clipboard.generalClipboard,
				formats: [Std.string(ClipboardFormats.HTML_FORMAT), Std.string(ClipboardFormats.RICH_TEXT_FORMAT), Std.string(ClipboardFormats.TEXT_FORMAT)],
				transferModes: [
					Std.string(ClipboardTransferMode.CLONE_ONLY),
					Std.string(ClipboardTransferMode.CLONE_PREFERRED),
					Std.string(ClipboardTransferMode.ORIGINAL_ONLY),
					Std.string(ClipboardTransferMode.ORIGINAL_PREFERRED)
				]
			},
			constants: {
				invokeReasons: [
					Std.string(InvokeEventReason.LOGIN),
					Std.string(InvokeEventReason.NOTIFICATION),
					Std.string(InvokeEventReason.OPEN_URL),
					Std.string(InvokeEventReason.STANDARD)
				],
				notificationTypes: [Std.string(NotificationType.CRITICAL), Std.string(NotificationType.INFORMATIONAL)],
				systemIdleModes: [Std.string(SystemIdleMode.KEEP_AWAKE), Std.string(SystemIdleMode.NORMAL)],
				windowDisplayStates: [
					Std.string(NativeWindowDisplayState.NORMAL),
					Std.string(NativeWindowDisplayState.MAXIMIZED),
					Std.string(NativeWindowDisplayState.MINIMIZED)
				],
				windowChrome: [
					Std.string(NativeWindowSystemChrome.ALTERNATE),
					Std.string(NativeWindowSystemChrome.NONE),
					Std.string(NativeWindowSystemChrome.STANDARD)
				],
				windowTypes: [Std.string(NativeWindowType.LIGHTWEIGHT), Std.string(NativeWindowType.NORMAL), Std.string(NativeWindowType.UTILITY)]
			},
			icons: {
				dockBounceThrows: dockBounceThrows,
				iconBitmapCount: icon.bitmaps.length,
				interactiveHeight: interactiveIcon.height,
				interactiveWidth: interactiveIcon.width,
				trayMaxTipLength: SystemTrayIcon.MAX_TIP_LENGTH,
				trayTooltipIsNull: trayIcon.tooltip == null
			},
			process: {
				argumentsAreNull: processInfo.arguments == null,
				executableIsNull: processInfo.executable == null,
				isSupported: nativeProcessSupported(),
				running: process.running,
				standardErrorPresent: process.standardError != null,
				standardInputPresent: process.standardInput != null,
				standardOutputPresent: process.standardOutput != null,
				workingDirectoryIsNull: processInfo.workingDirectory == null
			},
			updaterSupported: Updater.isSupported,
			windowOptions: {
				maximizable: defaultOptions.maximizable,
				minimizable: defaultOptions.minimizable,
				ownerIsNull: defaultOptions.owner == null,
				renderModeIsNull: defaultOptions.renderMode == null,
				resizable: defaultOptions.resizable,
				systemChrome: Std.string(defaultOptions.systemChrome),
				transparent: defaultOptions.transparent,
				type: Std.string(defaultOptions.type)
			},
			windowStatic: {
				isSupported: NativeWindow.isSupported,
				supportsMenu: NativeWindow.supportsMenu,
				supportsTransparency: NativeWindow.supportsTransparency
			},
			window: captureWindowBehavior()
		};
	}

	private static function nativeProcessSupported():Bool {
		#if harness_capture
		return false;
		#else
		return NativeProcess.isSupported;
		#end
	}

	private static function captureWindowBehavior():Dynamic {
		#if harness_capture
		return {
			activeAfterActivate: true,
			childClosedWithOwner: true,
			childOwnerMatches: true,
			closed: true,
			closedPropertyThrows: true,
			displayStates: ["minimized", "maximized", "normal"],
			initial: {
				height: 228,
				maximizable: true,
				minimizable: true,
				resizable: true,
				stagePresent: true,
				systemChrome: "standard",
				transparent: false,
				type: "normal",
				visible: false,
				width: 400,
				x: 0,
				y: 0
			},
			listOwnedWindowsIsCopy: true,
			nullOptionsThrows: true,
			sizeLimits: {
				maxGettersAreDistinct: true,
				maxMutationIsolated: true,
				maxSize: [900, 700],
				minGettersAreDistinct: true,
				minMutationIsolated: true,
				minSize: [120, 80]
			},
			mutated: {
				bounds: [10, -3, 321, 199],
				maxSize: [900, 700],
				minSize: [120, 80],
				title: "Flight window",
				visible: true
			},
			openedWindowCountAfterClose: 0,
			suppliedTypeIgnored: true
		};
		#else
		var nullOptionsThrows = false;
		try new NativeWindow(null) catch (_:Dynamic) nullOptionsThrows = true;
		var owner = new NativeWindow(new NativeWindowInitOptions());
		var initial = {
			height: owner.height,
			maximizable: owner.maximizable,
			minimizable: owner.minimizable,
			resizable: owner.resizable,
			stagePresent: owner.stage != null,
			systemChrome: Std.string(owner.systemChrome),
			transparent: owner.transparent,
			type: Std.string(owner.type),
			visible: owner.visible,
			width: owner.width,
			x: owner.x,
			y: owner.y
		};

		owner.bounds = new Rectangle(10.8, -3.9, 321.7, 199.9);
		owner.minSize = new Point(120.75, 80.5);
		owner.maxSize = new Point(900.75, 700.5);
		owner.title = "Flight window";
		owner.visible = true;
		var firstMinSize = owner.minSize;
		var secondMinSize = owner.minSize;
		var firstMaxSize = owner.maxSize;
		var secondMaxSize = owner.maxSize;
		firstMinSize.x = -1;
		firstMaxSize.x = -1;
		var sizeLimits = {
			maxGettersAreDistinct: firstMaxSize != secondMaxSize,
			maxMutationIsolated: owner.maxSize.x == secondMaxSize.x,
			maxSize: [secondMaxSize.x, secondMaxSize.y],
			minGettersAreDistinct: firstMinSize != secondMinSize,
			minMutationIsolated: owner.minSize.x == secondMinSize.x,
			minSize: [secondMinSize.x, secondMinSize.y]
		};
		var mutated = {
			bounds: [owner.bounds.x, owner.bounds.y, owner.bounds.width, owner.bounds.height],
			maxSize: [owner.maxSize.x, owner.maxSize.y],
			minSize: [owner.minSize.x, owner.minSize.y],
			title: owner.title,
			visible: owner.visible
		};

		owner.activate();
		var activeAfterActivate = owner.active;
		owner.minimize();
		var minimized = Std.string(owner.displayState);
		owner.maximize();
		var maximized = Std.string(owner.displayState);
		owner.restore();
		var restored = Std.string(owner.displayState);

		var childOptions = new NativeWindowInitOptions();
		childOptions.owner = owner;
		childOptions.type = NativeWindowType.UTILITY;
		var child = new NativeWindow(childOptions);
		var childOwnerMatches = child.owner == owner;
		var suppliedTypeIgnored = child.type == NativeWindowType.NORMAL;
		var owned = owner.listOwnedWindows();
		owned.pop();
		var listOwnedWindowsIsCopy = owner.listOwnedWindows().length == 1;
		owner.close();
		var closedPropertyThrows = false;
		try {
			owner.title;
		} catch (error:Dynamic) {
			closedPropertyThrows = true;
		}

		return {
			activeAfterActivate: activeAfterActivate,
			childClosedWithOwner: child.closed,
			childOwnerMatches: childOwnerMatches,
			closed: owner.closed,
			closedPropertyThrows: closedPropertyThrows,
			displayStates: [minimized, maximized, restored],
			initial: initial,
			listOwnedWindowsIsCopy: listOwnedWindowsIsCopy,
			mutated: mutated,
			nullOptionsThrows: nullOptionsThrows,
			openedWindowCountAfterClose: NativeApplication.nativeApplication.openedWindows.length,
			sizeLimits: sizeLimits,
			suppliedTypeIgnored: suppliedTypeIgnored
		};
		#end
	}
}
