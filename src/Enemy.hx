package ;
import motion.Actuate;
class Enemy extends Entity {
	public static var fade = false;
	var fadeThis : Bool;
	public function new(?animName:String, ?hasShadow=true) {
		super(animName, hasShadow);
		fadeThis = true;
		Game.CUR.lm.addChild(this, Const.ENEMY_L);
	}
	override public function delete() {
		if(fade && fadeThis && roomId != Level.ROOMID) {
			Actuate.tween(this, .5, {alpha: 0.}).onComplete(function() {
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