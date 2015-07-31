package ;
import com.xay.util.SpriteLib;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.filters.DropShadowFilter;
import flash.filters.GlowFilter;
import flash.geom.Point;
@:bitmap("res/levels.png") class LevelsBD extends BitmapData {}
class Level {
	public static var RWID : Int;
	public static var RHEI : Int;
	public static var WID : Int;
	public static var HEI : Int;
	public var startX : Float;
	public var startY : Float;
	public var posX : Float;
	public var posY : Float;
	var levelIdX : Int;
	var levelIdY : Int;
	var nbLevelsX : Int;
	var nbLevelsY : Int;
	var levelsBD : BitmapData;
	var groundBmp : Bitmap;
	var wallBmp : Bitmap;
	var tiles : Array<Array<Int> >;
	public function new() {
		groundBmp = new Bitmap();
		wallBmp = new Bitmap();
		RWID = Std.int(Const.WID / 16);
		RHEI = Std.int(Const.HEI / 16);
		levelsBD = new LevelsBD(0, 0);
		load();
		setRoomId(0, 1);
		Game.CUR.lm.addChild(groundBmp, Const.BACK_L);
		Game.CUR.lm.addChild(wallBmp, Const.BACK_L);
		render();
		Game.CUR.lm.getContainer().x = -posX;
		Game.CUR.lm.getContainer().y = -posY;
	}
	public function render() {
		var gbd : BitmapData, wbd : BitmapData;
		if(groundBmp.bitmapData != null) {
			gbd = groundBmp.bitmapData;
			gbd.fillRect(gbd.rect, 0x0);
		} else {
			gbd = new BitmapData(WID * 16, HEI * 16, true, 0x00000000);
		}
		if(wallBmp.bitmapData != null) {
			wbd = wallBmp.bitmapData;
			wbd.fillRect(gbd.rect, 0x0);
		} else {
			wbd = new BitmapData(WID * 16, HEI * 16, true, 0x00000000);
		}
		for(j in 0...HEI) {
			for(i in 0...WID) {
				var tile = getTile(i, j);
				if(tile == 1) {
					SpriteLib.copyFramePixels(wbd, "tileset", i*16, j*16, 1);
				}
				SpriteLib.copyFramePixels(gbd, "tileset", i*16, j*16, 0);
			}
		}
		wbd.applyFilter(wbd, wbd.rect, new Point(0, 0), new DropShadowFilter(4, 270, 0, 1., 2., 2., 1., 1, true, false));
		groundBmp.bitmapData = gbd;
		wallBmp.bitmapData = wbd;
	}
	public function load() {
		WID = levelsBD.width;
		HEI = levelsBD.height;
		nbLevelsX = Std.int(WID / (RWID - 1));
		nbLevelsY = Std.int(HEI / (RHEI - 1));
		tiles = [];
		for(j in 0...HEI) {
			tiles[j] = [];
			for(i in 0...WID) {
				var col = levelsBD.getPixel(i, j);
				var tile = 0;
				if(col == 0x303030) {
					tile = 1;
				} else if(col == 0xFF00FF) {
					startX = i * 16;
					startY = j * 16;
				}
				tiles[j][i] = tile;
			}
		}
	}
	public function loadEntities(idx:Int, idy:Int) {
		if(idx < 0 || idy < 0 || idx >= nbLevelsX || idy >= nbLevelsY) return false;
		return true;
	}
	public function nextLevel(dx:Int, dy:Int) {
		if(Math.abs(dx) + Math.abs(dy) != 1) {
			return false;
		}
		if(!loadEntities(levelIdX + dx, levelIdY + dy)) {
			return false;
		}
		setRoomId(levelIdX + dx, levelIdY + dy);
		Game.CUR.hero.locked = true;
		Game.CUR.moveCameraTo(posX, posY, .5, function() {
			Game.CUR.hero.locked = false;
		});
		render();
		return true;
	}
	function setRoomId(idx:Int, idy:Int) {
		levelIdX = idx;
		levelIdY = idy;
		posX = idx * (RWID - 1) * 16;
		posY = idy * (RHEI - 1) * 16;
	}
	public inline function isOnMap(x:Int, y:Int) {
		return x >= 0 && y >= 0 && x < WID && y < HEI;
	}
	public function getTile(x:Int, y:Int) {
		if(!isOnMap(x, y)) {
			return 0;
		}
		return tiles[y][x];
	}
	public function tileCollides(x:Int, y:Int) {
		return getTile(x, y) == 1;
	}
	public function entityCollides(e:Entity, x:Float, y:Float) {
		if(tileCollides(Std.int(x - e.cradius) >> 4, Std.int(y - e.cradius) >> 4)) return true;
		if(tileCollides(Std.int(x + e.cradius) >> 4, Std.int(y - e.cradius) >> 4)) return true;
		if(tileCollides(Std.int(x + e.cradius) >> 4, Std.int(y + e.cradius) >> 4)) return true;
		if(tileCollides(Std.int(x - e.cradius) >> 4, Std.int(y + e.cradius) >> 4)) return true;
		return false;
	}
}