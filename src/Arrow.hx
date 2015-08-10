package ;
import com.xay.util.Util;
import flash.geom.Rectangle;
import haxe.Timer;
import motion.Actuate;
class Arrow extends Enemy {
	var dir : Const.DIR;
	var flying : Bool;
	public function new(x:Float, y:Float, dir:Const.DIR) {
		super("arrowFlying", true);
		this.xx = Std.int(x);
		this.yy = Std.int(y);
		this.dir = dir;
		friction = 0;
		frictionZ = 0;
		gravity = 0;
		zz = 7;
		flying = true;
		shadow.scaleX = .8;
		shadow.scaleY = .1;
		shadow.alpha = .1;
		switch(dir) {
			case RIGHT:
				vx = 2.;
				rotation = 0;
			case LEFT:
				vx = -2.;
				scaleX = -1;
			case UP:
				vy = -2.;
				rotation = -90;
				shadow.rotation = 90;
			case DOWN:
				vy = 2.;
				rotation = 90;
				shadow.rotation = 90;
		}
	}
	override public function update() {
		super.update();
		var cx = Util.SGN(vx) * 4;
		var cy = Util.SGN(vy) * 4;
		if(dir == LEFT) {
			cx -= 2;
		}
		if(dir == DOWN) {
			cy -= 3;
		}
		if(Game.CUR.level.pointCollides(xx + cx, yy + cy)) {
			flying = false;
			setAnim("arrowHit", false);
			anim.play();
			anim.onEnd = function() {
				Actuate.tween(this, .8, {alpha: 0.}).onComplete(function() {
					die();
				}).onUpdate(function() {
					shadow.alpha = this.alpha - .7;
				});
			}
			vx = vy = 0;
			switch(dir) {
				case RIGHT, LEFT:
					bmp.scrollRect = new Rectangle(0, 0, bmp.width - 3, bmp.height);
				case DOWN:
					bmp.scrollRect = new Rectangle(0, 0, bmp.width - 4, bmp.height);
					yy += 2;
					shadow.visible = false;
				case UP:
					
			}
		}
	}
}