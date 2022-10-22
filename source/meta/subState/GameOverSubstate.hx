package meta.subState;

import openfl.filters.ShaderFilter;
import openfl.display.GraphicsShader;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.graphics.FlxGraphic;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import gameObjects.Boyfriend;
import gameObjects.Character;
import meta.MusicBeat.MusicBeatSubState;
import meta.data.Conductor.BPMChangeEvent;
import meta.data.Conductor;
import meta.data.dependency.FNFSprite;
import meta.state.*;
import meta.state.menus.*;
import openfl.media.Sound;
import openfl.utils.Assets;

#if sys
import sys.FileSystem;
#end

import vlc.MP4Handler;

class GameOverSubstate extends MusicBeatSubState
{
	//
	var bf:Character;
	var camFollow:FlxObject;
	var stageSuffix:String = "";
	
	public static var redGraphic:FlxGraphic;
	public var retry:FlxSprite;
	var constantResize:Float = 5 / 4;

	public static var deathSoundName = 'fnf_loss_sfx';
	public static var loopSoundName = 'gameOver';
	public static var endSoundName = 'gameOverEnd';
	public static var deathSoundBPM:Float = 100;

	public var lastCharacter:String = '';

	public function new(character:String, x:Float, y:Float)
	{
		super();

		lastCharacter = character;

		Conductor.songPosition = 0;
		if (daBf != 'gf-stand') {
			PlayState.boyfriend.destroy();
			FlxG.camera.scroll.set();
			FlxG.camera.target = null;
		}
		
		gameoverStart(daBf, x, y);
	}

	public static var daBf:String = '';
	public static function preload() {
		var daBoyfriendType = PlayState.boyfriend.curCharacter;
		deathSoundName = 'fnf_loss_sfx';
		loopSoundName = 'gameOver';
		endSoundName = 'gameOverEnd';
		deathSoundBPM = 100;
		daBf = PlayState.boyfriend.curCharacter;
		switch (daBoyfriendType)
		{
			case 'bf-og':
				daBf = daBoyfriendType;
			case 'bf-pixel':
				daBf = 'bf-pixel-dead';
				loopSoundName = 'MissingnoDeath';
				endSoundName = 'MissingnoDone';
				deathSoundName += '-pixel';
			case 'smol-hypno' | 'alexis':
				daBf = 'smol-hypno';
				loopSoundName = 'bygonedeathmusic';
				endSoundName = 'bygoneConfirm';
				deathSoundName = 'bygonedeathNoise';
			case 'cold-gold':
				loopSoundName = 'MtSilverLoop';
				endSoundName = 'MtSilverEnd';
			case 'gf':
				daBf = 'gf';
			case 'gf-stand' | 'gf-kneel':
				daBf = 'gf-stand';
				var preloadGraphic:FlxSprite = new FlxSprite();
				preloadGraphic.frames = Paths.getSparrowAtlas('characters/gf/phase_3_death');
				PlayState.instance.add(preloadGraphic);
				preloadGraphic.visible = false;
				//
				deathSoundName = '';
				loopSoundName = 'LostCauseLoop';
				endSoundName = 'LostCauseEnd';
			case 'ba-bf':
				daBf = 'buryman-death';
				deathSoundName = 'buryman-death/BA${FlxG.random.int(0, 3)}';
				loopSoundName = 'BurymanDeath';
				precacheSoundFile(Paths.sound('buryman-death/buriedThud'));
				precacheSoundFile(Paths.sound('buryman-death/buriedDeath'));
			case 'dawn' | 'dawn-bf':
				daBf = 'dawn';
				loopSoundName = 'DeathTollDeathAmbience';
			case 'mike-bed' | 'mike-fp':
				daBf = 'mike-death';
				deathSoundName = 'DissensionDeath';
			case 'mx' | 'lord-x' | 'hypno-cards':
				switch (PlayState.playerLane) {
					case 0:
						daBf = 'mx';
					case 1:
						daBf = 'lord-x';
					case 2:
						daBf = 'hypno-cards';
				}
				deathSoundName = 'PS_Death';
			case 'grey':
				precacheSoundFile(Paths.sound('Shitno-Death'));
			default:
				daBf = PlayState.boyfriend.curCharacter;
		}
		precacheSoundFile(Paths.sound(deathSoundName));
		precacheSoundFile(Paths.sound(loopSoundName));
		precacheSoundFile(Paths.sound(deathSoundName));
	}

	public var deathEnd:Void->Void = function(){};
	public var onEnd:Void->Void = function(){};
	public var stepFunction:Void->Void = function() {};
	public var updateFunction:Void->Void = function() {};
	public var escapeFunction:Void->Void = function(){};
	var gf:FlxSprite;
	public function gameoverStart(character:String, x:Float, y:Float) {
		switch (character) {
			case 'gf':
				var camHUD = new FlxCamera();
				FlxG.cameras.add(camHUD);
				FlxCamera.defaultCameras = [camHUD];
				camHUD.flash(FlxColor.RED, 0.5);
				timeBeforeEnd = 1.35;
				
				var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('characters/death/gf/sky'));
				bg.setGraphicSize(Std.int(bg.width * 1.5));
				bg.updateHitbox();
				bg.x -= bg.width * 0.15;
				bg.y -= bg.height * 0.15;
				add(bg);

				var trees:FlxSprite = new FlxSprite().loadGraphic(Paths.image('characters/death/gf/trees'));
				trees.setGraphicSize(Std.int(trees.width * 2));
				trees.updateHitbox();
				trees.x -= (trees.width * 0.5) + 5;
				trees.y += (trees.height * 0.15) - 1;
				add(trees);

				var trunk:FlxSprite = new FlxSprite().loadGraphic(Paths.image('characters/death/gf/trunk'));
				trunk.setGraphicSize(Std.int(trunk.width * 1.5));
				trunk.updateHitbox();
				trunk.x += (trunk.width * 0.75) + 5;
				trunk.y -= (trunk.height * 0.15) - 1;
				add(trunk);
				
				gf = new FlxSprite(FlxG.width / 2, FlxG.height / 2);
				gf.frames = Paths.getSparrowAtlas('characters/death/gf/gf');
				gf.animation.addByPrefix('deathLoopStart', 'GF_DIZZLE_OPENING instance 1', 24, false);
				gf.animation.addByPrefix('deathLoop', 'GF_DIZZLE_LOOP instance 1', 24, true);
				gf.animation.addByPrefix('deathConfirm', 'GF_WAKEUP instance 1', 24, false);
				gf.animation.play('deathLoopStart');
				gf.animation.finishCallback = function(name:String) {
					switch (name) {
						case 'deathLoopStart':
							gf.animation.play('deathLoop');
					}
				};
				gf.setGraphicSize(Std.int(gf.width * 1.25));
				gf.updateHitbox();
				// gf.x -= gf.width * 0.25;
				// gf.x += 150;
				gf.y -= gf.height * 0.35;
				gf.antialiasing = true;
				add(gf);

				var hando:FlxSprite = new FlxSprite();
				hando.frames = Paths.getSparrowAtlas('characters/death/gf/claw');
				hando.animation.addByPrefix('claw', 'claw', 24, true);
				hando.animation.play('claw');
				hando.setGraphicSize(Std.int(hando.width * 0.75));
				hando.updateHitbox();
				hando.x = -hando.width * 0.25;
				hando.y += hando.height * 0.25;
				// FlxTween.tween(hando, {x: -hando.width * 0.25}, 0.75, {ease: FlxEase.linear});
				hando.antialiasing = true;
				
				add(hando);

				var retry:FNFSprite = new FNFSprite(75, 300);
				retry.frames = Paths.getSparrowAtlas('characters/death/gf/gf_gameover');
				retry.animation.addByPrefix('start', "gameover_start' instance 1", 24, false);
				retry.addOffset('start', 40, 45);
				retry.animation.addByPrefix('end', "gameover_over instance 1", 24, false);
				retry.addOffset('end', 130, 50);
				retry.animation.addByPrefix('idle', "gameover_concept instance 1", 24, true);
				// retry.setGraphicSize(Std.int(retry.width * 0.5));
				// retry.updateHitbox();
				add(retry);
				retry.playAnim('start');
				retry.animation.finishCallback = function(name:String) {
					if (name == 'start')
						retry.playAnim('idle');
					if (name == 'end') 
						FlxTween.tween(retry, {alpha: 0}, 1, {ease: FlxEase.linear});
				}

				deathEnd = function()
				{
					gf.x -= 50;
					retry.playAnim('end');
					gf.animation.play('deathConfirm');
				};

			case 'gf-stand' | 'gf-kneel' | 'gf-stand-death':
				timeBeforeEnd = 4.5;
				bf = PlayState.boyfriend;

				var deathThingy:FNFSprite = new FNFSprite(1000, 1000);
				deathThingy.frames = Paths.getSparrowAtlas('characters/gf/phase_3_death');
				deathThingy.animation.addByPrefix('start', 'gameover-start', 24, false);
				deathThingy.animation.addByPrefix('loop', 'gameover-loop', 24, true);
				deathThingy.animation.addByPrefix('end', 'gameover-final', 24, false);
				deathThingy.visible = true;
				deathThingy.playAnim('start', true);
				deathThingy.x = x - deathThingy.width / 2;
				deathThingy.y = y - deathThingy.height / 2 - deathThingy.height / 6 + 128;
				add(deathThingy);

				if (bf.atlasCharacter != null)
					add(bf.atlasCharacter);

				updateFunction = function() {
					camFollow.setPosition(x, y);
					FlxG.camera.follow(camFollow, LOCKON, 0.01);
					if (deathThingy.animation.curAnim.name == 'start' && deathThingy.animation.finished) {
						FlxG.sound.playMusic(Paths.music(loopSoundName));
						deathThingy.playAnim('loop');
					}
				};

				new FlxTimer().start(1.5, function(tmr:FlxTimer) {	
					if (!isEnding) 
						FlxTween.tween(PlayState.camGame, {zoom: PlayState.camGame.zoom + 0.05}, 2, {ease: FlxEase.quadInOut});
				});

				deathEnd = function() {
					deathThingy.playAnim('end');
					FlxTween.cancelTweensOf(PlayState.camGame);
					PlayState.camGame.fade(FlxColor.BLACK, timeBeforeEnd / 2, false, function(){
						PlayState.camGame.alpha = 0;
					});
					FlxTween.tween(PlayState.camGame, {zoom: PlayState.camGame.zoom - 0.15}, timeBeforeEnd / 2, {ease: FlxEase.quadIn});
				};

			case 'smol-hypno':
				var retry:FNFSprite = new FNFSprite(280, 200);	
				retry.frames = Paths.getSparrowAtlas('characters/death/bygone/Retry');
				retry.animation.addByPrefix('idle', "Retry instance 1", 24, false);				
				add(retry);
				retry.playAnim('idle');
				retry.animation.finishCallback = function(name:String) {
					if (name == 'idle')
						retry.playAnim('idle');
				}
				retry.scale.set(0.65, 0.65);
				retry.alpha = 0;	

				if (PlayState.alexis)
					{
						var alexisdies:FNFSprite = new FNFSprite(850, 100);
						alexisdies.frames = Paths.getSparrowAtlas('characters/death/bygone/GGirl_Poof');
						alexisdies.animation.addByPrefix('idle', "GGirlPoof", 12, false);				
						add(alexisdies);
						alexisdies.scale.set(1.15, 1.15);
						FlxG.sound.play(Paths.sound('bygonedeathNoise'));
						alexisdies.playAnim('idle');
						alexisdies.animation.finishCallback = function(name:String) {
							if (name == 'idle')
								FlxTween.tween(alexisdies, {alpha: 0}, 0.3, {ease: FlxEase.circOut});					
						}
						new FlxTimer().start(1.7, function(tmr:FlxTimer)
							{									
								FlxG.sound.volume = 0;
								FlxG.sound.playMusic(Paths.music(loopSoundName));
								FlxTween.tween(FlxG.sound, {volume: 1}, 2, {ease: FlxEase.linear});
								FlxTween.tween(retry, {alpha: 1}, 1.5, {ease: FlxEase.circIn});								
							});
					}
				else
					{						
						var camHUD = new FlxCamera();
						FlxG.cameras.add(camHUD);
						FlxCamera.defaultCameras = [camHUD];
						camHUD.flash(FlxColor.RED, 0.5);							
						FlxG.sound.volume = 0.15;
						FlxG.sound.playMusic(Paths.music(loopSoundName));
						FlxTween.tween(FlxG.sound, {volume: 1}, 1.5, {ease: FlxEase.linear});
						FlxTween.tween(retry, {alpha: 1}, 1, {ease: FlxEase.circIn});					
					}						
								
				deathEnd = function(){
					remove(retry);
					FlxG.sound.play(Paths.sound(endSoundName));

					var confirm:FNFSprite = new FNFSprite(420, 0);
					confirm.frames = Paths.getSparrowAtlas('characters/death/bygone/Confirm');
					confirm.animation.addByPrefix('idle', "Confirm instance 1", 24, false);		
					add(confirm);
					confirm.playAnim('idle');					
				};
			case 'buryman-death':
				var camHUD = new FlxCamera();
				FlxG.camera.zoom = 6;
				FlxG.cameras.add(camHUD);
				FlxCamera.defaultCameras = [camHUD];
				// camHUD.zoom = 0.6;
				FlxG.sound.play(Paths.sound('buryman-death/buriedThud'));
				var retry:Boyfriend = new Boyfriend();
				retry.setCharacter(0, 0, 'buryman-death');
				retry.playAnim('retry');

				new FlxTimer().start(0.5, function(tmr:FlxTimer)
				{						
					var sound:Sound = Paths.sound(deathSoundName);
					FlxG.sound.play(sound);
					new FlxTimer().start((sound.length / 1000) - 0.05, function(tmr:FlxTimer){
						camHUD.flash(FlxColor.BLACK, 0.5);

						bf = new Boyfriend();
						bf.setCharacter(x, y, character);
						bf.screenCenter();
						bf.x += Std.int(FlxG.width / 8);
						add(retry);
						retry.setPosition((bf.x + bf.width / 2) - retry.width / 2, bf.y + 32);
						retry.playAnim('retry');
						bf.y += Std.int(FlxG.height / 3);
						add(bf);
						bf.playAnim('idle');

						FlxG.sound.playMusic(Paths.music(loopSoundName));
						Conductor.changeBPM(65);
					});
				});

				deathEnd = function() {
					retry.playAnim('accept');
					FlxTween.tween(camHUD, {alpha: 0}, timeBeforeEnd, {ease: FlxEase.linear});
				};
				stepFunction = function() {
					if (curBeat % 4 == 3) {
						if (curStep % 8 == 6)
							bf.playAnim('idle');
					}
				}

			case 'dawn':
				var camHUD = new FlxCamera();				
				FlxG.cameras.add(camHUD);
				FlxCamera.defaultCameras = [camHUD];
				camHUD.zoom = 1.2;
				FlxG.sound.play(Paths.sound('DT_Loss_SFX'));
				camHUD.flash(FlxColor.RED, 2.5);	
				
				var flicker:FlxSprite = new FlxSprite().loadGraphic(Paths.image('characters/death/hellbell/vignetteFlicker'));	
				flicker.cameras = [camHUD];											
				flicker.screenCenter();
				flicker.y -= 25;
				flicker.scale.set(1.35, 1.35);		
				flicker.antialiasing = true;	
				flicker.alpha = 0.2;				

				var skillissue:FNFSprite = new FNFSprite(-225, -250);	
				skillissue.frames = Paths.getSparrowAtlas('characters/death/hellbell/hellbellDeath');
				skillissue.animation.addByPrefix('idle', "deathIdle", 24, false);		
				skillissue.animation.addByPrefix('lol', "deathLol", 24, false);				
				skillissue.animation.addByPrefix('confirm', "deathConfirm", 24, false);		
				skillissue.scale.set(1.3, 1.3);			
				skillissue.antialiasing = true;		
				add(skillissue);
				skillissue.playAnim('idle');	
				skillissue.animation.finishCallback = function(name:String) {
					switch (name) {
						case 'idle':
							skillissue.animation.play('lol');	
							flicker.alpha = 0.22;	
							new FlxTimer().start(0.08, function(tmr:FlxTimer)
								{						
									flicker.alpha = 0.2;
									new FlxTimer().start(0.08, function(tmr:FlxTimer)
										{						
											flicker.alpha = 0.22;
											new FlxTimer().start(0.08, function(tmr:FlxTimer)
												{						
													flicker.alpha = 0.2;
													new FlxTimer().start(0.08, function(tmr:FlxTimer)
														{						
															flicker.alpha = 0.22;
															new FlxTimer().start(0.08, function(tmr:FlxTimer)
																{						
																	flicker.alpha = 0.2;
																	new FlxTimer().start(0.08, function(tmr:FlxTimer)
																		{						
																			flicker.alpha = 0.22;
																			new FlxTimer().start(0.08, function(tmr:FlxTimer)
																				{						
																					flicker.alpha = 0.2;
																				});	
																		});	
																});	
														});	
												});	
										});	
								});										
						case 'lol':
							skillissue.animation.play('idle');														
					}
				};		

				add(flicker);
				new FlxTimer().start(1.5, function(tmr:FlxTimer)
					{			
						FlxG.sound.playMusic(Paths.music(loopSoundName));		
						FlxTween.tween(camHUD, {zoom: 0.6}, 2, {ease: FlxEase.quadInOut});
						FlxTween.tween(skillissue, {y: -70}, 2, {ease: FlxEase.quadInOut});
						FlxTween.tween(skillissue, {x: -30}, 2, {ease: FlxEase.quadInOut});
					});		
				
				deathEnd = function() {
					camHUD.flash(FlxColor.BLACK, 0.2);	
					skillissue.playAnim('confirm');
					new FlxTimer().start(1.2, function(tmr:FlxTimer)
						{						
							FlxTween.tween(camHUD, {alpha: 0}, timeBeforeEnd, {ease: FlxEase.linear});
						});					
				};

			case 'mike-death':
				var camHUD = new FlxCamera();
				FlxG.cameras.add(camHUD);
				FlxCamera.defaultCameras = [camHUD];
				
				bf = new Boyfriend();
				bf.setCharacter(x, y, character);
				bf.setGraphicSize(Std.int(bf.width * 1.25));
				bf.screenCenter();
				bf.y += 100;
				bf.antialiasing = true;
				add(bf);
				bf.playAnim('firstDeath');
				camHUD.flash(0x6CFC0000, 0.5);	

				var sound:Sound = Paths.sound(deathSoundName);
				FlxG.sound.play(sound);

				deathEnd = function() { bf.playAnim('deathConfirm'); }
			
			case 'mx' | 'lord-x' | 'hypno-cards':
				FlxG.sound.play(Paths.sound(deathSoundName));

				var deathCam:FlxCamera = new FlxCamera(0, 0, 768, 672);
				FlxG.cameras.reset(deathCam);
				
				var crt:ShaderFilter = new ShaderFilter(new GraphicsShader("", Paths.shader('crt')));
				deathCam.setFilters([crt]);
				// lmao
				deathCam.x += (FlxG.width / 2 - deathCam.width / 2);
				deathCam.y += (FlxG.height / 2 - deathCam.height / 2);
				cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

				var blackBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
				add(blackBG);
				
				var gameoverGraphic:FlxSprite = new FlxSprite();
				gameoverGraphic.frames = Paths.getSparrowAtlas('UI/base/pasta/PN_GameOver');
				gameoverGraphic.animation.addByPrefix('idle', 'pastanight_curtains0', 0, false);
				gameoverGraphic.animation.addByPrefix('moving', 'pastanight_curtains0', 24, false);
				gameoverGraphic.animation.addByPrefix('retry', 'pastanight_curtains_retry0', 24, true);
				gameoverGraphic.animation.play('idle');

				gameoverGraphic.setGraphicSize(Std.int(gameoverGraphic.width * 3));
				gameoverGraphic.setPosition(deathCam.width / 2 - gameoverGraphic.width / 2, deathCam.height / 2 - gameoverGraphic.height / 2);

				var miniChar:FlxSprite = new FlxSprite();
				miniChar.frames = Paths.getSparrowAtlas('UI/base/pasta/PN_LoseSprites');
				switch (character) {
					case 'mx':
						miniChar.animation.addByPrefix('idle', 'pastanight_LoseMX0', 24);
					case 'hypno-cards':
						miniChar.animation.addByPrefix('idle', 'pastanight_LoseHypno0', 24);
					case 'lord-x':
						miniChar.animation.addByPrefix('idle', 'pastanight_LoseLordX0', 24);
				}
				miniChar.animation.play('idle');
				miniChar.setGraphicSize(Std.int(miniChar.width * 3));
				miniChar.setPosition(deathCam.width / 2 - miniChar.width / 2, deathCam.height / 2 - miniChar.height / 2);
				if (character == 'lord-x')
					miniChar.x += 24;
				add(miniChar);
				add(gameoverGraphic);
				
				var velocity:Float = -5;
				var totalElapsed:Float = 0;
				updateFunction = function() {
					totalElapsed += FlxG.elapsed;
					if (crt != null)
						crt.shader.data.time.value = [totalElapsed];

					if (miniChar.y > gameoverGraphic.y + gameoverGraphic.height) {
						if (gameoverGraphic.animation.curAnim.name != 'moving' 
						&& gameoverGraphic.animation.curAnim.name != 'retry') {
							gameoverGraphic.animation.play('moving');
							gameoverGraphic.animation.finishCallback = function(name:String) {
								if (name == 'moving')
									gameoverGraphic.animation.play('retry');
							}
							//
						}
					}
	
					miniChar.y += velocity * (FlxG.elapsed / (1 / 60)) * 3;
					if (velocity < 32)
						velocity += 0.21875 * (FlxG.elapsed / (1 / 60));
				};
			default: 
				if (PlayState.SONG.song.toLowerCase() == 'insomnia')
					{
						var camHUD = new FlxCamera();
						FlxG.cameras.add(camHUD);
						FlxCamera.defaultCameras = [camHUD];

						var bg:FlxSprite = new FlxSprite(-FlxG.width, -FlxG.height).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
						bg.scrollFactor.set();
						bg.cameras = [camHUD];
						add(bg);
						bg.antialiasing = true;


						var video:MP4Handler = new MP4Handler();
						video.playVideo(Paths.video('feraligatr'));
						video.finishCallback = function()
						{
							if (video.bitmapData != null)
								bg.pixels = video.bitmapData;

							bg.setGraphicSize(Std.int(FlxG.width), Std.int(FlxG.height));
							bg.screenCenter();
						}
	
						deathEnd = function()
						{
							if (video != null) video.finishVideo();
							FlxTween.tween(bg, {alpha: 0}, timeBeforeEnd, {ease: FlxEase.linear});

							onEnd = function()
							{
								remove(bg);
								bg.pixels.dispose();
								bg = null;
							};
							
							Conductor.changeBPM(100);
						};

						escapeFunction = function ()
							{
								if (video != null) video.finishVideo();
							}
					} 
				else if (PlayState.SONG.song.toLowerCase() == "monochrome") {
					deathSoundName = '';
					loopSoundName = '';
					endSoundName = '';
				}
				else if (PlayState.SONG.song.toLowerCase() == "shitno") {
					deathSoundName = 'Shitno-Death';
					loopSoundName = '';
					endSoundName = '';

					var camHUD = new FlxCamera();
					FlxG.cameras.add(camHUD);
					FlxCamera.defaultCameras = [camHUD];

					var shaderabb:ShaderFilter = new ShaderFilter(new GraphicsShader("", Paths.shader('aberration')));
					camHUD.setFilters([shaderabb]);
					if (shaderabb != null)
						{
							shaderabb.shader.data.aberration.value = [0.001];
							shaderabb.shader.data.effectTime.value = [0.001];
						}

					var shitno:FlxSprite = new FlxSprite().loadGraphic(Paths.image('jumpscares/Shitno'));	
					shitno.cameras = [camHUD];											
					shitno.screenCenter();
					add(shitno);
					shitno.visible = false;

					var totalAbb:Float = 0.001;
					
					new FlxTimer().start(2.0, function(tmr:FlxTimer)
					{	
						FlxG.sound.play(Paths.sound(deathSoundName));
						shitno.visible = true;
						camHUD.shake(0.01, 2.0);

						new FlxTimer().start(1.10, function(tmr:FlxTimer)
							{	
								new FlxTimer().start(0.125, function(tmr:FlxTimer)
									{	
										shitno.visible = !shitno.visible;
										totalAbb += 0.15;
										if (shaderabb != null)
											{
												shaderabb.shader.data.aberration.value = [totalAbb];
												shaderabb.shader.data.effectTime.value = [totalAbb];

											}
									},4);
							});

						new FlxTimer().start(1.75, function(tmr:FlxTimer)
							{	
								shitno.visible = false;

								new FlxTimer().start(1.0, function(tmr:FlxTimer)
									{
										Main.switchState(this, new ShopState());
									});
							});
					});

				}
				else 
				{
					FlxG.sound.play(Paths.sound(deathSoundName));
					
					bf = new Boyfriend();
					bf.setCharacter(x, y, character);
					bf.y += bf.characterData.offsetY;
					add(bf);

					bf.playAnim('firstDeath');
					updateFunction = function() {
						if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12)
							FlxG.camera.follow(camFollow, LOCKON, 0.01);

						if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
							FlxG.sound.playMusic(Paths.music(loopSoundName));
					};
					deathEnd = function() {
						bf.playAnim('deathConfirm');
					};
				}
			
		}
		Conductor.changeBPM(deathSoundBPM);
		if (bf != null) {
			camFollow = new FlxObject(bf.getGraphicMidpoint().x + 20 + bf.characterData.camOffsetX, bf.getGraphicMidpoint().y - 40 + bf.characterData.camOffsetY, 1, 1);
			add(camFollow);
		}
	}

	// from psych engine
	private static function precacheSoundFile(file:Dynamic):Void {
		if (Assets.exists(file, SOUND) || Assets.exists(file, MUSIC))
			Assets.getSound(file, true);
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null && FlxG.sound.music.playing)
		{
			Conductor.songPosition += elapsed * 1000;
			if (Math.abs(FlxG.sound.music.time - Conductor.songPosition) > 20)
				Conductor.songPosition = FlxG.sound.music.time;
		}

		super.update(elapsed);

		if (controls.ACCEPT)
			endBullshit();

		if (controls.BACK)
		{
			if (escapeFunction != null) escapeFunction();

			if (FlxG.sound.music != null)
				FlxG.sound.music.stop();

			if (PlayState.isStoryMode) {
				Main.switchState(this, new StoryMenuState());
			} else
				Main.switchState(this, new ShopState());
		}

		if (updateFunction != null)
			updateFunction();
		// if (FlxG.sound.music.playing)
		//	Conductor.songPosition = FlxG.sound.music.time;
	}

	override function stepHit()
	{
		super.stepHit();
		if (stepFunction != null)
			stepFunction();
	}

	var isEnding:Bool = false;


	var timeBeforeEnd:Float = 0.7;
	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			if(deathEnd != null)
				deathEnd();
			if (FlxG.sound.music != null)
				FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music(endSoundName));
			new FlxTimer().start(timeBeforeEnd, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 1, false, function()
				{
					if (onEnd != null)
						onEnd();
					Main.switchState(this, new PlayState());
				});
			});
			//
		}
	}
}
