package meta.state.menus;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import gameObjects.Character;
import meta.MusicBeat.MusicBeatState;
import meta.data.Highscore;
import meta.data.Song;
import meta.data.dependency.Discord;
import overworld.OverworldStage;

using StringTools;
typedef Cartridge = {
    var weekName:String;
    var weekFile:String;
}

class StoryMenuState extends MusicBeatState {

    public var gameboy:FlxSprite;
	public static var cartridgeList:Array<Cartridge> = [
        {
            weekName: "Hypno's Lullaby",
            weekFile: "HypnoWeek"
        }, 
	    {
            weekName: "Lost Silver",
            weekFile: "LostSilverWeek"
        }, 
        {
            weekName: "Missingno",
			weekFile: "GlitchWeek"
        }
    ];
    public var cartridgeSpriteList:Array<FlxSprite> = [];
	public var pitchCorrection:Array<Int> = []; // crappy fix

    var cornerText:FlxText;
	var displacementX:Float = 0;
	var displacementY:Float = 0;

    override public function create() {
        super.create();

		// "Simply use setProperty()" - BAnims

		Discord.changePresence('STORY MODE', 'Main Menu');
		ForeverTools.resetMenuMusic(true);

        gameboy = new FlxSprite();
		gameboy.frames = Paths.getSparrowAtlas('menus/story/CampaignBoy');
        //
		gameboy.animation.addByIndices('idle', 'allcombined', Character.generateIndicesAtPoint(1, 16), '', 24, true);
        //
		gameboy.animation.addByIndices('confirm', 'allcombined', Character.generateIndicesAtPoint(17, 72), '', 24, false);
		gameboy.animation.addByIndices('confirm-alt', 'allcombined', Character.generateIndicesAtPoint(89, 72), '', 24, false);
        //
		gameboy.animation.play('idle');
        gameboy.setGraphicSize(Std.int(gameboy.width * 0.6));
        gameboy.updateHitbox();
		gameboy.screenCenter(X);
		gameboy.y = FlxG.height - gameboy.height + 64;
        gameboy.antialiasing = true;

        for (i in 0...cartridgeList.length) {
			if (FlxG.save.data.cartridgesOwned.contains(cartridgeList[i].weekFile))
				{
					var newCartridge:FlxSprite = new FlxSprite();
					newCartridge.frames = Paths.getSparrowAtlas('menus/story/${cartridgeList[i].weekFile}');
					newCartridge.animation.addByPrefix('idle', '${cartridgeList[i].weekFile}0', 24, true);
					newCartridge.animation.addByPrefix('confirm', '${cartridgeList[i].weekFile}Confirm0', 24, false);
					newCartridge.animation.play('idle');
					//
					newCartridge.setGraphicSize(Std.int(newCartridge.width * 0.6));
					newCartridge.updateHitbox();
					newCartridge.screenCenter();
					newCartridge.antialiasing = true;
					//
					add(newCartridge);
					cartridgeSpriteList.push(newCartridge);
					pitchCorrection.push(i);
				}
        }
		add(gameboy);

		var backgroundHeader:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, Std.int(FlxG.height / 8), FlxColor.WHITE);
		backgroundHeader.scrollFactor.set(0, 0);
		add(backgroundHeader);

        var counterTextSize:Int = 24;
		cornerText = new FlxText().setFormat(Paths.font("poketext.ttf"), counterTextSize, FlxColor.BLACK);
        add(cornerText);
        
		updateSelectionScript(selectedWeek);
		CoolUtil.lerpSnap = true;
    }

    public static var selectedWeek:Int = 0;
    public var centricAngle:Float = 0;

	public var moverCooldown:Float = 0;
    var canControl:Bool = true;

    override public function update(elapsed:Float) {
        super.update(elapsed);

		if (canControl) {
			var left = controls.UI_LEFT;
			var right = controls.UI_RIGHT;
			var newSelection:Int = selectedWeek;

			var direction:Int = (left ? -1 : 0) + (right ? 1 : 0);
			if (Math.abs(direction) > 0)
			{
				if (moverCooldown <= 0)
				{
					newSelection += direction;
					moverCooldown += FlxG.updateFramerate / 4;
				}
				else
					moverCooldown--;
			}
			else
				moverCooldown = 0;
			horizontalSelection(newSelection, cartridgeSpriteList.length - 1);

			if (controls.ACCEPT)
			{
				cartridgeSpriteList[selectedWeek].animation.play('confirm');
				if (selectedWeek == 2) {
					displacementX += 32;
					displacementY -= 16;
				}
				cartridgeSpriteList[selectedWeek].animation.finishCallback = function(name:String) {
					cartridgeSpriteList[selectedWeek].visible = false;
					FlxG.sound.music.fadeOut(0.25, 0, function(tween:FlxTween){
						FlxG.sound.play(Paths.sound('GameboyStartup'), 0.25, false, null, true, function() {
							PlayState.storyDifficulty = 2;
							var difficulty:String = '-' + CoolUtil.difficultyFromNumber(PlayState.storyDifficulty).toLowerCase();
							difficulty = difficulty.replace('-normal', '');

							// FlxTransitionableState.skipNextTransIn = false;
							// FlxTransitionableState.skipNextTransOut = false;

							var old:Bool = false;
							PlayState.isStoryMode = true;
							PlayState.storyPlaylist = Main.gameWeeks[pitchCorrection[selectedWeek]].copy();
							PlayState.storyWeek = pitchCorrection[selectedWeek];
							PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0], old);
							if (pitchCorrection[selectedWeek] == 2) 
								Main.switchState(this, new OverworldStage());
							else
								Main.switchState(this, new PlayState());
						});
						// 
						new FlxTimer().start(0.25, function(timer:FlxTimer){
							FlxG.camera.fade(FlxColor.WHITE, 0.25, false);
						});
					});
                }
                if (pitchCorrection[selectedWeek] == 2) 
					gameboy.animation.play('confirm-alt');
                else gameboy.animation.play('confirm');
				canControl = false;
			}

			if (controls.BACK)
				Main.switchState(this, new MainMenuState());  
        }

		for (i in 0...cartridgeSpriteList.length)
		{
			var curSprite:FlxSprite = cartridgeSpriteList[i];
			curSprite.setPosition(gameboy.x + gameboy.width / 2 - curSprite.width / 2, -225);
			if (i == 2) {
				curSprite.x += displacementX;
				curSprite.y += displacementY;
			}
			var currentAngle:Float = -((i - selectedWeek) * 60);
			curSprite.angle = CoolUtil.fakeLerp(curSprite.angle, currentAngle, elapsed / (1 / 15));
			curSprite.x = curSprite.x - Math.sin(curSprite.angle * (Math.PI / 180)) * 550;
			curSprite.y = curSprite.y + Math.cos(curSprite.angle * (Math.PI / 180)) * 550;
			curSprite.alpha = ((i - selectedWeek == 0) ? 1 : 0.5);
		}
		CoolUtil.lerpSnap = false;
    }

	function horizontalSelection(newSelection:Int, limiter:Int = 1) {
		if (newSelection < 0)
			newSelection = limiter;
		if (newSelection > limiter)
			newSelection = 0;
        
		if (selectedWeek != newSelection)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.5);
			updateSelectionScript(newSelection);
		}
	}

    function updateSelectionScript(newSelection:Int) {
        selectedWeek = newSelection;
		cornerText.text = cartridgeList[pitchCorrection[selectedWeek]].weekName;
		cornerText.x = FlxG.width / 2 - cornerText.width / 2;
		cornerText.y = (FlxG.height / 8) / 2 - cornerText.height / 2;
    }
}