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
		Game.CUR.lm.addChild(this, Const.ENEMY_L);
		update();
	}
	override public function update() {
		if(charging) {
			vx += chargeX * .1;
			vy += chargeY * .1;
			var level = Game.CUR.level;
			if(chargeX > 0) {
				if(level.pointCollides(xx + 1 + 32 + vx, yy + 8) || level.pointCollides(xx + 1 + 32 + vx, yy + 24)) {
					xx = Std.int((xx - 1.) / 16 + 1) * 16 - 1;
					charging = false;
				}
			} else if(chargeX < 0) {
				if(level.pointCollides(xx + 1 + vx, yy + 8) || level.pointCollides(xx + 1 + vx, yy + 24)) {
					xx = Std.int((xx + 1.) / 16) * 16 - 1;
					charging = false;
				}
			} else if(chargeY > 0) {
				if(level.pointCollides(xx + 1 + 8, yy + 32 + vy) || level.pointCollides(xx + 1 + 24, yy + 32 + vy)) {
					yy = Std.int((yy - 1.) / 16 + 1) * 16;
					charging = false;
				}
			} else if(chargeY < 0) {
				if(level.pointCollides(xx + 1 + 8, yy + vy) || level.pointCollides(xx + 1 + 24, yy + vy)) {
					yy = Std.int((yy + 1.) / 16) * 16;
					charging = false;
				}
			}
			if(!charging) {
				chargeX = chargeY = vx = vy = 0;
			}
		} else {
			var hero = Game.CUR.hero;
			if(hero.y > yy + 4 && hero.y < yy + 28) {
				startCharge(hero.x < xx ? -1 : 1, 0);
			} else if(hero.x > xx + 4 && hero.x < xx + 28) {
				startCharge(0, hero.y < yy ? -1 : 1);
			}
		}
		super.update();
	}
	function startCharge(cx:Float, cy:Float) {
		if(Math.abs(Math.abs(cx) + Math.abs(cy) - 1.) > .1) return;
		charging = true;
		chargeX = cx;
		chargeY = cy;
	}
	override function collidesHero() {
		var hero = Game.CUR.hero;
		return Collision.circleToRect(hero.x, hero.y, hero.cradius, new Rectangle(xx + 4, yy + 3, 27, 27));
	}
}