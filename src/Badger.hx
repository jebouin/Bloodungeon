package ;
class Badger extends Enemy {
	public function new() {
		super("badgerBack", true);
		anim.play();
		xx = 46 * 16 + 23;
		yy = 43;
		cradius = 5;
		friction = 0;
		gravity = 0;
		shadow.alpha *= .7;
	}
	override public function die(?dx:Float=0., ?dy:Float=0.) {
		delete();
		shadow.visible = false;
		Fx.badgerDeath(xx, yy, dx, dy);
		Audio.playSound("explosion");
	}
	override public function update() {
		super.update();
		for(e in Game.CUR.entities) {
			if(e == this) continue;
			if(Type.getClass(e) == Blade) {
				var b = cast(e, Blade);
				if(b.collidesBadger()) {
					b.killBadger(this);
				}
			}
		}
		zz = 2;
		shadow.y += 2;
	}
}