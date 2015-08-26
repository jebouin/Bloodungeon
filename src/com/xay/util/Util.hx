package com.xay.util;
#if openfl
import openfl.display.DisplayObject;
import openfl.geom.Point;
import openfl.text.Font;
import openfl.utils.ByteArray;
import openfl.text.TextFormat;
import openfl.text.TextField;
#elseif flash
import flash.display.DisplayObject;
import flash.geom.Point;
import flash.text.Font;
import flash.utils.ByteArray;
import flash.text.TextFormat;
import flash.text.TextField;
#end
typedef RGB = {
	r:Int,
	g:Int,
	b:Int
}

typedef HSV = {
	h:Float,
	s:Float,
	v:Float
}

typedef RGBA = {
	>RGB,
	a:Int
}

class Util {
	public static var RADTODEG = 180./Math.PI;
	public static var DEGTORAD = Math.PI/180.;
	static public inline function IABS(v:Int) {
		return (v<0?-v:v);
	}
	static public inline function ABS(v:Float) {
		return (v<0?-v:v);
	}
	static public function SGN(v:Float) {
		return (v==0?0:(v>0?1:-1));
	}
	static public function randInt(min:Int, max:Int) {
		return Std.random(max-min+1)+min;
	}
	static public function randFloat(min:Float, max:Float) {
		return Math.random()*(max-min)+min;
	}
	static public function randSign() {
		return Std.random(2)*2-1;
	}
	static public function uniformRandPoint(minDist:Float, maxDist:Float) {
		var angle = randFloat(0, 2*Math.PI);
		var dist = randFloat(minDist, maxDist);
		return {x:Math.cos(angle)*dist, y:Math.sin(angle)*dist};
	}
	static public function max(v0:Float, v1:Float) {
		return (v0<v1?v1:v0);
	}
	static public function max3(v0:Float, v1:Float, v2:Float) {
		return max(max(v0, v1), v2);
	}
	static public function min(v0:Float, v1:Float) {
		return (v1<v0?v1:v0);
	}
	static public function min3(v0:Float, v1:Float, v2:Float) {
		return min(min(v0, v1), v2);
	}
	static public function swap(a, b) {
		var c = a;
		a = b;
		b = c;
	}
	static public function dist(x:Float, y:Float) {
		return Math.sqrt(pow2(x)+pow2(y));
	}
	static public function lerp(x:Float, y0:Float, y1:Float) {
		return x*(y1-y0) + y0;
	}
	static public function pow2(x:Float) {
		return x*x;
	}
	static public function pow3(x:Float) {
		return x*x*x;
	}
	static public function quadraticBezier(x:Float, a:Float, b:Float, c:Float) {
		return pow2(1-x)*a + 2*(1-x)*b + pow2(x)*c;
	}
	static public function cubicBezier(x:Float, a:Float, b:Float, c:Float, d:Float) {
		return pow3(1-x)*a + 3*pow2(1-x)*x*b + 3*(1-x)*pow2(x)*c + pow3(x)*d;
	}
	static public function quadraticBezier2D(t:Float, x0:Float, y0:Float, x1:Float, y1:Float, x2:Float, y2:Float) {
		return {x:quadraticBezier(t, x0, x1, x2), y:quadraticBezier(t, y0, y1, y2)};
	}
	static public function cubicBezier2D(t:Float, x0:Float, y0:Float, x1:Float, y1:Float, x2:Float, y2:Float, x3:Float, y3:Float) {
		return {x:cubicBezier(t, x0, x1, x2, x3), y:cubicBezier(t, y0, y1, y2, y3)};
	}
	static public function RGBToInt(col:RGB) : Int {
		return col.r<<16 | col.g<<8 | col.b;
	}
	static public function addAlpha(col:Int, alpha:Int) : Int {
		col &= 0x00ffffff;
		col |= alpha<<24;
		return col;
	}
	static public function intToRGB(col:Int) : RGB {
		return {r:col>>16,
				g:col>>8&0xff,
				b:col&0xff};
	}
	static public function intToRGBA(col:Int) : RGBA {
		return {r:col>>16&0xff,
				g:col>>8&0xff,
				b:col&0xff,
				a:col>>24};
	}
	static public function RGBToHSV(col:RGB) : HSV {
		var r = col.r/255;
		var g = col.g/255;
		var b = col.b/255;
		var min = Util.min3(r, g, b);
		var max = Util.max3(r, g, b);
		if(min==max) {
			return {h:0, s:0, v:min*100};
		}
		var d = (r==min?g-b:(b==min?r-g:b-r));
		var h = (r==min?3:(b==min?1:5));
		var nh = 60*(h - d/(max-min));
		var ns = (max-min)/max;
		var nv = max;
		return {h:nh, s:ns*100, v:nv*100};
	}
	static public function HSVToRGB(col:HSV) : RGB {
		col.s/=100;
		col.v/=100;
		if(col.s==0) {
			return {r:Std.int(col.v*255), g:Std.int(col.v*255), b:Std.int(col.v*255)};
		}
		var v = col.v;
		var s = col.s;
		col.h /= 60;
		var part = Std.int(col.h);
		var f = col.h-part;
		var m0 = Std.int(v*(1-s)*255);
		var m1 = Std.int(v*(1-s*f)*255);
		var m2 = Std.int(v*(1-s*(1-f))*255);
		var vv = Std.int(v*255);
		if(part==0) {
			return {r:vv, g:m2, b:m0};
		} else if(part==1) {
			return {r:m1, g:vv, b:m0};
		} else if(part==2) {
			return {r:m0, g:vv, b:m2};
		} else if(part==3) {
			return {r:m0, g:m1, b:vv};
		} else if(part==4) {
			return {r:m2, g:m0, b:vv};
		} else if(part==5) {
			return {r:vv, g:m0, b:m1};
		}
		trace("Conversion Error (Invalid hue)");
		return {r:-1, g:-1, b:-1};
	}
	static public function HSVToInt(col:HSV) : Int {
		var rgb : RGB = HSVToRGB(col);
		return RGBToInt(rgb);
	}
	static public function createTextField(str:String, font:Font, ?maxWidth=null, ?tSize=8) {
		var f = new TextFormat();
		f.font = font.fontName;
		f.size = tSize;
		f.color = 0xffffff;
		var tf = new TextField();
		tf.mouseEnabled = tf.selectable = false;
		tf.defaultTextFormat = f;
		tf.embedFonts = true;
		tf.htmlText = str;
		tf.width = tf.textWidth+4;
		if(maxWidth!=null) {
			//if(tf.width>maxWidth) {
				tf.width = maxWidth;
				tf.multiline = tf.wordWrap = true;
			//}
		} else {
			tf.multiline = tf.wordWrap = false;
		}
		tf.height = tf.textHeight+4;
		return tf;
	}
	static public function getStagePosOf(obj:DisplayObject, ?x:Float, ?y:Float) {
		var parent = obj;
		var p = new Point(x==null?obj.x:x, y==null?obj.y:y);
		while(parent.parent!=null) {
			parent = parent.parent;
			p = parent.localToGlobal(p);
		}
		return p;
	}
	static public function bresenham(x0:Int, y0:Int, x1:Int, y1:Int) {
		var l = [];
		var dx = ABS(x1-x0);
		var dy = ABS(y1-y0);
		var sx = x0<x1 ? 1 : -1;
		var sy = y0<y1 ? 1 : -1;
		var e = (dx>dy ? dx : -dy)*.5;
		var e2;
		while(true) {
			l.push({x:x0, y:y0});
			if(x0==x1 && y0==y1) break;
			e2 = e;
			if(e2 > -dx) {
				e -= dy;
				x0 += sx;
			}
			if(e2 < dy) {
				e += dx;
				y0 += sy;
			}
		}
		return l;
	}
	static public function pathToFileName(path:String) {
		var dotIndex = path.lastIndexOf(".");
		var name = path.substr(0, dotIndex);
		var slashIndex = name.lastIndexOf("/");
		return name.substr(slashIndex+1);
	}
}