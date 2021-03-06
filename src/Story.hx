package ;
import com.xay.util.Input;
import com.xay.util.Util;
class Story {
	public static var state = 0;
	public static var timer = 0;
	public static var totalTime = 0;
	public static var active = false;
	public static var actions = new Array<{t:Int, f:Void->Void, w:Bool}>();
	public static var talkExit = false;
	public static var talkTimer = 0;
	public static function init() {
		actions = [];
		totalTime = 0;
		addAction(0, sayHero.bind("alright...", -1), false);
		addAction(-1, sayHero.bind("I'm in.", -1), true);
		addAction(50, nothing, true);
		addAction(0, sayHero.bind("So his best time is 42 seconds...", -1), false);
		addAction(-1, sayHero.bind("I'll do waaay better.", -1), true);
		addAction(0, nothing, true);
	}
	static function addAction(t:Int, f:Void->Void, w:Bool) {
		actions.push({t:t==-1?t:totalTime, f:f, w:w});
		if(t > 0) {
			totalTime += t;
		}
	}
	public static function start() {
		state = 0;
		timer = 0;
		active = true;
		talkExit = false;
		Game.canPause = false;
		talkTimer = 0;
	}
	public static function disable() {
		active = false;
	}
	public static function update() {
		if(talkExit) {
			doTalkExit();
		}
		if(!active) return;
		if(state >= actions.length) {
			if(!Game.canPause) {
				Game.canPause = true;
				active = false;
			}
			return;
		}
		if(actions[state].w) {
			if(Input.newKeyPress("start")) {
				actions[state].f();
				state++;
			}
		} else {
			if(timer == actions[state].t) {
				actions[state].f();
				state++;
			}
			timer++;
		}
	}
	public static function sayHero(str:String, t:Int) {
		Game.CUR.hero.say(str, t);
	}
	public static function nothing() {
		
	}
	static function doTalkExit() {
		talkTimer++;
		if(talkTimer > 40 && Std.random(20) == 0) {
			talkTimer = 0;
			var x = 41 * 16 + Util.randFloat(-8, 8) + 3;
			var y = Util.randFloat(30 * 16, 34 * 16);
			Dialog.say(x, y, ["c'mon!", "faster!", "go!", "!!!", "almost there!"][Std.random(5)], 40);
		}
	}
}