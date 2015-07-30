package ;
import com.xay.util.Input;
class Hero extends Entity {
	public function new() {
		super();
		graphics.beginFill(0xFF0000);
		graphics.drawCircle(0, 0, 8);
		graphics.endFill();
		Game.CUR.lm.addChild(this, Const.HERO_L);
		maxSpeed = 3.;
	}
	override function delete() {
		super.delete();
	}
	override function update() {
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
	}
}