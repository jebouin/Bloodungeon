package ;
import com.xay.util.SpriteLib;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
class Level {
	public static var WID : Int;
	public static var HEI : Int;
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
			for(i in 0...WID) {
				tiles[j][i] = (Std.random(4)==1?1:0);
			}
		}
		for(j in 0...HEI) {
			tiles[j][0] = tiles[j][WID-1] = 1;
		}
		for(i in 0...WID) {
			tiles[0][i] = tiles[HEI-1][i] = 1;
		}
		Game.CUR.lm.addChild(groundBmp, Const.BACK_L);
		Game.CUR.lm.addChild(wallBmp, Const.FRONT_L);
		render();
	}
	public function render() {
		if(groundBmp.bitmapData != null) {
			groundBmp.bitmapData.dispose();
		}
		if(wallBmp.bitmapData != null) {
			wallBmp.bitmapData.dispose();
		}
		var gbd = new BitmapData(Const.WID, Const.HEI, true, 0x00000000);
		var wbd = new BitmapData(Const.WID, Const.HEI, true, 0x00000000);
		for(j in 0...HEI) {
			for(i in 0...WID) {
				var tile = getTile(i, j);
				if(tile == 1) {
					SpriteLib.copyFramePixels(wbd, "tileset", i*16, j*16, 1);
				}
				SpriteLib.copyFramePixels(gbd, "tileset", i*16, j*16, 0);
			}
		}
		groundBmp.bitmapData = gbd;
		wallBmp.bitmapData = wbd;
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
}