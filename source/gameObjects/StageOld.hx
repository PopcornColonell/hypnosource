package gameObjects;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import gameObjects.background.*;
import haxe.ds.List;
import meta.CoolUtil;
import meta.data.Conductor;
import meta.data.dependency.FNFSprite;
import meta.state.PlayState;

using StringTools;

/**
	This is the stage class. It sets up everything you need for stages in a more organised and clean manner than the
	base game. It's not too bad, just very crowded. I'll be adding stages as a separate
	thing to the weeks, making them not hardcoded to the songs.
**/
class StageOld extends FlxTypedGroup<FlxSprite>
{
	// "haha this is bad", "haha I dont care"
	public var bygoneFuck:FlxSprite;
	public var bygoneAlexisPassing:FlxSprite;
	public var bygoneAlexisGate:FlxSprite;
	public var bigHypno:FlxSprite;
	public var bridge2:FlxSprite;
	public var nursejoy:FlxSprite;
	public var bygonStuff:haxe.ds.List<FlxSprite> = new haxe.ds.List<FlxSprite>(); // did you just.... make a list kade?????
	public var bygonNewStuff:haxe.ds.List<FlxSprite> = new haxe.ds.List<FlxSprite>();



	public var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;

	public var brimstoneBackground:FlxSprite;

	public var curStage:String;

	var daPixelZoom = PlayState.daPixelZoom;

	public var foreground:FlxTypedGroup<FlxBasic>;

	public var pastaBoppers:Array<FNFSprite> = [];
	var saled:FNFSprite;
	public var gold:FNFSprite;

	public function new(curStage)
	{
		super();
		this.curStage = curStage;

		/// get hardcoded stage type if chart is fnf style
		if (PlayState.determinedChartType == "FNF")
		{
			// this is because I want to avoid editing the fnf chart type
			// custom stage stuffs will come with forever charts
			switch (CoolUtil.spaceToDash(PlayState.SONG.song.toLowerCase())) {
				case 'missingno':
					curStage = 'missingno';
				case 'dissension':
					curStage = 'mikes-room';
				case 'safety-lullaby' | 'left-unchecked':
					curStage = 'alley';
				case 'monochrome':
					curStage = 'none';
				case 'frostbite':
					curStage = 'mountain';
				case 'brimstone':
					curStage = 'buried';
				case 'insomnia':
					curStage = 'feralisleep';
				case 'bygone-purpose':
					curStage = 'bygone';
				case 'purin':
					curStage = 'pokecenter';
				case 'shinto':
					curStage = 'shitty-cave';
				case 'sansno':
					curStage = 'core';
				case 'missingcraft':
					curStage = 'missingcraft';
				case 'pasta-night':
					curStage = 'bar';
				case 'lost-cause':
					curStage = 'cave';
				case 'death-toll':
					curStage = 'hell';
				default:
					curStage = 'stage';
			}
			PlayState.curStage = curStage;
		}

		// to apply to foreground use foreground.add(); instead of add();
		foreground = new FlxTypedGroup<FlxBasic>();

		//
		switch (curStage)
		{

			case 'core':
				PlayState.defaultCamZoom = 0.8;
				curStage = 'core';
				var bg:FNFSprite = new FNFSprite(-200, 0).loadGraphic(Paths.image('backgrounds/sansno/lukewarm-land', 'shitpost'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;
				add(bg);

			case 'missingcraft':
				PlayState.defaultCamZoom = 0.6;
				curStage = 'missingcraft';
				var bg:FNFSprite = new FNFSprite(0, 0).loadGraphic(Paths.image('backgrounds/missingcraf/unknown', 'shitpost'));
				bg.setGraphicSize(Std.int(bg.width * 1.5));
				bg.updateHitbox();
				bg.x -= bg.width / 4;
				// bg.y += bg.height / 3;
				bg.antialiasing = true;
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;
				add(bg);

				var gf:Character = new Character().setCharacter(0, 0, 'minecrftgf');
				gf.screenCenter();
				add(gf);

			case 'missingno':

			case 'pokecenter':

				
			default:
				PlayState.defaultCamZoom = 0.9;
				curStage = 'stage';
				var bg:FNFSprite = new FNFSprite(-600, -200).loadGraphic(Paths.image('backgrounds/' + curStage + '/stageback'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;

				// add to the final array
				add(bg);

				var stageFront:FNFSprite = new FNFSprite(-650, 600).loadGraphic(Paths.image('backgrounds/' + curStage + '/stagefront'));
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				stageFront.antialiasing = true;
				stageFront.scrollFactor.set(0.9, 0.9);
				stageFront.active = false;

				// add to the final array
				add(stageFront);

				var stageCurtains:FNFSprite = new FNFSprite(-500, -300).loadGraphic(Paths.image('backgrounds/' + curStage + '/stagecurtains'));
				stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
				stageCurtains.updateHitbox();
				stageCurtains.antialiasing = true;
				stageCurtains.scrollFactor.set(1.3, 1.3);
				stageCurtains.active = false;

				// add to the final array
				add(stageCurtains);
		}
	}


	// get the dad's position
	public function dadPosition(curStage, boyfriend:Character, dad:Character, camPos:FlxPoint):Void
	{
		var characterArray:Array<Character> = [dad, boyfriend];
		for (char in characterArray) {
			switch (char.curCharacter)
			{

				/*
					if (isStoryMode)
					{
						camPos.x += 600;
						tweenCamIn();
				}*/
				/*
				case 'spirit':
					var evilTrail = new FlxTrail(char, null, 4, 24, 0.3, 0.069);
					evilTrail.changeValuesEnabled(false, false, false, false);
					add(evilTrail);
					*/
			}
		}
	}

	public function repositionPlayers(curStage, boyfriend:Character, dad:Character):Void
	{
		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'missingno':
				dad.x += 55;
				dad.y += 175;

			case 'alley':
				dad.x -= 300;
				if (!PlayState.old) 
					boyfriend.x += 50;

			default:
				// do nothing
		}
	}

	var curLight:Int = 0;
	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;
	var startedMoving:Bool = false;

	

	override function add(Object:FlxSprite):FlxSprite
	{
		if (Init.trueSettings.get('Disable Antialiasing'))
			cast(Object, FlxSprite).antialiasing = false;
		return super.add(Object);
	}
}
