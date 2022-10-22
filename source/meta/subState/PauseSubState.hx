package meta.subState;

import sys.FileSystem;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import gameObjects.userInterface.menu.Textbox;
import meta.MusicBeat.MusicBeatSubState;
import meta.data.font.Alphabet;
import meta.state.*;
import meta.state.menus.*;
import sys.thread.Mutex;
import sys.thread.Thread;

class PauseSubState extends MusicBeatSubState
{
	var grpText:Array<FlxText> = [];

	var menuItems:Array<String> = ['RESUME', 'RESTART', 'OPTIONS', 'EXIT'];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;
	var mainTextbox:Textbox;
	var bg:FlxSprite;

	var mutex:Mutex;
	var selector:FlxSprite;

	var pausePortraitLeft:FlxSprite;
	var pausePortraitRight:FlxSprite;

	public function new(x:Float, y:Float)
	{
		super();

		mutex = new Mutex();
		Thread.create(function(){
			mutex.acquire();
			pauseMusic = new FlxSound().loadEmbedded(Paths.music('LullabyPause'), true, true);
			pauseMusic.volume = 0;
			pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));
			FlxG.sound.list.add(pauseMusic);
			mutex.release();
		});

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var portraitDistance:Float = 1000;
		pausePortraitLeft = new FlxSprite(portraitDistance * -1, 0);
		pausePortraitLeft.loadGraphic(Paths.image('pause/' + PlayState.SONG.song.toLowerCase()+ '/left' + PlayState.instance.pausePortraitPrefix[0]));
		pausePortraitLeft.scrollFactor.set();
		if (!FileSystem.exists(Paths.getPath('pause/' + PlayState.SONG.song.toLowerCase()+ '/left' + PlayState.instance.pausePortraitPrefix[0] + '.png', IMAGE))) add(pausePortraitLeft);
		pausePortraitLeft.x = portraitDistance * -1;
		pausePortraitLeft.alpha = 0;
		if (PlayState.instance.pausePortraitRevealed[0] == false) pausePortraitLeft.color = FlxColor.BLACK;

		pausePortraitRight = new FlxSprite((FlxG.width / 2) + portraitDistance, 0);
		pausePortraitRight.loadGraphic(Paths.image('pause/' + PlayState.SONG.song.toLowerCase()+ '/right' + PlayState.instance.pausePortraitPrefix[1]));
		pausePortraitRight.scrollFactor.set();
		if (!FileSystem.exists(Paths.getPath('pause/' + PlayState.SONG.song.toLowerCase()+ '/right' + PlayState.instance.pausePortraitPrefix[1] + '.png', IMAGE))) add(pausePortraitRight);
		pausePortraitRight.x = (FlxG.width / 2) + portraitDistance;
		pausePortraitRight.alpha = 0;
		if (PlayState.instance.pausePortraitRevealed[1] == false) pausePortraitRight.color = FlxColor.BLACK;

		mainTextbox = new Textbox(x, y);
		mainTextbox.scrollFactor.set();
		mainTextbox.screenCenter();
		// mainTextbox.scale.set(6, 6);
		add(mainTextbox);

		for (i in menuItems) {
			var newText:FlxText = new FlxText(x, y, 16 * 8, i);
			newText.setFormat(Paths.font('poketext.ttf'), 8, FlxColor.BLACK);
			newText.screenCenter();
			newText.scrollFactor.set();
			add(newText);
			grpText.push(newText);
		}
		expanseHorizontal = 8 / mainTextbox.boxInternalDivision;
		expanseVertical = 4 / mainTextbox.boxInternalDivision;
		mainTextbox.boxInterval = Std.int(mainTextbox.boxInterval / mainTextbox.boxInternalDivision);

		selector = new FlxSprite();
		selector.loadGraphic(Paths.image('UI/pixel/selector'));
		selector.scrollFactor.set();
		add(selector);

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	var resize:Float = 6;
	var ogLerpVal:Float = 12.8;
	var lerpVal:Float = 16;
	var portraitLerp:Float = 12;
	var closing:Bool = false;
	var opening:Bool = true;

	var expanseHorizontal:Float;
	var expanseVertical:Float;

	var lockControls:Bool = false;

	override public function update(elapsed:Float) {
		
		var fakeElapsed:Float = CoolUtil.clamp(elapsed, 0, 1);
		if (fakeElapsed > 0) {
			if (!closing) {
				bg.alpha = FlxMath.lerp(bg.alpha, 0.6, fakeElapsed * ogLerpVal);
				//
				pausePortraitLeft.x = FlxMath.lerp(pausePortraitLeft.x, 0, fakeElapsed * portraitLerp);
				pausePortraitLeft.alpha = FlxMath.lerp(pausePortraitLeft.alpha, 1, fakeElapsed * portraitLerp);
				pausePortraitRight.x = FlxMath.lerp(pausePortraitRight.x, 560, fakeElapsed * portraitLerp);
				pausePortraitRight.alpha = FlxMath.lerp(pausePortraitRight.alpha, 1, fakeElapsed * portraitLerp);
			} else {
				bg.alpha = FlxMath.lerp(bg.alpha, 0, fakeElapsed * ogLerpVal);
				pausePortraitLeft.x = FlxMath.lerp(pausePortraitLeft.x, -1000, fakeElapsed * portraitLerp / 2);
				pausePortraitLeft.alpha = FlxMath.lerp(pausePortraitLeft.alpha, 0, fakeElapsed * portraitLerp);
				pausePortraitRight.x = FlxMath.lerp(pausePortraitRight.x, 1000, fakeElapsed * portraitLerp / 2);
				pausePortraitRight.alpha = FlxMath.lerp(pausePortraitRight.alpha, 0, fakeElapsed * portraitLerp);
			}

			if (opening)
			{
				lerpVal *= 1.05;
				if (mainTextbox.scale.x >= 5)
				{
					lerpVal = ogLerpVal / 1.5;
					resize = 4;
					opening = false;
				}

				mainTextbox.scale.x = FlxMath.lerp(mainTextbox.scale.x, resize, fakeElapsed * lerpVal);
				mainTextbox.scale.y = FlxMath.lerp(mainTextbox.scale.y, resize, fakeElapsed * lerpVal * 2);
			}
			else
			{
				if (closing)
				{
					mainTextbox.scale.x = FlxMath.lerp(mainTextbox.scale.x, resize, fakeElapsed * lerpVal * 2);
					mainTextbox.scale.y = FlxMath.lerp(mainTextbox.scale.y, resize, fakeElapsed * lerpVal);
				}
				else
				{
					mainTextbox.scale.x = FlxMath.lerp(mainTextbox.scale.x, resize, fakeElapsed * lerpVal);
					mainTextbox.scale.y = FlxMath.lerp(mainTextbox.scale.y, resize, fakeElapsed * lerpVal * 2);
				}

				if (mainTextbox.scale.x <= resize + 0.0125)
					mainTextbox.scale.x = resize;
				if (mainTextbox.scale.y <= resize + 0.0125)
					mainTextbox.scale.y = resize;
				//
				if (mainTextbox.boxWidth <= expanseHorizontal + 0.0125)
					mainTextbox.boxWidth = expanseHorizontal;
				if (mainTextbox.boxHeight <= expanseVertical + 0.0125)
					mainTextbox.boxHeight = expanseVertical;

				if (closing)
				{
					lerpVal *= 1.05;
					resize = 0;
					if (mainTextbox.scale.x <= 0.5)
						close();
				}
			}

			mainTextbox.boxWidth = FlxMath.lerp(mainTextbox.boxWidth, expanseHorizontal, fakeElapsed * lerpVal);
			mainTextbox.boxHeight = FlxMath.lerp(mainTextbox.boxHeight, expanseVertical, fakeElapsed * lerpVal);

			super.update(elapsed);
			for (i in 0...grpText.length)
			{
				var text = grpText[i];
				text.scale.set(mainTextbox.scale.x * (mainTextbox.boxWidth / expanseHorizontal),
					mainTextbox.scale.y * (mainTextbox.boxHeight / expanseVertical));
				text.screenCenter();
				text.x += mainTextbox.width / 4 + (mainTextbox.boxInterval * mainTextbox.scale.x);
				text.y -= mainTextbox.height / 4 - (selector.scale.y * mainTextbox.boxInterval * i);
			}

			if (!lockControls)
			{
				var upP = controls.UI_UP_P;
				var downP = controls.UI_DOWN_P;
				var accepted = controls.ACCEPT;
				//
				if (accepted)
				{
					switch (menuItems[curSelected].toLowerCase())
					{
						case 'resume':
							lerpVal = ogLerpVal;
							closing = true;
						case 'restart':
							Main.switchState(this, new PlayState());
						case 'exit':
							if (PlayState.isStoryMode)
								Main.switchState(this, new StoryMenuState());
							else
								Main.switchState(this, new ShopState());
					}
					lockControls = true;
				}

				if (upP)
					curSelected--;
				if (downP)
					curSelected++;
				if (curSelected < 0)
					curSelected = menuItems.length - 1;
				else if (curSelected > menuItems.length - 1)
					curSelected = 0;
			}
			selector.scale.set(mainTextbox.scale.x * (mainTextbox.boxWidth / expanseHorizontal),
				mainTextbox.scale.y * (mainTextbox.boxHeight / expanseVertical));
			selector.setPosition(mainTextbox.x - mainTextbox.width / 2 + (selector.scale.x * mainTextbox.boxInterval),
				(mainTextbox.y
					- mainTextbox.height / 2
					+ (selector.scale.y * mainTextbox.boxInterval * (curSelected + mainTextbox.boxInternalDivision))
					+ (selector.height / mainTextbox.boxInternalDivision)));
			// SHIT BANDAGE SOLUTION LOLLL
			if (mainTextbox.boxInternalDivision == 1) 
				selector.y += (selector.height / 2) + selector.scale.y;
				
			if (pauseMusic != null && pauseMusic.playing) {
				if (pauseMusic.volume < 0.5)
					pauseMusic.volume += 0.025 * fakeElapsed;
			}
			//
		}
	}

	override function destroy()
	{
		if (pauseMusic != null)
			pauseMusic.destroy();
		super.destroy();
	}
}