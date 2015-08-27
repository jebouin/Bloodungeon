package ;
class Cannon extends Enemy {
	public static var ALL = [];
	public static var timer = 1000;
	var tx : Int;
	var ty : Int;
	var level : Level;
	var diag : Bool;
	public function new(level:Level, tx:Int, ty:Int) {
		super("cannonFront", true);
		setAnim("cannonFront", false);
		this.tx = tx;
		this.ty = ty;
		this.level = level;
		setOrigin(.5, 1);
		xx = tx * 16 + 8;
		yy = ty * 16 + 16;
		moves = false;
		diag = false;
		shadow.alpha = .3;
		update();
		ALL.push(this);
	}
	override public function delete() {
		super.delete();
		ALL.remove(this);
	}
	override public function update() {
		super.update();
	}
	public function shoot() {
		var angle = 0.;
		if(diag) {
			angle += Math.PI * .25;
			setAnim("cannonFront", false);
		} else {
			setAnim("cannonDiag", false);
		}
		anim.play();
		diag = !diag;
		for(i in 0...4) {
			var dx = Math.cos(angle + i * Math.PI * .5);
			var dy = Math.sin(angle + i * Math.PI * .5);
			var sp = 2.;
			var b = new Snowball(xx + dx * 5, yy - 12 + dy * 5, dx * sp, dy * sp);
			b.roomId = roomId;
			Game.CUR.entities.push(b);
		}
	}
	public static function updateAll() {
		if(Game.CUR.hero != null && (Game.CUR.hero.dead || Game.CUR.hero.fell)) return;
		timer++;
		if(timer >= 40) {
			timer = 0;
			if(ALL.length > 0) {
				Audio.playSound("cannon");
			}
			for(c in ALL) {
				c.shoot();
			}
		}
	}
}