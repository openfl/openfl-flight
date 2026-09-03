package harness.scenarios;

import openfl.display.MovieClip;
import openfl.system.ApplicationDomain;
import openfl.system.Capabilities;
import openfl.system.ImageDecodingPolicy;
import openfl.system.LoaderContext;
import openfl.system.Security;
import openfl.system.SecurityDomain;
import openfl.system.System;
import openfl.system.TouchscreenType;

class SystemScenario {
	public static function run():Dynamic {
		var internalLib = Type.resolveClass("openfl.utils._internal.Lib");
		if (internalLib != null && Reflect.field(internalLib, "current") == null) {
			Reflect.setField(internalLib, "current", new MovieClip());
		}

		var currentApplicationDomain = ApplicationDomain.currentDomain;
		var childApplicationDomain = new ApplicationDomain(currentApplicationDomain);
		var defaultLoaderContext = new LoaderContext();
		var securityDomain = SecurityDomain.currentDomain;
		var customLoaderContext = new LoaderContext(true, childApplicationDomain, securityDomain);
		var unknownImageDecodingPolicy:ImageDecodingPolicy = "unknown";
		var securityStubsDoNotThrow = true;
		try {
			Security.allowDomain("one", "two", null, 4, true);
			Security.allowInsecureDomain("one", "two", null, 4, true);
			Security.loadPolicyFile("https://example.invalid/crossdomain.xml");
		} catch (_:Dynamic) {
			securityStubsDoNotThrow = false;
		}
		var totalMemory = System.totalMemory;
		var totalMemoryNumber = System.totalMemoryNumber;
		var language = Capabilities.language;
		var os = Capabilities.os;
		var manufacturer = Capabilities.manufacturer;
		var playerType = Capabilities.playerType;
		var version = Capabilities.version;
		var screenResolutionX = Capabilities.screenResolutionX;
		var screenResolutionY = Capabilities.screenResolutionY;
		var screenDPI = Capabilities.screenDPI;
		var pixelAspectRatio = Capabilities.pixelAspectRatio;
		var screenColor = Capabilities.screenColor;
		var serverString = Capabilities.serverString;
		var gcDoesNotThrow = true;
		try {
			System.gc();
		} catch (_:Dynamic) {
			gcDoesNotThrow = false;
		}
		var originalUseCodePage = System.useCodePage;
		System.useCodePage = !originalUseCodePage;
		var changedUseCodePage = System.useCodePage;
		System.useCodePage = originalUseCodePage;

		return {
			applicationDomain: {
				disabledMembersAbsent: !Reflect.hasField(childApplicationDomain, "domainMemory")
					&& !Reflect.hasField(childApplicationDomain, "getQualifiedDefinitionNames")
					&& !Reflect.hasField(ApplicationDomain, "MIN_DOMAIN_MEMORY_LENGTH"),
				currentParentIsNull: currentApplicationDomain.parentDomain == null,
				childParentIsCurrent: childApplicationDomain.parentDomain == currentApplicationDomain,
				hasKnownDefinition: childApplicationDomain.hasDefinition("openfl.system.System"),
				hasMissingDefinition: childApplicationDomain.hasDefinition("missing.SystemType"),
				knownDefinitionMatches: childApplicationDomain.getDefinition("openfl.system.System") == System,
				missingDefinitionIsNull: childApplicationDomain.getDefinition("missing.SystemType") == null
			},
			capabilities: {
				avHardwareDisable: Capabilities.avHardwareDisable,
				cpuArchitecture: Capabilities.cpuArchitecture,
				hasAccessibility: Capabilities.hasAccessibility,
				hasAudio: Capabilities.hasAudio,
				hasAudioEncoder: Capabilities.hasAudioEncoder,
				hasEmbeddedVideo: Capabilities.hasEmbeddedVideo,
				hasIME: Capabilities.hasIME,
				hasMP3: Capabilities.hasMP3,
				hasPrinting: Capabilities.hasPrinting,
				hasScreenBroadcast: Capabilities.hasScreenBroadcast,
				hasScreenPlayback: Capabilities.hasScreenPlayback,
				hasStreamingAudio: Capabilities.hasStreamingAudio,
				hasStreamingVideo: Capabilities.hasStreamingVideo,
				hasTLS: Capabilities.hasTLS,
				hasVideoEncoder: Capabilities.hasVideoEncoder,
				isDebugger: Capabilities.isDebugger,
				isEmbeddedInAcrobat: Capabilities.isEmbeddedInAcrobat,
				language: language,
				localFileReadDisable: Capabilities.localFileReadDisable,
				manufacturer: manufacturer,
				maxLevelIDC: Capabilities.maxLevelIDC,
				os: os,
				pixelAspectRatio: pixelAspectRatio,
				playerType: playerType,
				screenColor: screenColor,
				screenDPI: screenDPI,
				version: version,
				screenResolutionX: screenResolutionX,
				screenResolutionY: screenResolutionY,
				serverString: serverString,
				supports32BitProcesses: Capabilities.supports32BitProcesses,
				supports64BitProcesses: Capabilities.supports64BitProcesses,
				touchscreenType: Std.string(Capabilities.touchscreenType),
				hasMultiChannelAudio: Capabilities.hasMultiChannelAudio("DolbyDigital")
			},
			capabilityValidation: {
				languageNonEmpty: language != null && language != "",
				languageMatchesFormat: ~/^(?:[a-z]{2}|zh-(?:CN|TW)|xu)$/.match(language),
				osNonNull: os != null,
				osMatchesFormat: os != null && (os == "" || ~/^(?:Windows|Mac OS|Linux|Android|iPhone OS)(?: |$)/.match(os)),
				manufacturerNonEmpty: manufacturer != null && manufacturer != "",
				playerTypeIsKnown: ["Desktop", "PlugIn", "StandAlone"].indexOf(playerType) != -1,
				versionNonEmpty: version != null && version != "",
				versionMatchesFormat: ~/^[A-Za-z]+ [0-9]+,[0-9]+,[0-9]+,[0-9]+$/.match(version),
				screenResolutionXPositive: screenResolutionX > 0,
				screenResolutionYPositive: screenResolutionY > 0,
				screenDPIPositive: screenDPI > 0,
				pixelAspectRatioPositive: pixelAspectRatio > 0,
				screenColorIsKnown: ["color", "gray", "bw"].indexOf(screenColor) != -1,
				serverStringNonEmpty: serverString != null && serverString != "",
				serverStringHasResolution: serverString.indexOf("R=") != -1,
				avHardwareDisableIsBool: Type.typeof(Capabilities.avHardwareDisable) == TBool,
				localFileReadDisableIsBool: Type.typeof(Capabilities.localFileReadDisable) == TBool,
				hasAudio: Capabilities.hasAudio,
				hasAudioIsBool: Type.typeof(Capabilities.hasAudio) == TBool,
				hasMP3: Capabilities.hasMP3,
				hasMP3IsBool: Type.typeof(Capabilities.hasMP3) == TBool,
				hasVideoEncoder: Capabilities.hasVideoEncoder,
				hasVideoEncoderIsBool: Type.typeof(Capabilities.hasVideoEncoder) == TBool,
				hasScreenPlayback: Capabilities.hasScreenPlayback
			},
			constants: {
				imageDecodingPolicy: [Std.string(ImageDecodingPolicy.ON_DEMAND), Std.string(ImageDecodingPolicy.ON_LOAD)],
				unknownImageDecodingPolicyIsNull: unknownImageDecodingPolicy == null,
				touchscreenType: [Std.string(TouchscreenType.FINGER), Std.string(TouchscreenType.NONE), Std.string(TouchscreenType.STYLUS)],
				security: [Security.LOCAL_TRUSTED, Security.LOCAL_WITH_FILE, Security.LOCAL_WITH_NETWORK, Security.REMOTE]
			},
			loaderContext: {
				disabledMembersAbsent: !Reflect.hasField(defaultLoaderContext, "imageDecodingPolicy")
					&& !Reflect.hasField(defaultLoaderContext, "requestedContentParent")
					&& !Reflect.hasField(defaultLoaderContext, "uncaughtErrorEvents"),
				defaults: {
					allowCodeImport: defaultLoaderContext.allowCodeImport,
					allowLoadBytesCodeExecution: defaultLoaderContext.allowLoadBytesCodeExecution,
					applicationDomainIsNull: defaultLoaderContext.applicationDomain == null,
					checkPolicyFile: defaultLoaderContext.checkPolicyFile,
					securityDomainIsNull: defaultLoaderContext.securityDomain == null
				},
				custom: {
					allowCodeImport: customLoaderContext.allowCodeImport,
					allowLoadBytesCodeExecution: customLoaderContext.allowLoadBytesCodeExecution,
					applicationDomainMatches: customLoaderContext.applicationDomain == childApplicationDomain,
					checkPolicyFile: customLoaderContext.checkPolicyFile,
					securityDomainMatches: customLoaderContext.securityDomain == securityDomain
				}
			},
			security: {
				currentDomainStable: SecurityDomain.currentDomain == securityDomain,
				exactSettings: Security.exactSettings,
				sandboxTypeIsNull: Security.sandboxType == null,
				stubCallsDoNotThrow: securityStubsDoNotThrow
			},
			system: {
				totalMemoryIsInt: Type.typeof(totalMemory) == TInt,
				totalMemoryIsIntOrUInt: Type.typeof(totalMemory) == TInt,
				totalMemoryNonNegative: totalMemory >= 0,
				totalMemoryNumberIsFloat: Type.typeof(totalMemoryNumber) == TFloat,
				totalMemoryNumberNonNegative: totalMemoryNumber >= 0,
				useCodePageDefault: originalUseCodePage,
				useCodePageMutable: changedUseCodePage == !originalUseCodePage,
				gcDoesNotThrow: gcDoesNotThrow,
				processMethodsPresent: System.exit != null && System.pause != null && System.resume != null && System.setClipboard != null
			}
		};
	}
}
