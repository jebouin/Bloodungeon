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
class GameOver extends Scene {
	var lm : LayerManager;
	var title : Bitmap;
	var retry : Bitmap;
	var quit : Bitmap;
	var back : Shape;
	var selected : Int;
	var active : Bool;
	public function new() {
		super();
		lm = new LayerManager();
		Main.renderer.addChild(lm.getContainer());
		back = new Shape();
		back.graphics.beginFill(0x0, .8);
		back.graphics.drawRect(0, 0, Const.WID, Const.HEI);
		back.graphics.endFill();
		lm.addChild(back, 0);
		title = new Bitmap(Main.font.getText("GAME OVER"));
		title.scaleX = title.scaleY = 2.;
		title.x = Const.WID * .5 - title.width * .5;
		title.y = Const.HEI * .2 - title.height * .5;
		lm.addChild(title, 1);
		retry = new Bitmap(Main.font.getText("retry"));
		retry.x = Const.WID * .5 - retry.width * .5;
		retry.y = Const.HEI * .5;
		lm.addChild(retry, 1);
		quit = new Bitmap(Main.font.getText("quit"));
		quit.x = Const.WID * .5 - quit.width * .5;
		quit.y = Const.HEI * .5 + 16;
		lm.addChild(quit, 1);
		select(0);
		active = false;
		lm.getContainer().alpha = 0.;
		Actuate.tween(lm.getContainer(), 1., {alpha: 1.}).ease(Linear.easeNone);
		Timer.delay(function() {
			active = true;
		}, 600);
		Audio.stopMusics(2.);
	}
	override public function delete() {
		super.delete();
		lm.delete();
	}
	override public function update() {
		super.update();
		if(!active) return;
		if(Input.newKeyPress("up") && selected == 1) {
			select(0);
			Audio.playSound("moveCursor");
		} else if(Input.newKeyPress("down") && selected == 0) {
			select(1);
			Audio.playSound("moveCursor");
		}
		if(Input.newKeyPress("start")) {
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
			retry.alpha = 1.;
			quit.alpha = .5;
		} else {
			retry.alpha = .5;
			quit.alpha = 1.;
		}
	}
	function startPressed() {
		if(selected == 0) {
			Timer.delay(function() {
				exit(function() {
					Save.onStartGame();
					new Game();
				});
			}, 500);
		} else {
			Timer.delay(function() {
				exit(function() {
					
				});
			}, 500);
		}
	}
}