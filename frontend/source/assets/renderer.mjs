export {createInterpolator} from './interpolation.mjs';
import {identitySyllables} from './sigil-runtime.mjs';
export function createControls(send,clock=()=>performance.now()){
 let seq=0,last=-Infinity,playing=false,command=null,firePending=false,cancel=false,previous=JSON.stringify({left:false,right:false,thrust:false,fire:false});
 const flags={left:false,right:false,thrust:false,fire:false};
 function flush(){
  const now=clock(),next=JSON.stringify(flags);
  if(now-last<100||(!command&&!cancel&&!firePending&&next===previous&&(!playing||now-last<200)))return;
  if(seq>=2147483647)throw Error('Input sequence exhausted');
  last=now;const payload=command?{action:command,seq:++seq}:{action:cancel?'release':'input',seq:++seq,...flags,firePressed:!cancel&&firePending};
  if(!command)previous=next;command=null;firePending=false;cancel=false;if(send(payload)===false)firePending=!!payload.firePressed;
 }
 return {
 resume(accepted){if(!Number.isSafeInteger(accepted)||accepted<0||accepted>2147483647)throw Error('Invalid inputSeq');seq=Math.max(seq,accepted);},
 stamp(payload){if(seq>=2147483647)throw Error('Input sequence exhausted');return {...payload,seq:++seq};},
 setPlaying(value){playing=!!value;},
 cancelCommand(){command=null;},
 set(key,value){if(!(key in flags))throw Error('Unknown control');if(key==='fire'&&value&&!flags.fire)firePending=true;flags[key]=!!value;},
 release(){firePending=false;if(playing)cancel=true;for(const key in flags)flags[key]=false;},
 flush,
 command(action){if(!['start','restart'].includes(action))throw Error('Unknown command');command=action;flush();}
 };
}
const integer = (v,min=0,max=Number.MAX_SAFE_INTEGER)=>Number.isSafeInteger(v)&&v>=min&&v<=max;
const words = a=>Array.isArray(a)&&a.length<=64&&a.every(s=>typeof s==='string'&&s.length>0&&s.length<=64);
const position = o=>o&&integer(o.x,0,1024)&&integer(o.y,0,768);
const finite=(v,min,max)=>Number.isFinite(v)&&v>=min&&v<=max;
const velocity=o=>finite(o.vx,-4096,4096)&&finite(o.vy,-4096,4096);
const list=(a,p)=>Array.isArray(a)&&a.length<=1024&&a.every(p);
export function validateSnapshot(s){
 if(!s||![1,2].includes(s.version))return false;
 if(s.level!==undefined&&(!integer(s.level,1,99)||!['active','complete'].includes(s.phase)||!integer(s.transitionTicks,0,15)))return false;
 const motion=o=>s.version===1?position(o):!!(o&&finite(o.x,0,1024)&&finite(o.y,0,768)&&velocity(o));
 const projectile=o=>motion(o)&&integer(o.id);
 const enemy=o=>motion(o)&&integer(o.id)&&['large','small'].includes(o.kind)&&!!identitySyllables(o.ship)&&integer(o.angle,0,359)&&integer(o.radius,1,512);
 return !!((s.version===1||s.stepMs===100)&&typeof s.ship==='string'&&!!identitySyllables(s.ship)&&words(s.syllables)&&s.syllables.join('|')===identitySyllables(s.ship).join('|')&&['ready','playing','gameover'].includes(s.status)&&integer(s.tick)&&integer(s.score)&&integer(s.lives,0,s.syllables.length)&&s.width===1024&&s.height===768&&motion(s.player)&&integer(s.player.angle,0,359)&&list(s.shots,projectile)&&list(s.targets,o=>motion(o)&&integer(o.id)&&typeof o.kind==='string'&&typeof o.label==='string'&&o.label.length<=256&&words(o.syllables)&&integer(o.radius,1,512))&&(s.enemies===undefined||list(s.enemies,enemy))&&(s.enemyShots===undefined||list(s.enemyShots,projectile)));
}
export function sigilRegion(target){
 const sigilSyllables=identitySyllables(target.originShip);
 if(!sigilSyllables||!Array.isArray(target.syllables)||!target.syllables.length)return null;
 const start=sigilSyllables.indexOf(target.syllables[0]);
 if(start<0||target.syllables.some((s,i)=>s!==sigilSyllables[start+i]))return null;
 if(target.syllables.length===sigilSyllables.length)return {x:0,y:0,width:256,height:256};
 // Official core.esm.js maps planet phonemes TL, TR, BL, BR; star L, R.
 if(sigilSyllables.length===2&&target.syllables.length===1)return {x:start*128,y:0,width:128,height:256};
 if(sigilSyllables.length!==4)return null;
 if(target.syllables.length===2&&(start===0||start===2))return {x:0,y:start===0?0:128,width:256,height:128};
 if(target.syllables.length===1)return {x:(start%2)*128,y:Math.floor(start/2)*128,width:128,height:128};
 return null;
}
function object(ctx,t,images){
 const region=sigilRegion(t),image=images[t.originShip];
 if(region&&image){
  ctx.save();ctx.translate(t.x,t.y);
  // Remove only the generator's outer padding, not paths/cutouts. A cropped
  // quadrant fills its own diameter instead of being shrunk a second time.
  const count=identitySyllables(t.originShip).length;
  const bounds=count===1?{x:80,y:80,width:96,height:96}:count===2?{x:32,y:80,width:192,height:96}:{x:32,y:32,width:192,height:192};
  const x=Math.max(region.x,bounds.x),y=Math.max(region.y,bounds.y);
  const width=Math.min(region.x+region.width,bounds.x+bounds.width)-x,height=Math.min(region.y+region.height,bounds.y+bounds.height)-y;
  const size=Math.max(32,t.radius*2),scale=size/Math.max(width,height),w=width*scale,h=height*scale;
  ctx.drawImage(image,x,y,width,height,-w/2,-h/2,w,h);
  ctx.restore();return;
 }
 if(t.originShip||t.kind==='sigil'||t.kind==='fragment'){
  return; // Never invent a substitute sigil or obscure play when art is unavailable.
 }
 ctx.save();ctx.translate(t.x,t.y);ctx.strokeStyle='#a4c7b9';ctx.lineWidth=1.6;
 const r=t.radius;ctx.beginPath();
 if(t.kind==='star') {for(let i=0;i<10;i++){const a=i*Math.PI/5-Math.PI/2; const q=i%2?r*.45:r;ctx[i?'lineTo':'moveTo'](Math.cos(a)*q,Math.sin(a)*q);}ctx.closePath();}
 else if(t.kind==='comet'){ctx.arc(0,0,r*.6,0,Math.PI*2);ctx.moveTo(-r*.4,-r*.4);ctx.lineTo(-r*1.8,-r);ctx.moveTo(-r*.6,0);ctx.lineTo(-r*2,-r*.3);}
 else {ctx.ellipse(0,0,r,t.kind==='galaxy'?r*.38:r, t.kind==='galaxy'?-.5:0,0,Math.PI*2);}
 ctx.stroke();
 if(t.kind==='planet'||t.kind==='galaxy'){ctx.beginPath();ctx.ellipse(0,0,r*1.35,r*.3,-.4,0,Math.PI*2);ctx.stroke();}
 if(t.kind==='moon'){ctx.beginPath();ctx.arc(-r*.2,-r*.15,r*.18,0,Math.PI*2);ctx.stroke();}
 ctx.restore();
}
export function drawSnapshot(ctx,s,images={}){
 ctx.clearRect(0,0,1024,768);ctx.fillStyle='#091512';ctx.fillRect(0,0,1024,768);
 // Fixed visual registration marks, never simulated game entities.
 ctx.fillStyle='#32473e';for(let i=0;i<70;i++)ctx.fillRect((i*173+43)%1024,(i*137+71)%768,1,1);
 for(const t of s.targets)object(ctx,t,images);
 for(const e of s.enemies??[])object(ctx,{...e,originShip:e.ship,syllables:identitySyllables(e.ship)??[],kind:'sigil'},images);
 ctx.fillStyle='#f49283';for(const q of s.enemyShots??[]){ctx.beginPath();ctx.arc(q.x,q.y,3,0,Math.PI*2);ctx.fill();}
 ctx.fillStyle='#f4c86a';for(const q of s.shots){ctx.beginPath();ctx.arc(q.x,q.y,2.5,0,Math.PI*2);ctx.fill();}
 // Identity is always the authenticated host snapshot.ship. Partial lives do
 // not invent another @p: retain original tile locations inside a stable nose.
 ctx.save();ctx.translate(s.player.x,s.player.y);ctx.rotate((s.player.angle+90)*Math.PI/180);
 const image=images[s.ship],syllables=identitySyllables(s.ship);
 if(image&&syllables){
  for(let i=0;i<Math.min(s.lives,syllables.length);i++){
   const region=syllables.length>4?{x:(i%2)*128,y:Math.floor(i/2)*256/(syllables.length/2),width:128,height:256/(syllables.length/2)}:syllables.length===4?{x:(i%2)*128,y:Math.floor(i/2)*128,width:128,height:128}:syllables.length===2?{x:i*128,y:0,width:128,height:256}:{x:0,y:0,width:256,height:256};
   const moon=syllables.length>4,size=moon?18:24;
   ctx.drawImage(image,region.x,region.y,region.width,region.height,(moon?-9:-12)+region.x*size/256,(moon?-3:-6)+region.y*size/256,region.width*size/256,region.height*size/256);
  }
 }
 ctx.strokeStyle='#f4c86a';ctx.lineWidth=1.6;ctx.beginPath();ctx.moveTo(0,-27);ctx.lineTo(22,21);ctx.lineTo(0,16);ctx.lineTo(-22,21);ctx.closePath();ctx.stroke();ctx.restore();
}
