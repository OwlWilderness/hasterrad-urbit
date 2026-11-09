=/  b  *bowl:gall
=.  b  b(our ~zod, src ~zod, now ~2026.11.8)
=.  a  ~(. a b)
=/  w  (fresh:c ~zod)
=.  w  w(targets ~, phase %complete, pause 1)
=/  loaded  (on-load:a !>([%5 w 42 now.b [%| %| %| %|] %| now.b %| %| 0]))
=.  a  +.loaded
=/  watched  (on-watch:a /state)
=.  a  +.watched
=/  ticked  (on-arvo:a /tick [%behn %wake ~])
=.  a  +.ticked
=/  saved  !<([%5 w=world:c seq=@ud last=@da input=controls:c running=? due=@da connected=? pending=? cooldown=@ud] on-save:a)
?>  &(=(2 level.w.saved) =(%active phase.w.saved) fire.input.saved !pending.saved =(~ shots.w.saved))

=.  b  b(now (add now.b (div ~s1 10)))
=.  a  ~(. a b)
=/  held  (on-poke:a %json !>((pairs:enjs:format ~[['action' s+'input'] ['seq' n+'43'] ['left' b+%|] ['right' b+%|] ['thrust' b+%|] ['fire' b+%&] ['firePressed' b+%|]])))
=.  a  +.held
=/  after  !<([%5 w=world:c seq=@ud last=@da input=controls:c running=? due=@da connected=? pending=? cooldown=@ud] on-save:a)
?>  !pending.after
