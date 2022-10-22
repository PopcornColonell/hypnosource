package meta.state;

import meta.subState.UnlockSubstate.Unlockable;
import flxanimate.FlxAnimate;
import meta.data.dependency.FNFSprite;
import gameObjects.userInterface.Lyrics;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxTiledSprite;
import flixel.addons.effects.FlxTrail;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.FlxGraphic;
import flixel.graphics.tile.FlxGraphicsShader;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxShader;
import flixel.system.FlxAssets.FlxSoundAsset;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.ColorTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import gameObjects.*;
import gameObjects.Character;
import gameObjects.userInterface.*;
import gameObjects.userInterface.UnownSubstate;
import gameObjects.userInterface.notes.*;
import gameObjects.userInterface.notes.Strumline.UIStaticArrow;
import meta.*;
import meta.MusicBeat.MusicBeatState;
import meta.data.*;
import meta.data.Events;
import meta.data.ScriptHandler;
import meta.data.Song.SwagSong;
import meta.data.font.AttachedText;
import meta.state.charting.*;
import meta.state.menus.*;
import meta.subState.*;
import openfl.display.GraphicsShader;
import openfl.display.Shader;
import openfl.events.KeyboardEvent;
import openfl.filters.BitmapFilter;
import openfl.filters.ShaderFilter;
import openfl.media.Sound;
import openfl.utils.Assets;
import sys.io.File;
import meta.data.dependency.Discord;

#if sys
import sys.FileSystem;
#end

import vlc.MP4Handler;

using StringTools;


enum abstract GameModes(String) to String {
	var HELL_MODE;
	var NORMAL;
	var PUSSY_MODE;
	var FUCK_YOU;
}

class PlayState extends MusicBeatState
{
	public var startTimer:FlxTimer;

	public static var curStage:String = '';
	public static var SONG:SwagSong;
	@:isVar
	public var songSpeed(get, set):Float = 0;
	public var songSpeedTween:FlxTween;
	public static var laneSpeed:Array<Float> = [0, 0, 0, 0];
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 2;

	public static var songMusic:FlxSound;
	public static var vocals:FlxSound;

	public static var instance:PlayState;

	public static var subtitles:FlxText;

	public var botplayText:FlxText;
	public var botplaySubtext:FlxText;
	public static var botplayQuotes:Map<String, Array<String>> = [
		'safety-lullaby' => ['you took the safety part too seriously'],
		'left-unchecked' => ['its not that hard anymore i fixed it', 'the pendulums not tweened anymore please'],
		'lost-cause' => ['youre the lost cause', 'i know youre in botplay to stare at her ass'],
		'frostbite' => [
			'those psych engine ports go crazy',
			'did you get a brain freeze?',
			"Freakachu's in your insides rip your skin off do it now"
		],
		'insomnia' => [
			'a mimir mode',
			'dont fall asleep',
			'did you fall asleep on your keyboard?',
			'you really didnt wanna wake him up'
		],
		'monochrome' => ['hes an 11 year old corpse', 'did you need more time to type?'],
		'missingno' => ['mew was under the truck', 'i hope your pc actually crashes'],
		'brimstone' => [
			'brimstone betadciu type beat',
			'you probably played the leaked build',
			"Buryman has more life than your will to fucking play",
			'ge ge ge-get your hands back on your keyboard'
		],
		'amusia' => ['i am unamused', 'do you even have a sing?'],
		'bygone-purpose' => ['scrimblini', 'you should jump off like alexis'],
		'dissension' => [
			'why should I play fair?',
			// 'you seriously gonna cheat him again??' i dont think this one works sector
		],
		'death-toll' => [
			'go to hell', 
			"take a bath in the magma", 
			"lmao are you scared of an old dude?",
			"i have the high ground anakin"
		],
		'isotope' => ['we forgot to scrap it', 'Am I a joke to you?'],
		'purin' => ['hyperrealistic?!', 'purin', "Hang out a bit with Nurse Joy", 'do NOT put your dick in those holes'],
		'pasta-night' => ['guess you got counterpicked', 'maybe the kiddie table is for you'],
		'shinto' => ['peak 10/10 expreiuenc', "It's a her you fucking idiot"],
		'shitno' => ['why is it so cold', 'you got cold feet']
	];
	public var botplaySine:Float = 0;
	public static var campaignScore:Int = 0;

	public static var dadOpponent:Character;
	public static var boyfriend:Boyfriend;
	public var bygoneAlexis:Boyfriend;
	public static var alexis:Bool = false;

	var missingnoVHS:GraphicsShader;
	var pastanightCRT:ShaderFilter;
	var missingnoGlitch:GraphicsShader;
	var brimstoneShader:GraphicsShader;

	public var feraligatr:FlxSprite;
	var behindGroup:FlxTypedGroup<FlxSprite>;
	
	public var typhlosion:Character;
	public var freakachu:Character;

	public static var assetModifier:String = 'base';
	public static var changeableSkin:String = 'default';
	public static var buriedNotes:Bool = false;

	public var unspawnNotes:Array<Note> = [];
	private var ratingArray:Array<String> = [];
	private var allSicks:Bool = true;

	// if you ever wanna add more keys
	public static var numberOfKeys:Int = 4;
	public static var playerLane:Int = 1;
	// get it cus release
	// I'm funny just trust me
	private var curSection:Int = 0;
	private var camFollow:FlxObject;
	private var camFollowPos:FlxObject;

	// Discord RPC variables
	public static var songDetails:String = "";
	public static var detailsSub:String = "";
	public static var detailsPausedText:String = "";

	private static var prevCamFollow:FlxObject;

	private var curSong:String = "";
	private var gfSpeed:Int = 1;

	public static var health:Float = 1; // mario
	public static var combo:Int = 0;

	public static var misses:Int = 0;

	public var generatedMusic:Bool = false;

	private var startingSong:Bool = false;
	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	public static var inCutscene:Bool = false;

	public var pausePortraitPrefix:Array<String> = ['', ''];
	public var pausePortraitRevealed:Array<Bool> = [true, true];

	var canPause:Bool = true;

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	public static var camHUD:FlxCamera;
	public static var camGame:FlxCamera;
	public static var vignetteCam:FlxCamera;
	public static var dialogueHUD:FlxCamera;

	public var camDisplaceX:Float = 0;
	public var camDisplaceY:Float = 0; // might not use depending on result
	public static var cameraSpeed:Float = 1;

	public static var cameraCentered:Bool = false;

	public static var defaultCamZoom:Float = 1.05;

	public static var forceZoom:Array<Float>;

	public static var songScore:Int = 0;

	var storyDifficultyText:String = "";

	public static var iconRPC:String = "";

	public static var songLength:Float = 0;
	public static var songDisplayName:String = "";

	public var stageBuild:Stage;

	public static var uiHUD:ClassHUD;
	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var iconBfhypno:HealthIcon;
	public var iconFeraligatr:HealthIcon;

	public var firstPerson:Bool = false;
	public var staticCamera:Bool = false;

	public static var daPixelZoom:Float = 6;
	public static var buriedResize:Float = 0.5;
	public static var determinedChartType:String = "";

	// strumlines
	public var dadStrums:Strumline;
	public var boyfriendStrums:Strumline;

	public var missingnoStarted:Bool = false;
	public static var defaultDownscroll:Bool = false;

	var flashingEnabled:Bool = true;

	public var isDead:Bool = false;

	public static var strumLines:FlxTypedGroup<Strumline>;
	public static var strumHUD:Array<FlxCamera> = [];

	private var allUIs:Array<FlxCamera> = [];

	public var pendulum:FlxSprite;
	var tranceThing:FlxSprite;
	var tranceDeathScreen:FlxSprite;
	var pendulumShadow:FlxTypedGroup<FlxSprite>;
	var psyshockParticle:FlxSprite;	
	var cameraFlash:FlxSprite;

	public var tranceActive:Bool = false;
	public var tranceNotActiveYet:Bool = false;
	public var fadePendulum:Bool = false;

	var accuracyMod:Bool = false;
	var accuracySound:FlxSound;
	var accuracyText:FlxText;
	var accuracyBelow:Bool = false;
	var accuracyFrameDelay:Float = 0;
	var accuracyCameraMove:Bool = false;

	var tranceSound:FlxSound;
	var tranceCanKill:Bool = true;
	var pendulumOffset:Float = 0;
	var psyshockCooldown:Int = 80;
	var keyboardTimer:Int = 8;
	var keyboard:FlxSprite;
	var skippedFirstPendulum:Bool = false;
	var trance:Float = 0;
	var reducedDrain:Float = 3;

	var moneySound:FlxSound;
	
	public static var flashGraphic:FlxGraphic;

	var unowning:Bool = false;

	public static var eventList:Array<PlacedEvent> = [];

	// stores the last judgement object
	public static var lastRating:FlxSprite;
	public static var ratingPosition:FlxPoint;

	// stores the last combo objects in an array
	public static var lastCombo:Array<FlxSprite>;
	public static var gameplayMode:String = NORMAL;

	public var healthBarBA:FlxTiledSprite;
	public var healthBarBF:FlxTiledSprite;

	public static var selectedPasta:Bool = false;
	public static var old:Bool = true;
	public static var songLibrary:String;

	var lordX:Boyfriend;
	public var mx:Boyfriend;
	public var mxHand:Boyfriend;
	var table:FlxSprite;
	var hypno:Boyfriend;
	var hypnoHand:Boyfriend;
	var mxBlock:FlxSprite;

	//Frostbite Mechanics
	var useFrostbiteMechanic:Bool = false;
	var frostbiteTheromometerTyphlosion:FlxSprite;
	var frostbiteTheromometer:FlxSprite;
	var frostbiteBar:FlxBar;
	var coldness:Float = 0.0;
	var coldnessDisplay:Float = 0.0;
	var coldnessRate:Float = 0.0;
	var typhlosionUses:Int = 10;

	//Brimstone Gengar Notes
	var gengarNoteInvis:Float = 0.0;

	public var updateableScript:Array<ForeverModule> = [];
	public static var staticValues:Map<String, Dynamic> = [];
	public var camPos:FlxPoint;

	public static var bronzongMechanic:Bool = false;
	var blurAmount:Float = 0.0;

	// Shop Related Stuff
	var moneyBag:FlxSprite;
	
	// at the beginning of the playstate
	override public function create()
	{
		super.create();
		instance = this;

		var time = Sys.time();
		Events.obtainEvents();
		var newtime = Sys.time();
		trace(newtime - time);
		staticValues.clear();
		staticValues = [];

		// reset any values and variables that are static
		songScore = 0;
		combo = 0;
		health = 1;
		misses = 0;
		// sets up the combo object array
		lastCombo = [];
		eventList = [];

		ratingPosition = new FlxPoint(0, 0);
		alexis = false;

		defaultCamZoom = 1.05;
		cameraSpeed = 1;
		cameraCentered = false;
		forceZoom = [0, 0, 0, 0];
		buriedNotes = false;

		bronzongMechanic = false;
		defaultDownscroll = Init.trueSettings.get('Downscroll');
		flashingEnabled = Init.trueSettings.get('Flashing Lights');

		Timings.callAccuracy();

		assetModifier = 'base';
		changeableSkin = 'default';

		// stop any existing music tracks playing
		resetMusic();
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// create the game camera
		camGame = new FlxCamera();

		// create the hud camera (separate so the hud stays on screen)
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		allUIs.push(camHUD);
		FlxCamera.defaultCameras = [camGame];

		// default song
		if (SONG == null)
			SONG = Song.loadFromJson('test', 'test', old);

		playerLane = 1;
		if (SONG.song.toLowerCase() == 'pasta-night' && !selectedPasta) {
			persistentDraw = false;
			persistentUpdate = false;
			openSubState(new PastaNightSelect());
		} else if (selectedPasta) {
			playerLane = PastaNightSelect.selector;
			selectedPasta = false;
		}

		// FlxTransitionableState.defaultTransIn = FlxTransitionableState.defaultTransIn;

		songSpeed = SONG.speed;
		//
		laneSpeed = [SONG.speed, SONG.speed, SONG.speed, SONG.speed];
		prevLaneSpeed = [SONG.speed, SONG.speed, SONG.speed, SONG.speed];

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		/// here we determine the chart type!
		// determine the chart type here
		determinedChartType = "FNF";

		// set up a class for the stage type in here afterwards
		curStage = "stage";
		if (SONG.stage != null)
			curStage = SONG.stage;

		// cache shit
		displayRating('sick', 'early', true);
		popUpCombo(true);
		//

		dadOpponent = new Character().setCharacter(50, 850, SONG.player2);
		boyfriend = new Boyfriend();
		boyfriend.setCharacter(750, 850, SONG.player1);

		camPos = new FlxPoint(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);

		// set song position before beginning
		Conductor.songPosition = -(Conductor.crochet * 4);

		var darknessBG:FlxSprite = new FlxSprite(FlxG.width * -0.5, FlxG.height * -0.5).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		darknessBG.alpha = (100 - Init.trueSettings.get('Stage Opacity')) / 100;
		darknessBG.scrollFactor.set(0, 0);

		// initialize ui elements
		startingSong = true;
		startedCountdown = true;
		
		stageBuild = new Stage(curStage);
		add(stageBuild);

		changeableSkin = Init.trueSettings.get("UI Skin");

		behindGroup = new FlxTypedGroup<FlxSprite>();
		add(behindGroup);

		add(dadOpponent);
		add(boyfriend);		

		if (dadOpponent.atlasCharacter != null)
			add(dadOpponent.atlasCharacter);

		if (boyfriend.atlasCharacter != null)
			add(boyfriend.atlasCharacter);

		if (curStage == "bygone") {
			bygoneAlexis = new Boyfriend();

			bygoneAlexis.setCharacter(1200, 400, "alexis");
			bygoneAlexis.alpha = 0;
			add(bygoneAlexis);
		}
		
		add(stageBuild.foreground);
		add(darknessBG);

		backgroundGroup = new FlxTypedGroup<FlxSprite>();
		add(backgroundGroup);
		backgroundGroup.cameras = [camHUD];

		var pokehuds:Array<FlxSprite> = [];
		if (SONG.song.toLowerCase() == 'brimstone')
		{
			// create the thingy
			// camZooming = false;
			assetModifier = 'pixel';
			midPoint = (FlxG.width / 4) + ((32 * daPixelZoom * buriedResize) * 1.5);
			var secondSprite:Bool = false;
			for (i in 0...2)
			{
				var pokeHUD:FlxSprite = new FlxSprite().loadGraphic(Paths.image('UI/pixel/buried_hud'), true, 165, 54);
				pokeHUD.animation.add('pokeHUD', [0, 1], 0, false);
				pokeHUD.animation.play('pokeHUD');
				if (!secondSprite)
				{
					pokeHUD.animation.curAnim.curFrame = 0;
					secondSprite = true;
				}
				else
					pokeHUD.animation.curAnim.curFrame = 1;
				//
				pokeHUD.setGraphicSize(Std.int(pokeHUD.width * daPixelZoom * buriedResize));
				pokeHUD.updateHitbox();
				var downscroll = false;
				var hudShift = 30;
				if (i == 0)
					pokeHUD.y = (downscroll ? FlxG.height - (pokeHUD.height + hudShift) : 0 + hudShift);
				else
				{
					downscroll = !downscroll;
					pokeHUD.x = FlxG.width - pokeHUD.width;
					pokeHUD.y = (downscroll ? FlxG.height - (pokeHUD.height + hudShift) : 0 + hudShift);
				}
				add(pokeHUD);
				pokehuds.push(pokeHUD);
				pokeHUD.cameras = [camHUD];
			}
			healthBarBA = new FlxTiledSprite(Paths.image('UI/pixel/brimstone_healthbar'), 52 * 3, 2 * 3, false, false);
			healthBarBF = new FlxTiledSprite(Paths.image('UI/pixel/brimstone_healthbar'), 52 * 3, 2 * 3, false, false);
			for (i in 0...2)
			{
				// kms
				var buriedHealthBar:FlxTiledSprite;
				if (i == 0)
					buriedHealthBar = (Init.trueSettings.get("Downscroll") ? healthBarBA : healthBarBF);
				else
					buriedHealthBar = (Init.trueSettings.get("Downscroll") ? healthBarBF : healthBarBA);
				buriedHealthBar.cameras = [camHUD];
				add(buriedHealthBar);
				if (i == 0)
					buriedHealthBar.setPosition(pokehuds[0].x + 43 * 3, pokehuds[0].y + 48 * 3);
				else
					buriedHealthBar.setPosition(pokehuds[1].x + 79 * 3, pokehuds[1].y + 48 * 3);
			}
			//
			buriedNotes = true;
		}

		// strum setup
		strumLines = new FlxTypedGroup<Strumline>();
		Note.swagWidth = 160 * 0.7;

		switch (SONG.song.toLowerCase())
		{
			default:
				if (!SONG.threeLanes)
				{
					dadStrums = new Strumline(placement - midPoint, this, [dadOpponent], false, true, false, 4, Init.trueSettings.get('Downscroll'));
					dadStrums.visible = !Init.trueSettings.get('Centered Notefield');
					boyfriendStrums = new Strumline(placement + (!Init.trueSettings.get('Centered Notefield') ? midPoint : 0), this, [boyfriend], true, false,
						true, numberOfKeys, Init.trueSettings.get('Downscroll'));

					strumLines.add(dadStrums);
					strumLines.add(boyfriendStrums);

					boyfriendStrums.singingCharacters = [boyfriend];
					dadStrums.singingCharacters = [dadOpponent];
				}
				else
				{
					Note.swagWidth *= 0.9;
					var amount:Int = 3;
					for (i in 0...3)
					{
						var strumline:Strumline = new Strumline((((i + 0.5) / amount) * FlxG.width), this, [], i == playerLane ? true : false,
							i == playerLane ? false : true, i == playerLane ? true : false, 4, Init.trueSettings.get('Downscroll'));
						strumLines.add(strumline);
					}
				}

			case 'brimstone':
				if (Init.trueSettings.get('Downscroll'))
					midPoint = -midPoint + (Note.swagWidth / 2);
				dadStrums = new Strumline(placement - midPoint, this, [dadOpponent], false, true, false, 4, !Init.trueSettings.get('Downscroll'));
				dadStrums.visible = !Init.trueSettings.get('Centered Notefield');
				boyfriendStrums = new Strumline(placement + (!Init.trueSettings.get('Centered Notefield') ? (midPoint) : 0), this, [boyfriend], true, false,
					true, 4, Init.trueSettings.get('Downscroll'));

				strumLines.add(dadStrums);
				strumLines.add(boyfriendStrums);

				boyfriendStrums.singingCharacters = [boyfriend];
				dadStrums.singingCharacters = [dadOpponent];
			case 'pasta-night':
				// fpSong();
				firstPerson = true;
				staticCamera = true;
				//
				Note.swagWidth *= 0.9;
				var amount:Int = 3;
				dadOpponent.visible = false;
				boyfriend.visible = false;
				// mx
				mx = new Boyfriend(); // haha get it like boyfriend the creator of mx
				mx.setCharacter(0, 0, 'mx');
				mx.screenCenter();
				mx.isPlayer = (0 == playerLane);
				mxHand = new Boyfriend();
				mxHand.setCharacter(0, 0, 'mx-front');
				mxHand.screenCenter();
				mxHand.isPlayer = (0 == playerLane);

				mx.x -= 480;
				mx.y += 280;
				mxHand.x -= 480;
				mxHand.y += 280;

				//
				mxBlock = new FlxSprite();
				mxBlock.frames = Paths.getSparrowAtlas('characters/mx/mxblock');
				mxBlock.animation.addByPrefix('idle', 'blockIdle', 24, false);
				mxBlock.antialiasing = true;
				mxBlock.setPosition(mx.x, mx.y);
				mxBlock.x -= 185;
				mxBlock.y += 460;

				var mxStrum:Strumline = new Strumline((((0 + 0.5) / amount) * FlxG.width), this, [mx, mxHand], 0 == playerLane ? true : false,
					0 == playerLane ? false : true, 0 == playerLane ? true : false, 4, Init.trueSettings.get('Downscroll'));
				strumLines.add(mxStrum);
				mxStrum.singingCharacters = [mx, mxHand];

				// lord x
				lordX = new Boyfriend();
				lordX.setCharacter(0, 0, 'lord-x');
				lordX.setPosition(boyfriend.x - 400, boyfriend.y + 100);

				var lordXStrum:Strumline = new Strumline((((1 + 0.5) / amount) * FlxG.width), this, [lordX], 1 == playerLane ? true : false,
					1 == playerLane ? false : true, 1 == playerLane ? true : false, 4, Init.trueSettings.get('Downscroll'));
				strumLines.add(lordXStrum);
				lordXStrum.singingCharacters = [lordX];
				lordX.isPlayer = (1 == playerLane);

				// hypno
				hypno = new Boyfriend();
				hypno.setCharacter(0, 0, 'hypno-cards');
				hypno.setPosition(lordX.x + 350, lordX.y);
				hypno.isPlayer = (2 == playerLane);
				hypnoHand = new Boyfriend();
				hypnoHand.setCharacter(0, 0, 'hypno-cards-front');
				hypnoHand.setPosition(hypno.x + hypno.width / 2, hypno.y + hypno.height / 2);
				hypnoHand.x -= hypnoHand.width / 2; 
				hypnoHand.y -= hypnoHand.height / 2;
				hypnoHand.isPlayer = (2 == playerLane);

				var hypnoStrum:Strumline = new Strumline((((2 + 0.5) / amount) * FlxG.width), this, [hypno, hypnoHand], 2 == playerLane ? true : false,
					2 == playerLane ? false : true, 2 == playerLane ? true : false, 4, Init.trueSettings.get('Downscroll'));
				strumLines.add(hypnoStrum);
				hypnoStrum.singingCharacters = [hypno, hypnoHand];

				Paths.setCurrentLevel('assets/stages/bar');
				table = new FlxSprite().loadGraphic(Paths.image('TABLE'));
				Paths.revertCurrentLevel();
				//
				table.setGraphicSize(Std.int(table.width * 0.75));
				table.updateHitbox();
				table.antialiasing = true;
				table.screenCenter();
				table.x -= 50;
				table.y += 750;

				// add(chair);
				add(mx);
				add(hypno);
				add(table);
				add(lordX);
				add(mxHand);
				add(hypnoHand);
				add(mxBlock);
		} 

		// force them to dance
		dadOpponent.dance();
		boyfriend.dance();

		// strumline camera setup
		strumHUD = [];
		for (i in 0...strumLines.length) {
			// generate a new strum camera
			strumHUD[i] = new FlxCamera();
			strumHUD[i].bgColor.alpha = 0;

			strumHUD[i].cameras = [camHUD];
			allUIs.push(strumHUD[i]);
			FlxG.cameras.add(strumHUD[i]);
			// set this strumline's camera to the designated camera
			strumLines.members[i].cameras = [strumHUD[i]];
		}
		add(strumLines);

		if (SONG.song.toLowerCase() == 'pasta-night') {
			for (i in 0...strumHUD.length) 
				strumHUD[i].alpha = 0.5;
			strumHUD[playerLane].alpha = 1;

			if (Init.trueSettings.get("Centered Notefield")) {
				for (i in 0...strumLines.members.length) {
					if (i != playerLane)
						strumLines.members[i].visible = false;
					else {
						strumLines.members[i] = new Strumline((0.5 * FlxG.width), this, strumLines.members[i].character, true, false, true, 4, Init.trueSettings.get('Downscroll'));
						strumLines.members[i].singingCharacters = strumLines.members[i].character;
						strumLines.members[i].cameras = [strumHUD[playerLane]];
					}
				}
			}

			var tint:FlxSprite = new FlxSprite(-400, -400).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.YELLOW);
			tint.alpha = 0.04;
			add(tint);
			tint.cameras = [camHUD];
		}

		// gen hud
		trace('new hud, what the fuck????????');
		uiHUD = new ClassHUD();
		add(uiHUD);
		uiHUD.cameras = [camHUD];
		//

		add(uiHUD.iconGroup);
		add(uiHUD.scoreBar);
		add(uiHUD.accuracyBar);
		uiHUD.iconGroup.cameras = [camHUD];
		uiHUD.scoreBar.cameras = [camHUD];
		uiHUD.accuracyBar.cameras = [camHUD];

		var group:FlxTypedGroup<FlxBasic> = new FlxTypedGroup<FlxBasic>();
		add(group);

		if (!buriedNotes) {
			if (SONG.song.toLowerCase() == 'pasta-night') {
				var scale:Float = 0.6;
				var top:Bool = true;
				for (i in 0...groupIcons.length) {
					var icon = new HealthIcon(groupIcons[i], (i == playerLane));
					icon.y = uiHUD.healthBar.y - (icon.height / 2) + icon.offsetY;
					if (i != playerLane) {
						icon.y = uiHUD.healthBar.y - (icon.height / 3) + (icon.height / 6) * (top ? -1 : 1);
						icon.offsetX = 8 * (top ? -1 : 1);
						top = false;
					}
					uiHUD.iconGroup.add(icon);
					icon.scale.set(scale, scale);
					icon.initialWidth *= scale;
				}
				uiHUD.iconGroup.members[playerLane].scale.set(1, 1);
				uiHUD.iconGroup.members[playerLane].initialWidth *= 1/scale;

				uiHUD.iconGroup.sort(FlxSort.byY, FlxSort.DESCENDING);

				// create bar
				var colorData:Array<Array<Int>> = [[63, 9, 4], [61, 62, 93], [249, 223, 68]];
				var playerColor:FlxColor = FlxColor.fromRGB(colorData[playerLane][0], colorData[playerLane][1], colorData[playerLane][2]);
				// this is bullshit but its 3 am and im tired lmfao I just wanted to abstract the colors that werent the players fuck my life
				var colorStack:Array<Int> = [];
				for (i in 0...colorData.length) {
					if (i != playerLane)
						colorStack.push(i);
				}
				var opponentGradient = FlxColor.gradient(FlxColor.fromRGB(colorData[colorStack[0]][0], colorData[colorStack[0]][1],
					colorData[colorStack[0]][2]), FlxColor.fromRGB(colorData[colorStack[1]][0], colorData[colorStack[1]][1], colorData[colorStack[1]][2]), 8);
				uiHUD.healthBar.createGradientBar(opponentGradient, [playerColor], 1, 90);
			} else {
				iconP1 = new HealthIcon(SONG.player1, true);
				iconP1.y = uiHUD.healthBar.y - (iconP1.height / 2) + iconP1.offsetY;
				uiHUD.iconGroup.add(iconP1);
				iconP1.cameras = [camHUD];
				trace('icon ${SONG.player2}');
				iconP2 = new HealthIcon(SONG.player2, false);
				iconP2.y = uiHUD.healthBar.y - (iconP2.height / 2) + iconP2.offsetY;
				uiHUD.iconGroup.add(iconP2);
				iconP2.cameras = [camHUD];
			}
		}

		songDisplayName = SONG.song;
		
		// generate the song
		generateSong(SONG.song);

		// parse shit for the unowns
		UnownSubstate.init();

		// okay I need to stop making cameras
		vignetteCam = new FlxCamera();
		vignetteCam.bgColor.alpha = 0;
		FlxG.cameras.add(vignetteCam);

		// create a hud over the hud camera for dialogue
		dialogueHUD = new FlxCamera();
		dialogueHUD.bgColor.alpha = 0;
		FlxG.cameras.add(dialogueHUD);

		if (sys.FileSystem.exists(Paths.songJson(SONG.song.toLowerCase(), 'lyrics', false))) {
			trace('ly rics');
			var myLyrics:Array<LyricMeasure> = Lyrics.parseLyrics(SONG.song.toLowerCase());
			var lyrics:Lyrics = new Lyrics(myLyrics);
			add(lyrics);
			lyrics.cameras = [dialogueHUD];
		}
		
		botplayText = new FlxText(400, 75 + (Init.trueSettings.get('Downscroll') ? FlxG.height - 200 : 0), FlxG.width - 800, "BOTPLAY", 32);
		botplayText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayText.scrollFactor.set();
		botplayText.borderSize = 1.25;
		add(botplayText);
		botplayText.cameras = [dialogueHUD];
		var quoteList:Array<String> = botplayQuotes.get(CoolUtil.spaceToDash(SONG.song.toLowerCase()));
		if (quoteList != null && quoteList.length > 0)
		{
			botplaySubtext = new FlxText(0, 0, 0, quoteList[FlxG.random.int(0, quoteList.length - 1)]);
			botplaySubtext.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			botplaySubtext.y = botplayText.y + 24;
			botplaySubtext.screenCenter(X);
			botplaySubtext.scrollFactor.set();
			add(botplaySubtext);
			botplaySubtext.cameras = [dialogueHUD];
		}

		// set the camera position to the center of the stage
		var positionArray = getPositionArrayCenter();
		camPos.set(positionArray[0], positionArray[1]);
		manualCameraPosition = new FlxPoint();
		
		// switch song
		stageBuild.stageCreatePost();
		
		if (gameplayMode != PUSSY_MODE) {
			// switch character
			pendulum = new FlxSprite();
			if (SONG.player2 == 'hypno')
			{
				pendulumShadow = new FlxTypedGroup<FlxSprite>();

				pendulum.frames = Paths.getSparrowAtlas('UI/base/hypno/Pendelum');
				pendulum.animation.addByPrefix('idle', 'Pendelum instance 1', 24, true);
				pendulum.animation.play('idle');
				pendulum.antialiasing = true; // fuck you ASH

				pendulum.scale.set(1.3, 1.3);
				pendulum.updateHitbox();
				pendulum.origin.set(65, 0);
				pendulumOffset = -9;
				pendulum.angle = pendulumOffset;
				add(pendulumShadow);
				add(pendulum);

				tranceActive = true;
			}
			else if (SONG.player2 == 'hypno-two' || SONG.player2 == 'abomination-hypno' || tranceActive || ((playerLane == 0 || playerLane == 1) && SONG.song == "Pasta-Night"))
			{
				pendulumShadow = new FlxTypedGroup<FlxSprite>();

				pendulum.frames = Paths.getSparrowAtlas('UI/base/hypno/Pendelum_Phase2');
				pendulum.animation.addByPrefix('idle', 'Pendelum Phase 2', 24, true);
				pendulum.animation.play('idle');
				pendulum.antialiasing = true; // fuck you again
				pendulum.updateHitbox();
				pendulum.origin.set(65, 0);
				pendulum.cameras = [camHUD];
				pendulum.screenCenter(X);

				add(pendulumShadow);
				add(pendulum);

				if (tranceNotActiveYet) {
					pendulum.alpha = 0;
				}

				attachedText = new AttachedText(0, 0, 0, 'Angle: \n', 24, true);
				attachedText.cameras = [camHUD];
				attachedText.sprTracker = pendulum;
				// add(attachedText);
				tranceActive = true;
			}

			if (tranceActive)
			{
				tranceThing = new FlxSprite();
				tranceThing.frames = Paths.getSparrowAtlas('UI/base/hypno/StaticHypno');
				tranceThing.animation.addByPrefix('idle', 'StaticHypno', 24, true);
				tranceThing.animation.play('idle');
				tranceThing.cameras = [dialogueHUD];
				tranceThing.setGraphicSize(FlxG.width, FlxG.height);
				tranceThing.updateHitbox();
				add(tranceThing);
				tranceThing.alpha = 0;

				tranceDeathScreen = new FlxSprite();
				tranceDeathScreen.frames = Paths.getSparrowAtlas('UI/base/hypno/StaticHypno_highopacity');
				tranceDeathScreen.animation.addByPrefix('idle', 'StaticHypno', 24, true);
				tranceDeathScreen.animation.play('idle');
				tranceDeathScreen.cameras = [dialogueHUD];
				tranceDeathScreen.setGraphicSize(FlxG.width, FlxG.height);
				tranceDeathScreen.updateHitbox();
				add(tranceDeathScreen);
				tranceDeathScreen.alpha = 0;

				psyshockParticle = new FlxSprite();
				psyshockParticle.frames = Paths.getSparrowAtlas('characters/hypno/Psyshock');
				psyshockParticle.animation.addByPrefix('psyshock', 'Full Psyshock Particle', 24, false);
				psyshockParticle.animation.play('psyshock');
				psyshockParticle.updateHitbox();
				psyshockParticle.visible = false;
				add(psyshockParticle);
				psyshockParticle.scale.set(0.85, 0.85);
				psyshockParticle.animation.finishCallback = function(name:String)
					{
						psyshockParticle.visible = false;
						// trace('IT SHOULD DO THE THING FUCK YOU');
					};
					
				// pregen flash graphic
				flashGraphic = FlxG.bitmap.create(10, 10, FlxColor.fromString('0xFFFFAFC1'), true, 'flash-DoNotDelete');
				Paths.excludeAsset('flash-DoNotDelete');
				flashGraphic.persist = true;
				cameraFlash = new FlxSprite().loadGraphic(flashGraphic);
				cameraFlash.setGraphicSize(FlxG.width, FlxG.height);
				cameraFlash.updateHitbox();
				cameraFlash.cameras = [dialogueHUD];
				add(cameraFlash);
				cameraFlash.alpha = 0;

				// if (!ClientPrefs.photosensitive)
				// camHUD.flash(FlxColor.fromString('0xFFFFAFC1'), 0.1, null, true);

				FlxG.sound.play(Paths.sound('Psyshock'), 0);
				tranceSound = FlxG.sound.play(Paths.sound('TranceStatic'), 0, true);
			}

			if (fadePendulum)
				pendulumFade();
			if (accuracyMod)
			{
				accuracyThreshold = 90;
				if (gameplayMode == HELL_MODE)
					accuracyThreshold = 98;

				accuracyText = new FlxText();
				accuracyText.setFormat(Paths.font('vcr.ttf'), 18, FlxColor.WHITE);
				accuracyText.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
				accuracyText.cameras = [camHUD];
				accuracyText.antialiasing = true;

				iconFeraligatr = new HealthIcon('feraligatr', false);
				iconFeraligatr.cameras = [camHUD];
				// group.add(iconFeraligatr);
				accuracyText.color = FlxColor.WHITE;
				group.add(accuracyText);
				//
				accuracySound = new FlxSound().loadEmbedded(Paths.sound('feraligatrWakes'), false, false, die);
				FlxG.sound.list.add(accuracySound);
			}

			if (bronzongMechanic) {
				boyfriendStrums.keyAmount = 5;
				boyfriendStrums.xPos = placement - (!Init.trueSettings.get('Centered Notefield') ? midPoint : 0);
				boyfriendStrums.regenerateStrums();
			}

			if (useFrostbiteMechanic) // Freezing Mechanic
			{
				frostbiteBar = new FlxBar(1161 + 36 - 1134, 172 + 14, BOTTOM_TO_TOP, 16, 325, this, 'coldnessDisplay', 0, 1);
				frostbiteBar.createFilledBar(0xFF133551, 0xFFAAD6FF);
				add(frostbiteBar);
				frostbiteBar.cameras = [camHUD];

				frostbiteTheromometerTyphlosion = new FlxSprite(1164 - 1134, 119);
				frostbiteTheromometerTyphlosion.frames = Paths.getSparrowAtlas('UI/base/TyphlosionVit');
				frostbiteTheromometerTyphlosion.animation.addByPrefix('stage1', 'Typh1', 24, true);
				frostbiteTheromometerTyphlosion.animation.addByPrefix('stage2', 'Typh2', 24, true);
				frostbiteTheromometerTyphlosion.animation.addByPrefix('stage3', 'Typh3', 24, true);
				frostbiteTheromometerTyphlosion.animation.addByPrefix('stage4', 'Typh4', 24, true);
				frostbiteTheromometerTyphlosion.animation.addByPrefix('stage5', 'Typh5', 24, true);
				frostbiteTheromometerTyphlosion.animation.play('stage1');
				frostbiteTheromometerTyphlosion.updateHitbox();
				frostbiteTheromometerTyphlosion.antialiasing = true;
				add(frostbiteTheromometerTyphlosion);
				frostbiteTheromometerTyphlosion.cameras = [camHUD];

				frostbiteTheromometer = new FlxSprite(1161 - 1134, 172);
				frostbiteTheromometer.frames = Paths.getSparrowAtlas('UI/base/Thermometer');
				frostbiteTheromometer.animation.addByPrefix('stage1', 'Therm1', 24, true);
				frostbiteTheromometer.animation.addByPrefix('stage2', 'Therm2', 24, true);
				frostbiteTheromometer.animation.addByPrefix('stage3', 'Therm3', 24, true);
				frostbiteTheromometer.animation.play('stage1');
				frostbiteTheromometer.updateHitbox();
				frostbiteTheromometer.antialiasing = true;
				add(frostbiteTheromometer);
				frostbiteTheromometer.cameras = [camHUD];
			}
		} else {
			// pussy mode stuff
			tranceActive = false;
			bronzongMechanic = false;
			useFrostbiteMechanic = false;
			accuracyMod = false;
		}

		// create the game camera
		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(camPos.x, camPos.y);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		camFollowPos.setPosition(camPos.x, camPos.y);
		// check if the camera was following someone previously
		if (prevCamFollow != null) {
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		if (assetModifier == 'pixel')
			camGame.pixelPerfectRender = true;

		add(camFollow);
		add(camFollowPos);

		// actually set the camera up
		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		if (bronzongMechanic)
			{
				keysArray = [
					copyKey(Init.gameControls.get('LEFT')[0]),
					copyKey(Init.gameControls.get('DOWN')[0]),
					copyKey(Init.gameControls.get('UP')[0]),
					copyKey(Init.gameControls.get('RIGHT')[0]),
					copyKey(Init.gameControls.get('SPACE')[0])
				];
			}
		else
			{
				keysArray = [
					copyKey(Init.gameControls.get('LEFT')[0]),
					copyKey(Init.gameControls.get('DOWN')[0]),
					copyKey(Init.gameControls.get('UP')[0]),
					copyKey(Init.gameControls.get('RIGHT')[0])
				];
			}

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);

		moneySound = new FlxSound().loadEmbedded(Paths.sound('MoneyBagGet'), false, true);
		FlxG.sound.list.add(moneySound);

		GameOverSubstate.preload();
		Paths.clearUnusedMemory();

		if (!FlxG.save.data.playedSongs.contains(CoolUtil.spaceToDash(SONG.song.toLowerCase())))
			FlxG.save.data.playedSongs.push(CoolUtil.spaceToDash(SONG.song.toLowerCase()));

		// call the funny intro cutscene depending on the song
		songIntroCutscene();
	}


	public var minHealth:Float = 0;

	var groupIcons:Array<String> = ['mx', 'lord-x', 'hypno-cards'];
	function fpSong(dadNotes:Bool = false) {
		firstPerson = true;
		staticCamera = true;
		manualCameraPosition.set(dadOpponent.getMidpoint().x + 100 + dadOpponent.characterData.camOffsetX,
			dadOpponent.getMidpoint().y - 100 + dadOpponent.characterData.camOffsetY);
		boyfriend.visible = false;
		//
		if (!dadNotes)
			dadStrums.visible = false;
	}

	var barFlipped:Bool = false;
	function flipHealthbar() {
		var healthBar = uiHUD.healthBar;
		var colorData:Array<Int> = PlayState.boyfriend.characterData.healthbarColors;
		var bfColor = FlxColor.fromRGB(colorData[0], colorData[1], colorData[2]);
		var colorData:Array<Int> = PlayState.dadOpponent.characterData.healthbarColors;
		var dadColor = FlxColor.fromRGB(colorData[0], colorData[1], colorData[2]);
		//
		healthBar.createFilledBar(bfColor, dadColor);
		barFlipped = !barFlipped;
		iconP1.changeIcon(iconP1.char, !iconP1.isPlayer);
		iconP2.changeIcon(iconP2.char, !iconP2.isPlayer);
		if (iconBfhypno != null) {
			iconBfhypno.changeIcon(iconBfhypno.char, !iconBfhypno.isPlayer);
		}		
	}

	var buriedIntroInterval:Int = 0;
	var alternateBrimstone:Int = -1;
	public function brimstoneIntro() {
		brimstoneShaking = true;
		if (buriedIntroInterval == 2) {
			dadOpponent.playAnim('scream');
			dadOpponent.animation.finishCallback = function(name:String) {
				dadOpponent.dance();
			}; 
		}
		if (buriedIntroInterval < 4)
			myShake = shakeProgress;
		else 
			myShake = shakeProgressFinal;
		buriedIntroInterval++;
	}

	function pendulumFade() {
		pendulum.alpha = 0;
		tranceActive = false;
	}



	var brimstoneShaking:Bool = false;
	var shakeProgression:Int = 0;

	var shakeProgress:Array<Int> = [-13, 26, -16, 4, -1];
	var shakeProgressFinal:Array<Int> = [-28,52,-38,28,-21,12,-10,5,-1];

	var cameraXPlacement:Float = 0;
	var totalShakes:Int = 0;
	var curFrame:Int = 0;

	var brimstoneShakeX:Float = 0;

	var myShake:Array<Int>;
	function brimstoneShakes() {
		if (curFrame % Math.floor(12 * (FlxG.drawFramerate / 120)) == 0 && brimstoneShaking) {
			if (shakeProgression == 0) {
				cameraXPlacement = FlxG.camera.scroll.x;
				FlxG.camera.follow(null);
			}
			FlxG.camera.scroll.x += myShake[shakeProgression] * 3;
			shakeProgression++;
			if (shakeProgression >= myShake.length - 1) {
				totalShakes++;
				shakeProgression = 0;
				FlxG.camera.scroll.x = cameraXPlacement;
				FlxG.camera.follow(camFollowPos, LOCKON, 1);
				brimstoneShaking = false;
			}
			//
		}
	}

	// Test

	var deadstone:Bool = false;
	function gameoverBrimstoneShake()
	{
		if (curFrame % Math.floor(12 * (FlxG.drawFramerate / 120)) == 0)
		{
			if (shakeProgression <= shakeProgressFinal.length - 1) {
				if (shakeProgression == 0)
					cameraXPlacement = FlxG.camera.scroll.x;
				FlxG.camera.scroll.x += shakeProgressFinal[shakeProgression] * 3;
				shakeProgression++;
				if (shakeProgression >= shakeProgressFinal.length - 1)
				{
					// shakeProgression = 0;
					FlxG.camera.scroll.x = cameraXPlacement;
					FlxG.camera.follow(camFollowPos, LOCKON, 1);
					// deadstone = false;
				}
			}
			//
		}

		if (curFrame % Math.floor(4 * (FlxG.drawFramerate / 120)) == 0)
			boyfriend.y += 12;
	}

	var startingBrimstone:Bool = false;
	var bfStartPosition:Float = 0;
	function startBrimstone() {
		startingBrimstone = true;
		bfStartPosition = boyfriend.x;
		boyfriend.x += FlxG.width * 2;

		stripGroup = new FlxTypedGroup<FlxSprite>();
		var divisions = 18;
		for (i in 0...divisions) {
			var newStrip:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, Std.int(FlxG.height / divisions), FlxColor.BLACK);
			newStrip.y += (FlxG.height/divisions) * i;
			stripGroup.add(newStrip);
			stripGroup.cameras = [dialogueHUD];
		}
		add(stripGroup);
	}
	var stripGroup:FlxTypedGroup<FlxSprite>;
	function updateBrimstoneIntro() {
		if (curStep > 1) {
			if (curFrame % Math.floor(4 * (FlxG.drawFramerate / 60)) == 0)
			{
				if (curStep <= 48)
				{
					for (i in 0...stripGroup.members.length)
					{
						var alternate:Int = i % 2 == 0 ? 1 : -1;
						stripGroup.members[i].x += alternate * 64;
					}
				} else 
					remove(stripGroup);
			}
			//
			if (curFrame % Math.floor(2 * (FlxG.drawFramerate / 60)) == 0) {
				if (curStep >= 24)
				{
					if (boyfriend.x > bfStartPosition)
						boyfriend.x -= 50;
					
					if (boyfriend.x <= bfStartPosition)
					{
						boyfriend.x = bfStartPosition;
						startingBrimstone = false;
					}
				}
			}
			//
		}
	}

	public function startUnown(timer:Int = 15, word:String = ''):Void
	{
		if (gameplayMode != PUSSY_MODE) {
			canPause = false;
			unowning = true;
			persistentUpdate = true;
			persistentDraw = true;
			var realTimer = timer;
			var unownState = new UnownSubstate(realTimer, word);
			unownState.win = wonUnown;
			unownState.lose = die;
			unownState.cameras = [dialogueHUD];
			// FlxG.autoPause = false;
			openSubState(unownState);
		}
	}

	public function wonUnown():Void {
		canPause = true;
		unowning = false;
	}

	public var backgroundGroup:FlxTypedGroup<FlxSprite>;
	public var enableMovement:Bool = true;
	
	public var newgfcam:Bool = false;
	public var gfStand:Boyfriend;

	public var vignette:ShaderFilter;

	var brimstoneDesaturate:Bool = false;
	@:isVar
	public var desaturateAmplitude(default, set):Float = 0;
	function set_desaturateAmplitude(value:Float):Float {
		desaturateAmplitude = value;
		stageBuild.forEach(function(sprite:FlxSprite) {
			sprite.shader.data.amplitude.value = [desaturateAmplitude];
		});
		return value;
	}
	@:isVar
	
	public var desaturateAmount(default, set):Float = 1;
	function set_desaturateAmount(value:Float):Float
	{
		desaturateAmount = value;
		stageBuild.forEach(function(sprite:FlxSprite) {
			sprite.shader.data.desaturationAmount.value = [desaturateAmount];
		});
		return value;
	}
	var brimstoneDistortionTime:Float = 0;

	public function psyshock(?real:Bool = true) {
		psyshockParticle.setPosition(dadOpponent.x + 825, dadOpponent.y - 75);

		if (dadOpponent.curCharacter == 'hypno-two')
			{
				psyshockParticle.setPosition(dadOpponent.x + 625, dadOpponent.y + 200);
			}

		if (dadOpponent.curCharacter == 'abomination-hypno')
			{
				psyshockParticle.setPosition(dadOpponent.x - 100, dadOpponent.y + 200);
				psyshockParticle.flipX = true;
			}

		psyshockParticle.animation.play('psyshock');
		psyshockParticle.visible = true;
		psyshockParticle.animation.finishCallback = function(name:String)
			{
				psyshockParticle.visible = false;
			};

		FlxG.sound.play(Paths.sound('Psyshock'), 0.6);
		if (flashingEnabled) flash();

		if (real)
			trance += 0.25;
		else {
			tranceDeathScreen.alpha += 0.1;
			tranceCanKill = false;
		}
	}

	var flashTween:FlxTween;
	function flash() {
		cameraFlash.alpha = 1;
		flashTween = FlxTween.tween(cameraFlash, {alpha: 0}, 1);
	}


	public var shaderCatalog:Array<BitmapFilter> = [];

	// brimstone stuff
	public var brimstoneInterpolation:Float = 0;
	public var brimstoneDisplacement:Float = 0;
	public var brimstoneSineDisplacement:Float = 0;

	var glitchSet:Bool = false;
	var missingnoIndex:Int = 0;
	public function setupGlitchShader() {
		if (!glitchSet) {
			// /*
			missingnoGlitch = new GraphicsShader("", Paths.shader('glitch'));
			shaderCatalog.push(new ShaderFilter(missingnoGlitch));
			missingnoIndex = shaderCatalog.length - 1;
			camGame.setFilters(shaderCatalog);
			// */
			glitchSet = true;
		}
	}

	var frostSet:Bool = false;
	var frostbiteShader:ShaderFilter;
	var frostingShader:ShaderFilter;

	public function setupFrostbite()
	{
		if (!frostSet)
		{
			frostbiteShader = new ShaderFilter(new GraphicsShader("", Paths.shader('snowfall')));
			vignetteCam.setFilters([frostbiteShader]);
			frostSet = true;
		}
	}

	public var snowIntensityTween:FlxTween;
	public var canChangeIntensity:Bool = true;
	@:isVar
	public var snowIntensity(default, set):Float = 0;

	function set_snowIntensity(value:Float):Float
	{
		if (canChangeIntensity) {
			snowIntensity = value;
			trace(value);
			frostbiteShader.shader.data.intensity.value = [snowIntensity];
		}
		return snowIntensity;
	}

	public var snowAmountTween:FlxTween;
	public var canChangeAmount:Bool = true;
	@:isVar
	public var snowAmount(default, set):Float = 0;

	function set_snowAmount(value:Float):Float
	{
		if (canChangeAmount)
		{
			snowAmount = value;
			trace(value);
			frostbiteShader.shader.data.amount.value = [Std.int(snowAmount)];
		}
		return snowAmount;
	}

	var brimstoneSet:Bool = false;
	var brimstoneIndex:Int = 0;
	public var canRise:Bool = true;
	public var riserTween:FlxTween;
	@:isVar
	public var brimstoneDistortion(default, set):Float = 0;
	function set_brimstoneDistortion(value:Float):Float {
		if (canRise) {
			brimstoneDistortion = value;
			brimstoneShader.data.distort.value = [value];
		}
		return brimstoneDistortion;
	}

	public function setupBrimstoneShaders()
	{
		if (!brimstoneSet) {
			// /*
			brimstoneShader = new GraphicsShader("", Paths.shader('camEffects'));
			shaderCatalog.push(new ShaderFilter(brimstoneShader));
			brimstoneIndex = shaderCatalog.length - 1;
			camGame.setFilters(shaderCatalog);
			// */
			brimstoneSet = true;
		}
	}

	public var cameraValueMissingno(default, set):Float = defaultCamZoom;
	public var missingnoZoomIn:Bool = false;
	public var missingnoZoomIntensity(default, set):Float = 0;
	function set_missingnoZoomIntensity(newValue:Float){
		missingnoZoomIntensity = newValue;
		if (missingnoZoomIn) {
			if (shaderCatalog.length > 0) {
				var newShader:ShaderFilter = cast(shaderCatalog[0], ShaderFilter);
				newShader.shader.data.intensityChromatic.value = [missingnoZoomIntensity];
			}
		}
		return newValue;
	}
	
	function set_cameraValueMissingno(newValue:Float) {
		cameraValueMissingno = newValue;
		if (missingnoZoomIn) 
			FlxG.camera.zoom = cameraValueMissingno;
		return newValue;
	}


	public function flipCharacters() {
		// starting positions
		var startingPosBf:Float = boyfriend.x;
		var startingPosDad:Float = dadOpponent.x;

		boyfriend.x = startingPosDad;

		boyfriend.flipLeftRight();
		dadOpponent.flipLeftRight();

		if (boyfriend.atlasCharacter != null)
			boyfriend.atlasCharacter.setPosition(boyfriend.x, boyfriend.y);
		dadOpponent.x = startingPosBf;
		if (dadOpponent.atlasCharacter != null)
			dadOpponent.atlasCharacter.setPosition(dadOpponent.x, dadOpponent.y);
		
		flipStrums();
		if (!buriedNotes)
			flipHealthbar();
	}

	var isFlipped:Bool = false;
	var midPoint:Float = (FlxG.width / 4);
	var placement = (FlxG.width / 2);
	public function flipStrums()
	{
		var newX:Float = -midPoint;
		if (isFlipped)
			newX = -newX;

		if (!Init.trueSettings.get('Centered Notefield'))
		{
			for (i in 0...boyfriendStrums.receptors.members.length) {
				boyfriendStrums.receptors.members[i].x = placement + newX;
				boyfriendStrums.receptors.members[i].x -= ((boyfriendStrums.keyAmount / 2) * boyfriendStrums.noteWidth);
				boyfriendStrums.receptors.members[i].x += (boyfriendStrums.noteWidth * i);
			}

			for (i in 0...dadStrums.receptors.members.length) {
				dadStrums.receptors.members[i].x = placement - (newX + dadStrums.noteWidth / 2);
				dadStrums.receptors.members[i].x -= ((dadStrums.keyAmount / 2) * dadStrums.noteWidth);
				dadStrums.receptors.members[i].x += (dadStrums.noteWidth * i);
			}
			isFlipped = !isFlipped;
		}
	}

	public var disableCountdown = true;

	public var jumpscareSizeInterval:Float;
	public var jumpScare:FlxSprite;
	function generateJumpscare(jumpscareName:String) {
		jumpscareSizeInterval = 1.625;

		jumpScare = new FlxSprite().loadGraphic(Paths.image('jumpscares/$jumpscareName'));
		jumpScare.setGraphicSize(Std.int(FlxG.width * jumpscareSizeInterval), Std.int(FlxG.height * jumpscareSizeInterval));
		jumpScare.updateHitbox();
		jumpScare.screenCenter();
		add(jumpScare);

		jumpScare.setGraphicSize(Std.int(FlxG.width * jumpscareSizeInterval), Std.int(FlxG.height * jumpscareSizeInterval));
		jumpScare.updateHitbox();
		jumpScare.screenCenter();

		jumpScare.visible = false;
		jumpScare.cameras = [dialogueHUD];
	}

	public static function copyKey(arrayToCopy:Array<FlxKey>):Array<FlxKey>
	{
		var copiedArray:Array<FlxKey> = arrayToCopy.copy();
		var i:Int = 0;
		var len:Int = copiedArray.length;

		while (i < len)
		{
			if (copiedArray[i] == NONE)
			{
				copiedArray.remove(NONE);
				--i;
			}
			i++;
			len = copiedArray.length;
		}
		return copiedArray;
	}
	
	var keysArray:Array<Dynamic>;

	public function onKeyPress(event:KeyboardEvent):Void {
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);

		if ((key >= 0)
			&& !strumLines.members[playerLane].autoplay
			&& (FlxG.keys.checkStatus(eventKey, JUST_PRESSED))
			&& (FlxG.keys.enabled && !paused && (FlxG.state.active || FlxG.state.persistentUpdate)))
		{
			if (generatedMusic && !inCutscene)
			{
				var previousTime:Float = Conductor.songPosition;
				Conductor.songPosition = songMusic.time;
				// improved this a little bit, maybe its a lil
				var possibleNoteList:Array<Note> = [];
				var pressedNotes:Array<Note> = [];

				strumLines.members[playerLane].allNotes.forEachAlive(function(daNote:Note)
				{
					if ((daNote.noteData == key) && daNote.canBeHit && !daNote.isSustainNote && !daNote.tooLate && !daNote.wasGoodHit)
						possibleNoteList.push(daNote);
				});
				possibleNoteList.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

				// if there is a list of notes that exists for that control
				if (possibleNoteList.length > 0)
				{
					var eligable = true;
					var firstNote = true;
					// loop through the possible notes
					for (coolNote in possibleNoteList)
					{
						for (noteDouble in pressedNotes)
						{
							if (Math.abs(noteDouble.strumTime - coolNote.strumTime) < 10)
								firstNote = false;
							else
								eligable = false;
						}

						if (eligable) {
							goodNoteHit(coolNote, strumLines.members[playerLane].singingCharacters, strumLines.members[playerLane], firstNote); // then hit the note
							pressedNotes.push(coolNote);
						}
						// end of this little check
					}
					//
				}
				else // else just call bad notes
					if (!Init.trueSettings.get('Ghost Tapping'))
						missNoteCheck(true, key, strumLines.members[playerLane].singingCharacters, true);
				Conductor.songPosition = previousTime;
			}

			if (strumLines.members[playerLane].receptors.members[key] != null 
				&& strumLines.members[playerLane].receptors.members[key].animation.curAnim.name != 'confirm')
				strumLines.members[playerLane].receptors.members[key].playAnim('pressed');
		}
	}

	public function onKeyRelease(event:KeyboardEvent):Void {
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);

		if (FlxG.keys.enabled && !paused && (FlxG.state.active || FlxG.state.persistentUpdate)) {
			// receptor reset
			if (key >= 0 && strumLines.members[playerLane].receptors.members[key] != null) {
				strumLines.members[playerLane].receptors.members[key].playAnim('static');
				if (key == 4) {
					for (i in strumLines.members[playerLane].singingCharacters)
						i.isPressing = false;
				}
			}
		}
	}

	private function getKeyFromEvent(key:FlxKey):Int {
		if (key != NONE)
		{
			for (i in 0...keysArray.length)
			{
				for (j in 0...keysArray[i].length)
				{
					if (key == keysArray[i][j])
						return i;
				}
			}
		}
		return -1;
	}

	override public function destroy() {
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);

		super.destroy();
	}

	var staticDisplace:Int = 0;

	var lastSection:Int = 0;
	var dadY:Float;

	var usedTimeTravel:Bool = false;
	var canDie:Bool = true;

	var attachedText:AttachedText;
	var maxPendulumAngle:Float = 0;
	var alreadyHit:Bool = false;
	var canHitPendulum:Bool = false;
	var tranceInterval:Int = 0;
	var beatInterval:Float = 2; // every how many beats the pendulum must be hit 

	var manualCameraPosition:FlxPoint;
	var accuracyColor:FlxColor = new FlxColor();
	
	public var soundVolume:Float = 1;
	var powBlock:Bool = false;

	var botplayAlpha:Float = 0;
	var characterZoom:Float = 0;

	static var accuracyThreshold:Float = 90;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		
		stageBuild.stageUpdateConstant(elapsed);

		for (i in updateableScript) {
			if (i.alive && i.exists('onUpdate')) {
				i.get('onUpdate')(elapsed);
			} else
				updateableScript.splice(updateableScript.indexOf(i), 1);
		}
		
		// update accuracy mod
		if (accuracyMod) {
			accuracyText.alpha = uiHUD.alpha * 2;
			accuracyText.setPosition(uiHUD.accuracyBar.x, uiHUD.accuracyBar.y);
			iconFeraligatr.setPosition(uiHUD.accuracyBar.x - iconFeraligatr.width - iconFeraligatr.width, uiHUD.accuracyBar.y + uiHUD.accuracyBar.height / 2 - iconFeraligatr.height / 2);
			
			var determine:Float = 0;
			if (Timings.notesHit > 0) {
				determine = ((Timings.getAccuracy() - accuracyThreshold) / 100);
				determine *= (1 / ((100 - accuracyThreshold) / 100));
				//
				accuracyColor.setRGB(Std.int(Math.max(255 - (determine * 255), 0)), Std.int(Math.min(determine * 255, 255)), 0);
				accuracyText.color = accuracyColor;

				// logical side
				if (Timings.getAccuracy() < accuracyThreshold) {
					if (!accuracyBelow) {
						accuracyBelow = true;
						new FlxTimer().start(0.5, function(tmr:FlxTimer){
							if (accuracyBelow) {
								accuracySound.play();
								accuracySound.volume = 1;
								accuracyCameraMove = true;
							}
						});
					}
					if (accuracyCameraMove) {
						forceZoom[0] = FlxMath.lerp(forceZoom[0], ((accuracySound.time / accuracySound.length) / 1.5), elapsed * 2.4);
						soundVolume = FlxMath.lerp(soundVolume, 0.4, elapsed / (1 / 60));
						iconFeraligatr.animation.curAnim.curFrame = 1;
					}
				} else {
					iconFeraligatr.animation.curAnim.curFrame = 0;
					if (accuracyBelow) {
						forceZoom[0] = 0;
						accuracySound.pause();
						accuracySound.time = 0;
						accuracyBelow = false;
						accuracyCameraMove = false;
					} else
						soundVolume = FlxMath.lerp(soundVolume, 1, elapsed / (1 / 60));
				}
			}
			// im too lazy
			@:privateAccess
			accuracyText.text = '${ClassHUD.divider}Accuracy: '
				+ Std.string(Math.floor(Timings.getAccuracy() * 100) / 100)
				+ '%'
				+ Timings.comboDisplay
				+ ClassHUD.divider;
		}

		uiHUD.scoreBar.alpha = uiHUD.alpha;
		uiHUD.accuracyBar.alpha = uiHUD.alpha;

		botplayAlpha = FlxMath.lerp(botplayAlpha, strumLines.members[playerLane].autoplay ? 1 : 0, elapsed / (1 / 60));
		botplaySine += 180 * (elapsed / 4);
		botplayText.alpha = botplayAlpha - Math.abs(Math.sin((Math.PI * botplaySine) / 180));
		if (botplaySubtext != null)
			botplaySubtext.alpha = botplayText.alpha;

		if (health > 2)
			health = 2;

		if (!buriedNotes && SONG.song.toLowerCase() != 'pasta-night')
		{
			// pain, this is like the 7th attempt
			var healthBar = uiHUD.healthBar;
			healthBar.percent = (health * 50);
			if (barFlipped)
				healthBar.percent = ((2 - health) * 50);

			var iconLerp = 0.5;
			iconP1.setGraphicSize(Std.int(FlxMath.lerp(iconP1.initialWidth, iconP1.width, iconLerp)));
			iconP2.setGraphicSize(Std.int(FlxMath.lerp(iconP2.initialWidth, iconP2.width, iconLerp)));
			if (iconBfhypno != null) {
				iconBfhypno.setGraphicSize(Std.int(FlxMath.lerp(iconBfhypno.initialWidth, iconBfhypno.width, iconLerp)));
				iconBfhypno.updateHitbox();
			}

			iconP1.updateHitbox();
			iconP2.updateHitbox();			

			var iconOffset:Int = 26;
			iconP1.x = healthBar.x
				+ (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01))
				- ((barFlipped ? iconP1.width - iconOffset : iconOffset))
				- iconP1.offsetX;
			iconP2.x = healthBar.x
				+ (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01))
				- ((barFlipped ? iconOffset : iconP2.width - iconOffset))
				- iconP2.offsetX;
			if (iconBfhypno != null) {
					iconBfhypno.x = healthBar.x
					+ (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01))
					- ((barFlipped ? iconOffset : iconBfhypno.width - iconOffset + 8))
					- iconBfhypno.offsetX;
				}				

			healthBar.percent = (health * 50);
			if (!iconP1.animatedIcon)
			{
				if (healthBar.percent < 20)
					iconP1.animation.curAnim.curFrame = 1;
				else
					iconP1.animation.curAnim.curFrame = 0;
			}

			// /*
			if (!iconP2.animatedIcon) {
				if (iconP2.char == 'wigglytuff') {
					iconP2.animation.curAnim.curFrame = PlayState.dadOpponent.wigglyState;
				} else {
					if (healthBar.percent > 80)
						iconP2.animation.curAnim.curFrame = 1;
					else
						iconP2.animation.curAnim.curFrame = 0;
				}
			}
			if (barFlipped)
				healthBar.percent = ((2 - health) * 50);
			// */
		}
		else if (SONG.song.toLowerCase() == 'pasta-night') {
			var healthBar = uiHUD.healthBar;
			healthBar.percent = (health * 50);
			for (i in 0...uiHUD.iconGroup.members.length) {
				var iconLerp = 0.5;
				uiHUD.iconGroup.members[i].setGraphicSize(Std.int(FlxMath.lerp(uiHUD.iconGroup.members[i].initialWidth, uiHUD.iconGroup.members[i].width, iconLerp)));
				uiHUD.iconGroup.members[i].updateHitbox();
				var iconOffset:Int = 4;
				if (uiHUD.iconGroup.members[i].char == groupIcons[playerLane]) {
					uiHUD.iconGroup.members[i].x = healthBar.x
						+ (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset)
						- uiHUD.iconGroup.members[i].offsetX;
					if (!uiHUD.iconGroup.members[i].animatedIcon){
						if (healthBar.percent < 20)
							uiHUD.iconGroup.members[i].animation.curAnim.curFrame = 1;
						else
							uiHUD.iconGroup.members[i].animation.curAnim.curFrame = 0;
					}
				} else {
					uiHUD.iconGroup.members[i].x = healthBar.x
						+ (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01))
						- (uiHUD.iconGroup.members[i].width - iconOffset)
						- uiHUD.iconGroup.members[i].offsetX;
					if (!uiHUD.iconGroup.members[i].animatedIcon){
						if (healthBar.percent > 80)
							uiHUD.iconGroup.members[i].animation.curAnim.curFrame = 1;
						else
							uiHUD.iconGroup.members[i].animation.curAnim.curFrame = 0;
					}
				}
			}
		}		

		if (buriedNotes) {
			healthBarBF.width = ((52 * 3) * (health / 2));
		}

		// dialogue checks
		if (dialogueBox != null && dialogueBox.alive) {
			// wheee the shift closes the dialogue
			if (FlxG.keys.justPressed.SHIFT)
				dialogueBox.closeDialog();

			// the change I made was just so that it would only take accept inputs
			if (controls.ACCEPT && dialogueBox.textStarted) {
				FlxG.sound.play(Paths.sound('cancelMenu'));
				dialogueBox.curPage += 1;
				if (dialogueBox.curPage == dialogueBox.dialogueData.dialogue.length)
					dialogueBox.closeDialog()
				else
					dialogueBox.updateDialog();
			}
		}
		
		if (!inCutscene && generatedMusic) {
			// pause the game if the game is allowed to pause and enter is pressed
			if (FlxG.keys.justPressed.ENTER && startedCountdown && (accuracySound == null || (accuracySound != null && !accuracySound.playing)) && canPause && !deadstone)
			{
				// update drawing stuffs
				paused = true;
				persistentUpdate = false;
				persistentDraw = true;

				if (tranceSound != null) tranceSound.pause();

				// open pause substate
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				updateRPC(true);
			}

			// make sure you're not cheating lol
			if (!isStoryMode || Main.hypnoDebug) {
				if ((FlxG.keys.justPressed.SEVEN) && (!startingSong))
				{
					resetMusic();
					Main.switchState(this, new OriginalChartingState());
				}

				if (Main.hypnoDebug && (FlxG.keys.justPressed.EIGHT) && (!startingSong))
				{
					resetMusic();
					Main.switchState(this, new CharacterOffsetState());
				}

				if ((FlxG.keys.justPressed.SIX))
					strumLines.members[playerLane].autoplay = !strumLines.members[playerLane].autoplay;
			}

			if (dadOpponent != null)
			{
				if (!Math.isNaN(dadY) && dadOpponent.curCharacter == 'missingno' || dadOpponent.curCharacter == 'minecrftno')
					dadOpponent.y = dadY + ((Math.sin((Conductor.songPosition / 16000) * (180 / Math.PI))) * 5);
				else
					dadY = dadOpponent.y;
			}

			///*
			if (!canSpeak)
				vocals.volume = 0;
			else
				vocals.volume = soundVolume;
			songMusic.volume = soundVolume;
			
			if (!deadstone) {
				if (startingSong)
				{
					if (startedCountdown)
					{
						Conductor.songPosition += elapsed * 1000;
						if (Conductor.songPosition >= 0)
							startSong();
					}
				}
				else
				{
					// Conductor.songPosition = FlxG.sound.music.time;
					Conductor.songPosition += elapsed * 1000;

					if (!paused)
					{
						songTime += FlxG.game.ticks - previousFrameTime;
						previousFrameTime = FlxG.game.ticks;

						// Interpolation type beat
						if (Conductor.lastSongPos != Conductor.songPosition)
						{
							songTime = (songTime + Conductor.songPosition) / 2;
							Conductor.lastSongPos = Conductor.songPosition;
							// Conductor.songPosition += FlxG.elapsed * 1000;
							// trace('MISSED FRAME');
						}
					}

					// penduluuum
					if (pendulum != null && tranceActive) {
						var convertedTime:Float = ((Conductor.songPosition / (Conductor.crochet * beatInterval)) * Math.PI);
						pendulum.angle = (Math.sin(convertedTime) * 32) + pendulumOffset;
						// pendulum.screenCenter();
						// /*
						var pendulumTimeframe = Math.floor(((convertedTime / Math.PI) - Math.floor(convertedTime / Math.PI)) * 1000) / 1000;
						var reach:Float = 0.2;
						if (!tranceNotActiveYet) {
							if (pendulumTimeframe < reach || pendulumTimeframe > (1 - reach)) {
								if (!alreadyHit)
									canHitPendulum = true;
							} 
							else
							{
								alreadyHit = false;
								if (canHitPendulum) {
									if (tranceInterval % 2 == 0)
										losePendulum(true);
									tranceInterval++;
									canHitPendulum = false;
								}
							}
						

							// /*
							if (controls.SPACE_P || (strumLines.members[playerLane].autoplay && canHitPendulum && !alreadyHit))
							{
								if (canHitPendulum)
								{
									canHitPendulum = false;
									alreadyHit = true;
									winPendulum();
								}
								else
									losePendulum(true);
							}
						}
						// fuck you let me fix this with delta
						trance -= (((Conductor.bpm / 200) / 1000) * (elapsed / (1 / 90)));
						// 200 is based on left unchecked bpm & health "restore" decreases based on the bpm 
						// of the song so its not as easy on lower bpm songs

						tranceThing.alpha = trance / 2;
						if (trance > 1)
							tranceSound.volume = (trance - 1) / 2;
						else
							tranceSound.volume = 0;

						if (trance > 2) {
							trance = 2;
							if (tranceCanKill)
								die();
						}
						if (trance < -0.25)
							trance = -0.25;

						if (trance >= 0.8) {
							if (trance >= 1.6)
								boyfriend.idleSuffix = '-alt2';
							else
								boyfriend.idleSuffix = '-alt';
						}
						else
							boyfriend.idleSuffix = '';
					}	
				}

				if ((useFrostbiteMechanic && typhlosionUses >= 1 && typhlosion.animation.curAnim.name != 'fire' && gameplayMode != PUSSY_MODE) && (strumLines.members[playerLane].autoplay && coldness >= 0.5 || (controls.SPACE_P && !strumLines.members[playerLane].autoplay)))
					{
						useTyphlosion();
					}

				coldnessDisplay = FlxMath.lerp(coldnessDisplay, coldness, (elapsed / (1 / 120)) * 0.03);
			}
			// boyfriend.playAnim('singLEFT', true);
			// */
			var char = boyfriend;
			if (!deadstone && generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null) {
				if (!staticCamera)
				{
					var curSection = Std.int(curStep / 16);
					if (curSection != lastSection)
					{
						// section reset stuff
						var lastMustHit:Bool = PlayState.SONG.notes[lastSection].mustHitSection;
						if (PlayState.SONG.notes[curSection].mustHitSection != lastMustHit)
						{
							camDisplaceX = 0;
							camDisplaceY = 0;
						}
						lastSection = Std.int(curStep / 16);
					}

					if (!cameraCentered)
					{
						if (!PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
						{
							var char = dadOpponent;
							characterZoom = FlxMath.lerp(characterZoom, char.characterData.zoomOffset, elapsed * 2);

							var getCenterX = char.getMidpoint().x + 100;
							var getCenterY = char.getMidpoint().y - 100;

							camFollow.setPosition(getCenterX + camDisplaceX + char.characterData.camOffsetX,
								getCenterY + camDisplaceY + char.characterData.camOffsetY);
						}
						else
						{
							if (newgfcam) {
								char = gfStand;
								characterZoom = 0;
							}
							else 
								characterZoom = FlxMath.lerp(characterZoom, char.characterData.zoomOffset, elapsed * 2);

							var getCenterX = char.getMidpoint().x - 100;
							var getCenterY = char.getMidpoint().y - 100;

							camFollow.setPosition(getCenterX + camDisplaceX - char.characterData.camOffsetX,
								getCenterY + camDisplaceY + char.characterData.camOffsetY);							
						}
					}
					else
					{
						var positionArray = getPositionArrayCenter();
						camFollow.setPosition(positionArray[0] + camDisplaceX, positionArray[1] + camDisplaceY);
					}
					
				}
			}
			
			if (SONG.song.toLowerCase() == 'brimstone')	{
				if (brimstoneShaking)
					brimstoneShakes();
				if (startingBrimstone)
					updateBrimstoneIntro();
				if (deadstone)
					gameoverBrimstoneShake();

				if (vignette != null)
					vignette.shader.data.time.value = [Conductor.songPosition / (Conductor.stepCrochet * 8)];

				curFrame++;
			}

			if (brimstoneDesaturate) {
				brimstoneDistortionTime -= ((elapsed / (1 / 60)) * 0.0125) / 2;
				stageBuild.forEach(function(sprite:FlxSprite) {
					sprite.shader.data.distortionTime.value = [brimstoneDistortionTime];
				});
			}

			if (frostSet) 
				frostbiteShader.shader.data.time.value = [Conductor.songPosition / (Conductor.stepCrochet * 8)];
			
			var lerpVal = (elapsed * 2.4) * cameraSpeed;
			if (!brimstoneShaking) 
				camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

			var easeLerp = 1 - (elapsed * 3.125);
			// camera stuffs
			if (camZooming) {
				FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom + forceZoom[0] + characterZoom, FlxG.camera.zoom, easeLerp);
				for (hud in allUIs)
					hud.zoom = FlxMath.lerp(1 + forceZoom[1], hud.zoom, easeLerp);
			}

			// not even forcezoom anymore but still
			FlxG.camera.angle = FlxMath.lerp(0 + forceZoom[2], FlxG.camera.angle, easeLerp);
			for (hud in allUIs)
				hud.angle = FlxMath.lerp(0 + forceZoom[3], hud.angle, easeLerp);

			if (health < minHealth)
				health = minHealth;
			if (health <= minHealth && startedCountdown)
				die();

			/*if (Main.hypnoDebug)
				{
					if (FlxG.keys.justPressed.ONE) 
						{
							songMusic.volume = 0;
							vocals.volume = 0;
							doMoneyBag();
						}
			
					if (FlxG.keys.justPressed.TWO) {
						if (!usedTimeTravel && Conductor.songPosition + 10000 < songMusic.length)
						{
							usedTimeTravel = true;
							songMusic.pause();
							vocals.pause();
							Conductor.songPosition += 10000;
		
							canDie = false;
		
							songMusic.time = Conductor.songPosition;
							songMusic.play();
							vocals.time = Conductor.songPosition;
							vocals.play();
							new FlxTimer().start(0.5, function(tmr:FlxTimer)
							{
								usedTimeTravel = false;
							});
						}
					}
				}*/

			// copy paste im lazy
			var pendulumOffset:Array<Int> = [];
			if (dadOpponent.curCharacter == 'hypno')
			{
				switch (dadOpponent.animation.name)
				{
					case 'idle':
						switch (dadOpponent.animation.curAnim.curFrame)
						{
							case 0 | 1:
								pendulumOffset[0] = 814;
								pendulumOffset[1] = 264;
							case 2 | 3:
								pendulumOffset[0] = 813;
								pendulumOffset[1] = 270;
							case 4:
								pendulumOffset[0] = 813;
								pendulumOffset[1] = 266;
							case 5:
								pendulumOffset[0] = 813;
								pendulumOffset[1] = 263;
							case 6:
								pendulumOffset[0] = 814;
								pendulumOffset[1] = 255;
							case 7:
								pendulumOffset[0] = 811;
								pendulumOffset[1] = 251;
							case 8 | 9:
								pendulumOffset[0] = 809;
								pendulumOffset[1] = 249;
							case 10 | 11 | 12 | 13 | 14:
								pendulumOffset[0] = 808;
								pendulumOffset[1] = 248;
						}
					case 'singLEFT':
						switch (dadOpponent.animation.curAnim.curFrame)
						{
							case 0:
								pendulumOffset[0] = 775;
								pendulumOffset[1] = 336;
							case 1:
								pendulumOffset[0] = 790;
								pendulumOffset[1] = 351;
							case 2:
								pendulumOffset[0] = 826;
								pendulumOffset[1] = 366;
							case 3 | 4:
								pendulumOffset[0] = 830;
								pendulumOffset[1] = 378;
							case 5 | 6:
								pendulumOffset[0] = 831;
								pendulumOffset[1] = 393;
							case 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 | 16 | 17:
								pendulumOffset[0] = 832;
								pendulumOffset[1] = 396;
						}
					case 'singRIGHT':
						switch (dadOpponent.animation.curAnim.curFrame)
						{
							case 0 | 1 | 2:
								pendulumOffset[0] = 866;
								pendulumOffset[1] = 609;
							case 3:
								pendulumOffset[0] = 858;
								pendulumOffset[1] = 612;
							case 4:
								pendulumOffset[0] = 881;
								pendulumOffset[1] = 610;
							case 5:
								pendulumOffset[0] = 901;
								pendulumOffset[1] = 597;
							case 6:
								pendulumOffset[0] = 903;
								pendulumOffset[1] = 590;
							case 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 | 16 | 17:
								pendulumOffset[0] = 908;
								pendulumOffset[1] = 586;
						}
					case 'singUP':
						switch (dadOpponent.animation.curAnim.curFrame)
						{
							case 0:
								pendulumOffset[0] = 638;
								pendulumOffset[1] = -300;
							case 1:
								pendulumOffset[0] = 675;
								pendulumOffset[1] = -267;
							case 2:
								pendulumOffset[0] = 681;
								pendulumOffset[1] = -257;
							case 3:
								pendulumOffset[0] = 694;
								pendulumOffset[1] = -249;
							case 4:
								pendulumOffset[0] = 696;
								pendulumOffset[1] = -241;
							case 5:
								pendulumOffset[0] = 705;
								pendulumOffset[1] = -237;
							case 6 | 7:
								pendulumOffset[0] = 709;
								pendulumOffset[1] = -236;
							case 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 | 16 | 17:
								pendulumOffset[0] = 711;
								pendulumOffset[1] = -234;
						}
					case 'singDOWN':
						switch (dadOpponent.animation.curAnim.curFrame)
						{
							case 0:
								pendulumOffset[0] = 700;
								pendulumOffset[1] = 222;
							case 1:
								pendulumOffset[0] = 705;
								pendulumOffset[1] = 237;
							case 2:
								pendulumOffset[0] = 692;
								pendulumOffset[1] = 220;
							case 3 | 4:
								pendulumOffset[0] = 687;
								pendulumOffset[1] = 213;
							case 5:
								pendulumOffset[0] = 690;
								pendulumOffset[1] = 220;
							case 6:
								pendulumOffset[0] = 689;
								pendulumOffset[1] = 227;
							case 7:
								pendulumOffset[0] = 680;
								pendulumOffset[1] = 242;
							case 8:
								pendulumOffset[0] = 679;
								pendulumOffset[1] = 243;
							case 9 | 10 | 11 | 12 | 13 | 14 | 15 | 16 | 17:
								pendulumOffset[0] = 673;
								pendulumOffset[1] = 253;
						}
					case 'psyshock':
						switch (dadOpponent.animation.curAnim.curFrame)
						{
							case 0:
								pendulumOffset[0] = 737;
								pendulumOffset[1] = 386;
							case 1:
								pendulumOffset[0] = 713;
								pendulumOffset[1] = 396;
							case 2:
								pendulumOffset[0] = 706;
								pendulumOffset[1] = 394;
							case 3:
								pendulumOffset[0] = 708;
								pendulumOffset[1] = 392;
							case 4 | 5:
								pendulumOffset[0] = 709;
								pendulumOffset[1] = 391;
							case 6:
								pendulumOffset[0] = 709;
								pendulumOffset[1] = 405;
							case 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 | 16 | 17:
								pendulumOffset[0] = 703;
								pendulumOffset[1] = 416;
						}
				}
				pendulum.x = dadOpponent.x + pendulumOffset[0];
				pendulum.y = dadOpponent.y + pendulumOffset[1];
			}

			// spawn in the notes from the array
			while ((unspawnNotes[0] != null) && ((unspawnNotes[0].strumTime - Conductor.songPosition) < 3500)) {
				var dunceNote:Note = unspawnNotes[0];
				// push note to its correct strumline
				var myStrumline = strumLines.members[dunceNote.lane];
				if (myStrumline != null)
					myStrumline.push(dunceNote);
				unspawnNotes.splice(unspawnNotes.indexOf(dunceNote), 1);
			}

			// event bullshit
			if (eventList.length > 0) {
				// /*
				for (i in 0...eventList.length)
				{
					if (eventList[i] != null && Conductor.songPosition >= eventList[i].timestamp) {
						// /*
						var module:ForeverModule = Events.loadedModules.get(eventList[i].eventName);
						if (module.exists("eventFunction"))
							module.get("eventFunction")(eventList[i].params);
						stageBuild.dispatchEvent(eventList[i].eventName);
						if (module.exists("onUpdate"))
							updateableScript.push(module);
						// */
						trace(eventList.splice(i, 1));
					}
				}
				// */
			}
			noteCalls();
		}

		if (staticCamera) {
			camFollow.setPosition(manualCameraPosition.x + camDisplaceX, manualCameraPosition.y + camDisplaceY);
			if (accuracyMod && accuracyCameraMove && feraligatr != null)
				camFollow.setPosition(feraligatr.x + feraligatr.width / 2 + camDisplaceX, feraligatr.y + feraligatr.height / 3 + camDisplaceY);
		}
	}

	function die() {
		if (canDie && !paused) {
			FlxTween.globalManager.forEach(function(tween:FlxTween){
				tween.cancel();
			});
			FlxTimer.globalManager.forEach(function(timer:FlxTimer){
				timer.cancel();
			});
			// startTimer.active = false;
			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			isDead = true;
			canDie = false;
			if (tranceSound != null)
				tranceSound.stop();
			resetMusic();
			switch (SONG.song.toLowerCase()) {
				case 'brimstone':
					songMusic.pause();
					vocals.pause();
					boyfriend.playAnim('augh');
					boyfriend.canAnimate = false;
					FlxG.camera.follow(null);
					deadstone = true;
					FlxG.sound.play(Paths.sound('buryman-death/buriedDeath'));
					shakeProgression = 0;
					new FlxTimer().start(1, function(tmr:FlxTimer){
						//
						openSubState(new GameOverSubstate(boyfriend.curCharacter, boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
					});
				case 'lost-cause':
					boyfriend.atlasCharacter.visible = true;
					gfStand.atlasCharacter.visible = false;
					boyfriend.playAnim('FUCKING DIE', true);
					boyfriend.canAnimate = false;

					songMusic.pause();
					vocals.pause();
					deadstone = true;

					FlxTween.tween(camHUD, {alpha: 0}, Conductor.crochet / 1000);
					for (hud in strumHUD)
						FlxTween.tween(hud, {alpha: 0}, Conductor.crochet / 1000);
					FlxTween.tween(dialogueHUD, {alpha: 0}, Conductor.crochet / 1000);
					camFollow.setPosition(gfStand.getMidpoint().x + 150, gfStand.getMidpoint().y - 100);

					var backShadow:FlxSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
					backShadow.setGraphicSize(Std.int(FlxG.width * 5), Std.int(FlxG.height * 5));
					backShadow.screenCenter();
					backShadow.scrollFactor.set();
					backShadow.alpha = 0;
					backShadow.cameras = [camGame];
					add(backShadow);

					//
					var newCharacterGroup:FlxTypedGroup<FlxAnimate> = new FlxTypedGroup<FlxAnimate>();
					add(newCharacterGroup);
					//
					remove(boyfriend.atlasCharacter);
					newCharacterGroup.add(boyfriend.atlasCharacter);

					FlxTween.tween(backShadow, {alpha: 1}, (Conductor.crochet * 4) / 1000);
					new FlxTimer().start((Conductor.crochet * 4) / 1000, function(timer:FlxTimer){
						openSubState(new GameOverSubstate(boyfriend.curCharacter, camFollow.x, camFollow.y));
					});

				case 'monochrome':
					songMusic.pause();
					vocals.pause();
					dadOpponent.playAnim('fadeOut');
					deadstone = true;
					dadOpponent.canAnimate = false;
					FlxTween.tween(camHUD, {alpha: 0}, Conductor.crochet / 1000);
					for (hud in strumHUD)
						FlxTween.tween(hud, {alpha: 0}, Conductor.crochet / 1000);
					dadOpponent.animation.finishCallback = function(name:String){
						openSubState(new GameOverSubstate(boyfriend.curCharacter, boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
					}

				case 'shinto':
					songMusic.pause();
					vocals.pause();
					dadOpponent.playAnim('lose');
					deadstone = true;
					dadOpponent.canAnimate = false;
					FlxG.sound.play(Paths.sound('ShintoRetry'));
					new FlxTimer().start(0.22, function(heeehe:FlxTimer) {
						camHUD.alpha -= 0.34;
						strumHUD[0].alpha -= 0.34;
					}, 3);
					new FlxTimer().start(0.9584, function(tmr2:FlxTimer) {dadOpponent.visible = false;});
					new FlxTimer().start(1.13, function(tmr:FlxTimer){
						Main.switchState(this, new ShopState());
					});
				default:
					openSubState(new GameOverSubstate(boyfriend.curCharacter, boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			}
		}
	}

	// what
	
	function lcBar1() { 
		uiHUD.healthBar.createFilledBar(FlxColor.fromRGB(49, 176, 209), FlxColor.fromRGB(165, 0, 77));
	}
	function lcBar2() { 
		uiHUD.healthBar.createFilledBar(FlxColor.fromRGB(165, 0, 77), FlxColor.fromRGB(249, 223, 68));
	}
	function hbBar() { 
		uiHUD.healthBar.createFilledBar(FlxColor.fromRGB(49, 176, 209), FlxColor.fromRGB(126, 93, 145));
	}

	function hbEnding() {
				var dsCam = new FlxCamera();
				dsCam.bgColor.alpha = 0;
				allUIs.push(dsCam);
				FlxG.cameras.add(dsCam);
				//to layer bullshit on top of strumline lol

				var blackscreen:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
				blackscreen.cameras = [dsCam];
				add(blackscreen);
				blackscreen.alpha = 0;

				var ds1:FlxSprite = new FlxSprite().loadGraphic(Paths.image('UI/base/hellbell/ds_01'));
				ds1.antialiasing = true;
				ds1.scale.set(0.72, 0.72);
				ds1.updateHitbox();
				ds1.cameras = [dsCam];
				ds1.screenCenter(X);
				ds1.x += 10;
				ds1.y -= 30;
				ds1.scale.set(1.15, 1.15);
				add(ds1);

				var dsbf:FlxSprite = new FlxSprite().loadGraphic(Paths.image('UI/base/hellbell/ds_03'));
				dsbf.antialiasing = true;
				dsbf.scale.set(0.72, 0.72);
				dsbf.updateHitbox();
				dsbf.cameras = [dsCam];
				dsbf.screenCenter(X);
				dsbf.x += 10;
				dsbf.y -= 30;
				add(dsbf);
				dsbf.alpha = 0;

				camZooming = false;
				FlxTween.tween(uiHUD, {alpha: 0}, 1);
				FlxTween.tween(iconP1, {alpha: 0}, 1);
				FlxTween.tween(iconP2, {alpha: 0}, 1);				
				for (i in 0...strumHUD.length) {
					FlxTween.tween(strumHUD[i], {alpha: 0}, 1);
				}

				new FlxTimer().start(0.7, function(tmr:FlxTimer) {
					FlxTween.tween(FlxG.camera, {zoom: 0.4}, 2.5, {ease: FlxEase.quadOut});	
					FlxTween.tween(ds1.scale, {x: 0.72, y: 0.72}, 2.5, {
						ease: FlxEase.quadOut,
						onComplete: function(tween:FlxTween)
						{
							new FlxTimer().start(1.5, function(tmr:FlxTimer) {
								FlxG.sound.play(Paths.sound('bimbembooff'));
								FlxTween.tween(blackscreen, {alpha: 1}, 1);							
								new FlxTimer().start(0.7, function(tmr:FlxTimer) {
									FlxTween.tween(dsbf, {alpha: 0.3}, 1.8);
									new FlxTimer().start(3.4, function(tmr:FlxTimer) {
										camGame.alpha = 0;
										FlxTween.tween(dsCam, {alpha: 0}, 0.3);
										new FlxTimer().start(0.4, function(tmr:FlxTimer) {
											//wait
										});	
									});	
								});	
								
							});														
						}									
					});	
				});
	}

	function getPositionArrayCenter():Array<Float> {
		var leftPosX = (dadOpponent.getMidpoint().x + 100) + dadOpponent.characterData.camOffsetX;
		var rightPosX = (boyfriend.getMidpoint().x - 100) - boyfriend.characterData.camOffsetX;
		var leftPosY = (dadOpponent.getMidpoint().y - 100) + dadOpponent.characterData.camOffsetY;
		var rightPosY = (boyfriend.getMidpoint().y - 100) + boyfriend.characterData.camOffsetY;
		return [(leftPosX + rightPosX) / 2, ((leftPosY + rightPosY) / 2) + 50];
	}

	public var mxMechanic:Bool = false;
	function noteCalls()
	{
		// reset strums
		for (strumline in strumLines)
		{
			// handle strumline stuffs
			for (uiNote in strumline.receptors) {
				if (strumline.autoplay)
					strumCallsAuto(uiNote);
			}

			if (strumline.splashNotes != null) {
				for (i in 0...strumline.splashNotes.length)
				{
					strumline.splashNotes.members[i].x = strumline.receptors.members[i].x - 48;
					strumline.splashNotes.members[i].y = strumline.receptors.members[i].y + (Note.swagWidth / 6) - 56;
				}
			}
		}

		// if the song is generated
		if (generatedMusic && startedCountdown)
		{
			for (strumline in strumLines)
			{	
				strumline.allNotes.forEachAlive(function(daNote:Note) {
					daNote.downscrollNote = strumline.downscroll;

					// set the notes x and y
					var downscrollMultiplier = 1;
					if (daNote.downscrollNote)
						downscrollMultiplier = -1;

					var roundedSpeed = FlxMath.roundDecimal(songSpeed, 2);
					if (laneSpeed[daNote.noteData] != 0 && laneSpeed[daNote.noteData] != SONG.speed && daNote.lane == playerLane)
						roundedSpeed = FlxMath.roundDecimal(laneSpeed[daNote.noteData], 2);
					if (daNote.customScrollspeed)
						roundedSpeed = FlxMath.roundDecimal(daNote.noteSpeed, 2);

					var receptorPosY:Float = strumline.receptors.members[Math.floor(daNote.noteData)].y + Note.swagWidth / 6;
					var psuedoY:Float = ((
						// shubs be like ternary (this is just so downscroll also works as a default)
						// shut up kade
						(mxMechanic && daNote.lane == playerLane ? (defaultDownscroll ? -1 : 1) : downscrollMultiplier)
					 * -((Conductor.songPosition - daNote.strumTime) * (0.45 * roundedSpeed))));
					var psuedoX = 25 + daNote.noteVisualOffset;
					
					daNote.y = receptorPosY
						+ (Math.cos(flixel.math.FlxAngle.asRadians(daNote.noteDirection)) * psuedoY)
						+ (Math.sin(flixel.math.FlxAngle.asRadians(daNote.noteDirection)) * psuedoX)
						+ daNote.spriteOffet;
					// painful math equation
					daNote.x = strumline.receptors.members[Math.floor(daNote.noteData)].x
						+ (Math.cos(flixel.math.FlxAngle.asRadians(daNote.noteDirection)) * psuedoX)
						+ (Math.sin(flixel.math.FlxAngle.asRadians(daNote.noteDirection)) * psuedoY)
						+ daNote.spriteOffet;

					// also set note rotation
					// daNote.noteDirection = Math.sin(((Conductor.songPosition - daNote.strumTime) / 8000) * (180 / Math.PI)) * 5;
					daNote.angle = -daNote.noteDirection;

					// shitty note hack I hate it so much
					var center:Float = receptorPosY + Note.swagWidth / 2;
					if (daNote.isSustainNote && (strumline != dadStrums || !dadOpponent.curCharacter.contains('wiggl'))) {
						daNote.y -= ((daNote.height / 2) * downscrollMultiplier);

						if ((daNote.animation.curAnim.name.endsWith('holdend')) && (daNote.prevNote != null)) {
							daNote.y -= ((daNote.prevNote.height / 2) * downscrollMultiplier);
							if (daNote.downscrollNote) {
								daNote.y += (daNote.height * 2);
								if (daNote.endHoldOffset == Math.NEGATIVE_INFINITY) {
									// set the end hold offset yeah I hate that I fix this like this
									daNote.endHoldOffset = (daNote.prevNote.y - (daNote.y + daNote.height));
								}
								else
									daNote.y += daNote.endHoldOffset;
							} else {// this system is funny like that
								daNote.y += ((daNote.height / 2) * downscrollMultiplier);
							}
						}
						
						if (daNote.downscrollNote)
						{
							daNote.flipY = true;
							if ((daNote.parentNote != null && daNote.parentNote.wasGoodHit) 
								&& daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center
								&& (strumline.autoplay || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
							{
								var swagRect = FlxRect.weak(0, 0, daNote.frameWidth, daNote.frameHeight);
								swagRect.height = (center - daNote.y) / daNote.scale.y;
								swagRect.y = daNote.frameHeight - swagRect.height;
								daNote.clipRect = swagRect;
							}
						}
						else
						{
							daNote.flipY = false;
							if ((daNote.parentNote != null && daNote.parentNote.wasGoodHit)
								&& daNote.y + daNote.offset.y * daNote.scale.y <= center
								&& (strumline.autoplay || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
							{
								var swagRect = FlxRect.weak(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								swagRect.y = (center - daNote.y) / daNote.scale.y;
								swagRect.height -= swagRect.y;
								daNote.clipRect = swagRect;
							}
						}
					}
					// hell breaks loose here, we're using nested scripts!
					mainControls(daNote, strumline.singingCharacters, strumline, strumline.autoplay);

					// check where the note is and make sure it is either active or inactive
					if (daNote.y > FlxG.height) {
						daNote.active = false;
						daNote.visible = false;
					} else {
						daNote.visible = true;
						daNote.active = true;
					}

					if (!daNote.tooLate && daNote.strumTime < Conductor.songPosition - (Timings.msThreshold) && !daNote.wasGoodHit)
					{
						if ((!daNote.tooLate) && (daNote.lane == playerLane)) {
							if (!daNote.isSustainNote)
							{
								daNote.tooLate = true;
								for (note in daNote.childrenNotes)
									note.tooLate = true;
								
								canSpeak = false;
								missNoteCheck((Init.trueSettings.get('Ghost Tapping')) ? true : false, daNote.noteData,
									strumLines.members[playerLane].singingCharacters, true);
								// ambiguous name
								Timings.updateAccuracy(0);
							}
							else if (daNote.isSustainNote)
							{
								if (daNote.parentNote != null)
								{
									var parentNote = daNote.parentNote;
									if (!parentNote.tooLate)
									{
										var breakFromLate:Bool = false;
										for (note in parentNote.childrenNotes)
										{
											trace('hold amount ${parentNote.childrenNotes.length}, note is late?' + note.tooLate + ', ' + breakFromLate);
											if (note.tooLate && !note.wasGoodHit)
												breakFromLate = true;
										}
										if (!breakFromLate)
										{
											missNoteCheck((Init.trueSettings.get('Ghost Tapping')) ? true : false, daNote.noteData,
												strumLines.members[playerLane].singingCharacters, true);
											for (note in parentNote.childrenNotes)
												note.tooLate = true;
										}
										//
									}
								}
							}
						}
					
					}

					// if the note is off screen (above)
					if ((((!daNote.downscrollNote) && (daNote.y < -daNote.height))
						|| ((daNote.downscrollNote) && (daNote.y > (FlxG.height + daNote.height))))
					&& (daNote.tooLate || daNote.wasGoodHit))
						destroyNote(strumline, daNote);
				});

				// unoptimised asf camera control based on strums
				strumCameraRoll(strumline.receptors, (strumline == strumLines.members[playerLane]));
			}
			
		}
		
		// reset bf's animation
		var holdControls:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
		for (i in strumLines.members[playerLane].character) {
			if ((i != null && i.animation != null)
			&& (i.holdTimer > Conductor.stepCrochet * (4 / 1000)
					&& (!holdControls.contains(true) || strumLines.members[playerLane].autoplay)))
			{
				var nameOfAnimation = '';
				if (i.atlasCharacter != null)
					nameOfAnimation = i.atlasAnimation;
				else
					nameOfAnimation = i.animation.curAnim.name;

				if (nameOfAnimation.startsWith('sing') && !nameOfAnimation.endsWith('miss'))
					i.dance();
			}
		}

	}

	function winPendulum()
	{
		trance -= 0.075;
		var shadow:FlxSprite = pendulum.clone();
		shadow.setGraphicSize(Std.int(pendulum.width), Std.int(pendulum.height));
		shadow.updateHitbox();
		shadow.setPosition(pendulum.x, pendulum.y);
		shadow.cameras = pendulum.cameras;
		shadow.origin.set(pendulum.origin.x, pendulum.origin.y);
		shadow.angle = pendulum.angle;
		shadow.antialiasing = true;
		pendulumShadow.add(shadow);
		shadow.alpha = 0.5;
		FlxTween.tween(shadow, {alpha: 0}, Conductor.stepCrochet / 1000, {
			ease: FlxEase.linear,
			startDelay: Conductor.stepCrochet / 1000,
			onComplete: function(twn:FlxTween)
			{
				pendulumShadow.remove(shadow);
			}
		});

		var hypnoRating:FlxSprite = new FlxSprite(530, 370); //idk
		hypnoRating.frames = Paths.getSparrowAtlas('UI/base/hypno/Extras');
		hypnoRating.animation.addByPrefix('correct', 'Checkmark', 24, false);
		hypnoRating.animation.play('correct');
		hypnoRating.updateHitbox();
		hypnoRating.antialiasing = true;
		add(hypnoRating);
		hypnoRating.cameras = [PlayState.camHUD];
		hypnoRating.alpha = 1.0;
		hypnoRating.animation.finishCallback = function(name:String)
			{
				hypnoRating.destroy();
			}
	}

	function losePendulum(forced:Bool = false) {
		if (!strumLines.members[playerLane].autoplay)
		{
			trance += 0.115;

			var hypnoRating:FlxSprite = new FlxSprite(500, 350); //idk
			hypnoRating.frames = Paths.getSparrowAtlas('UI/base/hypno/Extras');
			hypnoRating.animation.addByPrefix('incorrect', 'X finished', 24, false);
			hypnoRating.animation.play('incorrect');
			hypnoRating.updateHitbox();
			hypnoRating.antialiasing = true;
			add(hypnoRating);
			hypnoRating.cameras = [PlayState.camHUD];
			hypnoRating.alpha = 1.0;
			hypnoRating.animation.finishCallback = function(name:String)
				{
					hypnoRating.destroy();
				}
		}
	}

	function useTyphlosion()
		{
			FlxG.sound.play(Paths.sound('TyphlosionUse'));

			typhlosion.playAnim('fire');
			typhlosion.animation.finishCallback = function(name:String)
				typhlosion.playAnim('idle');
			typhlosionUses -= 1;
			switch (typhlosionUses)
			{
				case 8: frostbiteTheromometerTyphlosion.animation.play('stage2');
				case 6: frostbiteTheromometerTyphlosion.animation.play('stage3');
				case 4: frostbiteTheromometerTyphlosion.animation.play('stage4');
				case 2: frostbiteTheromometerTyphlosion.animation.play('stage5');
			}
			coldness -= (0.35 * (typhlosionUses * 0.075)) + 0.20;

			if (typhlosionUses == 0)
				{
					new FlxTimer().start(0.85, function(tmr:FlxTimer)
						{
							FlxG.sound.play(Paths.sound('TyphlosionDeath'));
							typhlosion.playAnim('fire', true);
							typhlosion.animation.finishCallback = function(name:String)
								{
									typhlosion.animation.curAnim.pause();
								}
							FlxTween.tween(typhlosion, {y: typhlosion.y + 500}, 1.5, {ease: FlxEase.quadInOut});
						});
				}
		}

	function destroyNote(strumline:Strumline, daNote:Note)
	{
		daNote.active = false;
		daNote.exists = false;

		var chosenGroup = (daNote.isSustainNote ? strumline.holdsGroup : strumline.notesGroup);
		// note damage here I guess
		daNote.kill();
		if (strumline.allNotes.members.contains(daNote))
			strumline.allNotes.remove(daNote, true);
		if (chosenGroup.members.contains(daNote))
			chosenGroup.remove(daNote, true);
		daNote.destroy();
	}

	public var canSpeak:Bool = true;
	function goodNoteHit(coolNote:Note, character:Array<Character>, characterStrums:Strumline, ?canDisplayJudgement:Bool = true)
	{
		if (!coolNote.wasGoodHit) {
			coolNote.wasGoodHit = true;
			canSpeak = true;

			for (i in character)
				characterPlayAnimation(coolNote, i);
			
			if (characterStrums.receptors.members[coolNote.noteData] != null) {
				if (characterStrums == dadStrums && dadOpponent.curCharacter.contains('wiggl')) {
					// characterStrums.receptors.members[coolNote.noteData].playAnim('pressed', true);
					strumHUD[0].shake(0.00625, 0.05);
				} else
					characterStrums.receptors.members[coolNote.noteData].playAnim('confirm', true);
			}

			if (coolNote.noteType == 1 && characterStrums == boyfriendStrums)
				{
					trace('gengar note hit');
					FlxG.sound.play(Paths.sound('GengarNoteSFX'));
					if (flashingEnabled) dialogueHUD.flash(0x528E16FF, 0.5);
					gengarNoteInvis += 0.70;
					if (gengarNoteInvis > 0.70) gengarNoteInvis = 0.70;				
					destroyNote(characterStrums, coolNote);
					return;
				}

			// special thanks to sam, they gave me the original system which kinda inspired my idea for this new one
			if (canDisplayJudgement) {
				// get the note ms timing
				var noteDiff:Float = Math.abs(coolNote.strumTime - Conductor.songPosition);
				// get the timing
				if (coolNote.strumTime < Conductor.songPosition)
					ratingTiming = "late";
				else
					ratingTiming = "early";

				// loop through all avaliable judgements
				var foundRating:String = 'miss';
				var lowestThreshold:Float = Math.POSITIVE_INFINITY;
				for (myRating in Timings.judgementsMap.keys())
				{
					var myThreshold:Float = Timings.judgementsMap.get(myRating)[1];
					if (noteDiff <= myThreshold && (myThreshold < lowestThreshold))
					{
						foundRating = myRating;
						lowestThreshold = myThreshold;
					}
				}

				if (!coolNote.isSustainNote) {
					increaseCombo(foundRating, coolNote.noteData, character);
					popUpScore(foundRating, ratingTiming, characterStrums, coolNote);
					healthCall(Timings.judgementsMap.get(foundRating)[3]);
				} else if (coolNote.isSustainNote) {
					// call updated accuracy stuffs
					if (coolNote.parentNote != null)
						healthCall(100 / coolNote.parentNote.childrenNotes.length);
				}
			}

			if (characterStrums.displayJudgements) {
				if (!coolNote.isSustainNote)
				{
					if (coolNote.childrenNotes.length > 0) 
						Timings.notesHit++;
				}
				else {
					Timings.updateAccuracy(100, true, coolNote.parentNote.childrenNotes.length);
					if (coolNote.noteType == 2 && coolNote.animation.curAnim.name.contains('end')) {
						for (i in character)
							i.isPressing = false;
					}
					//
				}
			}

			if (!coolNote.isSustainNote) {
				if (characterStrums == dadStrums && dadOpponent.curCharacter.contains('wiggl'))
					return;
				destroyNote(characterStrums, coolNote);
			}				
		}
	}

	function missNoteCheck(?includeAnimation:Bool = false, direction:Int = 0, character:Array<Character>, popMiss:Bool = false, lockMiss:Bool = false)
	{
		if (usedTimeTravel)
			return;
		
		if (includeAnimation)
		{
			for (i in character)
				{
					if (i.forceNoMiss) //just made a super quick way to force it to not play miss animations if you do miss (used in pasta night)
						{
							decreaseCombo(popMiss);
							return;
						}
				}

			var stringDirection:String = UIStaticArrow.getArrowFromNumber(direction);

			if (!paused) {
				if (alexis)
					FlxG.sound.play(Paths.soundRandom('Electric_miss', 1, 5), FlxG.random.float(0.5, 0.6));
				else
					FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
	
			}

			for (i in character)
				i.playAnim('sing' + stringDirection.toUpperCase() + 'miss', lockMiss);
		}

		if (bronzongMechanic && direction == 4)
			{
				trace('BELL NOTE MISSED');
				health -= 0.3;
				blurAmount = 1.0;
			}

		decreaseCombo(popMiss);
		//
	}

	public function characterPlayAnimation(coolNote:Note, character:Character)
	{
		if (coolNote.noteData < 4) {
			// alright so we determine which animation needs to play
			var stringArrow:String = '';
			var altString:String = '';

			var baseString = 'sing' + UIStaticArrow.getArrowFromNumber(coolNote.noteData).toUpperCase();

			// I tried doing xor and it didnt work lollll
			if (coolNote.noteAlt > 0)
				altString = '-alt';
			if (((SONG.notes[Math.floor(curStep / 16)] != null) && (SONG.notes[Math.floor(curStep / 16)].altAnim))
				&& (character.animOffsets.exists(baseString + '-alt')))
			{
				if (altString != '-alt')
					altString = '-alt';
				else
					altString = '';
			}

			stringArrow = baseString + altString;
			character.playAnim(stringArrow, true);
			character.holdTimer = 0;
		} else {
			// specil hell bell BEHAVIOR
			character.isPressing = true;
		}
	}

	private function strumCallsAuto(cStrum:UIStaticArrow, ?callType:Int = 1, ?daNote:Note):Void
	{
		switch (callType)
		{
			case 1:
				// end the animation if the calltype is 1 and it is done
				if ((cStrum.animation.finished) && (cStrum.canFinishAnimation))
					cStrum.playAnim('static');
			default:
				// check if it is the correct strum
				if (daNote.noteData == cStrum.ID)
				{
					// if (cStrum.animation.curAnim.name != 'confirm')
					cStrum.playAnim('confirm'); // play the correct strum's confirmation animation (haha rhymes)

					// stuff for sustain notes
					if ((daNote.isSustainNote) && (!daNote.animation.curAnim.name.endsWith('holdend')))
						cStrum.canFinishAnimation = false; // basically, make it so the animation can't be finished if there's a sustain note below
					else
						cStrum.canFinishAnimation = true;
				}
		}
	}

	private function mainControls(daNote:Note, char:Array<Character>, strumline:Strumline, autoplay:Bool):Void
	{
		var notesPressedAutoplay = [];

		// here I'll set up the autoplay functions
		if (autoplay)
		{
			// check if the note was a good hit
			if (daNote.strumTime <= Conductor.songPosition)
			{
				// use a switch thing cus it feels right idk lol
				// make sure the strum is played for the autoplay stuffs
				/*
					charStrum.forEach(function(cStrum:UIStaticArrow)
					{
						strumCallsAuto(cStrum, 0, daNote);
					});
				 */

				// kill the note, then remove it from the array
				var canDisplayJudgement = false;
				if (strumline.displayJudgements)
				{
					canDisplayJudgement = true;
					for (noteDouble in notesPressedAutoplay)
					{
						if (noteDouble.noteData == daNote.noteData)
						{
							// if (Math.abs(noteDouble.strumTime - daNote.strumTime) < 10)
							canDisplayJudgement = false;
							// removing the fucking check apparently fixes it
							// god damn it that stupid glitch with the double judgements is annoying
						}
						//
					}
					notesPressedAutoplay.push(daNote);
				}
				goodNoteHit(daNote, char, strumline, canDisplayJudgement);
			}
			//
		} 

		var holdControls:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT, controls.SPACE];
		if (!autoplay) {
			// check if anything is held
			if (holdControls.contains(true))
			{
				// check notes that are alive
				strumline.allNotes.forEachAlive(function(coolNote:Note)
				{
					if ((coolNote.parentNote != null && coolNote.parentNote.wasGoodHit)
					&& coolNote.canBeHit && coolNote.lane == playerLane
					&& !coolNote.tooLate && coolNote.isSustainNote
					&& holdControls[coolNote.noteData])
						goodNoteHit(coolNote, char, strumline);
				});
				//
			}
		}
	}

	private function strumCameraRoll(cStrum:FlxTypedSpriteGroup<UIStaticArrow>, mustHit:Bool)
	{
		if (!Init.trueSettings.get('No Camera Note Movement') && enableMovement)
		{
			var camDisplaceExtend:Float = 15;
			if (PlayState.SONG.notes[Std.int(curStep / 16)] != null)
			{
				if ((!firstPerson && ((PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && mustHit)
					|| (!PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && !mustHit)))
					|| (firstPerson && mustHit)) 
				{
					camDisplaceX = 0;
					if (cStrum.members[0].animation.curAnim.name == 'confirm')
						camDisplaceX -= camDisplaceExtend;
					if (cStrum.members[3].animation.curAnim.name == 'confirm')
						camDisplaceX += camDisplaceExtend;
					
					camDisplaceY = 0;
					if (cStrum.members[1].animation.curAnim.name == 'confirm')
						camDisplaceY += camDisplaceExtend;
					if (cStrum.members[2].animation.curAnim.name == 'confirm')
						camDisplaceY -= camDisplaceExtend;

				}
			}
		} else {
			camDisplaceX = 0;
			camDisplaceY = 0;
		}
		//
	}

	override public function onFocus():Void
	{
		if (!paused)
			updateRPC(false);
		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		updateRPC(true);
		super.onFocusLost();
	}

	public static function updateRPC(pausedRPC:Bool)
	{
		Discord.changePresence('Heard you like snooping around Discord', 'Real classy.', iconRPC);
		/*
		var displayRPC:String = (pausedRPC) ? detailsPausedText : songDetails;
		if (health > 0)
			Discord.changePresence(displayRPC, detailsSub, iconRPC);
		*/
	}

	var animationsPlay:Array<Note> = [];

	private var ratingTiming:String = "";

	function popUpScore(baseRating:String, timing:String, strumline:Strumline, coolNote:Note)
	{
		// set up the rating
		var score:Int = 50;

		// notesplashes
		if (baseRating == "sick")
			// create the note splash if you hit a sick
			createSplash(coolNote, strumline);
		else
 			// if it isn't a sick, and you had a sick combo, then it becomes not sick :(
			if (allSicks)
				allSicks = false;

		displayRating(baseRating, timing);
		Timings.updateAccuracy(Timings.judgementsMap.get(baseRating)[3]);
		score = Std.int(Timings.judgementsMap.get(baseRating)[2]);

		songScore += score;

		popUpCombo();
	}

	public function createSplash(coolNote:Note, strumline:Strumline)
	{
		// play animation in existing notesplashes
		var noteSplashRandom:String = (Std.string((FlxG.random.int(0, 1) + 1)));
		if (strumline.splashNotes != null)
			strumline.splashNotes.members[coolNote.noteData].playAnim('anim' + noteSplashRandom, true);
	}

	private var createdColor = FlxColor.fromRGB(204, 66, 66);

	function popUpCombo(?cache:Bool = false)
	{
		var comboString:String = Std.string(combo);
		var negative = false;
		if ((comboString.startsWith('-')) || (combo == 0))
			negative = true;
		var stringArray:Array<String> = comboString.split("");
		// deletes all combo sprites prior to initalizing new ones
		if (lastCombo != null)
		{
			while (lastCombo.length > 0)
			{
				lastCombo[0].kill();
				lastCombo.remove(lastCombo[0]);
			}
		}

		for (scoreInt in 0...stringArray.length)
		{
			// numScore.loadGraphic(Paths.image('UI/' + pixelModifier + 'num' + stringArray[scoreInt]));
			var numScore = ForeverAssets.generateCombo('combo', stringArray[scoreInt], (!negative ? allSicks : false), assetModifier, changeableSkin, 'UI',
				negative, createdColor, scoreInt);
			numScore.setPosition(numScore.x + ratingPosition.x, numScore.y + ratingPosition.y);
			add(numScore);
			// hardcoded lmao
			if (!Init.trueSettings.get('Simply Judgements'))
			{
				add(numScore);
				FlxTween.tween(numScore, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						numScore.kill();
					},
					startDelay: Conductor.crochet * 0.002
				});
			}
			else
			{
				add(numScore);
				// centers combo
				numScore.y += 10;
				numScore.x -= 95;
				numScore.x -= ((comboString.length - 1) * 22);
				lastCombo.push(numScore);
				FlxTween.tween(numScore, {y: numScore.y + 20}, 0.1, {type: FlxTweenType.BACKWARD, ease: FlxEase.circOut});
			}
			// hardcoded lmao
			if (Init.trueSettings.get('Fixed Judgements'))
			{
				if (!cache)
					numScore.cameras = [camHUD];
				numScore.y += 50;
			}
			numScore.x += 100;
			if (cache)
				numScore.alpha = 0.0001;
		}
	}

	function decreaseCombo(?popMiss:Bool = false)
	{
		if (combo > 0)
			combo = 0; // bitch lmao
		else
			combo--;

		// misses
		songScore -= 10;
		misses++;

		// display negative combo
		if (popMiss) {
			// doesnt matter miss ratings dont have timings
			displayRating("miss", 'late');
			healthCall(Timings.judgementsMap.get("miss")[3]);
		}
		popUpCombo();

		// gotta do it manually here lol
		Timings.updateFCDisplay();
	}

	function increaseCombo(?baseRating:String, ?direction = 0, ?character:Array<Character>)
	{
		// trolled this can actually decrease your combo if you get a bad/shit/miss
		if (baseRating != null)
		{
			if (Timings.judgementsMap.get(baseRating)[3] > 0)
			{
				if (combo < 0)
					combo = 0;
				combo += 1;
			}
			else
				missNoteCheck(true, direction, character, false, true);
		}
	}

	public function displayRating(daRating:String, timing:String, ?cache:Bool = false)
	{
		/* so you might be asking
			"oh but if the rating isn't sick why not just reset it"
			because miss judgements can pop, and they dont mess with your sick combo
		 */
		var rating = ForeverAssets.generateRating('$daRating', (daRating == 'sick' ? allSicks : false), timing, assetModifier, changeableSkin, 'UI');
		rating.setPosition(rating.x + ratingPosition.x, rating.y + ratingPosition.y);
		add(rating);

		if (!Init.trueSettings.get('Simply Judgements'))
		{
			add(rating);

			FlxTween.tween(rating, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					rating.kill();
				},
				startDelay: Conductor.crochet * 0.00125
			});
		}
		else
		{
			if (lastRating != null) {
				lastRating.kill();
			}
			add(rating);
			lastRating = rating;
			FlxTween.tween(rating, {y: rating.y + 20}, 0.2, {type: FlxTweenType.BACKWARD, ease: FlxEase.circOut});
			FlxTween.tween(rating, {"scale.x": 0, "scale.y": 0}, 0.1, {
				onComplete: function(tween:FlxTween)
				{
					rating.kill();
				},
				startDelay: Conductor.crochet * 0.00125
			});
		}
		// */

		if (!cache) {
			if (Init.trueSettings.get('Fixed Judgements')) {
				// bound to camera
				rating.cameras = [camHUD];
				rating.screenCenter();
			}
			
			// return the actual rating to the array of judgements
			Timings.gottenJudgements.set(daRating, Timings.gottenJudgements.get(daRating) + 1);

			// set new smallest rating
			if (Timings.smallestRating != daRating) {
				if (Timings.judgementsMap.get(Timings.smallestRating)[0] < Timings.judgementsMap.get(daRating)[0])
					Timings.smallestRating = daRating;
			}
		} else
			rating.alpha = 0.0001; // uh hopefully this dont break ig
	}

	function healthCall(?ratingMultiplier:Float = 0)
	{
		// health += 0.012;
		var healthBase:Float = 0.06;
		health += (healthBase * (ratingMultiplier / 100));
	}

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (dadOpponent.curCharacter == 'gold')
		{
			dadOpponent.visible = true;
			dadOpponent.playAnim('fadeIn', true);
			dadOpponent.animation.finishCallback = function(name:String) {
				if (name == 'fadeIn')
					dadOpponent.dance();
			};
		}

		if (!paused)
		{
			songMusic.play();
			#if !html5
			songMusic.onComplete = doMoneyBag;
			vocals.play();

			// resyncVocals();

			// Song duration in a float, useful for the time left feature
			songLength = songMusic.length;

			// Updating Discord Rich Presence (with Time Left)
			updateRPC(false);
			#end
		}
	}

	function doMoneyBag():Void
		{
			inCutscene = true;
			canDie = false;

			var blackscreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width * 4, FlxG.height * 4, FlxColor.BLACK);
			blackscreen.cameras = [dialogueHUD];
			blackscreen.alpha = 0.0001;
			add(blackscreen);

			if (tranceSound != null) {
				tranceSound.pause();
				tranceSound.stop();
			}
			FlxTween.tween(camHUD, {alpha: 0}, 0.25, {ease: FlxEase.linear}) ;
			for (hud in strumHUD)
				FlxTween.tween(hud, {alpha: 0}, 0.25, {ease: FlxEase.linear});

			FlxTween.tween(blackscreen, {alpha: 1.0}, 0.35, {onComplete: function(tween:FlxTween)
				{
					moneyBag = new FlxSprite(1130, -40);
					moneyBag.frames = Paths.getSparrowAtlas('UI/base/moneybag');
					moneyBag.animation.addByPrefix('getCoin', 'Moneybag final', 24, false);
					moneyBag.animation.play('getCoin');
					moneyBag.updateHitbox();
					moneyBag.antialiasing = true;
					add(moneyBag);
					moneyBag.cameras = [dialogueHUD];
					moneyBag.animation.finishCallback = function(name:String) 
					{
						moneyBag.visible = false;
						new FlxTimer().start(0.01, function(tmr:FlxTimer)
							{
								moneySound.stop();
								endSong();
							});
					};

					new FlxTimer().start(0.50, function(tmr:FlxTimer)
						{
							moneySound.play();

							var moneyFromDaSong:Float = 0.0;
							moneyFromDaSong = 100; //base song amount could be 100
							moneyFromDaSong += FlxMath.roundDecimal((Math.floor(Timings.getAccuracy() * 100) / 10000) * 150, 0); //and then you can earn up to a extra 150 coins which is determined by your accuracy. (and then round it up too)

							var moneyGainText:FlxText = new FlxText(1132, 670, 100, "+0", 36);
							moneyGainText.text = "+" + Std.string(moneyFromDaSong);
							FlxG.save.data.money += moneyFromDaSong;

							moneyGainText.setFormat(Paths.font("poke.ttf"), 36, 0xFFFFDC44, CENTER, FlxTextBorderStyle.OUTLINE, 0xFF331D00);
							moneyGainText.scrollFactor.set();
							moneyGainText.borderSize = 1.5;
							moneyGainText.visible = true;
							add(moneyGainText);
							moneyGainText.cameras = [dialogueHUD];

							moneyGainText.scale.x = 1.5;
							moneyGainText.scale.y = 1.5;
							FlxTween.tween(moneyGainText, {"scale.x": 1.0, "scale.y": 1.0}, 0.70, {type: FlxTweenType.ONESHOT, ease: FlxEase.expoOut, onComplete: function (tween:FlxTween)
							{
								FlxTween.tween(moneyGainText, {y: moneyGainText.y + 50, alpha: 0.0}, 0.35, {type: FlxTweenType.ONESHOT, ease: FlxEase.expoInOut});
							}});
						});
				}});
		}

	public var songLoops:Bool = false;

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());
		if (!songLoops) {
			var songData = SONG;
			Conductor.changeBPM(songData.bpm);

			songDetails = CoolUtil.dashToSpace(songDisplayName) + ' - ' + CoolUtil.difficultyFromNumber(storyDifficulty);
			if (isStoryMode) 
				songDetails = '${StoryMenuState.cartridgeList[storyWeek].weekName} - ' + CoolUtil.difficultyFromNumber(storyDifficulty);
			detailsPausedText = "Paused - " + songDetails;

			detailsSub = "";
			updateRPC(false);

			curSong = songData.song;
			songMusic = new FlxSound().loadEmbedded(Paths.inst(SONG.song, old, songLibrary), SONG.song.toLowerCase() == 'sansno', true);
			if (SONG.needsVoices)
				vocals = new FlxSound().loadEmbedded(Paths.voices(SONG.song, old, songLibrary), SONG.song.toLowerCase() == 'sansno', true);
			else
				vocals = new FlxSound();

			FlxG.sound.list.add(songMusic);
			FlxG.sound.list.add(vocals);
		} else
			Conductor.songPosition = 0;

		// generate the chart
		unspawnNotes = ChartLoader.generateChartType(SONG, determinedChartType, this);
		if (sys.FileSystem.exists(Paths.songJson(SONG.song.toLowerCase(), 'events', old))) {
			trace('events found');
			var eventJson:SwagSong = Song.loadFromJson('events'+(old ? '_old' : ''), SONG.song.toLowerCase(), old);
			if (eventJson != null)
				eventList = ChartLoader.generateChartType(eventJson, 'event', this);
		}

		// sort through them
		unspawnNotes.sort(sortByShit);
		
		// give the game the heads up to be able to start
		generatedMusic = true;

		Timings.accuracyMaxCalculation(unspawnNotes);
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);

	function resyncVocals():Void
	{
		if (!deadstone) {
			trace('resyncing vocal time ${vocals.time}');
			// songMusic.pause();
			vocals.pause();
			Conductor.songPosition = songMusic.time;
			vocals.time = Conductor.songPosition;
			// songMusic.play();
			vocals.play();
			trace('new vocal time ${Conductor.songPosition}');
		}
	}
	
	override function stepHit()
	{
		super.stepHit();
		if (tranceActive && !tranceNotActiveYet && (SONG.song.toLowerCase() != 'left-unchecked' || Conductor.songPosition > 20000))
		{
			if (psyshockCooldown <= 0)
			{
				psyshock();
				if (dadOpponent.curCharacter == 'hypno')
				{
					dadOpponent.playAnim('psyshock', true);
					dadOpponent.canAnimate = false; //
					new FlxTimer().start(Conductor.stepCrochet * 4 / 1000, function(tmr:FlxTimer)
					{
						dadOpponent.canAnimate = true;
						dadOpponent.dance();
					});
					psyshockCooldown = psyshockCalculate(110, 65);
				}
				else
					psyshockCooldown = psyshockCalculate(75, 40);
			}
			else
				psyshockCooldown--;
		}

		if (songMusic != null && Math.abs(songMusic.time - Conductor.songPosition) > 20
		|| (SONG.needsVoices && vocals != null && Math.abs(vocals.time - Conductor.songPosition) > 20))
			resyncVocals();
		//*/
		stageBuild.stageUpdateStep(curStep);
	}

	function psyshockCalculate(startingValue:Int, endingValue:Int):Int 
		return Std.int(FlxMath.lerp(startingValue, endingValue, Conductor.songPosition / songLength));

	private function charactersDance(curBeat:Int)
	{
		if (!startingBrimstone) {
			for (j in strumLines.members)
			{
				for (i in j.character)
				{
					var nameOfAnimation = '';
					if (i.atlasCharacter != null)
						nameOfAnimation = i.atlasAnimation;
					else nameOfAnimation = i.animation.curAnim.name;
					
					if ((nameOfAnimation.startsWith("idle") || nameOfAnimation.startsWith("dance"))
						&& (curBeat % 2 == 0 || i.characterData.quickDancer))
						i.dance();
				}
			}

		}

		if (mxBlock != null && curBeat % 2 == 0)
			mxBlock.animation.play('idle');

		if (feraligatr != null && curBeat % 2 == 0)
			feraligatr.animation.play('idle');

		if (typhlosion != null && curBeat % 2 == 0 && typhlosionUses >= 1 && typhlosion.animation.curAnim.name != 'fire')
			typhlosion.playAnim('idle');
	}

	public var bopIntensity:Float = 1;
	public var bopFrequency:Float = 1;
	public var camZooming:Bool = true;
	override function beatHit()
	{
		super.beatHit();

		if (bopFrequency != 0) {
			if ((FlxG.camera.zoom < 1.35 && curBeat % (4 / bopFrequency) == 0)
				&& camZooming
				&& (!Init.trueSettings.get('Reduced Movements')))
			{
				FlxG.camera.zoom += 0.015 * bopIntensity;
				camHUD.zoom += 0.05 * bopIntensity;
				for (hud in strumHUD)
					hud.zoom += 0.05 * bopIntensity;
			}
		}


		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
			}
		}

		if (!Init.trueSettings.get('Reduced Movements') && !buriedNotes)
		{
			for (i in uiHUD.iconGroup) {
				i.setGraphicSize(Std.int(i.width + 45));
				i.updateHitbox();
			}	
		}

		//
		charactersDance(curBeat);

		// stage stuffs
		stageBuild.stageUpdate(curBeat);
	}

	public static function resetMusic()
	{
		// simply stated, resets the playstate's music for other states and substates
		if (songMusic != null)
			songMusic.stop();

		if (vocals != null)
			vocals.stop();
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused && !isDead)
		{
			// trace('null song');
			if (songMusic != null)
			{
				//	trace('nulled song');
				songMusic.pause();
				vocals.pause();
				//	trace('nulled song finished');
			}

			FlxTimer.globalManager.forEach(function(timer:FlxTimer){
				if (!timer.finished)
					timer.active = false;
			});
			FlxTween.globalManager.forEach(function(tween:FlxTween){
				if (!tween.finished)
					tween.active = false;
			});
		}

		// trace('open substate');
		super.openSubState(SubState);
		// trace('open substate end ');
	}

	override function closeSubState()
	{
		super.closeSubState();
		
		if (paused)
		{
			songMusic.play();
			vocals.play();

			if (tranceSound != null) tranceSound.play();

			FlxTimer.globalManager.forEach(function(timer:FlxTimer) {
				if (!timer.finished)
					timer.active = true;
			});
			FlxTween.globalManager.forEach(function(tween:FlxTween) {
				if (!tween.finished)
					tween.active = true;
			}); 
			if (songMusic != null && !startingSong) {
				if (startTimer == null || startTimer.active)
					resyncVocals();			
			}
			paused = false;
			///*
			updateRPC(false);
			// */
		}
	}

	/*
		Extra functions and stuffs
	 */
	/// song end function at the end of the playstate lmao ironic I guess
	private var endSongEvent:Bool = false;

	function endSong():Void
	{
		if (!songLoops) {
			canPause = false;

			songMusic.volume = 0;
			vocals.volume = 0;

			if (SONG.validScore) {
				if (!FlxG.save.data.unlockedSongs.contains(CoolUtil.spaceToDash(SONG.song.toLowerCase())))
					FlxG.save.data.unlockedSongs.push(CoolUtil.spaceToDash(SONG.song.toLowerCase()));
				Highscore.saveScore(SONG.song, songScore, storyDifficulty);
			}
			
			if (!isStoryMode)
				Main.switchState(this, new ShopState());
			else {
				// set the campaign's score higher
				campaignScore += songScore;
				// remove a song from the story playlist
				storyPlaylist.remove(storyPlaylist[0]);
				songEndSpecificActions();
			}
			//
		} else
			generateSong(SONG.song);
	}

	private function songEndSpecificActions()
	{
		var videoName:String = '';
		switch (CoolUtil.spaceToDash(SONG.song.toLowerCase()))
		{			
			case 'shinto':
				videoName = 'shinto';
			case 'insomnia':
				videoName = 'monochrome_cutscene';
			case 'left-unchecked':
				videoName = 'leftunchecked';
			default:
				// if you wanna override the default song end call return here
		}
		callDefaultSongEnd(videoName);
	}



	private function callDefaultSongEnd(videoName:String = '')
	{
		ForeverTools.killMusic([songMusic, vocals]);
		if ((storyPlaylist.length <= 0))
		{
			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;

			if (SONG.validScore)
				Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
			FlxG.save.flush();

			switch (storyWeek) {
				case 0:
					// unlock freeplay lol
					UnlockSubstate.queueNewUnlock('freeplay');
			}

			Main.switchState(this, new StoryMenuState());
		}
		else 
		{
			var difficulty:String = '-' + CoolUtil.difficultyFromNumber(storyDifficulty).toLowerCase();
			difficulty = difficulty.replace('-normal', '');

			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;

			PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0], old);
			if (videoName == '')
				FlxG.switchState(new PlayState());
			else {
				VideoState.videoName = videoName;
				FlxG.switchState(new VideoState());
			}
		}
	}

	var dialogueBox:DialogueBox;

	var blackFade:FlxSprite;
	function loopFade(tmr:FlxTimer) {
        blackFade.alpha -= 0.1;
        if (blackFade.alpha < 0)
            startCountdown();
        else
            new FlxTimer().start(0.25, loopFade);
    }

	public function songIntroCutscene()
	{
		inCutscene = true;
		switch (curSong.toLowerCase())
		{
			case 'missingno':
				inCutscene = false;
				blackFade = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
				blackFade.setGraphicSize(dialogueHUD.width, dialogueHUD.height);
				blackFade.scrollFactor.set();
				blackFade.screenCenter();
				blackFade.cameras = [dialogueHUD];
				add(blackFade);
				new FlxTimer().start(0.25, loopFade);
			case "monochrome":
				FlxG.sound.play(Paths.sound('ImDead' + FlxG.random.int(1, 7)), 1);
				new FlxTimer().start(2, function(tmr:FlxTimer) {
					startCountdown();
				});
			case "death-toll":

				var dsCam = new FlxCamera();
				dsCam.bgColor.alpha = 0;
				allUIs.push(dsCam);
				FlxG.cameras.add(dsCam);
				//to layer bullshit on top of strumline lol

				var blackscreen:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
				blackscreen.cameras = [dsCam];
				add(blackscreen);

				var dsbg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('UI/base/hellbell/dsgradient'));
				dsbg.antialiasing = true;
				dsbg.scale.set(0.72, 0.72);
				dsbg.updateHitbox();
				dsbg.cameras = [dsCam];
				dsbg.screenCenter();
				add(dsbg);
				dsbg.visible = false;

				var ds1:FlxSprite = new FlxSprite().loadGraphic(Paths.image('UI/base/hellbell/ds_01'));
				ds1.antialiasing = true;
				ds1.scale.set(0.72, 0.72);
				ds1.updateHitbox();
				ds1.cameras = [dsCam];
				ds1.screenCenter(X);
				ds1.x += 10;
				ds1.y -= 30;

				var ds2:FlxSprite = new FlxSprite(0, 0);	
				ds2.frames = Paths.getSparrowAtlas('UI/base/hellbell/bimbembo');
				ds2.animation.addByPrefix('intro', "dsintro", 24, false);
				ds2.antialiasing = true;
				ds2.scale.set(0.72, 0.72);
				ds2.updateHitbox();
				ds2.cameras = [dsCam];
				ds2.screenCenter();
				ds2.x += 10;
				ds2.y -= 30;
				add(ds2);
				ds2.visible = false;

				add(ds1);

				camZooming = false;
				FlxG.camera.zoom = 0.55;
				uiHUD.alpha = 0;
				iconP1.alpha = 0;
				iconP2.alpha = 0;
				for (i in 0...strumHUD.length) {
					strumHUD[i].zoom = 0.65;
				}
				for (i in 0...strumHUD.length) {
					strumHUD[i].alpha = 0;
				}

				new FlxTimer().start(1, function(tmr:FlxTimer){
					dsbg.visible = true;	
					ds2.visible = true;
									
					remove(blackscreen);
					new FlxTimer().start(0.7, function(tmr:FlxTimer) {
						ds2.animation.play("intro");
						new FlxTimer().start(0.55, function(tmr:FlxTimer) {
							FlxG.sound.play(Paths.sound('bimbembo'));
						});	
					});										
						new FlxTimer().start(2.8, function(tmr:FlxTimer) {
								startCountdown();
								new FlxTimer().start(0.5, function(tmr:FlxTimer) {
									for (i in 0...strumHUD.length) {
										FlxTween.tween(strumHUD[i], {alpha: 1}, 0.7);
									}
									FlxTween.tween(ds2, {alpha: 0}, 0.4);
									FlxTween.tween(dsbg, {alpha: 0}, 0.7, {
										ease: FlxEase.linear,
										onComplete: function(twn:FlxTween)
										{
											remove(dsbg);
											remove(ds2);
											new FlxTimer().start(0.5, function(tmr:FlxTimer) {
												FlxTween.tween(FlxG.camera, {zoom: 0.75}, 1.35, {
													ease: FlxEase.backIn,		
													onComplete: function(tween:FlxTween)
														{
															camZooming = true;
														}							
												});	
												FlxTween.tween(ds1.scale, {x: 1.15, y: 1.15}, 1.5, {
													ease: FlxEase.backIn,
													onComplete: function(tween:FlxTween)
													{
														remove(ds1);												
													}									
												});									
												for (i in 0...strumHUD.length) {
													FlxTween.tween(strumHUD[i], {zoom: 1}, 1.5, {
														ease: FlxEase.backIn,								
													});				
												}
												new FlxTimer().start(1.2, function(tmr:FlxTimer) {
													FlxTween.tween(uiHUD, {alpha: 1}, 2);
													FlxTween.tween(iconP1, {alpha: 1}, 2);
													FlxTween.tween(iconP2, {alpha: 1}, 2);
												});
											});
										}
									});	
								});						
						});	
				});

										
			default:
				startCountdown();
		}
	}

	public static var swagCounter:Int = 0;

	public function startCountdown():Void
	{
		inCutscene = false;
		Conductor.songPosition = -(Conductor.crochet * 5);
		swagCounter = 0;

		camHUD.visible = true;
		var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
		introAssets.set('default', [
			ForeverTools.returnSkinAsset('ready', assetModifier, changeableSkin, 'UI'),
			ForeverTools.returnSkinAsset('set', assetModifier, changeableSkin, 'UI'),
			ForeverTools.returnSkinAsset('go', assetModifier, changeableSkin, 'UI')
		]);

		var introAlts:Array<String> = introAssets.get('default');
		for (value in introAssets.keys())
		{
			if (value == PlayState.curStage)
				introAlts = introAssets.get(value);
		}

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			startedCountdown = true;

			charactersDance(curBeat);

			if (!disableCountdown) {
				switch (swagCounter)
				{
					case 0:
						FlxG.sound.play(Paths.sound('intro3-' + assetModifier), 0.6);
						Conductor.songPosition = -(Conductor.crochet * 4);
					case 1:
						var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
						ready.scrollFactor.set();
						ready.updateHitbox();

						if (assetModifier == 'pixel')
							ready.setGraphicSize(Std.int(ready.width * PlayState.daPixelZoom));

						ready.screenCenter();
						add(ready);
						FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								ready.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro2-' + assetModifier), 0.6);

						Conductor.songPosition = -(Conductor.crochet * 3);
					case 2:
						var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
						set.scrollFactor.set();

						if (assetModifier == 'pixel')
							set.setGraphicSize(Std.int(set.width * PlayState.daPixelZoom));

						set.screenCenter();
						add(set);
						FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								set.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro1-' + assetModifier), 0.6);

						Conductor.songPosition = -(Conductor.crochet * 2);
					case 3:
						var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
						go.scrollFactor.set();

						if (assetModifier == 'pixel')
							go.setGraphicSize(Std.int(go.width * PlayState.daPixelZoom));

						go.updateHitbox();

						go.screenCenter();
						add(go);
						FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								go.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('introGo-' + assetModifier), 0.6);

						Conductor.songPosition = -(Conductor.crochet * 1);
				}
			} 

			Conductor.songPosition = -(Conductor.crochet * (5 - (swagCounter + 1)));
			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	override function add(Object:FlxBasic):FlxBasic {
		if (Init.trueSettings.get('Disable Antialiasing') && Std.isOfType(Object, FlxSprite))
			cast(Object, FlxSprite).antialiasing = false;
		return super.add(Object);
	}

	function get_songSpeed():Float {
		return songSpeed;
	}

	function set_songSpeed(value:Float):Float {
		if (generatedMusic) {
			var ratio:Float = value / songSpeed; // funny word huh
			for (strumline in strumLines)
			{
				for (note in strumline.allNotes)
				{
					if (!note.customScrollspeed && note.isSustainNote && !note.animation.curAnim.name.endsWith('end'))
					{
						note.scale.y *= ratio;
						note.updateHitbox();
					}
				}
			}
			for (note in unspawnNotes)
			{
				if (!note.customScrollspeed && note.isSustainNote && !note.animation.curAnim.name.endsWith('end'))
				{
					note.scale.y *= ratio;
					note.updateHitbox();
				}
			}
		}
		songSpeed = value;
		return value;
	}

	var prevLaneSpeed:Array<Float> = [];

	public function setLaneSpeed(i:Int) {
		trace('Lane Speed Being Set to ' + i);
		if (generatedMusic) {
			if (laneSpeed[i] != prevLaneSpeed[i])
			{
				var ratio:Float = laneSpeed[i] / prevLaneSpeed[i]; // funny word huh
				for (strumline in strumLines)
				{
					for (note in strumline.allNotes)
					{
						if (!note.customScrollspeed
							&& (note.noteData == i)
							&& note.isSustainNote
							&& !note.animation.curAnim.name.endsWith('end'))
						{
							note.scale.y *= ratio;
							note.updateHitbox();
						}
					}
				}
				for (note in unspawnNotes)
				{
					if (!note.customScrollspeed
						&& (note.noteData == i)
						&& note.isSustainNote
						&& !note.animation.curAnim.name.endsWith('end'))
					{
						note.scale.y *= ratio;
						note.updateHitbox();
					}
				}
				prevLaneSpeed[i] = laneSpeed[i];
			}
			//
		}
	}



}
