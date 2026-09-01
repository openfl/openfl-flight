package openfl.net;

#if !flash
import flight.Net as FlightNet;
import flight.Signals as FlightSignals;
import flight.types.NetProgress;
import flight.types.NetRequest;
import flight.types.NetResponse;
import flight.types.Signal;
import haxe.io.Bytes;
import openfl.errors.TypeError;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.HTTPStatusEvent;
import openfl.events.IOErrorEvent;
import openfl.events.ProgressEvent;
import openfl.events.SecurityErrorEvent;
import openfl.utils.ByteArray;

/**
	The URLLoader class downloads data from a URL as text, binary data, or
	URL-encoded variables. It is useful for downloading text files, XML, or
	other information to be used in a dynamic, data-driven application.

	A URLLoader object downloads all of the data from a URL before making it
	available to code in the applications. It sends out notifications about the
	progress of the download, which you can monitor through the
	`bytesLoaded` and `bytesTotal` properties, as well as
	through dispatched events.

	When loading very large video files, such as FLV's, out-of-memory errors
	may occur.

	When you use this class in Flash Player and in AIR application content
	in security sandboxes other than then application security sandbox,
	consider the following security model:


	* A SWF file in the local-with-filesystem sandbox may not load data
	from, or provide data to, a resource that is in the network sandbox.
	*  By default, the calling SWF file and the URL you load must be in
	exactly the same domain. For example, a SWF file at www.adobe.com can load
	data only from sources that are also at www.adobe.com. To load data from a
	different domain, place a URL policy file on the server hosting the
	data.


	For more information related to security, see the Flash Player Developer
	Center Topic: [Security](http://www.adobe.com/go/devnet_security_en).

	@event complete           Dispatched after all the received data is decoded
							  and placed in the data property of the URLLoader
							  object. The received data may be accessed once
							  this event has been dispatched.
	@event httpResponseStatus Dispatched if a call to the load() method
							  attempts to access data over HTTP, and Adobe AIR
							  is able to detect and return the status code for
							  the request.
	@event httpStatus         Dispatched if a call to URLLoader.load() attempts
							  to access data over HTTP. For content running in
							  Flash Player, this event is only dispatched if
							  the current Flash Player environment is able to
							  detect and return the status code for the
							  request.(Some browser environments may not be
							  able to provide this information.) Note that the
							  `httpStatus` event (if any) is sent
							  before (and in addition to) any
							  `complete` or `error`
							  event.
	@event ioError            Dispatched if a call to URLLoader.load() results
							  in a fatal error that terminates the download.
	@event open               Dispatched when the download operation commences
							  following a call to the
							  `URLLoader.load()` method.
	@event progress           Dispatched when data is received as the download
							  operation progresses.

							  Note that with a URLLoader object, it is not
							  possible to access the data until it has been
							  received completely. So, the progress event only
							  serves as a notification of how far the download
							  has progressed. To access the data before it's
							  entirely downloaded, use a URLStream object.
	@event securityError      Dispatched if a call to URLLoader.load() attempts
							  to load data from a server outside the security
							  sandbox. Also dispatched if a call to
							  `URLLoader.load()` attempts to load a
							  SWZ file and the certificate is invalid or the
							  digest string does not match the component.

	@see [Loading external data](https://books.openfl.org/openfl-developers-guide/http-communications/loading-external-data.html)
	@see [Web service requests](https://books.openfl.org/openfl-developers-guide/http-communications/web-service-requests.html)
	@see `openfl.net.URLRequest`
	@see `openfl.net.URLStream`
**/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
class URLLoader extends EventDispatcher
{
	/**
		Indicates the number of bytes that have been loaded thus far during the
		load operation.
	**/
	public var bytesLoaded:Int;

	/**
		Indicates the total number of bytes in the downloaded data. This property
		contains 0 while the load operation is in progress and is populated when
		the operation is complete. Also, a missing Content-Length header will
		result in bytesTotal being indeterminate.
	**/
	public var bytesTotal:Int;

	/**
		The data received from the load operation. This property is populated only
		when the load operation is complete. The format of the data depends on the
		setting of the `dataFormat` property:

		If the `dataFormat` property is
		`URLLoaderDataFormat.TEXT`, the received data is a string
		containing the text of the loaded file.

		If the `dataFormat` property is
		`URLLoaderDataFormat.BINARY`, the received data is a ByteArray
		object containing the raw binary data.

		If the `dataFormat` property is
		`URLLoaderDataFormat.VARIABLES`, the received data is a
		URLVariables object containing the URL-encoded variables.
	**/
	public var data:Dynamic;

	/**
		Controls whether the downloaded data is received as text
		(`URLLoaderDataFormat.TEXT`), raw binary data
		(`URLLoaderDataFormat.BINARY`), or URL-encoded variables
		(`URLLoaderDataFormat.VARIABLES`).

		If the value of the `dataFormat` property is
		`URLLoaderDataFormat.TEXT`, the received data is a string
		containing the text of the loaded file.

		If the value of the `dataFormat` property is
		`URLLoaderDataFormat.BINARY`, the received data is a ByteArray
		object containing the raw binary data.

		If the value of the `dataFormat` property is
		`URLLoaderDataFormat.VARIABLES`, the received data is a
		URLVariables object containing the URL-encoded variables.

		@default URLLoaderDataFormat.TEXT
	**/
	public var dataFormat:URLLoaderDataFormat;

	@:noCompletion private var __loadGeneration:Int = 0;
	@:noCompletion private var __loading:Bool = false;

	/**
		Creates a URLLoader object.

		@param request A URLRequest object specifying the URL to download. If this
					   parameter is omitted, no load operation begins. If
					   specified, the load operation begins immediately (see the
					   `load` entry for more information).
	**/
	public function new(request:URLRequest = null)
	{
		super();

		bytesLoaded = 0;
		bytesTotal = 0;
		dataFormat = URLLoaderDataFormat.TEXT;

		if (request != null)
		{
			load(request);
		}
	}

	/**
		Closes the load operation in progress. Any load operation in progress is
		immediately terminated. If no URL is currently being streamed, an invalid
		stream error is thrown.

	**/
	public function close():Void
	{
		if (!__loading) return;
		__loadGeneration++;
		__loading = false;
	}

	/**
		Sends and loads data from the specified URL. The data can be received as
		text, raw binary data, or URL-encoded variables, depending on the value
		you set for the `dataFormat` property. Note that the default
		value of the `dataFormat` property is text. If you want to send
		data to the specified URL, you can set the `data` property in
		the URLRequest object.

		**Note:** If a file being loaded contains non-ASCII characters (as
		found in many non-English languages), it is recommended that you save the
		file with UTF-8 or UTF-16 encoding as opposed to a non-Unicode format like
		ASCII.

		 A SWF file in the local-with-filesystem sandbox may not load data
		from, or provide data to, a resource that is in the network sandbox.

		 By default, the calling SWF file and the URL you load must be in
		exactly the same domain. For example, a SWF file at www.adobe.com can load
		data only from sources that are also at www.adobe.com. To load data from a
		different domain, place a URL policy file on the server hosting the
		data.

		You cannot connect to commonly reserved ports. For a complete list of
		blocked ports, see "Restricting Networking APIs" in the _OpenFL
		Developer's Guide_.

		 In Flash Player 10 and later, if you use a multipart Content-Type (for
		example "multipart/form-data") that contains an upload (indicated by a
		"filename" parameter in a "content-disposition" header within the POST
		body), the POST operation is subject to the security rules applied to
		uploads:

		* The POST operation must be performed in response to a user-initiated
		action, such as a mouse click or key press.
		* If the POST operation is cross-domain (the POST target is not on the
		same server as the SWF file that is sending the POST request), the target
		server must provide a URL policy file that permits cross-domain
		access.

		Also, for any multipart Content-Type, the syntax must be valid
		(according to the RFC2046 standards). If the syntax appears to be invalid,
		the POST operation is subject to the security rules applied to
		uploads.

		For more information related to security, see the Flash Player
		Developer Center Topic: [Security](http://www.adobe.com/go/devnet_security_en).

		@param request A URLRequest object specifying the URL to download.
		@throws ArgumentError `URLRequest.requestHeader` objects may
							  not contain certain prohibited HTTP request headers.
							  For more information, see the URLRequestHeader class
							  description.
		@throws MemoryError   This error can occur for the following reasons: 1)
							  Flash Player or AIR cannot convert the
							  `URLRequest.data` parameter from UTF8 to
							  MBCS. This error is applicable if the URLRequest
							  object passed to `load()` is set to
							  perform a `GET` operation and if
							  `System.useCodePage` is set to
							  `true`. 2) Flash Player or AIR cannot
							  allocate memory for the `POST` data. This
							  error is applicable if the URLRequest object passed
							  to `load` is set to perform a
							  `POST` operation.
		@throws SecurityError Local untrusted files may not communicate with the
							  Internet. This may be worked around by reclassifying
							  this file as local-with-networking or trusted.
		@throws SecurityError You are trying to connect to a commonly reserved
							  port. For a complete list of blocked ports, see
							  "Restricting Networking APIs" in the _OpenFL
							  Developer's Guide_.
		@throws TypeError     The value of the request parameter or the
							  `URLRequest.url` property of the
							  URLRequest object passed are `null`.
		@event complete           Dispatched after data has loaded successfully.
		@event httpResponseStatus Dispatched if a call to the `load()`
								  method attempts to access data over HTTP and
								  Adobe AIR is able to detect and return the
								  status code for the request.
		@event httpStatus         If access is over HTTP, and the current Flash
								  Player environment supports obtaining status
								  codes, you may receive these events in addition
								  to any `complete` or
								  `error` event.
		@event ioError            The load operation could not be completed.
		@event open               Dispatched when a load operation commences.
		@event progress           Dispatched when data is received as the download
								  operation progresses.
		@event securityError      A load operation attempted to retrieve data from
								  a server outside the caller's security sandbox.
								  This may be worked around using a policy file on
								  the server.
		@event securityError      A load operation attempted to load a SWZ file (a
								  Adobe platform component), but the certificate
								  is invalid or the digest does not match the
								  component.

		@see [Loading external data](https://books.openfl.org/openfl-developers-guide/http-communications/loading-external-data.html)
	**/
	public function load(request:URLRequest):Void
	{
		if (request == null || request.url == null) throw new TypeError("URLRequest and URLRequest.url must be non-null");

		var generation = ++__loadGeneration;
		__loading = true;
		dispatchEvent(new Event(Event.OPEN));

		var progress:Signal<NetProgress->Void> = FlightSignals.createSignal();
		FlightSignals.connectSignal(progress, function(value:NetProgress):Void
		{
			if (!__loading || generation != __loadGeneration || value.phase != "download") return;
			bytesLoaded = Std.int(value.loaded);
			bytesTotal = Std.int(value.total);
			dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, value.loaded, value.total));
		});

		var promise = FlightNet.sendNetRequest(__toFlightRequest(request), {progress: progress});
		promise.then(function(response:NetResponse):NetResponse
		{
			__defer(function():Void __complete(generation, request, response));
			return response;
		}, function(error:Dynamic):NetResponse
		{
			__defer(function():Void __fail(generation, Std.string(error)));
			return cast null;
		});
	}

	@:noCompletion private function __complete(generation:Int, request:URLRequest, response:NetResponse):Void
	{
		if (!__loading || generation != __loadGeneration) return;
		__loading = false;
		__dispatchStatus(response, request.url);

		data = __decodeResponse(response.body);
		if (!response.ok)
		{
			if (Std.int(response.status) == 403)
			{
				dispatchEvent(new SecurityErrorEvent(SecurityErrorEvent.SECURITY_ERROR, false, false, response.statusText));
			}
			else
			{
				dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR, true, false, response.statusText));
			}
			return;
		}

		var length = __dataLength(data);
		if (bytesTotal <= 0) bytesTotal = length;
		if (bytesLoaded <= 0) bytesLoaded = length;
		dispatchEvent(new Event(Event.COMPLETE));
	}

	@:noCompletion private function __decodeResponse(body:Dynamic):Dynamic
	{
		return switch (dataFormat)
		{
			case URLLoaderDataFormat.BINARY:
				if (body == null)
				{
					new ByteArray();
				}
				else if (Std.isOfType(body, Bytes))
				{
					ByteArray.fromBytes(cast body);
				}
				#if js
				else if (Std.isOfType(body, js.lib.ArrayBuffer))
				{
					ByteArray.fromBytes(Bytes.ofData(cast body));
				}
				#end
				else
				{
					ByteArray.fromBytes(Bytes.ofString(Std.string(body)));
				}

			case URLLoaderDataFormat.VARIABLES:
				var variables:URLVariables = cast {};
				variables.decode(body == null ? "" : Std.string(body));
				variables;

			default:
				body == null ? null : Std.string(body);
		}
	}

	@:noCompletion private function __dispatchStatus(response:NetResponse, requestURL:String):Void
	{
		var status = Std.int(response.status);
		var redirected = response.url != null && response.url != requestURL;
		var responseEvent = new HTTPStatusEvent(HTTPStatusEvent.HTTP_RESPONSE_STATUS, false, false, status, redirected);
		responseEvent.responseURL = response.url;
		responseEvent.responseHeaders = [];
		if (response.headers != null)
		{
			for (name in Reflect.fields(response.headers))
			{
				responseEvent.responseHeaders.push(new URLRequestHeader(name, Std.string(Reflect.field(response.headers, name))));
			}
		}
		dispatchEvent(responseEvent);
		dispatchEvent(new HTTPStatusEvent(HTTPStatusEvent.HTTP_STATUS, false, false, status, redirected));
	}

	@:noCompletion private function __fail(generation:Int, message:String):Void
	{
		if (!__loading || generation != __loadGeneration) return;
		__loading = false;
		dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR, true, false, message));
	}

	@:noCompletion private static function __dataLength(value:Dynamic):Int
	{
		if (value == null) return 0;
		if (Std.isOfType(value, Bytes)) return (cast value : Bytes).length;
		return Bytes.ofString(Std.string(value)).length;
	}

	@:noCompletion private static function __defer(callback:Void->Void):Void
	{
		#if (clay || lime || js)
		callback();
		#else
		haxe.Timer.delay(callback, 0);
		#end
	}

	@:noCompletion private static function __encodeData(value:Dynamic):String
	{
		if (value == null) return "";
		if (Std.isOfType(value, String)) return cast value;
		if (Std.isOfType(value, Bytes)) return Std.string(value);

		var values = [];
		for (name in Reflect.fields(value))
		{
			values.push(StringTools.urlEncode(name) + "=" + StringTools.urlEncode(Std.string(Reflect.field(value, name))));
		}
		return values.length == 0 ? Std.string(value) : values.join("&");
	}

	@:noCompletion private function __toFlightRequest(request:URLRequest):NetRequest
	{
		var method = request.method == null ? URLRequestMethod.GET : request.method;
		var url = request.url;
		var body:Dynamic = null;
		if (request.data != null)
		{
			if (method == URLRequestMethod.GET)
			{
				var query = __encodeData(request.data);
				if (query != "") url += (url.indexOf("?") == -1 ? "?" : "&") + query;
			}
			else if (Std.isOfType(request.data, Bytes))
			{
				body = cast request.data;
			}
			else
			{
				body = __encodeData(request.data);
			}
		}

		var headers:Dynamic = {};
		if (request.requestHeaders != null)
		{
			for (header in request.requestHeaders)
			{
				if (header != null && header.name != null) Reflect.setField(headers, header.name, header.value);
			}
		}
		if (request.contentType != null) Reflect.setField(headers, "Content-Type", request.contentType);
		if (request.userAgent != null) Reflect.setField(headers, "User-Agent", request.userAgent);

		return cast {
			url: url,
			method: method,
			headers: headers,
			body: body,
			responseType: dataFormat == URLLoaderDataFormat.BINARY ? "arraybuffer" : "text",
			timeoutMs: request.idleTimeout,
			credentials: request.manageCookies || request.withCredentials ? "include" : "omit",
			redirect: request.followRedirects ? "follow" : "manual"
		};
	}
}
#else
typedef URLLoader = flash.net.URLLoader;
#end
