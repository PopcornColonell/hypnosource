package meta.state.charting;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxStrip;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxTiledSprite;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUITabMenu;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.tile.FlxGraphicsShader;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import gameObjects.userInterface.menu.DebugUI.UIBox;
import gameObjects.userInterface.menu.DebugUI;
import gameObjects.userInterface.notes.Note;
import haxe.io.Bytes;
import lime.media.AudioBuffer;
import lime.media.vorbis.VorbisFile;
import meta.MusicBeat.MusicBeatState;
import openfl.display.BitmapData;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;
import openfl.media.Sound;
import sys.thread.Thread;

class TestState extends MusicBeatState
{
	override public function create()
	{
		super.create();
		FlxG.mouse.useSystemCursor = false;
		FlxG.mouse.visible = true;

		generateBackground();

		var songMusic:FlxSound = new FlxSound().loadEmbedded(Paths.inst('isotope', false), false, true);
		FlxG.sound.list.add(songMusic);

		var visualiser:FlxGraphicsShader = new FlxGraphicsShader('', Paths.shader('visualizer'));
		var falseGraphic:FlxSprite = new FlxSprite().makeGraphic(1280, 720);
		falseGraphic.shader = visualiser;
		add(falseGraphic);
		// FlxG.camera.setFilters();
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
	}

	private function generateBackground()
	{
		// var coolGrid = new FlxBackdrop(null, 1, 1, true, true, 1, 1);
		// coolGrid.loadGraphic(Paths.image('UI/forever/base/chart editor/grid'));
		// coolGrid.alpha = (32 / 255);
		// add(coolGrid);

		// gradient
		var coolGradient = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height,
			FlxColor.gradient(FlxColor.fromRGB(188, 158, 255, 200), FlxColor.fromRGB(80, 12, 108, 255), 16));
		coolGradient.alpha = (32 / 255);
		add(coolGradient);
	}
}
