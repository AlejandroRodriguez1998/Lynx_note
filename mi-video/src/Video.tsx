import React, {useEffect, useState} from 'react';
import {
  AbsoluteFill, Composition, Still, Html5Audio, Img, OffthreadVideo,
  Sequence, continueRender, delayRender, interpolate, spring, staticFile,
  useCurrentFrame,
} from 'remotion';
import timeline from './timeline.json';

const FPS = 30;
const duration = timeline.reduce((n,s) => n+s.seconds,0)*FPS;
type Scene = (typeof timeline)[number];
const C = {bg:'#102d24',cream:'#f3f1df',lime:'#d3e59a',muted:'#afc1ad',line:'#385247'};
const clamp = {extrapolateLeft:'clamp',extrapolateRight:'clamp'} as const;

const GlobalStyle:React.FC = () => <style>{`
  @font-face {font-family:Ubuntu;src:url('${staticFile('fonts/UbuntuSans.ttf')}') format('truetype');font-weight:100 900;font-display:block;}
  *{box-sizing:border-box} body{margin:0}
`}</style>;

const Backdrop:React.FC = () => {
  const f=useCurrentFrame();
  return <AbsoluteFill style={{background:C.bg,color:C.cream,fontFamily:'Ubuntu, sans-serif',overflow:'hidden'}}>
    <div style={{position:'absolute',width:1200,height:1200,right:-350,top:-550,borderRadius:'50%',background:'radial-gradient(circle,#43643c55,transparent 67%)',transform:`translateY(${Math.sin(f/130)*30}px)`}}/>
    <div style={{position:'absolute',width:1000,height:1000,left:-500,bottom:-700,borderRadius:'50%',border:'1px solid #65816655'}}/>
    <div style={{position:'absolute',width:1200,height:1200,left:-600,bottom:-800,borderRadius:'50%',border:'1px solid #65816633'}}/>
    <div style={{position:'absolute',left:54,top:34,display:'flex',alignItems:'center',gap:14}}>
      <Img src={staticFile('icono.png')} style={{width:47,height:47,objectFit:'contain'}}/>
      <span style={{fontSize:27,fontWeight:700,letterSpacing:-.7}}>Lynx Note<span style={{fontWeight:400,color:C.muted,fontSize:20,marginLeft:21}}>Una demo, paso a paso.</span></span>
    </div>
  </AbsoluteFill>;
};

const Browser:React.FC<{children:React.ReactNode;width?:number;height?:number;style?:React.CSSProperties}> = ({children,width=1480,height=832.5,style}) => <div style={{position:'absolute',left:384,top:132,width,borderRadius:17,overflow:'hidden',border:'1px solid #73866b88',boxShadow:'0 25px 70px #0007',background:'#efeddc',...style}}>
  <div style={{height:40,background:'#e3e6d9',display:'flex',alignItems:'center',padding:'0 17px',gap:8}}>
    {['#c5b49c','#b4c18f','#9baa81'].map((color,i)=><div key={i} style={{width:10,height:10,borderRadius:'50%',background:color}}/>)}
    <div style={{marginLeft:24,fontSize:14,color:'#4b5948',letterSpacing:.4}}>Lynx Note <span style={{color:'#82907b',marginLeft:18}}>Entorno de demostración</span></div>
    <div style={{marginLeft:'auto',fontSize:13,color:'#64745e'}}>Captura real de la aplicación</div>
  </div>
  <div style={{width,height,position:'relative',overflow:'hidden'}}>{children}</div>
</div>;

const points:Record<string,string[]> = {
  access:['Abre Sign up o Log in','Introduce tus datos','Accede a tu espacio'],
  notes:['Selecciona una nota','Consulta sus bloques','Edita o comparte'],
  create:['Escribe un título','Combina texto, listas e imágenes','Guarda con Create Note'],
  collections:['Crea una colección','Asígnala al editar la nota','Agrupa por proyecto'],
  friends:['Revisa las solicitudes','Acepta una amistad','Consulta lo compartido'],
  share:['Abre la opción de compartir','Selecciona destinatarios','Confirma con Sharing'],
  receive:['Entra con otra cuenta','Revisa la notificación','Abre la nota recibida'],
  admin:['Accede con rol admin','Abre el panel de gestión','Consulta usuarios y notas'],
};

const Sidebar:React.FC<{scene:Scene}> = ({scene}) => {
  const f=useCurrentFrame();
  const appear = spring({frame:f,fps:FPS,config:{damping:22}});
  const list = points[scene.id] ?? [];
  return <div style={{position:'absolute',left:56,top:163,width:290,transform:`translateY(${(1-appear)*18}px)`,opacity:appear}}>
    <div style={{fontSize:16,letterSpacing:2,fontWeight:700,color:C.lime,marginBottom:30}}>{scene.eyebrow}</div>
    <div style={{fontSize:53,lineHeight:1.02,letterSpacing:-2.2,fontWeight:600,marginBottom:48}}>{scene.title}</div>
    <div style={{width:44,height:3,background:C.lime,marginBottom:40}}/>
    {list.map((text,i)=><div key={text} style={{display:'flex',alignItems:'flex-start',gap:14,marginBottom:27,opacity:interpolate(f,[i*9+5,i*9+20],[0,1],clamp)}}>
      <span style={{fontSize:13,paddingTop:5,color:C.lime,fontWeight:700}}>0{i+1}</span>
      <span style={{fontSize:23,lineHeight:1.25,color:'#dbe2cd'}}>{text}</span>
    </div>)}
    <div style={{marginTop:40,fontSize:16,lineHeight:1.5,color:C.muted}}>Datos ficticios.<br/>Funciones reales.</div>
  </div>;
};

const TutorialScene:React.FC<{scene:Scene}> = ({scene}) => {
  const f=useCurrentFrame();
  const reveal=interpolate(f,[0,12],[0,1],clamp);
  return <AbsoluteFill style={{opacity:reveal}}>
    <Sidebar scene={scene}/>
    <Browser><OffthreadVideo src={staticFile(`captures/${scene.id}.mp4`)} muted style={{width:'100%',height:'100%',objectFit:'cover'}}/></Browser>
    <div style={{position:'absolute',right:58,top:52,fontSize:17,letterSpacing:1.2,color:C.muted}}>GUÍA DE USO <span style={{marginLeft:17,color:C.lime}}>{scene.eyebrow.split(' / ')[0]} / 09</span></div>
  </AbsoluteFill>;
};

const Intro:React.FC<{cover?:boolean}> = ({cover=false}) => {
  const f=useCurrentFrame();
  const a=cover?1:spring({frame:f,fps:FPS,config:{damping:24}});
  return <AbsoluteFill>
    <div style={{position:'absolute',left:70,top:192,width:835,opacity:a,transform:`translateY(${(1-a)*24}px)`}}>
      <div style={{fontSize:19,fontWeight:600,color:C.lime,letterSpacing:3,marginBottom:27}}>NOTAS · COLECCIONES · AMIGOS</div>
      <div style={{display:'flex',alignItems:'center',gap:27,marginBottom:22}}><Img src={staticFile('icono.png')} style={{width:130,height:130}}/><span style={{fontSize:90,fontWeight:650,letterSpacing:-4}}>Lynx Note</span></div>
      <div style={{fontSize:104,lineHeight:1.01,fontWeight:500,letterSpacing:-5}}>Tus ideas,<br/><span style={{color:C.lime}}>en su sitio.</span></div>
      <p style={{fontSize:30,color:'#c4d0bd',lineHeight:1.4,marginTop:35,width:730}}>Guarda lo importante.<br/>Organiza tus proyectos. Comparte con tu equipo.</p>
      <div style={{display:'inline-flex',gap:12,alignItems:'center',border:'1px solid #799063',borderRadius:99,padding:'14px 22px',fontSize:21,marginTop:13}}><span style={{color:C.lime}}>▶</span> Demo y tutorial en español</div>
    </div>
    <Browser width={1280} height={720} style={{left:1000,top:230,transform:`perspective(2000px) rotateY(-13deg) rotateZ(2deg) translateY(${cover?0:Math.sin(f/70)*8}px)`,transformOrigin:'left center',boxShadow:'0 35px 80px #0008'}}>
      <Img src={staticFile('captures/note.png')} style={{width:'100%',height:'100%'}}/>
    </Browser>
  </AbsoluteFill>;
};

const MobileScene:React.FC = () => {
  const f=useCurrentFrame();
  return <AbsoluteFill>
    <div style={{position:'absolute',left:105,top:230,width:900}}>
      <div style={{color:C.lime,fontSize:19,letterSpacing:2.5,marginBottom:34}}>09 / DISEÑO ADAPTABLE</div>
      <div style={{fontSize:90,fontWeight:500,letterSpacing:-4,lineHeight:1.05}}>Tus notas,<br/>también <span style={{color:C.lime}}>en el móvil.</span></div>
      <p style={{fontSize:31,color:'#c4d0bd',lineHeight:1.45,width:780,marginTop:34}}>La misma aplicación, con navegación<br/>y contenido adaptados a tu pantalla.</p>
      {['Menú desplegable','Vista individual de cada nota','Acceso desde el navegador'].map((t,i)=><div key={t} style={{marginTop:22,fontSize:26,color:C.cream,opacity:interpolate(f,[i*12,i*12+18],[0,1],clamp)}}><span style={{color:C.lime,marginRight:20}}>↗</span>{t}</div>)}
    </div>
    <div style={{position:'absolute',left:1210,top:135,width:444,height:844,borderRadius:42,padding:12,background:'#071c15',border:'2px solid #769263',boxShadow:'0 30px 80px #0007'}}>
      <div style={{borderRadius:30,overflow:'hidden',height:816,background:'#efeddc',paddingTop:30}}>
        <div style={{position:'absolute',top:20,left:174,width:90,height:8,borderRadius:99,background:'#294336'}}/>
        <OffthreadVideo src={staticFile('captures/mobile.mp4')} muted style={{width:420,height:775.4,objectFit:'cover'}}/>
      </div>
    </div>
    <div style={{position:'absolute',left:1250,top:994,fontSize:16,color:C.muted}}>Captura real · navegador móvil</div>
  </AbsoluteFill>;
};

const Outro:React.FC = () => {
  const f=useCurrentFrame();
  return <AbsoluteFill style={{alignItems:'center',paddingTop:154,opacity:interpolate(f,[0,16],[0,1],clamp)}}>
    <Img src={staticFile('icono.png')} style={{width:138,height:138,marginBottom:28}}/>
    <div style={{fontSize:22,color:C.lime,letterSpacing:4,marginBottom:27}}>LYNX NOTE</div>
    <div style={{fontSize:87,letterSpacing:-3,fontWeight:550}}>Organiza. Conecta. <span style={{color:C.lime}}>Comparte.</span></div>
    <div style={{display:'flex',gap:15,marginTop:40}}>{['Ruby on Rails','MongoDB','Bootstrap'].map(t=><span key={t} style={{border:'1px solid #698159',borderRadius:99,padding:'12px 24px',fontSize:23,color:'#d6deca'}}>{t}</span>)}</div>
    <div style={{marginTop:64,textAlign:'center',fontSize:25,lineHeight:1.6,color:'#c4d0bd'}}>Un proyecto de<br/><span style={{color:C.cream,fontSize:30}}>Alejandro Paniagua Rodríguez & Ángela Gijón Flores</span></div>
    <div style={{marginTop:36,fontSize:20,color:C.muted}}>Sistemas Web · Escuela Superior de Informática · UCLM</div>
    <div style={{marginTop:37,fontSize:20,color:C.lime}}>Código: github.com/AlejandroRodriguez1998/Lynx_note</div>
  </AbsoluteFill>;
};

const Captions:React.FC<{scene:Scene}> = ({scene}) => {
  const t=useCurrentFrame()/FPS;
  const caption=scene.captions.find(c=>t>=c.start&&t<c.end);
  if(!caption)return null;
  return <div style={{position:'absolute',left:200,right:200,bottom:24,display:'flex',justifyContent:'center'}}><div style={{padding:'10px 23px',background:'#071c15ed',borderRadius:9,color:'#fffef0',fontSize:27,lineHeight:1.25,textAlign:'center',boxShadow:'0 2px 15px #0003'}}>{caption.text}</div></div>;
};

const useLocalFont = () => {
  const [fontHandle]=useState(()=>delayRender('Loading local font'));
  useEffect(()=>{document.fonts.load('500 30px Ubuntu').then(()=>continueRender(fontHandle)).catch(()=>continueRender(fontHandle));},[fontHandle]);
};

const Film:React.FC = () => {
  const f=useCurrentFrame();
  useLocalFont();
  return <AbsoluteFill style={{fontFamily:'Ubuntu, sans-serif',color:C.cream,background:C.bg}}>
    <GlobalStyle/><Backdrop/>
    <Html5Audio src={staticFile('audio/music.wav')} volume={.32}/>
    {timeline.map(scene=><Sequence key={scene.id} from={scene.from*FPS} durationInFrames={scene.seconds*FPS}>
      {scene.id==='intro'?<Intro/>:scene.id==='outro'?<Outro/>:scene.id==='mobile'?<MobileScene/>:<TutorialScene scene={scene}/>}
      <Sequence from={15}><Html5Audio src={staticFile(`audio/${scene.id}.mp3`)}/></Sequence>
      <Captions scene={scene}/>
    </Sequence>)}
    <div style={{position:'absolute',bottom:0,left:0,width:`${f/duration*100}%`,height:4,background:C.lime}}/>
    <AbsoluteFill style={{background:'#071c15',pointerEvents:'none',opacity:interpolate(f,[duration-18,duration-1],[0,1],clamp)}}/>
  </AbsoluteFill>;
};

const Cover:React.FC = () => {
  useLocalFont();
  return <AbsoluteFill style={{fontFamily:'Ubuntu, sans-serif',color:C.cream}}><GlobalStyle/><Backdrop/><Intro cover/></AbsoluteFill>;
};

export const RemotionRoot:React.FC = () => <>
  <Composition id="LynxNote" component={Film} durationInFrames={duration} fps={FPS} width={1920} height={1080}/>
  <Still id="LynxCover" component={Cover} width={1920} height={1080}/>
</>;
