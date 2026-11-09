// Official @urbit/http-api receives only the existing same-origin Eyre cookie.
// Scry bootstraps the channel destination from server-owned state, not a form.
export async function openTransport(api,onState,onFailure){
 api.onError=onFailure;api.onRetry=onFailure;
 const initial=await api.scry({app:'hasterrad',path:'/state'});
 if(!initial||typeof initial.ship!=='string'||!/^~[a-z-]{3,128}$/.test(initial.ship))throw Error('Missing authoritative identity');
 api.ship=initial.ship.slice(1);
 onState(initial);
 const subscription=await api.subscribe({app:'hasterrad',path:'/state',event:onState,err:onFailure,quit:onFailure});
 return {send:json=>api.poke({app:'hasterrad',mark:'json',json}),subscription};
}
