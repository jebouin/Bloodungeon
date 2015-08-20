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
import flash.display.Sprite;
import flash.filters.BlurFilter;
import haxe.Timer;
import motion.Actuate;
import motion.easing.Cubic;
import motion.easing.Linear;
import motion.easing.Quad;
class Menu extends Scene {
	public static var CUR : Menu;
	public var lm : LayerManager;
	var selectedOption : Int;
	var selectedMode : Int;
	var back : JungleBack;
	var texts : Array<Bitmap>;
	var normalMode : Bitmap;
	var yoloMode : Bitmap;
	var backMode : Bitmap;
	var skipText : Bitmap;
	var skippedText : Bitmap;
	var textContainer : Sprite;
	var isDown : Bool;
	var isInSpace : Bool;
	var isInDungeon : Bool;
	var started : Bool;
	var transition : Bool;
	var startTimer : Timer;
	public function new() {
		CUR = this;
		super();
		Audio.playMusic(5);
		lm = new LayerManager();
		Main.renderer.addChild(lm.getContainer());
		back = new JungleBack();
		textContainer = new Sprite();
		textContainer.x = textContainer.y = 0;
		lm.addChild(textContainer, 1);
		texts = [];
		for(i in 0...4) {
			var strs = ["new game", "continue", "achievements", "stats"];
			var bmp = new Bitmap(Main.font.getText(strs[i]));
			bmp.y = Const.HEI * .2 + i * 17;
			bmp.x = Const.WID * .5 - bmp.width * .5;
			textContainer.addChild(bmp);
			texts.push(bmp);
		}
		normalMode = new Bitmap(Main.font.getText("normal mode"));
		normalMode.x = Const.WID * 9. / 12. - normalMode.width *.5;
		normalMode.y = Const.HEI * .5 - 10;
		yoloMode = new Bitmap(Main.font.getText("yolo mode"));
		yoloMode.x = Const.WID * 9. / 12. - yoloMode.width * .5;
		yoloMode.y = Const.HEI * .5 + 10;
		backMode = new Bitmap(Main.font.getText("back"));
		backMode.x = Const.WID * 9. / 12. - backMode.width * .5;
		backMode.y = Const.HEI * .5 + 20;
		normalMode.visible = yoloMode.visible = backMode.visible = false;
		lm.addChild(normalMode, 1);
		lm.addChild(yoloMode, 1);
		lm.addChild(backMode, 1);
		skipText = new Bitmap(Main.font.getText("skip story? (s)"));
		skipText.scaleX = skipText.scaleY = 1.;
		skipText.x = Const.WID * .5 - skipText.width * .5;
		skipText.y = Const.HEI * .5 - skipText.height * .5;
		skipText.visible = false;
		skippedText = new Bitmap(Main.font.getText("story skipped"));
		skippedText.scaleX = skippedText.scaleY = 1.;
		skippedText.x = Const.WID * .5 - skippedText.width * .5;
		skippedText.y = Const.HEI * .5 - skippedText.height * .5;
		skippedText.visible = false;
		lm.addChild(skipText, 1);
		lm.addChild(skippedText, 1);
		selectedOption = 0;
		//onFocusLoss = quit;
		updateOptions();
		isDown = false;
		isInDungeon = false;
		transition = false;
		
		/*started = false;
		startTransition();*/
		
		started = true;
	}
	function startTransition() {
		back.startTransition();
		textContainer.y = Const.HEI;
		Timer.delay(function() {
			Actuate.tween(textContainer, 1.2, {y:0}).ease(Quad.easeOut).onComplete(function() {
				started = true;
			});
		}, 4800);
	}
	override public function delete() {
		super.delete();
		lm.delete();
	}
	override public function update() {
		super.update();
		if(started && !transition) {
			if(!isDown) {
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
			} else if(!isInDungeon) {
				if(Input.newKeyPress("down") && selectedMode < 2) {
					selectMode(selectedMode+1);
				}
				if(Input.newKeyPress("up") && selectedMode > 0) {
					selectMode(selectedMode-1);
				}
				if(Input.newKeyPress("start")) {
					startPressed();
				} else if(Input.newKeyPress("escape")) {
					selectMode(2);
					startPressed();
				}
			} else {
				if(Input.newKeyPress("skip")) {
					startGameWithoutStory();
				}
			}
		}
		back.update();
	}
	function startPressed() {
		if(isDown) {
			if(selectedMode == 0) {
				goInDungeon();
			} else if(selectedMode == 1) {
				goInDungeon(true);
			} else if(selectedMode == 2) {
				goUp();
			}
		} else if(!isInDungeon) {
			if(selectedOption == 0) {
				goDown();
			} else if(selectedOption == 1) {
				goDown();
			} else if(selectedOption == 2) {
				new AchievementMenu();
			} else if(selectedOption == 3) {
				new StatsMenu();
			}
		}
	}
	function updateOptions() {
		for(t in texts) {
			t.alpha = .5;
		}
		for(i in 0...texts.length) {
			if(i == selectedOption) {
				var t = texts[i];
				t.alpha = 1.;
			}
		}
	}
	function selectMode(id:Int) {
		selectedMode = id;
		normalMode.alpha = yoloMode.alpha = backMode.alpha = .5;
		if(id == 0) {
			normalMode.alpha = 1.;
		} else if(id == 1) {
			yoloMode.alpha = 1.;
		} else {
			backMode.alpha = 1.;
		}
	}
	function goDown() {
		if(isDown) {
			return;
		}
		transition = true;
		isDown = true;
		selectMode(0);
		back.goDown();
		Actuate.tween(textContainer, 1.6, {y:-Const.HEI}).ease(Quad.easeIn);
		normalMode.visible = yoloMode.visible = backMode.visible = true;
		normalMode.y = Const.HEI * .5 + Const.HEI;
		yoloMode.y = Const.HEI * .5 + 20 + Const.HEI;
		backMode.y = Const.HEI * .5 + 40 + Const.HEI;
		yoloMode.alpha = normalMode.alpha = backMode.alpha = .5;
		normalMode.alpha = 1.;
		Timer.delay(function() {
			Actuate.tween(normalMode, 1., {y:Const.HEI * .5 + 10}).ease(Quad.easeIn);
			Actuate.tween(yoloMode, 1., {y:Const.HEI * .5 + 25}).ease(Quad.easeIn);
			Actuate.tween(backMode, 1., {y:Const.HEI * .5 + 40}).ease(Quad.easeIn);
		}, 1000);
		Timer.delay(function() {
			transition = false;
		}, 2000);
	}
	function goUp() {
		if(!isDown) {
			return;
		}
		back.goUp();
		Timer.delay(function() {
			Actuate.tween(textContainer, 1., {y:0}).ease(Quad.easeIn);
		}, 1000);
		Actuate.tween(normalMode, 1.6, {y:Const.HEI * .5 + Const.HEI + 10}).ease(Quad.easeIn);
		Actuate.tween(yoloMode, 1.6, {y:Const.HEI * .5 + Const.HEI + 25}).ease(Quad.easeIn);
		Actuate.tween(backMode, 1.6, {y:Const.HEI * .5 + Const.HEI + 40}).ease(Quad.easeIn).onComplete(function() {
			normalMode.visible = yoloMode.visible = backMode.visible = false;
		});
		isDown = false;
		transition = true;
		Timer.delay(function() {
			transition = false;
		}, 2000);
	}
	function hide() {
		var filter = new BlurFilter(0, 0, 3);
		var c = lm.getContainer();
		Actuate.tween(filter, .5, {blurX:5., blurY:5.}).onUpdate(function() {
			c.filters = [filter];
		});
	}
	public static function removeBlur() {
		if(CUR == null) return;
		var filter = new BlurFilter(5., 5., 3);
		var c = CUR.lm.getContainer();
		Actuate.tween(filter, .5, {blurX:0., blurY:0.}).onUpdate(function() {
			c.filters = [filter];
		}).onComplete(function() {
			c.filters = [];
		});
	}
	function quit() {
		lm.getContainer().visible = false;
	}
	function resume() {
		leaveDungeon();
		lm.getContainer().visible = true;
	}
	function goInDungeon(?yolo:Bool=false) {
		if(!isDown) return;
		if(isInDungeon) return;
		isInDungeon = true;
		transition = true;
		back.goInDungeon();
		Actuate.tween(normalMode, .3, {x:Const.WID+10});
		Actuate.tween(yoloMode, .3, {x:Const.WID+10});
		Actuate.tween(backMode, .3, {x:Const.WID+10}).onComplete(function() {
			normalMode.visible = yoloMode.visible = backMode.visible = false;
		});
		Timer.delay(function() {
			transition = false;
			if(yolo) {
				Game.skipStory = Game.yoloMode = true;
				startGame();
			} else {
				Game.skipStory = Game.yoloMode = false;
				skipText.visible = true;
				skipText.alpha = 1.;
				Timer.delay(function() {
					Actuate.tween(skipText, 2., {alpha: 0}).ease(Linear.easeNone);
				}, 1500);
				startTimer = Timer.delay(function() {
					startGame();
				}, 3500);
			}
		}, yolo ? 400 : 1300);
	}
	function leaveDungeon() {
		if(!isInDungeon || transition) return;
		isInDungeon = false;
		isDown = false;
		skippedText.visible = normalMode.visible = yoloMode.visible = backMode.visible = false;
		normalMode.x = Const.WID * 9. / 12. - normalMode.width * .5;
		yoloMode.x = Const.WID * 9. / 12. - yoloMode.width * .5;
		backMode.x = Const.WID * 9. / 12. - backMode.width * .5;
		textContainer.visible = true;
		textContainer.y = 0;
		selectMode(0);
		back.leaveDungeon();
	}
	function startGame() {
		if(startTimer != null) {
			startTimer.stop();
			startTimer = null;
		}
		Actuate.stop(skipText);
		skipText.visible = false;
		transition = false;
		quit();
		var g = new Game();
		g.onDelete = resume;
	}
	function startGameWithoutStory() {
		Game.skipStory = true;
		skipText.visible = false;
		Timer.delay(function() {
			startGame();
		}, 950);
		skippedText.visible = true;
		for(i in 0...9) {
			Timer.delay(function() {
				skippedText.visible = false;
			}, i*100 + 50);
			Timer.delay(function() {
				skippedText.visible = true;
			}, i*100 + 100);
		}
	}
}