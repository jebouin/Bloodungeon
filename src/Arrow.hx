package ;
import com.xay.util.Util;
import flash.geom.Rectangle;
import haxe.Timer;
import motion.Actuate;
class Arrow extends Enemy {
	var dir : Const.DIR;
	var flying : Bool;
	public function new(x:Float, y:Float, dir:Const.DIR) {
		super("arrowSideFlying", true);
		this.xx = x;
		this.yy = y;
		this.dir = dir;
		friction = 0;
		frictionZ = 0;
		gravity = 0;
		zz = 7;
		flying = true;
		switch(dir) {
			case RIGHT:
				vx = 2.;
			case LEFT:
				vx = -2.;
			case UP:
				vy = -2.;
			case DOWN:
				vy = 2.;
		}
		shadow.scaleX = .7;
		shadow.scaleY = .2;
		shadow.alpha = .3;
	}
	override public function update() {
		super.update();
		var cx = Util.SGN(vx) * 4;
		var cy = Util.SGN(vy) * 4;
		if(Game.CUR.level.pointCollides(xx + cx, yy + cy)) {
			flying = false;
			setAnim("arrowSideHit", false);
			anim.play();
			vx = vy = 0;
			bmp.scrollRect = new Rectangle(0, 0, bmp.width - 3, bmp.height);
			Timer.delay(function() {
				Actuate.tween(this, .8, {alpha: 0.}).onComplete(function() {
					die();
				}).onUpdate(function() {
					shadow.alpha = this.alpha - .7;
				});
			}, 200);
		}
	}
}