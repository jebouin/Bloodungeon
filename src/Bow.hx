package ;
class Bow extends Enemy {
	public static var ALL = [];
	public static var timer = 1000;
	var dir : Const.DIR;
	var vertical : Bool;
	public function new(tx:Int, ty:Int, dir:Const.DIR) {
		vertical = (dir == UP || dir == DOWN);
		vertical = false;
		super(vertical ? "bowFrontIdle" : "bowSideIdle", false);
		this.xx = tx * 16 + 8;
		this.yy = ty * 16 + 7;
		this.dir = dir;
		if(dir == LEFT) {
			scaleX = -1;
			yy += 1;
		}
		if(dir == DOWN) {
			xx -= 1;
		}
		ALL.push(this);
	}
	override public function delete() {
		super.delete();
		ALL.remove(this);
	}
	public static function updateAll() {
		timer++;
		if(timer > 70) {
			shootAll();
			timer = 0;
		}
	}
	public static function shootAll() {
		for(b in ALL) {
			b.shoot();
		}
	}
	public function shoot() {
		var a = new Arrow(xx, yy, dir);
		a.roomId = roomId;
		Game.CUR.entities.push(a);
	}
}