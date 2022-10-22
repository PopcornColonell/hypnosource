package meta.state.menus;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import meta.MusicBeat.MusicBeatState;
import meta.data.Highscore;
import meta.data.Song;
import meta.data.dependency.Discord;
import meta.data.font.Alphabet;
import meta.subState.UnlockSubstate;

using StringTools;

class MainMenuState extends MusicBeatState
{

	static final unlockedCharacters:Map<String, Array<String>> = [
		'Safety-Lullaby' => ['hypno', 'gf'],
		'Lost-Cause' => ['bf'],
		'Frostbite' => ['red', 'cold_gold', 'pikachu', 'typhlosion'],
		'Insomnia' => ['silver', 'feraligatr'],
		'Monochrome' => ['gold'],
		'Missingno' => ['missingno'],
		'Brimstone' => ['buried_alive', 'gengar', 'muk', 'apparition_gf'],
		'Bygone Purpose' => ['small_hypno'],
		'Pasta Night' => ['lord_x'],
		'Purin' => ['jigglypuff', 'pico'],
		'Amusia' => ['ponyta', 'wigglytuff'],
		'Shinto' => ['shinto'],
		'Shitno' => ['shitno'],
	];

	static final offsetArray:Map<String, FlxPoint> = [
		'hypno' => FlxPoint.weak(200, 100),
		'buried_alive' => FlxPoint.weak(-200, 0),
		'gold' => FlxPoint.weak(-50, 0),
		'silver' => FlxPoint.weak(-50, 0),
		'shinto' => FlxPoint.weak(-150, -50),
	];

	// i really hate random systemms that donht exclude the last character thikgny you fpicejkde out
	public static var theOneFromLastTime:String = '';

	public var optionList:Array<String> = [
		'story',
		'freeplay',
		'credits',
		'pokedex',
		'gallery',
		'options'
	];

	public var lockMap:Map<String, LockSprite> = [];

	public var textGroup:FlxTypedGroup<Alphabet>;
	public var backdrop:FlxBackdrop;

	override public function create() {
		super.create();

		ForeverTools.resetMenuMusic();
		Discord.changePresence('MAIN MENU', 'Main Menu');

		// POKEMON YELLOW LOL
		backdrop = new FlxBackdrop(Paths.image('menus/menu/pokemon_yellow_noise'), 1, 1, true, true, 1, 1);
		add(backdrop);

		var allCharacters:Array<String> = ['hypno'];
		for (i in 0...CoolUtil.difficultyArray.length) {
			for (j in unlockedCharacters.keys())
				if (Highscore.getScore(j, i) != 0) {
					for (h in unlockedCharacters[j])
						if (!allCharacters.contains(h) && theOneFromLastTime != h)
							allCharacters.push(h);
				}
		}
		var newCharacter:String = allCharacters[FlxG.random.int(0, allCharacters.length - 1)];
		theOneFromLastTime = newCharacter;

		var menuSprite:FlxSprite = new FlxSprite();
		menuSprite.frames = Paths.getSparrowAtlas('menus/menu/${newCharacter}_menu');
		menuSprite.animation.addByPrefix('idle', '${newCharacter.replace('_', ' ')} menu instance 1', 24, true);
		menuSprite.animation.play('idle');
		menuSprite.setPosition(FlxG.width, FlxG.height);
		menuSprite.setGraphicSize(Std.int(menuSprite.width * 0.8));
		menuSprite.updateHitbox();

		menuSprite.x -= menuSprite.width; 
		menuSprite.y -= menuSprite.height;
		if (offsetArray.exists(newCharacter)) {
			menuSprite.x += offsetArray[newCharacter].x * menuSprite.scale.x;
			menuSprite.y += offsetArray[newCharacter].y * menuSprite.scale.y;
		}
		menuSprite.antialiasing = true;
		add(menuSprite);

		var lockGroup:FlxTypedGroup<LockSprite> = new FlxTypedGroup<LockSprite>();
		textGroup = new FlxTypedGroup<Alphabet>();
		for (i in 0...optionList.length) {
			var alphabet:Alphabet = new Alphabet(0, i*64, optionList[i], true);
			alphabet.alpha = 0;
			alphabet.y = FlxG.height / 2 - ((optionList.length / 2) - i) * (96 / (optionList.length/6));
			alphabet.x = 32 + Math.pow(Math.abs(i - (optionList.length / 2)), 2) * (16 / (optionList.length / 6));
			textGroup.add(alphabet);

			if (!FlxG.save.data.mainMenuOptionsUnlocked.contains(optionList[i])) {
				alphabet.infiniteShuffle = true;
				var newLock:LockSprite = new LockSprite();
				newLock.scale.set(0.75, 0.75);
				lockMap.set(optionList[i], newLock);
				lockGroup.add(newLock);
			}
		}
		add(textGroup);
		add(lockGroup);
	}

	public var curSelection:Int = 0;
	public var lastSelection:Int = 0;
	public var canSelect:Bool = true;
	override public function update(elapsed:Float) {
		super.update(elapsed);
		
		var elapsedLerp:Float = (elapsed / (1 / 10));
		for (i in 0...textGroup.members.length) {
			if (!FlxG.save.data.mainMenuOptionsUnlocked.contains(optionList[i])) {
				var alphabet = textGroup.members[i];
				alphabet.infiniteShuffle = true;
				var curLock = lockMap.get(optionList[i]);
				curLock.alpha = alphabet.alpha;
				// curLock.setPosition(alphabet.x + (alphabet.length / 2) - curLock.width / 2, alphabet.y + alphabet.length / 2 - curLock.height / 2);
				curLock.x = (alphabet.members[0].x
					+ (alphabet.members[alphabet.members.length - 1].posX + 50) / 2)
					- curLock.width / 2;
				curLock.y = (alphabet.members[0].y) - (alphabet.height / 2);
			}
			else {
				var alphabet = textGroup.members[i];
				alphabet.infiniteShuffle = false;
				if (lockMap.exists(optionList[i])) {
					var curLock = lockMap.get(optionList[i]);
					curLock.unlock();
					FlxG.sound.play(Paths.sound('errorMenu'));
					lockMap.remove(optionList[i]);
				}
			}

			if (canSelect) 
				textGroup.members[i].alpha = 0.6;
			else textGroup.members[i].alpha = FlxMath.lerp(textGroup.members[i].alpha, 0, elapsedLerp / 2);
			if (i == curSelection)
				textGroup.members[i].alpha = 1;
		}
		
		backdrop.x += (elapsed / (1/60)) / 2;
		backdrop.y = Math.sin(backdrop.x / 48) * 48;

		var up:Bool = controls.UI_UP_P;
		var down:Bool = controls.UI_DOWN_P;
		var accept:Bool = controls.ACCEPT;

		if (canSelect 
			// || Main.hypnoDebug
			// i use this bug too much lol
			) {
			if (up)
				curSelection--;
			if (down)
				curSelection++;
	
			if (curSelection != lastSelection) {
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
				//
				if (curSelection < 0)
					curSelection = textGroup.members.length - 1;
				if (curSelection > textGroup.members.length - 1)
					curSelection = 0;
				lastSelection = curSelection;
			}

			if (accept) {
				if ((FlxG.save.data.mainMenuOptionsUnlocked.contains(optionList[curSelection])))
					{
						FlxG.sound.play(Paths.sound('confirmMenu'));
						FlxFlicker.flicker(textGroup.members[curSelection], 0.85, 0.06 * 2, true, false, function(flick:FlxFlicker)
						{
							switch (optionList[curSelection])
							{
								case 'story':
									Main.switchState(this, new StoryMenuState());
								case 'freeplay':
									Main.switchState(this, new ShopState());
								case 'pokedex':
									Main.switchState(this, new PokedexState());
								case 'options':
									openSubState(new OptionsMenuState());
									// Main.switchState(this, new OptionsMenuState());
								case 'credits':
									Main.switchState(this, new CreditsMenuState());
								case 'gallery':
									Main.switchState(this, new GalleryState());
								default:
									canSelect = true;
							}
						});
						canSelect = false;
					}
				else
					{
						FlxG.sound.play(Paths.sound('errorMenu'));
						camera.shake(0.005, 0.06);
					}
			}
		}

		if (Main.hypnoDebug && FlxG.keys.justPressed.SEVEN) //DEBUG UNLOCKS ALL PROGRESSION
			{
				FlxG.save.data.mainMenuOptionsUnlocked = ['story', 'freeplay', 'credits', 'pokedex', 'gallery', 'options'];
				FlxG.save.data.cartridgesOwned = ['HypnoWeek', 'LostSilverWeek', 'GlitchWeek'];
				FlxG.save.data.unlockedSongs = ['safety-lullaby', 'left-unchecked', 'lost-cause', 'frostbite', 'insomnia', 'monochrome', 'missingno', 'brimstone', 'amusia', 'dissension', 'purin', 'death-toll', 'isotope', 'bygone-purpose', 'pasta-night', 'shinto', 'shitno'];
			}

		if (Main.hypnoDebug && FlxG.keys.justPressed.DELETE) {
			FlxG.save.erase();
			FlxG.save.flush();
			FlxG.resetGame();
		}

		// unlock decision stuffs lmao
		if (FlxG.save.data.queuedUnlocks != null && FlxG.save.data.queuedUnlocks.length > 0) {
			var curUnlock:String = FlxG.save.data.queuedUnlocks[0];
			if (curUnlock != null) 
				openSubState(new UnlockSubstate(curUnlock));
		}
		//
	}
}
