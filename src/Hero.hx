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
		xx = Game.CUR.level.posX + Const.WID * .5;
		yy = Game.CUR.level.posY + Const.HEI * .5;
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
		if(xx > level.posX + Level.WID * 16 - 8) {
			level.nextLevel(1, 0);
		}
		if(xx < level.posX + 8) {
			level.nextLevel(-1, 0);
		}
		if(yy > level.posY + Level.HEI * 16 - 8) {
			level.nextLevel(0, 1);
		}
		if(yy < level.posY + 8) {
			level.nextLevel(0, -1);
		}
	}
}