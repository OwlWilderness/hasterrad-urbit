/+  default-agent, hasterrad-core
=,  hasterrad-core
|%
+$  card  card:agent:gall
+$  saved-v1  [%1 w=world-v1 seq=@ud last=@da input=controls running=? due=@da connected=?]
+$  saved-v2  [%2 w=world-v2 seq=@ud last=@da input=controls running=? due=@da connected=?]
+$  saved-v3  [%3 w=world-v4 seq=@ud last=@da input=controls running=? due=@da connected=?]
+$  saved-v4  [%4 w=world-v4 seq=@ud last=@da input=controls running=? due=@da connected=? pending=? cooldown=@ud]
+$  saved  [%5 w=world seq=@ud last=@da input=controls running=? due=@da connected=? pending=? cooldown=@ud]
--
=|  s=saved
=<  agent
|%
++  agent
  ^-  agent:gall
  |_  =bowl:gall
  +*  this  .
      def  ~(. (default-agent this %|) bowl)
  ++  on-init
    ^-  (quip card _this)
    =/  w  (fresh our.bowl)
    =.  status.w  %ready
    `this(s [%5 w 0 `@da`0 [%| %| %| %|] %| `@da`0 %| %| 0])
  ++  on-save  !>(s)
  ++  on-load
    |=  old=vase
    ^-  (quip card _this)
    ?>  |(?=(%1 -.q.old) ?=(%2 -.q.old) ?=(%3 -.q.old) ?=(%4 -.q.old) ?=(%5 -.q.old))
    =.  s
      ?:  ?=(%5 -.q.old)  !<(saved old)
      ?:  ?=(%4 -.q.old)
        =/  previous  !<(saved-v4 old)
        [%5 (upgrade-v4 w.previous) seq.previous last.previous input.previous running.previous due.previous connected.previous pending.previous cooldown.previous]
      ?:  ?=(%3 -.q.old)
        =/  previous  !<(saved-v3 old)
        [%5 (upgrade-v4 w.previous) seq.previous last.previous input.previous running.previous due.previous connected.previous %| 0]
      ?:  ?=(%2 -.q.old)
        =/  previous  !<(saved-v2 old)
        [%5 (upgrade-v2 w.previous) seq.previous last.previous input.previous running.previous due.previous connected.previous %| 0]
      =/  previous  !<(saved-v1 old)
      [%5 (upgrade-world w.previous) seq.previous last.previous input.previous running.previous due.previous connected.previous %| 0]
    ?>  =(our.bowl ship.w.s)
    =.  w.s  w.s(shots (scag 4 shots.w.s))
    =.  s  s(input [%| %| %| %|], connected %|, pending %|)
    ?.  running.s  `this
    :_  this(running.s %|)
    ~[[%pass /tick %arvo %b %rest due.s]]
  ++  on-poke
    |=  [=mark =vase]
    ^-  (quip card _this)
    ?>  =(our.bowl src.bowl)
    ?>  =(%json mark)
    =/  d  (decode !<(json vase))
    ?>  (gth seq.d seq.s)
    ?>  (gte now.bowl (add last.s (div ~s1 20)))
    =.  s  s(seq seq.d, last now.bowl)
    ?:  |(=('start' action.d) =('restart' action.d))
      =.  w.s  (fresh our.bowl)
      =.  s  s(input [%| %| %| %&], pending %|, cooldown 0)
      =^  cards  s  (schedule s now.bowl)
      [[[%give %fact ~[/state] %json !>((state-json s))] cards] this]
    ?>  =(%playing status.w.s)
    =.  pending.s
      ?:  |(=('release' action.d) =(%complete phase.w.s) (gte (lent shots.w.s) 4))  %|
      |(pending.s pressed.d &(fire.input.d !fire.input.s))
    =.  input.s  ?:  |(=('release' action.d) =(%complete phase.w.s))  [%| %| %| %|]  input.d
    =^  cards  s  (schedule s now.bowl)
    [[[%give %fact ~[/state] %json !>((state-json s))] cards] this]
  ++  on-watch
    |=  =path
    ^-  (quip card _this)
    ?>  =(our.bowl src.bowl)
    ?>  =(/state path)
    =.  connected.s  %&
    =^  cards  s  (schedule s now.bowl)
    [[[%give %fact ~[/state] %json !>((state-json s))] cards] this]
  ++  on-leave
    |=  =path
    ^-  (quip card _this)
    =.  connected.s  %|
    =.  s  s(input [%| %| %| %|], pending %|)
    ?.  running.s  `this
    :_  this(running.s %|)
    ~[[%pass /tick %arvo %b %rest due.s]]
  ++  on-peek
    |=  =path
    ^-  (unit (unit cage))
    ?>  =(our.bowl src.bowl)
    ?+  path  (on-peek:def path)
      [%x %state ~]  ``json+!>((state-json s))
    ==
  ++  on-agent  on-agent:def
  ++  on-arvo
    |=  [=wire =sign-arvo]
    ^-  (quip card _this)
    ?.  =(/tick wire)  (on-arvo:def wire sign-arvo)
    ?.  ?=([%behn %wake ~] sign-arvo)  `this(running.s %|)
    ?.  running.s  `this
    =.  running.s  %|
    ?:  |(!connected.s !=(%playing status.w.s) (gth now.bowl (add last.s ~s3)))
      `this(input.s [%| %| %| %|], pending.s %|)
    ?:  =(%complete phase.w.s)
      =.  s  s(w (step w.s [%| %| %| %|]), input [%| %| %| %&], pending %|, cooldown 0)
      =^  cards  s  (schedule s now.bowl)
      [[[%give %fact ~[/state] %json !>((state-json s))] cards] this]
    =.  cooldown.s  (sub cooldown.s (min 1 cooldown.s))
    =.  pending.s  &(pending.s (lth (lent shots.w.s) 4))
    =/  shoot  &(=(0 cooldown.s) pending.s (lth (lent shots.w.s) 4))
    =.  w.s  (step w.s input.s(fire shoot))
    =.  pending.s  &(pending.s =(%playing status.w.s) =(%active phase.w.s))
    =.  input.s  ?:(=(%complete phase.w.s) [%| %| %| %|] input.s)
    ?:  shoot
      =.  s  s(pending %|, cooldown 3)
      =^  cards  s  (schedule s now.bowl)
      [[[%give %fact ~[/state] %json !>((state-json s))] cards] this]
    =^  cards  s  (schedule s now.bowl)
    [[[%give %fact ~[/state] %json !>((state-json s))] cards] this]
  ++  on-fail  on-fail:def
  --
++  state-json
  |=  s=saved
  ^-  json
  =/  j  (snapshot w.s)
  ?>  ?=(%o -.j)
  [%o (~(put by p.j) 'inputSeq' (numb:enjs:format seq.s))]
++  schedule
  |=  [s=saved now=@da]
  ^-  (quip card saved)
  ?:  |(running.s !connected.s !=(%playing status.w.s))  `s
  =.  due.s  (add now (div ~s1 10))
  :_  s(running %&)
  ~[[%pass /tick %arvo %b %wait due.s]]
--
