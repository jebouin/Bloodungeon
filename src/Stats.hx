package ;
import com.xay.util.Input;
import com.xay.util.LayerManager;
import com.xay.util.SceneManager;
import com.xay.util.SceneManager.Scene;
import flash.display.Bitmap;
import haxe.Timer;
class Stats extends Scene {
	public static var totalDeaths : Int;
	public static var gameTime : Int;
	var lm : LayerManager;
	var title : Bitmap;
	var totalDeathsText : Bitmap;
	var gameTimeText : Bitmap;
	var exiting : Bool;
	public function new() {
		super();
		lm = new LayerManager();
		Main.renderer.addChild(lm.getContainer());
		title = new Bitmap(Main.font.getText("stats"));
		title.scaleX = title.scaleY = 2.;
		title.x = Const.WID * .5 - title.width * .5;
		title.y = 25;
		lm.addChild(title, 0);
		totalDeathsText = new Bitmap(Main.font.getText("total deaths: " + Std.string(totalDeaths)));
		totalDeathsText.x = Const.WID * .5 - totalDeathsText.width * .5;
		totalDeathsText.y = Const.HEI * .5 - totalDeathsText.height * .5;
		lm.addChild(totalDeathsText, 0);
		var str = "total game time: ";
		var ss = "";
		var t = Std.int(gameTime / 60);
		ss += Std.int(t / 3600);
		ss = StringTools.lpad(ss, "0", 2);
		str += ss + ":";
		ss = Std.string(Std.int((t % 3600) / 60));
		ss = StringTools.lpad(ss, "0", 2);
		str += ss + ":";
		ss = Std.string(Std.int(t % 60));
		ss = StringTools.lpad(ss, "0", 2);
		str += ss;
		gameTimeText = new Bitmap(Main.font.getText(str));
		gameTimeText.x = Const.WID * .5 - gameTimeText.width * .5;
		gameTimeText.y = Const.HEI * .6 - gameTimeText.height * .5;
		lm.addChild(gameTimeText, 0);
		exiting = false;
	}
	override public function delete() {
		super.delete();
		lm.delete();
	}
	override public function update() {
		super.update();
		if(Input.newKeyPress("start")) {
			delayExit();
		}
	}
	function delayExit() {
		if(exiting) return;
		exiting = true;
		Menu.removeBlur();
		Timer.delay(function() {
			delete();
		}, 200);
	}
}