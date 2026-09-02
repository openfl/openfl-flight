package harness.scenarios;

import openfl.net.ObjectEncoding;
import openfl.net.SharedObject;
import openfl.net.SharedObjectFlushStatus;

class SharedObjectScenario
{
	public static function run():Dynamic
	{
		var invalidNames:Array<Null<String>> = [
			null,
			"",
			"bad name",
			"bad~name",
			"bad%name",
			"bad&name",
			"bad\\name",
			"bad;name",
			"bad:name",
			"bad\"name",
			"bad'name",
			"bad,name",
			"bad<name",
			"bad>name",
			"bad?name",
			"bad#name"
		];
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
			largeQuotaRequestFlushSucceeded: shared.flush(1000000) == SharedObjectFlushStatus.FLUSHED,
			label: Reflect.field(shared.data, "label"),
			score: Reflect.field(shared.data, "score"),
			size: shared.size,
			sizeGrew: shared.size > defaults.size
		};

		var persistenceName = "flight-harness-round-trip";
		var persistencePath = "/flight-harness";
		var persistent = SharedObject.getLocal(persistenceName, persistencePath);
		persistent.clear();
		Reflect.setField(persistent.data, "profile", {
			name: "Ada",
			stats: {score: 73},
			tags: ["flight", "openfl"]
		});
		var persistedSize = persistent.size;
		var persistedFlush = persistent.flush() == SharedObjectFlushStatus.FLUSHED;
		evict(persistenceName, persistencePath);
		var reloaded = SharedObject.getLocal(persistenceName, persistencePath);
		var profile:Dynamic = Reflect.field(reloaded.data, "profile");
		var stats:Dynamic = Reflect.field(profile, "stats");
		var tags:Array<Dynamic> = cast Reflect.field(profile, "tags");
		var persistenceRoundTrip = {
			flushSucceeded: persistedFlush,
			newReferenceAfterEviction: reloaded != persistent,
			fieldCount: Reflect.fields(reloaded.data).length,
			name: Reflect.field(profile, "name"),
			score: Reflect.field(stats, "score"),
			tags: tags.join(","),
			size: reloaded.size,
			sizePreserved: reloaded.size == persistedSize
		};
		reloaded.clear();
		evict(persistenceName, persistencePath);
		var afterClearReload = SharedObject.getLocal(persistenceName, persistencePath);
		var persistedClear = {
			fieldCount: Reflect.fields(afterClearReload.data).length,
			size: afterClearReload.size
		};
		afterClearReload.clear();

		shared.setProperty("label", null);
		var nullProperty = {
			exists: Reflect.hasField(shared.data, "label"),
			value: Reflect.field(shared.data, "label")
		};

		var identity = {
			differentPath: SharedObject.getLocal("flight-harness-shared-object", "/other-harness") != shared,
			sameReference: SharedObject.getLocal("flight-harness-shared-object", "/flight-harness") == shared
		};

		shared.client = null;
		shared.objectEncoding = ObjectEncoding.AMF0;
		shared.fps = 12;
		shared.close();
		#if !openfl_strict
		var connectDoesNotThrow = doesNotThrow(function() shared.connect(null));
		var sendDoesNotThrow = doesNotThrow(function() shared.send([]));
		var setDirtyDoesNotThrow = doesNotThrow(function() shared.setDirty("score"));
		var remote = SharedObject.getRemote("flight-harness-remote", "/flight-harness");
		var remoteIsNull = remote == null;
		#else
		var connectDoesNotThrow:Null<Bool> = null;
		var sendDoesNotThrow:Null<Bool> = null;
		var setDirtyDoesNotThrow:Null<Bool> = null;
		var remoteIsNull:Null<Bool> = null;
		#end
		var mutations = {
			clientAcceptsNull: shared.client == null,
			objectEncoding: shared.objectEncoding,
			remoteIsNull: remoteIsNull,
			connectDoesNotThrow: connectDoesNotThrow,
			sendDoesNotThrow: sendDoesNotThrow,
			setDirtyDoesNotThrow: setDirtyDoesNotThrow
		};
		shared.client = shared;
		shared.objectEncoding = ObjectEncoding.DEFAULT;

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
			mutations: mutations,
			nullProperty: nullProperty,
			populated: populated,
			persistenceRoundTrip: persistenceRoundTrip,
			persistedClear: persistedClear
		};
	}

	private static function evict(name:String, localPath:String):Void
	{
		@:privateAccess SharedObject.__sharedObjects.remove(localPath + "/" + name);
	}

	private static function doesNotThrow(operation:Void->Void):Bool
	{
		try
		{
			operation();
			return true;
		}
		catch (_:Dynamic)
		{
			return false;
		}
	}
}
