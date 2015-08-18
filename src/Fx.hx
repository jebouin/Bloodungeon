package ;
import flash.display.BlendMode;
import flash.filters.BlurFilter;
import flash.filters.GlowFilter;
import haxe.Timer;
import motion.Actuate;
class Fx {
	public static function update() {
		Particle.updateAll();
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
}