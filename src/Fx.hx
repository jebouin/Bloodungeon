package ;
import flash.display.BlendMode;
import flash.filters.GlowFilter;
import motion.Actuate;
class Fx {
	public static function update() {
		Particle.updateAll();
	}
	public static function test() {
		var p = new Particle();
		p.drawRect(8, 8, 0xFF0000);
		p.x = -Game.CUR.lm.getContainer().x + Std.random(Const.WID);
		p.y = -Game.CUR.lm.getContainer().y + Std.random(Const.HEI);
		p.blendMode = BlendMode.ADD;
		Actuate.tween(p, .9, {alpha:0.}).onComplete(function() {
			p.delete();
		});
	}
}