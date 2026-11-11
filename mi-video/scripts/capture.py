"""Record actual browser interactions against the isolated Rails demo."""
import asyncio
import json
import os
import subprocess
import time
from pathlib import Path

from playwright.async_api import async_playwright, expect

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT/'public/captures'
OUT.mkdir(parents=True, exist_ok=True)
BASE = os.environ.get('LYNX_DEMO_URL', 'http://127.0.0.1:3100')
assert BASE.startswith(('http://127.0.0.1:', 'http://localhost:')), 'Local demo only'
CURSOR = """document.addEventListener('DOMContentLoaded',()=>{
 const c=document.createElement('div');c.id='demo-pointer';
 c.innerHTML='<svg width="30" height="36" viewBox="0 0 30 36"><path d="M3 2L4 28L11 21L17 33L22 30L16 19L26 18Z" fill="#173c30" stroke="white" stroke-width="2.5" stroke-linejoin="round"/></svg>';
 c.style.cssText='position:fixed;top:0;left:0;pointer-events:none;z-index:2147483647;transform:translate(-50px,-50px);filter:drop-shadow(0 2px 2px #0005)';document.body.append(c);
 document.addEventListener('mousemove',e=>c.style.transform=`translate(${e.clientX}px,${e.clientY}px)`);
 document.addEventListener('mousedown',e=>{const r=document.createElement('div');r.style.cssText=`position:fixed;left:${e.clientX-20}px;top:${e.clientY-20}px;width:40px;height:40px;border:3px solid #4d8a37;border-radius:50%;pointer-events:none;z-index:2147483646`;document.body.append(r);r.animate([{transform:'scale(.4)',opacity:1},{transform:'scale(1.6)',opacity:0}],{duration:500}).onfinish=()=>r.remove();});
});"""
evidence_path = OUT/'verification.json'
evidence = json.loads(evidence_path.read_text()) if evidence_path.exists() else []

async def pause(p, seconds=.7):
    await p.wait_for_timeout(seconds*1000)

async def go(p, route):
    response = await p.goto(BASE+route, wait_until='networkidle')
    assert response.status < 400, f'{route}: HTTP {response.status}'
    await expect(p.locator('body')).not_to_contain_text('Exception caught')

async def click(p, loc):
    await loc.scroll_into_view_if_needed()
    box = await loc.bounding_box()
    await p.mouse.move(box['x']+box['width']/2, box['y']+box['height']/2, steps=15)
    await pause(p,.25)
    await loc.click()
    await pause(p,.55)

async def type_into(p, loc, text, delay=30):
    await click(p, loc)
    await loc.fill('')
    await loc.press_sequentially(text, delay=delay)
    await pause(p,.35)

async def login(p, email='alex@example.com'):
    await go(p, '/login')
    await p.locator('#email').fill(email)
    await p.locator('#password').fill('DemoLynx2026!')
    await p.get_by_role('button', name='Log in', exact=True).click()
    await p.wait_for_url(BASE+'/')
    await pause(p,.7)

async def access(p):
    await go(p, '/signup')
    await pause(p,2)
    await go(p, '/login')
    await type_into(p, p.locator('#email'), 'alex@example.com',45)
    await type_into(p, p.locator('#password'), 'DemoLynx2026!',45)
    await click(p, p.get_by_role('button', name='Log in', exact=True))
    await p.wait_for_url(BASE+'/')
    await expect(p.locator('header')).to_contain_text('Collections')
    evidence.append('Login accepted; authenticated navigation visible')

async def notes(p):
    await go(p, '/notes')
    await pause(p,1.5)
    await click(p, p.locator('.listSelected').filter(has_text='Ideas para mi portfolio'))
    await expect(p.locator('#content')).to_contain_text('Publicar el portfolio')
    await pause(p,3)
    await click(p, p.locator('.listSelected').filter(has_text='Apuntes de Sistemas Web'))
    await expect(p.locator('#content')).to_contain_text('Modelo, Vista y Controlador')
    evidence.append('Note selection fetches actual note JSON and renders saved text and lists')

async def create(p):
    await go(p, '/notes')
    await click(p,p.get_by_role('link', name='New Note', exact=True))
    await type_into(p,p.locator('#note_title'),'Plan de la presentación',30)
    await click(p,p.get_by_role('button',name='Add Text',exact=True))
    await type_into(p,p.locator('#contentContainer textarea'),'Objetivo: presentar Lynx Note con una demo clara y práctica.',22)
    await click(p,p.get_by_role('button',name='Add List',exact=True))
    for i,text in enumerate(['Preparar las notas','Organizar el proyecto','Compartir con el equipo']):
        await type_into(p,p.locator('.list-input').nth(i),text,22)
    await click(p,p.get_by_role('button',name='Add Image',exact=True))
    await p.locator('input[type=file]').set_input_files(str(ROOT/'public/icono.png'))
    await pause(p,1.2)
    await click(p,p.get_by_role('button',name='Create Note',exact=True))
    await p.wait_for_url('**/notes?number=*')
    await expect(p.locator('#content')).to_contain_text('Objetivo: presentar Lynx Note')
    await expect(p.locator('#content img')).to_be_visible()
    await p.screenshot(path=str(OUT/'note.png'))
    evidence.append('Created note through multipart form with text, three list items and uploaded PNG; saved content rendered')

async def collections(p):
    await go(p,'/collections')
    await click(p,p.get_by_role('link',name='New Collection',exact=True))
    await type_into(p,p.locator('#collection_name'),'Proyecto web',50)
    await click(p,p.get_by_role('button',name='New Collection',exact=True))
    await p.wait_for_url('**/collections')
    await go(p,'/notes')
    await click(p,p.locator('.listSelected').filter(has_text='Plan de la presentación'))
    await click(p,p.locator('#content a[href$="/edit"]'))
    row = p.locator('#listContent li').filter(has_text='Proyecto web')
    await click(p,row.locator('input[type=checkbox]'))
    await p.locator('input[type=submit]').scroll_into_view_if_needed()
    await pause(p,1)
    await click(p,p.get_by_role('button',name='Edit Note',exact=True))
    await p.wait_for_url('**/notes?number=*')
    await go(p,'/collections')
    await expect(p.locator('main')).to_contain_text('Proyecto web')
    await expect(p.locator('main')).to_contain_text('Plan de la presentación')
    await p.screenshot(path=str(OUT/'collections.png'))
    evidence.append('Created collection and persisted note membership through edit form')

async def friends(p):
    await go(p,'/friendships')
    await pause(p,3)
    await click(p,p.get_by_role('button',name='Accept',exact=True))
    await pause(p,.6)
    # The original application uses a confirmation toast for accepting a request.
    await click(p,p.locator('#toast-delete button').filter(has_text='Accept'))
    await pause(p,1)
    await expect(p.locator('main')).to_contain_text('Leo')
    await click(p,p.get_by_role('link',name='New friendship',exact=True))
    await pause(p,2)
    await go(p,'/friendships')
    await click(p,p.get_by_role('link',name='Reunión del equipo',exact=True))
    await expect(p.locator('main')).to_contain_text('Propuesta de Sara')
    evidence.append('Accepted pending friendship via confirmation and opened a note shared by Sara')

async def share(p):
    await go(p,'/notes')
    await click(p,p.locator('.listSelected').filter(has_text='Plan de la presentación'))
    await pause(p,1.3)
    await click(p,p.locator('#content button[data-bs-target="#modalShare"]'))
    await expect(p.locator('#modalShare')).to_be_visible()
    await pause(p,1)
    await click(p,p.locator('#contentSharing li').filter(has_text='sara@example.com').locator('input[type=checkbox]'))
    await pause(p,1)
    await click(p,p.get_by_role('button',name='Sharing',exact=True))
    await p.wait_for_url('**/notes?number=*')
    await expect(p.locator('main')).to_contain_text('The note has been shared')
    evidence.append('Shared new note with Sara through SharingController#create')

async def receive(p):
    await go(p,'/logout')
    await login(p,'sara@example.com')
    await click(p,p.locator('#bellIcon'))
    await expect(p.locator('#contentNotification')).to_contain_text('shared a note')
    await pause(p,2)
    await go(p,'/friendships')
    await click(p,p.get_by_role('link',name='Plan de la presentación',exact=True))
    await expect(p.locator('main')).to_contain_text('Objetivo: presentar Lynx Note')
    evidence.append('Separate Sara session received notification and read the shared note; complete sharing flow verified')

async def admin(p):
    await go(p,'/logout')
    await login(p,'admin@example.com')
    await click(p,p.locator('header a[href="/admin"]'))
    await pause(p,2)
    await p.screenshot(path=str(OUT/'admin.png'))
    await click(p,p.locator('main').get_by_role('link',name='Users',exact=True))
    await expect(p.locator('main')).to_contain_text('alex@example.com')
    await pause(p,2)
    await go(p,'/admin/notes')
    await expect(p.locator('main')).to_contain_text('Plan de la presentación')
    evidence.append('Admin role sees dashboard plus actual user and note records')

async def mobile(p):
    await login(p)
    await go(p,'/notes')
    await pause(p,1.5)
    await click(p,p.get_by_role('link',name='Plan de la presentación',exact=True))
    await expect(p.locator('main')).to_contain_text('Objetivo: presentar Lynx Note')
    await pause(p,2)
    await click(p,p.locator('.navbar-toggler'))
    await pause(p,1.5)
    await click(p,p.locator('header').get_by_role('link',name='Collections',exact=True))
    await expect(p.locator('main')).to_contain_text('Proyecto web')
    evidence.append('Mobile user agent uses individual note view and responsive collapsed navigation')

async def record(context, scene, action):
    p = await context.new_page()
    await p.wait_for_timeout(200)
    started = time.monotonic()
    errors = []
    p.on('pageerror',lambda e: errors.append(str(e)))
    try:
        await action(p)
        elapsed = time.monotonic()-started
        await pause(p,max(1,scene['seconds']-elapsed+.5))
        await p.screenshot(path=str(OUT/f'{scene["id"]}-last.png'))
    except Exception:
        await p.screenshot(path=str(OUT/'failure.png'))
        print(await p.locator('body').inner_text(),flush=True)
        raise
    finally:
        video = p.video
        await p.close()
        raw = OUT/'raw'/f'{scene["id"]}-complete.webm'
        await video.save_as(str(raw))
        await video.delete()
    target = OUT/f'{scene["id"]}.mp4'
    subprocess.run(['ffmpeg','-y','-v','error','-i',str(raw),'-vf','tpad=stop_mode=clone:stop_duration=60,fps=30','-t',str(scene['seconds']),'-an','-c:v','libx264','-crf','17','-preset','fast','-pix_fmt','yuv420p','-movflags','+faststart',str(target)],check=True)
    Path(raw).unlink()
    print(scene['id'], 'saved', round(elapsed,2), 'seconds of actions', 'errors:', errors,flush=True)
    if errors:
        evidence.append({'scene':scene['id'],'browser_errors':errors})
    evidence_path.write_text(json.dumps(evidence,ensure_ascii=False,indent=2))

async def main():
    scenes = json.loads((ROOT/'src/timeline.json').read_text())
    selected = os.environ.get('LYNX_CAPTURE_ONLY','').split(',')
    async with async_playwright() as pw:
        browser = await pw.chromium.launch(executable_path=os.environ.get('LYNX_BROWSER'))
        context = await browser.new_context(viewport={'width':1280,'height':720},record_video_dir=str(OUT/'raw'),record_video_size={'width':1280,'height':720},locale='es-ES',timezone_id='Europe/Madrid')
        await context.add_cookies([{'name':'userConsent','value':'true','url':BASE}])
        await context.add_init_script(CURSOR)
        warm = await context.new_page()
        await go(warm,'/')
        await warm.screenshot(path=str(OUT/'home.png'))
        await warm.close()
        for scene in scenes:
            if scene['id'] in globals() and scene['id'] != 'mobile' and (selected == [''] or scene['id'] in selected):
                if selected != [''] and scene['id'] not in ['access','mobile']:
                    setup = await context.new_page()
                    await login(setup)
                    await setup.close()
                await record(context,scene,globals()[scene['id']])
        await context.close()
        # Mobile is captured separately with the mobile user agent used by the app.
        if selected == [''] or 'mobile' in selected:
            ctx = await browser.new_context(viewport={'width':390,'height':720},is_mobile=True,has_touch=True,user_agent='Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Mobile Safari/537.36',record_video_dir=str(OUT/'raw'),record_video_size={'width':390,'height':720},locale='es-ES')
            await ctx.add_cookies([{'name':'userConsent','value':'true','url':BASE}])
            await ctx.add_init_script(CURSOR)
            await record(ctx,next(s for s in scenes if s['id']=='mobile'),mobile)
            await ctx.close()
        await browser.close()
    (OUT/'verification.json').write_text(json.dumps(evidence,ensure_ascii=False,indent=2))

asyncio.run(main())
