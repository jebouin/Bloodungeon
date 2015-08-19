package ;
import com.xay.util.Input;
import com.xay.util.LayerManager;
import com.xay.util.SceneManager;
import com.xay.util.SceneManager.Scene;
import flash.display.Bitmap;
class StatsMenu extends Scene {
	var lm : LayerManager;
	var title : Bitmap;
	public function new() {
		super();
		lm = new LayerManager();
		Main.renderer.addChild(lm.getContainer());
		title = new Bitmap(Main.font.getText("stats"));
		title.scaleX = title.scaleY = 2.;
		title.x = Const.WID * .5 - title.width * .5;
		title.y = 25;
		lm.addChild(title, 0);
	}
	override public function delete() {
		super.delete();
		lm.delete();
	}
	override public function update() {
		super.update();
		if(Input.newKeyPress("start")) {
			delete();
		}
	}
}