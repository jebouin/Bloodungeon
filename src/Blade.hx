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
		xx = tx * 16 + 10 + Const.getDirX(lastDir) * (t - 16);
		yy = ty * 16 + 7 + Const.getDirY(lastDir) * (t - 16);
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
			super.update();
		}
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
}