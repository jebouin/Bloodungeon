package ;
import flash.geom.Rectangle;
class Blade extends Enemy {
	var level : Level;
	var tx : Int;
	var ty : Int;
	var lastDir : Const.DIR;
	var t : Float;
	public function new(level:Level, tx:Int, ty:Int, dir:Const.DIR, off:Float) {
		super("bladeRight", false);
		this.tx = tx;
		this.ty = ty;
		lastDir = dir;
		this.level = level;
		if(Math.isNaN(off)) {
			off = 0;
		}
		t = off * 16.;
		setPos();
		setAnimDir(dir);
		anim.play();
		update();
	}
	function setPos() {
		xx = tx * 16 + 8 + Const.getDirX(lastDir) * (t - 16);
		yy = ty * 16 + 9 + Const.getDirY(lastDir) * (t - 16);
	}
	function moveToNextRail() {
		var dir = null;
		var od = Const.getOpposite(lastDir);
		var canGoForward = false;
		for(d in Const.DIRS) {
			if(d != od) {
				if(level.areRailsConnected(tx, ty, d)) {
					if(d == lastDir) {
						canGoForward = true;
						break;
					} else {
						dir = d;
					}
				}
			}
		}
		if(canGoForward) {
			dir = lastDir;
		} else if(dir == null) {
			dir = od;
		}
		if(dir != lastDir && dir != null) {
			setAnimDir(dir);
			anim.play();
		}
		lastDir = dir;
		tx += Const.getDirX(dir);
		ty += Const.getDirY(dir);
	}
	function setAnimDir(dir:Const.DIR) {
		setAnim(["bladeLeft", "bladeRight", "bladeUp", "bladeDown"][dir.getIndex()], true);
		if(dir == LEFT) {
			scaleX = -1;
		} else {
			scaleX = 1;
		}
	}
	override public function update() {
		if(Game.CUR.level != null) {
			var spd = 2.7;
			t += spd;
			if(t > 16) {
				t = 0;
				moveToNextRail();
			}
			setPos();
			//Fx.spark(xx + (lastDir == RIGHT ? -4 : (lastDir == LEFT ? 4 : 0)), yy + (lastDir == DOWN ? -4 : (lastDir == UP ? 4 : 0)), lastDir);
			super.update();
		}
	}
	public function collidesBadger() {
		var badger = Game.CUR.badger;
		if(badger == null) return false;
		if(badger.dead) return false;
		if(lastDir == UP || lastDir == DOWN) {
			return Collision.circleToRect(badger.xx, badger.yy, badger.cradius, new Rectangle(xx - 10 + 8, yy - 8 + 2, 3, 14));
		} else {
			return Collision.circleToRect(badger.xx, badger.yy, badger.cradius, new Rectangle(xx - 10 + 2, yy - 8 + 3, 16, 6));
		}
		return false;
	}
	public function killBadger(b:Badger) {
		var ndx = b.xx - xx;
		var ndy = b.yy - yy;
		var dist = Math.sqrt(ndx * ndx + ndy * ndy);
		ndx /= dist;
		ndy /= dist;
		var nvx = Const.getDirX(lastDir);
		var nvy = Const.getDirY(lastDir);
		var dx = (ndx + nvx) * .5;
		var dy = (ndy + nvy) * .5;
		b.die(-dx, -dy);
	}
	override function collidesHero() {
		var hero = Game.CUR.hero;
		if(hero == null) return false;
		if(hero.dead) return false;
		if(lastDir == UP || lastDir == DOWN) {
			return Collision.circleToRect(hero.xx, hero.yy, hero.cradius, new Rectangle(xx - 10 + 8, yy - 8 + 2, 3, 14));
		} else {
			return Collision.circleToRect(hero.xx, hero.yy, hero.cradius, new Rectangle(xx - 10 + 2, yy - 8 + 3, 16, 6));
		}
		return false;
	}
	override function killHero(h:Hero) {
		var ndx = h.xx - xx;
		var ndy = h.yy - yy;
		var dist = Math.sqrt(ndx * ndx + ndy * ndy);
		ndx /= dist;
		ndy /= dist;
		var nvx = Const.getDirX(lastDir);
		var nvy = Const.getDirY(lastDir);
		var dx = (ndx + nvx) * .5;
		var dy = (ndy + nvy) * .5;
		h.die(-dx, -dy);
	}
}