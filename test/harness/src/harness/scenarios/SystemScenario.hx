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
				language: Capabilities.language,
				localFileReadDisable: Capabilities.localFileReadDisable,
				manufacturer: Capabilities.manufacturer,
				maxLevelIDC: Capabilities.maxLevelIDC,
				os: Capabilities.os,
				pixelAspectRatio: Capabilities.pixelAspectRatio,
				playerType: Capabilities.playerType,
				screenColor: Capabilities.screenColor,
				screenDPI: Capabilities.screenDPI,
				version: Capabilities.version,
				screenResolutionX: Capabilities.screenResolutionX,
				screenResolutionY: Capabilities.screenResolutionY,
				serverString: Capabilities.serverString,
				supports32BitProcesses: Capabilities.supports32BitProcesses,
				supports64BitProcesses: Capabilities.supports64BitProcesses,
				touchscreenType: Std.string(Capabilities.touchscreenType),
				hasMultiChannelAudio: Capabilities.hasMultiChannelAudio("DolbyDigital")
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
				totalMemoryNonNegative: totalMemory >= 0,
				totalMemoryNumberIsFloat: Type.typeof(totalMemoryNumber) == TFloat,
				totalMemoryNumberNonNegative: totalMemoryNumber >= 0,
				useCodePageDefault: originalUseCodePage,
				useCodePageMutable: changedUseCodePage == !originalUseCodePage
			}
		};
	}
}
