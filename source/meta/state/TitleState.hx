package meta.state;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import meta.MusicBeat.MusicBeatState;
import meta.data.*;
import meta.data.dependency.Discord;
import meta.data.font.Alphabet;
import meta.state.menus.*;
import openfl.Assets;

using StringTools;

/**
	I hate this state so much that I gave up after trying to rewrite it 3 times and just copy pasted the original code
	with like minor edits so it actually runs in forever engine. I'll redo this later, I've said that like 12 times now

	I genuinely fucking hate this code no offense ninjamuffin I just dont like it and I don't know why or how I should rewrite it
**/
class TitleState extends MusicBeatState
{
	static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;

	var wackyImage:FlxSprite;

	var bgTreesFar:FlxBackdrop;
	var bgTrees:FlxBackdrop;
	var bgGrass:FlxBackdrop;
	var staticBG:FlxSprite;

	override public function create():Void
	{
		controls.setKeyboardScheme(None, false);
		super.create();

		startIntro();
	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var hypnoDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;
	var titleTextSelected:FlxSprite;

	var constantResize:Float = 0.75;

	function startIntro()
	{
		if (!initialized)
		{
			///*
			Discord.changePresence('TITLE SCREEN', 'Main Menu');
			
			ForeverTools.resetMenuMusic(true);
		}

		persistentUpdate = true;

		staticBG = new FlxSprite(0, 0).loadGraphic(Paths.image('menus/title/staticBG'));
		add(staticBG);
		
		bgTreesFar = new FlxBackdrop(Paths.image('menus/title/bgTreesfar'), 1, 1, true, true, 1, 1);
		add(bgTreesFar);

		bgTrees = new FlxBackdrop(Paths.image('menus/title/bgTrees'), 1, 1, true, true, 1, 1);
		bgTrees.x += 350;
		add(bgTrees);

		bgGrass = new FlxBackdrop(Paths.image('menus/title/bgGrass'), 1, 1, true, true, 1, 1);
		add(bgGrass);

		var vintage:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('menus/title/darknessOverlay'));
		add(vintage);

		/*if (!FlxG.save.data.notFirstTime)
		{
			hypnoDance = new FlxSprite(FlxG.width * 0.6, -200);
			hypnoDance.frames = Paths.getSparrowAtlas('menus/title/StartScreen Hypno');
			hypnoDance.animation.addByPrefix('bop', 'Hypno StartScreen', 24, true);
			hypnoDance.animation.play('bop');
			hypnoDance.setGraphicSize(Std.int(hypnoDance.width * constantResize));
			hypnoDance.updateHitbox();
			// hypnoDance.setPosition(hypnoDance.x + FlxG.width * (1 - constantResize), hypnoDance.y + FlxG.height * (1 - constantResize));
			hypnoDance.antialiasing = true;
			add(hypnoDance);
		}
		*/

		logoBl = new FlxSprite();
		logoBl.frames = Paths.getSparrowAtlas('menus/title/Start_Screen_Assets');
		logoBl.antialiasing = true;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, true);
		logoBl.animation.play('bump');
		logoBl.setGraphicSize(Std.int(logoBl.width * 0.6));
		logoBl.updateHitbox();
		// logoBl.x += ;
		// logoBl.y += 200;
		add(logoBl);
		logoBl.screenCenter();
		logoBl.y -= 65;
		// logoBl.color = FlxColor.BLACK;

		/*if (!FlxG.save.data.notFirstTime)
		{
			gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.45);
			gfDance.frames = Paths.getSparrowAtlas('menus/title/StartscreenGF');
			gfDance.animation.addByPrefix('bop', 'GF Startscreen', 24, true);
			gfDance.animation.play('bop');
			gfDance.setGraphicSize(Std.int(gfDance.width * constantResize));
			gfDance.updateHitbox();
			gfDance.antialiasing = true;
			add(gfDance);
		}
		*/

		// gfDance.setPosition(gfDance.x + FlxG.width * (1 - constantResize), gfDance.y + FlxG.height * (1 - constantResize));
		// logoBl.shader = swagShader.shader;

		titleText = new FlxSprite(0, 0).loadGraphic(Paths.image('menus/title/pressStart'));
		titleText.setGraphicSize(Std.int(titleText.width * 0.6));
		titleText.antialiasing = true;
		titleText.screenCenter(X);
		titleText.y += 455;
		add(titleText);
		FlxTween.tween(titleText, {alpha: 0.85}, 0.01, {ease: FlxEase.linear, type: LOOPING});

		titleTextSelected = new FlxSprite(0, 0).loadGraphic(Paths.image('menus/title/pressStartSelected'));
		titleTextSelected.setGraphicSize(Std.int(titleTextSelected.width * 0.6));
		titleTextSelected.antialiasing = true;
		titleTextSelected.screenCenter(X);
		titleTextSelected.y += 455;
		titleTextSelected.visible = false;
		add(titleTextSelected);
		FlxTween.tween(titleTextSelected, {alpha: 0.85}, 0.01, {ease: FlxEase.linear, type: LOOPING});

		// var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menus/base/title/logo'));
		// logo.screenCenter();
		// logo.antialiasing = true;
		// add(logo);

		// FlxTween.tween(logoBl, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});
		// FlxTween.tween(logo, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "ninjamuffin99\nPhantomArcade\nkawaisprite\nevilsk8er", true);
		credTextShit.screenCenter();

		// credTextShit.alignment = CENTER;

		credTextShit.visible = false;

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('menus/base/title/newgrounds_logo'));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = true;

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		if (initialized)
			skipIntro();
		else
			initialized = true;

		//PROGRESSION DATA
		if (FlxG.save.data.money == null)
			FlxG.save.data.money = 0;
		if (FlxG.save.data.mainMenuOptionsUnlocked == null)
			FlxG.save.data.mainMenuOptionsUnlocked = ['story', 'credits', 'options'];
		if (FlxG.save.data.cartridgesOwned == null)
			FlxG.save.data.cartridgesOwned = ['HypnoWeek'];
		if (FlxG.save.data.itemsPurchased == null)
			FlxG.save.data.itemsPurchased = [];
		if (FlxG.save.data.playedSongs == null)
			FlxG.save.data.playedSongs = [];
		if (FlxG.save.data.unlockedSongs == null)
			FlxG.save.data.unlockedSongs = []; 
		//
		if (FlxG.save.data.queuedUnlocks == null)
			FlxG.save.data.queuedUnlocks = []; 
		if (FlxG.save.data.doneUnlocks == null)
			FlxG.save.data.doneUnlocks = [];

		if (FlxG.save.data.freeplayFirstTime == null) {FlxG.save.data.freeplayFirstTime = false;}
		if (FlxG.save.data.buyVinylFirstTime == null) {FlxG.save.data.buyVinylFirstTime = false;}
		if (FlxG.save.data.activatedPurin == null) {FlxG.save.data.activatedPurin = false;}

		// credGroup.add(credTextShit);
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		bgTreesFar.x += (elapsed / (1 / 120)) / 2.25;
		bgTrees.x += (elapsed / (1 / 120)) / 1.75;
		bgGrass.x += (elapsed / (1 / 120)) / 1.70;

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;
		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		if (pressedEnter && !transitioning && skippedIntro)
		{
			titleText.visible = false;
			titleTextSelected.visible = true;

			titleText = new FlxSprite(0, 0).loadGraphic(Paths.image('menus/title/pressStartSelected'));
			titleText.setGraphicSize(Std.int(titleText.width * 0.6));
			titleText.antialiasing = true;
			titleText.screenCenter(X);
			titleText.y += 455;
			add(titleText);
			titleText.blend = ADD;
			FlxTween.tween(titleText, {'scale.x': 0.825, 'scale.y': 0.825, alpha: 0.001}, 1.5, {ease: FlxEase.quadOut});
			
			FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

			transitioning = true;
			// FlxG.sound.music.stop();

			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				// {
				if (FlxG.save.data.notFirstTime == null 
				|| FlxG.save.data.notFirstTime == false)
				{
					FlxG.save.data.notFirstTime = true;
					FlxG.save.flush();
				}
				Main.switchState(this, new MainMenuState());
				// }
			});
			// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
		}

		// hi game, please stop crashing its kinda annoyin, thanks!
		if (pressedEnter && !skippedIntro && initialized)
		{
			skipIntro();
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function addMoreText(text:String)
	{
		var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
		coolText.screenCenter(X);
		coolText.y += (textGroup.length * 60) + 200;
		credGroup.add(coolText);
		textGroup.add(coolText);
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	override function beatHit()
	{
		super.beatHit();

		logoBl.animation.play('bump');
		danceLeft = !danceLeft;

		if (gfDance != null)
			gfDance.animation.play('bop');
		if (hypnoDance != null)
			hypnoDance.animation.play('bop');

		FlxG.log.add(curBeat);
		if (!skippedIntro)
			skipIntro();
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			remove(ngSpr);

			FlxG.camera.flash(FlxColor.BLACK, 4);
			remove(credGroup);
			skippedIntro = true;
		}
		//
	}
}
