import {createControls,validateSnapshot,drawSnapshot,createInterpolator} from './renderer.mjs';
import {openTransport} from './transport.mjs';
import {makeSigil} from './sigil-runtime.mjs';
export function mountUI(doc,win,Urbit){
 const el=id=>doc.getElementById(id),canvas=el('field'),ctx=canvas.getContext('2d');
 let api,link,state,connected=false,generation=0,lastState=0,busy=false,pending=null;
 const clock=()=>win.performance?.now()??performance.now();let lastSent=-Infinity,focused=true;
 const presentation=createInterpolator();let raf=null,disposed=false;
 function paint(){if(!doc.hidden&&state&&!disposed){const frame=presentation.sample(clock());if(frame)drawSnapshot(ctx,frame,images);}}
 function stopRender(){if(raf!==null)win.cancelAnimationFrame?.(raf);raf=null;presentation.freeze();}
 function schedule(){
  if(raf!==null||disposed||doc.hidden||!connected||(state?.status!=='playing'||state?.phase==='complete')||clock()-lastState>=350||!win.requestAnimationFrame)return;
  raf=win.requestAnimationFrame(()=>{raf=null;paint();schedule();});
 }
 function resumeRender(){if(state&&connected&&!doc.hidden&&!disposed){presentation.reset();presentation.push(state,clock());paint();schedule();}}
 const images={},loading=new Set();
 function ensureImages(next){
  const wanted=new Set([next.ship,...next.targets.map(t=>t.originShip),...(next.enemies??[]).map(e=>e.ship)].filter(Boolean));
  for(const ship of Object.keys(images))if(!wanted.has(ship))delete images[ship];
  for(const ship of wanted){
   if(images[ship]||loading.has(ship)||Object.keys(images).length+loading.size>=128)continue;
   let svg;try{svg=makeSigil(ship);}catch{continue;}
   loading.add(ship);const image=new win.Image();
   image.onload=()=>{loading.delete(ship);if(!disposed&&state&&(state.ship===ship||state.targets.some(t=>t.originShip===ship)||(state.enemies??[]).some(e=>e.ship===ship))){images[ship]=image;paint();if(state.ship===ship){el('sigil').src=image.src;el('sigil').hidden=false;}}};
   image.onerror=()=>loading.delete(ship);image.src='data:image/svg+xml;charset=utf-8,'+encodeURIComponent(svg);
  }
 }
 const info=el('info-panel');let infoReturn=null;
 function closeInfo(){info.close();el('info').setAttribute('aria-expanded','false');(infoReturn??el('info')).focus();}
 el('info').addEventListener('click',()=>{infoReturn=doc.activeElement;release();info.showModal();el('info').setAttribute('aria-expanded','true');el('info-close').focus();});
 el('info-close').addEventListener('click',closeInfo);
 info.addEventListener('cancel',event=>{event.preventDefault();closeInfo();});
 const listeners=[];function on(target,type,handler){target.addEventListener(type,handler);listeners.push(()=>target.removeEventListener(type,handler));}
 function failure(){stopRender();++generation;connected=false;pressed.clear();pointers.clear();controls.release();controls.setPlaying(false);pending=null;api?.reset();el('connection').textContent='Disconnected — controls paused';el('overlay').hidden=false;el('phase').textContent='Signal interrupted';el('message').textContent='Last rendered pose is frozen. Reconnect through your existing ship session.';el('start').disabled=true;el('reconnect').hidden=false;}
 function receive(next){
  if(!validateSnapshot(next)||!Number.isSafeInteger(next.inputSeq)||next.inputSeq<0||next.inputSeq>2147483647){failure();return;}
  controls.resume(next.inputSeq);controls.setPlaying(next.status==='playing'&&next.phase!=='complete'&&!doc.hidden&&focused);
  if(next.status!=='playing'||next.phase==='complete'){pressed.clear();pointers.clear();controls.release();if(['input','release'].includes(pending?.action))pending=null;}
  state=next;lastState=clock();connected=true;presentation.push(next,lastState);ensureImages(next);
  el('connection').textContent='Connected · Hoon authority';el('ship').textContent=state.ship;el('score').textContent=String(state.score);el('level').textContent=String(state.level??1);el('tick').textContent='STATE '+state.tick;
  el('sigil').hidden=!images[state.ship];if(images[state.ship])el('sigil').src=images[state.ship].src;
  el('lives').replaceChildren();state.syllables.forEach((syllable,i)=>{const span=doc.createElement('span');span.className='syllable'+(i>=state.lives?' lost':'');span.textContent=syllable;el('lives').append(span);});
  el('overlay').hidden=state.status==='playing'&&state.phase!=='complete';el('phase').textContent=state.phase==='complete'?'Level '+state.level+' complete':state.status==='gameover'?'Signal lost':'Ready to launch';el('message').textContent=state.phase==='complete'?'Next wave incoming — controls paused.':state.status==='gameover'?'Your ship is intact. Restart a new run.':'Break sigils into game pieces. Hoon owns every hit.';
  el('start').textContent=state.status==='gameover'?'Play again':'Start game';el('start').hidden=state.status==='playing';el('start').disabled=!['ready','gameover'].includes(state.status);el('reconnect').hidden=true;paint();schedule();
 }
 function send(payload){
  if(!connected||(['input','release'].includes(payload.action)&&(state?.status!=='playing'||state?.phase==='complete')))return;
  if(pending?.action==='release'&&payload.action==='input')return false;
  if(!pending||['input','release'].includes(pending.action)){
   if(payload.action==='input'&&pending?.action==='input')payload={...payload,firePressed:payload.firePressed||pending.firePressed};
   pending=payload;
  }pump();
 }
 async function pump(){
  if(!connected||!link||busy||!pending||clock()-lastSent<100)return;
  const payload=controls.stamp(pending);pending=null;lastSent=clock();busy=true;const own=generation;let deadline;
  try{await Promise.race([link.send(payload),new Promise((_,reject)=>{deadline=win.setTimeout(()=>reject(Error('Poke timeout')),5000);})]);}
  catch{if(own===generation)failure();}finally{win.clearTimeout(deadline);if(own===generation)busy=false;}
 }
 const controls=createControls(send,clock);const pressed=new Set(),pointers=new Map();
 const mapping={ArrowLeft:'left',KeyA:'left',ArrowRight:'right',KeyD:'right',ArrowUp:'thrust',KeyW:'thrust',Space:'fire'};
 function apply(){for(const name of ['left','right','thrust','fire'])controls.set(name,[...pressed].some(code=>mapping[code]===name)||[...pointers.values()].includes(name));controls.flush();}
 function release(){pressed.clear();pointers.clear();controls.release();controls.flush();}
 on(win,'keydown',event=>{if(info.open||event.target?.closest?.('a,dialog'))return;if(event.code==='Space'&&event.repeat)return;if(!mapping[event.code]||!connected||(state?.status!=='playing'||state?.phase==='complete')||event.target?.closest?.('input,textarea,select,[contenteditable=true],button:not([data-control]):not(#fullscreen)'))return;event.preventDefault();pressed.add(event.code);apply();});
 on(win,'keyup',event=>{if(mapping[event.code]){pressed.delete(event.code);apply();}});
 on(win,'blur',()=>{focused=false;release();controls.setPlaying(false);});
 on(win,'focus',()=>{focused=true;controls.setPlaying(connected&&state?.status==='playing'&&state?.phase!=='complete'&&!doc.hidden);});
 on(doc,'visibilitychange',()=>{if(doc.hidden){release();stopRender();}else resumeRender();controls.setPlaying(connected&&state?.status==='playing'&&state?.phase!=='complete'&&!doc.hidden&&focused);});
 for(const button of doc.querySelectorAll('[data-control]')){
  on(button,'pointerdown',event=>{if(!connected||(state?.status!=='playing'||state?.phase==='complete'))return;event.preventDefault();button.setPointerCapture(event.pointerId);pointers.set(event.pointerId,button.dataset.control);apply();});
  for(const type of ['pointerup','pointercancel','lostpointercapture'])on(button,type,event=>{pointers.delete(event.pointerId);apply();});
 }
 on(el('start'),'click',()=>{if(connected&&['ready','gameover'].includes(state?.status)){release();controls.command(state.status==='ready'?'start':'restart');canvas.focus();}});
 on(el('fullscreen'),'click',()=>{canvas.focus();if(doc.fullscreenElement)doc.exitFullscreen?.();else el('game').requestFullscreen?.().catch(()=>{});});
 async function connect(){
  if(disposed)return;stopRender();presentation.reset();const own=++generation;connected=false;link=null;state=null;pending=null;busy=false;controls.setPlaying(false);controls.cancelCommand();release();if(api){api.reset();}
  el('connection').textContent='Connecting…';el('start').disabled=true;
  try{
   api=new Urbit('');const current=api;
   const opened=await openTransport(current,next=>{if(own===generation)receive(next);},()=>{if(own===generation)failure();});
   if(own!==generation){current.reset();return;}link=opened;
  }catch{if(own===generation)failure();}
 }
 on(el('reconnect'),'click',connect);
 const timer=win.setInterval(()=>{controls.flush();pump();if(connected&&state?.status==='playing'&&clock()-lastState>5000)failure();},50);
 on(win,'pagehide',()=>{release();failure();});
 return {connect,flush:()=>{controls.flush();pump();},dispose(){release();disposed=true;stopRender();++generation;listeners.forEach(remove=>remove());win.clearInterval(timer);api?.reset();}};
}
if(typeof document!=='undefined'){
 const game=mountUI(document,window,window.UrbitHttpApi.Urbit);game.connect();
}
