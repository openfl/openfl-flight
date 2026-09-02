package harness.scenarios;

import openfl.net.URLLoaderDataFormat;
import openfl.net.URLRequest;
import openfl.net.URLRequestDefaults;
import openfl.net.URLRequestHeader;
import openfl.net.URLVariables;

class URLTypesScenario {
	public static function run():Dynamic {
		return {
			requestEdges: testRequestEdges(),
			headerEdges: testHeaderEdges(),
			variables: testVariables(),
			dataFormats: testDataFormats()
		};
	}

	private static function testRequestEdges():Dynamic {
		var previousFollowRedirects = URLRequestDefaults.followRedirects;
		var previousIdleTimeout = URLRequestDefaults.idleTimeout;
		var previousManageCookies = URLRequestDefaults.manageCookies;
		var previousUserAgent = URLRequestDefaults.userAgent;

		URLRequestDefaults.followRedirects = false;
		URLRequestDefaults.idleTimeout = 2345;
		URLRequestDefaults.manageCookies = false;
		URLRequestDefaults.userAgent = "flight-agent";
		var inherited = new URLRequest("");

		URLRequestDefaults.followRedirects = previousFollowRedirects;
		URLRequestDefaults.idleTimeout = previousIdleTimeout;
		URLRequestDefaults.manageCookies = previousManageCookies;
		URLRequestDefaults.userAgent = previousUserAgent;

		return {
			emptyUrl: inherited.url,
			followRedirects: inherited.followRedirects,
			idleTimeout: inherited.idleTimeout,
			manageCookies: inherited.manageCookies,
			userAgent: inherited.userAgent,
			defaultsRestored: URLRequestDefaults.followRedirects == previousFollowRedirects
				&& URLRequestDefaults.idleTimeout == previousIdleTimeout
				&& URLRequestDefaults.manageCookies == previousManageCookies
				&& URLRequestDefaults.userAgent == previousUserAgent
		};
	}

	private static function testHeaderEdges():Dynamic {
		var header = new URLRequestHeader(null, null);
		header.name = "X-Reassigned";
		header.value = "two";
		return {name: header.name, value: header.value};
	}

	private static function testVariables():Dynamic {
		var empty = new URLVariables();
		var nullSource = new URLVariables(null);
		var emptySource = new URLVariables("");
		var decoded = new URLVariables("greeting=hello%20world&plus=a+b&empty&=ignored&repeat=first&repeat=second&encoded%20key=a%2Fb");
		var initial = {
			fieldCount: Reflect.fields(cast decoded).length,
			greeting: Reflect.field(cast decoded, "greeting"),
			plus: Reflect.field(cast decoded, "plus"),
			empty: Reflect.field(cast decoded, "empty"),
			repeat: Reflect.field(cast decoded, "repeat"),
			encoded: Reflect.field(cast decoded, "encoded key"),
			canonical: canonical(decoded.toString())
		};

		decoded.decode("fresh=value&flag");
		var afterDecode = {
			fieldCount: Reflect.fields(cast decoded).length,
			fresh: Reflect.field(cast decoded, "fresh"),
			flag: Reflect.field(cast decoded, "flag"),
			oldFieldRemoved: !Reflect.hasField(cast decoded, "greeting")
		};

		var arrays = new URLVariables();
		Reflect.setField(cast arrays, "items[]", ["one two", "a/b"]);
		Reflect.setField(cast arrays, "sp ace", "x/y");

		var nullable = new URLVariables();
		Reflect.setField(cast nullable, "empty", "");
		Reflect.setField(cast nullable, "null", null);
		Reflect.setField(cast nullable, "unicode", "caf\u00e9 \u2603");

		var nullDecodeError:Dynamic = null;
		try {
			decoded.decode(null);
		} catch (error:Dynamic) {
			nullDecodeError = error;
		}

		return {
			emptyFieldCount: Reflect.fields(cast empty).length,
			emptyString: empty.toString(),
			nullSourceFieldCount: Reflect.fields(cast nullSource).length,
			emptySource: {
				fieldCount: Reflect.fields(cast emptySource).length,
				serialized: emptySource.toString()
			},
			initial: initial,
			afterDecode: afterDecode,
			arrayEncoding: canonical(arrays.toString()),
			nullableEncoding: canonical(nullable.toString()),
			nullDecode: {
				errorClass: errorClass(nullDecodeError),
				fieldCountAfterError: Reflect.fields(cast decoded).length,
				threw: nullDecodeError != null
			}
		};
	}

	private static function testDataFormats():Dynamic {
		var fromBinary:URLLoaderDataFormat = "binary";
		var fromText:URLLoaderDataFormat = "text";
		var fromVariables:URLLoaderDataFormat = "variables";
		var invalid:URLLoaderDataFormat = "invalid";
		return {
			binary: Std.string(URLLoaderDataFormat.BINARY),
			text: Std.string(URLLoaderDataFormat.TEXT),
			variables: Std.string(URLLoaderDataFormat.VARIABLES),
			fromBinary: fromBinary == URLLoaderDataFormat.BINARY,
			fromText: fromText == URLLoaderDataFormat.TEXT,
			fromVariables: fromVariables == URLLoaderDataFormat.VARIABLES,
			invalidIsNull: invalid == null,
			invalidString: Std.string(invalid)
		};
	}

	private static function canonical(value:String):String {
		var parts = value.split("&");
		parts.sort(function(a:String, b:String):Int return a < b ? -1 : (a > b ? 1 : 0));
		return parts.join("&");
	}

	private static function errorClass(error:Dynamic):String {
		if (error == null) return null;
		var type = Type.getClass(error);
		return type == null ? Std.string(Type.typeof(error)) : Type.getClassName(type);
	}
}
