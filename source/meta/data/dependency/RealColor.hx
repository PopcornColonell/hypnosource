package meta.data.dependency;
import flixel.util.FlxColor;

class RealColor {
	public static function fromRGB(Red:Int, Green:Int, Blue:Int, Alpha:Int = 255):FlxColor
		return FlxColor.fromRGB(Red, Green, Blue, Alpha);
}