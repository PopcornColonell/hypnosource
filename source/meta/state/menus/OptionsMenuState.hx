package meta.state.menus;

import gameObjects.userInterface.menu.Textbox;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import meta.MusicBeat.MusicBeatSubState;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import gameObjects.userInterface.menu.Checkmark;
import gameObjects.userInterface.menu.Selector;
import meta.MusicBeat.MusicBeatState;
import meta.data.dependency.Discord;
import meta.data.dependency.FNFSprite;
import meta.data.font.Alphabet;


/**
 * Options
 * 
 * Preferences
 * Controls
 * Mechanics
 * Effects
 * Exit
 * 
 */

/**
 * Preferences
 * 
 * Downscroll
 * Centered Notefield
 * Framerate Cap
 * 
 * Camera Movement
 * Note Splashes
 * Opaque Arrows
 * Opaque Holds
 * 
 * Antialiasing
 * Colorblind Filter (?)
 * 
 * FPS Counter
 * Memory Counter
 */

/**
 * Controls
 * 
 * Left
 * Down
 * Mechanic
 * Up
 * Right
 * 
 * Accept
 * Back
 * Pause
 * 
 * UI Left
 * UI Down
 * UI Up
 * UI Right
 * Edit Offset
 */

/**
 * Mechanics
 * 
 * Pendulum
 * Rate per Beats (2, min 1, max 8)
 * Psyshock (true by default)
 * Psyshock Damage (1.0)
 * Ghost Tapping (most likely not as it ruins the mechanic/requires a rewrite to function properly based on accuracy)
 * 
 * Typhlosion
 * Rate of Fire (2 by default, min 1, max 4), rate of how many times used per drain 
 * Pain Split (true by default)
 * 
 * Feraligatr
 * Time Before Death (in seconds) (default 10, min 5, max 15)
 * Accuracy Percentage (default 90, min 70, max 99)
 * 
 * Unowns
 * Time Multiplier (1 default, min 0.5, max 2)
 * Lock Arrows (false by default)
 * Disable Time (locked unless using lock arrows, which it gives you the option)
 * 
 * Missingno
 * Glitching (true default)
 * 
 * Buried
 * Gengar Notes (true default)
 * Muk Splashes (true default)
 * 
 * Death Toll 
 * 5th Key (true by default)
 * 
 * Pasta Night
 * MX Pow Block (true by default)
 * 
 * Bygone Purpose
 * Floaty-Note-y (true by default)
 */
class OptionsMenuState extends MusicBeatSubState
{
	override public function create():Void
	{
		super.create();

		var bg:FlxSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		bg.setGraphicSize(FlxG.width, FlxG.height);
		bg.screenCenter();
		bg.alpha = 0;

		FlxTween.tween(bg, {alpha: 1}, 0.25, {ease: FlxEase.circOut});
		var centralTextbox:Textbox = new Textbox(0, 0);
		centralTextbox.screenCenter();
		centralTextbox.scale.set(3, 3);

		FlxTween.tween(centralTextbox, {boxWidth: 12, boxHeight: 16}, 0.25, {ease: FlxEase.circOut});

		add(bg);
		add(centralTextbox);
	}
}
