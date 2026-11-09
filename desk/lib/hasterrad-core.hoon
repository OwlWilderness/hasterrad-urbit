/+  hasterrad-enemies
|%
+$  controls  [left=? right=? thrust=? fire=?]
+$  shot-v1  [id=@ud x=@ud y=@ud angle=@ud ttl=@ud]
+$  shot  [id=@ud x=@ud y=@ud angle=@ud ttl=@ud vx=@sd vy=@sd]
+$  target-v1  [id=@ud origin=@p kind=@tas syllables=(list @t) x=@ud y=@ud radius=@ud]
+$  target  [id=@ud origin=@p kind=@tas syllables=(list @t) x=@ud y=@ud radius=@ud vx=@sd vy=@sd]
+$  world-v1
  $:  ship=@p
      status=?(%ready %playing %gameover)
      tick=@ud  score=@ud  lives=@ud  x=@ud  y=@ud  angle=@ud  next=@ud  shield=@ud
      shots=(list shot-v1)  targets=(list target-v1)
  ==
+$  world-v2
  $:  ship=@p
      status=?(%ready %playing %gameover)
      tick=@ud  score=@ud  lives=@ud  x=@ud  y=@ud  angle=@ud  next=@ud  shield=@ud
      shots=(list shot)  targets=(list target)  vx=@sd  vy=@sd
  ==
+$  world-v4
  $:  ship=@p
      status=?(%ready %playing %gameover)
      tick=@ud  score=@ud  lives=@ud  x=@ud  y=@ud  angle=@ud  next=@ud  shield=@ud
      shots=(list shot)  targets=(list target)  vx=@sd  vy=@sd  foes=state:hasterrad-enemies
  ==
+$  world
  $:  ship=@p
      status=?(%ready %playing %gameover)
      tick=@ud  score=@ud  lives=@ud  x=@ud  y=@ud  angle=@ud  next=@ud  shield=@ud
      shots=(list shot)  targets=(list target)  vx=@sd  vy=@sd  foes=state:hasterrad-enemies
      level=@ud  phase=?(%active %complete)  pause=@ud
  ==
++  catalogue
  ^-  (list @p)
  ~[~nosfyl ~nolset ~dister-migrev-dolseg ~mister-dister-dozzod-dozzod ~paldev ~sogryp-dister-dozzod-dozzod]
++  kind
  |=  ship=@p
  ^-  @tas
  =/  bits  (met 0 ship)
  ?:  (lte bits 8)  %galaxy
  ?:  (lte bits 16)  %star
  ?:  (lte bits 32)  %planet
  ?:  (lte bits 64)  %moon
  %comet
++  spawn
  |=  [ship=@p id=@ud]
  ^-  target
  =/  v  (rock-vector ship id)
  [id ship (kind ship) (syllables ship) 757.760 393.216 (min 60 (add 20 (mul 4 (lent (syllables ship))))) vx.v vy.v]
++  alternating
  |=  names=(list @t)
  ^-  (list @t)
  ?:  =(0 (lent names))  ~
  (turn (gulf 0 (div (dec (lent names)) 2)) |=(n=@ud (snag (mul n 2) names)))
++  prefixes
  ^-  (list @t)
  (zing (turn catalogue |=(p=@p (alternating (syllables p)))))
++  suffixes
  ^-  (list @t)
  (zing (turn catalogue |=(p=@p (alternating (slag 1 (syllables p))))))
++  candidate
  |=  n=@ud
  ^-  (unit @p)
  =/  p  prefixes
  =/  s  suffixes
  =/  text=@t
    %-  rap  [3 ~['~' (snag (mod n (lent p)) p) (snag (mod (div n (lent p)) (lent s)) s) '-' (snag (mod (add n 3) (lent p)) p) (snag (mod (add (div n (lent p)) 1) (lent s)) s)]]
  =/  parsed  (slaw %p text)
  ?~  parsed  ~
  =/  ship=@p  u.parsed
  ?.  &(=(text (scot %p ship)) =(%planet (kind ship)) =(4 (lent (syllables ship))))  ~
  `ship
++  generate
  |=  [count=@ud seed=@ud]
  ^-  (list target)
  =/  found=(list target)  ~
  =/  seen=(set @p)  ~
  =/  i=@ud  0
  |-  ^-  (list target)
  ?:  |((gte i 64) (gte (lent found) (min count 7)))  (flop found)
  =/  c  (candidate (add seed i))
  ?~  c  $(i +(i))
  ?:  (~(has in seen) u.c)  $(i +(i))
  =/  n  (lent found)
  =/  t  (spawn u.c +(n))
  =.  t  t(y (mul 1.024 ?:(=(0 n) 384 ?:(=(1 n) 180 ?:(=(2 n) 588 80)))))
  $(i +(i), found [t found], seen (~(put in seen) u.c))
++  fresh
  |=  ship=@p
  ^-  world
  =/  w  (fixture ship)
  (seed-wave w)
++  fixture
  |=  ship=@p
  ^-  world
  [ship %playing 0 0 (lent (syllables ship)) 524.288 393.216 0 2 0 ~ ~[(spawn ~dirted-pallup 1)] --0 --0 fresh:hasterrad-enemies 1 %active 0]
++  rock-vector
  |=  [origin=@p id=@ud]
  ^-  [vx=@sd vy=@sd]
  =/  seed  (mug [origin id])
  (vector (mod seed 360) (add 1.280 (mod (div seed 360) 1.792)))
++  sine
  |=  angle=@ud
  ^-  @sd
  =/  a  (mod angle 360)
  =/  q  (mod a 180)
  =/  t=(list @ud)  ~[0 18 36 54 71 89 107 125 143 160 178 195 213 230 248 265 282 299 316 333 350 367 384 400 416 433 449 465 481 496 512 527 543 558 573 587 602 616 630 644 658 672 685 698 711 724 737 749 761 773 784 796 807 818 828 839 849 859 868 878 887 896 904 912 920 928 935 943 949 956 962 968 974 979 984 989 994 998 1.002 1.005 1.008 1.011 1.014 1.016 1.018 1.020 1.022 1.023 1.023 1.024 1.024]
  (new:si (lth a 180) (snag ?:((gth q 90) (sub 180 q) q) t))
++  vector
  |=  [angle=@ud speed=@ud]
  ^-  [vx=@sd vy=@sd]
  [(fra:si (pro:si (sine (add angle 90)) (new:si %.y speed)) --1.024) (fra:si (pro:si (sine angle) (new:si %.y speed)) --1.024)]
++  wrap
  |=  [p=@ud v=@sd size=@ud]
  ^-  @ud
  =/  value  (sum:si (new:si %.y p) v)
  =/  raw  (mod (abs:si value) size)
  =/  signed  (old:si value)
  ?:  |(-.signed =(0 raw))  raw
  (sub size raw)
++  translate
  |=  [x=@ud y=@ud vx=@sd vy=@sd]
  ^-  [@ud @ud]
  [(wrap x vx 1.048.576) (wrap y vy 786.432)]
++  move
  |=  [x=@ud y=@ud angle=@ud speed=@ud]
  ^-  [@ud @ud]
  =/  v  (vector angle speed)
  (translate x y vx.v vy.v)
++  step
  |=  [w=world input=controls]
  ^-  world
  ?.  =(%playing status.w)  w
  ?:  =(%complete phase.w)
    ?:  (gth pause.w 1)  w(tick +(tick.w), pause (dec pause.w))
    (seed-wave w(level (min 99 +(level.w)), phase %active, pause 0, tick +(tick.w)))
  ?:  =(0 (lent targets.w))  (complete-wave w)
  =/  before  [x.w y.w]
  =.  angle.w  (mod (add angle.w (add ?:(left.input 355 0) ?:(right.input 5 0))) 360)
  =/  v  (vector angle.w ?:(thrust.input 8.192 0))
  =/  pos  (translate x.w y.w vx.v vy.v)
  =.  w  w(tick +(tick.w), x -.pos, y +.pos, vx vx.v, vy vy.v)
  =.  w
    ?:  &(fire.input (lth (lent shots.w) 4))
      =/  v  (vector angle.w 24.576)
      w(shots [[next.w x.w y.w angle.w 30 vx.v vy.v] shots.w], next +(next.w))
    w
  =.  targets.w
    %+  turn  targets.w
    |=  t=target
    =/  p  (translate x.t y.t vx.t vy.t)
    t(x -.p, y +.p)
  =.  shots.w
    %+  turn  (skim shots.w |=(s=shot (gth ttl.s 1)))
    |=  s=shot
    =/  p  (translate x.s y.s vx.s vy.s)
    s(x -.p, y +.p, ttl (dec ttl.s))
  =.  foes.w  (step-wave:hasterrad-enemies foes.w tick.w (div x.w 1.024) (div y.w 1.024) level.w)
  =.  w  (collide w shots.w ~)
  ?:  =(0 (lent targets.w))  (complete-wave w)
  =/  bolts=(list bolt:hasterrad-enemies)
    %+  turn  shots.w
    |=  b=shot
    =/  start  (translate x.b y.b (dif:si --0 vx.b) (dif:si --0 vy.b))
    [id.b -.start +.start vx.b vy.b 3.072]
  =/  player=body:hasterrad-enemies  [-.before +.before vx.w vy.w 12.288]
  =/  encounter  (resolve-scaled:hasterrad-enemies foes.w bolts player 1.024 enemy-hit)
  =.  w  w(foes s.encounter, score (add score.w points.encounter), shots (skim shots.w |=(b=shot !(lien consumed.encounter |=(id=@ud =(id id.b))))))
  ?:  (gth shield.w 0)  w(shield (dec shield.w))
  ?.  |(danger.encounter (lien targets.w |=(t=target (near x.w y.w x.t y.t (add radius.t 12)))))  w
  =.  lives.w  (dec lives.w)
  w(x 524.288, y 393.216, vx --0, vy --0, shield 30, shots ~, status ?:(=(0 lives.w) %gameover %playing))
++  enemy-hit
|=  [x=@ud y=@ud vx=@s vy=@s tx=@ud ty=@ud tvx=@s tvy=@s radius=@ud]
^-  ?
=/  ap  (translate x y `@sd`vx `@sd`vy)
=/  bp  (translate tx ty `@sd`tvx `@sd`tvy)
=/  a=shot  [0 -.ap +.ap 0 2 `@sd`vx `@sd`vy]
=/  b=target  [0 ~zod %galaxy ~['zod'] -.bp +.bp (div (add radius 1.023) 1.024) `@sd`tvx `@sd`tvy]
(swept a b)
++  distance
  |=  [a=@ud b=@ud]
  (sub (max a b) (min a b))
++  near
  |=  [x=@ud y=@ud xx=@ud yy=@ud radius=@ud]
  =/  dx  (distance x xx)
  =/  dy  (distance y yy)
  =.  dx  (min dx (sub 1.048.576 dx))
  =.  dy  (min dy (sub 786.432 dy))
  =/  r  (mul radius 1.024)
  (lte (add (mul dx dx) (mul dy dy)) (mul r r))
++  split
  |=  [t=target next=@ud]
  ^-  (list target)
  ?:  (lte (lent syllables.t) 1)  ~
  =/  half  (div (lent syllables.t) 2)
  =/  impulse  (vector (mod (mug [origin.t id.t]) 360) 2.048)
  =/  ax  (sum:si vx.t vx.impulse)
  =/  ay  (sum:si vy.t vy.impulse)
  =/  bx  (dif:si vx.t vx.impulse)
  =/  by  (dif:si vy.t vy.impulse)
  =/  pa  (translate x.t y.t (pro:si vx.impulse --8) (pro:si vy.impulse --8))
  =/  pb  (translate x.t y.t (pro:si vx.impulse -8) (pro:si vy.impulse -8))
  :~  t(id next, syllables (scag half syllables.t), x -.pa, y +.pa, vx ax, vy ay, radius (max 16 (div radius.t 2)))
      t(id +(next), syllables (slag half syllables.t), x -.pb, y +.pb, vx bx, vy by, radius (max 16 (div radius.t 2)))
  ==
++  collide
  |=  [w=world pending=(list shot) kept=(list shot)]
  ^-  world
  ?~  pending  w(shots (flop kept))
  =/  s  i.pending
  =/  hit  (find-target targets.w s)
  ?~  hit  $(pending t.pending, kept [s kept])
  =/  t  u.hit
  =.  targets.w  (weld (split t next.w) (skim targets.w |=(a=target !=(id.a id.t))))
  $(pending t.pending, w w(score (add score.w 10), next (add next.w 2)))
++  delta
  |=  [a=@ud b=@ud size=@ud]
  ^-  @sd
  =/  d  (dif:si (new:si %.y a) (new:si %.y b))
  ?:  (lte (abs:si d) (div size 2))  d
  =/  signed  (old:si d)
  (sum:si d (new:si !-.signed size))
++  dot
  |=  [ax=@sd ay=@sd bx=@sd by=@sd]
  ^-  @sd
  (sum:si (pro:si ax bx) (pro:si ay by))
++  swept
  |=  [s=shot t=target]
  ^-  ?
  =/  sp  (translate x.s y.s (dif:si --0 vx.s) (dif:si --0 vy.s))
  =/  tp  (translate x.t y.t (dif:si --0 vx.t) (dif:si --0 vy.t))
  =/  qx  (delta -.tp -.sp 1.048.576)
  =/  qy  (delta +.tp +.sp 786.432)
  =/  dx  (dif:si vx.s vx.t)
  =/  dy  (dif:si vy.s vy.t)
  =/  projection  (dot qx qy dx dy)
  =/  length  (abs:si (dot dx dy dx dy))
  =/  radius  (mul 1.024 (max 16 radius.t))
  =/  rr  (mul radius radius)
  =/  signed  (old:si projection)
  ?:  |(!-.signed =(0 length))
    (lte (abs:si (dot qx qy qx qy)) rr)
  ?:  (gte (abs:si projection) length)
    =/  ex  (dif:si qx dx)
    =/  ey  (dif:si qy dy)
    (lte (abs:si (dot ex ey ex ey)) rr)
  =/  cross  (abs:si (dif:si (pro:si qx dy) (pro:si qy dx)))
  (lte (mul cross cross) (mul rr length))
++  find-target
  |=  [targets=(list target) s=shot]
  ^-  (unit target)
  ?~  targets  ~
  ?:  (swept s i.targets)  `i.targets
  $(targets t.targets)
++  snapshot
  |=  w=world
  ^-  json
  %-  pairs:enjs:format
  :~  ['version' [%n '2']]
      ['stepMs' [%n '100']]
      ['enemies' (enemies-json:hasterrad-enemies foes.w)]
      ['enemyShots' (shots-json:hasterrad-enemies foes.w)]
      ['ship' [%s (scot %p ship.w)]]
      ['syllables' [%a (turn (syllables ship.w) |=(s=@t [%s s]))]]
      ['status' [%s status.w]]
      ['tick' (numb:enjs:format tick.w)]
      ['level' (numb:enjs:format level.w)]
      ['phase' [%s phase.w]]
      ['transitionTicks' (numb:enjs:format pause.w)]
      ['score' (numb:enjs:format score.w)]
      ['lives' (numb:enjs:format lives.w)]
      ['width' [%n '1024']]
      ['height' [%n '768']]
      ['player' (pairs:enjs:format ~[['x' (fixed-json (new:si %.y x.w))] ['y' (fixed-json (new:si %.y y.w))] ['angle' (numb:enjs:format angle.w)] ['vx' (fixed-json vx.w)] ['vy' (fixed-json vy.w)]])]
      ['shots' [%a (turn shots.w |=(s=shot (pairs:enjs:format ~[['id' (numb:enjs:format id.s)] ['x' (fixed-json (new:si %.y x.s))] ['y' (fixed-json (new:si %.y y.s))] ['vx' (fixed-json vx.s)] ['vy' (fixed-json vy.s)]])))]]
      ['targets' [%a (turn targets.w target-json)]]
  ==
++  target-json
  |=  t=target
  ^-  json
  %-  pairs:enjs:format
  :~  ['id' (numb:enjs:format id.t)]
      ['originShip' [%s (scot %p origin.t)]]
      ['generated' [%b %.y]]
      ['ingredientSourcePool' [%a (turn catalogue |=(p=@p [%s (scot %p p)]))]]
      ['kind' [%s kind.t]]
      ['label' [%s ?:(=((syllables origin.t) syllables.t) (scot %p origin.t) (rap 3 syllables.t))]]
      ['syllables' [%a (turn syllables.t |=(s=@t [%s s]))]]
      ['x' (fixed-json (new:si %.y x.t))]
      ['vx' (fixed-json vx.t)]
      ['vy' (fixed-json vy.t)]
      ['y' (fixed-json (new:si %.y y.t))]
      ['radius' (numb:enjs:format radius.t)]
  ==
++  fixed-json
  |=  value=@sd
  ^-  json
  =/  signed  (old:si value)
  =/  mag  (abs:si value)
  =/  whole  (div mag 1.024)
  =/  frac  (div (mul (mod mag 1.024) 1.000.000) 1.024)
  =/  digits  (skim (trip (scot %ud frac)) |=(c=@tD !=(c '.')))
  =/  padded  (weld (reap (sub 6 (lent digits)) '0') digits)
  =/  integral  (skim (trip (scot %ud whole)) |=(c=@tD !=(c '.')))
  [%n (cat 3 ?:(-.signed '' '-') (crip (weld integral ['.' padded])))]
++  upgrade-v2
  |=  old=world-v2
  ^-  world
  [ship.old status.old tick.old score.old lives.old x.old y.old angle.old next.old shield.old shots.old targets.old vx.old vy.old [tick.old 1 (add tick.old 80) 0 ~ ~] 1 %active 0]
++  upgrade-world
  |=  old=world-v1
  ^-  world
  =/  shots=(list shot)
    %+  turn  shots.old
    |=  s=shot-v1
    =/  v  (vector angle.s 24.576)
    [id.s (mul x.s 1.024) (mul y.s 1.024) angle.s ttl.s vx.v vy.v]
  =/  targets=(list target)
    %+  turn  targets.old
    |=  t=target-v1
    =/  v  (rock-vector origin.t id.t)
    [id.t origin.t kind.t syllables.t (mul x.t 1.024) (mul y.t 1.024) (max 16 radius.t) vx.v vy.v]
  [ship.old status.old tick.old score.old lives.old (mul x.old 1.024) (mul y.old 1.024) angle.old next.old shield.old shots targets --0 --0 [tick.old 1 (add tick.old 80) 0 ~ ~] 1 %active 0]
++  upgrade-v4
  |=  old=world-v4
  ^-  world
  [ship.old status.old tick.old score.old lives.old x.old y.old angle.old next.old shield.old shots.old targets.old vx.old vy.old foes.old 1 %active 0]
++  difficulty
  |=  level=@ud
  (min 4 (sub (max 1 level) 1))
++  complete-wave
  |=  w=world
  ^-  world
  w(phase %complete, pause 15, shots ~, vx --0, vy --0, foes [tick.w next.foes.w (add tick.w 80) turn.foes.w ~ ~])
++  seed-wave
  |=  w=world
  ^-  world
  =/  d  (difficulty level.w)
  =/  ts  (generate (min 6 (add 1 level.w)) (add tick.w level.w))
  =/  i=@ud  0
  =/  out=(list target)  ~
  |-  ^-  world
  ?~  ts  w(targets (flop out), next (add next.w i), shield (max 20 shield.w), foes [tick.w next.foes.w (add tick.w 150) turn.foes.w ~ ~])
  =/  t  i.ts
  =/  v  (vector (mod (mug [origin.t id.t]) 360) (add 768 (mul d 256)))
  =/  px  (wrap x.w (new:si %.y (add 393.216 (mul (mod i 3) 65.536))) 1.048.576)
  =/  py  (wrap y.w (new:si %.y (mul (mod i 4) 98.304)) 786.432)
  $(ts t.ts, i +(i), out [t(id (add next.w i), x px, y py, vx vx.v, vy vy.v) out])
++  decode
  |=  j=json
  ^-  [action=@t seq=@ud input=controls pressed=?]
  ?>  ?=(%o -.j)
  =/  a  (~(got by p.j) 'action')
  =/  s  (~(got by p.j) 'seq')
  ?>  ?=(%s -.a)
  =/  seq  (ni:dejs:format s)
  ?>  &((gth seq 0) (lte seq 2.147.483.647))
  ?:  |(=('start' p.a) =('restart' p.a))
    ?>  =(2 (lent ~(tap by p.j)))
    [p.a seq [%| %| %| %|] %|]
  ?>  |(=('input' p.a) =('release' p.a))
  =/  count  (lent ~(tap by p.j))
  ?>  |(=(6 count) =(7 count))
  =/  pressed
    ?:  =(6 count)  %|
    =/  edge  (~(got by p.j) 'firePressed')
    ?>  ?=(%b -.edge)
    p.edge
  =/  l  (~(got by p.j) 'left')
  =/  r  (~(got by p.j) 'right')
  =/  t  (~(got by p.j) 'thrust')
  =/  f  (~(got by p.j) 'fire')
  ?>  &(?=(%b -.l) ?=(%b -.r) ?=(%b -.t) ?=(%b -.f))
  [p.a seq [p.l p.r p.t p.f] pressed]
++  syllables
  |=  ship=@p
  ^-  (list @t)
  =/  letters=tape  (skim (trip (scot %p ship)) |=(c=@tD &((gte c 'a') (lte c 'z'))))
  (chunks (crip letters))
++  chunks
  |=  letters=@t
  ^-  (list @t)
  ?:  =(0 letters)  ~
  [(cut 3 [0 3] letters) $(letters (rsh [3 3] letters))]
--
