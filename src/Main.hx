package;
import com.xay.util.BitmapFont;
import com.xay.util.Input;
import com.xay.util.Renderer;
import com.xay.util.SceneManager;
import com.xay.util.SpriteLib;
import flash.display.BitmapData;
import flash.display.StageAlign;
import flash.display.StageQuality;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.Lib;
import flash.ui.Mouse;
import net.hires.debug.Stats;
@:bitmap("res/tileset.png") class TilesetBD extends BitmapData {}
@:bitmap("res/hero.png") class HeroBD extends BitmapData {}
@:bitmap("res/enemies.png") class EnemiesBD extends BitmapData {}
@:bitmap("res/fontTiny.png") class FontTinyBD extends BitmapData {}
class Main {
	public static var renderer : Renderer;
	public static var font : BitmapFont;
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
		Input.addKey("suicide", 82);
		//Mouse.hide();
		Lib.current.stage.addEventListener(MouseEvent.RIGHT_CLICK, function(_) {});
	}
	static function initGFX() {
		SpriteLib.addBD("tileset", new TilesetBD(0, 0));
		SpriteLib.sliceBD("tileset", "tileset", 0, 0, 16, 16);
		SpriteLib.addBD("hero", new HeroBD(0, 0));
		SpriteLib.sliceBD("hero", "hero", 0, 0, 15, 16, 8, 1, 1);
		SpriteLib.addAnim("heroIdle", "hero", "0-7", 3);
		SpriteLib.addBD("enemies", new EnemiesBD(0, 0));
		SpriteLib.sliceBD("enemies", "thwomp", 0, 0, 35, 32, 5, 1);
		SpriteLib.addAnim("thwompIdle", "thwomp", "0", 1);
		SpriteLib.addAnim("thwompCharge", "thwomp", "1-4", 5);
		SpriteLib.sliceBD("enemies", "spike", 0, 33, 16, 26, 7, 1, 1);
		SpriteLib.addAnim("spikeIdle", "spike", "0", 1);
		SpriteLib.addAnim("spikeOut", "spike", "1-6", 4);
		SpriteLib.sliceBD("enemies", "button", 0, 60, 13, 46, 4, 1, 1);
		SpriteLib.addAnim("buttonOut", "button", "0", 1);
		SpriteLib.addAnim("buttonPushed", "button", "1-3", 3);
		SpriteLib.sliceBD("enemies", "door", 0, 107, 16, 27, 3, 1, 1);
		SpriteLib.sliceBD("enemies", "spinnerBase", 0, 135, 19, 21, 1, 1, 1);
		SpriteLib.addAnim("spinnerBase", "spinnerBase", "0", 1);
		SpriteLib.sliceBD("enemies", "spinnerPart", 21, 135, 16, 18, 8, 1, 1);
		SpriteLib.sliceBD("enemies", "bowSide", 16, 161, 12, 17, 5, 1);
		SpriteLib.sliceBD("enemies", "bowFront", 15, 183, 15, 14, 5, 1);
		SpriteLib.sliceBD("enemies", "bowBack", 15, 197, 15, 12, 5, 1);
		SpriteLib.addAnim("bowSideShoot", "bowSide", "0-4", 5);
		SpriteLib.addAnim("bowFrontShoot", "bowFront", "0-4", 5);
		SpriteLib.addAnim("bowBackShoot", "bowBack", "0-4", 5);
		SpriteLib.sliceBD("enemies", "arrow", 0, 161, 14, 7, 1, 8, 1);
		SpriteLib.addAnim("arrowFlying", "arrow", "0-3", 4);
		SpriteLib.addAnim("arrowHit", "arrow", "3-7", 2);
		SpriteLib.addAnim("arrowIdle", "arrow", "7", 1);
		SpriteLib.sliceBD("enemies", "fire", 0, 229, 14, 20, 5, 1);
		SpriteLib.addAnim("fire", "fire", "0-4", 3);
		font = new BitmapFont(new FontTinyBD(0, 0), 5, 5);
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
		stats.y = stage.stageHeight - 100;
		stage.addChild(stats);
		initInput();
		initGFX();
		Audio.init();
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