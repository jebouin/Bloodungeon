package ;
import com.xay.util.Input;
import haxe.Timer;
import motion.Actuate;
class Hero extends Entity {
	public var hooverTimer : Int;
	public var spawnX : Float;
	public var spawnY : Float;
	var prevRoomDir : Const.DIR;
	public function new() {
		super("heroIdle");
		/*graphics.beginFill(0xFF0000);
		graphics.drawCircle(0, 0, 8);
		graphics.endFill();*/
		Game.CUR.lm.addChild(this, Const.HERO_L);
		maxSpeed = 2.3;
		collides = true;
		spawnX = 21 * 16 + 8;
		spawnY = 34 * 16 + 8;
		spawn();
		hooverTimer = 0;
		gravity = 0;
		setOrigin(.5, .8);
		prevRoomDir = Const.DIR.UP;
	}
	public function spawn() {
		xx = spawnX;
		yy = spawnY;
		vx = vy = 0;
		visible = true;
		locked = false;
		dead = false;
		scaleX = scaleY = 1;
		parent.removeChild(this);
		Game.CUR.lm.addChild(this, Const.HERO_L);
		//set dir
	}
	override function delete() {
		super.delete();
	}
	override function update() {
		if(locked) return;
		if(Input.keyDown("left")) {
			vx -= speed;
			scaleX = -1;
		}
		if(Input.keyDown("right")) {
			vx += speed;
			scaleX = 1;
		}
		if(Input.keyDown("up")) {
			vy -= speed;
		}
		if(Input.keyDown("down")) {
			vy += speed;
		}
		if(Input.oldKeyDown("action")) {
			jump();
		}
		if(Input.oldKeyDown("suicide")) {
			die();
		}
		super.update();
		var level = Game.CUR.level;
		if(xx > level.posX + Level.RWID * 16 - 8 && prevRoomDir != LEFT) {
			goToNextRoom(RIGHT);
		}
		if(xx < level.posX + 8 && prevRoomDir != RIGHT) {
			goToNextRoom(LEFT);
		}
		if(yy > level.posY + Level.RHEI * 16 - 8 && prevRoomDir != UP) {
			goToNextRoom(DOWN);
		}
		if(yy < level.posY + 8 && prevRoomDir != DOWN) {
			goToNextRoom(UP);
		}
		hooverTimer++;
		zz = 2 + Math.sin(hooverTimer * .2) * 2;
	}
	override public function die() {
		if(dead) return;
		visible = shadow.visible = false;
		dead = true;
		locked = true;
		Timer.delay(function() {
			Game.CUR.onRespawn();
			spawn();
		}, 500);
	}
	public function computeSpawnPos(horizontal:Bool) {
		var tx = Std.int(xx / 16);
		var ty = Std.int(yy / 16);
		var dx = horizontal?1:0;
		var dy = horizontal?0:1;
		var sx = tx, ex = tx;
		var sy = ty, ey = ty;
		while(Game.CUR.level.getCollision(sx, sy) == NONE) {
			sx -= dx;
			sy -= dy;
		}
		while(Game.CUR.level.getCollision(ex, ey) == NONE) {
			ex += dx;
			ey += dy;
		}
		var stx = (sx + ex) * .5;
		var sty = (sy + ey) * .5;
		spawnX = stx * 16 + 8;
		spawnY = sty * 16 + 8;
		if(prevRoomDir == Const.DIR.DOWN) {
			spawnY += 12;
		}
	}
	function goToNextRoom(dir:Const.DIR) {
		prevRoomDir = dir;
		Game.CUR.nextRoom(dir);
	}
}