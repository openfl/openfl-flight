package openfl.display;

#if !flash
/**
	Implemented by objects that may be used as the source of a BitmapData draw
	operation. The OpenFL interface contains renderer-only private members; the
	Flight adapter intentionally keeps no renderer contract here.
**/
interface IBitmapDrawable {}
#else
typedef IBitmapDrawable = flash.display.IBitmapDrawable;
#end
