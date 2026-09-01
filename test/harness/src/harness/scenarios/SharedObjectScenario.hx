package harness.scenarios;

import openfl.net.ObjectEncoding;
import openfl.net.SharedObject;
import openfl.net.SharedObjectFlushStatus;

class SharedObjectScenario
{
	public static function run():Dynamic
	{
		var invalidNames:Array<Null<String>> = [null, "", "bad name", "bad:name"];
		var rejected:Array<Bool> = [];
		for (name in invalidNames)
		{
			var didReject = false;
			try
			{
				SharedObject.getLocal(name, "/flight-harness");
			}
			catch (_:Dynamic)
			{
				didReject = true;
			}
			rejected.push(didReject);
		}

		var shared = SharedObject.getLocal("flight-harness-shared-object", "/flight-harness");
		shared.clear();
		var defaults = {
			clientSelf: shared.client == shared,
			dataFields: Reflect.fields(shared.data).length,
			defaultObjectEncoding: SharedObject.defaultObjectEncoding,
			objectEncoding: shared.objectEncoding,
			size: shared.size
		};
		var emptyFlush = shared.flush() == SharedObjectFlushStatus.FLUSHED;

		shared.setProperty("score", 42);
		shared.setProperty("label", "flight");
		shared.setDirty("score");
		var populated = {
			fieldCount: Reflect.fields(shared.data).length,
			flushSucceeded: shared.flush(1024) == SharedObjectFlushStatus.FLUSHED,
			label: Reflect.field(shared.data, "label"),
			score: Reflect.field(shared.data, "score"),
			sizePositive: shared.size > 0
		};

		shared.setProperty("label", null);
		var nullProperty = {
			exists: Reflect.hasField(shared.data, "label"),
			value: Reflect.field(shared.data, "label")
		};

		var identity = {
			differentPath: SharedObject.getLocal("flight-harness-shared-object", "/other-harness") != shared,
			sameReference: SharedObject.getLocal("flight-harness-shared-object", "/flight-harness") == shared
		};

		var previousEncoding = SharedObject.defaultObjectEncoding;
		SharedObject.defaultObjectEncoding = ObjectEncoding.HXSF;
		var encoded = SharedObject.getLocal("flight-harness-encoding", "/flight-harness");
		encoded.clear();
		var inheritedEncoding = encoded.objectEncoding;
		SharedObject.defaultObjectEncoding = previousEncoding;

		shared.clear();
		var cleared = {
			dataFields: Reflect.fields(shared.data).length,
			emptyFlush: shared.flush() == SharedObjectFlushStatus.FLUSHED,
			size: shared.size
		};
		encoded.clear();

		return {
			cleared: cleared,
			defaults: defaults,
			emptyFlush: emptyFlush,
			identity: identity,
			inheritedEncoding: inheritedEncoding,
			invalidNamesRejected: rejected,
			nullProperty: nullProperty,
			populated: populated
		};
	}
}
