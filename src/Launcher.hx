package ;
class Launcher extends Enemy {
	public static var timer = 40;
	static var ALL : Array<Launcher> = [];
	public function new(tx:Int, ty:Int, facesRight:Bool) {
		super("launcherIdle", false);
		anim.stop();
		setOrigin(0, .5);
		xx = tx * 16;
		yy = ty * 16 + 16;
		if(!facesRight) {
			scaleX = -1;
			xx += 16;
		}
		parent.removeChild(this);
		Game.CUR.lm.addChild(this, Const.HERO_L);
		ALL.push(this);
	}
	override public function delete() {
		ALL.remove(this);
	}
	override public function update() {
		super.update();
	}
	function shoot() {
		setAnim("launcherShoot", false);
		anim.play();
		var r = new Rocket(xx + scaleX * 20, yy, scaleX < 0 ? 180 : 0);
		r.roomId = this.roomId;
		Game.CUR.entities.push(r);
	}
	public static function updateAll() {
		timer++;
		if(timer >= 80) {
			timer = 0;
			for(l in ALL) {
				l.shoot();
			}
		}
	}
}