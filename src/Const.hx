package ;
enum DIR {
	LEFT;
	RIGHT;
	UP;
	DOWN;
}
class Const {
	public static var WID : Int;
	public static var HEI : Int;
	public static var SCALE = 4;
	static var CUR_L = 0;
	public static var VOID_L = CUR_L++;
	public static var BACK_L = CUR_L++;
	public static var SHADOW_L = CUR_L++;
	public static var ENEMY_L = CUR_L++;
	public static var HERO_L = CUR_L++;
	public static var FRONT_L = CUR_L++;
	public static inline function stringToDir(s:String) {
		return (s == "up" ? UP : (s == "down" ? DOWN : (s == "left" ? LEFT : (s == "right" ? RIGHT : null))));
	}
}