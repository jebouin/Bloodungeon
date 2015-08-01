package ;
import com.xay.util.Input;
class Hero extends Entity {
	public function new() {
		super();
		graphics.beginFill(0xFF0000);
		graphics.drawCircle(0, 0, 8);
		graphics.endFill();
		Game.CUR.lm.addChild(this, Const.HERO_L);
		maxSpeed = 2.3;
		collides = true;
		xx = Game.CUR.level.startX;
		yy = Game.CUR.level.startY;
	}
	override function delete() {
		super.delete();
	}
	override function update() {
		if(locked) return;
		if(Input.keyDown("left")) {
			vx -= speed;
		}
		if(Input.keyDown("right")) {
			vx += speed;
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
		super.update();
		var level = Game.CUR.level;
		if(xx > level.posX + Level.RWID * 16 - 8) {
			level.nextRoom(1, 0);
		}
		if(xx < level.posX + 8) {
			level.nextRoom(-1, 0);
		}
		if(yy > level.posY + Level.RHEI * 16 - 8) {
			level.nextRoom(0, 1);
		}
		if(yy < level.posY + 8) {
			level.nextRoom(0, -1);
		}
	}
}