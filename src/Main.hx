package;
import com.xay.util.BitmapFont;
import com.xay.util.Input;
import com.xay.util.Renderer;
import com.xay.util.SceneManager;
import com.xay.util.SpriteLib;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageQuality;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.Lib;
import flash.ui.Mouse;
import motion.Actuate;
import motion.easing.Cubic;
import net.hires.debug.Stats;
@:bitmap("res/tileset.png") class TilesetBD extends BitmapData {}
@:bitmap("res/hero.png") class HeroBD extends BitmapData {}
@:bitmap("res/enemies.png") class EnemiesBD extends BitmapData {}
@:bitmap("res/fontTiny.png") class FontTinyBD extends BitmapData {}
class Main {
	public static var renderer : Renderer;
	public static var font : BitmapFont;
	public static var is60FPS : Bool;
	public static var secondUpdate : Bool;
	public static var hasFocus = true;
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
		Input.addKey("start", 13);
		Input.addKey("start", 32);
		Input.addKey("mute", 77);
		Input.addKey("fps", 70);
		Input.addKey("escape", 27);
		Input.addKey("suicide", 82);
		Input.addKey("skip", 83);
		//Mouse.hide();
		Lib.current.stage.addEventListener(MouseEvent.RIGHT_CLICK, function(_) {});
		Lib.current.addEventListener(Event.DEACTIVATE, onFocusOut);
		Lib.current.addEventListener(Event.ACTIVATE, onFocusIn);
	}
	static function initGFX() {
		SpriteLib.addBD("tileset", new TilesetBD(0, 0));
		SpriteLib.sliceBD("tileset", "tileset", 0, 0, 16, 16);
		SpriteLib.addBD("hero", new HeroBD(0, 0));
		SpriteLib.sliceBD("hero", "hero", 0, 0, 15, 16, 8, 1, 1);
		SpriteLib.addAnim("heroIdle", "hero", "0-7", 3);
		SpriteLib.sliceBD("hero", "heroHead", 0, 19, 9, 8, 1, 1);
		SpriteLib.addBD("enemies", new EnemiesBD(0, 0));
		SpriteLib.sliceBD("enemies", "thwomp", 0, 0, 35, 32, 5, 1);
		SpriteLib.addAnim("thwompIdle", "thwomp", "0", 1);
		SpriteLib.addAnim("thwompCharge", "thwomp", "1-4", 5);
		SpriteLib.sliceBD("enemies", "spike", 0, 33, 16, 26, 7, 1, 1);
		SpriteLib.addAnim("spikeIdle", "spike", "0", 1);
		SpriteLib.addAnim("spikeOut", "spike", "1-6", 3);
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
		SpriteLib.sliceBD("enemies", "xana", 0, 416, 14, 21, 1, 1);
		SpriteLib.addAnim("xana", "xana", "0", 1);
		SpriteLib.sliceBD("enemies", "sideSpike", 0, 251, 16, 16, 5, 5);
		SpriteLib.sliceBD("enemies", "frontSpike", 0, 331, 16, 28, 5, 3);
		SpriteLib.sliceBD("enemies", "cannon", 0, 443, 18, 18, 4, 1);
		SpriteLib.addAnim("cannonFront", "cannon", "0,3", 30);
		SpriteLib.addAnim("cannonDiag", "cannon", "2,1", 30);
		SpriteLib.sliceBD("enemies", "snowball", 0, 462, 12, 12, 4, 1);
		SpriteLib.addAnim("snowball", "snowball", "0-3", 3);
		SpriteLib.sliceBD("enemies", "snowsplash", 0, 475, 5, 16, 3, 1);
		SpriteLib.addAnim("snowsplash", "snowsplash", "0-2", 3);
		SpriteLib.sliceBD("enemies", "blade", 188, 4, 21, 22, 4, 1, 1);
		SpriteLib.addAnim("bladeLeft", "blade", "0,1", 2);
		SpriteLib.addAnim("bladeRight", "blade", "0,1", 2);
		SpriteLib.addAnim("bladeDown", "blade", "2,3", 2);
		SpriteLib.addAnim("bladeUp", "blade", "2,3", 2);
		SpriteLib.sliceBD("enemies", "tesla", 184, 29, 10, 10, 6, 1);
		SpriteLib.addAnim("teslaIdle", "tesla", "0-5", 2);
		SpriteLib.addAnim("teslaCharge", "tesla", "0-5", 2);
		SpriteLib.sliceBD("enemies", "launcher", 85, 242, 32, 36, 4, 1);
		SpriteLib.addAnim("launcherIdle", "launcher", "3", 30);
		SpriteLib.addAnim("launcherShoot", "launcher", "0-3", 5);
		SpriteLib.sliceBD("enemies", "rocket", 227, 252, 19, 16, 1, 1);
		SpriteLib.addAnim("rocket", "rocket", "0", 60);
		SpriteLib.sliceBD("enemies", "explosion", 63, 466, 32, 32, 5, 1);
		SpriteLib.addAnim("explosion", "explosion", "0-4", 1);
		
		SpriteLib.addAnim("spikeRightIdle", "sideSpike", "2,3,4,3", 10);
		SpriteLib.addAnim("spikeLeftIdle", "sideSpike", "7,8,9,8", 10);
		SpriteLib.addAnim("spikeDownIdle", "sideSpike", "12,13,14,13", 10);
		SpriteLib.addAnim("spikeDownRightIdle", "sideSpike", "17,18,19,18", 10);
		SpriteLib.addAnim("spikeDownLeftIdle", "sideSpike", "22,23,24,23", 10);
		SpriteLib.addAnim("spikeUpIdle", "frontSpike", "2,3,4,3", 10);
		SpriteLib.addAnim("spikeUpLeftIdle", "frontSpike", "7,8,9,8", 10);
		SpriteLib.addAnim("spikeUpRightIdle", "frontSpike", "12,13,14,13", 10);
		
		SpriteLib.addAnim("spikeRightOut", "sideSpike", "0-3", 5);
		SpriteLib.addAnim("spikeLeftOut", "sideSpike", "5-8", 5);
		SpriteLib.addAnim("spikeDownOut", "sideSpike", "10-13", 5);
		SpriteLib.addAnim("spikeDownRightOut", "sideSpike", "15-18", 5);
		SpriteLib.addAnim("spikeDownLeftOut", "sideSpike", "20-23", 5);
		SpriteLib.addAnim("spikeUpOut", "frontSpike", "0-3", 5);
		SpriteLib.addAnim("spikeUpLeftOut", "frontSpike", "5-8", 5);
		SpriteLib.addAnim("spikeUpRightOut", "frontSpike", "10-13", 5);
		font = new BitmapFont(new FontTinyBD(0, 0), 5, 5);
	}
	static function main() {
		var stage = Lib.current.stage;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.quality = StageQuality.BEST;
		stage.align = StageAlign.TOP_LEFT;
		is60FPS = true;
		renderer = new Renderer(Const.WID, Const.HEI, Const.SCALE);
		var stats = new Stats();
		stats.x = stage.stageWidth - Stats.XPOS;
		stats.y = stage.stageHeight - 100;
		//stage.addChild(stats);
		initGFX();
		initInput();
		Audio.init();
		Achievements.init();
		SceneManager.init();
		Save.init();
		Story.init();
		
		/*Game.skipStory = true;
		Game.continueGame = false;
		Game.yoloMode = false;
		new Game();*/
		
		new Menu();
		stage.addEventListener(Event.ENTER_FRAME, update);
	}
	static function update(_) {
		if(hasFocus) {
			secondUpdate = false;
			SceneManager.update();
			if(!is60FPS) {
				secondUpdate = true;
				SceneManager.update();
			}
			if(Input.keyDown("mute") && !Input.oldKeyDown("mute")) {
				Audio.mute();
			}
			if(Input.keyDown("fps") && !Input.oldKeyDown("fps")) {
				changeFPS();
			}
			renderer.update();
			Input.update();
		}
	}
	public static function announce(str:String) {
		var text = new Bitmap(font.getText(str));
		text.scaleX = text.scaleY = 2.;
		text.x = Std.int(Const.WID * .5 - text.width * .5);
		text.y = Std.int(Const.HEI - text.height - 10);
		renderer.addChild(text);
		text.filters = [new DropShadowFilter(0, 0, 0x0, .4, 50., 10., 10., 3)];
		Actuate.tween(text, 1., {alpha: 0.}).onComplete(function() {
			text.parent.removeChild(text);
		}).ease(Cubic.easeIn);
	}
	public static function changeFPS() {
		if(is60FPS) {
			is60FPS = false;
			announce("30 fps");
			Lib.current.stage.frameRate = 30;
		} else {
			is60FPS = true;
			announce("60 fps");
			Lib.current.stage.frameRate = 60;
		}
	}
	static function onFocusOut(_) {
		if(!hasFocus) return;
		hasFocus = false;
		Audio.onFocusOut();
		if(Game.CUR != null) {
			Game.CUR.onFocusOut();
		}
		renderer.update();
	}
	static function onFocusIn(_) {
		if(hasFocus) return;
		hasFocus = true;
		Audio.onFocusIn();
		if(Game.CUR != null) {
			Game.CUR.onFocusIn();
		}
	}
}