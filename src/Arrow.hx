package ;
import com.xay.util.Util;
import flash.geom.Rectangle;
import haxe.Timer;
import motion.Actuate;
import motion.easing.Linear;
class Arrow extends Enemy {
	var dir : Const.DIR;
	var flying : Bool;
	var shot : Bool;
	var startX : Float;
	var startY : Float;
	public function new(x:Float, y:Float, dir:Const.DIR) {
		super("arrowFlying", true);
		anim.stop();
		anim.setFrame(2);
		this.xx = Std.int(x);
		this.yy = Std.int(y);
		this.dir = dir;
		this.startX = x;
		this.startY = y;
		friction = 0;
		frictionZ = 0;
		gravity = 0;
		zz = 7;
		shot = flying = false;
		shadow.scaleX = .8;
		shadow.scaleY = .1;
		shadow.alpha = .1;
		alpha = 0.;
		Actuate.tween(this, .4, {alpha: 1.}).ease(Linear.easeNone);
		switch(dir) {
			case RIGHT:
				rotation = 0;
			case LEFT:
				scaleX = -1;
			case UP:
				rotation = -90;
				shadow.rotation = 90;
			case DOWN:
				rotation = 90;
				shadow.rotation = 90;
		}
	}
	public function shoot() {
		if(shot) return;
		anim.play();
		shot = flying = true;
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
	}
	override public function update() {
		super.update();
		if(!shot) return;
		var cx = Util.SGN(vx) * 4;
		var cy = Util.SGN(vy) * 4;
		if(dir == LEFT) {
			cx -= 2;
		} else if(dir == DOWN) {
			cy -= 3;
		} else if(dir == UP) {
			cy -= 1;
		}
		if(Math.abs(x - startX) > 8 || Math.abs(y - startY) > 8) {
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
}