// Presentation only. Never feed sampled positions back to input or authority.
const wrap=(n,size)=>((n%size)+size)%size;
const delta=(a,b,size)=>wrap(b-a+size/2,size)-size/2;
export function createInterpolator(){
 let previous=null,current=null,received=0,last=null,frozen=false;
 function push(next,now){
  const reset=!current||next.ship!==current.ship||next.status!==current.status||next.lives!==current.lives||next.tick<current.tick||next.tick-current.tick>3||Math.abs(delta(current.player.x,next.player.x,next.width))>128||Math.abs(delta(current.player.y,next.player.y,next.height))>128;
  if(!reset&&next.tick===current.tick){current=next;return;}
  previous=reset?null:current;current=next;received=now;frozen=false;
  if(reset)last=next;
 }
 function pose(now){
  const step=current.stepMs??100,offset=Math.min(50,Math.max(-50,now-received-50));
  const steps=previous?Math.max(1,current.tick-previous.tick):1;
  const alpha=1+Math.min(0,offset)/(step*steps);
  function entity(a,b){
   if(offset<0&&a){
    const out={...b,x:wrap(a.x+delta(a.x,b.x,current.width)*alpha,current.width),y:wrap(a.y+delta(a.y,b.y,current.height)*alpha,current.height)};
    if(Number.isFinite(a.angle)&&Number.isFinite(b.angle))out.angle=wrap(a.angle+delta(a.angle,b.angle,360)*alpha,360);
    return out;
   }
   if(offset>0&&current.version===2&&Number.isFinite(b.vx)&&Number.isFinite(b.vy))return {...b,x:wrap(b.x+b.vx*offset/step,current.width),y:wrap(b.y+b.vy*offset/step,current.height)};
   return {...b};
  }
  function entities(key){
   const old=new Map((previous?.[key]??[]).map(e=>[e.id,e]));
   return (current[key]??[]).map(b=>{let a=old.get(b.id);if(a&&(a.originShip!==b.originShip||a.ship!==b.ship||a.kind!==b.kind||JSON.stringify(a.syllables)!==JSON.stringify(b.syllables)))a=null;return entity(a,b);});
  }
  return {...current,player:entity(previous?.player,current.player),targets:entities('targets'),shots:entities('shots'),enemies:entities('enemies'),enemyShots:entities('enemyShots')};
 }
 return {push,sample(now){if(!current)return null;if(frozen)return last??current;if(current.status!=='playing')return last=current;return last=pose(now);},freeze(){frozen=true;},reset(){previous=null;current=null;last=null;frozen=false;}};
}
