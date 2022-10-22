package meta.state;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import meta.MusicBeat.MusicBeatState;
import sys.io.File;

class ShaderState extends MusicBeatState {
    override public function create() {
        var centerText:FlxText = new FlxText().setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE);
		centerText.text = 'throw me the file that got dumped\nin your fuckin root folder\nplease and thanks\n';
        // centerText.updateHitbox();
        centerText.screenCenter();
        // centerText.x = FlxG.width / 2 - centerText.width;
        add(centerText);

	    var gl = lime.graphics.opengl.GL;
		var user =
			{
				SHADING_LANGUAGE_VERSION: gl.SHADING_LANGUAGE_VERSION,
			    CURRENT_PROGRAM: gl.CURRENT_PROGRAM,
			    VERSION: gl.VERSION,
			    FLOAT_VERSION: gl.version,
            };
		var content:String = haxe.Json.stringify(user);
	    File.saveContent('./glsl.txt', content);
    }
}