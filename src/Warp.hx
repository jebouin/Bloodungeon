package ;
import com.xay.util.Util;
import flash.display.Graphics;
import flash.display.LineScaleMode;
import flash.display.Shape;
import flash.display.Sprite;
import flash.filters.GlowFilter;
class Warp extends Sprite {
	var circles : Array<Shape>;
	var timer : Int;
	var deTimer : Int;
	var activated : Bool;
	public function new() {
		super();
		mouseChildren = mouseEnabled = false;
		circles = [];
		for(i in 0...4) {
			var c = new Shape();
			var d = 8. + i*4.;
			renderArc(c.graphics, d, Math.PI * .25, Math.PI * .75, 1.);
			renderArc(c.graphics, d, Math.PI * 1.25, Math.PI * 1.75, 1.);
			addChild(c);
			circles.push(c);
		}
		scaleY = .7;
		timer = 0;
		deTimer = -1;
		activated = false;
		filters = [new GlowFilter(0xFFFFFF, .35, 16, 16, 5., 1)];
	}
	public function update() {
		if(!visible) return;
		if(activated) {
			if(Std.random(30) == 0) {
				Main.glitch();
			}
		}
		timer++;
		for(i in 0...4) {
			circles[i].rotation += (i + 1.) * Math.cos(timer * .05) * 1.;
			if(activated) {
				circles[i].rotation += (i + 1.) * 10.;
			}
		}
	}
	function renderArc(g:Graphics, d:Float, startAngle:Float, endAngle:Float, thick:Float) {
		var da = Math.PI * 2. / 30.;
		g.lineStyle(thick, 0xFFFFFF, 1., false, LineScaleMode.NONE);
		g.moveTo(Math.cos(startAngle) * d, Math.sin(startAngle) * d);
		while(startAngle + da < endAngle) {
			startAngle += da;
			g.lineTo(Math.cos(startAngle) * d, Math.sin(startAngle) * d);
		}
		g.lineTo(Math.cos(endAngle) * d, Math.sin(startAngle) * d);
	}
	public function activate() {
		activated = true;
		for(i in 0...4) {
			circles[i].scaleX = i*.5 + 1.;
		}
	}
	public function deactivate() {
		activated = false;
		for(i in 0...4) {
			circles[i].rotation = 0;
			circles[i].scaleX = 1.;
		}
	}
}