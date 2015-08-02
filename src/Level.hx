package ;
import com.xay.util.LayerManager;
import flash.utils.ByteArray;
import com.xay.util.SpriteLib;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.filters.DropShadowFilter;
import flash.filters.GlowFilter;
import flash.geom.Point;
import Collision;
@:file("res/floor0.tmx") class Floor0TMX extends ByteArray {}
class Level {
	public static var RWID : Int;
	public static var RHEI : Int;
	public static var WID : Int;
	public static var HEI : Int;
	public var startX : Float;
	public var startY : Float;
	public var posX : Float;
	public var posY : Float;
	var roomIdX : Int;
	var roomIdY : Int;
	var nbRoomsX : Int;
	var nbRoomsY : Int;
	var tiles : Array<Array<TILE_COLLISION_TYPE> >;
	var ground0Layer : TiledLayer;
	var ground1Layer : TiledLayer;
	var overLayer : TiledLayer;
	var wall0Layer : TiledLayer;
	var wall1Layer : TiledLayer;
	var map : TiledMap;
	public function new() {
		RWID = Std.int(Const.WID / 16);
		RHEI = Std.int(Const.HEI / 16);
		load();
		Game.CUR.lm.addChild(ground0Layer, Const.BACK_L);
		Game.CUR.lm.addChild(ground1Layer, Const.BACK_L);
		Game.CUR.lm.addChild(overLayer, Const.BACK_L);
		Game.CUR.lm.addChild(wall0Layer, Const.BACK_L);
		Game.CUR.lm.addChild(wall1Layer, Const.BACK_L);
		startX = 21 * 16 + 8;
		startY = 59 * 16 + 8;
		/*startX = 4 * 16 + 8;
		startY = 34 * 16 + 8;*/
		setRoomId(Std.int(startX / 16 / (RWID - 1)), Std.int(startY / 16 / (RHEI - 1)));
		Game.CUR.lm.getContainer().x = -posX;
		Game.CUR.lm.getContainer().y = -posY;
	}
	public function load() {
		map = new TiledMap(new Floor0TMX().toString());
		ground0Layer = map.getLayer("ground0");
		ground1Layer = map.getLayer("ground1");
		overLayer = map.getLayer("over");
		wall0Layer = map.getLayer("wall0");
		wall1Layer = map.getLayer("wall1");
		WID = map.wid;
		HEI = map.hei;
		nbRoomsX = Std.int(WID / (RWID - 1));
		nbRoomsY = Std.int(HEI / (RHEI - 1));
		tiles = [];
		for(j in 0...HEI) {
			tiles[j] = [];
			for(i in 0...WID) {
				var overTileCol = Collision.TILE_COLLISIONS[overLayer.getTileAt(i, j)];
				var wall0TileCol = Collision.TILE_COLLISIONS[wall0Layer.getTileAt(i, j)];
				var wall1TileCol = Collision.TILE_COLLISIONS[wall1Layer.getTileAt(i, j)];
				var col = NONE;
				if(wall1TileCol != NONE) {
					col = wall1TileCol;
				} else {
					col = wall0TileCol;
				}
				tiles[j][i] = col;
			}
		}
		//set wall z order
		/*for(j in 0...HEI) {
			for(i in 0...WID) {
				var tile = getCollision(i, j);
				var btile = getCollision(i, j+1);
				if(tile != NONE && btile != NONE) {
					wall1Layer.setTileAt(i, j, wall0Layer.getTileAt(i, j));
					wall0Layer.setTileAt(i, j, 0);
				}
			}
		}
		wall0Layer.render();
		wall1Layer.render();*/
	}
	public function loadEntities(idx:Int, idy:Int) {
		if(idx < 0 || idy < 0 || idx >= nbRoomsX || idy >= nbRoomsY) return false;
		return true;
	}
	public function nextRoom(dx:Int, dy:Int) {
		if(Math.abs(dx) + Math.abs(dy) != 1) {
			return false;
		}
		if(!loadEntities(roomIdX + dx, roomIdY + dy)) {
			return false;
		}
		setRoomId(roomIdX + dx, roomIdY + dy);
		Game.CUR.lock();
		Game.CUR.moveCameraTo(posX, posY, .5, function() {
			Game.CUR.unlock();
		});
		return true;
	}
	function setRoomId(idx:Int, idy:Int) {
		roomIdX = idx;
		roomIdY = idy;
		posX = idx * (RWID - 1) * 16;
		posY = idy * (RHEI - 1) * 16;
	}
	public inline function isOnMap(x:Int, y:Int) {
		return x >= 0 && y >= 0 && x < WID && y < HEI;
	}
	public function getCollision(x:Int, y:Int) {
		if(!isOnMap(x, y)) {
			return NONE;
		}
		return tiles[y][x];
	}
	public function getHeight(x:Int, y:Int) {
		if(!isOnMap(x, y)) {
			return 0;
		}
		return 0;
	}
	public function getCollisionAt(x:Float, y:Float) {
		return getCollision(Std.int(x / 16), Std.int(y / 16));
	}
	public function getHeightAt(x:Float, y:Float) {
		var tx = Std.int(x) >> 4;
		var ty = Std.int(y) >> 4;
		return getHeight(tx, ty);
	}
	public function tileCollides(x:Int, y:Int) {
		return getCollision(x, y) == FULL;
	}
	public function entityCollides(e:Entity, x:Float, y:Float) {
		y -= 16 * getHeightAt(x, y);
		if(tileCollides(Std.int(x - e.cradius) >> 4, Std.int(y - e.cradius) >> 4)) return true;
		if(tileCollides(Std.int(x + e.cradius) >> 4, Std.int(y - e.cradius) >> 4)) return true;
		if(tileCollides(Std.int(x + e.cradius) >> 4, Std.int(y + e.cradius) >> 4)) return true;
		if(tileCollides(Std.int(x - e.cradius) >> 4, Std.int(y + e.cradius) >> 4)) return true;
		return false;
	}
}