package com.genome2d.textures;
import com.genome2d.assets.GImageAsset;
import com.genome2d.assets.GImageAssetType;
import com.genome2d.context.IGContext;
import com.genome2d.debug.GDebug;
import com.genome2d.geom.GRectangle;
import com.genome2d.textures.GTexture;
import com.genome2d.textures.GTextureBase;

#if flash
import flash.display.BitmapData;
import flash.display.Bitmap;
import flash.utils.ByteArray;
#end

#if js
import js.html.ImageElement;
#end

@:access(com.genome2d.textures.GTexture)
class GTextureManager {
	static private var g2d_context:IGContext;
    static public function init(p_context:IGContext):Void {
		g2d_context = p_context;
        g2d_textures = new Map<String,GTexture>();
    }

    static public var defaultFilteringType:Int = GTextureFilteringType.LINEAR;

    static private var g2d_textures:Map<String,GTexture>;
    static public function getAllTextures():Map<String,GTexture> {
        return g2d_textures;
    }

    static private function g2d_addTexture(p_texture:GTexture):Void {
        if (p_texture.id == null || p_texture.id.length == 0) GDebug.error("Invalid texture id");
        if (g2d_textures.exists(p_texture.id)) GDebug.error("Duplicate textures id: "+p_texture.id);
        g2d_textures.set(p_texture.id, p_texture);
    }

    static private function g2d_removeTexture(p_texture:GTexture):Void {
        g2d_textures.remove(p_texture.id);
    }

    static public function getTexture(p_id:String):GTexture {
        return g2d_textures.get(p_id);
    }
	
	static public function getTextures(p_ids:Array<String>):Array<GTexture> {
		var textures:Array<GTexture> = new Array<GTexture>();
		for (id in p_ids) textures.push(g2d_textures.get(id));
        return textures;
    }
	
	static public function findTextures(p_regExp:EReg = null):Array<GTexture> {
        var found:Array<GTexture> = new Array<GTexture>();
        for (tex in g2d_textures) {
            if (p_regExp != null) {
                if (p_regExp.match(tex.id)) {
                    found.push(tex);
                }
            } else {
                found.push(tex);
            }
        }

        return found;
    }

    static public function disposeAll():Void {
        for (texture in g2d_textures) {
			if (texture.id.indexOf("g2d_") != 0) texture.dispose();
        }
    }

    static public function invalidateAll(p_force:Bool):Void {
		for (texture in g2d_textures) {
			texture.invalidateNativeTexture(p_force);
        }
    }
	
	static public function createTexture(p_id:String, p_source:Dynamic, p_scaleFactor:Float = 1, p_repeatable:Bool = false, p_format:String = "bgra"):GTexture {
		var texture:GTexture = null;
		// Create from asset
		if (Std.is(p_source, GImageAsset)) {
			var imageAsset:GImageAsset = cast p_source;
			switch (imageAsset.type) {
				#if flash
				case GImageAssetType.BITMAPDATA:
					texture = new GTexture(g2d_context, p_id, imageAsset.bitmapData);
				case GImageAssetType.ATF:
					texture = new GTexture(g2d_context, p_id, imageAsset.bytes);
				#elseif js
				case GImageAssetType.IMAGEELEMENT:
					texture = new GTexture(g2d_context, p_id, imageAsset.imageElement);
				#end
			}
		#if flash
		// Create from bitmap data
		} else if (Std.is(p_source, BitmapData)) {
			texture = new GTexture(g2d_context, p_id, p_source);
		// Create from ATF byte array
		} else if (Std.is(p_source, ByteArray)) {
			texture = new GTexture(g2d_context, p_id, p_source);
			
		// Create from Embedded
		} else if (Std.is(p_source, Class)) {
			var bitmap:Bitmap = cast Type.createInstance(p_source, []);
			texture = new GTexture(g2d_context, p_id, bitmap.bitmapData);
		#elseif js
		} else if (Std.is(p_source, ImageElement)) {
			texture = new GTexture(g2d_context, p_id, p_source);
		#end
		// Create render texture
		} else if (Std.is(p_source, GRectangle)) {
			texture = new GTexture(g2d_context, p_id, p_source);
		}

		if (texture != null) {
			texture.repeatable = p_repeatable;
			texture.scaleFactor = p_scaleFactor;
			texture.invalidateNativeTexture(false);
		} else {
			GDebug.error("Invalid texture source.");
		}

        return texture;
    }
	
	static public function createSubTexture(p_id:String, p_texture:GTexture, p_region:GRectangle, p_frame:GRectangle = null, p_prefixParentId:Bool = true):GTexture {
		var texture:GTexture = new GTexture(g2d_context, p_prefixParentId?p_texture.id+"_"+p_id:p_id, p_texture);
		
		texture.region = p_region;
		
		if (p_frame != null) {
            texture.g2d_frame = p_frame;
            texture.pivotX = (p_frame.width-p_region.width)*.5 + p_frame.x;
            texture.pivotY = (p_frame.height-p_region.height)*.5 + p_frame.y;
        }

        return texture;
	}

    static public function createRenderTexture(p_id:String, p_width:Int, p_height:Int, p_scaleFactor:Float = 1):GTexture {
        var texture:GTexture = new GTexture(g2d_context, p_id, new GRectangle(0,0,p_width, p_height));
        texture.invalidateNativeTexture(false);
        return texture;
    }
	 
	static public function createSubTextures(p_texture:GTexture, p_xml:Xml, p_prefixParentId:Bool = true):Array<GTexture> {
        var textures:Array<GTexture> = new Array<GTexture>();

        var root = p_xml.firstElement();
        var it:Iterator<Xml> = root.elements();

        while(it.hasNext()) {
            var node:Xml = it.next();

            var region:GRectangle = new GRectangle(Std.parseInt(node.get("x")), Std.parseInt(node.get("y")), Std.parseInt(node.get("width")), Std.parseInt(node.get("height")));
			var frame:GRectangle = null;
			
            if (node.get("frameX") != null && node.get("frameWidth") != null && node.get("frameY") != null && node.get("frameHeight") != null) {
                frame = new GRectangle(Std.parseInt(node.get("frameX")), Std.parseInt(node.get("frameY")), Std.parseInt(node.get("frameWidth")), Std.parseInt(node.get("frameHeight")));
            }
			textures.push(createSubTexture(node.get("name"), p_texture, region, frame, p_prefixParentId));
        }

        return textures;
	}
}
