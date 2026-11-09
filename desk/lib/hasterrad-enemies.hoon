!:
|%
+$  enemy
  $:  id=@ud  kind=?(%large %small)  x=@ud  y=@ud  px=@ud  py=@ud
      vx=@s  vy=@s  angle=@ud  radius=@ud  ttl=@ud  fire-at=@ud  born=@ud
  ==
+$  shot
  $:  id=@ud  x=@ud  y=@ud  px=@ud  py=@ud  vx=@s  vy=@s  ttl=@ud  born=@ud
  ==
+$  state  [clock=@ud next=@ud spawn-at=@ud turn=@ud enemies=(list enemy) shots=(list shot)]
+$  bolt  [id=@ud x=@ud y=@ud vx=@s vy=@s radius=@ud]
+$  body  [x=@ud y=@ud vx=@s vy=@s radius=@ud]
+$  hit-gate  $-([x=@ud y=@ud vx=@s vy=@s tx=@ud ty=@ud tvx=@s tvy=@s radius=@ud] ?)
+$  outcome  [s=state points=@ud consumed=(list @ud) danger=?]
++  fresh
  ^-  state
  [0 1 80 0 ~ ~]
::  Signed atoms are zig-zag encoded; these small helpers avoid float physics.
++  signed
  |=  [negative=? magnitude=@ud]
  ^-  @s
  ?:  &(negative !=(0 magnitude))  `@s`(dec (mul 2 magnitude))
  `@s`(mul 2 magnitude)
++  magnitude
  |=  v=@s
  ^-  @ud
  (div +(v) 2)
++  negative
  |=  v=@s
  =(1 (mod v 2))
++  translate
  |=  [p=@ud v=@s span=@ud]
  ^-  @ud
  =/  m  (mod (magnitude v) span)
  (mod ?:((negative v) (sub (add p span) m) (add p m)) span)
++  delta
  |=  [a=@ud b=@ud span=@ud]
  ^-  @s
  =/  d  (sub (max a b) (min a b))
  ?:  (gth d (div span 2))  (signed (gte b a) (sub span d))
  (signed (lth b a) d)
++  cadence
  |=  kind=?(%large %small)
  ?:(=(%large kind) 24 16)
++  points
  |=  kind=?(%large %small)
  ?:(=(%large kind) 100 250)
++  make-enemy
  |=  [id=@ud turn=@ud tick=@ud px=@ud py=@ud]
  ^-  enemy
  =/  small  =(1 (mod turn 2))
  =/  neg  =(1 (mod (div turn 2) 2))
  =/  x  (mod (add px 512) 1.024)
  =/  y  (mod (add py 384) 768)
  [id ?:(small %small %large) x y x y (signed neg ?:(small 6 3)) (signed neg ?:(small 2 1)) ?:(neg 198 18) ?:(small 18 30) 300 (add tick 10) tick]
++  aim
  |=  [e=enemy tick=@ud px=@ud py=@ud]
  ^-  [vx=@s vy=@s]
  =/  spread  ?:(=(%large kind.e) 96 20)
  =/  offset  (signed =(0 (mod (add (div tick (cadence kind.e)) id.e) 2)) spread)
  =/  raw-x  (delta x.e px 1.024)
  =/  raw-y  (delta y.e py 768)
  =/  horizontal  (gte (magnitude raw-x) (magnitude raw-y))
  =/  dx  (delta x.e ?:(horizontal px (translate px offset 1.024)) 1.024)
  =/  dy  (delta y.e ?:(horizontal (translate py offset 768) py) 768)
  =/  scale  (max 1 (max (magnitude dx) (magnitude dy)))
  =/  speed  ?:(=(%large kind.e) 12 16)
  ::  Coincident aim still fires a nonzero, finite, straight shot.
  ?:  &(=(0 dx) =(0 dy))  [(signed %.n speed) --0]
  [(signed (negative dx) (div (mul speed (magnitude dx)) scale)) (signed (negative dy) (div (mul speed (magnitude dy)) scale))]
++  advance-enemy
  |=  e=enemy
  ^-  enemy
  e(px x.e, py y.e, x (translate x.e vx.e 1.024), y (translate y.e vy.e 768), ttl (dec ttl.e))
++  advance-shot
  |=  s=shot
  ^-  shot
  s(px x.s, py y.s, x (translate x.s vx.s 1.024), y (translate y.s vy.s 768), ttl (dec ttl.s))
++  step
  |=  [s=state tick=@ud px=@ud py=@ud]
  ^-  state
  (step-level s tick px py 0)
++  step-level
  |=  [s=state tick=@ud px=@ud py=@ud difficulty=@ud]
  ^-  state
  =/  d  (min 4 difficulty)
  ?:  (lte tick clock.s)  s
  =.  s  s(clock tick)
  =.  enemies.s  (turn (skim enemies.s |=(e=enemy (gth ttl.e 1))) advance-enemy)
  =.  shots.s  (turn (skim shots.s |=(b=shot (gth ttl.b 1))) advance-shot)
  =.  s  (fire-level s enemies.s ~ px py d)
  ?:  (lth tick spawn-at.s)  s
  =.  spawn-at.s  (add tick (sub 100 (mul d 15)))
  ?:  (gte (lent enemies.s) 1)  s
  =/  e  (make-enemy next.s turn.s tick px py)
  =.  e  e(vx (signed (negative vx.e) (add (magnitude vx.e) d)), vy (signed (negative vy.e) (add (magnitude vy.e) (div d 2))))
  s(enemies [e enemies.s], next +(next.s), turn +(turn.s))
++  step-wave
  |=  [s=state tick=@ud px=@ud py=@ud level=@ud]
  ^-  state
  =/  d  (min 3 (sub (max 3 level) 3))
  =.  s  ?:((lth level 3) s(spawn-at (add tick 1.000)) s)
  =.  s  ?:((lth level 5) s(turn 0) s)
  =/  before  spawn-at.s
  =.  s  (step-level s tick px py d)
  =.  s  ?:(=(before spawn-at.s) s s(spawn-at (add tick (sub 180 (mul d 20)))))
  =.  enemies.s
    %+  turn  enemies.s
    |=  e=enemy
    ?:  !=(born.e tick)  e
    ?:  =(%small kind.e)  e
    e(vx (signed (negative vx.e) (add 2 d)), vy (signed (negative vy.e) 1), fire-at (add tick 20))
  s
++  fire-all
  |=  [s=state pending=(list enemy) kept=(list enemy) px=@ud py=@ud]
  ^-  state
  (fire-level s pending kept px py 0)
++  fire-level
  |=  [s=state pending=(list enemy) kept=(list enemy) px=@ud py=@ud d=@ud]
  ^-  state
  ?~  pending  s(enemies (flop kept))
  =/  e  i.pending
  ?:  (lth clock.s fire-at.e)  $(pending t.pending, kept [e kept])
  =.  e  e(fire-at (add clock.s (sub (cadence kind.e) (mul (min 4 d) 2))))
  ?:  (gte (lent shots.s) 12)  $(pending t.pending, kept [e kept])
  =/  v  (aim e clock.s px py)
  =/  b=shot  [next.s x.e y.e x.e y.e vx.v vy.v 50 clock.s]
  $(pending t.pending, kept [e kept], s s(shots [b shots.s], next +(next.s)))
++  find-hit
  |=  [es=(list enemy) b=bolt tick=@ud scale=@ud hit=hit-gate]
  ^-  (unit enemy)
  ?~  es  ~
  =/  e  i.es
  =/  vx=@s  ?:(=(born.e tick) --0 vx.e)
  =/  vy=@s  ?:(=(born.e tick) --0 vy.e)
  ?:  (hit x.b y.b vx.b vy.b (mul px.e scale) (mul py.e scale) (scale-velocity vx scale) (scale-velocity vy scale) (add radius.b (mul radius.e scale)))  `e
  $(es t.es)
++  resolve
  |=  [s=state bolts=(list bolt) player=body hit=hit-gate]
  ^-  outcome
  (resolve-scaled s bolts player 1 hit)
++  scale-velocity
  |=  [v=@s scale=@ud]
  ^-  @s
  (signed (negative v) (mul (magnitude v) scale))
++  resolve-scaled
  |=  [s=state bolts=(list bolt) player=body scale=@ud hit=hit-gate]
  ^-  outcome
  ?>  (gth scale 0)
  =/  out=outcome  [s 0 ~ %.n]
  =.  out  (kill-bolts out bolts scale hit)
  (hazards out player scale hit)
++  kill-bolts
  |=  [out=outcome bs=(list bolt) scale=@ud hit=hit-gate]
  ^-  outcome
  ?~  bs  out
  =/  found  (find-hit enemies.s.out i.bs clock.s.out scale hit)
  ?~  found  $(bs t.bs)
  =/  e  u.found
  =.  enemies.s.out  (skim enemies.s.out |=(a=enemy !=(id.a id.e)))
  =.  out  out(points (add points.out (points kind.e)), consumed [id.i.bs consumed.out])
  $(bs t.bs)
++  hazards
  |=  [out=outcome player=body scale=@ud hit=hit-gate]
  ^-  outcome
  =/  pending=(list shot)  shots.s.out
  =/  kept=(list shot)  ~
  =.  danger.out
    %+  lien  enemies.s.out
    |=  e=enemy
    (hit (mul px.e scale) (mul py.e scale) (scale-velocity ?:(=(born.e clock.s.out) --0 vx.e) scale) (scale-velocity ?:(=(born.e clock.s.out) --0 vy.e) scale) x.player y.player vx.player vy.player (add (mul radius.e scale) radius.player))
  |-  ^-  outcome
  ?~  pending  out(s s.out(shots (flop kept)))
  =/  b  i.pending
  =/  touch  (hit (mul px.b scale) (mul py.b scale) (scale-velocity ?:(=(born.b clock.s.out) --0 vx.b) scale) (scale-velocity ?:(=(born.b clock.s.out) --0 vy.b) scale) x.player y.player vx.player vy.player (add (mul 3 scale) radius.player))
  ?:  touch  $(pending t.pending, out out(danger %.y))
  $(pending t.pending, kept [b kept])
++  signed-json
  |=  n=@s
  ^-  json
  [%n (crip (weld ?:((negative n) ~['-'] ~) (trip (scot %ud (magnitude n)))))]
++  enemy-json
  |=  e=enemy
  ^-  json
  %-  pairs:enjs:format
  :~  ['id' (numb:enjs:format id.e)]
      ['kind' [%s kind.e]]
      ['ship' [%s '~zod']]
      ['x' (numb:enjs:format x.e)]
      ['y' (numb:enjs:format y.e)]
      ['angle' (numb:enjs:format angle.e)]
      ['radius' (numb:enjs:format radius.e)]
      ['vx' (signed-json vx.e)]
      ['vy' (signed-json vy.e)]
  ==
++  shot-json
  |=  b=shot
  ^-  json
  %-  pairs:enjs:format
  :~  ['id' (numb:enjs:format id.b)]
      ['x' (numb:enjs:format x.b)]
      ['y' (numb:enjs:format y.b)]
      ['vx' (signed-json vx.b)]
      ['vy' (signed-json vy.b)]
  ==
++  enemies-json
  |=  s=state
  ^-  json
  [%a (turn enemies.s enemy-json)]
++  shots-json
  |=  s=state
  ^-  json
  [%a (turn shots.s shot-json)]
--
