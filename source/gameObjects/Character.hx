package gameObjects;

/**
	The character class initialises any and all characters that exist within gameplay. For now, the character class will
	stay the same as it was in the original source of the game. I'll most likely make some changes afterwards though!
**/
import flixel.FlxG;
import flixel.addons.util.FlxSimplex;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flxanimate.FlxAnimate;
import gameObjects.userInterface.HealthIcon;
import meta.*;
import meta.data.*;
import meta.data.dependency.FNFSprite;
import meta.state.PlayState;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;
// import flixel.util.typeLimit.OneOfThree;

enum Direction {
	LEFT;
	RIGHT;
}
typedef CharacterData = {
	var offsetX:Float;
	var offsetY:Float;
	var camOffsetX:Float;
	var camOffsetY:Float;
	var quickDancer:Bool;
	var facingDirection:Direction;
	var zoomOffset:Float;
	var healthbarColors:Array<Int>;
}
class Character extends FNFSprite
{
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';

	public var canAnimate:Bool = true;
	public var atlasCharacter:FlxAnimate; // shitty character bandage
	public var isCovering:Bool = false;
	public var hasTransformed:Bool = false;

	public var holdTimer:Float = 0;
	public var idleSuffix:String = '';

	public var characterData:CharacterData;
	public var adjustPos:Bool = true;

	public var forceNoMiss:Bool = false;

	public function new(?isPlayer:Bool = false) {
		super(x, y);
		this.isPlayer = isPlayer;
	}

	public var wigglyState:Int = 0;
	public function setCharacter(x:Float, y:Float, character:String):Character
	{
		curCharacter = character;
		var tex:FlxAtlasFrames;
		antialiasing = true;

		characterData = {
			offsetY: 0,
			offsetX: 0, 
			camOffsetY: 0,
			camOffsetX: 0,
			quickDancer: false,
			facingDirection: LEFT,
			zoomOffset: 0,
			healthbarColors: [0, 0, 0]
		};

		// /*
		if (atlasCharacter != null && atlasCharacter.exists)
			atlasCharacter.destroy();
		// */

		switch (curCharacter)
		{
			case 'gf':
				// GIRLFRIEND CODE
				tex = Paths.getSparrowAtlas('characters/gf/Hypno Girlfriend', true);
				frames = tex;

				animation.addByPrefix('idle', 'gf_idle_not_hypno_2s instance 1', 24, false);
				animation.addByPrefix('idle-alt1', 'gf_idle_ok_maybe_shes_hypno_2s instance 1', 24, false);
				animation.addByPrefix('idle-alt2', 'gf_idle_ok_shes_hypno_2s instance 1', 24, false);
				
				animation.addByPrefix('singUP', 'gf_up instance 1', 24, false);
				animation.addByPrefix('singLEFT', 'gf_left_alt instance 1', 24, false);
				animation.addByPrefix('singRIGHT', 'gf_right_better instance 1', 24, false);
				animation.addByPrefix('singDOWN', 'gf_down instance 1', 24, false);
				animation.addByPrefix('singUPmiss', 'gf_up_MISS instance 1', 24, false);
				animation.addByPrefix('singLEFTmiss', 'gf_left_alt_MISS instance 1', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'gf_right_better_miss instance 1', 24, false);
				animation.addByPrefix('singDOWNmiss', 'gf_down_MISS instance 1', 24, false);

				addOffset("idle", -6);
				addOffset("idle-alt", 5, -8);
				addOffset("idle-alt2", 49, -23);

				addOffset("singUP", -25, 49);
				addOffset("singLEFT", 68, -24);
				addOffset("singRIGHT", -10, -43);
				addOffset("singDOWN", -16, -125);
				addOffset("singUPmiss", -35, 50);
				addOffset("singLEFTmiss", 65, -27);
				addOffset("singRIGHTmiss", -1, -60);
				addOffset("singDOWNmiss", -18, -136);

				playAnim('idle');

				characterData.facingDirection = LEFT;
				characterData.healthbarColors = [165, 0, 77];
				characterData.camOffsetX = 50;
				characterData.camOffsetY = 50;
				characterData.zoomOffset = 0.05;
			
			case 'gf-stand' | 'gf-kneel' | 'gf-stand-death':
				atlasCharacter = new FlxAnimate(x, y, Paths.getPath('images/characters/atlases/phase_3', TEXT));
				switch (curCharacter) {
					case 'gf-kneel':
						atlasCharacter.anim.addByAnimIndices('idle', indicesContinueAmount(14), 24);
						atlasCharacter.anim.addByAnimIndices('singLEFT', indicesContinueAmount(4), 24);
						atlasCharacter.anim.addByAnimIndices('singRIGHT', indicesContinueAmount(4), 24);
						atlasCharacter.anim.addByAnimIndices('singUP', indicesContinueAmount(4), 24);
						atlasCharacter.anim.addByAnimIndices('singDOWN', indicesContinueAmount(4), 24);
						atlasCharacter.anim.addByAnimIndices('singLEFTmiss', indicesContinueAmount(4), 24);
						atlasCharacter.anim.addByAnimIndices('singRIGHTmiss', indicesContinueAmount(4), 24);
						atlasCharacter.anim.addByAnimIndices('singUPmiss', indicesContinueAmount(4), 24);
						atlasCharacter.anim.addByAnimIndices('singDOWNmiss', indicesContinueAmount(4), 24);
						atlasCharacter.anim.addByAnimIndices('bfdrop', indicesContinueAmount(60), 24);

						characterData.healthbarColors = [165, 0, 77];
						characterData.offsetX = 200;
						characterData.offsetY = 100 - 320;
						characterData.facingDirection = RIGHT;
						characterData.zoomOffset = 0.15;

						currentIndex = 154;
						atlasCharacter.anim.addByAnimIndices('FUCKING DIE', indicesContinueAmount(85), 24);

					case 'gf-stand':
						currentIndex = 107;
						atlasCharacter.anim.addByAnimIndices('idle', indicesContinueAmount(14), 24);
						atlasCharacter.anim.addByAnimIndices('singLEFT', indicesContinueAmount(4), 24);
						atlasCharacter.anim.addByAnimIndices('singRIGHT', indicesContinueAmount(4), 24);
						atlasCharacter.anim.addByAnimIndices('singUP', indicesContinueAmount(4), 24);
						atlasCharacter.anim.addByAnimIndices('singDOWN', indicesContinueAmount(4), 24);
						atlasCharacter.anim.addByAnimIndices('singLEFTmiss', indicesContinueAmount(4), 24);
						atlasCharacter.anim.addByAnimIndices('singRIGHTmiss', indicesContinueAmount(4), 24);
						atlasCharacter.anim.addByAnimIndices('singUPmiss', indicesContinueAmount(4), 24);
						atlasCharacter.anim.addByAnimIndices('singDOWNmiss', indicesContinueAmount(4), 24);

						characterData.healthbarColors = [165, 0, 77];
						characterData.offsetX = 150;
						characterData.offsetY = 75 - 400;
						characterData.camOffsetX = -300;
						characterData.camOffsetY = -50;
						characterData.facingDirection = RIGHT;

					case 'gf-stand-death':
						currentIndex = 154;
						atlasCharacter.anim.addByAnimIndices('FUCKING DIE', indicesContinueAmount(85), 24);

						characterData.offsetX = -150;
						characterData.offsetY = 210;
						//characterData.camOffsetX = 300;
						characterData.camOffsetY = 50;
				}

				atlasCharacter.scale.set(0.75, 0.75);
				atlasCharacter.antialiasing = true;

				visible = false;
				playAnim('idle');
			/*
			case 'gf-stand':
				
				tex = Paths.getSparrowAtlas('characters/gf/last_stand', true);
				frames = tex;

				animation.addByPrefix('idle', 'Lullaby_GF_Idle_2', 24, false);
				animation.addByPrefix('singUP', 'Lullaby_GF_up0', 24, false);
				animation.addByPrefix('singRIGHT', 'Lullaby_GF_right0', 24, false);
				animation.addByPrefix('singDOWN', 'Lullaby_GF_down0', 24, false);
				animation.addByPrefix('singLEFT', 'Lullaby_GF_left0', 24, false);
				animation.addByPrefix('singUPmiss', 'Lullaby_GF_up_miss', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'Lullaby_GF_right_miss', 24, false);
				animation.addByPrefix('singDOWNmiss', 'Lullaby_GF_down_miss', 24, false);
				animation.addByPrefix('singLEFTmiss', 'Lullaby_GF_left_miss', 24, false);

				addOffset("idle");
				addOffset("singUP", -3, 12);
				addOffset("singLEFT", 4, -5);
				addOffset("singRIGHT", 2, 1);
				addOffset("singDOWN", -7, -17);
				addOffset("singUPmiss", -3, 12);
				addOffset("singLEFTmiss", 4, -5);
				addOffset("singRIGHTmiss", 2, 1);
				addOffset("singDOWNmiss", -7, -17);

				playAnim('idle');

				setGraphicSize(Std.int(width * 1.44));
				// lmao
				for (i in animOffsets)
				{
					i[0] *= scale.x;
					i[1] *= scale.y;
				}

				characterData.healthbarColors = [165, 0, 77];
				characterData.offsetX = 150;
				characterData.offsetY = 75;
				characterData.camOffsetX = -300;
				characterData.camOffsetY = -50;
				characterData.facingDirection = RIGHT;

			case 'gf-stand-death':
				tex = Paths.getSparrowAtlas('characters/death/gf/gameover', true);
				frames = tex;

				animation.addByPrefix('firstDeath', 'firstDeath', 24, false);
				animation.addByPrefix('deathLoop', 'loop', 24, true);
				animation.addByPrefix('deathConfirm', 'confirm', 24, false);

				addOffset('firstDeath', 33, 11);
				addOffset('deathLoop', -160, 9);
				addOffset('deathConfirm', 26, 406);

				playAnim('firstDeath');

				setGraphicSize(Std.int(width * 0.8));
				// lmao
				for (i in animOffsets)
				{
					i[0] *= scale.x;
					i[1] *= scale.y;
				}

				characterData.offsetX = -150;
				characterData.offsetY = 210;
				//characterData.camOffsetX = 300;
				characterData.camOffsetY = 50;

			case 'gf-kneel':

				tex = Paths.getSparrowAtlas('characters/gf/phase_3', true);
				frames = tex;

				// typic I hope you actually burn in hell
				animation.addByPrefix('idle', 'GF_SHAKING_BF_she_is_like_real_hot_tho_because_she_is_lullaby_girlfriend', 24, false);
				animation.addByPrefix('singUP', 'up_GF_SHAKING_BF_she_is_like_real_hot_tho_because0', 24, false);
				animation.addByPrefix('singRIGHT', 'right_GF_SHAKING_BF_she_is_like_real_hot_tho_because0', 24, false);
				animation.addByPrefix('singDOWN', 'down_GF_SHAKING_BF_she_is_like_real_hot_tho_because0', 24, false);
				animation.addByPrefix('singLEFT', 'left_GF_SHAKING_BF_she_is_like_real_hot_tho_because0', 24, false);
				animation.addByPrefix('singUPmiss', 'up_GF_SHAKING_BF_she_is_like_real_hot_tho_because_miss', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'right_GF_SHAKING_BF_she_is_like_real_hot_tho_because_miss', 24, false);
				animation.addByPrefix('singDOWNmiss', 'down_GF_SHAKING_BF_she_is_like_real_hot_tho_because_miss', 24, false);
				animation.addByPrefix('singLEFTmiss', 'left_GF_SHAKING_BF_she_is_like_real_hot_tho_because_miss', 24, false);

				animation.addByPrefix('bfdrop', 'GF_SHAKING_BF_drop', 24, false);
				
				addOffset("idle");
				addOffset("bfdrop", 27, 93);
				addOffset("singUP", -2, 22);
				addOffset("singLEFT", 42, -4);
				addOffset("singRIGHT", -18, 0);
				addOffset("singDOWN", -2, -10);
				addOffset("singUPmiss", -1, 22);
				addOffset("singLEFTmiss", 29, 7);
				addOffset("singRIGHTmiss", -21, 0);
				addOffset("singDOWNmiss", -2, -9);

				playAnim('idle');

				setGraphicSize(Std.int(width * 1));
				// lmao
				for (i in animOffsets)
				{
					i[0] *= scale.x;
					i[1] *= scale.y;
				}

				characterData.healthbarColors = [165, 0, 77];
				characterData.offsetX = 200;
				characterData.offsetY = 100;
				characterData.facingDirection = RIGHT;
				characterData.zoomOffset = 0.15;
			*/

			case 'abomination-hypno':
				frames = Paths.getSparrowAtlas('characters/hypno/ABOMINATION_HYPNO');
				animation.addByPrefix('idle', 'idle', 24, true);
				animation.addByPrefix('singUP', 'up', 24, false);
				animation.addByPrefix('singRIGHT', 'right', 24, false);
				animation.addByPrefix('singDOWN', 'down', 24, false);
				animation.addByPrefix('singLEFT', 'left', 24, false);

				addOffset("idle");
				addOffset("singUP", -5, 181);
				addOffset("singLEFT", 115, -69);
				addOffset("singRIGHT", -3, -27);
				addOffset("singDOWN", -2, -211);

				playAnim('idle');

				characterData.facingDirection = LEFT;
				characterData.healthbarColors = [249, 223, 68];
				characterData.camOffsetX = -200;
				characterData.camOffsetY = 170;
				characterData.zoomOffset = -0.15;

			case 'beelze':
				frames = Paths.getSparrowAtlas('characters/beelze/beelze_normal', false);
				animation.addByPrefix('idle', 'OldMan_Idle', 24, false);
				animation.addByPrefix('singUP', 'OldMan_Up', 24, false);
				animation.addByPrefix('singRIGHT', 'OldMan_Right', 24, false);
				animation.addByPrefix('singDOWN', 'OldMan_Down', 24, false);
				animation.addByPrefix('singLEFT', 'OldMan_Left', 24, false);
				animation.addByPrefix('Walk', 'OldMan_Walk', 24, false);
				animation.addByPrefix('Laugh', 'OldMan_Laugh', 24, false);

				addOffset("idle");
				addOffset("singUP", 59, 11);
				addOffset("singLEFT", 112, -6);
				addOffset("singRIGHT", -24, -6);
				addOffset("singDOWN", 51, -15);
				addOffset("Walk", 101, 20);
				addOffset("Laugh", 268, 35);

				playAnim('idle');

				setGraphicSize(Std.int(width * 0.725));
				// lmao
				for (i in animOffsets)
				{
					i[0] *= scale.x;
					i[1] *= scale.y;
				}

				characterData.facingDirection = LEFT;
				characterData.healthbarColors = [126, 93, 145];
				characterData.camOffsetX = -365;
				characterData.camOffsetY = 80;
				characterData.zoomOffset = 0.12;

			case 'beelzescary':
				frames = Paths.getSparrowAtlas('characters/beelze/beelze_ooscaryface', false);
				animation.addByPrefix('idle', 'OldMan_Creepy_Idle', 24, false);
				animation.addByPrefix('singUP', 'OldMan_Creepy_Up', 24, false);
				animation.addByPrefix('singRIGHT', 'OldMan_Creepy_Right', 24, false);
				animation.addByPrefix('singDOWN', 'OldMan_Creepy_Down', 24, false);
				animation.addByPrefix('singLEFT', 'OldMan_Creepy_Left', 24, false);

				addOffset("idle");
				addOffset("singUP", 71, 9);
				addOffset("singLEFT", 142, -8);
				addOffset("singRIGHT", -29, -6);
				addOffset("singDOWN", 65, -20);

				playAnim('idle');

				setGraphicSize(Std.int(width * 0.725));
				// lmao
				for (i in animOffsets)
				{
					i[0] *= scale.x;
					i[1] *= scale.y;
				}

				characterData.facingDirection = LEFT;
				characterData.healthbarColors = [126, 93, 145];
				characterData.camOffsetX = 400;
				characterData.camOffsetY = 80;
				characterData.zoomOffset = 0.18;

			case 'hellbell':
				frames = Paths.getSparrowAtlas('characters/beelze/HellBell', false);
				animation.addByPrefix('idle', 'BellIdle', 24, false);
				animation.addByPrefix('bong', 'BongLmao', 24, false);

				addOffset("idle");
				addOffset("bong", -49, 0);

				playAnim('idle');

				setGraphicSize(Std.int(width * 0.825));
				// lmao
				for (i in animOffsets)
				{
					i[0] *= scale.x;
					i[1] *= scale.y;
				}

				characterData.facingDirection = LEFT;

			case 'dawn' | 'dawn-bf':
				// /*
				atlasCharacter = new FlxAnimate(x, y, Paths.getPath('images/characters/atlases/dawn', TEXT));
				atlasCharacter.anim.addByAnimIndices('idle', indicesContinueAmount(24), 24);
				atlasCharacter.anim.addByAnimIndices('singLEFT', indicesContinueAmount(14), 24);
				atlasCharacter.anim.addByAnimIndices('singLEFTmiss', indicesContinueAmount(14), 24);
				atlasCharacter.anim.addByAnimIndices('singRIGHT', indicesContinueAmount(14), 24);
				atlasCharacter.anim.addByAnimIndices('singRIGHTmiss', indicesContinueAmount(14), 24);
				atlasCharacter.anim.addByAnimIndices('singUP', indicesContinueAmount(14), 24);
				atlasCharacter.anim.addByAnimIndices('singUPmiss', indicesContinueAmount(14), 24);
				atlasCharacter.anim.addByAnimIndices('singDOWN', indicesContinueAmount(14), 24);
				atlasCharacter.anim.addByAnimIndices('singDOWNmiss', indicesContinueAmount(14), 24);

				atlasCharacter.anim.addByAnimIndices('transition', indicesContinueAmount(11), 24);
				atlasCharacter.anim.addByAnimIndices('idle-cover', indicesContinueAmount(24), 24);
				atlasCharacter.anim.addByAnimIndices('singLEFT-cover', indicesContinueAmount(14), 24);
				atlasCharacter.anim.addByAnimIndices('singRIGHT-cover', indicesContinueAmount(14), 24);
				atlasCharacter.anim.addByAnimIndices('singUP-cover', indicesContinueAmount(14), 24);
				atlasCharacter.anim.addByAnimIndices('singDOWN-cover', indicesContinueAmount(14), 24);

				atlasCharacter.anim.addByAnimIndices('transform', indicesContinueAmount(24), 24);
				atlasCharacter.anim.addByAnimIndices('idle-transformed', indicesContinueAmount(24), 24);
				atlasCharacter.anim.addByAnimIndices('singLEFT-transformed', indicesContinueAmount(14), 24);
				atlasCharacter.anim.addByAnimIndices('singLEFTmiss-transformed', indicesContinueAmount(14), 24);
				atlasCharacter.anim.addByAnimIndices('singRIGHT-transformed', indicesContinueAmount(14), 24);
				atlasCharacter.anim.addByAnimIndices('singRIGHTmiss-transformed', indicesContinueAmount(14), 24);
				atlasCharacter.anim.addByAnimIndices('singUP-transformed', indicesContinueAmount(14), 24);
				atlasCharacter.anim.addByAnimIndices('singUPmiss-transformed', indicesContinueAmount(14), 24);
				atlasCharacter.anim.addByAnimIndices('singDOWN-transformed', indicesContinueAmount(14), 24);
				atlasCharacter.anim.addByAnimIndices('singDOWNmiss-transformed', indicesContinueAmount(14), 24);

				atlasCharacter.anim.addByAnimIndices('idle-boyfriend', indicesContinueAmount(24), 24);
				atlasCharacter.anim.addByAnimIndices('singLEFT-boyfriend', indicesContinueAmount(14), 24);
				atlasCharacter.anim.addByAnimIndices('singLEFTmiss-boyfriend', indicesContinueAmount(14), 24);
				atlasCharacter.anim.addByAnimIndices('singRIGHT-boyfriend', indicesContinueAmount(14), 24);
				atlasCharacter.anim.addByAnimIndices('singRIGHTmiss-boyfriend', indicesContinueAmount(14), 24);
				atlasCharacter.anim.addByAnimIndices('singUP-boyfriend', indicesContinueAmount(14), 24);
				atlasCharacter.anim.addByAnimIndices('singUPmiss-boyfriend', indicesContinueAmount(14), 24);
				atlasCharacter.anim.addByAnimIndices('singDOWN-boyfriend', indicesContinueAmount(14), 24);
				atlasCharacter.anim.addByAnimIndices('singDOWNmiss-boyfriend', indicesContinueAmount(14), 24);

				atlasCharacter.anim.addByAnimIndices('transition-boyfriend', indicesContinueAmount(14), 24);
				atlasCharacter.anim.addByAnimIndices('idle-cover-boyfriend', indicesContinueAmount(24), 24);
				atlasCharacter.anim.addByAnimIndices('singLEFT-cover-boyfriend', indicesContinueAmount(14), 24);
				atlasCharacter.anim.addByAnimIndices('singRIGHT-cover-boyfriend', indicesContinueAmount(14), 24);
				atlasCharacter.anim.addByAnimIndices('singUP-cover-boyfriend', indicesContinueAmount(14), 24);
				atlasCharacter.anim.addByAnimIndices('singDOWN-cover-boyfriend', indicesContinueAmount(14), 24);

				atlasCharacter.scale.set(1.25, 1.25);
				atlasCharacter.antialiasing = true;

				PlayState.instance.add(atlasCharacter);

				characterData.facingDirection = RIGHT;
				characterData.healthbarColors = [200, 200, 200];
				characterData.offsetX = -300;
				characterData.offsetY = 50;
				characterData.camOffsetX = -1550;
				characterData.camOffsetY = -150;
				characterData.zoomOffset = -0.08;

				setGraphicSize(Std.int(width * 1.2));

				visible = false;
				playAnim('idle');
				
			case 'bf-pixel':
				frames = Paths.getSparrowAtlas('characters/bf/bfPixel');
				animation.addByPrefix('idle', 'BF IDLE', 24, false);
				animation.addByPrefix('singUP', 'BF UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'BF LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'BF RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'BF DOWN NOTE', 24, false);
				animation.addByPrefix('singUPmiss', 'BF UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF DOWN MISS', 24, false);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				width -= 100;
				height -= 100;

				antialiasing = false;

				characterData.facingDirection = LEFT;
				characterData.healthbarColors = [49, 176, 209];
				characterData.offsetX = 10;
				characterData.offsetY = 20;
				characterData.camOffsetX = 200;
				characterData.camOffsetY = -100;

			case 'ba-bf':
				frames = Paths.getSparrowAtlas('characters/bf/ba_BF_assets');
				animation.addByPrefix('idle', 'BF_Idle', 24, false);
				animation.addByIndices('throw', 'BF_Ball_Throw', [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16], '', 24, false);
				animation.addByIndices('throw2', 'BF_Ball_Throw', [17,18,19,20,21,22,23,24], '', 24, false);
				animation.addByPrefix('augh', 'BF_AURGH', 24, false);
				animation.addByPrefix('singUP', 'BF_Up0', 24, false);
				animation.addByPrefix('singLEFT', 'BF_Left0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF_Right0', 24, false);
				animation.addByPrefix('singDOWN', 'BF_Down0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF_Up Miss', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF_Left Miss', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF_Right Miss', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF_Down Miss', 24, false);

				// pixel bullshit
				setGraphicSize(Std.int(width * 6));
				updateHitbox();
				antialiasing = false;

				characterData.offsetX = 400;
				characterData.offsetY = 550;
				characterData.facingDirection = RIGHT;

			case 'missingno-summon':
				frames = Paths.getSparrowAtlas('characters/buried/missingnopokeball_assets');
				animation.addByPrefix('throw', 'Ball_Throw', 24, false);
				animation.addByPrefix('idle', 'Ball_Idle_Normal', 24, false);
				animation.addByPrefix('break1', 'Ball_Idle_Break01', 24, false);
				animation.addByPrefix('break2', 'Ball_Idle_Break02', 24, false);
				animation.addByIndices('burst1', 'Ball_FinalBurst', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35], "", 24, false);
				animation.addByIndices('burst2', 'Ball_FinalBurst', [36, 37, 38, 39, 40, 41, 42, 43, 44], "", 24, false);
				animation.addByPrefix('full-break1', 'Ball_Break01', 24, false);
				animation.addByPrefix('full-break2', 'Ball_Break02', 24, false);

				// pixel bullshit
				setGraphicSize(Std.int(width * 6));
				updateHitbox();
				antialiasing = false;
			
			case 'bf-pixel-dead':
				frames = Paths.getSparrowAtlas('characters/death/BF_Death_Missingno');
				animation.addByPrefix('firstDeath', "bf_misngno_death", 24, false);
				animation.addByIndices('deathLoop', 'bf_misngno_death', [61], '', 0);
				animation.addByIndices('deathConfirm', 'bf_misngno_death', [61], '', 0);

				addOffset('firstDeath', 0, -160);
				addOffset('deathLoop', 0, -160);
				addOffset('deathConfirm', 0, -160);

				playAnim('firstDeath');

				// pixel bullshit
				setGraphicSize(Std.int(width * 6));
				updateHitbox();
				antialiasing = false;
				
				characterData.offsetY = 150;
				characterData.camOffsetY = 240;
				characterData.facingDirection = LEFT;
			case 'missingno':
				frames = Paths.getSparrowAtlas('characters/buried/Missingno');
				animation.addByIndices('danceLeft', 'missingno idle', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13], "", 24, false);
				animation.addByIndices('danceRight', 'missingno idle', [14, 15, 16, 17, 18, 19, 20, 21, 22, 23], "", 24, false);
				animation.addByPrefix('intro', 'missingno intro', 24, false);
				animation.addByPrefix('singUP', 'missingno up', 24, false);
				animation.addByPrefix('singLEFT', 'missingno left', 24, false);
				animation.addByPrefix('singRIGHT', 'missingno right', 24, false);
				animation.addByPrefix('singDOWN', 'missingno down', 24, false);

				addOffset('singLEFT', 8, -1);
				addOffset('singRIGHT', 3, 1);
				addOffset('singDOWN', 10, 0);
				addOffset('singUP', 1, -2);

				playAnim('idle');

				// pixel bullshit
				setGraphicSize(Std.int(width * 7));
				updateHitbox();
				antialiasing = false;

				characterData.camOffsetX = -400;
				characterData.camOffsetY = -200;
				characterData.healthbarColors = [128, 112, 152];
				characterData.facingDirection = RIGHT;
				characterData.zoomOffset = -0.15;
				// alpha = 0;
			case 'ba-missingno':
				frames = Paths.getSparrowAtlas('characters/buried/ba_missingno_assets');
				animation.addByIndices('danceLeft', 'BA_Missingno_Idle', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13], "", 24, false);
				animation.addByIndices('danceRight', 'BA_Missingno_Idle', [14, 15, 16, 17, 18, 19, 20, 21, 22, 23], "", 24, false);
				animation.addByPrefix('singUP', 'BA_Missingno_Up0', 24, false);
				animation.addByPrefix('singLEFT', 'BA_Missingno_Left0', 24, false);
				animation.addByPrefix('singRIGHT', 'BA_Missingno_Right0', 24, false);
				animation.addByPrefix('singDOWN', 'BA_Missingno_Down0', 24, false);
				//
				animation.addByPrefix('singUPmiss', 'BA_Missingno_Up Miss', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BA_Missingno_Left Miss', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BA_Missingno_Right Miss', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BA_Missingno_Down Miss', 24, false);
				
				playAnim('idle');

				// pixel bullshit
				setGraphicSize(Std.int(width * 6));
				updateHitbox();
				antialiasing = false;
				characterData.facingDirection = RIGHT;
				characterData.offsetX = 500;
				characterData.offsetY = 500;
				characterData.camOffsetX = 600;
				characterData.camOffsetY = -400;
			case 'muk': 
				frames = Paths.getSparrowAtlas('characters/buried/leanmonster');
				animation.addByPrefix('idle', 'Muk_Idle', 24, false);
				animation.addByPrefix('intro', 'Muk_Intro', 24, false);
				animation.addByIndices('outro', 'Muk_Intro', [
					34, 33, 32, 31, 30, 29, 28, 27, 26, 25, 24, 23, 22, 21, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0
				], '', 24, false);
				animation.addByPrefix('puke', 'Muk_Puke', 24, false);
				animation.addByPrefix('singUP', 'Muk_Up', 24, false);
				animation.addByPrefix('singLEFT', 'Muk_Left', 24, false);
				animation.addByPrefix('singRIGHT', 'Muk_Right', 24, false);
				animation.addByPrefix('singDOWN', 'Muk_Down', 24, false);

				playAnim('idle');

				// pixel bullshit
				setGraphicSize(Std.int(width * 6));
				updateHitbox();
				antialiasing = false;
			case 'white-hand':
				frames = Paths.getSparrowAtlas('characters/buried/WA_assets');
				animation.addByPrefix('idle', 'WH_Idle', 24, false);
				animation.addByPrefix('intro', 'WH_Intro', 24, false);
				animation.addByPrefix('transform', 'WH_ToGF', 24, false);

				playAnim('idle');

				// pixel bullshit
				setGraphicSize(Std.int(width * 6));
				updateHitbox();
				antialiasing = false;
			case 'the-apparition':
				frames = Paths.getSparrowAtlas('characters/buried/apparitiongf_assets');
				animation.addByPrefix('idle', 'BAGF_Idle', 24, true);
				animation.addByPrefix('singUP', 'BAGF_Up', 24, false);
				animation.addByPrefix('singLEFT', 'BAGF_Left', 24, false);
				animation.addByPrefix('singRIGHT', 'BAGF_Right', 24, false);
				animation.addByPrefix('singDOWN', 'BAGF_Down', 24, false);

				playAnim('idle');

				// pixel bullshit
				setGraphicSize(Std.int(width * 6));
				updateHitbox();
				antialiasing = false;
			case 'silver':
				frames = Paths.getSparrowAtlas('characters/silver/Silver_Spritesheet');
				animation.addByPrefix('idle', 'Silver Idle', 24, true);
				animation.addByPrefix('singUP', 'Silver Up', 24, false);
				animation.addByPrefix('singLEFT', 'Silver Left', 24, false);
				animation.addByPrefix('singRIGHT', 'Silver Right', 24, false);
				animation.addByPrefix('singDOWN', 'Silver Down', 24, false);

				addOffset('idle');
				addOffset('singUP', 15, 55);
				addOffset('singLEFT', 121, -54);
				addOffset('singRIGHT', 54, -58);
				addOffset('singDOWN', 62, -92);
				playAnim('idle');

				characterData.facingDirection = RIGHT;
				characterData.camOffsetX = -150;
				characterData.camOffsetY = 150;

			case 'red-dead':
				frames = Paths.getSparrowAtlas('characters/red/mt_silver_red_dead');
				animation.addByPrefix('idle', 'DEAD RED IDLE', 24, true);
				animation.addByPrefix('singUP', 'DEAD RED up', 24, false);
				animation.addByPrefix('singLEFT', 'DEAD RED left', 24, false);
				animation.addByPrefix('singRIGHT', 'DEAD RED right', 24, false);
				animation.addByPrefix('singDOWN', 'DEAD RED down', 24, false);

				addOffset('idle');
				addOffset('singLEFT', 176, 3);
				addOffset('singRIGHT', -86, -1);
				addOffset('singDOWN', 19, -8);
				addOffset('singUP', -1, 59);

				playAnim('idle');

				characterData.healthbarColors = [255, 55, 55];

			case 'red':
				frames = Paths.getSparrowAtlas('characters/red/mt_silver_red_norm');
				animation.addByPrefix('idle', 'Norm Red Idle', 24, false);
				animation.addByPrefix('singUP', 'Norm Red UP', 24, false);
				animation.addByPrefix('singLEFT', 'Norm Red left', 24, false);
				animation.addByPrefix('singRIGHT', 'Norm Red right', 24, false);
				animation.addByPrefix('singDOWN', 'Norm Red down', 24, false);

				addOffset('idle');
				addOffset('singLEFT', 20);
				addOffset('singRIGHT', -59);
				addOffset('singDOWN', 11, 6);
				addOffset('singUP', 0, 36);

				playAnim('idle');

				characterData.offsetX = -250;
				// characterData.camOffsetX = 100;
				characterData.healthbarColors = [255, 55, 55];
				
			case 'typhlosion':
				frames = Paths.getSparrowAtlas('characters/gold/TYPHLOSION_MECHANIC');
				animation.addByIndices('idle', 'TYPHLOSION MECHANIC', generateIndicesAtPoint(1, 15), "", 24, false);
				animation.addByIndices('fire', 'TYPHLOSION MECHANIC', generateIndicesAtPoint(16, 14), "", 24, false);
				playAnim('idle');
				
				characterData.facingDirection = RIGHT;

			case 'freakachu':
				frames = Paths.getSparrowAtlas('characters/red/Freakachu');
				animation.addByPrefix('idle', 'Freakachu IDLE', 24, false);
				animation.addByPrefix('painsplit', 'Freakachu PAIN SPLIT', 24, false);
				playAnim('idle');
				addOffset("painsplit", -5, 28);
				
			case 'cold-gold':
				frames = Paths.getSparrowAtlas('characters/gold/Cold_Gold');

				animation.addByPrefix('idle', 'GOLD IDLE', 24, false);
				animation.addByPrefix('singUP', 'GOLD UP POSE0', 24, false);
				animation.addByPrefix('singLEFT', 'GOLD LEFT POSE0', 24, false);
				animation.addByPrefix('singRIGHT', 'GOLD RIGHT POSE0', 24, false);
				animation.addByPrefix('singDOWN', 'GOLD DOWN POSE0', 24, false);
				animation.addByPrefix('singUPmiss', 'GOLD UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'GOLD LEFT POSE MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'GOLD RIGHT POSE MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'GOLD DOWN POSE MISS', 24, false);

				addOffset('idle');
				addOffset("singUP", 35, 30);
				addOffset("singRIGHT", -10, -7);
				addOffset("singLEFT", 78, 16);
				addOffset("singDOWN", -70, -37);
				addOffset("singUPmiss", 36, 10);
				addOffset("singRIGHTmiss", -15, -15);
				addOffset("singLEFTmiss", 50);
				addOffset("singDOWNmiss", -88, -77);

				playAnim('idle');

				characterData.offsetY = 160;
				characterData.camOffsetY = -160;
				characterData.healthbarColors = [234, 216, 255];

				characterData.facingDirection = RIGHT; 

			case 'buryman':
				frames = Paths.getSparrowAtlas('characters/buried/buryman_assets');
				animation.addByPrefix('idle', 'buryman_idle', 24, true);
				animation.addByPrefix('ground', 'buryman_ground', 24, false);
				animation.addByPrefix('scream', 'buryman_scream', 24, false);
				animation.addByPrefix('laugh', 'buryman_laugh', 24, true);
				animation.addByPrefix('singUP', 'buryman_up', 24, false);
				animation.addByPrefix('singRIGHT', 'buryman_right', 24, false);
				animation.addByPrefix('singDOWN', 'buryman_down', 24, false);
				animation.addByPrefix('singLEFT', 'buryman_left', 24, false);

				animation.finishCallback = function(name:String){
					if (name == 'laugh') {
						canAnimate = true;
						dance();
					}
				}

				playAnim('idle');

				// pixel bullshit
				setGraphicSize(Std.int(width * 6));
				updateHitbox();
				antialiasing = false;

				characterData.camOffsetX = -1430;
				
				// characterData.camOffsetY = -100;
				characterData.facingDirection = LEFT; // flip this later
			case 'buryman-death':
				frames = Paths.getSparrowAtlas('characters/death/BA_DeathRetry');
				animation.addByPrefix('idle', 'buried_death', 24, false);
				animation.addByPrefix('retry', 'BA_retry0', 24, true);
				animation.addByPrefix('accept', 'BA_retry_confirm', 24, false);
				
				addOffset('accept', 24, 24);

				playAnim('idle');

				// pixel bullshit
				setGraphicSize(Std.int(width * 3));
				updateHitbox();
				antialiasing = false;

			case 'hypno2' | 'hypno-two':
				tex = Paths.getSparrowAtlas('characters/hypno/Hypno Phase 2 Sheet', true);
				frames = tex;
				animation.addByPrefix('idle', 'Hypno2 Idle', 24, true);
				animation.addByPrefix('singUP', 'Hypno Up Finished', 24, false);
				animation.addByPrefix('singRIGHT', 'Hypno Right Finished', 24, false);
				animation.addByPrefix('singDOWN', 'Hypno Down', 24, false);
				animation.addByPrefix('singLEFT', 'Hypno Left final', 24, false);

				addOffset('idle', -4, 6);
				addOffset('singLEFT', 59, -94);
				addOffset('singRIGHT', 4, -139);
				addOffset('singDOWN', 11, -348);
				addOffset('singUP', -3, 141);

				setGraphicSize(Std.int(width * 1.3));
				updateHitbox();

				playAnim('idle');

				characterData.offsetX = -300;
				characterData.offsetY = 100;
				characterData.camOffsetX = 200;
				characterData.camOffsetY = 200;
				characterData.healthbarColors = [249, 223, 68];
				characterData.facingDirection = RIGHT;
			case 'hypno':
				frames = Paths.getSparrowAtlas('characters/hypno/Hypno Phase 1 Sheet', true);

				animation.addByPrefix('idle', 'Hypno Idle 1', 24, false);
				animation.addByPrefix('singUP', 'Hypno Up', 24, false);
				animation.addByPrefix('singRIGHT', 'Hypno Right', 24, false);
				animation.addByPrefix('singDOWN', 'Final Hypno Down', 24, false);
				animation.addByPrefix('singLEFT', 'Hypno Left', 24, false);
				animation.addByPrefix('psyshock', 'Psyshock Full', 24, false);
				animation.addByIndices('psyshock particle', "Full Psyshock Particle", [0, 1, 2, 3, 4, 5, 6], "", 24, false);

				addOffset('idle');
				addOffset('singLEFT', 144, 22);
				addOffset('singRIGHT', -338, 93);
				addOffset('singDOWN', -150, -120);
				addOffset('singUP', -89, 267);
				addOffset('psyshock', -312, 22);
				addOffset('psyshock particle', -940, 190);

				setGraphicSize(Std.int(width * 1.3));
				updateHitbox();

				playAnim('idle');

				characterData.offsetX = -250;
				characterData.offsetY = 100;
				characterData.camOffsetX = 200;
				characterData.healthbarColors = [249, 223, 68];
				characterData.facingDirection = RIGHT;
			case 'gold':
				tex = Paths.getSparrowAtlas('characters/gold/Lost Silver Assets Gold');
				frames = tex;
				animation.addByPrefix('idle', "Silver Idle", 24, true);
				animation.addByPrefix('singUP', "Full Silver Up", 24, false);
				animation.addByPrefix('singRIGHT', "Silver Right Finished", 24, false);
				animation.addByPrefix('singDOWN', 'Silver Down Full', 24, false);
				animation.addByPrefix('singLEFT', "Lost Silver Left finished", 24, false);

				animation.addByIndices('fadeIn', "Silver Spawn Full", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15], "", 24, false);
				animation.addByIndices('fadeOut', "Silver Spawn Full", [15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0], "", 24, false);

				addOffset('singLEFT', 619, 126);
				addOffset('singRIGHT', -96, 91);
				addOffset('singDOWN', 11, -348);
				addOffset('singUP', -3, 181);

				setGraphicSize(Std.int(width * 1.3));
				updateHitbox();

				playAnim('idle');
				
				characterData.camOffsetX = 0;
				characterData.offsetX = 150;
				characterData.offsetY = 600;
				characterData.camOffsetX = -(characterData.offsetX);
				characterData.camOffsetY = -(characterData.offsetY - 500);
				characterData.healthbarColors = [255, 255, 255];
				characterData.facingDirection = RIGHT;
			case 'gold-no-more':
				frames = Paths.getSparrowAtlas('characters/gold/GOLD_NO_MORE');
				animation.addByPrefix('idle', "No More instance 1", 24, false);
				setGraphicSize(Std.int(width * 1.3));
				updateHitbox();

				playAnim('idle');

				characterData.offsetY = 600;
				characterData.facingDirection = RIGHT;

			case 'gold-head-rip':
				frames = Paths.getSparrowAtlas('characters/gold/GOLD_HEAD_RIPPING_OFF');
				animation.addByPrefix('idle', "Head rips_OneLayer instance 1", 24, false);
				setGraphicSize(Std.int(width * 1.3));
				updateHitbox();

				playAnim('idle');

				characterData.offsetY = 600;
				characterData.facingDirection = RIGHT;

			case 'gold-headless':
				tex = Paths.getSparrowAtlas('characters/gold/GoldHead Sheet');
				frames = tex;
				animation.addByPrefix('idle', 'GoldHead Idle', 24, false);
				animation.addByPrefix('singUP', 'GoldHead Up', 24, false);
				animation.addByPrefix('singLEFT', 'GoldHead Left Full', 24, false);
				animation.addByPrefix('singRIGHT', 'GoldHead Right', 24, false);
				animation.addByPrefix('singDOWN', 'GoldHead DOwn full', 24, false);

				addOffset('singUP', 0, 207);
				addOffset('singLEFT', 276, 22);
				addOffset('singRIGHT', -103, 80);
				addOffset('singDOWN', 50, -180);

				setGraphicSize(Std.int(width * 1.3));
				updateHitbox();

				playAnim('idle');

				characterData.camOffsetX = 0;
				characterData.offsetX = -25;
				characterData.offsetY = 600;
				characterData.camOffsetX = -(characterData.offsetX);
				characterData.camOffsetY = -(characterData.offsetY - 500);
				characterData.healthbarColors = [255, 255, 255];
				characterData.facingDirection = RIGHT;
			case 'gengar':
				frames = Paths.getSparrowAtlas('characters/buried/gengar_assets');
				animation.addByPrefix('idle', 'gengar idle', 24, false);
				animation.addByPrefix('singUP', 'gengar up', 24, false);
				animation.addByPrefix('singRIGHT', 'gengar right', 24, false);
				animation.addByPrefix('singDOWN', 'gengar down', 24, false);
				animation.addByPrefix('singLEFT', 'gengar left', 24, false);

				playAnim('idle');

				// pixel bullshit
				setGraphicSize(Std.int(width * 6));
				updateHitbox();
				antialiasing = false;

				characterData.offsetX = 216;
				characterData.offsetY = 216;
				characterData.camOffsetX = -characterData.offsetX * 2;
				characterData.camOffsetY = -characterData.offsetY;
			case 'enter-gengar':
				frames = Paths.getSparrowAtlas('characters/buried/enter_gengar');
				animation.addByIndices('entrance', 'gengar entrance', [
					0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36,
					37, 38, 39, 40, 41
				], '', 24, false);
				animation.addByIndices('exit', 'gengar entrance', [42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56], '', 24, false);
				animation.addByIndices('leave', 'gengar entrance', [56, 55, 54, 53, 52, 51, 50, 49, 48], '', 24, false);

				// pixel bullshit
				setGraphicSize(Std.int(width * 6));
				updateHitbox();
				antialiasing = false;

				characterData.offsetX = 216;
				characterData.offsetY = 216;
				characterData.camOffsetX = -characterData.offsetX * 2;
				characterData.camOffsetY = -characterData.offsetY;

			case 'wigglytuff': 
				var phaseString:String = curCharacter;
				switch (wigglyState) {
					default:
						phaseString = 'wigglytuff';
						characterData.zoomOffset = -0.20;
						characterData.healthbarColors = [163, 103, 117];
					case 1:
						phaseString = 'DECAY 1'; 
						characterData.zoomOffset = -0.125;
						characterData.healthbarColors = [123, 74, 86];
					case 2:
						phaseString = 'DECAY 2'; 
						characterData.zoomOffset = -0.05;
						characterData.healthbarColors = [99, 56, 67];
					case 3:
						phaseString = 'STARE';
						characterData.zoomOffset = 0;
						characterData.healthbarColors = [84, 47, 56];
				}
				characterData.camOffsetY = (192 * (1 / (1 - (characterData.zoomOffset + 0.15)))) - 192;

				frames = Paths.getSparrowAtlas('characters/disabled/wiggles_glitchy');
				
				animation.addByPrefix('idle', '$phaseString idle', 24, false);
				animation.addByPrefix('singUP', '$phaseString up', 24, false);
				animation.addByPrefix('singLEFT', '$phaseString left', 24, false);
				animation.addByPrefix('singRIGHT', '$phaseString right', 24, false);
				animation.addByPrefix('singDOWN', '$phaseString down', 24, false);
				
				switch (phaseString.toLowerCase()) {
					case 'wigglytuff':
						var idleOffset:FlxPoint = FlxPoint.weak(0, 0);
						addOffset('idle', idleOffset.x, idleOffset.y);
						addOffset("singUP", idleOffset.x + 1, idleOffset.y + 5);
						addOffset("singRIGHT", idleOffset.x + 1, idleOffset.y + 11);
						addOffset("singLEFT", idleOffset.x + 1, idleOffset.y + -4);
						addOffset("singDOWN", -35, -14);
					case 'decay 1':
						var idleOffset:FlxPoint = FlxPoint.weak(-47, -73);
						addOffset('idle', idleOffset.x, idleOffset.y);
						addOffset("singUP", idleOffset.x + 2, idleOffset.y + 11);
						addOffset("singLEFT", idleOffset.x + 10, idleOffset.y + -5);
						addOffset("singRIGHT", idleOffset.x + 1, idleOffset.y + 3);
						addOffset("singDOWN", idleOffset.x + 3, idleOffset.y + -6);
					case 'decay 2':
						var idleOffset:FlxPoint = FlxPoint.weak(-46, -80);
						addOffset('idle', idleOffset.x, idleOffset.y);
						addOffset("singUP", idleOffset.x + 1, idleOffset.y + 12);
						addOffset("singLEFT", idleOffset.x + 3, idleOffset.y + 2);
						addOffset("singRIGHT", idleOffset.x + 1, idleOffset.y + 5);
						addOffset("singDOWN", idleOffset.x + 1, idleOffset.y + -1);
					case 'stare':
						var idleOffset:FlxPoint = FlxPoint.weak(-10, -76);
						addOffset('idle', idleOffset.x, idleOffset.y);
						addOffset("singUP", idleOffset.x + 2, idleOffset.y + 70);
						addOffset("singLEFT", idleOffset.x + 118, idleOffset.y + 4);
						addOffset("singRIGHT", idleOffset.x + -8, idleOffset.y + 15);
						addOffset("singDOWN", idleOffset.x + 35, idleOffset.y + -33);
				}

				setGraphicSize(Std.int(width * 1.25));
				updateHitbox();

				for (i in animOffsets) {
					i[0] *= scale.x;
					i[1] *= scale.y;
				}

				playAnim('$phaseString idle');

				characterData.facingDirection = RIGHT;

			case 'ponyta-perspective':
				frames = Paths.getSparrowAtlas('characters/disabled/ponyta_perspective');

				animation.addByPrefix('idle', 'Ponyta Idle', 24, false);
				//
				animation.addByPrefix('singUP', 'Ponyta up', 24, false);
				animation.addByPrefix('singLEFT', 'Ponyta left', 24, false);
				animation.addByPrefix('singRIGHT', 'Ponyta right', 24, false);
				animation.addByPrefix('singDOWN', 'Ponyta down', 24, false);
				//
				animation.addByPrefix('singUPmiss', 'ponyta up mis', 24, false);
				animation.addByPrefix('singLEFTmiss', 'ponyta left miss', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'ponyta right miss', 24, false);
				animation.addByPrefix('singDOWNmiss', 'ponyta down miss', 24, false);

				addOffset('idle');
				addOffset("singUP", 10, 0);
				addOffset("singRIGHT", -3, -5);
				addOffset("singLEFT", 10, -15);
				addOffset("singDOWN", -8, -25);
				addOffset("singUPmiss", -14, -14);
				addOffset("singRIGHTmiss", -25, -12);
				addOffset("singLEFTmiss", 2, -28);
				addOffset("singDOWNmiss", -24, -41);

				characterData.facingDirection = RIGHT;
			
			case 'wiggles-death-stare':
				frames = Paths.getSparrowAtlas('characters/disabled/The_death_stare');
		
				animation.addByPrefix('idle', 'idle', 24, false);
				animation.addByPrefix('singUP', 'up', 24, false);
				animation.addByPrefix('singLEFT', 'left', 24, false);
				animation.addByPrefix('singRIGHT', 'right', 24, false);
				animation.addByPrefix('singDOWN', 'down', 24, false);

				addOffset('idle');
				addOffset("singUP", -10, 10);
				addOffset("singRIGHT", -20);
				addOffset("singLEFT", 110);
				addOffset("singDOWN", 0, -54);

				characterData.facingDirection = LEFT;
				characterData.healthbarColors = [84, 47, 56];

			case 'wiggles-terror':
				frames = Paths.getSparrowAtlas('characters/disabled/WigglesTerrorUneashed'); // fuck you and your stupid typo

				animation.addByIndices('idle', 'WigglesTerror', generateIndicesAtPoint(0, 14), "", 24, false);
				animation.addByIndices('singLEFT', 'WigglesTerror', generateIndicesAtPoint(15, 14), "", 24, false);
				animation.addByIndices('singUP', 'WigglesTerror', generateIndicesAtPoint(30, 14), "", 24, false);
				animation.addByIndices('singRIGHT', 'WigglesTerror', generateIndicesAtPoint(45, 14), "", 24, false);
				animation.addByIndices('singDOWN', 'WigglesTerror', generateIndicesAtPoint(60, 14), "", 24, false);

				characterData.facingDirection = LEFT;
				characterData.healthbarColors = [84, 47, 56];

			case 'gf-gameboy':
				frames = Paths.getSparrowAtlas('characters/gf-gameboy', 'gf');
				animation.addByPrefix('idle', 'Lmao', 24, true);
				playAnim('idle');
				
				// setGraphicSize(Std.int(width * 6));
				// updateHitbox();
				antialiasing = true;
			case 'glitchy-red':
				frames = Paths.getSparrowAtlas('characters/red/Glitchy_Red_Assets_elpepe');
				animation.addByPrefix('idle', 'RedIdle', 24, false);
				animation.addByPrefix('singUP', 'RedUp', 24, false);
				animation.addByPrefix('singLEFT', 'RedLeft', 24, false);
				animation.addByPrefix('singRIGHT', 'RedRight', 24, false);
				animation.addByPrefix('singDOWN', 'RedDown', 24, false);

				addOffset('idle');
				addOffset('singLEFT', 107, 9);
				addOffset('singRIGHT', -57, 22);
				addOffset('singDOWN', 2, -11);
				addOffset('singUP', 81, 28);
				playAnim('idle');

				characterData.facingDirection = LEFT;
				characterData.zoomOffset = 0.15;
				characterData.healthbarColors = [185, 49, 43];

			case 'glitchy-red-mad':
				frames = Paths.getSparrowAtlas('characters/red/Glitchy_Red_Assets_angrybitch');
				animation.addByPrefix('idle', 'RedIdleMad', 24, false);
				animation.addByPrefix('singUP', 'RedUpMad', 24, false);
				animation.addByPrefix('singLEFT', 'RedLeftMad', 24, false);
				animation.addByPrefix('singRIGHT', 'RedRightMad', 24, false);
				animation.addByPrefix('singDOWN', 'RedDownMad', 24, false);

				addOffset('idle');
				addOffset('singRIGHT', -153, 10);
				addOffset('singDOWN', -66, -19);
				addOffset('singLEFT', 76, 20);		
				addOffset('singUP', -73, 57);
				playAnim('idle');

				characterData.offsetX = -80;
				characterData.facingDirection = LEFT;
				characterData.zoomOffset = 0.175;
				characterData.healthbarColors = [185, 49, 43];
			
			case 'glitchy-bf':
				frames = Paths.getSparrowAtlas('characters/bf/Boyfriend_Isotope');
				animation.addByPrefix('idle', 'Bf Idle Dance', 24, false);
				animation.addByPrefix('singUP', 'boyfriend up', 24, false);
				animation.addByPrefix('singRIGHT', 'boyfriend right', 24, false);
				animation.addByPrefix('singLEFT', 'boyfriend left', 24, false);
				animation.addByPrefix('singDOWN', 'boyfriend down', 24, false);
				animation.addByPrefix('singUPmiss', 'boyfriend u miss', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'boyfriend righ miss', 24, false);
				animation.addByPrefix('singLEFTmiss', 'boyfriend lef miss', 24, false);
				animation.addByPrefix('singDOWNmiss', 'boyfriend dow miss', 24, false);

				addOffset('idle');
				addOffset('singRIGHT', -10, 20);
				addOffset('singLEFT', 160, 0);
				addOffset('singDOWN', 0, -40);
				addOffset('singUP', 100, 90);
				addOffset('singRIGHTmiss', 70, 170);
				addOffset('singLEFTmiss', 370, 170);
				addOffset('singDOWNmiss', 70, 100);
				addOffset('singUPmiss', 230, 270);
				playAnim('idle');

				characterData.facingDirection = RIGHT;
				characterData.healthbarColors = [49, 176, 209];

			case 'smol-hypno':
				frames = Paths.getSparrowAtlas('characters/hypno/Smol_Hypno_Sprites');
				animation.addByPrefix('idle', 'Smol H Idle', 24, true);
				animation.addByPrefix('singUP', 'Smol H Up0', 24, false);
				animation.addByPrefix('singLEFT', 'Smol H Left0', 24, false);
				animation.addByPrefix('singRIGHT', 'Smol H Right0', 24, false);
				animation.addByPrefix('singDOWN', 'Smol H Down0', 24, false);
				animation.addByPrefix('singUPmiss', 'Smol H Up Miss', 24, false);
				animation.addByPrefix('singLEFTmiss', 'Smol H Left Miss', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'Smol H Right Miss', 24, false);
				animation.addByPrefix('singDOWNmiss', 'Smol H Down Miss', 24, false);

				addOffset('idle');
				addOffset("singUP", 3, 1);
				addOffset("singRIGHT", -25, -10);
				addOffset("singLEFT", 24, -16);
				addOffset("singDOWN", -11, -13);
				addOffset("singUPmiss", 50, 143);
				addOffset("singRIGHTmiss", 64, 78);
				addOffset("singLEFTmiss", 165, 57);
				addOffset("singDOWNmiss", 95, 59);

				playAnim('idle');

				characterData.quickDancer = true;

				characterData.offsetX = 216;
				characterData.offsetY = -216;
			case 'alexis':
				frames = Paths.getSparrowAtlas('characters/hypno/GGirl Alexis Full Spritesheet');
				animation.addByPrefix('idle', 'GGirl Idle', 24, true);
				animation.addByPrefix('singUP', 'GGirl Up0', 24, false);
				animation.addByPrefix('singLEFT', 'GGirl Left0', 24, false);
				animation.addByPrefix('singRIGHT', 'GGirl Right0', 24, false);
				animation.addByPrefix('singDOWN', 'GGirl Down0', 24, false);
				animation.addByPrefix('singUPmiss', 'GGirl Up Miss', 24, false);
				animation.addByPrefix('singLEFTmiss', 'GGirl left Miss', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'GGirl Right Miss', 24, false);
				animation.addByPrefix('singDOWNmiss', 'GGirl Down Miss', 24, false);

				addOffset('idle', -5,0);
				addOffset("singUP", -29,27);
				addOffset("singRIGHT", -27,28);
				addOffset("singLEFT", 62,5);
				addOffset("singDOWN", 25,-15);
				addOffset("singUPmiss", 50, 143);
				addOffset("singRIGHTmiss", -30,22);
				addOffset("singLEFTmiss", 72,28);
				addOffset("singDOWNmiss", 23,28);

				playAnim('idle');

				characterData.quickDancer = true;

			case 'ponyta':
				frames = Paths.getSparrowAtlas('characters/disabled/PONYTA');
				animation.addByPrefix('idle', 'PONYTA IDLE0', 24, false);
				animation.addByPrefix('singUP', 'PONYTA UP0', 24, false);
				animation.addByPrefix('singLEFT', 'PONYTA LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'PONYTA RIGHT ', 24, false);
				animation.addByPrefix('singDOWN', 'PONYTA DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'PONYTA Miss UP0', 24, false);
				animation.addByPrefix('singLEFTmiss', 'PONYTA MISS LEFT0', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'PONYTA MISS RIGHT0', 24, false);
				animation.addByPrefix('singDOWNmiss', 'PONYTA MISS DOWN0', 24, false);

				addOffset('idle');
				addOffset("singUP", -25, -9);
				addOffset("singRIGHT", 17, -25);
				addOffset("singLEFT", 2, -18);
				addOffset("singDOWN", -7, -57);
				addOffset("singUPmiss", -27);
				addOffset("singRIGHTmiss", 8, -24);
				addOffset("singLEFTmiss", 8, -16);
				addOffset("singDOWNmiss", -18, -62);

				playAnim('idle');

				characterData.camOffsetY = 120;
				characterData.camOffsetX = 64;
				characterData.healthbarColors = [255, 192, 0];

			case 'ponyta-scared':
				frames = Paths.getSparrowAtlas('characters/disabled/Ponyta_Scared');
				animation.addByPrefix('toScared', 'PONYTA ToScared', 24, false);
				animation.addByPrefix('idle', 'PONYTA SCARED IDLE0', 24, false);
				animation.addByPrefix('singUP', 'PONYTA SCARED UP0', 24, false);
				animation.addByPrefix('singLEFT', 'PONYTA SCARED LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'PONYTA SCARED RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'PONYTA SCARED DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'PONYTA SCARED UP MISS0', 24, false);
				animation.addByPrefix('singLEFTmiss', 'PONYTA SCARED LEFT MISS0', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'PONYTA SCARED RIGHT MISS0', 24, false);
				animation.addByPrefix('singDOWNmiss', 'PONYTA SCARED DOWN MISS0', 24, false);

				animation.finishCallback = function(name:String){
					if (name == 'toScared')
						dance();
				}

				addOffset('idle');
				addOffset('toScared', -4, 4);
				addOffset("singUP", -32, -8);
				addOffset("singRIGHT", 13, -2);
				addOffset("singLEFT", 4, -11);
				addOffset("singDOWN", -12, -36);
				addOffset("singUPmiss", -34, 1);
				addOffset("singRIGHTmiss", 12, -3);
				addOffset("singLEFTmiss", -2, -13);
				addOffset("singDOWNmiss", -9, -37);

				playAnim('toScared');

				characterData.camOffsetY = 120;
				characterData.camOffsetX = 64;
				characterData.healthbarColors = [255, 192, 0];

			case 'pico':
				frames = Paths.getSparrowAtlas('characters/purin/Full_pico_purin');

				animation.addByPrefix('idle', 'Pico Idle dance', 24, false);
				animation.addByPrefix('singLEFT', 'PICO LEFT ', 24, false);
				animation.addByPrefix('singRIGHT', 'PICO RIGHT', 24, false);
				animation.addByPrefix('singUP', 'PICO UP', 24, false);
				animation.addByPrefix('singDOWN', 'PICO DOWN', 24, false);
				animation.addByPrefix('singLEFTmiss', 'pico miss left', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'pico right miss', 24, false);
				animation.addByPrefix('singUPmiss', 'pico miss up', 24, false);
				animation.addByPrefix('singDOWNmiss', 'pico miss down', 24, false);
				animation.addByPrefix('preidle', 'Pico_idle_01', 24, false);
				animation.addByPrefix('turn', 'Pico Turn', 24, false);
				animation.addByPrefix('knife', 'Knife out', 24, false);

				addOffset("idle");
				addOffset("singUP", -21, 31);
				addOffset("singLEFT", -18, -3);
				addOffset("singRIGHT", -32, 5);
				addOffset("singDOWN", 108, -42);
				addOffset("singUPmiss", -21, 31);
				addOffset("singLEFTmiss", -21, 42);
				addOffset("singRIGHTmiss", -31, 3);
				addOffset("singDOWNmiss", 102, -28);
				addOffset("preidle", -30, 10);
				addOffset("turn", -28, 29);
				addOffset("knife", -3, 11);

				playAnim('idle');

				for (i in animOffsets) {
					i[0] *= scale.x;
					i[1] *= scale.y;
				}

				characterData.healthbarColors = [255, 140, 0];
				characterData.camOffsetY = -60;
				characterData.facingDirection = LEFT;

			case 'jigglypuff':
				frames = Paths.getSparrowAtlas('characters/purin/jigglyassets');
				animation.addByPrefix('idle', 'Jigglypuff idle main', 24, false);
				animation.addByPrefix('singUP', 'jigglyup', 24, false);
				animation.addByPrefix('singLEFT', 'jigglyleft', 24, false);
				animation.addByPrefix('singRIGHT', 'jigglyright', 24, false);
				animation.addByPrefix('singDOWN', 'jigglydown', 24, false);
				animation.addByPrefix('sleep', 'jigglysing', 24, false);
				animation.addByPrefix('turn', 'jigglyturn', 24, false);

				addOffset('idle');
				addOffset("singUP", 122, 100);
				addOffset("singRIGHT", 28, 54);
				addOffset("singLEFT", 234, 69);
				addOffset("singDOWN", 28, -39);
				addOffset("sleep", 0, 0);
				addOffset("turn", 50, 3);

				characterData.healthbarColors = [150, 150, 150];

				setGraphicSize(Std.int(width * 0.5));
				for (i in animOffsets) {
					i[0] *= scale.x;
					i[1] *= scale.y;
				}
				characterData.facingDirection = RIGHT;
				characterData.offsetX = -10;
				characterData.offsetY = -150;
				characterData.camOffsetY = -30;
				characterData.camOffsetX = -20;
				characterData.zoomOffset = 0.15;

				playAnim('idle');
				
			case 'jigglyfront':
				frames = Paths.getSparrowAtlas('characters/purin/Purin_Recolored');
				animation.addByPrefix('idle', 'Body', 24, false);
				animation.addByPrefix('singUP', 'Up pose', 24, false);
				animation.addByPrefix('singLEFT', 'Left pose', 24, false);
				animation.addByPrefix('singRIGHT', 'Right pose', 24, false);
				animation.addByPrefix('singDOWN', 'Jigglypuff Down front', 24, false);

				addOffset('idle', 0, 0);
				addOffset("singUP", 47, 22);
				addOffset("singRIGHT", -53, 14);
				addOffset("singLEFT", 217, 5);
				addOffset("singDOWN", 35, -41);

				characterData.healthbarColors = [150, 150, 150];

				setGraphicSize(Std.int(width * 0.5));
				for (i in animOffsets) {
					i[0] *= scale.x;
					i[1] *= scale.y;
				}
				characterData.facingDirection = RIGHT;
				characterData.offsetX = -100;
				characterData.offsetY = -230;
				characterData.camOffsetX = -110;
				characterData.camOffsetY = 50;
				characterData.zoomOffset = 0.6;

				playAnim('idle');

			case 'mx' | 'mx-front':
				if (!curCharacter.contains('front'))
				{
					frames = Paths.getSparrowAtlas('characters/mx/mxback');
					animation.addByPrefix('idle', 'IdleBack', 16, false);
					animation.addByPrefix('singUP', 'UpBack', 24, false);
					animation.addByPrefix('singLEFT', 'LeftBack', 24, false);
					animation.addByPrefix('singRIGHT', 'RightBack', 24, false);
					animation.addByPrefix('singDOWN', 'DownBack', 24, false);
					animation.addByPrefix('hit1', 'Hit1Back', 24, false);
					animation.addByPrefix('hit2', 'Hit2Back', 24, false);

					addOffset("idle");
					addOffset("singUP", 4, 135);
					addOffset("singLEFT", 88);
					addOffset("singRIGHT", -52, 50);
					addOffset("singDOWN", 25, -46);
					addOffset("hit1", 8);
					addOffset("hit2", 11, -13);
				}
				else
				{
					frames = Paths.getSparrowAtlas('characters/mx/mxfront');
					animation.addByPrefix('idle', 'IdleFront', 16, false);
					animation.addByPrefix('singUP', 'UpFront', 24, false);
					animation.addByPrefix('singLEFT', 'LeftFront', 24, false);
					animation.addByPrefix('singRIGHT', 'RightFront', 24, false);
					animation.addByPrefix('singDOWN', 'DownFront', 24, false);
					animation.addByPrefix('hit1', 'Hit1Front', 24, false);
					animation.addByPrefix('hit2', 'Hit2Front', 24, false);

					addOffset("idle", 68, 5);
					addOffset("singUP", 64, 16);
					addOffset("singLEFT", 451, -124);
					addOffset("singRIGHT", -10, -120);
					addOffset("singDOWN", 64, -122);
					addOffset("hit1", 111, -2);
					addOffset("hit2", 144, -110);
				}

				forceNoMiss = true;

				playAnim('idle');
				setGraphicSize(Std.int(width * 0.9));
				updateHitbox();
				// lmao
				for (i in animOffsets) {
					i[0] *= scale.x;
					i[1] *= scale.y;
				}

				characterData.healthbarColors = [63, 9, 4];
			case 'hypno-cards' | 'hypno-cards-front':
				frames = Paths.getSparrowAtlas('characters/hypno/PASTA_HYPNO');
				var modifier:String = '';
				if (curCharacter.contains('front')) 
					modifier = ' Front';
				animation.addByPrefix('idle', 'Hypno Idle${modifier}0', 24, false);
				animation.addByPrefix('singUP', 'Hypno Up${modifier}0', 24, false);
				animation.addByPrefix('singRIGHT', 'Hypno Right${modifier}0', 24, false);
				animation.addByPrefix('singDOWN', 'Hypno Down${modifier}0', 24, false);
				animation.addByPrefix('singLEFT', 'Hypno Left${modifier}0', 24, false);
				if (curCharacter.contains('front')) {
					addOffset("idle", -64, -172);
					addOffset("singUP", 37, 299);
					addOffset("singRIGHT", -141, -104);
					addOffset("singLEFT", 34, 73);
					addOffset("singDOWN", -139, -160);
				} else {
					addOffset("singUP", -172 , 137);
					addOffset("singRIGHT", -151, 70);
					addOffset("singLEFT", -126, 22);
					addOffset("singDOWN", -60, -66);
				}

				forceNoMiss = true;

				playAnim('idle');
				setGraphicSize(Std.int(width * 1.5));
				updateHitbox();
				// lmao
				/*
				for (i in animOffsets)
				{
					i[0] *= scale.x;
					i[1] *= scale.y;
				}
				*/
				
			case 'lord-x':
				frames = Paths.getSparrowAtlas('characters/GAMBLE_X');
				animation.addByPrefix('idle', 'X IDLE', 24, false);
				animation.addByPrefix('singUP', 'X UP', 24, false);
				animation.addByPrefix('singRIGHT', 'X RIGHT', 24, false);
				animation.addByPrefix('singDOWN', 'X DOWN', 24, false);
				animation.addByPrefix('singLEFT', 'X LEFT', 24, false);

				addOffset("singUP", 0, 34);
				addOffset("singRIGHT", -28, 164);
				addOffset("singLEFT", 41, 3);
				addOffset("singDOWN", 0, 8);
				playAnim('idle');

				forceNoMiss = true;

				characterData.healthbarColors = [61, 62, 93];

			case 'googar':
				frames = Paths.getSparrowAtlas('characters/buried/googar_assets');
				animation.addByPrefix('idle', 'googar idle', 24);
				animation.addByPrefix('singUP', 'googar up', 24);
				animation.addByPrefix('singRIGHT', 'googar right', 24);
				animation.addByPrefix('singDOWN', 'googar down', 24);
				animation.addByPrefix('singLEFT', 'googar left', 24);

				playAnim('idle');

				// pixel bullshit
				setGraphicSize(Std.int(width * 6));
				updateHitbox();
				antialiasing = false;

			case 'shinto': 
				frames = Paths.getSparrowAtlas('characters/shinto/shitno_assets');
				animation.addByPrefix('idle', 'shitno_idle', 24);
				animation.addByPrefix('singUP', 'shitno_up', 24);
				animation.addByPrefix('singRIGHT', 'shitno_left', 24);
				animation.addByPrefix('singDOWN', 'shitno_down', 24);
				animation.addByPrefix('singLEFT', 'shitno_right', 24);

				animation.addByPrefix('lose', 'shitno_lose', 24);
				animation.addByPrefix('end', 'shitno_end', 24, false);

				characterData.offsetX = 50;
				characterData.offsetY = -230;

				characterData.camOffsetX = -360;
				characterData.camOffsetY = -120;

				addOffset('lose', -100, -30);

				flipX = true;
				playAnim('idle');

				characterData.facingDirection = LEFT;

				// pixel bullshit
				setGraphicSize(Std.int(width * 6));
				updateHitbox();
				antialiasing = false;
				characterData.healthbarColors = [247, 223, 111];

			case 'shitno': 
				frames = Paths.getSparrowAtlas('characters/shinto/shitno');
				animation.addByPrefix('idle', 'Idle', 24);
				animation.addByPrefix('singUP', 'Up', 24);
				animation.addByPrefix('singRIGHT', 'Left', 24);
				animation.addByPrefix('singDOWN', 'Down', 24);
				animation.addByPrefix('singLEFT', 'Right', 24);

				characterData.offsetX = 50;
				characterData.offsetY = -230;

				addOffset('singUP', 50, 10);

				flipX = true;
				playAnim('idle');

				characterData.facingDirection = LEFT;

				characterData.healthbarColors = [207, 159, 0];

			case 'grey-cold': 
				frames = Paths.getSparrowAtlas('characters/shinto/Grey_Assets');
				animation.addByPrefix('idle', 'GreyCold_Idle', 24, false); 
				animation.addByPrefix('singUP', 'GreyCold_Up', 24, false);
				animation.addByPrefix('singRIGHT', 'GreyCold_Right', 24, false);
				animation.addByPrefix('singDOWN', 'GreyCold_Down', 24, false);
				animation.addByPrefix('singLEFT', 'GreyCold_Left', 24, false);
				animation.addByPrefix('singLEFTmiss', 'GreyCold_Miss_Left', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'GreyCold_Miss_Right', 24, false);
				animation.addByPrefix('singUPmiss', 'GreyCold_Miss_Up', 24, false);
				animation.addByPrefix('singDOWNmiss', 'GreyCold_Miss_Down', 24, false);
				animation.addByPrefix('talk', 'GreyCold_Talk', 24, false); 
				animation.addByPrefix('turn', 'GreyCold_Turn', 24, false); 
				playAnim('idle');

				characterData.facingDirection = LEFT;
				characterData.healthbarColors = [207, 167, 175];

				setGraphicSize(Std.int(width * 2));
				updateHitbox();
				antialiasing = false;

			case 'grey': 
				frames = Paths.getSparrowAtlas('characters/shinto/Grey_Assets');
				animation.addByPrefix('idle', 'Grey_Idle', 24, false); 
				animation.addByPrefix('singUP', 'Grey_Up', 24, false);
				animation.addByPrefix('singRIGHT', 'Grey_Left', 24, false);
				animation.addByPrefix('singDOWN', 'Grey_Down', 24, false);
				animation.addByPrefix('singLEFT', 'Grey_Right', 24, false);
				animation.addByPrefix('singLEFTmiss', 'Grey_Miss_Right', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'Grey_Miss_Left', 24, false);
				animation.addByPrefix('singUPmiss', 'Grey_Miss_Up', 24, false);
				animation.addByPrefix('singDOWNmiss', 'Grey_Miss_Down', 24, false);
				animation.addByPrefix('talk2', 'Grey_Talk1', 24, false);
				animation.addByPrefix('talk', 'Grey_Talk2', 24, false);
				playAnim('idle');

				characterData.facingDirection = LEFT;
				characterData.healthbarColors = [207, 167, 175];

				setGraphicSize(Std.int(width * 2));
				updateHitbox();
				antialiasing = false;

			case 'steven-front':
				frames = Paths.getSparrowAtlas('characters/steven/steve');
				animation.addByPrefix('idle', 'STEVE IDLE', 24, false);
				animation.addByPrefix('singUP', 'STEVE UP', 24, false);
				animation.addByPrefix('singLEFT', 'STEVE LEFT', 24, false);
				animation.addByPrefix('singRIGHT', 'STEVE RIGHT', 24, false);
				animation.addByPrefix('singDOWN', 'STEVE DOWN', 24, false);

				addOffset('idle');
				addOffset('singLEFT', 59, 19);
				addOffset('singRIGHT', -17, 38);
				addOffset('singDOWN', 20, -10);
				addOffset('singUP', 17, 29);

				playAnim('idle');

				characterData.facingDirection = LEFT;
				characterData.healthbarColors = [179, 0, 0];
				characterData.camOffsetX = -400;

			case 'steven-start':
				frames = Paths.getSparrowAtlas('characters/steven/alt_steven_pov');
				animation.addByPrefix('idle', 'idle', 24, false);
				animation.addByPrefix('singUP', 'up', 24, false);
				animation.addByPrefix('singLEFT', 'left', 24, false);
				animation.addByPrefix('singRIGHT', 'right', 24, false);
				animation.addByPrefix('singDOWN', 'down', 24, false);

				addOffset('idle');
				addOffset('singLEFT', 3, -20);
				addOffset('singRIGHT', -11, 5);
				addOffset('singDOWN', 0, -34);
				addOffset('singUP', 10, 21);

				playAnim('idle');

				setGraphicSize(Std.int(width * 1.5));
				updateHitbox();
				characterData.facingDirection = RIGHT;
				characterData.healthbarColors = [179, 0, 0];
				characterData.camOffsetX = -225;
				characterData.camOffsetY = -100;

			case 'steven-bed':
				frames = Paths.getSparrowAtlas('characters/steven/steven_phase_1');
				animation.addByPrefix('idle', 'IDLE', 24, false);
				animation.addByPrefix('singUP', 'UP', 24, false);
				animation.addByPrefix('singLEFT', 'LEFT', 24, false);
				animation.addByPrefix('singRIGHT', 'RIGHT', 24, false);
				animation.addByPrefix('singDOWN', 'DOWN', 24, false);

				addOffset('idle');
				addOffset('singLEFT', -10, 0);
				addOffset('singRIGHT', -18, 0);
				addOffset('singDOWN', -8, 1);
				addOffset('singUP', -12, 0);

				playAnim('idle');

				characterData.facingDirection = RIGHT;
				characterData.healthbarColors = [179, 0, 0];
				characterData.camOffsetX = -300;
				characterData.camOffsetY = -85;
				characterData.zoomOffset = 0.1;

			case 'steven-fp':
				frames = Paths.getSparrowAtlas('characters/steven/steven_phase_2');
				animation.addByPrefix('idle', 'SR IDLE', 24, false);
				animation.addByPrefix('singUP', 'SR UP', 24, false);
				animation.addByPrefix('singLEFT', 'SR LEFT', 24, false);
				animation.addByPrefix('singRIGHT', 'SR RIGHT', 24, false);
				animation.addByPrefix('singDOWN', 'SR DOWN', 24, false);

				addOffset('idle');
				addOffset('singLEFT', 50, -14);
				addOffset('singRIGHT', -10, -20);
				addOffset('singDOWN', 2, -78);
				addOffset('singUP', 0, 20);

				playAnim('idle');

				characterData.facingDirection = LEFT;
				characterData.healthbarColors = [179, 0, 0];
				
				characterData.camOffsetX = -125;
				characterData.camOffsetY = -250;
				characterData.zoomOffset = 0.00;

			case 'mike-bed':
				atlasCharacter = new FlxAnimate(x, y, Paths.getPath('images/characters/atlases/mikebed', TEXT));
				atlasCharacter.anim.addByAnimIndices('idle', indicesContinueAmount(12), 24);
				atlasCharacter.anim.addByAnimIndices('singDOWN', indicesContinueAmount(8), 24);
				atlasCharacter.anim.addByAnimIndices('singLEFT', indicesContinueAmount(8), 24);
				atlasCharacter.anim.addByAnimIndices('singUP', indicesContinueAmount(8), 24);
				atlasCharacter.anim.addByAnimIndices('singRIGHT', indicesContinueAmount(8), 24);
				atlasCharacter.anim.addByAnimIndices('singDOWNmiss', indicesContinueAmount(8), 24);
				atlasCharacter.anim.addByAnimIndices('singLEFTmiss', indicesContinueAmount(8), 24);
				atlasCharacter.anim.addByAnimIndices('singUPmiss', indicesContinueAmount(8), 24);
				atlasCharacter.anim.addByAnimIndices('singRIGHTmiss', indicesContinueAmount(8), 24);

				atlasCharacter.scale.set(0.8, 0.8);
				atlasCharacter.antialiasing = true;

				setGraphicSize(Std.int(width * 0.8));

				visible = false;
				playAnim('idle');

				characterData.offsetX = -450;
				characterData.offsetY = -525;
				characterData.camOffsetX = -450;
				characterData.camOffsetY = 285;
				characterData.healthbarColors = [248, 143, 60];
				characterData.facingDirection = LEFT;

			case 'mike-fp':
				frames = Paths.getSparrowAtlas('characters/mike/BRO_DEAD');
				animation.addByPrefix('idle', 'BRO IDLE', 24, false);
				animation.addByPrefix('singUP', 'BRO UP', 24, false);
				animation.addByPrefix('singLEFT', 'BRO LEFT', 24, false);
				animation.addByPrefix('singRIGHT', 'BRO RIGHT', 24, false);
				animation.addByPrefix('singDOWN', 'BRO DOWN', 24, false);

				addOffset('idle');
				addOffset('singLEFT', 72, -2);
				addOffset('singRIGHT', -10, 10);
				addOffset('singDOWN', -28, -8);
				addOffset('singUP', 0, 0);

				playAnim('idle');

				characterData.facingDirection = LEFT;
				characterData.healthbarColors = [248, 143, 60];

			case 'mike-death':
				frames = Paths.getSparrowAtlas('characters/death/mike/Red_Game_Over_Assets_culosfortnite');
				animation.addByPrefix('firstDeath', 'Death', 24, false);
				animation.addByPrefix('deathLoop', 'Dead Loop', 24, true);
				animation.addByPrefix('deathConfirm', 'Confirm', 24, false);

				addOffset('firstDeath', 38, 65);
				addOffset('deathLoop', 37, 65);
				addOffset('deathConfirm', 37, 71);

				playAnim('firstDeath');
				
				//characterData.offsetY = 450;
				//characterData.camOffsetX = 0;
				characterData.camOffsetY = 0;
				characterData.facingDirection = LEFT;

			case 'gffisk':
				frames = Paths.getSparrowAtlas('characters/gffisk_assets', 'shitpost');
				animation.addByPrefix('idle', 'gffisk idle', 24);
				animation.addByPrefix('singUP', 'gffisk up', 24);
				animation.addByPrefix('singRIGHT', 'gffisk right', 24);
				animation.addByPrefix('singDOWN', 'gffisk down', 24);
				animation.addByPrefix('singLEFT', 'gffisk left', 24);
				animation.addByPrefix('GOD', 'the power of God', 24);
				characterData.facingDirection = LEFT;
				playAnim('idle');
				// pixel bullshit
				setGraphicSize(Std.int(width * 4));
				updateHitbox();
				antialiasing = false;

				characterData.offsetX = 50;
				characterData.offsetY = 250;

				characterData.camOffsetX = 180;
				characterData.camOffsetY = -120;
			case 'hypno-sdan':
				frames = Paths.getSparrowAtlas('characters/hypno_sdan_assets', 'shitpost');
				animation.addByPrefix('danceLeft', 'hypno sdan dance left', 24);
				animation.addByPrefix('danceRight', 'hypno sdan dance right', 24);
				animation.addByPrefix('singUP', 'hypno sdan up', 24);
				animation.addByPrefix('singRIGHT', 'hypno sdan right', 24);
				animation.addByPrefix('singDOWN', 'hypno sdan down', 24);
				animation.addByPrefix('singLEFT', 'hypno sdan left', 24);
				characterData.facingDirection = RIGHT;
				playAnim('idle');
				// pixel bullshit
				setGraphicSize(Std.int(width * 4));
				updateHitbox();
				antialiasing = false;

				characterData.offsetX = 150;
				characterData.offsetY = 230;

				characterData.camOffsetX = -360;
				characterData.camOffsetY = -120;
			case 'minecrftno':
				frames = Paths.getSparrowAtlas('characters/minecrftno', 'shitpost');
				animation.addByIndices('danceLeft', 'missingo_idle', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'missingo_idle', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28], "", 24, false);
				animation.addByPrefix('intro', 'missingo_intro', 24, false);
				animation.addByPrefix('singUP', 'missingo_up', 24, false);
				animation.addByPrefix('singLEFT', 'missingo_left', 24, false);
				animation.addByPrefix('singRIGHT', 'missingo_right', 24, false);
				animation.addByPrefix('singDOWN', 'missingo_down', 24, false);
				dance();
				
				// setGraphicSize(Std.int(width * 6));
				// updateHitbox();

				characterData.facingDirection = RIGHT;
				characterData.offsetY = -32;
				
				antialiasing = true;
			case 'minecrftbf':
				frames = Paths.getSparrowAtlas('characters/bf_but_in_minecrftno', 'shitpost');
				animation.addByPrefix('idle', 'lolbf_idle', 24, false);
				animation.addByPrefix('singUP', 'lolbf_up', 24, false);
				animation.addByPrefix('singLEFT', 'lolbf_left', 24, false);
				animation.addByPrefix('singRIGHT', 'lolbf_right', 24, false);
				animation.addByPrefix('singDOWN', 'lolbf_down', 24, false);
				characterData.facingDirection = LEFT;
				playAnim('idle');
				
				// setGraphicSize(Std.int(width * 6));
				// updateHitbox();
				antialiasing = true;
			case 'minecrftgf':
				frames = Paths.getSparrowAtlas('characters/gf_but_in_minecrftno', 'shitpost');
				animation.addByPrefix('idle', 'lolgf', 24, true);
				playAnim('idle');
				
				// setGraphicSize(Std.int(width * 6));
				// updateHitbox();
				antialiasing = true;

			default:
				frames = Paths.getSparrowAtlas('characters/boyfreb');
				animation.addByPrefix('idle', 'freb', 1, true);
				playAnim('idle');
				characterData.healthbarColors = [49, 176, 209];
		}

		dance();

		// fuck you ninjamuffin lmao
		if ((isPlayer && characterData.facingDirection != LEFT) 
		|| (!isPlayer && characterData.facingDirection != RIGHT))
			flipLeftRight();

		if (adjustPos) {
			x += characterData.offsetX;
			trace('character ${curCharacter} scale ${scale.y}');
			y += (characterData.offsetY - (frameHeight * scale.y));
		}

		this.x = x;
		this.y = y;

		// /*
		if (atlasCharacter != null) 
			atlasCharacter.setPosition(this.x, this.y);
		// */
		return this;
	}

	public static function generateIndicesAtPoint(point:Int, amount:Int):Array<Int> {
		var returnArray:Array<Int> = [];
		for (i in 0...amount) 
			returnArray.push((point - 1) + i);
		return returnArray;
	}

	public var currentIndex:Int = 1;
	public function indicesContinueAmount(amount:Int):Array<Int> {
		var theArray:Array<Int> = generateIndicesAtPoint(currentIndex, amount);
		currentIndex += amount;
		return theArray;
	}

	public function resizeOffsets() {
		for (i in animOffsets.keys())
			animOffsets[i] = [animOffsets[i][0] * scale.x, animOffsets[i][1] * scale.y];
	}

	public function flipLeftRight():Void
	{
		// flip sprites in pairs
		var animations:Array<Array<String>> = [['singLEFT', 'singRIGHT'], ['singLEFTmiss', 'singRIGHTmiss']];
		for (pair in animations) {
			// should always be in groups of two
			if (animation.getByName(pair[0]) != null 
			 && animation.getByName(pair[1]) != null) {
				var firstAnim = animation.getByName(pair[0]).frames;
				var secondAnim = animation.getByName(pair[1]).frames;
				animation.getByName(pair[0]).frames = secondAnim;
				animation.getByName(pair[1]).frames = firstAnim;	

				if (animOffsets.exists(pair[0]) 
				 && animOffsets.exists(pair[1])) {
					var firstAnimOffset = animOffsets[pair[0]];
					var secondAnimOffset = animOffsets[pair[1]];
					animOffsets[pair[0]] = firstAnimOffset;
					animOffsets[pair[1]] = secondAnimOffset;
				}
			}
		}

		// flip
		flipX = !flipX;
	}

	public function flipUpDown():Void
		{
			// flip sprites in pairs
			var animations:Array<Array<String>> = [['singUP', 'singDOWN'], ['singUPmiss', 'singDOWNmiss']];
			for (pair in animations) {
				// should always be in groups of two
				if (animation.getByName(pair[0]) != null 
				 && animation.getByName(pair[1]) != null) {
					var firstAnim = animation.getByName(pair[0]).frames;
					var secondAnim = animation.getByName(pair[1]).frames;
					animation.getByName(pair[0]).frames = secondAnim;
					animation.getByName(pair[1]).frames = firstAnim;	
	
					if (animOffsets.exists(pair[0]) 
					 && animOffsets.exists(pair[1])) {
						var firstAnimOffset = animOffsets[pair[0]];
						var secondAnimOffset = animOffsets[pair[1]];
						animOffsets[pair[0]] = firstAnimOffset;
						animOffsets[pair[1]] = secondAnimOffset;
					}
				}
			}
	
			// flip
			flipX = !flipX;
		}

	override function update(elapsed:Float)
	{
		if (!isPlayer)
		{
			// /*
			if (atlasCharacter != null) {
				if (atlasAnimation.startsWith('sing'))
					holdTimer += elapsed;
			} else {
				if (animation.curAnim.name.startsWith('sing'))
					holdTimer += elapsed;
			}
			
			var dadVar:Float = 4;
			if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001) {
				dance();
				holdTimer = 0;
			}
		}

		if (isPressing) {
			coverEars(true);
			uncoverCooldown = (8 * (Conductor.stepCrochet / 1000));
		}
		else {
			uncoverCooldown -= elapsed;
			if (uncoverCooldown <= 0)
				coverEars(false);
		}
		super.update(elapsed);
	}

	private var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance(?forced:Bool = false)
	{
		if (!debugMode)
		{
			var curCharSimplified:String = simplifyCharacter();
			switch (curCharSimplified)
			{
				default:
					// Left/right dancing, think Skid & Pump
					if (atlasCharacter != null) {
						playAnim('idle', forced);
					} else {
						if (animation.getByName('danceLeft') != null && animation.getByName('danceRight') != null)
						{
							danced = !danced;
							if (danced)
								playAnim('danceRight', forced);
							else
								playAnim('danceLeft', forced);
						}
						else if (animation.getByName('idle' + idleSuffix) != null)
						{
							playAnim('idle' + idleSuffix, forced);
						}
						else
							playAnim('idle', forced);
					}

			}
		}
	}

	public var atlasAnimation:String = ''; //  fuck you flxanimate
	public var isPressing:Bool = false;
	public var uncoverCooldown:Float;

	public function coverEars(?yaCover:Bool = false) {
		if (isCovering != yaCover && !hasTransformed) {
			canAnimate = false;
			var modifier = '';
			if (curCharacter == 'dawn-bf')
				modifier += '-boyfriend';
			atlasCharacter.anim.play('transition' + modifier, true, !yaCover, (yaCover ? 0 : 4));
			atlasAnimation = 'transition' + modifier;
			isCovering = yaCover;
			atlasCharacter.anim.onComplete = function()
			{
				if (atlasAnimation.contains('transition') && !canAnimate) {
					canAnimate = true;
					dance();
				}
			};
		}
	}

	public function transformDawn()
	{
		if (!hasTransformed)
		{
			canAnimate = false;
			atlasCharacter.anim.play('transform');
			atlasAnimation = 'transform';
			hasTransformed = true;
			atlasCharacter.anim.onComplete = function()
			{
				if (atlasAnimation.contains('transform') && !canAnimate) {
					canAnimate = true;
					dance();
				}
			};
		}
	}

	override public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		if (!canAnimate || (atlasAnimation.contains('transition')
			&& ((!atlasCharacter.anim.reversed && atlasCharacter.anim.curFrame < 3)
			|| (atlasCharacter.anim.reversed && atlasCharacter.anim.curFrame > 2)))) {
			return;
		} else canAnimate = true;

		var modifier = '';
		if (isCovering && !hasTransformed)
			modifier += '-cover';
		if (hasTransformed)
			modifier += '-transformed';
		if (curCharacter == 'dawn-bf')
			modifier += '-boyfriend';

		if (atlasCharacter != null) {
			atlasCharacter.anim.play(AnimName + modifier, Force, Reversed, Frame);
			atlasAnimation = AnimName;
		} else {
			animation.play(AnimName, Force, Reversed, Frame);
			var daOffset = animOffsets.get(AnimName);
			if (animOffsets.exists(AnimName))
				offset.set(daOffset[0], daOffset[1]);
			else
				offset.set(0, 0);
		}
	}

	public function simplifyCharacter():String
	{
		var base = curCharacter;

		if (base.contains('-'))
			base = base.substring(0, base.indexOf('-'));
		return base;
	}
}