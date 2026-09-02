package harness.scenarios;

import openfl.net.URLRequest;
import openfl.net.URLRequestHeader;
import openfl.net.URLRequestMethod;
import openfl.net.URLVariables;

class URLRequestScenario {
	public static function run():Dynamic {
		return {
			defaults: testDefaults(),
			properties: testProperties(),
			variables: testVariables()
		};
	}

	private static function testDefaults():Dynamic {
		var request = new URLRequest();
		return {
			url: request.url,
			method: request.method,
			contentType: request.contentType,
			requestHeaderCount: request.requestHeaders.length,
			dataIsNull: request.data == null,
			followRedirects: request.followRedirects,
			idleTimeout: request.idleTimeout,
			manageCookies: request.manageCookies,
			userAgent: request.userAgent
		};
	}

	private static function testProperties():Dynamic {
		var request = new URLRequest("https://example.invalid/first");
		request.url = "https://example.invalid/second";
		request.method = URLRequestMethod.POST;
		request.contentType = "application/x-www-form-urlencoded";
		request.requestHeaders.push(new URLRequestHeader("X-Flight", "one"));
		request.requestHeaders.push(new URLRequestHeader("X-Mode", "two"));
		var variables = new URLVariables("name=flight&count=2");
		request.data = variables;
		request.followRedirects = false;
		request.idleTimeout = 1234;
		request.manageCookies = false;
		request.userAgent = "flight-test-agent";

		var storedVariables:URLVariables = cast request.data;
		return {
			url: request.url,
			method: request.method,
			contentType: request.contentType,
			requestHeaderCount: request.requestHeaders.length,
			firstHeader: headerState(request.requestHeaders[0]),
			secondHeader: headerState(request.requestHeaders[1]),
			dataIdentityPreserved: request.data == variables,
			dataName: Reflect.field(cast storedVariables, "name"),
			dataCount: Reflect.field(cast storedVariables, "count"),
			followRedirects: request.followRedirects,
			idleTimeout: request.idleTimeout,
			manageCookies: request.manageCookies,
			userAgent: request.userAgent
		};
	}

	private static function testVariables():Dynamic {
		var variables = new URLVariables("space=hello%20world&plus=hello+again&ampersand=a%26b&equals=a%3Db");
		return {
			space: Reflect.field(cast variables, "space"),
			plus: Reflect.field(cast variables, "plus"),
			ampersand: Reflect.field(cast variables, "ampersand"),
			equals: Reflect.field(cast variables, "equals"),
			toString: canonical(variables.toString()),
			roundTrip: canonical(new URLVariables(variables.toString()).toString())
		};
	}

	private static function headerState(header:URLRequestHeader):Dynamic {
		return {name: header.name, value: header.value};
	}

	private static function canonical(value:String):String {
		var parts = value.split("&");
		parts.sort(function(a:String, b:String):Int return a < b ? -1 : (a > b ? 1 : 0));
		return parts.join("&");
	}
}
