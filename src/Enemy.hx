package ;
class Enemy extends Entity {
	public function new(?animName:String, ?hasShadow=true) {
		super(animName, hasShadow);
		Game.CUR.lm.addChild(this, Const.ENEMY_L);
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