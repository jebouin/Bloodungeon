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
	public static var WID : Int;
	public static var HEI : Int;
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
		WID = Std.int(Const.WID / 16);
		HEI = Std.int(Const.HEI / 16);
		tiles = [];
		for(j in 0...HEI) {
			tiles[j] = [];
		}
		levelsBD = new LevelsBD(0, 0);
		nbLevelsX = Std.int(levelsBD.width / (WID - 1));
		nbLevelsY = Std.int(levelsBD.height / (HEI - 1));
		posX = posY = 1 << 12;
		updatePos();
		loadLevel(0, 1);
		Game.CUR.lm.addChild(groundBmp, Const.BACK_L);
		Game.CUR.lm.addChild(wallBmp, Const.BACK_L);
		render();
	}
	public function render() {
		var gbd : BitmapData, wbd : BitmapData;
		if(groundBmp.bitmapData != null) {
			gbd = groundBmp.bitmapData;
			gbd.fillRect(gbd.rect, 0x0);
		} else {
			gbd = new BitmapData(Const.WID, Const.HEI, true, 0x00000000);
		}
		if(wallBmp.bitmapData != null) {
			wbd = wallBmp.bitmapData;
			wbd.fillRect(gbd.rect, 0x0);
		} else {
			wbd = new BitmapData(Const.WID, Const.HEI, true, 0x00000000);
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
		wbd.applyFilter(wbd, wbd.rect, new Point(0, 0), new DropShadowFilter(4, 270, 0, 1., 2., 2., 1., 0, true, false));
		groundBmp.bitmapData = gbd;
		wallBmp.bitmapData = wbd;
	}
	public function loadLevel(idx:Int, idy:Int) {
		if(idx < 0 || idy < 0 || idx >= nbLevelsX || idy >= nbLevelsY) return false;
		levelIdX = idx;
		levelIdY = idy;
		for(j in 0...HEI) {
			for(i in 0...WID) {
				var col = levelsBD.getPixel(i + levelIdX * (WID - 1), j + levelIdY * (HEI - 1));
				var tile = 0;
				if(col == 0x303030) {
					tile = 1;
				}
				tiles[j][i] = tile;
			}
		}
		return true;
	}
	public function nextLevel(dx:Int, dy:Int) {
		if(Math.abs(dx) + Math.abs(dy) != 1) {
			return false;
		}
		if(!loadLevel(levelIdX + dx, levelIdY + dy)) {
			return false;
		}
		var px = posX;
		var py = posY;
		posX += dx * (WID - 1) * 16;
		posY += dy * (HEI - 1) * 16;
		updatePos();
		var pbd = new BitmapData(groundBmp.bitmapData.width, groundBmp.bitmapData.height, true, 0x0);
		pbd.copyPixels(groundBmp.bitmapData, groundBmp.bitmapData.rect, new Point(0, 0), groundBmp.bitmapData, new Point(0, 0), true);
		pbd.copyPixels(wallBmp.bitmapData, wallBmp.bitmapData.rect, new Point(0, 0), wallBmp.bitmapData, new Point(0, 0), true);
		var prevBitmap = new Bitmap(pbd);
		prevBitmap.x = px;
		prevBitmap.y = py;
		Game.CUR.lm.addChild(prevBitmap, Const.BACK_L);
		Game.CUR.hero.locked = true;
		Game.CUR.moveCameraTo(posX, posY, .5, function() {
			prevBitmap.parent.removeChild(prevBitmap);
			prevBitmap.bitmapData.dispose();
			Game.CUR.hero.locked = false;
		});
		render();
		return true;
	}
	function levelTransition() {
		
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
		x -= posX;
		y -= posY;
		if(tileCollides(Std.int(x - e.cradius) >> 4, Std.int(y - e.cradius) >> 4)) return true;
		if(tileCollides(Std.int(x + e.cradius) >> 4, Std.int(y - e.cradius) >> 4)) return true;
		if(tileCollides(Std.int(x + e.cradius) >> 4, Std.int(y + e.cradius) >> 4)) return true;
		if(tileCollides(Std.int(x - e.cradius) >> 4, Std.int(y + e.cradius) >> 4)) return true;
		return false;
	}
	public function updatePos() {
		groundBmp.x = wallBmp.x = Std.int(posX);
		groundBmp.y = wallBmp.y = Std.int(posY);
	}	
}