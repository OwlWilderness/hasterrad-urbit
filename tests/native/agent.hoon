=/  b  *bowl:gall
=.  b  b(our ~dirted-pallup, src ~dirted-pallup, now ~2026.11.8)
=.  a  ~(. a b)
=/  w  (fixture:c ~dirted-pallup)
=/  old=world-v4:c  [ship.w status.w 71 230 3 x.w y.w 37 80 20 ~[[5 10 10 0 30 --0 --0]] targets.w vx.w vy.w [71 12 90 2 ~ ~]]
=/  loaded  (on-load:a !>([%4 old 42 now.b [%& %& %& %&] %| now.b %& %& 2]))
=.  a  +.loaded
=/  saved  !<([%5 w=world:c seq=@ud last=@da input=controls:c running=? due=@da connected=? pending=? cooldown=@ud] on-save:a)
?>  =((upgrade-v4:c old) w.saved)
?>  &(=(42 seq.saved) =(2 cooldown.saved) !pending.saved !connected.saved =([%| %| %| %|] input.saved))
=/  pause  (complete-wave:c w.saved(targets ~))
=/  loaded  (on-load:a !>(saved(w pause)))
=.  a  +.loaded
=.  b  b(now (add now.b ~s1))
=.  a  ~(. a b)
=/  poke  (on-poke:a %json !>((pairs:enjs:format ~[['action' s+'input'] ['seq' n+'43'] ['left' b+%&] ['right' b+%|] ['thrust' b+%&] ['fire' b+%&] ['firePressed' b+%&]])))
=.  a  +.poke
=/  paused  !<([%5 w=world:c seq=@ud last=@da input=controls:c running=? due=@da connected=? pending=? cooldown=@ud] on-save:a)
?>  &(!pending.paused =([%| %| %| %|] input.paused) =(pause w.paused))
=.  b  b(now (add now.b ~s1))
=.  a  ~(. a b)
=/  restarted  (on-poke:a %json !>((pairs:enjs:format ~[['action' s+'restart'] ['seq' n+'44']])))
=.  a  +.restarted
=/  reset  !<([%5 w=world:c seq=@ud last=@da input=controls:c running=? due=@da connected=? pending=? cooldown=@ud] on-save:a)
?>  &(=(44 seq.reset) =(1 level.w.reset) =(0 score.w.reset) =(4 lives.w.reset) =(2 (lent targets.w.reset)) !pending.reset =(0 cooldown.reset))
