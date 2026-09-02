package harness.scenarios;

import openfl.events.Event;
import openfl.events.HTTPStatusEvent;
import openfl.events.IOErrorEvent;
import openfl.events.ProgressEvent;
import openfl.events.SecurityErrorEvent;
import openfl.net.URLLoader;
import openfl.net.URLLoaderDataFormat;
import openfl.net.URLRequest;
import openfl.net.URLRequestHeader;
import openfl.net.URLRequestMethod;

class URLLoaderScenario {
	public static function run():Dynamic {
		return {
			requestDefaults: testRequestDefaults(),
			requestMutation: testRequestMutation(),
			header: testHeader(),
			loaderDefaults: testLoaderDefaults(),
			loadStart: testLoadStart(),
			errorEvents: testErrorEvents(),
			invalidLoads: testInvalidLoads(),
			closeAndReload: testCloseAndReload(),
			constructorLoad: testConstructorLoad()
		};
	}

	private static function testErrorEvents():Dynamic {
		var loader = new URLLoader();
		var events:Array<String> = [];
		loader.addEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):Void events.push('${event.type}:${event.text}'));
		loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(event:SecurityErrorEvent):Void events.push('${event.type}:${event.text}'));
		loader.dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false, "io failure"));
		loader.dispatchEvent(new SecurityErrorEvent(SecurityErrorEvent.SECURITY_ERROR, false, false, "security failure"));

		return {
			bytesLoaded: loader.bytesLoaded,
			bytesTotal: loader.bytesTotal,
			data: loader.data,
			events: events
		};
	}

	private static function testRequestDefaults():Dynamic {
		var request = new URLRequest();
		return {
			contentType: request.contentType,
			data: request.data,
			followRedirects: request.followRedirects,
			idleTimeout: request.idleTimeout,
			manageCookies: request.manageCookies,
			withCredentials: request.withCredentials,
			method: request.method,
			headerCount: request.requestHeaders.length,
			url: request.url,
			userAgent: request.userAgent
		};
	}

	private static function testRequestMutation():Dynamic {
		var request = new URLRequest("https://example.invalid/resource");
		request.contentType = "application/json";
		request.data = '{"flight":true}';
		request.followRedirects = false;
		request.idleTimeout = 1250;
		request.manageCookies = false;
		request.withCredentials = true;
		request.method = URLRequestMethod.POST;
		request.requestHeaders = [new URLRequestHeader("X-Flight", "adapter")];
		request.userAgent = "openfl-flight-test";

		return {
			contentType: request.contentType,
			data: request.data,
			followRedirects: request.followRedirects,
			idleTimeout: request.idleTimeout,
			manageCookies: request.manageCookies,
			withCredentials: request.withCredentials,
			method: request.method,
			headerName: request.requestHeaders[0].name,
			headerValue: request.requestHeaders[0].value,
			url: request.url,
			userAgent: request.userAgent
		};
	}

	private static function testHeader():Dynamic {
		var defaults = new URLRequestHeader();
		var values = new URLRequestHeader("Accept", "text/plain");
		return {
			defaultName: defaults.name,
			defaultValue: defaults.value,
			name: values.name,
			value: values.value
		};
	}

	private static function testLoaderDefaults():Dynamic {
		var loader = new URLLoader();
		return {
			bytesLoaded: loader.bytesLoaded,
			bytesTotal: loader.bytesTotal,
			data: loader.data,
			dataFormat: loader.dataFormat
		};
	}

	private static function testLoadStart():Dynamic {
		var loader = new URLLoader();
		var events:Array<String> = [];
		var types:Array<String> = [
			Event.OPEN,
			HTTPStatusEvent.HTTP_RESPONSE_STATUS,
			HTTPStatusEvent.HTTP_STATUS,
			ProgressEvent.PROGRESS,
			Event.COMPLETE,
			IOErrorEvent.IO_ERROR,
			SecurityErrorEvent.SECURITY_ERROR
		];
		for (type in types) {
			loader.addEventListener(type, function(event:Event):Void events.push(event.type));
		}

		loader.bytesLoaded = 7;
		loader.bytesTotal = 9;
		loader.data = "before";
		loader.dataFormat = URLLoaderDataFormat.TEXT;
		loader.load(new URLRequest("data:text/plain,flight"));

		return {
			events: events,
			bytesLoaded: loader.bytesLoaded,
			bytesTotal: loader.bytesTotal,
			data: loader.data,
			dataFormat: loader.dataFormat
		};
	}

	private static function testInvalidLoads():Dynamic {
		var nullLoader = new URLLoader();
		var nullOpenEvents = 0;
		nullLoader.addEventListener(Event.OPEN, function(_):Void nullOpenEvents++);
		var nullError:Dynamic = null;
		try {
			nullLoader.load(null);
		} catch (error:Dynamic) {
			nullError = error;
		}

		var urlLoader = new URLLoader();
		var urlOpenEvents = 0;
		urlLoader.addEventListener(Event.OPEN, function(_):Void urlOpenEvents++);
		var urlError:Dynamic = null;
		try {
			urlLoader.load(new URLRequest());
		} catch (error:Dynamic) {
			urlError = error;
		}

		return {
			nullRequest: {
				threw: nullError != null,
				errorClass: errorClass(nullError),
				openEvents: nullOpenEvents
			},
			nullUrl: {
				threw: urlError != null,
				errorClass: errorClass(urlError),
				openEvents: urlOpenEvents
			}
		};
	}

	private static function testCloseAndReload():Dynamic {
		var loader = new URLLoader();
		var events:Array<String> = [];
		var types:Array<String> = [Event.OPEN, Event.COMPLETE, IOErrorEvent.IO_ERROR, SecurityErrorEvent.SECURITY_ERROR];
		for (type in types) {
			loader.addEventListener(type, function(event:Event):Void events.push(event.type));
		}

		loader.close();
		loader.dataFormat = URLLoaderDataFormat.BINARY;
		loader.load(new URLRequest("data:application/octet-stream;base64,AAEC"));
		loader.close();
		loader.close();
		loader.dataFormat = URLLoaderDataFormat.VARIABLES;
		loader.load(new URLRequest("data:text/plain,first=one%26second=two"));
		loader.close();

		return {
			events: events,
			bytesLoaded: loader.bytesLoaded,
			bytesTotal: loader.bytesTotal,
			data: loader.data,
			dataFormat: Std.string(loader.dataFormat)
		};
	}

	private static function testConstructorLoad():Dynamic {
		var loader = new URLLoader(new URLRequest("data:text/plain,constructor"));
		loader.close();
		return {
			bytesLoaded: loader.bytesLoaded,
			bytesTotal: loader.bytesTotal,
			data: loader.data,
			dataFormat: Std.string(loader.dataFormat)
		};
	}

	private static function errorClass(error:Dynamic):String {
		if (error == null) return null;
		var type = Type.getClass(error);
		return type == null ? Std.string(Type.typeof(error)) : Type.getClassName(type);
	}
}
