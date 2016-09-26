/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.input;

class GMouseInputType {
    inline static public var MOUSE_DOWN:String = "mouseDown";
    inline static public var MOUSE_MOVE:String = "mouseMove";
    inline static public var MOUSE_UP:String = "mouseUp";
    inline static public var MOUSE_OVER:String = "mouseOver";
    inline static public var MOUSE_OUT:String = "mouseOut";
    inline static public var RIGHT_MOUSE_DOWN:String = "rightMouseDown";
    inline static public var RIGHT_MOUSE_UP:String = "rightMouseUp";
    inline static public var MOUSE_WHEEL:String = "mouseWheel";

	#if flash
    inline static public function fromNative(p_nativeType:String):String {
        var type:String = "";
        switch (p_nativeType) {
            case "mouseMove":
                type = MOUSE_MOVE;
            case "mouseDown":
                type = MOUSE_DOWN;
            case "mouseUp":
                type = MOUSE_UP;
            case "mouseWheel":
                type = MOUSE_WHEEL;
			case "rightMouseDown":
                type = RIGHT_MOUSE_DOWN;
			case "rightMouseUp":
                type = RIGHT_MOUSE_UP;
        }

        return type;
    }
	#elseif js
	inline static public function fromNative(p_nativeType:String):String {
        var type:String = "";
        switch (p_nativeType) {
            case "mousemove" | "touchmove":
                type = MOUSE_MOVE;
            case "mousedown" | "touchstart":
                type = MOUSE_DOWN;
            case "mouseup" | "touchend" | "touchcancel":
                type = MOUSE_UP;
        }

        return type;
    }
	#end
}
