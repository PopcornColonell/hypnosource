package meta;

// import Main;
import flixel.FlxG;
import haxe.Timer;
import openfl.events.Event;
import openfl.system.System;
import openfl.text.TextField;
import openfl.text.TextFormat;

/**
	This is the infoHud class that is derrived from the default FPS class from haxeflixel.
	It displays debug information, like frames per second, and active states.
	Hopefully I can also add memory usage in here (reminder to remove later if I don't know how to)
**/
class InfoHud extends TextField
{
	var times:Array<Float> = [];
	var memPeak:Float = 0;

	// display info
	static var displayFps = true;
	static var displayMemory = true;
	static var displayExtra = true;

	public function new(x:Float, y:Float)
	{
		super();

		this.x = x;
		this.y = x;

		autoSize = LEFT;
		selectable = false;

		defaultTextFormat = new TextFormat(Paths.font("vcr.ttf"), 18, 0xFFFFFF);
		text = "";

		addEventListener(Event.ENTER_FRAME, update);
	}

	static final intervalArray:Array<String> = ['KB', 'MB', 'GB', 'TB'];

	var memInterval:Int = 0;
	var memPeakInterval:Int = 0;

	function update(_:Event)
	{
		var now:Float = Timer.stamp();
		times.push(now);
		while (times[0] < now - 1)
			times.shift();

		var mem:Float = System.totalMemory / 1024 / 1024 * 1000;
		// /*
		for (i in 0...intervalArray.length)
		{
			if (mem > Math.pow(1000, i))
				memInterval = i;
		}
		//  */
		mem /= Math.pow(1000, memInterval);
		mem = Math.round(mem * 100) / 100;
		if (mem > memPeak)
		{
			memPeak = mem;
			memPeakInterval = memInterval;
		}

		if (visible)
		{
			text = '' // set up the text itself
			+ (displayFps ? times.length + " FPS\n" : '') // Framerate
			+ (displayExtra ? Main.mainClassState + "\n" : '') // Current Game State
			+ (displayMemory ? mem + ' ${intervalArray[memInterval]} / ' // Current Memory Usage
			+ memPeak + ' ${intervalArray[memPeakInterval]}\n' : ''); // Total Memory Usage
		}
	}

	public static function updateDisplayInfo(shouldDisplayFps:Bool, shouldDisplayExtra:Bool, shouldDisplayMemory:Bool)
	{
		displayFps = shouldDisplayFps;
		displayExtra = shouldDisplayExtra;
		displayMemory = shouldDisplayMemory;
	}
}
