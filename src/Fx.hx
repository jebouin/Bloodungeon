package ;
import com.xay.util.SpriteLib;
import com.xay.util.Util;
import flash.display.BlendMode;
import flash.display.ColorCorrection;
import flash.display.Shape;
import flash.filters.BlurFilter;
import flash.filters.GlowFilter;
import flash.geom.ColorTransform;
import flash.geom.Rectangle;
import flash.Lib;
import haxe.Timer;
import motion.Actuate;
import motion.easing.Elastic;
import motion.easing.Expo;
import motion.easing.Linear;
class Fx {
	public static var sx = 0.;
	public static var sy = 0.;
	public static var flashShape : Shape;
	public static var flashCT : ColorTransform;
	public static function init() {
		flashShape = new Shape();
		flashShape.graphics.beginFill(0xFFFFFF);
		flashShape.graphics.drawRect(0, 0, Const.WID, Const.HEI);
		flashShape.graphics.endFill();
		flashShape.blendMode = BlendMode.ADD;
		flashCT = new ColorTransform();
	}
	public static function update() {
		Particle.updateAll();
	}
	public static function screenShake(dx:Float, dy:Float, ?t=.5, ?random=false) {
		sx = dx;
		sy = dy;
		var c = Game.CUR.lm.getContainer();
		if(random) {
			Actuate.tween(Fx, t, {sy:0.}).onUpdate(function() {
				c.x = -(Game.CUR.camX + (Math.random() - .5) * 2. * sy);
				c.y = -(Game.CUR.camY + (Math.random() - .5) * 1.6 * sy);
			}).ease(Elastic.easeOut);
		} else {
			Actuate.tween(Fx, t, {sx:0., sy:0.}).onUpdate(function() {
				c.x = -(Game.CUR.camX + sx);
				c.y = -(Game.CUR.camY + sy);
			}).ease(Elastic.easeOut);
		}
	}
	public static function stopScreenShake() {
		Actuate.stop(Fx, "sx, sy");
	}
	public static function flash(r:Float, g:Float, b:Float, t:Float, intensity:Float, ?long=false) {
		flashCT.redMultiplier = r;
		flashCT.greenMultiplier = g;
		flashCT.blueMultiplier = b;
		flashCT.alphaMultiplier = 1.;
		flashShape.transform.colorTransform = flashCT;
		flashShape.alpha = intensity;
		flashShape.visible = true;
		Game.CUR.frontlm.addChild(flashShape, 10);
		if(long) {
			Actuate.tween(flashShape, t, {alpha: 0.}).onComplete(function() {
				flashShape.parent.removeChild(flashShape);
			}).ease(Expo.easeIn);
		} else {
			Actuate.tween(flashShape, t, {alpha: 0.}).onComplete(function() {
				flashShape.parent.removeChild(flashShape);
			});
		}
	}
	static function particleCollision(p:Particle, radius:Float) {
		function collides(x:Float, y:Float) {
			return Game.CUR.level.entityCollides(x, y, radius);
		}
		if(collides(p.xx, p.yy)) {
			p.vx *= -1;
			p.vy *= -1;
			p.xx += p.vx;
			p.yy += p.vy;
			return;
		}
		if(collides(p.xx + p.vx, p.yy + p.vy)) {
			if(collides(p.xx + p.vx, p.yy)) {
				if(p.vx > 0) {
					p.xx = Std.int(p.xx / 16 + 1.) * 16 - radius - .2;
				} else {
					p.xx = Std.int(p.xx / 16) * 16 + radius + .2;
				}
				p.vx *= -1;
			}
			if(collides(p.xx, p.yy + p.vy)) {
				if(p.vy > 0) {
					p.yy = Std.int(p.yy / 16 + 1.) * 16 - radius - .2;
				} else {
					p.yy = Std.int(p.yy / 16) * 16 + radius + .2;
				}
				p.vy *= -1;
			}
		}
	}
	public static function test() {
		for(i in 0...10) {
			var p = Particle.create();
			if(p == null) break;
			Game.CUR.lm.addChild(p, Const.FRONT_L);
			p.drawRect(8, 8, 0xFF0000);
			p.xx = -Game.CUR.lm.getContainer().x + Std.random(Const.WID) - 100;
			p.yy = -Game.CUR.lm.getContainer().y + Std.random(Const.HEI);
			p.vx = 10.;
			p.blendMode = BlendMode.ADD;
		}
	}
	public static function heroDeath(x:Float, y:Float, dx:Float, dy:Float) {
		flash(1., 0., 0., .5, .3);
		var d = Math.sqrt(dx*dx + dy*dy);
		if(d < .1) {
			screenShake(0, 8, .5, true);
			dx = 0;
			dy = 0;
		} else {
			dx /= d;
			dy /= d;
			screenShake(dx * 12., dy * 12., .6);
			
		}
		var angle = (d < .1 ? 0 : Math.atan2(-dy, -dx));
		//head
		var p = Particle.create();
		if(p == null) return;
		SpriteLib.copyFramePixelsFromSliceToGraphics(p.graphics, "heroHead", 0);
		p.xx = x;
		p.yy = y;
		p.zz = 8;
		var spd = d < .1 ? 0 : Util.randFloat(6., 8.5);
		var pa = angle + Util.randFloat(-.5, .5);
		p.vx = Math.cos(pa) * spd;
		p.vy = Math.sin(pa) * spd;
		p.vz = Util.randFloat(7.5, 9.);
		p.gravity = .8;
		p.bounciness = .7;
		p.friction = .06;
		p.rotVel = Util.randFloat(20., 30.) * Util.randSign();
		p.onBounce = function(p:Particle) {
			var col = Game.CUR.level.getCollisionAt(p.xx, p.yy);
			if(Game.CUR.level.entityCollidesFully(p.xx, p.yy, 4, HOLE)) {
				p.onUpdate = null;
				p.onDie = null;
				p.bounciness = -1;
				p.gravity = 0;
				p.vz = 0;
				Actuate.tween(p, .8, {scaleX: 0., scaleY: 0.}).onComplete(function() {
					p.delete();
				});
			} else {
				if(col == ICE) {
					p.rotVel = 0;
					if(p.bounciness > 0.) {
						p.bounciness = 0;
						p.vx *= 1.3;
						p.vy *= 1.3;
						p.friction = .03;
					}
				} else {
					p.rotVel *= -.94;
				}
			}
		};
		p.onUpdate = function(p:Particle) {
			particleCollision(p, 3);
			if(p.timer < 50 && !Main.secondUpdate) {
				for(i in 0...3) {
					var blood = bloodParticle(false);
					if(blood == null) return;
					var headAngle = p.rotation * Math.PI / 180. - Math.PI * .5;
					headAngle += Util.randFloat(-.4, .4);
					var speed = Util.randFloat(3., 4.);
					var ax = -Math.cos(headAngle);
					var az = Math.sin(headAngle);
					blood.xx = p.xx + ax * 5.;
					blood.yy = p.yy;
					blood.zz = p.zz + az * 8.;
					blood.vx = ax * speed;
					blood.vz = az * speed * 2.;
					blood.vy = Math.sin(p.timer / 10.);
					Game.CUR.lm.addChild(blood, Const.BACK_L);
					blood.onUpdate = function(p:Particle) {
						if(Game.CUR.level.getCollisionAt(blood.xx, blood.yy) == HOLE) {
							blood.onDie = null;
							blood.delete();
						}
					};
				}
			}
		}
		p.onDie = function() {
			p.drawToBD(Game.CUR.level.ground1Layer.bmp.bitmapData);
		};
		Timer.delay(function() {
			if(Game.CUR != null) {
				p.delete();
			}
		}, 5000);
		Game.CUR.lm.addChild(p, Const.BACKWALL_L);
	}
	public static function bloodParticle(isDark:Bool, ?wid=2.5, ?hei=1.5, ?lifeTime=30) {
		var p = Particle.create();
		if(p == null) return null;
		var col = (isDark ? 100 + Std.random(40) : 155 + Std.random(50)) << 16;
		p.drawRect(wid, hei, col);
		p.lifeTime = lifeTime;
		p.onDie = function() {
			p.drawToBD(Game.CUR.level.ground1Layer.bmp.bitmapData);
		}
		p.gravity = .8;
		p.friction = .12;
		return p;
	}
	public static function doorOpened(tx:Int, ty:Int, wid:Int, hei:Int) {
		for(j in ty...ty+hei) {
			for(i in tx...tx+wid) {
				for(k in 0...4) {
					var s = Particle.create();
					s.drawCircle(7, 0xFFFFFF);
					s.blendMode = BlendMode.ADD;
					s.xx = i * 16 + Math.random() * 16;
					s.yy = j * 16 + 5 + Math.random() * 8;
					s.lifeTime = 30 + Std.random(30);
					s.vz = Util.randFloat(.4, 1.1);
					s.alpha = .5 + Math.random() * .2;
					Actuate.tween(s, s.lifeTime * Lib.current.stage.frameRate / 60. / 60., {scaleX: 0., scaleY: 0., alpha: 0.}).ease(Linear.easeNone);
					Game.CUR.lm.addChild(s, Const.BACK_L);
				}
			}
		}
		screenShake(10, 10, .5, true);
	}
	public static function rocketSmoke(x:Float, y:Float) {
		var p = Particle.create();
		if(p == null) return;
		p.xx = x + Util.randFloat(-2, 2);
		p.yy = y + Util.randFloat(-2, 2);
		p.drawCircle(4., 0xFFFFFF);
		p.lifeTime = 20 + Std.random(20);
		Game.CUR.lm.addChild(p, Const.BACK_L);
		p.onUpdate = function(p:Particle) {
			var t = 1. - p.timer / p.lifeTime;
			p.scaleX = p.scaleY = t;
			if(t > .7) {
				t -= .7;
				t /= .3;
				p.transformColor(.5 + t * .5, .5 + t * .2, .5, .5 + t * .5);
			} else {
				p.transformColor(t * .5, t * .5, t * .5, t);
			}
		}
	}
	public static function laserParticle(x:Float, y:Float, laserRot:Float, floor:Int) {
		var p = Particle.create();
		if(p == null) return;
		p.xx = x;
		p.yy = y;
		if(floor == 2) {
			var v = Std.random(100) + 100;
			p.drawCircle(Util.randFloat(1.5, 3.), 0x0000CC + (v << 8) + (v << 16));
		} else if(floor == 3) {
			var v = Std.random(100) + 100;
			p.drawCircle(Util.randFloat(1.5, 3.), v + (v << 8) + (v << 16));
		}
		var dir = -laserRot + Util.randFloat(-.5, .5);
		var spd = Util.randFloat(0., 6.);
		p.vx = -Math.cos(dir) * spd;
		p.vy = Math.sin(dir) * spd;
		p.vz = Util.randFloat(2., 5.5);
		p.gravity = .3;
		p.friction = .1;
		p.lifeTime = 30;
		p.onUpdate = function(p:Particle) {
			p.scaleX = p.scaleY = 1. - p.timer / p.lifeTime;
		}
		Game.CUR.lm.addChild(p, Const.FRONT_L);
	}
	public static function beam(x:Float, y:Float) {
		flash(1., 1., 1., .4, 1.);
		var s = new Shape();
		var g = s.graphics;
		var h = 50;
		var w = 6;
		g.beginFill(0xFFFFFF, 1.);
		g.drawRect(-w*.5, -h, w, h);
		g.endFill();
		s.filters = [new GlowFilter(0xFFFFFF, .5, 30., 30., 8., 1)];
		Game.CUR.lm.addChild(s, Const.FRONT_L);
		s.x = x;
		s.y = y + 24;
		Fx.screenShake(0., -30., 1.4);
		Actuate.tween(s, .4, {scaleX:0., scaleY:3.}).onComplete(function() {
			s.parent.removeChild(s);
		});
	}
}