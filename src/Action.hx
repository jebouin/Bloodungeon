package ;
class Action {
	public static function closeExit() {
		Game.CUR.level.replaceLittleLights();
		Game.CUR.level.removeExitLight();
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
		Audio.playMusic(4);
	}
}