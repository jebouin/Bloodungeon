package ;
import haxe.Timer;
import motion.Actuate;
class Bow extends Enemy {
	public static var ALL = [];
	public static var timer = 1000;
	var dir : Const.DIR;
	var vertical : Bool;
	var arrow : Arrow;
	public function new(tx:Int, ty:Int, dir:Const.DIR) {
		super(dir == UP ? "bowBackShoot" : (dir == DOWN ? "bowFrontShoot" : "bowSideShoot"), false);
		anim.playing = false;
		this.xx = tx * 16 + 8;
		this.yy = ty * 16 + 7;
		this.dir = dir;
		if(dir == LEFT) {
			scaleX = -1;
			yy += 1;
		} else if(dir == DOWN) {
			xx -= 1;
		} else if(dir == UP) {
			xx -= 1;
		}
		anim.setFrame(4);
		moves = false;
		ALL.push(this);
		update();
	}
	override public function delete() {
		super.delete();
		ALL.remove(this);
	}
	public static function updateAll() {
		if(Game.CUR.hero != null && (Game.CUR.hero.dead || Game.CUR.hero.fell)) return;
		timer++;
		if(timer > 50) {
			shootAll();
			timer = 0;
		}
	}
	public static function shootAll() {
		for(b in ALL) {
			b.shoot();
		}
		if(ALL.length > 0) {
			Audio.playSound("bow");
		}
	}
	public function reload() {
		arrow = new Arrow(xx, yy, dir);
		switch(dir) {
			case LEFT:
				arrow.xx -= 2; arrow.yy += 2;
			case RIGHT:
				arrow.xx += 2; arrow.yy += 2;
			case DOWN:
				arrow.yy += 3;
			case UP:
				arrow.xx += 1; arrow.yy += 1;
		}
		arrow.roomId = roomId;
		Game.CUR.entities.push(arrow);
	}
	public function shoot() {
		anim.loop = false;
		anim.setFrame(0);
		anim.play();
		if(arrow == null) {
			reload();
			Actuate.tween(arrow, 0., {alpha: 1.});
		}
		arrow.shoot();
		arrow = null;
		Timer.delay(function() {
			reload();
		}, 200);
	}
}