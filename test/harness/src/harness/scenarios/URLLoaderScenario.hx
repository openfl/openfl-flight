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
			loadStart: testLoadStart()
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
}
