//bloodungeon
//new game
//continue
//achievements
//stats
//todo: change for continue game
package ;
import com.xay.util.Input;
import com.xay.util.LayerManager;
import com.xay.util.SceneManager;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
class Menu extends Scene {
	public static var CUR : Menu;
	public var lm : LayerManager;
	var selectedOption : Int;
	var back : JungleBack;
	var texts : Array<Bitmap>;
	public function new() {
		CUR = this;
		super();
		lm = new LayerManager();
		Main.renderer.addChild(lm.getContainer());
		back = new JungleBack();
		texts = [];
		for(i in 0...4) {
			var strs = ["new game", "continue", "achievements", "stats"];
			var bmp = new Bitmap(Main.font.getText(strs[i]));
			bmp.y = Const.HEI * .2 + i * 17;
			bmp.x = Const.WID * .5 - bmp.width * .5;
			lm.addChild(bmp, 1);
			texts.push(bmp);
		}
		onFocusGain = show;
		onFocusLoss = hide;
		selectedOption = 0;
		updateOptions();
	}
	override public function delete() {
		super.delete();
		lm.delete();
	}
	override public function update() {
		super.update();
		var optionChanged = false;
		if(Input.newKeyPress("down") && selectedOption < texts.length - 1) {
			selectedOption++;
			optionChanged = true;
		}
		if(Input.newKeyPress("up") && selectedOption > 0) {
			selectedOption--;
			optionChanged = true;
		}
		if(optionChanged) {
			updateOptions();
		}
		if(Input.newKeyPress("start")) {
			startPressed();
		}
		back.update();
	}
	function startPressed() {
		if(selectedOption == 0) {
			new Game();
		} else if(selectedOption == 1) {
			new Game();
		} else if(selectedOption == 2) {
			new AchievementMenu();
		} else if(selectedOption == 3) {
			new StatsMenu();
		}
	}
	function updateOptions() {
		for(t in texts) {
			t.alpha = .7;
		}
		for(i in 0...texts.length) {
			if(i == selectedOption) {
				var t = texts[i];
				t.alpha = 1.;
			}
		}
	}
	function hide() {
		lm.getContainer().visible = false;
	}
	function show() {
		lm.getContainer().visible = true;
	}
}