package meta.state;

import flixel.addons.display.FlxBackdrop;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
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
import flash.system.System;
import meta.data.font.Alphabet;
import meta.state.menus.*;
import openfl.Assets;

using StringTools;

class DisclaimerState extends MusicBeatState
{
	public static var seenDisclaimer:Bool;

	var warningbox:FlxSprite;
	var pussybox:FlxSprite;
	var continuebox:FlxSprite;
	var warningtext:FlxSprite;
	var pussytext:FlxSprite;
	var continuetext:FlxSprite;
	var selection:Float = 0;
	var canselect:Bool = false;

	override public function create():Void
	{
		super.create();
		if (FlxG.save.data.seenDisclaimer == null || FlxG.save.data.seenDisclaimer == false) {
			startDisclaimer();
		}
		else {
			Main.switchState(this, new TitleState());
		}
	}

	function startDisclaimer() {
		warningbox = new FlxSprite();
		warningbox.frames = Paths.getSparrowAtlas('menus/title/selectors');
		warningbox.animation.addByPrefix('warningbox', 'warningbox', 24, true);
		warningbox.animation.play('warningbox');
		warningbox.screenCenter();
		warningbox.x -= 235;
		warningbox.y -= 150;
		warningbox.setGraphicSize(Std.int(warningbox.width * 2.7));
		warningbox.updateHitbox();
		warningbox.scale.set(2.5, 2.5);
		warningbox.alpha = 0;

		pussybox = new FlxSprite();
		pussybox.frames = Paths.getSparrowAtlas('menus/title/selectors');
		pussybox.animation.addByPrefix('pussybox', 'pussybox', 24, true);
		pussybox.animation.play('pussybox');
		pussybox.screenCenter();
		pussybox.y -= 100;
		pussybox.x -= 185;
		pussybox.alpha = 0;

		continuebox = new FlxSprite();
		continuebox.frames = Paths.getSparrowAtlas('menus/title/selectors');
		continuebox.animation.addByPrefix('continuebox', 'continuebox', 24, true);
		continuebox.animation.play('continuebox');
		continuebox.screenCenter();
		continuebox.y -= 100;
		continuebox.x += 185;
		continuebox.alpha = 0;

		warningtext = new FlxSprite();
		warningtext.frames = Paths.getSparrowAtlas('menus/title/selectortext');
		warningtext.animation.addByPrefix('warningtext', 'warningtext', 24, true);
		warningtext.animation.play('warningtext');
		warningtext.screenCenter();
		warningtext.x -= warningbox.x - 115;
		warningtext.y -= warningbox.y - 25;
		warningtext.setGraphicSize(Std.int(warningtext.width * 2.2));
		warningtext.updateHitbox();
		warningtext.scale.set(2.5, 2.5);
		warningtext.alpha = 0;

		pussytext = new FlxSprite();
		pussytext.frames = Paths.getSparrowAtlas('menus/title/selectortext');
		pussytext.animation.addByPrefix('pussytext', 'pussytext', 24, true);
		pussytext.animation.addByPrefix('selectpussytext', 'selectpussytext', 24, true);
		pussytext.animation.play('selectpussytext');		
		pussytext.screenCenter();
		pussytext.y += 100;
		pussytext.x -= 185;
		pussytext.scale.set(0.5, 0.5);
		pussytext.alpha = 0;

		continuetext = new FlxSprite();
		continuetext.frames = Paths.getSparrowAtlas('menus/title/selectortext');
		continuetext.animation.addByPrefix('continuetext', 'continuetext', 24, true);
		continuetext.animation.addByPrefix('selectcontinuetext', 'selectcontinuetext', 24, true);
		continuetext.animation.play('continuetext');
		continuetext.screenCenter();
		continuetext.y += 100;
		continuetext.x += 185;
		continuetext.scale.set(0.5, 0.5);
		continuetext.alpha = 0;

		add(pussybox);
		add(continuebox);	
		add(pussytext);
		add(continuetext);
		add(warningbox);
		add(warningtext);

		new FlxTimer().start(0.6, function(tmr:FlxTimer) {			
			FlxTween.tween(warningbox, {'scale.x': 1, 'scale.y': 1, alpha: 1}, 0.5, {
				ease: FlxEase.backOut,
				onComplete: function(twn:FlxTween)
				{
					new FlxTimer().start(0.5, function(tmr:FlxTimer) {
						FlxTween.tween(warningtext, {'scale.x': 1, 'scale.y': 1, alpha: 1}, 0.5, {ease: FlxEase.backOut});
						new FlxTimer().start(1.5, function(tmr:FlxTimer) {
							continuebox.alpha = 1;
							pussybox.alpha = 1;
							FlxTween.tween(pussybox, {y: pussybox.y + 200}, 1, {ease: FlxEase.bounceOut});	
							new FlxTimer().start(0.3, function(tmr:FlxTimer) {
								FlxTween.tween(continuebox, {y: continuebox.y + 200}, 1, {
									ease: FlxEase.bounceOut, 
									onComplete: function(twn:FlxTween)
										{
											new FlxTimer().start(0.5, function(tmr:FlxTimer) {
												FlxTween.tween(pussytext, {'scale.x': 1, 'scale.y': 1, alpha: 1}, 0.5, {ease: FlxEase.backOut});
												new FlxTimer().start(0.3, function(tmr:FlxTimer) {
													FlxTween.tween(continuetext, {'scale.x': 1, 'scale.y': 1, alpha: 1}, 0.5, {ease: FlxEase.backOut});
													canselect = true;
												});	
											});	
										}
								});														
							});						
						});	
					});	
				}
			});	
		});	
	}

	function updateDisclaimer() {
		var leftright:Bool = (controls.UI_LEFT_P || controls.UI_RIGHT_P);
		var accept:Bool = controls.ACCEPT;	

		if (canselect) {
			if (leftright) {	
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.5);
				if (selection == 0)	{
					new FlxTimer().start(0.02, function(tmr:FlxTimer) {
						selection = 1;
						pussytext.animation.play('pussytext');
						continuetext.animation.play('selectcontinuetext');	
					});	
				}
				else if (selection == 1) {
					new FlxTimer().start(0.02, function(tmr:FlxTimer) {
						selection = 0;
						pussytext.animation.play('selectpussytext');
						continuetext.animation.play('continuetext');
					});		
				}
			}

			if (accept)
			{
				canselect = false;
				if (selection == 0) {
					FlxG.camera.flash(FlxColor.WHITE, 1);
					FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
					new FlxTimer().start(0.5, function(tmr:FlxTimer) {
						FlxG.sound.play(Paths.sound('HEHEHEHA'), 0.7);
						new FlxTimer().start(1.3, function(tmr:FlxTimer) {
							System.exit(0);
						});				
					});		
				}		
				else if (selection == 1) {
					FlxG.camera.flash(FlxColor.WHITE, 1);
					FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
					new FlxTimer().start(0.6, function(tmr:FlxTimer) {
						if (FlxG.save.data.seenDisclaimer == null 
							|| FlxG.save.data.seenDisclaimer == false)
							{
								FlxG.save.data.seenDisclaimer = true;
								FlxG.save.flush();
							}
							Main.switchState(this, new TitleState());
					});				
				}
			}
		}
	}

	override function update(elapsed:Float)
	{
		if (FlxG.save.data.seenDisclaimer == null || FlxG.save.data.seenDisclaimer == false) {
			updateDisclaimer();
		}

		super.update(elapsed);
	}

	override function beatHit()
	{
		super.beatHit();
		FlxG.log.add(curBeat);
	}
}
