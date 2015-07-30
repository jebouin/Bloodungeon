package;
import com.xay.util.Input;
import com.xay.util.Renderer;
import com.xay.util.SceneManager;
import com.xay.util.SpriteLib;
import flash.display.BitmapData;
import flash.display.StageAlign;
import flash.display.StageQuality;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.Lib;
import net.hires.debug.Stats;
@:bitmap("res/tileset.png") class TilesetBD extends BitmapData {}
class Main {
	public static var renderer : Renderer;
	static function initInput() {
		Input.init();
		Input.addKey("left", 65);
		Input.addKey("left", 37);
		Input.addKey("right", 68);
		Input.addKey("right", 39);
		Input.addKey("up", 87);
		Input.addKey("up", 38);
		Input.addKey("down", 83);
		Input.addKey("down", 40);
		Input.addKey("action", 32);
	}
	static function initGFX() {
		SpriteLib.init();
		SpriteLib.addBD(new TilesetBD(0, 0));
		SpriteLib.setBD(0);
		SpriteLib.sliceFrameSet("tileset", 0, 0, 16, 16, 16, 16);
	}
	static function main() {
		var stage = Lib.current.stage;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.quality = StageQuality.BEST;
		stage.align = StageAlign.TOP_LEFT;
		Const.WID = Std.int(stage.stageWidth / Const.SCALE);
		Const.HEI = Std.int(stage.stageHeight / Const.SCALE);
		renderer = new Renderer(Const.WID, Const.HEI, Const.SCALE);
		var stats = new Stats();
		stats.x = stage.stageWidth - Stats.XPOS;
		stage.addChild(stats);
		initInput();
		initGFX();
		SceneManager.init();
		SceneManager.add(new Game());
		stage.addEventListener(Event.ENTER_FRAME, update);
	}
	static function update(_) {
		SceneManager.update();
		renderer.update();
		Input.update();
	}
}