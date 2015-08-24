package com.xay.util;
import com.xay.util.Util;
#if openfl
import openfl.display.BitmapData;
import openfl.geom.Point;
import openfl.geom.Rectangle;
#elseif flash
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
#end
class BitmapFont {
	var bd : BitmapData;
	var charWid : Int;
	var charHei : Int;
	public static var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 .,?!;:<>{}[]()#^*_-+=/\\~\'\"";
	public function new(bd:BitmapData, charWid:Int, charHei:Int) {
		this.bd = bd;
		this.charWid = charWid;
		this.charHei = charHei;
	}
	public function delete() {
		bd.dispose();
	}
	public function getText(text:String, maxWidChars:Int=-1, wordwrap=false, centered=false, margin=0) {
		text = text.toUpperCase();
		if(wordwrap&&maxWidChars>0) {
			text = wordWrap(text, maxWidChars);
		}
		var tl = text.length;
		var wid = tl*charWid+tl-1;
		var hei = charHei;
		var nbWidChars = tl;
		if(maxWidChars>0) {
			nbWidChars = Std.int(Util.min(maxWidChars, tl));
			wid = Std.int(Util.min(wid, Std.int(nbWidChars*charWid+nbWidChars-1)));
			hei = Math.ceil(tl/nbWidChars)*(charHei+1) - 1;
		}
		var destx = 0;
		var desty = 0;
		var bd = new BitmapData(wid + margin*2, hei + margin*2, true, 0x0);
		var n = 0;
		for(i in 0...tl) {
			if(n==nbWidChars) {
				destx = 0;
				desty += charHei+1;
				n = 0;
			}
			if(n==0&&centered) {
				destx += getLineOffsetToCenter(text, Std.int(i/nbWidChars), nbWidChars);
			}
			var frame = chars.indexOf(text.charAt(i));
			var sx = (frame&7)*(charWid+1);
			var sy = (frame>>3)*(charHei+1);
			bd.copyPixels(this.bd, new Rectangle(sx, sy, charWid, charHei), new Point(destx + margin, desty + margin));
			destx += charWid+1;
			n++;
		}
		return bd;
	}
	function getLineOffsetToCenter(text:String, line:Int, wid:Int) {
		var p = wid*(line+1)-1;
		var o = 0;
		while(text.charAt(p)==" "||p>=text.length) {
			p--;
			o++;
		}
		return Std.int(o*charWid/2.);
	}
	public function wordWrap(text:String, wid:Int) {
		var words = text.split(" ");
		text = "";
		var l = 0;
		var i = 0;
		while(i < words.length) {
			var w = words[i];
			var wl = w.length;
			if(l+wl>wid&&l!=0) {
				for(j in 0...wid-l) text+=" ";
				l = 0;
			} else {
				text+=w;
				l+=w.length;
				i++;
				if(l!=wid) {
					l++;
					text+=" ";
				}
			}
		}
		return text;
	}
}