package ;
import flash.utils.ByteArray;
import com.xay.util.SpriteLib;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.filters.DropShadowFilter;
import flash.filters.GlowFilter;
import flash.geom.Point;
@:file("res/floor0.tmx") class Floor0TMX extends ByteArray {}
enum COLLISION_TYPE {
	NONE;
	FULL;
}
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
	var tiles : Array<Array<COLLISION_TYPE> >;
	var groundLayer : TiledLayer;
	var overLayer : TiledLayer;
	var map : TiledMap;
	public function new() {
		RWID = Std.int(Const.WID / 16);
		RHEI = Std.int(Const.HEI / 16);
		load();
		Game.CUR.lm.getContainer().x = -posX;
		Game.CUR.lm.getContainer().y = -posY;
	}
	public function load() {
		map = new TiledMap(new Floor0TMX().toString());
		WID = map.wid;
		HEI = map.hei;
		nbRoomsX = Std.int(WID / (RWID - 1));
		nbRoomsY = Std.int(HEI / (RHEI - 1));
		tiles = [];
		for(j in 0...HEI) {
			tiles[j] = [];
			for(i in 0...WID) {
				tiles[j][i] = NONE;
			}
		}
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
		Game.CUR.hero.locked = true;
		Game.CUR.moveCameraTo(posX, posY, .5, function() {
			Game.CUR.hero.locked = false;
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
	public function tileCollides(x:Int, y:Int) {
		return getCollision(x, y) == FULL;
	}
	public function entityCollides(e:Entity, x:Float, y:Float) {
		if(tileCollides(Std.int(x - e.cradius) >> 4, Std.int(y - e.cradius) >> 4)) return true;
		if(tileCollides(Std.int(x + e.cradius) >> 4, Std.int(y - e.cradius) >> 4)) return true;
		if(tileCollides(Std.int(x + e.cradius) >> 4, Std.int(y + e.cradius) >> 4)) return true;
		if(tileCollides(Std.int(x - e.cradius) >> 4, Std.int(y + e.cradius) >> 4)) return true;
		return false;
	}
}