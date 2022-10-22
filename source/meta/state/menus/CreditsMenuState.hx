package meta.state.menus;

import haxe.Json;
import sys.io.File;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import meta.MusicBeat;
import openfl.display.GraphicsShader;
import openfl.filters.ShaderFilter;
import sys.FileSystem;

using StringTools;
typedef Credits = {
    var name:String;
    var quote:String;
    var profession:String;
    var description:String;
}

class CreditsMenuState extends MusicBeatState {
	public var chromaticAberration:ShaderFilter;
	public var aberrateTimeValue:Float = 0.05;

	public var templist:Array<Credits> = [
		{
			name: 'KadeDeveloper',
			quote: "",
			profession: 'Programmer',
			description: ""
		},
		{
			name: 'Typic',
			quote: "proud gymbiote",
			profession: 'Artist, Animator',
			description: "Yo its me, the guy whos work you probably saw on the lullaby gf sprite way back when.  I'm glad I had the opportunity to come back to this project and work on v2, not only to make a sprite of gf I'm more proud of for lost cause, but to also do some bg work as well. I made the background art for pasta night (the room itself not the characters) and for isotope, both of which I'm very proud of. Hope you all enjoy the update, cause I know for a fact that I and the rest of the team enjoyed working on it."
		},
		{
			name: 'Garbo',
			quote: "I farded and a poopy almost slipped out",
			profession: 'Artist, Animator',
			description: "I’m Garbo, aka the Chaos Nightmare Phantasm Sink guy thanks for playing our mod it’s been a crazy adventure and one of the best experiences I’ve had working with people online. My favorite thing that I got the chance to work on would have to be the Frostbite Sprites with the help from Scorch. Stay Hungry, Devour."
		},
		{
			name: 'Adam McHummus',
			quote: "I put my whole Adam McHummussy into my shit",
			profession: 'Composer',
			description: "ayo, I’m Adam, but you can call me Adam McHummus, I’ve done a fair bit of music for some very popular fnf mods, nothing too special, although hypno will always be an epic mod to work on, with all the people I’ve met and befriended here, it was worth it in some ways, I looked up to banbuds when i first heard about him and getting the chance to work on a mod with him was huge for me, and hey, look at me now, we’re already on v2 and I’ve made so much cool shit, I really hope y’all enjoyed it as much as I did working on it,,"
		},
		{
			name: 'Punkett',
			quote: "famous (I'll put the cat image there if I remember to punkett sorry",
			profession: 'Musician',
			description: "HIII IM PUNKETT !!! i make cool songs also i worked on funkin at freddys also triple trouble.. anyway im so happy i got to work on this mod bc its awesome and pokemon is awesome!!!! definitely one of my favorite teams ive worked with .... so thank u for playing the mod i hope u enjoy :] smooches"
		},
		{
			name: 'Saster',
			profession: 'Musician',
			quote: "Follow me for more quality content!",
			description: "Hey! I did the music for the Freeplay menu and Amusia! Working on this mod with all these amazing and talented people was really fun and I’m glad I was able to be a part of it. I hope you find enjoyment from our mod and hope to see you in another! <3"
		},
		{
			name: 'SimplyCrispy',
			profession: 'Musician',
			quote: "I'm a Top G B)",
			description: "I made Dissension and the Perish Mix for Monochrome, pretty lame if you ask me lol. In total seriousness, working on Hypno was a dream come true for me, it was always one of my top 3 and the only one I didn't actually work on, as such, I was stoked to get to join the team and help this amazing project get to where it is now. Everyone in the dev team is a goat, love them all to death, and working with them, becoming closer to them and just hanging out with them in general was the highlight of it all for me, it's not often you get to see a team feel so cozy and actually genuinely passionate about the product they're producing, and I couldn't ask for better. Love y'all"
		},
		{
			name: 'Rea',
			quote: "there is a ball of playdoh in my mouth and im going to swallow it",
			profession: 'Artist, Animator',
			description: "Ayo, Rea here. Working on hypno has been a blast, I'm honored to be a part of this team; working here has taught me a lot, it also gave me the opportunity to meet and befriend many cool people. Most of my work for this mod has went towards the development of Strangled Red's section. Thank you for playing the mod and enjoy! 10 piece mcdonal nugget"
		},
		{
			name: 'Uncle Jeol',
			quote: "innocence got me fucked up",
			profession: 'Artist, Animator, Pixel Artist',
			description: "Jeol here. I've been spriting for this mod since I did the v1 Missingno assets, it's been an amazing ride, and I love this fucking team to death. This project has let me go nuts with pixel art and I even had a go at some flash-style stuff, which was a great experience. I hope everyone who plays it has a blast! If you don't I'm filling your house with gas."
		},
		{
			name: 'BAnims',
			quote: "I hate my phone",
			profession: 'Artist, Animator, Pixel Artist',
			description: "It’s me BAnims, yknow, the guy on Twitter that made snoopy sprites. Anyways, like the majority of the team probably have already said, even though it’s had some ups and downs, it was still a pretty fun project for me to work on, and I’d like to thank my friends that got me to where I am today. Another thing, this mod made me love Gengar as I was working on the sprites for him, because ‘GOO GOO GOO GAAAAAH."
		},
		{
			name: "Gibz679",
			quote: "#ASHVCSWEEP",
			profession: "Charter",
			description: "Hi IM GIBZ, My name can be pronounced gibz or Gibz679,idrc. hypno's lullaby is one of my favorite mods and getting too work on it still feels like a dream,Some of the songs i charted were
frostbite,shitno,monochrome,stranged red and isotope,missingno and a few other songs .This has been one crazy ass experience working on this mod but still the most fun i have had working on a mod, anyways this mod is cool because scary pokémon, Thank you for playing/supporting this mod. \n\nshubs fix the random huge ass space in the middle, i’m on my phone so i can’t"
		},
		{
			name: 'Mr Nol',
			quote: "you don’t have to tell me twice, but during the stone age…",
			profession: 'Musician, Sound Design, Chromatics',
			description: "Sup, it’s NoL the nobody here, honestly Hypno’s lullaby has actually changed my life and I couldn’t be anymore greatful to be on the team! (Even if what I do is close to nothing.) I know this is gonna be said like a thousand times but this team really does feel like a friend group, rather than ya know, ONE OF THE BIGGEST MODS EVER!!! Anyways this mod made me buy this funny gengar plushie that’s how much I love this mod"
		},
		{
			name: 'Kyoto',
			profession: 'Artist and Animator',
			quote: "I am not gay, If they ever tell you otherwise its the voices.",
			description: "I'm simply some other guy, a Mexican if you will. I've been in the fnf modding scenery for a long long long long time now but have never been part of a huge project like this one. Banbuds Got me to work on this and I am so grateful for being part of such a ambiguous project with people who have such ambiguous visions. I've had a huge art change only from the inspiration I've gotten looking at other fellow members being here and my experience within the dev team, which have been one hell of a ride, Its got its ups and its got its downs but that's what's part of the ride, something I wont be forgetting about any time soon. And to my friends, who have lifted me up in my worst, I thank you the most. Your all the reason I can stand up in my legs to be able to have spirit to do the things I do. I owe you all the world and more"
		},
		{
			name: 'Jacaris',
			profession: '(a.k.a. Jacey Amaris)\nComposer and Voice Actor',
			quote: "pronounced Ja-Sar-Is you dweebs",
			description: "names jacey. you might know me as the menace behind the song Chaos from the VS. Sonic EXE mod as well as the voice of Super Sonic (Fleetway), or for my unbridled enthusiasm and obsession with Sonic in general. im responsible for the music of both Lost Cause and Purin and they stand as some of my final contributions to the FNF community before i go back into my cave to fixate on Sonic for the rest of my life, so i hope you enjoyed! its been a pleasure"
		},
		{
			name: 'Marco Antonio',
			quote: "UN SALUDO A LA GRASAAAAAA",
			profession: 'Artist, Animator, Tilin Master',
			description: "hoi, Marco here, i made art for this, wow, its really been a pleasure to work for this mod, this was one of the mods that inspired me way back in October to make my own stuff for this community, i really enjoyed working for it and i hope you enjoyed it, thank you so much for the support, with all that being said, reject Hypno's Lullaby, Embrace Mario's Madness."
		},
		{
			name: "River",
			quote: "the fragrance is quite oppressive",
			profession: "Artist, Animator, Musician and Certified Pony Lover",
			description: "Hey, I'm River. You may know me as the guy who made No Heroes, or maybe the guy who made Strangled, but that doesn't matter. Working with this team has been so much fun, and I had a blast making some of the art assets for this mod. I'm incredibly grateful to be given the opportunity to work on sprites for this project and from the bottom of my heart, I want to thank everyone who made this little poke-pasta mod possible. Also hi Penkaru."
		},
		{
			name: 'Zekuta',
			quote: "Who the fuck needs those?",
			profession: 'Artist, Animator',
			description: "What's up, playa'? I'm the guy who made the Hypno sprite for Pasta Night. But that's not the important part. How I ended up in this team is a mystery, but to work with all of these talented people is a treat.  Whether I met some of them prior or after joining the team, it's been a real pleasure getting to know them. I've learned a thing or two from a few fellow artists here and I'm grateful for that. Now that's out of the way, here's to a goated update to a goated mod. Now keep scrolling down. There's more goated people you need to check out. ;)."
		},
		{
			name: 'Xooplord',
			quote: "Unauthorized fucking thing… shoot it down!!",
			profession: 'Artist',
			description: "hi I’m xoop, I’m on a couple of mods not many notable ones because I am notorious for working slow LMAO I did one of the promo arts and helped with the barebones of gold’s death animation that has been remade one too many times T_T I’m eternally grateful I was able to work on this project, Hypno was one of my all time favorite mods when I was just a teeny baby mod artist and the fact that I’ve come this far to work on it for V2, even if it was barely anything, is so crazy to me. I hope you guys enjoy this as much as I do!!!!"
		},
		{
			name: 'niffirg',
			quote: "#HESGOTTHEsweep",
			profession: 'Charter',
			description: "niffirg here, yes it’s niffIRG and not niffRIG please stop saying niffrig (imagine crying emojis here) It’s also just my name backwards. Anyways, now that those 2 things are cleared up hello!!! I’m a charter and content creator you may or may not have seen on the Tube… In all seriousness tho, even through all the more difficult times, this mod was still extremely fun to work and I still feel very lucky to have the opportunity to contribute to this :) Big thank you to everyone in the dev team and to YOU!!! FOR PLAYING!!"
		},
		{
			name: 'Razencro',
			quote: "help me i'm stuck in a fnf mod credit screen ahhhh get me out!!!!",
			profession: 'Video Editor',
			description: "I’m Razencro and I'm a video editor. I did like 2 things total for this awesome ass mod and a trailer. Super lucky and grateful to be able to have helped out. Props to everyone involved for being so talented and creating a legendary mod."
		},
		{
			name: 'JoeDoughBoi',
			profession: 'Pillsbury DoughBoi',
			quote: 'Hi Mom',
			description: "I was brought on after finding out about Pasta Night. I originally was just meant to overview the Lord X sprites but I ended up volunteering to help design the background characters and level layout. It was awesome trying to fit as many references as we could, and I'm grateful that the team was as open as they were with it. The Hypno dev team is amazing, and working with them has been nothing but a pleasure. Also, staying up and watching Spy x Family was one of the many highlights I've had :')"
		}
		// */
    ];

    public var iconList:Array<FlxSprite> = [];
	public var personList:Array<Credits> = [];
	var backdrop:FlxBackdrop;

    override public function create() {
        super.create();

		// initialize shop music
		FlxG.sound.playMusic(Paths.music('creditsTheme'), 0.5, true);
		// FlxG.sound.music.fadeIn(0.5, 0, 1);

		var camGame:FlxCamera = new FlxCamera();
		var camHUD:FlxCamera = new FlxCamera(0, 0, 912, 513);
        
		// camHUD.bgColor.alpha = 0;
		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
        
        // loll
		var camOther:FlxCamera = new FlxCamera();
		camOther.bgColor.alpha = 0;
		FlxG.cameras.add(camOther);

		var sprite:FlxSprite = new FlxSprite();
		sprite.frames = Paths.getSparrowAtlas('menus/credit/CREDITS_TV');
		sprite.animation.addByPrefix('CREDITS TV', 'CREDITS TV', 24);
		sprite.animation.play('CREDITS TV');
        add(sprite);
        sprite.screenCenter();
        sprite.cameras = [camGame];
        sprite.y += 16;
        camHUD.cameras = [camGame];

        camHUD.x = FlxG.width / 2 - camHUD.width / 2;
		camHUD.y = (FlxG.height / 2 - camHUD.height / 2) - 64;

		chromaticAberration = new ShaderFilter(new GraphicsShader("", Paths.shader('monitor')));
		// chromaticAberration.shader.data.effectTime.value = [aberrateTimeValue];
		camHUD.setFilters([chromaticAberration]); 

		// camHUD
		var background:FlxGroup = new FlxGroup();
		add(background);
		background.cameras = [camHUD];

		// POKEMON YELLOW LOL
		backdrop = new FlxBackdrop(Paths.image('menus/menu/pokemon_yellow_noise'), 1, 1, true, true, 1, 1);
		background.add(backdrop);

		// background shis
		var white:FlxSprite = new FlxSprite().makeGraphic(1280, 720, FlxColor.WHITE);
        white.alpha = 0.25;
		background.add(white);

		var list:Array<String> = CoolUtil.coolTextFile(Paths.txt('images/menus/credit/iconorder'));
		for (person in list) {
			if (FileSystem.exists(Paths.getPath('images/menus/credit/icon/${person.replace(' ', '_')}.json', TEXT))) {
				var icon:FlxSprite = new FlxSprite();
				if (FileSystem.exists(Paths.getPath('images/menus/credit/icon/${person.replace(' ', '_')}.png', IMAGE)))
					icon.loadGraphic(Paths.image('menus/credit/icon/${person.replace(' ', '_')}'));
				else icon.loadGraphic(Paths.image('menus/credit/icon/placeholder'));
				icon.setGraphicSize(Std.int(icon.width * (3 / 5)));
				icon.updateHitbox();
				icon.antialiasing = true;
				iconList.push(icon);
				background.add(icon);
			
				var rawJson = File.getContent(Paths.getPath('images/menus/credit/icon/${person.replace(' ', '_')}.json', TEXT));
				var credits:Credits = cast Json.parse(rawJson).info;
				credits.name = person;
				personList.push(credits);
			}
        }

		var box:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menus/credit/box'));
        background.add(box);

		for (i in 0...iconList.length)
			iconList[i].alpha = 0.3;
		iconList[verticalSelection].alpha = 1;

        var point:Int = 200;

        var upPointer:FlxSprite = new FlxSprite();
		upPointer.frames = Paths.getSparrowAtlas('menus/menu/campaign_menu_UI_assets');
		upPointer.animation.addByPrefix('idle', 'arrow push left', 0, false);
        upPointer.animation.play('idle');
        upPointer.animation.curAnim.curFrame = 1;
        upPointer.angle = 90;
        upPointer.y = 32;
		upPointer.x = point - upPointer.width / 2;

		var downPointer:FlxSprite = new FlxSprite();
		downPointer.frames = Paths.getSparrowAtlas('menus/menu/campaign_menu_UI_assets');
		downPointer.animation.addByPrefix('idle', 'arrow push left', 0, false);
		downPointer.animation.play('idle');
		downPointer.animation.curAnim.curFrame = 1;
		downPointer.angle = -90;
		downPointer.y = camHUD.height - (downPointer.height + 32);
		downPointer.x = point - downPointer.width / 2;

        background.add(upPointer);
        background.add(downPointer);
		CoolUtil.lerpSnap = true;

        topText = new FlxText(0, 0, 0, 'goober');
		topText.setFormat(Paths.font('vcr.ttf'), 32, FlxColor.WHITE);
        topText.y = 32;
        background.add(topText);

		professionText = new FlxText(0, 0, 485 - 32, 'idea person');
		professionText.setFormat(Paths.font('vcr.ttf'), 24, FlxColor.WHITE);
		professionText.autoSize = false;
		professionText.alignment = FlxTextAlign.CENTER;
		background.add(professionText);

		stupidQuote = new FlxText(0, 0, 485 - 32, 'I like men');
		stupidQuote.setFormat(Paths.font('vcr.ttf'), 16, FlxColor.WHITE);
		stupidQuote.autoSize = false;
		stupidQuote.alignment = FlxTextAlign.CENTER;
		background.add(stupidQuote);

		descriptionText = new FlxText(0, 0, 485 - 32, "this person is completely useless to the team and will not contribute at all whatsoever. I don't know what else to say, they are completely fucking useless");
		descriptionText.setFormat(Paths.font('vcr.ttf'), 20, FlxColor.WHITE);
		descriptionText.x = 384 + 16;
		background.add(descriptionText);

		updateText();
    }

	public var moverCooldown:Float = 0;

	public var verticalSelection:Int = 0;

    public var topText:FlxText;
	public var stupidQuote:FlxText;
    public var professionText:FlxText;
    public var descriptionText:FlxText;

    override public function update(elapsed:Float) {
        super.update(elapsed);

		backdrop.x += (elapsed / (1 / 60)) / 2;
		backdrop.y = Math.sin(backdrop.x / 48) * 48;

		if (controls.BACK)
			Main.switchState(this, new MainMenuState());  
        
		// controls
		var newSelection:Int = verticalSelection;
		var up = controls.UI_UP;
		var down = controls.UI_DOWN;
		var left = controls.UI_LEFT;
		var right = controls.UI_RIGHT;
		// direction up
		var directionVertical:Int = (up ? -2 : 0) + (down ? 2 : 0);
		var directionHorizontal:Int = (left ? -1 : 0) + (right ? 1 : 0);
		if (Math.abs(directionVertical) > 0)
		{
			if (moverCooldown <= 0)
			{
				newSelection += directionVertical;
				var even:Int = ((newSelection % 2) == 0 ? 1 : 0);

				if (newSelection < 0)
					newSelection = (iconList.length - 1) - even;
				if (newSelection > iconList.length - 1)
					newSelection = newSelection % 2;
                
				moverCooldown += FlxG.updateFramerate / 4;
			}
			else
				moverCooldown--;
		}
		else if (Math.abs(directionHorizontal) > 0)
		{
			if (moverCooldown <= 0)
			{
				newSelection += directionHorizontal;

				if (newSelection < 0)
					newSelection = iconList.length - 1;
				if (newSelection > iconList.length - 1)
					newSelection = 0;
                
				moverCooldown += FlxG.updateFramerate / 4;
			}
			else
				moverCooldown--;
		}
		else
			moverCooldown = 0;
		updateVerticalSelection(newSelection, iconList.length - 1);
			
        var step:Int = 0;
		var j:Int = 0;
		//
		var constant:Float = 150;
		constant *= (11 / 12);
		var fakeElapsed:Float = CoolUtil.clamp(elapsed, 0, 1);
        for (i in 0...iconList.length) {
			var iconX = (125 + (step * constant) - (iconList[i].width / 2));
			var iconY = (125 + (constant * (j - Math.floor(verticalSelection / 2) + 0.5)) - (iconList[i].height / 2) + ((constant / 2) * step));
			iconList[i].x = iconX;
			iconList[i].y = CoolUtil.fakeLerp(iconList[i].y, iconY, fakeElapsed / (1 / 15));
			step++;
			if (step > 1)
			{
				step = 0;
				j++;
			}
        }
		CoolUtil.lerpSnap = false;
    }

	function updateVerticalSelection(newSelection:Int, limiter:Int = 1)
	{
		if (verticalSelection != newSelection)
		{
			verticalSelection = newSelection;
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.5);

			for (i in 0...iconList.length)
                iconList[i].alpha = 0.3;
			iconList[verticalSelection].alpha = 1;
            //
			updateText();
		}
        //
	}

    function updateText() {
		topText.text = personList[verticalSelection].name;
		topText.x = 384 + ((485 / 2) - (topText.width / 2));
		professionText.text = personList[verticalSelection].profession;
		professionText.x = 384 + ((485 / 2) - (professionText.width / 2));
		professionText.y = topText.y + topText.height;
        //
		stupidQuote.text = "\"" + personList[verticalSelection].quote + "\"";
		stupidQuote.x = 384 + ((485 / 2) - (stupidQuote.width / 2));
		stupidQuote.y = professionText.y + professionText.height + 8;
        //
		descriptionText.text = "\"" + personList[verticalSelection].description + "\"";
		descriptionText.y = stupidQuote.y + stupidQuote.height + 16;
    }
}