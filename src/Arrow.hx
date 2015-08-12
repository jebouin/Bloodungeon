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
		setDir(dir);
	}
	function setDir(dir:Const.DIR) {
		this.dir = dir;
		switch(dir) {
			case RIGHT:
				rotation = 0;
			case LEFT:
				scaleX = -1;
				rotation = 0;
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
		if(flying) {
			var cx = Util.SGN(vx) * 4 + xx;
			var cy = Util.SGN(vy) * 4 + yy;
			if(dir == LEFT) {
				cx -= 2;
			} else if(dir == DOWN) {
				cy -= 3;
			} else if(dir == UP) {
				cy -= 1;
			}
			if(Math.abs(x - startX) > 8 || Math.abs(y - startY) > 8) {
				if(Game.CUR.level.pointCollides(cx, cy, false, false)) {
					onHit();
				}
			}
			for(e in Game.CUR.entities) {
				if(Type.getClass(e) == Thwomp) {
					var t = cast(e, Thwomp);
					var cr = t.getCollisionRect();
					if(cr.contains(cx, cy)) {
						var middleX = cr.left + cr.width * .5;
						var middleY = cr.top + cr.height * .5;
						var cax = Util.min(cx - cr.left, cr.right - cx);
						var cay = Util.min(cy - cr.top, cr.bottom - cy);
						if(cax > cay) {
							if(cy > middleY) {
								yy = cr.bottom - Util.SGN(vy) * 4 - 3;
								setDir(UP);
							} else {
								yy = cr.top - Util.SGN(vy) * 4 + 3;
								setDir(DOWN);
							}
						} else {
							if(cx > middleX) {
								xx = cr.right - Util.SGN(vx) * 4 - 3;
								setDir(LEFT);
							} else {
								xx = cr.left - Util.SGN(vx) * 4 + 3;
								setDir(RIGHT);
							}
						}
						parent.removeChild(this);
						t.addChild(this);
						xx -= t.xx;
						yy -= t.yy;
						onHit(300);
					}
				}
			}
		}
	}
	function onHit(?fadeDelay=0) {
		flying = false;
		setAnim("arrowHit", false);
		anim.play();
		anim.onEnd = function() {
			Timer.delay(function() {
				Actuate.tween(this, .8, {alpha: 0.}).onComplete(function() {
					die();
				}).onUpdate(function() {
					shadow.alpha = this.alpha - .7;
				});
			}, fadeDelay);
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
	override function collidesHero() {
		if(!flying) return false;
		var hero = Game.CUR.hero;
		var dx = hero.xx - xx;
		var dy = hero.yy - yy;
		var r = hero.cradius + 2;
		return dx*dx + dy*dy < r * r;
	}
}