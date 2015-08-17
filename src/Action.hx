package ;
class Action {
	public static function closeExit() {
		Game.CUR.level.replaceLittleLights();
		Game.CUR.level.removeExitLight();
	}
	public static function exitFloor0() {
		Game.CUR.level.nextFloor();
	}
	public static function exitFloor1() {
		Game.CUR.level.nextFloor();
	}
	public static function exitFloor2() {
		Game.CUR.level.nextFloor();
	}
	public static function lastRush() {
		Audio.playMusic(4);
	}
}