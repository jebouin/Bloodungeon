package;
import com.xay.util.Renderer;
import com.xay.util.SceneManager;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.Lib;
import net.hires.debug.Stats;
class Main {
	public static var renderer : Renderer;
	static function main() {
		var stage = Lib.current.stage;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		Const.WID = Std.int(stage.stageWidth / Const.SCALE);
		Const.HEI = Std.int(stage.stageHeight / Const.SCALE);
		renderer = new Renderer(Const.WID, Const.HEI, Const.SCALE);
		var stats = new Stats();
		stage.addChild(stats);
		SceneManager.init();
		SceneManager.add(new Game());
		stage.addEventListener(Event.ENTER_FRAME, update);
	}
	static function update(_) {
		SceneManager.update();
		renderer.update();
	}
}