package;

/*
	Aw hell yeah! something I can actually work on!
 */
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import lime.utils.Assets;
import meta.CoolUtil;
import openfl.display.BitmapData;
import openfl.display3D.textures.Texture;
import openfl.media.Sound;
import openfl.system.System;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import sys.FileSystem;
import sys.io.File;

using StringTools;

class Paths
{
	// Here we set up the paths class. This will be used to
	// Return the paths of assets and call on those assets as well.
	public static var SOUND_EXT = "ogg";

	// level we're loading
	static var currentLevel:String = 'assets';
	static var previousLevel:String = 'assets';

	// set the current level top the condition of this function if called
	static public function setCurrentLevel(name:String)
	{
		if (currentLevel != name) {
			previousLevel = currentLevel;
			currentLevel = name.toLowerCase();
		}
	}

	static public function revertCurrentLevel() {
		var tempCurLevel = currentLevel;
		currentLevel = previousLevel;
		previousLevel = tempCurLevel;
	}

	// stealing my own code from psych engine
	public static var currentTrackedAssets:Map<String, FlxGraphic> = [];
	public static var currentTrackedTextures:Map<String, Texture> = [];
	public static var currentTrackedSounds:Map<String, Sound> = [];
	
	public static function excludeAsset(key:String)
	{
		if (!dumpExclusions.contains(key))
			dumpExclusions.push(key);
	}

	public static var dumpExclusions:Array<String> = [];

	/// haya I love you for the base cache dump I took to the max
	public static function clearUnusedMemory()
	{
		// clear non local assets in the tracked assets list
		var counter:Int = 0;
		for (key in currentTrackedAssets.keys())
		{
			if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key))
			{
				var obj = currentTrackedAssets.get(key);
				if (obj != null)
				{
					var isTexture:Bool = currentTrackedTextures.exists(key);
					if (isTexture)
					{
						var texture = currentTrackedTextures.get(key);
						texture.dispose();
						texture = null;
						currentTrackedTextures.remove(key);
					}
					@:privateAccess
					if (openfl.Assets.cache.hasBitmapData(key))
					{
						openfl.Assets.cache.removeBitmapData(key);
						FlxG.bitmap._cache.remove(key);
					}
					trace('removed $key, ' + (isTexture ? 'is a texture' : 'is not a texture'));
					obj.destroy();
					currentTrackedAssets.remove(key);
					counter++;
				}
			}
		}
		trace('removed $counter assets');
		// run the garbage collector for good measure lmfao
		System.gc();
	}



	// define the locally tracked assets
	public static var localTrackedAssets:Array<String> = [];

	public static function clearStoredMemory(?cleanUnused:Bool = false)
	{
		// clear anything not in the tracked assets list
		@:privateAccess
		for (key in FlxG.bitmap._cache.keys())
		{
			var obj = FlxG.bitmap._cache.get(key);
			if (obj != null && !currentTrackedAssets.exists(key) && !dumpExclusions.contains(key))
			{
				openfl.Assets.cache.removeBitmapData(key);
				FlxG.bitmap._cache.remove(key);
				obj.destroy();
			}
		}

		// clear all sounds that are cached
		for (key in currentTrackedSounds.keys())
		{
			if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key) && key != null)
			{
				Assets.cache.clear(key);
				currentTrackedSounds.remove(key);
			}
		}	
		// flags everything to be cleared out next unused memory clear
		localTrackedAssets = [];
	}

	public static function returnGraphic(key:String, ?library:String, ?textureCompression:Bool = false)
	{
		var path = getPath('images/$key.png', IMAGE, library);
		if (library != null) {
			// do dumbshit
			return FlxG.bitmap.add(path, true, path);
		} else {
			if (FileSystem.exists(path))
			{
				if (!currentTrackedAssets.exists(key))
				{
					var bitmap:BitmapData = BitmapData.fromFile(path);
					var newGraphic:FlxGraphic;
					if (textureCompression)
					{
						var texture = FlxG.stage.context3D.createTexture(bitmap.width, bitmap.height, BGRA, true, 0);
						texture.uploadFromBitmapData(bitmap);
						currentTrackedTextures.set(key, texture);
						bitmap.dispose();
						bitmap.disposeImage();
						bitmap = null;
						trace('new texture $key, bitmap is $bitmap');
						newGraphic = FlxGraphic.fromBitmapData(BitmapData.fromTexture(texture), false, key, false);
					}
					else
					{
						newGraphic = FlxGraphic.fromBitmapData(bitmap, false, key, false);
						trace('new bitmap $key, not textured');
					}
					newGraphic.persist = true;
					currentTrackedAssets.set(key, newGraphic);
				}
				localTrackedAssets.push(key);
				return currentTrackedAssets.get(key);
			}
		}
		
		trace('oh no ' + key + ' is returning null NOOOO');
		return null;
	}

	public static function returnSound(path:String, key:String, ?library:String) {
		// I hate this so god damn much
		var gottenPath:String = getPath('$path/$key.$SOUND_EXT', SOUND, library);
		gottenPath = gottenPath.substring(gottenPath.indexOf(':') + 1, gottenPath.length);
		// trace(gottenPath);
		if (!currentTrackedSounds.exists(gottenPath)) {
			if (library != null)
				currentTrackedSounds.set(gottenPath, OpenFlAssets.getSound(getPath('$path/$key.$SOUND_EXT', SOUND, library)));
			else
				currentTrackedSounds.set(gottenPath, Sound.fromFile('./' + gottenPath));
		}
		localTrackedAssets.push(key);
		return currentTrackedSounds.get(gottenPath);
	}

	//
	public static function getPath(file:String, type:AssetType, ?library:Null<String>) {
		if (library != null)
			return getLibraryPath(file, type, library);
		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, type:AssetType, library:String = "preload") {
		return if (library == "preload" || library == "default" || library.contains('assets')) 
			getPreloadPath(file); 
		else getLibraryPathForce(file, type, library);
	}

	static function getLibraryPathForce(file:String, type:AssetType, library:String = 'assets') {
		var returnPath:String = '$library:$library/$file';
		if (!OpenFlAssets.exists(returnPath, type))
			returnPath = CoolUtil.swapSpaceDash(returnPath);
		return returnPath;
	}

	static public function shader(name:String) {
		return File.getContent('./assets/shaders/$name.frag');
	}

	static function getPreloadPath(file:String) {
		var returnPath:String = '$currentLevel/$file';
		if (!FileSystem.exists(returnPath))
			returnPath = CoolUtil.swapSpaceDash(returnPath);
		return returnPath;
	}

	static public function file(file:String, type:AssetType = TEXT, ?library:String) {
		return getPath(file, type, library);
	}

	static public function txt(key:String, ?library:String) {
		return getPath('$key.txt', TEXT, library);
	}

	static public function video(key:String) {
		return 'assets/cutscenes/$key.mp4';
	}

	static public function xml(key:String, ?library:String) {
		return getPath('data/$key.xml', TEXT, library);
	}

	static public function json(key:String, ?library:String) {
		return getPath('songs/$key.json', TEXT, library);
	}

	static public function module(key:String, ?library:String)
	{
		return getPath('$key.hxs', TEXT, library);
	}

	static public function songJson(song:String, secondSong:String, old:Bool, ?library:String)
		return getPath('songs/${song.toLowerCase()}/${secondSong.toLowerCase() + (old ? '_old' : '')}.json', TEXT, library);

	static public function sound(key:String, ?library:String):Dynamic {
		var sound:Sound = returnSound('sounds', key, library);
		return sound;
	}
	
	static public function soundRandom(key:String, min:Int, max:Int, ?library:String) {
		return sound(key + FlxG.random.int(min, max), library);
	}

	static public function music(key:String, ?library:String):Dynamic {
		var file:Sound = returnSound('music', key, library);
		return file;
	}

	static public function voices(song:String, old:Bool, ?library:String):Any {
		var songKey:String = '${CoolUtil.swapSpaceDash(song.toLowerCase())}/Voices' + (old ? '_old' : '');
		var voices = returnSound('songs', songKey, library);
		return voices;
	}

	static public function inst(song:String, old:Bool, ?library:String):Any	{
		var songKey:String = '${CoolUtil.swapSpaceDash(song.toLowerCase())}/Inst' + (old ? '_old' : '');
		var inst = returnSound('songs', songKey, library);
		return inst;
	}

	static public function image(key:String, ?library:String, ?textureCompression:Bool = false) {
		var returnAsset:FlxGraphic = returnGraphic(key, library, textureCompression);
		return returnAsset;
	}

	static public function font(key:String) {
		return 'assets/fonts/$key';
	}

	static public function getSparrowAtlas(key:String, ?compression:Bool = false, ?library:String) {
		var graphic:FlxGraphic = returnGraphic(key, library, compression);
		var fileContents;
		if (library == null)
			fileContents = File.getContent(file('images/$key.xml', library));
		else
			fileContents = Assets.getText(file('images/$key.xml', library));
		return (FlxAtlasFrames.fromSparrow(graphic, fileContents));
	}

	static public function getPackerAtlas(key:String, ?library:String)
		return (FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library)));
}
