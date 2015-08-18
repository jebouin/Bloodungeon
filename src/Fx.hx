package ;
import com.xay.util.Util;
import flash.display.BlendMode;
import flash.filters.BlurFilter;
import flash.filters.GlowFilter;
import haxe.Timer;
import motion.Actuate;
import motion.easing.Elastic;
class Fx {
	public static var sx = 0.;
	public static var sy = 0.;
	public static function update() {
		Particle.updateAll();
	}
	public static function screenShake(dx:Float, dy:Float, ?t=.5, ?random=false) {
		sx = dx;
		sy = dy;
		var c = Game.CUR.lm.getContainer();
		if(random) {
			Actuate.tween(Fx, t, {sy:0.}).onUpdate(function() {
				c.x = -(Game.CUR.camX + (Math.random() - .5) * 2. * sy);
				c.y = -(Game.CUR.camY + (Math.random() - .5) * 1.6 * sy);
			}).ease(Elastic.easeOut);
		} else {
			Actuate.tween(Fx, t, {sx:0., sy:0.}).onUpdate(function() {
				c.x = -(Game.CUR.camX + sx);
				c.y = -(Game.CUR.camY + sy);
			}).ease(Elastic.easeOut);
		}
	}
	public static function stopScreenShake() {
		Actuate.stop(Fx, "sx, sy");
	}
	public static function test() {
		for(i in 0...10) {
			var p = Particle.create();
			if(p == null) break;
			Game.CUR.lm.addChild(p, Const.FRONT_L);
			p.drawRect(8, 8, 0xFF0000);
			p.xx = -Game.CUR.lm.getContainer().x + Std.random(Const.WID) - 100;
			p.yy = -Game.CUR.lm.getContainer().y + Std.random(Const.HEI);
			p.vx = 10.;
			p.blendMode = BlendMode.ADD;
		}
	}
	public static function heroDeath(dx:Float, dy:Float) {
		var d = Math.sqrt(dx*dx + dy*dy);
		if(d < .1) {
			screenShake(0, 8, .5, true);
		} else {
			dx /= d;
			dy /= d;
			screenShake(dx * 15., dy * 15., .6);
		}
	}
}