package everything;

import scripts.FunkinHScript;
import scripts.FunkinHScript.HScriptState;
import flixel.util.FlxDestroyUtil;
import flixel.FlxState;

class FNFGame extends FlxGame {
	override function switchState():Void
	{
        #if SCRIPTABLE_STATES
		if (_nextState is MusicBeatState){
			var state:MusicBeatState = cast _nextState;
            if (state.canBeScripted){
                var className = Type.getClassName(Type.getClass(_nextState));
                for (filePath in Paths.getFolders("states"))
                {
					var fileName = 'override/$className.hscript';
					if (Paths.exists(filePath + fileName)){
                        try{
							FlxDestroyUtil.destroy(cast(_nextState, FlxState)); //
						}
						catch (err){trace(err);}
                        _nextState = new HScriptState(fileName);
						trace(fileName);
                        return super.switchState();
                    }
                }
            }
        }
        #end



        return super.switchState();
    }
}
