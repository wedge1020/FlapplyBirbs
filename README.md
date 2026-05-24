# flappy

Vircon32 flappy bird-type game (written in assembly / machine code)

Struck by inspiration to attempt a Vircon32 game, and flappy bird came to
mind. Further, doing so in assembly  language, because that just makes it
more fun.

## gravity with sine?

The initial thought  going into this was becoming enamoured  with an idea
of using  the `sin` instruction to  be centrally important in  what would
otherwise be  the "gravity" calculation. I  want to explore and  see if I
can  accomplish  this central  gameplay  mechanism  by playing  with  the
amplitude and position  on the curve, basically letting the  sine wave as
it plays out influence the sprite position. We'll see.

I actually don't know if this approach has ever been explored before. Who
knows: maybe the  mainstream flappy bird approach is  already doing this.
I've not looked into it. This is merely my own thought and exploration at
this point.

## machine code routines

Then, as  I finally  set down  to lay out  some code,  I realized  that I
wanted to work some RAM-based magic as I've done in other recent projects
(`debuggerBIOS`), and  specifically to  do so with  respect to  the `INP`
IOPorts.  Although I  don't currently  see a  need for  a loop,  I wanted
something that could  potentially be used in a loop,  without the need to
manually specify the symbolic port names.

Now, while the latest version of the Vircon32 assembler does support just
specifying the IOPort hex values, I  found myself thinking of the problem
from a different perspective: I wanted to do it in RAM, which requires it
to actually be in machine code  instead of assembly language. And moreso:
to be machine code  in RAM meant the routine itself  has to modify itself
during runtime.

Here's the routine (8 words starting at RAM address 0x00000000):

```
    mov   R0,                  0x4E208000 ; mov  R1,           0x5C000400
    mov   [0x00000000],        R0
    mov   R0,                  0x5C000400
    mov   [0x00000001],        R0
    mov   R0,                  0x88200000 ; or   R1,           R0
    mov   [0x00000002],        R0
    mov   R0,                  0x4E034000 ; mov  [0x00000005], R1
    mov   [0x00000003],        R0
    mov   R0,                  0x00000005
    mov   [0x00000004],        R0
    mov   R0,                  0x5C000400 ; in   R0,           INP_port
    mov   [0x00000005],        R0
    mov   R0,                  0x10000000 ; ret
    mov   [0x00000006],        R0
    mov   R0,                  0x00000000 ; hlt (for safety)
    mov   [0x00000007],        R0
```

Basically, I  `CALL` it, storing  the desired  INP IOPort offset  in `R0`
(the parameter to this subroutine).

It is  `OR`ed against the  value in `R1` (the  machine code for  the `IN`
instruction from the base INP  IOPort)`, giving the specific port address
needed for the transaction.

This result is then stored in RAM,  at the precise address I desire it to
be executed. So while it is  predictable (assuming the parameter value is
appropriate- I  do no  checks), it  is still  neat in  that I  wrote, via
assembly, a machine  code routine that, in machine  code, modifies itself
in RAM then executes that modified machine code instruction.

It is the little things like that I do enjoy so.

I also love the required abstraction: what you see initially happening in
assembly  has no  bearing  on  the eventual  machine  code routine  being
executed. That I  am transacting `R0` in assembly has  nothing to do with
the use of `R0` in the machine code routine. So, troubleshooting needs to
maintain the appropriate context.

## gameplay

Actual gameplay should  be similar to what one expects  from the array of
flappy bird-like games: you press a button (`up`, I suppose) to engage in
one instance  of heightening. Not  pressing anything results in  a steady
falling toward screen bottom.

There are a set of vertical obstacles  moving from right to left, with an
opening you must clear.

While the game is over upon *any* collision, I am toying with the idea of
having more variety in this regard: maybe hitting an object won't be game
over,  but will  be like  hitting  a wall:  you simply  are blocked  from
proceeding further right until you clear the obstacle.

Also considering possible power-ups.

And multi-player.

I have background music, and want  to have level themes. Thinking a total
of 32 levels.  Maybe raise the number of cleared  obstacles to 1024, then
having 32 obstacles to clear per "level".

Or, have 31 levels of 32  obstacles, and one (intro/training) level of 8,
which would result in exactly 1000. We'll see.
