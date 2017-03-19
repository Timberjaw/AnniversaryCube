/*
Anniversary Puzzle: Simon Says

Reproduce musical sequence.
*/

#include <futurocube>

new icon[]=[ICON_MAGIC1,ICON_MAGIC2,1,1,
    BLUE,GREEN,BLUE,
    GREEN,BLUE,GREEN,
    BLUE,GREEN,0,
    ''SIMON1'',''_c1''] //icon,icon,menu,side,9cells,name,info

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
new sequence[] = [0,1,2,3,0,2,1,0]

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

  playNote(0,true)
  playNote(1,true)
  playNote(2,true)
  playNote(3,true)
  playNote(0,true)
  playNote(2,true)
  playNote(1,true)
  playNote(0,true)
  drawSides()

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

drawSingleSide(side,clear) {
    if(clear) {
        ClearCanvas()
    }

    switch(side) {
        case 0: SetColor(cRED)
        case 1: SetColor(cGREEN)
        case 2: SetColor(cBLUE)
        case 3: SetColor(cORANGE)
        case 4: SetColor(cMAGENTA)
        case 5: SetColor(cPURPLE)
    }

    DrawSide(side)

    if(clear) {
        PrintCanvas()
    }
}

drawSides() {
    // Bottom
    drawSingleSide(0,false)

    // Top
    drawSingleSide(1,false)

    // Left
    drawSingleSide(2,false)

    // Right
    drawSingleSide(3,false)

    // Front
    drawSingleSide(4,false)

    // Back
    drawSingleSide(5,false)
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
    drawSingleSide(side,true)
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
    SetVolume(17000)
    Quiet()
    Play("@700")
    WaitPlayOver()
    Play("1000")
    WaitPlayOver()
    Play("@300")
    WaitPlayOver()
    Play("@50")
    WaitPlayOver()
    Play("@9")
    WaitPlayOver()
}
