package harness.scenarios;

import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.display.Tile;
import openfl.display.TileContainer;
import openfl.display.Tilemap;
import openfl.display.Tileset;
import openfl.geom.ColorTransform;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;

class TilesScenario {
	public static function run():Dynamic {
		var bitmap = new BitmapData(64, 32, true, 0xFFFFFFFF);
		var tileset = new Tileset(bitmap, [new Rectangle(0, 0, 16, 8), new Rectangle(16, 4, 12, 10)]);
		var firstRect = tileset.getRect(0);
		firstRect.x = 99;
		var nullRectId = tileset.addRect(null);
		var thirdId = tileset.addRect(new Rectangle(32.8, 8.2, 7.9, 9.9));
		var tilesetClone = tileset.clone();

		var tile = new Tile(1, 5, 6, 2, 3, 450, 2, 4);
		tile.tileset = tileset;
		var defaults = tileState(tile);
		tile.alpha = 0.25;
		tile.blendMode = BlendMode.ADD;
		tile.colorTransform = new ColorTransform(0.5, 0.6, 0.7, 0.8, 1, 2, 3, 4);
		tile.data = "payload";
		tile.visible = false;
		tile.rect = new Rectangle(1, 2, 3, 4);
		tile.width = 12;
		tile.height = 20;
		var mutated = tileState(tile);
		var clone = tile.clone();
		clone.x = 100;
		if (clone.rect != null) clone.rect.x = 50;

		var a = new Tile(0, 1, 0);
		var b = new Tile(1, 2, 0);
		var c = new Tile(2, 3, 0);
		var nested = new TileContainer();
		nested.addTile(c);
		var group = new TileContainer(10, 20);
		group.tileset = tileset;
		group.addTiles([a, b, nested]);
		var initialOrder = ids(group);
		group.addTile(a);
		var movedOrder = ids(group);
		group.addTileAt(c, 1);
		var addedFromNestedOrder = ids(group);
		group.swapTilesAt(0, 2);
		var swappedOrder = ids(group);
		group.setTileIndex(c, 0);
		var reindexedOrder = ids(group);
		group.sortTiles(function(left, right) return left.id - right.id);
		var sortedOrder = ids(group);
		var groupClone = group.clone();
		var removed = group.removeTileAt(1);
		var invalidRemoval = group.removeTileAt(99);

		var map = new Tilemap(320, 240, tileset, false);
		map.addTiles([new Tile(0), new Tile(1)]);
		var snapshot = map.getTiles();
		map.swapTilesAt(0, 1);
		map.removeTiles(1);
		map.setTiles(groupClone);
		map.tileset = tilesetClone;
		map.width = 160;
		map.height = 120;

		return {
			tileset: {
				numRects: tileset.numRects,
				rectData: [for (value in tileset.rectData) value],
				firstRectIsCopied: tileset.getRect(0).x == 0,
				invalidLowIsNull: tileset.getRect(-1) == null,
				invalidHighIsNull: tileset.getRect(99) == null,
				nullRectId: nullRectId,
				thirdId: thirdId,
				hasSecond: tileset.hasRect(new Rectangle(16, 4, 12, 10)),
				missingIdIsNull: tileset.getRectID(new Rectangle(9, 9, 9, 9)) == null,
				cloneDistinct: tilesetClone != tileset,
				cloneBitmapShared: tilesetClone.bitmapData == bitmap,
				cloneRectCount: tilesetClone.numRects
			},
			tile: {
				defaults: defaults,
				mutated: mutated,
				cloneDistinct: clone != tile,
				cloneMatrixDistinct: clone.matrix != tile.matrix,
				cloneRectDistinct: clone.rect != tile.rect,
				originalXAfterCloneMutation: tile.x,
				originalRectXAfterCloneMutation: tile.rect.x,
				hitWithoutParents: tile.hitTestTile(clone)
			},
			container: {
				initialOrder: initialOrder,
				movedOrder: movedOrder,
				addedFromNestedOrder: addedFromNestedOrder,
				swappedOrder: swappedOrder,
				reindexedOrder: reindexedOrder,
				sortedOrder: sortedOrder,
				containsDirect: group.contains(a),
				containsNestedChild: group.contains(c),
				removedId: removed == null ? -1 : removed.id,
				removedParentIsNull: removed == null || removed.parent == null,
				invalidRemovalIsNull: invalidRemoval == null,
				remainingCount: group.numTiles,
				cloneCount: groupClone.numTiles,
				cloneChildDistinct: groupClone.getTileAt(0) != group.getTileAt(0)
			},
			tilemap: {
				width: map.width,
				height: map.height,
				smoothing: map.smoothing,
				alphaEnabled: map.tileAlphaEnabled,
				blendModeEnabled: map.tileBlendModeEnabled,
				colorTransformEnabled: map.tileColorTransformEnabled,
				numTiles: map.numTiles,
				tilesetIsClone: map.tileset == tilesetClone,
				snapshotCount: snapshot.numTiles,
				snapshotChildDistinct: snapshot.getTileAt(0) != map.getTileAt(0),
				hitInside: map.hitTestPoint(10, 10),
				hitOutside: map.hitTestPoint(200, 200)
			}
		};
	}

	private static function ids(group:TileContainer):Array<Int> return [for (i in 0...group.numTiles) group.getTileAt(i).id];

	private static function tileState(tile:Tile):Dynamic {
		var bounds = tile.getBounds(null);
		return {
			id: tile.id,
			x: tile.x,
			y: tile.y,
			scaleX: tile.scaleX,
			scaleY: tile.scaleY,
			rotation: tile.rotation,
			originX: tile.originX,
			originY: tile.originY,
			alpha: tile.alpha,
			blendMode: Std.string(tile.blendMode),
			visible: tile.visible,
			width: tile.width,
			height: tile.height,
			bounds: {x: bounds.x, y: bounds.y, width: bounds.width, height: bounds.height},
			rectIsNull: tile.rect == null,
			tilesetIsNull: tile.tileset == null
		};
	}
}
