package harness.scenarios;

import openfl.text.StaticText;

class StaticTextScenario
{
	public static function run():Dynamic
	{
		var instance:StaticText = Type.createInstance(StaticText, []);

		return {
			typeName: Type.getClassName(Type.getClass(instance)),
			text: instance.text,
			display: {
				alpha: instance.alpha,
				height: instance.height,
				parent: instance.parent == null,
				root: instance.root == null,
				stage: instance.stage == null,
				visible: instance.visible,
				width: instance.width
			}
		};
	}
}
