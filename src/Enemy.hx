package ;
import motion.Actuate;
class Enemy extends Entity {
	public static var fade = false;
	var onHeroKilled : Dynamic;
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
			if(onHeroKilled != null) {
				onHeroKilled();
			}
			killHero(Game.CUR.hero);
		}
	}
	public function collidesHero() {
		return false;
	}
	function killHero(h:Hero) {
		h.die();
	}
}