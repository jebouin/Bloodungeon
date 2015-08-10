package ;
class Action {
	public static function closeExit() {
		Game.CUR.level.replaceLittleLights();
		Game.CUR.level.removeExitLight();
	}
	public static function exitFloor0() {
		Game.CUR.level.nextFloor();
	}
}