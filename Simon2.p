/*
Anniversary Puzzle: Simon Says

Reproduce musical sequence.
*/

#include <futurocube>

new i

new icon[]=[ICON_MAGIC1,ICON_MAGIC2,1,1,
    cPURPLE,GREEN,cPURPLE,
    GREEN,cPURPLE,GREEN,
    cPURPLE,GREEN,0,
    ''SIMON2'',''c5''] //icon,icon,menu,side,9cells,name,info

// Active state
new STATE_RUNNING = 0
new STATE_GOOD = 1
new STATE_BAD = 2
new STATE_DONE = 3

new activeState = 0 // 0 running | 1 good | 2 bad
new activeStateTimer = 0

// Sequence (corresponds to side IDs)
//
// Futuro IDs (0 is bottom):
//       [5]
// [0][2][1][3]
//       [4]
//
new sequence[] = [1,0,2,3,3,2,1,0]

// Current position in the sequence
new seqIndex = 0

// Tapped side
new tappedSide = -1

new motion

main()
{
  ICON(icon)
  RegAllSideTaps()
  RegMotion(SHAKING)

  SetVolume(4000)

  drawSides()
  for(i = 0; i < sizeof(sequence); i++) {
      playNote(sequence[i],true);
  }

  for (;;)
  {
    //ClearCanvas()
    //c=GetCursor()

    //printf("side: %d, square: %d, index: %d\r\n",_side(c), _square(c), _i(c))

    motion = Motion()
    if(motion && _is(motion, SHAKING)) {
        printf("RESET\n")
        Restart()
    } else if(motion) {
        doTap()
    }
    AckMotion()

    if(activeState == STATE_GOOD) {
        SetRgbColor(0,0,0)
        DrawCube()
        SetRgbColor(255,200,200)
        DrawSide(tappedSide)
        activeStateTimer--

        if(activeStateTimer <= 0) {
            activeState = STATE_RUNNING
            drawSides()
        }
    }

    if(activeState == STATE_BAD) {
        SetRgbColor(0,0,0)
        DrawCube()
        SetRgbColor(15,0,0)
        DrawSide(tappedSide)
        activeStateTimer--

        if(activeStateTimer <= 0) {
            activeState = STATE_RUNNING
            drawSides()
        }
    }

    if(activeState == STATE_DONE) {
        SetRgbColor(100,255,100+GetRnd(156))
        DrawCube()
    }

    PrintCanvas()
    Sleep()
  }
}

drawSides() {
    // Bottom
    SetColor(cRED)
    DrawSide(0)

    // Top
    SetColor(cGREEN)
    DrawSide(1)

    // Left
    SetColor(cBLUE)
    DrawSide(2)

    // Right
    SetColor(cORANGE)
    DrawSide(3)

    // Front
    SetColor(cMAGENTA)
    DrawSide(4)

    // Back
    SetColor(cPURPLE)
    DrawSide(5)
}

doTap() {
    //if(activeState == STATE_RUNNING) {
        tappedSide = eTapSide()
        printf("TAP ON SIDE %d\n", tappedSide)
        if(tappedSide == sequence[seqIndex] || activeState == STATE_DONE) {
            if((seqIndex + 1) < sizeof(sequence)) {
                // New input is correct
                activeState = STATE_GOOD
                activeStateTimer = 100
                seqIndex++
                printf("SIDE OK\n")
            } else {
                printf("WON!\n")
                activeState = STATE_DONE
                playNote(tappedSide,true)
                playVictory()
                return
            }
        } else {
            // Incorrect change, reset
            //Play("wrong_move")
            activeState = STATE_BAD
            activeStateTimer = 100
            printf("SIDE BAD, EXPECTED %d, RESETTING\n", sequence[seqIndex])
            seqIndex = 0
        }

        playNote(tappedSide,false)
    //}
}

playNote(side,wait) {
    Quiet()
    //SetAudioForce(1)
    switch(side) {
        case 0: Play("@_f4")
        case 1: Play("@_a4")
        case 2: Play("@_g4")
        case 3: Play("@_c4")
        case 4: Play("@_e1")
        case 5: Play("@_a#1")
    }

    if(wait) {
        WaitPlayOver()
    }
}

playVictory() {
    Quiet()
    SetVolume(17000)
    Play("@_c_SIMULATION")
    WaitPlayOver()
}
