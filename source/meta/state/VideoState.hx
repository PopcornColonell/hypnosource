package meta.state;

import vlc.MP4Handler;
import sys.FileSystem;
import meta.MusicBeat.MusicBeatState;

class VideoState extends MusicBeatState {

    public static var videoName:String;

    override public function create() {
        super.create();

        #if VIDEOS_ALLOWED
        var filepath:String = Paths.video(videoName);
        if (!FileSystem.exists(filepath)) {
            close();
            return;
        }

        var video:MP4Handler = new MP4Handler();
        video.playVideo(filepath);
        video.finishCallback = function() {
            close();
            return;
        }
        #end
    }

    public function close() 
        Main.switchState(this, new PlayState());
}