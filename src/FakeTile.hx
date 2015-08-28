package ;
import com.xay.util.SpriteLib;
import com.xay.util.Util;
import flash.display.BitmapData;
import flash.filters.GlowFilter;
import flash.geom.Rectangle;
import motion.Actuate;
class FakeTile extends Enemy {
	public static var nbBroken = 0;
	public static var brokens = [false, false, false, false, false, false];
	var dir : Const.DIR;
	var rect : Rectangle;
	var tx : Int;
	var ty : Int;
	var wid : Int;
	var hei : Int;
	var secretId : Int;
	public function new(level:Level, tx:Int, ty:Int, wid:Int, hei:Int, tileId:Int, secretId:Int, dir:Const.DIR) {
		super(null, false);
		this.dir = dir;
		this.secretId = secretId;
		this.tx = tx;
		this.ty = ty;
		this.wid = wid;
		this.hei = hei;
		fadeThis = false;
		moves = false;
		bmp.bitmapData = new BitmapData(wid << 4, hei << 4, true);
		for(j in 0...hei) {
			for(i in 0...wid) {
				SpriteLib.copyFramePixelsFromSlice(bmp.bitmapData, "tileset", tileId, i << 4, j << 4);
			}
		}
		setOrigin(0, 0);
		xx = tx * 16;
		yy = ty * 16;
		parent.removeChild(this);
		Game.CUR.lm.addChild(this, Const.BACK_L);
		rect = new Rectangle(xx, yy, wid * 16, hei * 16);
		for(j in ty...ty+hei) {
			for(i in tx...tx+wid) {
				var rcol = level.getCollision(i+1, j);
				level.setCollision(i, j, FULL);
			}
		}
		update();
		if(brokens[secretId]) {
			disappear(true);
		}
		if(Game.yoloMode) {
			filters = [new GlowFilter(0xFFFFFF, .3, 10., 2., 5., 1)];
		}
	}
	override public function update() {
		super.update();
		var hero = Game.CUR.hero;
		if(hero == null) return;
		var nx = hero.xx + Util.SGN(hero.vx) * (hero.cradius + 5);
		var ny = hero.yy + Util.SGN(hero.vy) * (hero.cradius + 5);
		if(canDisappear() && rect.contains(nx, ny)) {
			disappear();
		}
	}
	function canDisappear() {
		var hero = Game.CUR.hero;
		if(hero.vx > 0 && dir == RIGHT) {
			return true;
		}
		if(hero.vx < 0 && dir == LEFT) {
			return true;
		}
		if(hero.vy > 0 && dir == DOWN) {
			return true;
		}
		if(hero.vy < 0 && dir == UP) {
			return true;
		}
		return false;
	}
	function disappear(?onLoad=false) {
		var th = ty + hei;
		if(Game.CUR.level.floor == 3) {
			th = ty + 1;
		}
		for(j in ty...th) {
			for(i in tx...tx+wid) {
				var rcol = Game.CUR.level.getCollision(i+1, j);
				if(rcol == ICE) {
					Game.CUR.level.setCollision(i, j, ICE);
				} else {
					Game.CUR.level.setCollision(i, j, NONE);
				}
			}
		}
		//BOOM!
		die();
		brokens[secretId] = true;
		Game.CUR.level.fakeTileWasRemoved(secretId);
		if(!onLoad) {
			Save.onFakeTileBroken();
			if(nbBroken == 0) {
				Achievements.unlock("Secret...");
			}
			nbBroken++;
			if(nbBroken == 6) {
				Achievements.unlock("Cheater");
			}
		}
	}
}