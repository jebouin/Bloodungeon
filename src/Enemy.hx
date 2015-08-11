package ;
import motion.Actuate;
class Enemy extends Entity {
	public static var fade = false;
	public function new(?animName:String, ?hasShadow=true) {
		super(animName, hasShadow);
		Game.CUR.lm.addChild(this, Const.ENEMY_L);
	}
	override public function delete() {
		if(fade) {
			Actuate.tween(this, .8, {alpha: 0.}).onComplete(function() {
				onFadeComplete();
			});
		} else {
			super.delete();
		}
	}
	function onFadeComplete() {
		super.delete();
	}
	override public function update() {
		super.update();
		if(collidesHero()) {
			Game.CUR.hero.die();
		}
	}
	public function collidesHero() {
		return false;
	}
}