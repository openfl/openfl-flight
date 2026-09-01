package openfl.display;

import openfl.geom.Matrix;
import openfl.geom.Rectangle;

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:access(openfl.display.Tile)
@:access(openfl.display.TileContainer)
@:access(openfl.geom.Matrix)
@:access(openfl.geom.Rectangle)
class Tilemap extends #if !flash DisplayObject #else Bitmap implements IDisplayObject #end implements ITileContainer
{
	public var numTiles(get, never):Int;
	public var tileAlphaEnabled:Bool;
	public var tileBlendModeEnabled:Bool;
	public var tileColorTransformEnabled:Bool;
	public var tileset(get, set):Tileset;
	#if !flash
	public var smoothing:Bool;
	#end

	@:noCompletion private var __group:TileContainer;
	@:noCompletion private var __tileset:Tileset;
	#if !flash
	@:noCompletion private var __height:Int;
	@:noCompletion private var __width:Int;
	#end

	public function new(width:Int, height:Int, tileset:Tileset = null, smoothing:Bool = true)
	{
		super();
		__tileset = tileset;
		this.smoothing = smoothing;
		tileAlphaEnabled = true;
		tileBlendModeEnabled = true;
		tileColorTransformEnabled = true;
		__group = new TileContainer();
		__group.tileset = tileset;
		#if !flash
		__width = width;
		__height = height;
		#else
		bitmapData = new BitmapData(width, height, true, 0);
		#end
	}

	public function addTile(tile:Tile):Tile return __group.addTile(tile);
	public function addTileAt(tile:Tile, index:Int):Tile return __group.addTileAt(tile, index);
	public function addTiles(tiles:Array<Tile>):Array<Tile> return __group.addTiles(tiles);
	public function contains(tile:Tile):Bool return __group.contains(tile);
	public function getTileAt(index:Int):Tile return __group.getTileAt(index);
	public function getTileIndex(tile:Tile):Int return __group.getTileIndex(tile);
	public function getTiles():TileContainer return __group.clone();
	public function removeTile(tile:Tile):Tile return __group.removeTile(tile);
	public function removeTileAt(index:Int):Tile return __group.removeTileAt(index);
	public function removeTiles(beginIndex:Int = 0, endIndex:Int = 0x7fffffff):Void
	{
		__group.removeTiles(beginIndex, endIndex);
	}
	public function setTileIndex(tile:Tile, index:Int):Void __group.setTileIndex(tile, index);

	public function setTiles(group:TileContainer):Void
	{
		while (__group.numTiles > 0) __group.removeTileAt(__group.numTiles - 1);
		if (group != null)
		{
			for (i in 0...group.numTiles) __group.addTile(group.getTileAt(i));
		}
	}

	public function sortTiles(compareFunction:Tile->Tile->Int):Void __group.sortTiles(compareFunction);
	public function swapTiles(tile1:Tile, tile2:Tile):Void __group.swapTiles(tile1, tile2);
	public function swapTilesAt(index1:Int, index2:Int):Void __group.swapTilesAt(index1, index2);

	#if !flash
	@:noCompletion private override function __enterFrame(deltaTime:Int):Void
	{
		if (__group.__dirty) __setRenderDirty();
	}

	@:noCompletion private override function __getBounds(rect:Rectangle, matrix:Matrix):Void
	{
		var bounds = new Rectangle(0, 0, __width, __height);
		bounds.__transform(bounds, matrix);
		rect.__expand(bounds.x, bounds.y, bounds.width, bounds.height);
	}

	@:noCompletion private override function __hitTest(x:Float, y:Float, shapeFlag:Bool, stack:Array<DisplayObject>, interactiveOnly:Bool,
		hitObject:DisplayObject):Bool
	{
		if (!hitObject.visible) return false;
		__getRenderTransform();
		var px = __renderTransform.__transformInverseX(x, y);
		var py = __renderTransform.__transformInverseY(x, y);
		if (px >= 0 && py >= 0 && px <= __width && py <= __height)
		{
			if (stack != null && !interactiveOnly) stack.push(hitObject);
			return true;
		}
		return false;
	}

	@:noCompletion private override function get_height():Float return __height * Math.abs(scaleY);
	@:noCompletion private override function set_height(value:Float):Float
	{
		__height = Std.int(value);
		return __height * Math.abs(scaleY);
	}
	#end

	@:noCompletion private function get_numTiles():Int return __group.numTiles;
	@:noCompletion private function get_tileset():Tileset return __tileset;
	@:noCompletion private function set_tileset(value:Tileset):Tileset
	{
		if (value != __tileset)
		{
			__tileset = value;
			__group.tileset = value;
			#if !flash
			__setRenderDirty();
			#end
		}
		return value;
	}

	#if !flash
	@:noCompletion private override function get_width():Float return __width * Math.abs(scaleX);
	@:noCompletion private override function set_width(value:Float):Float
	{
		__width = Std.int(value);
		return __width * Math.abs(scaleX);
	}
	#end
}
