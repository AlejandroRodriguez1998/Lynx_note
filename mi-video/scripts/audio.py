"""Generate Spanish narration, word-timed subtitles and an original quiet soundtrack."""
import asyncio
import json
import math
import subprocess
import wave
from pathlib import Path

import edge_tts
import numpy as np

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'public/audio'
OUT.mkdir(parents=True, exist_ok=True)

def duration(path):
    return float(subprocess.check_output(['ffprobe', '-v', 'error', '-show_entries', 'format=duration', '-of', 'default=nw=1:nk=1', str(path)]))

async def main():
    scenes = json.loads((ROOT / 'src/scenes.json').read_text())
    offset = 0
    srt = []
    def stamp(t):
        ms = round(t * 1000)
        return f'{ms//3600000:02}:{ms//60000%60:02}:{ms//1000%60:02},{ms%1000:03}'
    for scene in scenes:
        path = OUT / f'{scene["id"]}.mp3'
        words_path = path.with_suffix('.json')
        if not path.exists() or not words_path.exists():
            words = []
            for attempt in range(3):
                try:
                    words = []
                    with path.open('wb') as f:
                        voice = edge_tts.Communicate(scene['voice'], 'es-ES-AlvaroNeural', rate='+2%', boundary='WordBoundary')
                        async for item in voice.stream():
                            if item['type'] == 'audio':
                                f.write(item['data'])
                            elif item['type'] == 'WordBoundary':
                                words.append({'text': item['text'], 'start': item['offset']/1e7, 'end': (item['offset']+item['duration'])/1e7})
                    words_path.write_text(json.dumps(words, ensure_ascii=False))
                    break
                except Exception:
                    if attempt == 2:
                        raise
                    await asyncio.sleep(2)
        words = json.loads(words_path.read_text())
        scene['seconds'] = max(scene['seconds'], math.ceil(duration(path) + 1.7))
        scene['from'] = offset
        scene['captions'] = []
        group = []
        for word in words:
            group.append(word)
            if len(' '.join(x['text'] for x in group)) > 68 or word == words[-1]:
                caption = {'text': ' '.join(x['text'] for x in group), 'start': group[0]['start'] + .5, 'end': group[-1]['end'] + .65}
                scene['captions'].append(caption)
                srt.append(f'{len(srt)+1}\n{stamp(offset+caption["start"])} --> {stamp(offset+caption["end"])}\n{caption["text"]}\n')
                group = []
        print(scene['id'], scene['seconds'], 'voice', round(duration(path), 2), flush=True)
        offset += scene['seconds']
    (ROOT/'src/timeline.json').write_text(json.dumps(scenes, ensure_ascii=False, indent=2))
    (ROOT/'exports/lynx-note-subtitulos.srt').write_text('\n'.join(srt))
    # Original instrumental: soft keys and warm sustained chords, no sampled music.
    sr = 44100
    result = np.zeros((int((offset+1)*sr), 2), dtype=np.float32)
    rng = np.random.default_rng(11)
    chords = [[50,57,60,65], [46,53,58,62], [53,60,64,69], [48,55,60,64]]
    for bar in range(math.ceil(offset/4)):
        start = bar*4
        for j, midi in enumerate(chords[bar%4]):
            length = 5
            t = np.arange(int(length*sr))/sr
            freq = 440*2**((midi-69)/12)
            env = (1-np.exp(-t/0.35))*np.exp(-t/2)*(np.minimum((length-t)/.6, 1))
            tone = (np.sin(2*np.pi*freq*t) + .13*np.sin(2*np.pi*freq*2*t))*.038*env
            pos = int(start*sr)
            n = min(len(tone), len(result)-pos)
            pan = j/3
            result[pos:pos+n, 0] += tone[:n]*(.7-.25*pan)
            result[pos:pos+n, 1] += tone[:n]*(.45+.25*pan)
        # A light upper-register motif gives the demo a gentle pulse.
        for beat in range(4):
            midi = chords[bar%4][beat]+24
            t = np.arange(int(1.7*sr))/sr
            tone = np.sin(2*np.pi*440*2**((midi-69)/12)*t)*np.exp(-t*4)*(1-np.exp(-t*100))*.025
            pos = int((start+beat)*sr)
            n = min(len(tone), len(result)-pos)
            result[pos:pos+n] += tone[:n,None]
    fade = np.minimum(np.arange(len(result))/sr/3, 1)*np.minimum((len(result)-np.arange(len(result)))/sr/4, 1)
    result *= fade[:,None]
    with wave.open(str(OUT/'music.wav'), 'wb') as f:
        f.setnchannels(2); f.setsampwidth(2); f.setframerate(sr)
        f.writeframes((np.clip(result, -1, 1)*32767).astype('<i2').tobytes())
    print('Total:', offset, 'seconds', flush=True)

asyncio.run(main())
