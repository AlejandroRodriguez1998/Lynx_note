"""Normalize the final voice/music mix and enable progressive MP4 playback."""
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
source = ROOT/'exports/lynx-note-tutorial.mp4'
target = source.with_name('lynx-note-tutorial-normalized.mp4')
analysis = subprocess.run(['ffmpeg','-hide_banner','-i',str(source),'-af','loudnorm=I=-16:TP=-1.5:LRA=11:print_format=json','-f','null','-'],capture_output=True,text=True,check=True)
match = re.findall(r'\{\s*"input_i".*?\}',analysis.stderr,re.S)[-1]
stats = json.loads(match)
audio_filter = (
    'loudnorm=I=-16:TP=-1.5:LRA=11:linear=true:'
    f'measured_I={stats["input_i"]}:measured_TP={stats["input_tp"]}:'
    f'measured_LRA={stats["input_lra"]}:measured_thresh={stats["input_thresh"]}:'
    f'offset={stats["target_offset"]}'
)
subprocess.run(['ffmpeg','-y','-hide_banner','-loglevel','warning','-i',str(source),'-c:v','copy','-af',audio_filter,'-ar','48000','-c:a','aac','-b:a','192k','-metadata','title=Lynx Note | Demo y tutorial','-metadata','artist=Alejandro Paniagua Rodríguez y Ángela Gijón Flores','-movflags','+faststart',str(target)],check=True)
target.replace(source)
(ROOT/'exports/audio-analysis.json').write_text(json.dumps(stats,indent=2))
print(source)
