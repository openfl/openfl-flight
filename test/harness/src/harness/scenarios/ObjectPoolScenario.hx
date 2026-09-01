package harness.scenarios;

import openfl.utils.ObjectPool;

class ObjectPoolScenario {
	public static function run():Dynamic {
		var created = 0;
		var cleaned = 0;
		var pool = new ObjectPool<PooledValue>(function():PooledValue {
			created++;
			return new PooledValue(created);
		}, function(value:PooledValue):Void {
			cleaned++;
			value.cleanCount++;
		});

		var initial = counts(pool);
		var first = pool.get();
		var afterFirstGet = counts(pool);
		pool.release(first);
		var afterRelease = counts(pool);
		var second = pool.get();
		var reused = first == second;
		var reusedCleanCount = second.cleanCount;
		pool.release(second);

		pool.size = 2;
		var afterResize = counts(pool);
		var one = pool.get();
		var two = pool.get();
		var overflow = pool.get();
		var atCapacity = counts(pool);
		pool.release(one);
		pool.release(two);
		var finalCounts = counts(pool);

		return {
			initial: initial,
			afterFirstGet: afterFirstGet,
			afterRelease: afterRelease,
			reused: reused,
			reusedCleanCount: reusedCleanCount,
			afterResize: afterResize,
			atCapacity: atCapacity,
			overflowIsNull: overflow == null,
			finalCounts: finalCounts,
			created: created,
			cleaned: cleaned
		};
	}

	private static function counts(pool:ObjectPool<PooledValue>):Dynamic {
		return {
			active: pool.activeObjects,
			inactive: pool.inactiveObjects,
			size: pool.size
		};
	}
}

private class PooledValue {
	public var id(default, null):Int;
	public var cleanCount:Int;

	public function new(id:Int) {
		this.id = id;
		cleanCount = 0;
	}
}
