import {EventEmitter} from 'node:events';
export function fixtureUI(){
 class Element extends EventTarget{constructor(){super();this.dataset={};this.children=[];this.hidden=false;this.disabled=false;}replaceChildren(...e){this.children=e;}append(e){this.children.push(e);}focus(){doc.activeElement=this;}setAttribute(k,v){this[k]=v;}showModal(){this.open=true;}close(){this.open=false;}getContext(){return new Proxy({},{get:()=>()=>{},set:()=>true});}setPointerCapture(){} }
 const elements={};for(const id of ['game','connection','field','overlay','phase','message','start','restart','reconnect','fullscreen','sigil','ship','score','lives','tick','level','info','info-panel','info-close'])elements[id]=new Element();
 const doc=new EventTarget();doc.hidden=false;doc.getElementById=id=>elements[id];doc.querySelectorAll=()=>[];doc.createElement=()=>new Element();
 let now=0;const timers=[];const win=new EventTarget();win.performance={now:()=>now};win.setInterval=fn=>(timers.push(fn),timers.length);win.clearInterval=()=>{};win.setTimeout=()=>1;win.clearTimeout=()=>{};win.Image=class{set src(v){this.value=v;this.onload?.();}get src(){return this.value;}};
 const fixture={version:1,inputSeq:6,ship:'~zod',syllables:['zod'],status:'playing',tick:29,score:0,lives:1,width:1024,height:768,player:{x:512,y:384,angle:0},shots:[],targets:[]};
 const instances=[],sent=[];class API{constructor(){instances.push(this);}async scry(){return fixture;}async subscribe(p){this.watcher=p.event;return 1;}async poke(p){sent.push({time:now,...p.json});if(this.block)await new Promise(resolve=>this.unblock=resolve);}reset(){} }
 return {doc,win,fixture,elements,API,instances,sent,advance(ms){now+=ms;timers.forEach(fn=>fn());},async settle(){await new Promise(setImmediate);}};
}
