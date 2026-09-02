package harness.scenarios;

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
		var currentApplicationDomain = ApplicationDomain.currentDomain;
		var childApplicationDomain = new ApplicationDomain(currentApplicationDomain);
		var defaultLoaderContext = new LoaderContext();
		var securityDomain = SecurityDomain.currentDomain;
		var customLoaderContext = new LoaderContext(true, childApplicationDomain, securityDomain);
		var totalMemory = System.totalMemory;
		var totalMemoryNumber = System.totalMemoryNumber;
		var language = Capabilities.language;
		var os = Capabilities.os;
		var playerType = Capabilities.playerType;
		var version = Capabilities.version;
		var screenResolutionX = Capabilities.screenResolutionX;
		var screenResolutionY = Capabilities.screenResolutionY;
		var screenDPI = Capabilities.screenDPI;
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
				manufacturer: Capabilities.manufacturer,
				maxLevelIDC: Capabilities.maxLevelIDC,
				os: os,
				pixelAspectRatio: Capabilities.pixelAspectRatio,
				playerType: playerType,
				screenColor: Capabilities.screenColor,
				screenDPI: screenDPI,
				version: version,
				screenResolutionX: screenResolutionX,
				screenResolutionY: screenResolutionY,
				serverString: Capabilities.serverString,
				supports32BitProcesses: Capabilities.supports32BitProcesses,
				supports64BitProcesses: Capabilities.supports64BitProcesses,
				touchscreenType: Std.string(Capabilities.touchscreenType),
				hasMultiChannelAudio: Capabilities.hasMultiChannelAudio("DolbyDigital")
			},
			capabilityValidation: {
				languageMatchesFormat: ~/^(?:[a-z]{2}|zh-(?:CN|TW)|xu)$/.match(language),
				osMatchesFormat: os == "" || ~/^(?:Windows|Mac OS|Linux|Android|iPhone OS)(?: |$)/.match(os),
				playerTypeIsKnown: ["Desktop", "PlugIn", "StandAlone"].indexOf(playerType) != -1,
				versionMatchesFormat: ~/^[A-Za-z]+ [0-9]+,[0-9]+,[0-9]+,[0-9]+$/.match(version),
				screenResolutionXPositive: screenResolutionX > 0,
				screenResolutionYPositive: screenResolutionY > 0,
				screenDPIPositive: screenDPI > 0,
				hasAudio: Capabilities.hasAudio,
				hasMP3: Capabilities.hasMP3,
				hasVideoEncoder: Capabilities.hasVideoEncoder,
				hasScreenPlayback: Capabilities.hasScreenPlayback
			},
			constants: {
				imageDecodingPolicy: [Std.string(ImageDecodingPolicy.ON_DEMAND), Std.string(ImageDecodingPolicy.ON_LOAD)],
				touchscreenType: [Std.string(TouchscreenType.FINGER), Std.string(TouchscreenType.NONE), Std.string(TouchscreenType.STYLUS)],
				security: [Security.LOCAL_TRUSTED, Security.LOCAL_WITH_FILE, Security.LOCAL_WITH_NETWORK, Security.REMOTE]
			},
			loaderContext: {
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
				sandboxTypeIsNull: Security.sandboxType == null
			},
			system: {
				totalMemoryIsInt: Type.typeof(totalMemory) == TInt,
				totalMemoryIsIntOrUInt: Type.typeof(totalMemory) == TInt,
				totalMemoryNonNegative: totalMemory >= 0,
				totalMemoryNumberIsFloat: Type.typeof(totalMemoryNumber) == TFloat,
				totalMemoryNumberNonNegative: totalMemoryNumber >= 0,
				useCodePageDefault: originalUseCodePage,
				useCodePageMutable: changedUseCodePage == !originalUseCodePage,
				gcDoesNotThrow: gcDoesNotThrow
			}
		};
	}
}
