package meta.state.menus;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxAssets;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import gameObjects.Character;
import sys.thread.Thread;

enum PreloadType
{
	atlas;
	image;
}

class PreloadState extends FlxState
{
	var globalRescale:Float = 2 / 3;
	var preloadStart:Bool = false;

	var loadText:FlxText;
	var assetStack:Map<String, PreloadType> = [];
	var maxCount:Int;

	public static var preloadedAssets:Map<String, FlxGraphic>;

	var backgroundGroup:FlxTypedGroup<FlxSprite>;
	var bg:FlxSprite;

	public static var unlockedSongs:Array<Bool> = [false, false];

	override public function create()
	{
		super.create();

		FlxG.camera.alpha = 0;

		maxCount = Lambda.count(assetStack);
		trace(maxCount);
		// create funny assets
		backgroundGroup = new FlxTypedGroup<FlxSprite>();
		FlxG.mouse.visible = false;

		preloadedAssets = new Map<String, FlxGraphic>();

		bg = new FlxSprite();
		bg.loadGraphic(Paths.image('menus/load/Loading Hypno'));
		bg.setGraphicSize(Std.int(bg.width * globalRescale));
		bg.updateHitbox();
		backgroundGroup.add(bg);

		var gfBg:FlxSprite = new FlxSprite();
		gfBg.loadGraphic(Paths.image('menus/load/Loading GF'));
		gfBg.setGraphicSize(Std.int(gfBg.width * globalRescale));
		gfBg.updateHitbox();
		backgroundGroup.add(gfBg);

		var unownBg:FlxSprite = new FlxSprite();
		unownBg.loadGraphic(Paths.image('menus/load/Loading Unown'));
		unownBg.setGraphicSize(Std.int(unownBg.width * globalRescale));
		unownBg.updateHitbox();
		backgroundGroup.add(unownBg);

		var pendulum:FlxSprite = new FlxSprite();
		pendulum.frames = Paths.getSparrowAtlas('menus/load/Loading Screen Pendelum');
		pendulum.animation.addByPrefix('load', 'Loading Pendelum Finished', 24, true);
		pendulum.animation.play('load');
		pendulum.setGraphicSize(Std.int(pendulum.width * globalRescale));
		pendulum.updateHitbox();
		backgroundGroup.add(pendulum);
		pendulum.x = FlxG.width - (pendulum.width + 10);
		pendulum.y = FlxG.height - (pendulum.height + 10);

		add(backgroundGroup);
		FlxTween.tween(FlxG.camera, {alpha: 1}, 0.5, {
			onComplete: function(tween:FlxTween)
			{
				Thread.create(function()
				{
					assetGenerate();
				});
			}
		});

		loadText = new FlxText(5, FlxG.height - (32 + 5), 0, 'Loading...', 32);
		loadText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(loadText);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	var storedPercentage:Float = 0;

	function assetGenerate()
	{
		//
		var countUp:Int = 0;
		for (i in assetStack.keys())
		{
			trace('calling asset $i');

			var savedGraphic:FlxGraphic = Paths.returnGraphic(i);
			savedGraphic.persist = true;
            Paths.excludeAsset(i);
			trace(savedGraphic + ', yeah its working');

			countUp++;
			storedPercentage = countUp / maxCount;
			loadText.text = 'Loading... Progress at ${Math.floor(storedPercentage * 100)}%';
		}

		///*
		FlxTween.tween(FlxG.camera, {alpha: 0}, 0.5, {
			onComplete: function(tween:FlxTween)
			{
				FlxG.switchState(new DisclaimerState());
			}
		});
		//*/
	}
}