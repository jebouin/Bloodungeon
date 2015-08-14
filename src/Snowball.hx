package ;
import com.xay.util.Util;
import com.xay.util.XSprite;
class Snowball extends Enemy {
	var startX : Float;
	var startY : Float;
	var splashed : Bool;
	var splash : XSprite;
	public function new(x:Float, y:Float, vx:Float, vy:Float) {
		super("snowball", true);
		this.xx = startX = x;
		this.yy = startY = y;
		this.vx = vx;
		this.vy = vy;
		splashed = false;
		friction = 0;
		moves = true;
		collides = false;
		shadow.alpha *= .6;
		shadow.scaleX *= .8;
		shadow.scaleY *= .8;
	}
	override public function delete() {
		if(splash != null) {
			splash.delete();
		}
		super.delete();
	}
	override public function update() {
		super.update();
		if(!splashed) {
			var svx = Util.SGN(vx) * 5;
			var svy = Util.SGN(vy) * 5;
			var cx = svx + xx;
			var cy = svy + yy;
			if(vy < 0) {
				cy += 3;
			}
			if(Math.abs(x - startX) > 8 || Math.abs(y - startY) > 8) {
				if(Game.CUR.level.pointCollides(cx, cy, false, false)) {
					if(!Game.CUR.level.pointCollides(cx, cy - svy, false, false)) {
						vx = 0;
					}
					if(!Game.CUR.level.pointCollides(cx - svx, cy, false, false)) {
						vy = 0;
					}
					onHit(cx, cy);
				}
			}
		} else {
			if(!splash.anim.playing) {
				die();
				return;
			}
			splash.update();
		}
	}
	function onHit(cx:Float, cy:Float) {
		visible = false;
		shadow.visible = false;
		splashed = true;
		splash = new XSprite("snowsplash", false);
		splash.setOriginInPixels(5, 8);
		splash.x = Std.int(xx);
		splash.y = Std.int(yy);
		if(vx < 0) splash.x += 2;
		splash.rotation = 180 + Std.int(Math.atan2(vy, vx) * 180 / Math.PI);
		Game.CUR.lm.addChild(splash, Const.BACK_L);
		vx = vy = 0;
	}
	override function collidesHero() {
		if(splashed) return false;
		var hero = Game.CUR.hero;
		var dx = hero.xx - xx;
		var dy = hero.yy - yy;
		var r = hero.cradius + 4;
		return dx*dx + dy*dy < r * r;
	}
}