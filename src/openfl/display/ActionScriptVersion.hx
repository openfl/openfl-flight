package openfl.display;

#if !flash
/** Identifies the ActionScript language generation used by loaded SWF content. **/
enum abstract ActionScriptVersion(UInt) from UInt to UInt
{
	var ACTIONSCRIPT2 = 2;
	var ACTIONSCRIPT3 = 3;
}
#else
typedef ActionScriptVersion = flash.display.ActionScriptVersion;
#end
