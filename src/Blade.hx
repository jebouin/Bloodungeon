package ;
class Blade extends Enemy {
	var level : Level;
	var tx : Int;
	var ty : Int;
	var lastDir : Const.DIR;
	var timer = 0;
	public function new(level:Level, tx:Int, ty:Int, dir:Const.DIR) {
		super("blade", false);
		setOrigin(.5, 1);
		this.tx = tx;
		this.ty = ty;
		lastDir = dir;
		setPos();
		this.level = level;
		anim.stop();
		update();
	}
	function setPos() {
		xx = tx * 16 + 8;
		yy = ty * 16 + 8;
	}
	function moveToNextRail() {
		var dir = null;
		var od = Const.getOpposite(lastDir);
		var canGoForward = false;
		for(d in Const.DIRS) {
			if(d != od) {
				if(level.areRailsConnected(tx, ty, d)) {
					if(d == lastDir) {
						canGoForward = true;
						break;
					} else {
						dir = d;
					}
				}
			}
		}
		if(canGoForward) {
			dir = lastDir;
		} else if(dir == null) {
			dir = od;
		}
		lastDir = dir;
		tx += Const.getDirX(dir);
		ty += Const.getDirY(dir);
		setPos();
	}
	override public function update() {
		if(Game.CUR.level != null) {
			timer++;
			if(timer >= 10) {
				timer = 0;
				moveToNextRail();
			}
			super.update();
		}
	}
}