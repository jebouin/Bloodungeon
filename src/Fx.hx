package ;
import com.xay.util.SpriteLib;
import com.xay.util.Util;
import flash.display.BlendMode;
import flash.filters.BlurFilter;
import flash.filters.GlowFilter;
import flash.geom.Rectangle;
import flash.Lib;
import haxe.Timer;
import motion.Actuate;
import motion.easing.Elastic;
import motion.easing.Linear;
class Fx {
	public static var sx = 0.;
	public static var sy = 0.;
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
		for(i in 0...1) {
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
							/*p.onUpdate = function(p:Particle) {
								particleCollision(p, 3);
								if(p.timer < 200) {
									var blood = bloodParticle(false, 2.5, 1.5, 1);
									if(blood == null) return;
									blood.xx = p.xx + Util.randFloat(-3, 3);
									blood.yy = p.yy + Util.randFloat(-3, 3);
								}
							};*/
						}
					} else {
						p.rotVel *= -.94;
					}
				}
				/*if(p.vz > 2.) {
					var bd = Game.CUR.level.ground0Layer.bmp.bitmapData;
					var bx = Std.int(p.xx);
					var by = Std.int(p.yy);
					bd.lock();
					for(j in -3...4) {
						for(i in -3...4) {
							var dist = i*i + j*j;
							if(dist > 16) continue;
							var col = 0xFF000000;
							var r = 200 + Std.random(55);
							bd.setPixel32(bx + i, by + j, col + (r << 16));
						}
					}
					bd.unlock(new Rectangle(bx - 5, by - 5, 10, 10));
				}*/
			};
			p.onUpdate = function(p:Particle) {
				particleCollision(p, 3);
				if(p.timer < 50) {
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
			Timer.delay(function() {
				Actuate.tween(p, 1., {alpha: 0.}).onComplete(function() {
					p.delete();
				});
			}, 5000);
			Game.CUR.lm.addChild(p, Const.BACKWALL_L);
		}
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
	/*public static function spark(x:Float, y:Float, dir:Const.DIR) {
		var s = Particle.create();
		s.drawRect(1, 1, 0xFFFF00);
		s.xx = x;
		s.yy = y;
		s.lifeTime = 20;
		s.gravity = .7;
		s.vz = Util.randFloat(6., 8.);
		s.vx = Util.randFloat(1., 2.);
		if(dir == RIGHT) s.vx *= -1;
		if(dir == UP || dir == DOWN) s.vx = 0.;
		Game.CUR.lm.addChild(s, Const.BACK_L);
	}*/
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
	}
}