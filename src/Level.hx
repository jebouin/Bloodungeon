package ;
import com.xay.util.LayerManager;
import com.xay.util.Util;
import flash.accessibility.Accessibility;
import flash.display.BlendMode;
import flash.display.DisplayObject;
import flash.display.GradientType;
import flash.display.Sprite;
import flash.filters.ShaderFilter;
import flash.geom.Matrix;
import flash.net.drm.DRMVoucherDownloadContext;
import flash.utils.ByteArray;
import com.xay.util.SpriteLib;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.filters.DropShadowFilter;
import flash.filters.GlowFilter;
import flash.geom.Point;
import Collision;
@:file("res/floor0.tmx") class Floor0TMX extends ByteArray {}
@:file("res/floor1.tmx") class Floor1TMX extends ByteArray {}
@:file("res/floor2.tmx") class Floor2TMX extends ByteArray {}
@:file("res/floor3.tmx") class Floor3TMX extends ByteArray {}
class Level {
	public static var ROOMID = 0;
	public static var RWID : Int;
	public static var RHEI : Int;
	public static var WID : Int;
	public static var HEI : Int;
	public var floor : Int;
	public var posX : Float;
	public var posY : Float;
	public var dark : Sprite;
	public var light : Shape;
	public var light2 : Shape;
	var exitLight : Shape;
	var roomIdX : Int;
	var roomIdY : Int;
	var nbRoomsX : Int;
	var nbRoomsY : Int;
	var tiles : Array<Array<TILE_COLLISION_TYPE> >;
	var rails : Array<Array<RAIL_KIND> >;
	var spikePos : Array<{x:Int, y:Int, dir:Const.DIR8}>;
	var bowsPos : Array<{x:Int, y:Int, dir:Const.DIR}>;
	var torches : Array<Torch>;
	var fakeTileRemoved : Array<Bool>;
	var ground0Layer : TiledLayer;
	var ground1Layer : TiledLayer;
	var overLayer : TiledLayer;
	var wall0Layer : TiledLayer;
	var wall1Layer : TiledLayer;
	var activeGroup : TiledGroup;
	var map : TiledMap;
	var actionRects : Array<{x:Int, y:Int, wid:Int, hei:Int, f:String}>;
	public function new() {
		RWID = Std.int(Const.WID / 16);
		RHEI = Std.int(Const.HEI / 16);
		renderLighting();
		load(3);
		loadEntities(roomIdX, roomIdY);
	}
	public function update() {
		Bow.updateAll();
		Spinner.updateAll();
		Torch.updateAll();
		Cannon.updateAll();
	}
	public function load(floor:Int) {
		Audio.playMusic(floor);
		this.floor = floor;
		if(map != null) {
			ground0Layer.delete();
			ground1Layer.delete();
			overLayer.delete();
			wall0Layer.delete();
			wall1Layer.delete();
		}
		switch(floor) {
			case 0:
				map = new TiledMap(new Floor0TMX().toString());
			case 1:
				map = new TiledMap(new Floor1TMX().toString());
			case 2:
				map = new TiledMap(new Floor2TMX().toString());
			case 3:
				map = new TiledMap(new Floor3TMX().toString());
			default:
				return;
		}
		ground0Layer = map.getLayer("ground0");
		ground1Layer = map.getLayer("ground1");
		overLayer = map.getLayer("over");
		wall0Layer = map.getLayer("wall0");
		wall1Layer = map.getLayer("wall1");
		activeGroup = map.getGroup("active");
		Game.CUR.lm.addChild(ground0Layer, Const.BACK_L);
		Game.CUR.lm.addChild(ground1Layer, Const.BACK_L);
		Game.CUR.lm.addChild(overLayer, Const.BACK_L);
		Game.CUR.lm.addChild(wall0Layer, Const.BACK_L);
		Game.CUR.lm.addChild(wall1Layer, Const.BACK_L);
		WID = map.wid;
		HEI = map.hei;
		nbRoomsX = Std.int(WID / (RWID - 1));
		nbRoomsY = Std.int(HEI / (RHEI - 1));
		tiles = [];
		var hasRails = floor == 3;
		rails = hasRails ? [] : null;
		spikePos = [];
		bowsPos = [];
		torches = [];
		actionRects = [];
		fakeTileRemoved = [];
		for(i in 0...20) {
			fakeTileRemoved[i] = false;
		}
		for(j in 0...HEI) {
			tiles[j] = [];
			if(rails != null) {
				rails[j] = [];
			}
			for(i in 0...WID) {
				var ground0Tile = ground0Layer.getTileAt(i, j);
				var ground0TileCol = Collision.TILE_COLLISIONS[ground0Tile];
				var ground1Tile = ground1Layer.getTileAt(i, j);
				var ground1TileCol = Collision.TILE_COLLISIONS[ground1Tile];
				var overTile = overLayer.getTileAt(i, j);
				var overTileCol = Collision.TILE_COLLISIONS[overTile];
				var wall0Tile = wall0Layer.getTileAt(i, j);
				var wall0TileCol = Collision.TILE_COLLISIONS[wall0Tile];
				var wall1Tile = wall1Layer.getTileAt(i, j);
				var wall1TileCol = Collision.TILE_COLLISIONS[wall1Tile];
				var col = NONE;
				if(ground0Tile == 0) {
					col = HOLE;
				} else if(wall1TileCol != NONE) {
					col = wall1TileCol;
				} else if(wall0TileCol != NONE) {
					col = wall0TileCol;
				} else if(ground1TileCol == ICE) {
					col = ICE;
				} else if(ground0TileCol != NONE) {
					col = ground0TileCol;
				} 
				tiles[j][i] = col;
				function addSpecial(layer:TiledLayer, tile:Int) {
					if(tile == 16) {
						layer.setTileAt(i, j, 0);
						spikePos.push({x:i, y:j, dir:null});
					} else if(tile == 32) {
						layer.setTileAt(i, j, 0);
						setCollision(i, j, BOW);
						bowsPos.push({x:i, y:j, dir:RIGHT});
					} else if(tile == 48) {
						layer.setTileAt(i, j, 0);
						setCollision(i, j, BOW);
						bowsPos.push({x:i, y:j, dir:LEFT});
					} else if(tile == 64) {
						layer.setTileAt(i, j, 0);
						setCollision(i, j, BOW);
						bowsPos.push({x:i, y:j, dir:UP});
					} else if(tile == 80) {
						layer.setTileAt(i, j, 0);
						setCollision(i, j, BOW);
						bowsPos.push({x:i, y:j, dir:DOWN});
					} else if(tile == 96) {
						layer.setTileAt(i, j, 0);
						spikePos.push({x:i, y:j, dir:RIGHT});
					} else if(tile == 112) {
						layer.setTileAt(i, j, 0);
						spikePos.push({x:i, y:j, dir:LEFT});
					} else if(tile == 128) {
						layer.setTileAt(i, j, 0);
						spikePos.push({x:i, y:j, dir:UP});
					} else if(tile == 144) {
						layer.setTileAt(i, j, 0);
						spikePos.push({x:i, y:j, dir:DOWN});
					} else if(tile == 160) {
						layer.setTileAt(i, j, 0);
						spikePos.push({x:i, y:j, dir:UP_LEFT});
					} else if(tile == 176) {
						layer.setTileAt(i, j, 0);
						spikePos.push({x:i, y:j, dir:DOWN_RIGHT});
					} else if(tile == 192) {
						layer.setTileAt(i, j, 0);
						spikePos.push({x:i, y:j, dir:DOWN_LEFT});
					} else if(tile == 208) {
						layer.setTileAt(i, j, 0);
						spikePos.push({x:i, y:j, dir:UP_RIGHT});
					}
				}
				if(overTile & 15 == 0) {
					addSpecial(overLayer, overTile);
				}
				if(wall1Tile & 15 == 0) {
					addSpecial(wall1Layer, wall1Tile);
				}
				if(overTile == 88) {
					overLayer.setTileAt(i, j, 0);
					setCollision(i, j, FULL);
					torches.push(new Torch(i, j));					
				}
				if(hasRails) {
					var railKinds : Array< Array<RAIL_KIND> > = [[DR, H, DL], [V, UR, UL], [X, H, H], [NONE, V, V]];
					var stx = ((overTile - 1) & 15) - 8;
					var sty = ((overTile - 1) >> 4) - 10;
					var railKind : RAIL_KIND = NONE;
					if(stx >= 0 && sty >= 0 && stx < 3 && sty < 4) {
						railKind = railKinds[sty][stx];
					}
					rails[j][i] = railKind;
				}
			}
		}
		overLayer.render(); //cleans spikes and torches on tiles
		wall1Layer.render();
		var p = new Point(0, 0);
		var bd = wall0Layer.bmp.bitmapData;
		var shadowAlpha = 1.;
		if(floor == 3) {
			shadowAlpha *= .6;
		}
		bd.applyFilter(bd, bd.rect, p, new DropShadowFilter(shadowAlpha, -90, 0xFF000000, 1., 1., 8., 1., 1, true));
		bd.applyFilter(bd, bd.rect, p, new DropShadowFilter(1., 45, 0xFF000000, .2, 1., 1., 1., 1, false));
		bd.applyFilter(bd, bd.rect, p, new DropShadowFilter(1., 135, 0xFF000000, .2, 1., 1., 1., 1, false));
		bd = ground0Layer.bmp.bitmapData;
		bd.applyFilter(bd, bd.rect, p, new GlowFilter(0xFFFFFFFF, .6, 2., 2., 2., 1, true));
		switch(floor) {
			case 0:
				/*setRoomId(2, 3);
				Hero.spawnX = 31 * 16 + 8;
				Hero.spawnY = 34 * 16 + 8;*/
				setRoomId(1, 5);
				Hero.spawnX = 21 * 16 + 8;
				Hero.spawnY = 52 * 16 + 8;
				addLighting();
			case 1:
				Game.CUR.cd.activate();
				removeLighting();
				setRoomId(2, 5);
				Hero.spawnX = 35 * 16 + 8;
				Hero.spawnY = 51 * 16 + 8;
				/*setRoomId(0, 0);
				Hero.spawnX = 12 * 16 + 8;
				Hero.spawnY = 6 * 16 + 8;*/
				/*setRoomId(3, 5);
				Hero.spawnX = 44 * 16 + 8;
				Hero.spawnY = 47 * 16 + 8;*/
			case 2:
				Game.CUR.cd.activate();
				removeLighting();
				setRoomId(2, 2);
				Hero.spawnX = 34 * 16 + 8;
				Hero.spawnY = 22 * 16 + 8;
				/*setRoomId(0, 1);
				Hero.spawnX = 13 * 16 + 8;
				Hero.spawnY = 18 * 16 + 8;*/
			case 3:
				Game.CUR.cd.activate();
				removeLighting();
				/*setRoomId(1, 4);
				Hero.spawnX = 24 * 16;
				Hero.spawnY = 41 * 16;*/
				/*setRoomId(2, 3);
				Hero.spawnX = 30 * 16 + 8;
				Hero.spawnY = 34 * 16 + 8;*/
				/*setRoomId(0, 0);
				Hero.spawnX = 11 * 16 + 8;
				Hero.spawnY = 8 * 16 + 8;*/
				/*setRoomId(1, 1);
				Hero.spawnX = 15 * 16 + 8;
				Hero.spawnY = 17 * 16 + 8;*/
				setRoomId(3, 2);
				Hero.spawnX = 43 * 16 + 8;
				Hero.spawnY = 20 * 16 + 8;
		}
		var bd = ground0Layer.bmp.bitmapData;
		for(j in 0...HEI) {
			for(i in 0...WID) {
				var tile = ground0Layer.getTileAt(i, j);
				if(tile == 137 || tile == 138 || tile == 153 || tile == 154) {
					var m = Util.randFloat(.85, .95);
					var rm = m;
					var gm = m;
					var bm = m;
					for(jj in j << 4...(j << 4) + 16) {
						for(ii in i << 4...(i << 4) + 16) {
							var c = bd.getPixel(ii, jj);
							var b = c & 0xFF;
							var g = (c >> 8) & 0xFF;
							var r = (c >> 16) & 0xFF;
							r = Std.int(b * rm);
							g = Std.int(b * gm);
							b = Std.int(b * bm);
							bd.setPixel32(ii, jj, 0xFF000000 + (r << 16) + (g << 8) + b);
						}
					}
				}
			}
		}
		Game.CUR.lm.getContainer().x = -posX;
		Game.CUR.lm.getContainer().y = -posY;
	}
	public function loadEntities(idx:Int, idy:Int) {
		if(idx < 0 || idy < 0 || idx >= nbRoomsX || idy >= nbRoomsY) return false;
		var nextRoomX = idx * (RWID - 1) * 16;
		var nextRoomY = idy * (RHEI - 1) * 16;
		for(pos in spikePos) {
			var tx = pos.x;
			var ty = pos.y;
			var dir = pos.dir;
			if(isInRoom(tx, ty, idx, idy)) {
				var s = new Spike(tx, ty, dir);
				s.roomId = ROOMID;
				Game.CUR.addEntity(s);
			}
		}
		Bow.timer = Cannon.timer = 1000;
		for(pos in bowsPos) {
			if(isInRoom(pos.x, pos.y, idx, idy)) {
				var b = new Bow(pos.x, pos.y, pos.dir);
				b.roomId = ROOMID;
				Game.CUR.addEntity(b);
			}
		}
		for(o in activeGroup.objects) {
			var x = Std.parseFloat(o.properties.get("x"));
			var y = Std.parseFloat(o.properties.get("y"));
			var wid = Std.parseFloat(o.properties.get("width"));
			var hei = Std.parseFloat(o.properties.get("height"));
			if(x >= nextRoomX && y >= nextRoomY && x < nextRoomX + Const.WID && y < nextRoomY + Const.HEI) {
				var tx = Std.int(x) >> 4;
				var ty = Std.int(y) >> 4;
				var twid = Std.int(wid) >> 4;
				var thei = Std.int(hei) >> 4;
				var e : Entity = null;
				switch(o.type) {
					case "Thwomp":
						e = new Thwomp(tx, ty);
					case "Button":
						var facesRight = getCollision(tx+1, ty) == NONE;
						var id = Std.parseInt(o.properties.get("id"));
						e = new Button(tx + (facesRight?0:1), ty, facesRight, id);
					case "Door":
						var id = Std.parseInt(o.properties.get("id"));
						e = new Door(this, tx, ty, twid, thei, id);
					case "Spinner":
						var nbBranches = Std.parseInt(o.properties.get("nb"));
						var size = Std.parseInt(o.properties.get("size"));
						var speed = Std.parseFloat(o.properties.get("speed"));
						var initAngle = Std.parseFloat(o.properties.get("initAngle"));
						e = new Spinner(x + 8., y + 8., initAngle, nbBranches, size, speed);
					case "Action":
						var f = o.properties.get("function");
						actionRects.push({x:tx, y:ty, wid:twid, hei:thei, f:f});
					case "FakeTile":
						var secretId = Std.parseInt(o.properties.get("secretId"));
						if(fakeTileRemoved[secretId]) {
							continue;
						}
						var id = Std.parseInt(o.properties.get("id"));
						var dir = Const.stringToDir(o.properties.get("dir"));
						e = new FakeTile(tx, ty, twid, thei, id, secretId, dir);
					case "Laser":
						e = new Laser(this, tx, ty);
					case "Cannon":
						e = new Cannon(this, tx, ty);
						setCollision(tx, ty, FULL);
					case "Blade":
						var dir = Const.stringToDir(o.properties.get("dir"));
						var off = Std.parseFloat(o.properties.get("offset"));
						e = new Blade(this, tx, ty, dir, off);
					case "Tesla":
						var time = Std.parseInt(o.properties.get("time"));
						var off = Std.parseInt(o.properties.get("offset"));
						var id = Std.parseInt(o.properties.get("id"));
						var linksStrs = o.properties.get("links").split(",");
						var links = [];
						for(l in linksStrs) {
							links.push(Std.parseInt(l));
						}
						e = new Tesla(tx, ty, id, links, time, off);
					default:
						
				}
				if(e != null) {
					e.roomId = ROOMID;
					Game.CUR.addEntity(e);
					e.update();
				}
			}
		}
		return true;
	}
	public function reloadEntities() {
		Game.CUR.clearEntities(true);
		loadEntities(roomIdX, roomIdY);
	}
	public function nextFloor() {
		for(t in torches) {
			t.delete();
		}
		torches = [];
		Game.CUR.clearEntities(true);
		Game.CUR.hero.prevRoomDir = null;
		load(floor + 1);
		loadEntities(roomIdX, roomIdY);
		Game.CUR.hero.spawn();
	}
	public function nextRoom(dir:Const.DIR) {
		ROOMID++;
		Enemy.fade = true;
		var dx = (dir == RIGHT ? 1 : (dir == LEFT ? -1 : 0));
		var dy = (dir == DOWN ? 1 : (dir == UP ? -1 : 0));
		Game.CUR.hero.computeSpawnPos(dir == UP || dir == DOWN);
		closeRoom(dir);
		setRoomId(roomIdX + dx, roomIdY + dy);
		loadEntities(roomIdX, roomIdY);
		Game.CUR.lock();
		Game.CUR.moveCameraTo(posX, posY, .5, function() {
			Game.CUR.unlock();
			var toDelete = [];
			for(e in Game.CUR.entities) {
				if(e != Game.CUR.hero && e.roomId != -1) {
					if(e.roomId != ROOMID) {
						toDelete.push(e);
					}
				}
			}
			for(e in toDelete) {
				e.delete();
				Game.CUR.entities.remove(e);
			}
		});
		return true;
	}
	function closeRoom(dir:Const.DIR) {
		var tx = roomIdX * (RWID - 1);
		var ty = roomIdY * (RHEI - 1);
		if(dir == LEFT || dir == RIGHT) {
			var x = tx + (dir == RIGHT ? RWID-2:1);
			for(j in 0...10) {
				tiles[j + ty][x] = FULL;
			}
		} else {
			var y = ty + (dir == DOWN ? RHEI-2:1);
			for(i in 0...15) {
				tiles[y][i + tx] = FULL;
			}
		}
	}
	function setRoomId(idx:Int, idy:Int) {
		roomIdX = idx;
		roomIdY = idy;
		posX = idx * (RWID - 1) * 16;
		posY = idy * (RHEI - 1) * 16;
		if(floor == 0 && idx == 2 && idy == 3) {
			addExitLight();
		}
	}
	public inline function isOnMap(x:Int, y:Int) {
		return x >= 0 && y >= 0 && x < WID && y < HEI;
	}
	public function getCollision(x:Int, y:Int) {
		if(!isOnMap(x, y)) {
			return NONE;
		}
		return tiles[y][x];
	}
	public function getRail(x:Int, y:Int) : RAIL_KIND {
		if(!isOnMap(x, y) || rails == null) {
			return NONE;
		}
		return rails[y][x];
	}
	public function areRailsConnected(x0:Int, y0:Int, dir:Const.DIR) {
		var k0 = getRail(x0, y0);
		var k1 = getRail(x0 + Const.getDirX(dir), y0 + Const.getDirY(dir));
		if(k0 == NONE || k1 == NONE) {
			return false;
		}
		if(dir == DOWN) {
			var kk = k0;
			k0 = k1;
			k1 = kk;
			dir = UP;
		}
		if(dir == RIGHT) {
			var kk = k0;
			k0 = k1;
			k1 = kk;
			dir = LEFT;
		}
		switch(dir) {
			case UP:
				return (k0 == V || k0 == UL || k0 == UR || k0 == X) && (k1 == V || k1 == DL || k1 == DR || k1 == X);
			case LEFT:
				return (k0 == H || k0 == UL || k0 == DL || k0 == X) && (k1 == H || k1 == UR || k1 == DR || k1 == X);
			default:
				
		}
		return false;
	}
	public function setCollision(x:Int, y:Int, type:TILE_COLLISION_TYPE) {
		if(!isOnMap(x, y)) return;
		tiles[y][x] = type;
	}
	public function getHeight(x:Int, y:Int) {
		if(!isOnMap(x, y)) {
			return 0;
		}
		return 0;
	}
	public function getCollisionAt(x:Float, y:Float) {
		return getCollision(Std.int(x / 16), Std.int(y / 16));
	}
	public function getHeightAt(x:Float, y:Float) {
		var tx = Std.int(x) >> 4;
		var ty = Std.int(y) >> 4;
		return getHeight(tx, ty);
	}
	public inline function tileCollides(x:Int, y:Int, ?holeCollides=false, ?bowCollides=true) {
		return getCollision(x, y) == FULL || (bowCollides && getCollision(x, y) == BOW) || (holeCollides && getCollision(x, y) == HOLE);
	}
	public function pointCollides(x:Float, y:Float, ?holeCollides=false, ?bowCollides=true) {
		return tileCollides(Std.int(x) >> 4, Std.int(y) >> 4, holeCollides, bowCollides);
	}
	public function entityCollides(e:Entity, x:Float, y:Float) {
		//y -= 16 * getHeightAt(x, y);
		if(tileCollides(Std.int(x - e.cradius) >> 4, Std.int(y - e.cradius) >> 4)) return true;
		if(tileCollides(Std.int(x + e.cradius) >> 4, Std.int(y - e.cradius) >> 4)) return true;
		if(tileCollides(Std.int(x + e.cradius) >> 4, Std.int(y + e.cradius) >> 4)) return true;
		if(tileCollides(Std.int(x - e.cradius) >> 4, Std.int(y + e.cradius) >> 4)) return true;
		return false;
	}
	public function entityCollidesFully(e:Entity, x:Float, y:Float, col:Collision.TILE_COLLISION_TYPE) {
		if(getCollisionAt(x - e.cradius, y - e.cradius) != col) return false;
		if(getCollisionAt(x + e.cradius, y - e.cradius) != col) return false;
		if(getCollisionAt(x + e.cradius, y + e.cradius) != col) return false;
		if(getCollisionAt(x - e.cradius, y + e.cradius) != col) return false;
		return true;
	}
	public function isInRoom(tx:Int, ty:Int, rx:Int, ry:Int) {
		return (tx >= rx * (RWID - 1) && tx < (rx + 1) * (RWID - 1) && ty >= ry * (RHEI - 1) && ty < (ry + 1) * (RHEI - 1));
	}
	public function checkActions() {
		var tx = Std.int(Game.CUR.hero.xx) >> 4;
		var ty = Std.int(Game.CUR.hero.yy) >> 4;
		var toDelete = [];
		for(r in actionRects) {
			if(tx >= r.x && tx < r.x+r.wid && ty >= r.y && ty < r.y+r.hei) {
				switch(r.f) {
					case "blockExit":
						Action.closeExit();
					case "exitFloor0":
						Action.exitFloor0();
					case "exitFloor1":
						Action.exitFloor1();
					default:
						trace("Unknown action");
				}
				toDelete.push(r);
			}
		}
		for(r in toDelete) {
			actionRects.remove(r);
		}
	}
	public function renderLighting() {
		dark = new Sprite();
		dark.graphics.beginFill(0x0);
		dark.graphics.drawRect(0, 0, Const.WID, Const.HEI);
		dark.graphics.endFill();
		dark.alpha = 1.;
		dark.blendMode = BlendMode.LAYER;
		light = new Shape();
		light2 = new Shape();
		var g = light.graphics;
		var g2 = light2.graphics;
		g.beginFill(0xFFFFFF);
		g2.beginFill(0xFFFFFF);
		g.drawCircle(0, 0, 100);
		g2.drawCircle(0, 0, 80);
		g.endFill();
		g2.endFill();
		light.alpha = .4;
		light2.alpha = .6;
		light.blendMode = light2.blendMode = BlendMode.ERASE;
		dark.addChild(light);
		dark.addChild(light2);
		//exit light
		exitLight = new Shape();
		exitLight.blendMode = BlendMode.ERASE;
		g = exitLight.graphics;
		for(i in 0...10) {
			var lwid = 24 + i * 10;
			var lhei = 70 + i * 3;
			g.beginFill(0xFFFFFF, i == 0 ? .4 : .1);
			g.drawRect(Const.WID - lwid, 5 * 16 - lhei * .5, lwid, lhei);
			g.endFill();
		}
		Torch.dark = dark;
	}
	public function replaceLittleLights() {
		light.graphics.clear();
		light2.graphics.clear();
		light.graphics.beginFill(0xFFFFFF);
		light2.graphics.beginFill(0xFFFFFF);
		light.graphics.drawCircle(0, 0, 40);
		light2.graphics.drawCircle(0, 0, 30);
		light.graphics.endFill();
		light2.graphics.endFill();
		light.alpha = .2;
		light2.alpha = .4;
	}
	public function addExitLight() {
		if(exitLight.parent != null) return;
		dark.addChild(exitLight);
	}
	public function removeExitLight() {
		if(exitLight.parent == null) return;
		dark.removeChild(exitLight);
	}
	public function addLighting() {
		if(dark.parent != null) return;
		Game.CUR.frontlm.addChild(dark, 0);
	}
	public function removeLighting() {
		if(dark.parent == null) return;
		dark.parent.removeChild(dark);
	}
	public function fakeTileWasRemoved(id:Int) {
		fakeTileRemoved[id] = true;
	}
}