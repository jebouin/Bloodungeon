package ;
import com.xay.util.Input;
import com.xay.util.LayerManager;
import com.xay.util.SceneManager.Scene;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import haxe.Timer;
import motion.Actuate;
import motion.easing.Linear;
class Pause extends Scene {
	var lm : LayerManager;
	var title : Bitmap;
	var resume : Bitmap;
	var quit : Bitmap;
	var back : Shape;
	var selected : Int;
	public function new() {
		super();
		lm = new LayerManager();
		Main.renderer.addChild(lm.getContainer());
		back = new Shape();
		back.graphics.beginFill(0x0, .8);
		back.graphics.drawRect(0, 0, Const.WID, Const.HEI);
		back.graphics.endFill();
		lm.addChild(back, 0);
		title = new Bitmap(Main.font.getText("paused"));
		title.scaleX = title.scaleY = 2.;
		title.x = Const.WID * .5 - title.width * .5;
		title.y = Const.HEI * .2 - title.height * .5;
		lm.addChild(title, 1);
		resume = new Bitmap(Main.font.getText("resume"));
		resume.x = Const.WID * .5 - resume.width * .5;
		resume.y = Const.HEI * .5;
		lm.addChild(resume, 1);
		quit = new Bitmap(Main.font.getText("quit"));
		quit.x = Const.WID * .5 - quit.width * .5;
		quit.y = Const.HEI * .5 + 16;
		lm.addChild(quit, 1);
		select(0);
	}
	override public function delete() {
		super.delete();
		lm.delete();
	}
	override public function update() {
		super.update();
		if(Input.newKeyPress("up") && selected == 1) {
			select(0);
			Audio.playSound("moveCursor");
		} else if(Input.newKeyPress("down") && selected == 0) {
			select(1);
			Audio.playSound("moveCursor");
		}
		if(Input.newKeyPress("escape") && !Main.secondUpdate) {
			select(0);
			startPressed();
		}
		if(Input.newKeyPress("start") && !Main.secondUpdate) {
			Audio.playSound("select");
			startPressed();
		}
	}
	function exit(?onEnd:Void->Void) {
		delete();
		if(onEnd != null) {
			onEnd();
		}
	}
	function select(id:Int) {
		selected = id;
		if(id == 0) {
			resume.alpha = 1.;
			quit.alpha = .5;
		} else {
			resume.alpha = .5;
			quit.alpha = 1.;
		}
	}
	function startPressed() {
		if(selected == 0) {
			exit();
		} else {
			Timer.delay(function() {
				exit(function() {
					Game.CUR.delete();
				});
			}, 500);
		}
	}
}