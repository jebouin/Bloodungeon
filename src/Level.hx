package ;
import flash.display.Shape;
class Level {
	public function new() {
		var s = new Shape();
		s.graphics.beginFill(0xF0B67F);
		s.graphics.drawRect(0, 0, Const.WID, Const.HEI);
		s.graphics.endFill();
		Game.CUR.lm.addChild(s, Const.BACK_L);
	}
}