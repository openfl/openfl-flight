package harness.scenarios;

import openfl.events.AccelerometerEvent;
import openfl.sensors.Accelerometer;
import openfl.sensors.DeviceRotation;
import openfl.sensors.Geolocation;

class SensorScenario
{
	public static function run():Dynamic
	{
		var accelerometer = new Accelerometer();
		var updates:Array<Dynamic> = [];
		accelerometer.addEventListener(AccelerometerEvent.UPDATE, function(event:AccelerometerEvent):Void
		{
			updates.push({
				accelerationX: event.accelerationX,
				accelerationY: event.accelerationY,
				accelerationZ: event.accelerationZ,
				timestampIsNonNegative: event.timestamp >= 0
			});
		});

		var negativeIntervalError = errorClass(function():Void accelerometer.setRequestedUpdateInterval(-1));
		accelerometer.setRequestedUpdateInterval(0);
		var initialMuted = accelerometer.muted;
		accelerometer.muted = true;
		var mutedAfterSet = accelerometer.muted;
		accelerometer.muted = false;

		return {
			accelerometer: {
				initialMuted: initialMuted,
				isSupported: Accelerometer.isSupported,
				mutedAfterSet: mutedAfterSet,
				negativeIntervalError: negativeIntervalError,
				updates: updates
			},
			deviceRotation: {
				constructorError: errorClass(function():Void
				{
					new DeviceRotation();
				}),
				isSupported: DeviceRotation.isSupported,
				plainClass: Type.getSuperClass(DeviceRotation) == null
			},
			geolocation: {
				accuracyConstants: [
					Geolocation.LOCATION_ACCURACY_BEST,
					Geolocation.LOCATION_ACCURACY_BEST_FOR_NAVIGATION,
					Geolocation.LOCATION_ACCURACY_HUNDRED_METERS,
					Geolocation.LOCATION_ACCURACY_KILOMETER,
					Geolocation.LOCATION_ACCURACY_NEAREST_TEN_METERS,
					Geolocation.LOCATION_ACCURACY_THREE_KILOMETERS
				],
				constructorError: errorClass(function():Void
				{
					new Geolocation();
				}),
				isSupported: Geolocation.isSupported,
				plainClass: Type.getSuperClass(Geolocation) == null
			}
		};
	}

	private static function errorClass(operation:Void->Void):Null<String>
	{
		try
		{
			operation();
			return null;
		}
		catch (error:Dynamic)
		{
			var errorClass = Type.getClass(error);
			return errorClass == null ? Std.string(error) : Type.getClassName(errorClass);
		}
	}
}
