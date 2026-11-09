import test from 'node:test';
import assert from 'node:assert/strict';
import {createControls, createInterpolator, sigilRegion} from '../frontend/source/assets/renderer.mjs';
import {identitySyllables, makeSigil} from '../frontend/source/assets/sigil-runtime.mjs';
import {openTransport} from '../frontend/source/assets/transport.mjs';

test('short down/up survives transport throttle as one press edge',()=>{
 let now=0;const sent=[];const c=createControls(x=>sent.push(x),()=>now);
 c.setPlaying(true);c.flush();now=20;c.set('fire',true);c.flush();now=40;c.set('fire',false);c.flush();
 now=100;c.flush();assert.equal(sent.at(-1).fire,false);assert.equal(sent.at(-1).firePressed,true);
 now=300;c.flush();assert.equal(sent.at(-1).firePressed,false);
});
test('held heartbeats carry no additional press edges',()=>{
 let now=0;const sent=[];const c=createControls(x=>sent.push(x),()=>now);c.setPlaying(true);c.set('fire',true);c.flush();
 now=200;c.flush();now=400;c.set('fire',true);c.flush();
 assert.equal(sent.filter(x=>x.firePressed).length,1);assert.ok(sent.every(x=>x.fire));
});
test('release discards pending press and resumes above accepted sequence',()=>{
 let now=0;const sent=[];const c=createControls(x=>sent.push(x),()=>now);c.resume(100);c.setPlaying(true);c.set('fire',true);c.release();c.flush();
 assert.equal(sent[0].action,'release');assert.equal(sent[0].firePressed,false);assert.ok(sent[0].seq>100);
 assert.throws(()=>c.resume(-1));assert.throws(()=>c.set('unknown',true));
});
test('moon identity retains all syllables and transparent official glyph composition',()=>{
 const ship='~sitnup-ronsym-dirted-pallup';assert.equal(identitySyllables(ship).length,8);
 const svg=makeSigil(ship);assert.ok(svg.includes('<svg'));assert.ok(svg.includes('mask'));
 const syllables=identitySyllables('~dirted-pallup');
 assert.deepEqual(sigilRegion({originShip:'~dirted-pallup',syllables:[syllables[3]]}),{x:128,y:128,width:128,height:128});
});
test('interpolation is bounded presentation and preserves authoritative membership',()=>{
 const s={version:2,ship:'~zod',status:'playing',lives:1,tick:1,stepMs:100,width:1024,height:768,player:{x:100,y:100,vx:10,vy:0,angle:0},targets:[],shots:[],enemies:[],enemyShots:[]};
 const i=createInterpolator();i.push(s,0);const sample=i.sample(10000);assert.equal(sample.player.x,105);assert.equal(s.player.x,100);assert.deepEqual(sample.shots,[]);
 i.freeze();assert.deepEqual(i.sample(20000),sample);
});
test('transport uses host-derived identity and native authenticated routes',async()=>{
 const calls=[],states=[];const api={scry:async arg=>{calls.push(arg);return {ship:'~dirted-pallup'};},subscribe:async arg=>{calls.push(arg);return 7;},poke:async arg=>calls.push(arg)};
 const link=await openTransport(api,s=>states.push(s),()=>{});assert.equal(api.ship,'dirted-pallup');assert.equal(link.subscription,7);
 await link.send({action:'input',seq:1});assert.deepEqual(calls[0],{app:'hasterrad',path:'/state'});assert.equal(calls[2].mark,'json');assert.equal(states.length,1);
 await assert.rejects(openTransport({...api,scry:async()=>({ship:'anonymous'})},()=>{},()=>{}));
});
