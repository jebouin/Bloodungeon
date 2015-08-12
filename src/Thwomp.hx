package ;
import com.xay.util.Util;
import flash.geom.Rectangle;
import haxe.Timer;
import motion.Actuate;
class Thwomp extends Enemy {
	public var charging : Bool;
	public var chargeX : Float;
	public var chargeY : Float;
	public function new(tx:Int, ty:Int) {
		super("thwompIdle", false);
		setOrigin(0, 0);
		chargeX = chargeY = 0;
		xx = tx * 16 - 1;
		yy = ty * 16;
		friction = 0;
		this.maxSpeed = 6.;
		charging = false;
	}
	override public function update() {
		if(!charging) {
			var hero = Game.CUR.hero;
			if(hero != null) {
				if(!hero.dead) {
					if(canHit(Std.int(hero.xx) >> 4, Std.int(hero.yy) >> 4)) {
						if(hero.y > yy && hero.y < yy + 32) {
							startCharge(hero.x < xx ? -1 : 1, 0);
						} else if(hero.x > xx && hero.x < xx + 32) {
							startCharge(0, hero.y < yy ? -1 : 1);
						}
					}
				}
			}
		}
		if(charging) {
			vx += chargeX * .075;
			vy += chargeY * .075;
			var level = Game.CUR.level;
			if(chargeX > 0) {
				if(level.pointCollides(xx + 1 + 32 + vx, yy + 8, true) || level.pointCollides(xx + 1 + 32 + vx, yy + 24, true)) {
					xx = Std.int((xx - 1.) / 16 + 1) * 16 - 1;
					charging = false;
				}
			} else if(chargeX < 0) {
				if(level.pointCollides(xx + 1 + vx, yy + 8, true) || level.pointCollides(xx + 1 + vx, yy + 24, true)) {
					xx = Std.int((xx + 1.) / 16) * 16 - 1;
					charging = false;
				}
			} else if(chargeY > 0) {
				if(level.pointCollides(xx + 1 + 8, yy + 32 + vy, true) || level.pointCollides(xx + 1 + 24, yy + 32 + vy, true)) {
					yy = Std.int((yy - 1.) / 16 + 1) * 16;
					charging = false;
				}
			} else if(chargeY < 0) {
				if(level.pointCollides(xx + 1 + 8, yy + vy, true) || level.pointCollides(xx + 1 + 24, yy + vy, true)) {
					yy = Std.int((yy + 1.) / 16) * 16;
					charging = false;
				}
			}
			if(!charging) {
				chargeX = chargeY = vx = vy = 0;
				setAnim("thwompIdle", false);
				anim.play();
			}
		}
		super.update();
	}
	function canHit(ttx:Int, tty:Int) {
		var tx = Std.int(xx + 8.) >> 4;
		var ty = Std.int(yy + 8.) >> 4;
		var level = Game.CUR.level;
		if(tty == ty || tty == ty + 1) {
			if(ttx > tx + 1) {
				for(i in tx+2...ttx+1) {
					if(level.getCollision(i, ty) == FULL || level.getCollision(i, ty+1) == FULL) {
						return false;
					}
				}
				return true;
			} else if(ttx < tx) {
				for(i in ttx...tx) {
					if(level.getCollision(i, ty) == FULL || level.getCollision(i, ty+1) == FULL) {
						return false;
					}
				}
				return true;
			}
		} else if(ttx == tx || ttx == tx + 1) {
			if(tty > ty + 1) {
				for(i in ty+2...tty+1) {
					if(level.getCollision(tx, i) == FULL || level.getCollision(tx+1, i) == FULL) {
						return false;
					}
				}
				return true;
			} else if(tty < ty) {
				for(i in tty...ty) {
					if(level.getCollision(tx, i) == FULL || level.getCollision(tx+1, i) == FULL) {
						return false;
					}
				}
				return true;
			}
		}
		return false;
	}
	function startCharge(cx:Float, cy:Float) {
		if(Math.abs(Math.abs(cx) + Math.abs(cy) - 1.) > .1) return;
		charging = true;
		chargeX = cx;
		chargeY = cy;
		setAnim("thwompCharge");
		anim.play();
	}
	override function collidesHero() {
		var hero = Game.CUR.hero;
		if(hero == null) return false;
		return Collision.circleToRect(hero.x, hero.y, hero.cradius, getCollisionRect());
	}
	public function getCollisionRect() {
		return new Rectangle(xx + 5, yy + 5, 24, 24);
	}
}