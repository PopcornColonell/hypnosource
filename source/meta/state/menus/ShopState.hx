package meta.state.menus;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.tile.FlxGraphicsShader;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import flxanimate.FlxAnimate;
import gameObjects.userInterface.menu.Textbox;
import haxe.Json;
import lime.math.Vector2;
import meta.MusicBeat.MusicBeatState;
import meta.data.Conductor;
import meta.data.Highscore;
import meta.data.Song;
import meta.data.dependency.Discord;
import meta.data.font.Alphabet;
import meta.state.menus.FreeplayState;
import meta.subState.UnlockSubstate.LockSprite;
import openfl.display.GraphicsShader;
import openfl.events.MouseEvent;
import openfl.filters.ShaderFilter;
import sys.FileSystem;
import sys.io.File;
import sys.thread.Mutex;
import sys.thread.Thread;

using StringTools;

typedef ShopItem =
{
	var name:String;
	var price:Float;
	var animName:String;
	var songUnlock:String;
	var songDescription:String;
	var unlockRequirements:Array<String>;
	var xOffset:Int;
	var yOffset:Int;
	var lane:Int;
	var row:Int;
	var scale:Float;
}

typedef ShopLines =
{
	var idleLines:Array<String>;
	var pussyLines:Array<String>;
	var hellLines:Array<String>;
	var poorLines:Array<String>;
}

class ShopState extends MusicBeatState
{
	// SHOP RELATED VARIABLES
	var itemArray:Array<ShopItem> = [];
	var folderList:Array<String> = CoolUtil.returnAssetsLibrary('images/shop', 'assets');
	var itemSprites:FlxTypedSpriteGroup<FlxSprite>;
	var itemPrices:FlxTypedSpriteGroup<FlxText>;
	var itemsCreated:Int = 0;
	var curItemSelected:Int = 0;
	var shopItemsBox:FlxSprite;
	var shopHand:FlxSprite;
	var shopCurrencyIcon:FlxSprite;
	var currencyText:FlxText;
	var shopItemName:Alphabet;

	public var shopGroup:FlxTypedGroup<FlxObject>;
	public var freeplayGroup:FlxTypedGroup<FlxObject>;

	public var grpSongs:FlxTypedSpriteGroup<Alphabet>;
	public var grpLocked:FlxTypedSpriteGroup<LockSprite>;

	private var songs:Array<SongMetadata> = [];
	private var existingSongs:Array<String> = [];

	public static var mutex:Mutex;
	public static var playIntro:Bool = false;

	public static var portraitOffset:Map<String, FlxPoint> = [
		'frostbite' => new FlxPoint(27, 1),
		'safety-lullaby' => new FlxPoint(106, 74),
		'left-unchecked' => new FlxPoint(39, 54),
		'monochrome' => new FlxPoint(1),
		'missingno' => new FlxPoint(12),
		'brimstone' => new FlxPoint(0, 115),
		'death-toll' => new FlxPoint(160, 165),
		'isotope' => new FlxPoint(12, 8),
		'shitno' => new FlxPoint(72, 90)
	];

	static final pastaUnlock:String = 'Seems like I made my coin, and you got what you wanted. 
		See ya kid, have this as a little token of appreciation. Some shitty goblin gave it to me.';
	static final excludedItems:Array<String> = ['GameBoy Advanced SP', 'Lit Candle', 'Pokemon Silver'];

	var backgroundHeader:FlxSprite;

	var cartridgeIntro:FlxSprite;
	var staticIntro:FlxSprite;

	var cartridgeGuy:FlxSprite;
	var cartridgeLight:FlxSprite;
	var candleSine:Float = 0;

	var freeplayBG:FlxSprite;
	var freeplayHeader:Alphabet;

	var shopSign:FlxSprite;

	public var shopLines:ShopLines;

	var mainTextbox:Textbox;
	var mainTextboxText:FlxText;

	var subTextbox:Textbox;
	var subTextboxTextGroup:FlxTypedSpriteGroup<FlxText>;
	var selectionArray:Array<String> = ['BUY', 'SELL', 'EXIT'];

	var shopSelection:Int = 0;
	var shopSelector:FlxSprite;
	var inShop:Bool = false;
	var confirmingPurchase:Bool = false;
	var inCutscene:Bool = false;

	var gameBoy:FlxAnimate;
	var blackOverlay:FlxSprite;

	var currentShopDialogue:String;
	var lastShopDialogue:Array<Int> = [];

	override public function create()
	{
		super.create();

		if (!freeplaySelected)
			Discord.changePresence('BROWSING THE SHOP', 'Freeplay Menu');
		else
			Discord.changePresence('CHOOSING A SONG', 'Freeplay Menu');

		var rawJson = File.getContent(Paths.getPath('images/shop/shopText.json', TEXT)).trim();
		while (!rawJson.endsWith("}"))
			rawJson = rawJson.substr(0, rawJson.length - 1);
		shopLines = cast Json.parse(rawJson).shopLines;

		PlayState.SONG = null;
		mutex = new Mutex();

		Conductor.songPosition = 0;
		Conductor.changeBPM(166);

		if (FlxG.save.data.freeplayFirstTime == false) {
			FlxG.save.data.freeplayFirstTime = true;
			playIntro = true;
			FlxG.save.flush();
		}

		glitchingno = new FlxGraphicsShader("", Paths.shader('glitch'));
		chromaticAberration = new ShaderFilter(new GraphicsShader("", Paths.shader('shopShader')));
		chromaticAberration.shader.data.effectTime.value = [aberrateTimeValue];
		FlxG.camera.setFilters([chromaticAberration]);

		// initialize shop music
		FlxG.sound.playMusic(Paths.music('FreeplayMenu'), 0, true);
		if (!playIntro)
			FlxG.sound.music.fadeIn(0.5, 0, 1);

		// FlxG.stage.addEventListener(MouseEvent.MOUSE_WHEEL, scroll);

		// instantiate the new groups
		shopGroup = new FlxTypedGroup<FlxObject>();
		freeplayGroup = new FlxTypedGroup<FlxObject>();

		backgroundHeader = new FlxSprite().makeGraphic(FlxG.width, Std.int(FlxG.height / 8), FlxColor.WHITE);
		backgroundHeader.scrollFactor.set(0, 0);
		add(backgroundHeader);

		// SHOP STUFF
		// create shop header

		var shopHeader:Alphabet = new Alphabet(0, 0, 'Shop', true, false, false);
		shopHeader.controllable = true;
		shopHeader.setPosition(Std.int(FlxG.width / 2 - shopHeader.width / 2), 16);
		shopGroup.add(shopHeader);

		// THE GUY THE LAD
		cartridgeGuy = new FlxSprite();
		cartridgeGuy.frames = Paths.getSparrowAtlas('menus/shop/CGShop_assets');
		for (i in 0...idleAmount)
		{
			cartridgeGuy.animation.addByPrefix('idle-$i', 'CG_Idle0${i + 1}0', 24, true);
			cartridgeGuy.animation.addByPrefix('idle-$i-alt', 'CG_Idle0${i + 1}_Alt0', 24, false);
		}
		cartridgeGuy.animation.addByPrefix('scared', 'CG_Scared01', 24, false);
		cartridgeGuy.animation.addByPrefix('scaredloop', 'CG_Scared02_Loop', 24, false);

		shuffleCartridgeIdle(true);
		cartridgeGuy.animation.play('idle-$cartridgeIdle');

		cartridgeGuy.setGraphicSize(Std.int(1.375 * cartridgeGuy.width));
		cartridgeGuy.updateHitbox();
		cartridgeGuy.antialiasing = true;
		cartridgeGuy.setPosition(0, FlxG.height - cartridgeGuy.height);
		shopGroup.add(cartridgeGuy);

		// HIS INTRODUCTION
		if (playIntro)
		{
			cartridgeIntro = new FlxSprite();
			cartridgeIntro.frames = Paths.getSparrowAtlas('menus/shop/CGIntro_assets');
			cartridgeIntro.animation.addByPrefix('intro', 'CG_Intro', 24, false);
			cartridgeIntro.animation.play('intro');
			cartridgeIntro.setGraphicSize(Std.int(1.375 * cartridgeIntro.width));
			cartridgeIntro.updateHitbox();
			cartridgeIntro.antialiasing = true;
			cartridgeIntro.setPosition(0, FlxG.height - cartridgeGuy.height);
			cartridgeIntro.alpha = 0.0001;
			add(cartridgeIntro);
			cartridgeGuy.visible = false;
		}

		cartridgeLight = new FlxSprite().loadGraphic(Paths.image('menus/shop/CandleLight'));
		cartridgeLight.antialiasing = true;
		cartridgeLight.setPosition(cartridgeGuy.x + 67 - cartridgeLight.width / 2, cartridgeGuy.y + 508 - cartridgeLight.height / 2);
		shopGroup.add(cartridgeLight);

		// HIS SIGN LOLLLL
		shopSign = new FlxSprite();
		shopSign.frames = Paths.getSparrowAtlas('menus/shop/CGShopSign_assets');
		shopSign.animation.addByPrefix('signThing', 'ShopSign', 24, false);
		shopSign.animation.play('signThing');
		shopSign.y += backgroundHeader.height;
		shopSign.x += (cartridgeGuy.width / 3) + 16;
		shopGroup.add(shopSign);

		// the textbox ig
		mainTextbox = new Textbox(0, 0);
		mainTextbox.scale.set(3, 3);
		mainTextbox.boxWidth = 24;
		mainTextbox.boxHeight = 4;
		mainTextbox.setPosition((FlxG.width / 2 - ((mainTextbox.boxWidth - 4) * mainTextbox.boxInterval * mainTextbox.scale.x) / 4) + 24,
			FlxG.height - ((FlxG.height / 12) + 36));
		shopGroup.add(mainTextbox);

		mainTextboxText = new FlxText(0, 0, mainTextbox.boxWidth * mainTextbox.boxInterval, "");
		mainTextboxText.setFormat(Paths.font('poketext.ttf'), 8, FlxColor.BLACK, FlxTextAlign.LEFT);
		mainTextboxText.antialiasing = false;
		shopGroup.add(mainTextboxText);

		if (!playIntro)
			changeShopDialogue();

		subTextbox = new Textbox(0, 0);
		subTextbox.scale.set(3, 3);
		subTextbox.boxWidth = 5;
		subTextbox.boxHeight = 6;
		subTextbox.setPosition((FlxG.width * (4 / 5) - ((subTextbox.boxWidth - 4) * subTextbox.boxInterval * subTextbox.scale.x) / 4) + 24,
			FlxG.height - ((FlxG.height / 12) + 64));
		shopGroup.add(subTextbox);

		subTextboxTextGroup = new FlxTypedSpriteGroup<FlxText>();
		for (i in selectionArray)
		{
			var subTextboxText:FlxText = new FlxText(0, 0, subTextbox.boxWidth * subTextbox.boxInterval, i);
			subTextboxText.setFormat(Paths.font('poketext.ttf'), 8, FlxColor.BLACK, FlxTextAlign.LEFT);
			subTextboxText.antialiasing = false;
			subTextboxTextGroup.add(subTextboxText);
		}
		shopGroup.add(subTextboxTextGroup);

		// SHOP SELECTOR (Main)
		shopSelector = new FlxSprite(966, 524).loadGraphic(Paths.image('UI/pixel/selector'));
		shopGroup.add(shopSelector);
		shopSelector.setGraphicSize(Std.int(shopSelector.width * 3));
		shopSelector.updateHitbox();
		shopSelector.antialiasing = false;

		// SHOP BOX
		shopItemsBox = new FlxSprite(647, 116).loadGraphic(Paths.image('menus/shop/selectionBox'));
		shopGroup.add(shopItemsBox);
		shopItemsBox.alpha = 0.0001;
		shopItemsBox.updateHitbox();
		shopItemsBox.antialiasing = true;

		// SHOP ITEMS
		itemSprites = new FlxTypedSpriteGroup<FlxSprite>();
		shopGroup.add(itemSprites);

		// SHOP PRICE TEXTS
		itemPrices = new FlxTypedSpriteGroup<FlxText>();
		shopGroup.add(itemPrices);

		// my DUMBASS doesnt know how to sort arrays. so i just put a number in the folder name first if somebody can help that woud be awesome im so sorry - sector : - (

		for (i in folderList)
		{
			trace('found folder: ' + i);
			if (FileSystem.exists(Paths.getPath('images/shop/${i}/${i}.json', TEXT)))
			{
				var rawJson = File.getContent(Paths.getPath('images/shop/${i}/${i}.json', TEXT));
				var swagShit:ShopItem = cast Json.parse(rawJson).itemDetail;
				itemArray.push(swagShit);

				trace('images/shop/${i}/item');

				// le sprite
				var shopItem:FlxSprite = new FlxSprite(647, 116);
				shopItem.frames = Paths.getSparrowAtlas('shop/${i}/item');
				shopItem.animation.addByPrefix('idle', itemArray[itemsCreated].animName, 24, true);
				shopItem.animation.play('idle');
				shopItem.x = 682 + (itemArray[itemsCreated].lane * 190);
				shopItem.y = 135 + (itemArray[itemsCreated].row * 145);
				shopItem.x += itemArray[itemsCreated].xOffset;
				shopItem.y += itemArray[itemsCreated].yOffset;
				shopItem.antialiasing = true;
				shopItem.ID = itemArray[itemsCreated].lane + (itemArray[itemsCreated].row * 3);
				shopItem.setGraphicSize(Std.int(shopItem.width * itemArray[itemsCreated].scale));
				shopItem.antialiasing = true;
				shopItem.alpha = 0.0001;
				itemSprites.add(shopItem);

				if (FlxG.save.data.itemsPurchased.contains(itemArray[itemsCreated].name))
					shopItem.color = FlxColor.GRAY;

				// shop
				var shopItemPriceText:FlxText = new FlxText(650, 116, 100);
				shopItemPriceText.setFormat(Paths.font("poke.ttf"), 32, FlxColor.WHITE, "center");
				shopItemPriceText.text = '' + itemArray[itemsCreated].price;
				shopItemPriceText.x = 695 + (itemArray[itemsCreated].lane * 182);
				shopItemPriceText.y = 238 + (itemArray[itemsCreated].row * 140);
				shopItemPriceText.ID = itemArray[itemsCreated].lane + (itemArray[itemsCreated].row * 3);
				shopItemPriceText.alpha = 0.0001;

				itemPrices.add(shopItemPriceText);

				if (FlxG.save.data.itemsPurchased.contains(itemArray[itemsCreated].name))
				{
					shopItemPriceText.color = FlxColor.GRAY;
					shopItemPriceText.text = 'OWNED';
				}

				itemsCreated += 1;
			}
		}

		if (FlxG.save.data.buyVinylFirstTime && !FlxG.save.data.itemsPurchased.contains(itemArray[8].name))
		{
			itemPrices.forEach(function(text:FlxText)
			{
				if (text.ID == 8)
				{
					itemArray[8].price = 450;
					text.text = '450';
				}
			});
		}

		// SHOP CURSOR (ITEM BOX)
		shopHand = new FlxSprite(647, 116);
		shopHand.frames = Paths.getSparrowAtlas('menus/shop/ShopCursor');
		shopHand.animation.addByPrefix('idle', 'ShopCursor instance 1', 24, true);
		shopHand.animation.play('idle');
		shopHand.setGraphicSize(Std.int(shopHand.width * 0.75));
		shopHand.antialiasing = true;
		shopHand.alpha = 0.0001;
		shopGroup.add(shopHand);

		// SHOP CURRENCY ICON
		shopCurrencyIcon = new FlxSprite(800, -10);
		shopCurrencyIcon.frames = Paths.getSparrowAtlas('menus/shop/PokeDollarSign');
		shopCurrencyIcon.animation.addByPrefix('idle', 'PokeDollarSign instance 1', 24, true);
		shopCurrencyIcon.animation.play('idle');
		shopCurrencyIcon.setGraphicSize(Std.int(shopCurrencyIcon.width * 0.6));
		shopCurrencyIcon.antialiasing = true;
		shopGroup.add(shopCurrencyIcon);

		// SHOP ITEM NAME (am i gonna use this idk maybe)
		shopItemName = new Alphabet(25, 80, '', true, false, true);
		shopItemName.controllable = true;
		shopGroup.add(shopItemName);

		// SHOP COUNTER
		currencyText = new FlxText(880, 23, 500, '', 42);
		currencyText.setFormat(Paths.font("poketext.ttf"), 42, FlxColor.BLACK, LEFT);
		currencyText.antialiasing = true;
		shopGroup.add(currencyText);
		currencyText.text = FlxG.save.data.money;

		// create freeplay header
		freeplayHeader = new Alphabet(0, 0, 'Freeplay', true, false, false);
		freeplayHeader.controllable = true;
		freeplayHeader.setPosition(Std.int(FlxG.width / 2 - freeplayHeader.width / 2), 16);

		freeplayBlankPortrait = new FreeplayPortrait();
		freeplayBlankPortrait.loadNewPortrait('blank', Paths.getSparrowAtlas('menus/freeplay/blank'));
		freeplayActivePortrait = new FreeplayPortrait();
		freeplayActivePortrait.loadNewPortrait('unknown', Paths.getSparrowAtlas('menus/freeplay/unknown'));
		freeplayActivePortrait.alpha = 0;

		var rightPointer:FlxSprite = new FlxSprite();
		rightPointer.frames = Paths.getSparrowAtlas('menus/menu/campaign_menu_UI_assets');
		rightPointer.animation.addByPrefix('idle', 'arrow push right', 0, false);
        rightPointer.animation.play('idle');
        rightPointer.animation.curAnim.curFrame = 1;
        rightPointer.y = FlxG.height / 2 - rightPointer.height / 2;
		rightPointer.x = FlxG.width - 64 - rightPointer.width;
		shopGroup.add(rightPointer);

		var leftPointer:FlxSprite = new FlxSprite();
		leftPointer.frames = Paths.getSparrowAtlas('menus/menu/campaign_menu_UI_assets');
		leftPointer.animation.addByPrefix('idle', 'arrow push left', 0, false);
		leftPointer.animation.play('idle');
		leftPointer.animation.curAnim.curFrame = 1;
		leftPointer.y = FlxG.height / 2 - leftPointer.height / 2;
		leftPointer.x = 64;
		freeplayGroup.add(leftPointer);

		for (i in 0...Main.gameWeeks.length)
		{
			for (j in Main.gameWeeks[i])
			{
				addToFreeplayList(j);
				existingSongs.push(j.toLowerCase());
			}
		}
		var folderSongs:Array<String> = CoolUtil.returnAssetsLibrary('songs', 'assets');
		for (i in folderSongs)
		{
			if (!existingSongs.contains(i.toLowerCase()))
				addToFreeplayList(i);
		}
		// addToFreeplayList('missingcraft', 'shitpost');

		grpSongs = new FlxTypedSpriteGroup<Alphabet>();
		grpLocked = new FlxTypedSpriteGroup<LockSprite>();

		limiter = 0;
		for (i in 0...songs.length)
		{
			if (!songs[i].old)
			{
				var songText:Alphabet;
				var displayName:String = songs[i].songName;
				if (!FlxG.save.data.playedSongs.contains(CoolUtil.spaceToDash(songs[i].songName.toLowerCase())))
				{
					var stringArray:Array<String> = displayName.split('');
					displayName = '';
					for (j in stringArray)
					{
						if (j == '-')
							displayName += '-';
						else
							displayName += '?';
					}
				}

				songText = new Alphabet(0, (70 * i) + 30, displayName, true, false, false);
				songText.textIdentifier = limiter;
				for (j in songText.members)
					j.alpha = 0;

				// songText.controllable = true;
				grpSongs.add(songText);

				// create lock sprite lol
				var lockSprite:LockSprite = new LockSprite();
				lockSprite.lockIdentifier = limiter;
				
				if (!FlxG.save.data.unlockedSongs.contains(CoolUtil.spaceToDash(songs[i].songName.toLowerCase())))
					lockSprite.locked = true;
				else { 
					lockSprite.locked = false;
					lockSprite.alpha = 0;
				}
				grpLocked.add(lockSprite);
				limiter++;
			}
		}
		freeplayGroup.add(grpSongs);
		freeplayGroup.add(grpLocked);

		freeplayBG = new FlxSprite().loadGraphic(backgroundHeader.graphic);
		freeplayBG.scrollFactor.set(0, 0);
		freeplayGroup.add(freeplayBG);

		freeplayGroup.add(freeplayHeader);
		freeplayGroup.add(freeplayBlankPortrait);
		freeplayGroup.add(freeplayActivePortrait);

		add(shopGroup);
		add(freeplayGroup);

		if (playIntro)
		{
			// INTRODUCTION STATIC
			staticIntro = new FlxSprite(0, 0);
			staticIntro.frames = Paths.getSparrowAtlas('menus/shop/static');
			staticIntro.animation.addByPrefix('idle', 'static', 24, true);
			staticIntro.animation.play('idle');
			staticIntro.setGraphicSize(Std.int(staticIntro.width * 2.0));
			staticIntro.antialiasing = true;
			staticIntro.alpha = 0.0001;
			add(staticIntro);
			staticIntro.screenCenter();

			canControl = false;
			inCutscene = true;

			shopGroup.forEach(function(object:FlxObject)
			{
				object.visible = false;
			});

			freeplayGroup.forEach(function(object:FlxObject)
			{
				object.visible = false;
			});

			backgroundHeader.visible = false;
			FlxTween.tween(cartridgeIntro, {alpha: 1.0}, 1.5, {ease: FlxEase.quadOut});

			new FlxTimer().start(5.5, function(tmr:FlxTimer)
			{
				staticIntro.alpha = 1.0;

				new FlxTimer().start(0.25, function(tmr:FlxTimer)
				{
					staticIntro.alpha = 0.0;
					playIntro = false;
					canControl = true;
					inCutscene = false;
					FlxTween.tween(staticIntro, {alpha: 0.0}, 1.5, {ease: FlxEase.quadIn});
					cartridgeIntro.visible = false;

					shopGroup.forEach(function(object:FlxObject)
					{
						object.visible = true;
					});
					freeplayGroup.forEach(function(object:FlxObject)
					{
						object.visible = true;
					});

					backgroundHeader.visible = true;

					FlxG.sound.playMusic(Paths.music('FreeplayMenu'), 0, true);
					FlxG.sound.music.fadeIn(0.5, 0, 1);
					shopSign.animation.play('signThing');
					shuffleCartridgeIdle(true);
					cartridgePlayIdle(true);
					changeShopDialogue();
				});

				/*FlxTween.tween(staticIntro, {alpha: 1.0}, 3.0, {ease: FlxEase.quadIn, onComplete: function(twn:FlxTween) {
						playIntro = false;
						canControl = true; 
						FlxTween.tween(staticIntro, {alpha: 0.0}, 1.5, {ease: FlxEase.quadIn});
						cartridgeIntro.visible = false;

						shopGroup.forEach(function(object:FlxObject) 
							{
								object.visible = true;
							});
						freeplayGroup.forEach(function(object:FlxObject) 
							{
								object.visible = true;
							});

						backgroundHeader.visible = true;

						FlxG.sound.playMusic(Paths.music('FreeplayMenu'), 0, true);
						FlxG.sound.music.fadeIn(0.5, 0, 1);
						shopSign.animation.play('signThing');
						shuffleCartridgeIdle(true);
						cartridgePlayIdle(true);
						changeShopDialogue();
					}});
				 */
			});
		}

		menuDisplacement = FlxG.width * (freeplaySelected ? -1 : 0);

		var portraitText:String = '';
		
		if (FlxG.save.data.playedSongs.contains(CoolUtil.spaceToDash(songs[verticalSelection].songName.toLowerCase())))
			portraitText = grpSongs.members[verticalSelection].text;
		else
			portraitText = 'unknown';
		switchPortrait(portraitText);

		CoolUtil.lerpSnap = true;
	}

	function addToFreeplayList(i:String, ?library:String)
	{
		for (j in 0...2)
		{
			var old:Bool = j == 0 ? true : false;
			var icon:String = 'gf';
			var chartExists:Bool = FileSystem.exists(Paths.songJson(i, i + '-hard', old, library));
			if (library != null)
				chartExists = openfl.utils.Assets.exists(Paths.songJson(i, i + '-hard', old, library), TEXT);
			if (chartExists)
			{
				var castSong:SwagSong = Song.loadFromJson(i + '-hard', i, library, old);
				icon = (castSong != null) ? castSong.player2 : 'gf';
				addSong(CoolUtil.spaceToDash(castSong.song), 1, (i == 'pasta-night') ? 'hypno-cards' : icon, library, old, FlxColor.WHITE);
			}
		}
	}

	function changeShopDialogue(?dialouge:String)
	{
		if (!inCutscene)
		{
			if (inShop)
			{
				chordProgression = 0;
				if (dialouge != null)
					currentShopDialogue = dialouge;
				else
					currentShopDialogue = itemArray[curItemSelected].songDescription;
			}
			else
			{
				if (lastShopDialogue.length == shopLines.idleLines.length)
					lastShopDialogue = [];
				var randomizeDialogue:Int = FlxG.random.int(0, shopLines.idleLines.length - 1, lastShopDialogue);
				chordProgression = 0;
				currentShopDialogue = shopLines.idleLines[randomizeDialogue];

				if (dialouge != null)
					currentShopDialogue = dialouge;

				lastShopDialogue.push(randomizeDialogue);
				timeToChange += 10 * 60;
			}
		}
	}

	function scroll(event:MouseEvent)
	{
		if (freeplaySelected && canControl)
			updateVerticalSelection(verticalSelection - event.delta, grpSongs.members.length - 1);
	}

	function onMouseDown(event:MouseEvent)
	{
		if (freeplaySelected && canControl)
		{
			canControl = false;
			for (j in grpSongs)
			{
				if (j.textIdentifier == verticalSelection)
				{
					selectedItem = j;
					break;
				}
			}
			if (selectedItem != null)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));
				FlxFlicker.flicker(selectedItem, 0.85, 0.06 * 2, true, false, function(flick:FlxFlicker)
				{
					zoomIn = true;
				});
			}
		}
	}

	public var limiter:Int = 0;

	public var menuDisplacement:Float = 0;

	public static var freeplaySelected:Bool = false;

	public var previousX:Map<FlxObject, Float> = [];

	public var moverCooldown:Float = 0;

	public static var verticalSelection:Int = 0;

	public var elapsedTotal:Float = 0;
	public var candleTime:Float = 0;
	public var prevY:Float = 0;

	public var freeplayBlankPortrait:FreeplayPortrait;
	public var glitchingno:FlxGraphicsShader;
	public var chromaticAberration:ShaderFilter;

	public var aberrateValue:Float = 0;
	public var glitchValue:Float = 0;
	public var aberrateTimeValue:Float = 0.05;

	public var topBarDisplacement:Float = 0;

	public var chordProgression:Int = 0;
	public var textCooldown:Int = 0;
	public var timeToChange:Float = 0;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (Main.hypnoDebug && FlxG.keys.justPressed.SEVEN) // DEBUG GIVES MONEY
		{
			FlxG.save.data.money = 9999;
		}

		var fakeElapsed:Float = CoolUtil.clamp(elapsed, 0, 1);
		// menu switching
		var left = controls.UI_LEFT_P;
		var right = controls.UI_RIGHT_P;
		if (canControl)
		{
			if (left && freeplaySelected)
			{
				freeplaySelected = false;
				Discord.changePresence('BROWSING THE SHOP', 'Freeplay Menu');
				shopSign.animation.play('signThing', true);
				shuffleCartridgeIdle(true);
				cartridgePlayIdle(true);
			}
			if (right && !freeplaySelected)
			{
				Discord.changePresence('CHOOSING A SONG', 'Freeplay Menu');
				freeplaySelected = true;
			}
		}

		//
		if (fakeElapsed > 0)
		{
			menuDisplacement = FlxMath.lerp(menuDisplacement, FlxG.width * (freeplaySelected ? -1 : 0), fakeElapsed / (1 / 15));
			if (menuDisplacement > -0.5)
				menuDisplacement = 0;
			else if (menuDisplacement < -FlxG.width + 0.5)
				menuDisplacement = -FlxG.width;

			shopGroup.forEach(function(object:FlxObject)
			{
				if (!previousX.exists(object))
					previousX.set(object, object.x);
				object.x = previousX.get(object) + menuDisplacement;
				previousX.set(object, object.x - menuDisplacement);
			});
			freeplayGroup.forEach(function(object:FlxObject)
			{
				if (!previousX.exists(object))
					previousX.set(object, object.x);
				object.x = previousX.get(object) + menuDisplacement + FlxG.width;
				previousX.set(object, object.x - menuDisplacement - FlxG.width);
			});

			// box thingy
			elapsedTotal += fakeElapsed;
			var formula:Float = Math.sin((180 / Math.PI) * ((elapsedTotal - (fakeElapsed * 120)) / 24)) / 12;
			prevY += freeplayBlankPortrait.y;
			freeplayBlankPortrait.y = prevY + formula;
			prevY -= freeplayBlankPortrait.y + formula;
			freeplayActivePortrait.y = freeplayBlankPortrait.y;
			if (!endingFreeplay)
				updatePortraits(fakeElapsed);
		}

		//
		for (i in 0...limiter + 1)
		{
			var item:Alphabet = null;
			var lock:LockSprite = null;
			// uhh lmao
			for (j in 0...grpSongs.members.length)
			{
				// it was worse before deal with it
				if (grpSongs.members[j].textIdentifier == i)
				{
					item = grpSongs.members[j];
					// get the lock (poorly but it works)
					lock = grpLocked.members[j];
					break;
				}
			}
			if (item != null)
			{
				item.targetY = (i - verticalSelection);
				item.zDepth = Math.abs(i - verticalSelection);
				// set up the general item values to be reused
				var scaledY = FlxMath.remapToRange(item.targetY, 0, 1, 0, 1.3);
				var dilationFactor:Float = (Math.abs(i - verticalSelection) + 1) / 2;
				var itemScale:Float = ((i == verticalSelection) ? 1 : (0.95 / dilationFactor));
				var yPosition:Float = (scaledY * (120 / dilationFactor)) + (FlxG.height * 0.48);
				var itemAlpha:Float = (freeplaySelected ? ((i == verticalSelection) ? 1 : 0.75 - (item.zDepth / 5)) : 0);
				//
				for (j in 0...item.members.length)
				{
					item.members[j].scale.x = CoolUtil.fakeLerp(item.members[j].scale.x, itemScale, fakeElapsed / (1 / 15));
					item.members[j].scale.y = CoolUtil.fakeLerp(item.members[j].scale.y, itemScale, fakeElapsed / (1 / 15));
					if (!endingFreeplay)
					{
						var placementX:Float = (FlxG.width * (2 / 3));
						// am I doing this right
						var xPosition:Float = (placementX
							- (item.members[j].scale.x / 2) * (item.members.length + 1) * 40)
							+ (item.members[j].posX * item.members[j].scale.x);
						item.members[j].y = CoolUtil.fakeLerp(item.members[j].y, yPosition, fakeElapsed / (1 / 15));
						//  item position
						var itemPosition:Float = (Math.abs(i - verticalSelection) * 15);
						if (!previousX.exists(item.members[j]))
							previousX.set(item.members[j],
								Math.max(-placementX, CoolUtil.fakeLerp(previousX.get(item.members[j]), itemPosition, fakeElapsed / (1 / 15))));
						// item x
						item.members[j].x = menuDisplacement
							+ xPosition
							+ FlxG.width
							- previousX.get(item.members[j])
							+ ((item.members[j].offset.x * (1 / item.members[j].scale.x)) - item.members[j].offset.x);
						previousX.set(item.members[j],
							Math.max(-placementX, CoolUtil.fakeLerp(previousX.get(item.members[j]), itemPosition, fakeElapsed / (1 / 15))));

						item.members[j].alpha = CoolUtil.fakeLerp(item.members[j].alpha, itemAlpha, fakeElapsed / (1 / 15));
					}
					else
					{
						if (i == verticalSelection)
						{
							var newX:Float = (FlxG.width / 2)
								- ((item.members[item.members.length - 1].posX +
									item.members[item.members.length - 1].frameWidth) * item.members[j].scale.x) / 2;
							item.members[j].x = FlxMath.lerp(item.members[j].x, newX + (item.members[j].posX), fakeElapsed / (1 / 15));
							item.members[j].y = FlxMath.lerp(item.members[j].y, yPosition, fakeElapsed / (1 / 15));
						}
					}
					item.members[j].displacementFormula();
				}

				if (lock != null)
				{
					lock.zDepth = item.zDepth;
					lock.scale.set(item.members[0].scale.x, item.members[0].scale.y);
					// easier fix lol
					lock.x = (item.members[0].x
						+ ((item.members[item.members.length - 1].posX + item.members[item.members.length - 1].frameWidth) * lock.scale.x) / 2)
						- lock.width / 2;
					// yeah im stupid
					lock.y = (item.members[0].y) - (lock.height / 4);
					if (lock.animation.curAnim.name != 'unlock') {
						if (lock.locked)
							lock.alpha = item.members[0].alpha;
						else lock.alpha = 0;
					}
				}

				//
				switch (item.text.toLowerCase())
				{
					case 'missingno' | 'isotope':
						// trace('m,,issingno hveorv');
						for (j in item.members)
							if (j.shader != glitchingno)
								j.shader = glitchingno;
						glitchValue += (fakeElapsed / (1 / 15)) / 15;
						glitchingno.data.prob.value = [0.25 + Math.abs(Math.sin((fakeElapsed * 2) * Math.PI))];
						glitchingno.data.time.value = [glitchValue / 2];

					// freeplayActivePortrait.shader = glitchingno;
					default:
						for (j in item.members)
							if (j.shader != null)
								j.shader = null;
				}

				// icon shit
				/*
					var icon = iconArray[i];
					icon.angle = CoolUtil.fakeLerp(icon.angle, item.angleTo, elapsedTime);
					var myAngle:Float = flixel.math.FlxAngle.asRadians(icon.angle);
					var psuedoX:Float = -(icon.width + 12);
					var psuedoY:Float = -(icon.height / 3);
					icon.y = item.members[0].y + (Math.sin(myAngle) * psuedoX) + (Math.cos(myAngle) * psuedoY);
					icon.x = item.members[0].x + (Math.cos(myAngle) * psuedoX) + (Math.sin(myAngle) * psuedoY);
				 */
			}
		}
		grpSongs.sort(depthSorting, FlxSort.DESCENDING);
		grpLocked.sort(lockSorting, FlxSort.DESCENDING);

		if (freeplaySelected)
		{
			if (canControl)
			{
				// controls
				var newSelection:Int = verticalSelection;
				var up = controls.UI_UP;
				var down = controls.UI_DOWN;
				// direction up
				var directionUp:Int = (up ? -1 : 0) + (down ? 1 : 0);
				if (Math.abs(directionUp) > 0)
				{
					if (moverCooldown <= 0)
					{
						newSelection += directionUp;
						moverCooldown += FlxG.updateFramerate / 4;
					}
					else
						moverCooldown--;
				}
				else
					moverCooldown = 0;
				updateVerticalSelection(newSelection, grpSongs.members.length - 1);
				
				if (controls.ACCEPT)
				{
					if (FlxG.save.data.unlockedSongs.contains(songs[verticalSelection].songName.toLowerCase()))
					{
						canControl = false;
						endingFreeplay = true;

						for (j in grpSongs)
						{
							if (j.textIdentifier == verticalSelection)
							{
								selectedItem = j;
								break;
							}
						}
						FlxG.sound.play(Paths.sound('confirmMenu'));
						FlxFlicker.flicker(selectedItem, 0.85, 0.06 * 2, true, false, function(flick:FlxFlicker)
						{
							zoomIn = true;
						});
					}
					else
					{
						FlxG.sound.play(Paths.sound('errorMenu'));
						camera.shake(0.005, 0.06);

						// auto unlock 
						/*
						if (Main.hypnoDebug) {
							var selectedLock:LockSprite = null;
							for (j in grpLocked)
							{
								if (j.lockIdentifier == verticalSelection)
								{
									selectedLock = j;
									break;
								}
							}
							if (selectedLock != null)
								selectedLock.unlock();
						}*/
					}
				}
			}
			else if (!canControl)
			{
				if (endingFreeplay) {
					killThread = true;
					var realElapsed:Float = (fakeElapsed / (1 / 60));
					freeplayBlankPortrait.alpha = FlxMath.lerp(freeplayBlankPortrait.alpha, 0, realElapsed / 6);
					freeplayActivePortrait.alpha = FlxMath.lerp(freeplayActivePortrait.alpha, 0, realElapsed / 6);
					for (i in grpSongs)
					{
						if (i != selectedItem)
						{
							for (j in i.members)
								j.alpha = FlxMath.lerp(j.alpha, 0, realElapsed / 6);
						}
					}

					//
					if (zoomIn)
					{
						if (chromaticAberration != null)
						{
							if (aberrateTimeValue < 1.35)
							{
								aberrateValue += (fakeElapsed / (1 / 15)) * (speed * 1.12);
								aberrateTimeValue += (fakeElapsed / (1 / 15)) * speed;
								speed += 0.0003125 * (fakeElapsed / (1 / 160));
								chromaticAberration.shader.data.aberration.value = [aberrateValue];
								chromaticAberration.shader.data.effectTime.value = [aberrateTimeValue];
							}
							if (aberrateTimeValue > 1)
							{
								selectedItem.alpha = FlxMath.lerp(selectedItem.alpha, 0, realElapsed);
								if (selectedItem.alpha <= 0.01)
									gotoSong();
							}
						}
					}
				}
				//
			}
		}
		else
		{
			// text writing logic bullSHEEET
			if (chordProgression < currentShopDialogue.length - 1)
			{
				mainTextboxText.text = currentShopDialogue.substring(0, chordProgression);
				if (textCooldown <= 0)
				{
					chordProgression++;
					if (!CoolUtil.lerpSnap && !inCutscene)
						FlxG.sound.play(Paths.sound('cartridgeGuy'), 0.1);
					textCooldown += Std.int(FlxG.updateFramerate / 16);
				}
				else
					textCooldown--;
			}
			else
			{
				mainTextboxText.text = currentShopDialogue;
				if (!inShop)
					timeToChange -= (elapsed / (1 / 60));
				if (timeToChange <= 0 && !playIntro)
					changeShopDialogue();
			}

			mainTextboxText.scale.set(mainTextbox.scale.x, mainTextbox.scale.y);
			mainTextboxText.setPosition(mainTextbox.x
				- ((mainTextbox.scale.x * (mainTextbox.boxWidth * mainTextbox.boxInterval)) / 2)
				+ 9
				+ mainTextboxText.width,
				mainTextbox.y
				- ((mainTextbox.scale.y * (mainTextbox.boxHeight * mainTextbox.boxInterval)) / 2)
				+ mainTextboxText.height);

			for (i in 0...subTextboxTextGroup.members.length)
			{
				var text:FlxText = subTextboxTextGroup.members[i];
				text.scale.set(subTextbox.scale.x, subTextbox.scale.y);
				text.setPosition(subTextbox.x
					- ((subTextbox.scale.x * (subTextbox.boxWidth * mainTextbox.boxInterval)) / 2)
					+ mainTextbox.boxInterval
					+ text.width,
					subTextbox.y
					- ((subTextbox.scale.y * (subTextbox.boxHeight * mainTextbox.boxInterval)) / 2)
					+ text.height
					+ (i * mainTextbox.boxInterval * text.scale.y));
			}

			candleTime += 180 * (fakeElapsed / 4);
			candleSine = 1 + (Math.sin((Math.PI * candleTime) / 180) / 3);
			cartridgeLight.scale.set(candleSine, candleSine);

			var up = controls.UI_UP_P;
			var down = controls.UI_DOWN_P;
			var accept = controls.ACCEPT;

			if (inShop)
			{
				if (!inCutscene)
				{
					if (left)
						switchShopSel(-1, true);
					else if (right)
						switchShopSel(1, true);
					else if (down)
						switchShopSel(3, true);
					else if (up)
						switchShopSel(-3, true);
					else if (accept)
						purchaseItem();
				}
			}
			else if (!inShop)
			{
				if (!inCutscene)
				{
					if (up)
						switchShopSel(-1);
					else if (down)
						switchShopSel(1);
					else if (accept)
					{
						FlxG.sound.play(Paths.sound('confirmMenu'));

						switch (shopSelection)
						{
							case 0:
								{
									inShop = true;
									switchSubmenus();
								}
							case 1:
								{
									if (FlxG.save.data.itemsPurchased.length == 0) changeShopDialogue('Sell? You literally have nothing on you, what the hell is wrong with your brain.');
									else if (FlxG.save.data.itemsPurchased.length > 0) changeShopDialogue("Why would I buy your shit back, I'm trying to get rid of it you moron.");
								
								}
							case 2:
								{
									killThread = true;
									Main.switchState(this, new MainMenuState());
								}
						}
					}
				}
			}
		}

		if (controls.BACK && !inCutscene && !endingFreeplay)
		{
			if (inShop)
			{
				inShop = false;
				switchSubmenus();
			}
			else
			{
				killThread = true;
				Main.switchState(this, new MainMenuState());
			}
		}

		if (inShop)
		{
			shopHand.x = 425 + ((curItemSelected % 3) * 200);
			shopHand.y = 100 + (itemArray[curItemSelected].row * 128);
		}

		// update song stuff
		Conductor.songPosition += elapsed * 1000;
		if (FlxG.sound.music != null && Math.abs(FlxG.sound.music.time - Conductor.songPosition) > 20)
			Conductor.songPosition = FlxG.sound.music.time;
		CoolUtil.lerpSnap = false;
	}

	function purchaseItem()
	{
		if (!confirmingPurchase
			&& !FlxG.save.data.itemsPurchased.contains(itemArray[curItemSelected].name)
			&& FlxG.save.data.money >= itemArray[curItemSelected].price)
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));
			confirmingPurchase = true;
			changeShopDialogue();

			itemPrices.forEach(function(text:FlxText)
			{
				if (text.ID == (curItemSelected))
				{
					text.text = 'CONFIRM?';
				}
			});

			return;
		}
		if (!FlxG.save.data.itemsPurchased.contains(itemArray[curItemSelected].name)
			&& FlxG.save.data.money >= itemArray[curItemSelected].price)
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));
			FlxG.save.data.money -= itemArray[curItemSelected].price;
			if (!FlxG.save.data.itemsPurchased.contains(itemArray[curItemSelected].name)
				&& itemArray[curItemSelected].name != 'Broken Vinyl')
				FlxG.save.data.itemsPurchased.push(itemArray[curItemSelected].name);
			currencyText.text = FlxG.save.data.money;

			itemSprites.forEach(function(spr:FlxSprite)
			{
				if (spr.ID == (curItemSelected))
				{
					spr.color = FlxColor.GRAY;
				}
			});

			itemPrices.forEach(function(text:FlxText)
			{
				if (text.ID == (curItemSelected))
				{
					text.color = FlxColor.GRAY;
					text.text = 'OWNED';
				}
			});

			switch (itemArray[curItemSelected].name)
			{
				default:
					unlockSongCutscene(itemArray[curItemSelected].songUnlock);
				case 'Pokemon Silver':
					{
						if (!FlxG.save.data.cartridgesOwned.contains('LostSilverWeek'))
							FlxG.save.data.cartridgesOwned.push('LostSilverWeek');
					}
				case 'Broken Vinyl':
					{
						if (!FlxG.save.data.buyVinylFirstTime)
							FlxG.save.data.buyVinylFirstTime = true;
						vinylCutscene();
					}
			}

			changeShopDialogue('What do you want?');
			confirmingPurchase = false;
		}
		else
		{
			FlxG.sound.play(Paths.sound('errorMenu'));
			camera.shake(0.005, 0.06);
		}
	}

	function vinylCutscene()
	{
		canControl = false;
		inCutscene = true;
		backgroundHeader.visible = false;
		shopGroup.forEach(function(object:FlxObject)
		{
			object.visible = false;
		});

		freeplayGroup.forEach(function(object:FlxObject)
		{
			object.visible = false;
		});

		gameBoy = new FlxAnimate(225, 0, Paths.getPath('images/menus/shop/gameboy', TEXT));
		gameBoy.anim.addByAnimIndices('idle', [
			0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 14, 14, 14, 14, 14, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38,
			39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74,
			75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108,
			109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137,
			138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166,
			167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195,
			196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214
		], 24);
		gameBoy.setGraphicSize(Std.int(gameBoy.width * 5.0));
		gameBoy.antialiasing = true;
		add(gameBoy);
		FlxG.sound.play(Paths.sound('gameBoyAnim'));
		gameBoy.anim.play('idle');

		blackOverlay = new FlxSprite(0, 0).makeGraphic(FlxG.width * 4, FlxG.height * 4, FlxColor.BLACK);
		blackOverlay.alpha = 0.0001;
		add(blackOverlay);

		FlxG.sound.music.fadeOut(0.75, 0.0);

		new FlxTimer().start(8.0, function(tmr:FlxTimer)
		{
			PlayState.isStoryMode = true;
			PlayState.storyPlaylist = ['shinto', 'shitno'];
			PlayState.storyDifficulty = 2;
			var poop:String = Highscore.formatSong('shinto', PlayState.storyDifficulty);
			PlayState.SONG = Song.loadFromJson(poop, 'shinto', null, false);

			FlxTween.tween(blackOverlay, {alpha: 1.0}, 4.0, {ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween)
			{
				Main.switchState(this, new PlayState());
			}});
		});
	}

	function startSong(songName:String)
	{
		PlayState.storyDifficulty = 2;
		var poop:String = Highscore.formatSong(songName.toLowerCase(), PlayState.storyDifficulty);
		PlayState.SONG = Song.loadFromJson(poop, songName.toLowerCase(), null, false);
		PlayState.isStoryMode = false;

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		Main.switchState(this, new PlayState());
	}

	function unlockSongCutscene(?songUnlock:String = '') {
		inShop = false;
		switchSubmenus();
		inCutscene = true;
		canControl = false;

		new FlxTimer().start(0.25, function(tmr:FlxTimer){
			var mySong:String = CoolUtil.spaceToDash(songUnlock.toLowerCase());
			if (!FlxG.save.data.unlockedSongs.contains(mySong))
				FlxG.save.data.unlockedSongs.push(mySong);
			FlxG.save.flush();

			freeplaySelected = true;
			new FlxTimer().start(0.5, function(tmr:FlxTimer){
				var selectionTo:Int = 0;
				for (i in 0...songs.length) {
					if (mySong.contains(CoolUtil.spaceToDash(songs[i].songName.toLowerCase()))) 
						selectionTo = i;
				}

				var curSelection = verticalSelection;
				var selectionTimer:FlxTimer = new FlxTimer();
				selectionTimer.start(0.1, function(tmr:FlxTimer){
					if (verticalSelection > selectionTo)
						curSelection--;
					else if (verticalSelection < selectionTo)
						curSelection++;
					else {
						new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							var selectedLock:LockSprite = null;
							for (j in grpLocked)
							{
								if (j.lockIdentifier == verticalSelection)
								{
									selectedLock = j;
									break;
								}
							}
							if (selectedLock != null)
							{
								selectedLock.unlock();
								// I like the sound
								FlxG.sound.play(Paths.sound('errorMenu'));
							}

							new FlxTimer().start(1, function(tmr:FlxTimer)
							{
								inCutscene = false;
								canControl = true;
							});
						});
						selectionTimer.active = false;
						return;
					}
					updateVerticalSelection(curSelection, grpSongs.members.length - 1);
				}, Std.int(Math.abs(verticalSelection - selectionTo)) + 1);
				
			});
		});
	}

	function switchShopSel(amount:Int, ?subMenu:Bool = false)
	{
		if (subMenu)
			curItemSelected += amount;
		else
			shopSelection += amount;
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.5);

		if (subMenu) // ITEM MENU
		{
			if (curItemSelected < 0)
			{
				curItemSelected = itemsCreated - 1;
			}
			else if (curItemSelected >= itemsCreated)
			{
				curItemSelected = 0;
			}

			if (currentShopDialogue != 'What do you want?')
				changeShopDialogue('What do you want?');

			var postPurchasePrice:Int = Std.int(FlxG.save.data.money - itemArray[curItemSelected].price);

			currencyText.text = FlxG.save.data.money + " > " + postPurchasePrice;

			if (postPurchasePrice < 0)
				currencyText.color = FlxColor.RED;
			else
				currencyText.color = FlxColor.BLACK;

			if (FlxG.save.data.itemsPurchased.contains(itemArray[curItemSelected].name))
			{
				currencyText.text = FlxG.save.data.money;
				currencyText.color = FlxColor.BLACK;
			}

			itemPrices.forEach(function(text:FlxText)
			{
				if (text.text == 'CONFIRM?')
				{
					text.text = '' + itemArray[text.ID].price;
				}
			});
			confirmingPurchase = false;

			/*if (shopItemName != null)
				{
					shopItemName.destroyText();
					shopItemName.startText(itemArray[curItemSelected].name, false);
				}
			 */
		}
		else if (!subMenu) // SELECTION MENU
		{
			if (shopSelection < 0)
			{
				shopSelection = selectionArray.length - 1;
			}
			else if (shopSelection >= selectionArray.length)
			{
				shopSelection = 0;
			}

			currencyText.text = FlxG.save.data.money;
			currencyText.color = FlxColor.BLACK;
		}

		if (subMenu) // ITEM MENU
		{
			itemSprites.forEach(function(spr:FlxSprite)
			{
				spr.alpha = 0.5;
				if (spr.ID == (curItemSelected))
				{
					spr.alpha = 1.0;
				}
			});

			itemPrices.forEach(function(text:FlxText)
			{
				text.alpha = 0.5;
				if (text.ID == (curItemSelected))
				{
					text.alpha = 1.0;
				}
			});
		}
		else if (!subMenu)
		{
			shopSelector.y = 524 + (shopSelection * 27);
			trace(shopSelection);
		}
	}

	function switchSubmenus()
	{
		if (inShop)
		{
			canControl = false;
			shopItemsBox.alpha = 1.0;

			itemSprites.forEach(function(spr:FlxSprite)
			{
				spr.alpha = 0.5;
				if (spr.ID == (curItemSelected))
				{
					spr.alpha = 1.0;
				}
			});

			itemPrices.forEach(function(text:FlxText)
			{
				text.alpha = 0.5;
				if (text.ID == (curItemSelected))
				{
					text.alpha = 1.0;
				}
			});

			shopHand.alpha = 1.0;

			switchShopSel(0, true);
		}
		else
		{
			canControl = true;
			shopItemsBox.alpha = 0.0;

			itemSprites.forEach(function(spr:FlxSprite)
			{
				spr.alpha = 0.0;
			});

			itemPrices.forEach(function(text:FlxText)
			{
				text.alpha = 0.0;
			});

			shopHand.alpha = 0.0;

			timeToChange = 0.0;
			changeShopDialogue();
			switchShopSel(0);
		}
	}

	public var cartridgeIdle:Int = -1;
	public var animationCycle:Int = 0;
	public var animationCycleAmount:Int = 0;

	override function beatHit()
	{
		super.beatHit();
		if (!freeplaySelected)
		{
			if (curBeat % 2 == 0)
				cartridgePlayIdle();
		}
	}

	function cartridgePlayIdle(?ignoreFinished:Bool = false)
	{
		if (cartridgeGuy.animation.finished || ignoreFinished)
		{
			cartridgeGuy.animation.play('idle-$cartridgeIdle', true);
			animationCycle++;
			if (animationCycle > animationCycleAmount)
			{
				cartridgeGuy.animation.play('idle-$cartridgeIdle-alt', true);
				shuffleCartridgeIdle();
			}
		}
	}

	var idleAmount:Int = 3;

	function shuffleCartridgeIdle(?newIdle:Bool = false)
	{
		animationCycle = 0;
		animationCycleAmount = FlxG.random.int(3, 6);
		if (newIdle)
		{
			var newIdle:Int = FlxG.random.int(0, idleAmount - 1, [cartridgeIdle]);
			cartridgeIdle = newIdle;
		}
	}

	public var zoomIn:Bool = false;
	public var selectedItem:Alphabet = null;
	public var speed:Float = 0.055;

	public function gotoSong()
	{
		trace(verticalSelection);
		PlayState.storyDifficulty = 2;
		var poop:String = Highscore.formatSong(songs[verticalSelection].songName.toLowerCase(), PlayState.storyDifficulty);
		PlayState.SONG = Song.loadFromJson(poop, songs[verticalSelection].songName.toLowerCase(), songs[verticalSelection].library,
			songs[verticalSelection].old);
		PlayState.isStoryMode = false;

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		Main.switchState(this, new PlayState());
	}

	public var canControl:Bool = true;
	public var endingFreeplay:Bool = false;

	public var portraitThread:Thread;
	public var updateThread:Thread;
	public var switchingPortraits:Bool = false;
	public var portraitLoaded:Bool = false;
	public var switchBack:Bool = false;
	public var killThread:Bool = false;
	public var lastPortraits:Array<String> = [];
	public var curPortrait:String;

	public function switchPortrait(song:String)
	{
		if (portraitThread == null)
		{
			portraitThread = Thread.create(function()
			{
				while (true)
				{
					//
					if (!killThread)
					{
						var portrait:Null<String> = Thread.readMessage(false);

						if (portrait != null && portrait != curPortrait)
						{
							//  get the new portrait
							if (!FileSystem.exists(Paths.getPath('images/menus/freeplay/$portrait.png', IMAGE)))
								portrait = 'unknown';
							mutex.acquire();
							switchingPortraits = true;
							if (!lastPortraits.contains(curPortrait))
								lastPortraits.push(curPortrait);
							portraitGraphic = Paths.getSparrowAtlas('menus/freeplay/$portrait');
							portraitLoaded = true;
							curPortrait = portrait;
							mutex.release();
							trace('new graphic $portrait called lol');
						}
					}
					else
						return;
				}
			});
		}
		portraitThread.sendMessage(song);
	}

	public var freeplayActivePortrait:FreeplayPortrait;
	public var portraitGraphic:FlxAtlasFrames;
	public var activeAlpha:Float = 0;

	public function updatePortraits(elapsed:Float)
	{
		if (switchingPortraits && !switchBack)
		{
			activeAlpha = 0;
			if (freeplayActivePortrait.alpha <= 0.015)
			{
				if (portraitGraphic != null && portraitLoaded)
				{
					if (mutex.tryAcquire())
					{
						trace('changing portrait, last portraits; $lastPortraits');
						for (i in lastPortraits)
						{
							if (i != curPortrait)
							{
								dumpPortrait('menus/freeplay/$i');
								lastPortraits.splice(lastPortraits.indexOf(i), 1);
							}
						}
						freeplayActivePortrait.loadNewPortrait(curPortrait, portraitGraphic);
						activeAlpha = 1;
						portraitLoaded = false;
						switchingPortraits = false;
						mutex.release();
					}
				}
			}
		}
		if (freeplayActivePortrait.canExist)
			freeplayActivePortrait.alpha = FlxMath.lerp(freeplayActivePortrait.alpha, activeAlpha, (elapsed / (1 / 60)) * 0.25);
	}

	function dumpPortrait(key:String)
	{
		var obj = Paths.currentTrackedAssets.get(key);
		if (obj != null)
		{
			@:privateAccess
			if (openfl.Assets.cache.hasBitmapData(key))
			{
				openfl.Assets.cache.removeBitmapData(key);
				FlxG.bitmap._cache.remove(key);
			}
			trace('removed $key');
			obj.destroy();
			Paths.currentTrackedAssets.remove(key);
		}
	}

	function updateVerticalSelection(newSelection:Int, limiter:Int = 1)
	{
		if (newSelection < 0)
			newSelection = limiter;
		if (newSelection > limiter)
			newSelection = 0;
		if (verticalSelection != newSelection)
		{
			verticalSelection = newSelection;
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.5);
			// get the song
			var item:String = '';
			for (i in grpSongs)
			{
				if (i.textIdentifier == verticalSelection)
				{
					item = i.text;
					break;
				}
			}
			trace(item.toLowerCase());

			if (!FlxG.save.data.playedSongs.contains(CoolUtil.spaceToDash(songs[verticalSelection].songName.toLowerCase())))
				item = 'unknown'; 
			switchPortrait(item);
		}
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, library:String, old:Bool, songColor:FlxColor)
		songs.push(new SongMetadata(songName, weekNum, songCharacter, library, old, songColor));

	public static inline function depthSorting(Order:Int, Obj1:Alphabet, Obj2:Alphabet)
	{
		if (Obj1.zDepth > Obj2.zDepth)
			return -1;
		return 1;
	}

	public static inline function lockSorting(Order:Int, Obj1:LockSprite, Obj2:LockSprite)
	{
		if (Obj1.zDepth > Obj2.zDepth)
			return -1;
		return 1;
	}
}

class FreeplayPortrait extends FlxSprite
{
	public function new()
	{
		super();
		x += FlxG.width / 8;
	}

	public function loadNewPortrait(songName:String, atlasFrames:FlxAtlasFrames)
	{
		// ShopState.mutex.acquire();
		frames = atlasFrames;
		animation.addByPrefix('idle', '${songName.toLowerCase()}0', 24, true, false);
		setGraphicSize(Std.int(width * 0.75));
		updateHitbox();
		antialiasing = true;
		screenCenter(Y);
		animation.play('idle', true);
		//
		if (ShopState.portraitOffset.exists(songName.toLowerCase()))
		{
			offset.x += ShopState.portraitOffset.get(songName.toLowerCase()).x * scale.x;
			offset.y += ShopState.portraitOffset.get(songName.toLowerCase()).y * scale.y;
		}
		//
		existTime = 0;
		canExist = false;
		// ShopState.mutex.release();
	}

	var existTime:Float = 0;

	public var canExist:Bool = false;

	override public function update(elapsed:Float)
	{
		existTime += elapsed;
		if (existTime > elapsed)
			canExist = true;
		super.update(elapsed);
	}
}