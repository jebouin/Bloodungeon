package ;
import haxe.Timer;
class Action {
	public static function shake0() {
		Fx.screenShake(1., 1., 1000000., true);
		Timer.delay(function() {
			Game.CUR.hero.say("wtf", 100);
		}, 400);
	}
	public static function shake1() {
		Fx.screenShake(2., 2., 1000000., true);
		Timer.delay(function() {
			Game.CUR.hero.say("!!!", 100);
		}, 300);
	}
	public static function closeExit() {
		Game.CUR.level.closeExit();
	}
	public static function exitFloor0() {
		Game.CUR.nextFloor();
	}
	public static function exitFloor1() {
		var h = Game.CUR.hero;
		if(h.nbDeaths == h.nbDeathBeforeFloor) {
			Achievements.unlock("Phrygian warrior");
		}
		Game.CUR.nextFloor();
	}
	public static function exitFloor2() {
		var h = Game.CUR.hero;
		if(h.nbDeaths == h.nbDeathBeforeFloor) {
			Achievements.unlock("Icy hell");
		}
		Game.CUR.nextFloor();
	}
	public static function lastRush() {
		Game.CUR.startRush();
	}
}