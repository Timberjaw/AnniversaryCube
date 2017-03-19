/*
Anniversary Puzzle: Simon Says

Reproduce musical sequence.
*/

#include <futurocube>

#define cYELLOW 0x80800000

new i = 0

new icon[]=[ICON_MAGIC1,ICON_MAGIC2,1,1,
    BLUE,GREEN,BLUE,
    GREEN,BLUE,GREEN,
    BLUE,GREEN,0,
    ''SIMONGROUP'',''_c1''] //icon,icon,menu,side,9cells,name,info

// Active state
new STATE_RUNNING = 0
new STATE_GOOD = 1
new STATE_BAD = 2
new STATE_DONE = 3
new STATE_MENU = 99
new STATE_RUNNING_P1 = 100
new STATE_RUNNING_P2 = 101

new activeState = 0 // 0 running | 1 good | 2 bad
new metaState = 0
new activeStateTimer = 0

// Sequence (corresponds to side IDs)
//
// Futuro IDs (0 is bottom):
//       [5]
// [0][2][1][3]
//       [4]
//
new seqIndexP1 = 0
new seqIndexP2 = 0
new sequence_menu_p1[] = [1,0,3,3,5,4]
new sequence_menu_p2[] = [2,3,3,1,4]
new sequence_p1[] = [0,1,2,3,0,2,1,0]
new sequence_p2[] = [1,0,2,3,3,2,1,0]

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
  metaState = STATE_MENU

  for(;;) {
    if(metaState == STATE_MENU) {
        runMenu()
    } else if(metaState == STATE_RUNNING_P1) {
        runSimon1()
    } else if(metaState == STATE_RUNNING_P2) {
        runSimon2()
    } else {
        //printf("QUIT\n")
        //return
    }
    Sleep()
  }
}

runMenu() {
    Play("woodblock")

    for(;;)
    {
        motion = Motion()
        if(motion && _is(motion, SHAKING)) {
            printf("RESET\n")
            metaState = STATE_MENU
            //return
        } else if(motion) {
            doTapMenu()

            if(metaState == STATE_RUNNING_P1 || metaState == STATE_RUNNING_P2) {
                printf("STATE TRANSITION")
                return
            }
        }
        AckMotion()

        if(activeState == STATE_GOOD || activeState == STATE_BAD) {
            drawSingleSide(tappedSide,true)
            activeStateTimer--

            if(activeStateTimer <= 0) {
                activeState = STATE_RUNNING
            }
        } else {
            drawSides()
        }

        PrintCanvas()
        Sleep()
    }
}

runSimon1() {

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

  seqIndex = 0

  for (;;)
  {
    //ClearCanvas()
    //c=GetCursor()

    //printf("side: %d, square: %d, index: %d\r\n",_side(c), _square(c), _i(c))

    motion = Motion()
    if(motion && _is(motion, SHAKING)) {
        printf("P1 RESET\n")
        metaState = STATE_MENU
        return
    } else if(motion) {
        doTapP1()
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

runSimon2() {
  SetVolume(4000)

  drawSides()
  for(i = 0; i < sizeof(sequence_p2); i++) {
      playNote(sequence_p2[i],true);
  }

  seqIndex = 0

  for (;;)
  {
    //ClearCanvas()
    //c=GetCursor()

    //printf("side: %d, square: %d, index: %d\r\n",_side(c), _square(c), _i(c))

    motion = Motion()
    if(motion && _is(motion, SHAKING)) {
        printf("P2 RESET\n")
        metaState = STATE_MENU
        return
    } else if(motion) {
        doTapP2()
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
        case 4: SetColor(cYELLOW)
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

doTapMenu() {
    tappedSide = eTapSide()
    printf("COLOR TAP ON SIDE %d\n", tappedSide)

    if(tappedSide == sequence_menu_p1[seqIndexP1]) {
        if((seqIndexP1 + 1) < sizeof(sequence_menu_p1)) {
            // New input is correct
            activeState = STATE_GOOD
            activeStateTimer = 100
            seqIndexP1++
            printf("SIDE OK\n")
        } else {
            printf("WON!\n")
            metaState = STATE_RUNNING_P1
            return
        }
    } else {
        // Incorrect change, reset
        activeState = STATE_BAD
        activeStateTimer = 100
        printf("COLOR SIDE BAD, EXPECTED %d, RESETTING\n", sequence_menu_p1[seqIndexP1])
        seqIndexP1 = 0
    }

    if(tappedSide == sequence_menu_p2[seqIndexP2]) {
        if((seqIndexP2 + 1) < sizeof(sequence_menu_p2)) {
            // New input is correct
            activeState = STATE_GOOD
            activeStateTimer = 100
            seqIndexP2++
            printf("SIDE OK\n")
        } else {
            printf("WON!\n")
            metaState = STATE_RUNNING_P2
            return
        }
    } else {
        // Incorrect change, reset
        //Play("wrong_move")
        activeState = STATE_BAD
        activeStateTimer = 100
        printf("COLOR SIDE BAD, EXPECTED %d, RESETTING\n", sequence_menu_p2[seqIndexP2])
        seqIndexP2 = 0
    }
}

doTapP1() {
    //if(activeState == STATE_RUNNING) {
        tappedSide = eTapSide()
        printf("TAP ON SIDE %d\n", tappedSide)
        if(tappedSide == sequence_p1[seqIndex] || activeState == STATE_DONE) {
            if((seqIndex + 1) < sizeof(sequence_p1)) {
                // New input is correct
                activeState = STATE_GOOD
                activeStateTimer = 100
                seqIndex++
                printf("SIDE OK\n")
            } else {
                printf("WON!\n")
                activeState = STATE_DONE
                playNote(tappedSide,true)
                playVictoryP1()
                return
            }
        } else {
            // Incorrect change, reset
            //Play("wrong_move")
            activeState = STATE_BAD
            activeStateTimer = 100
            printf("SIDE BAD, EXPECTED %d, RESETTING\n", sequence_p1[seqIndex])
            seqIndex = 0
        }

        playNote(tappedSide,false)
    //}
}

doTapP2() {
    //if(activeState == STATE_RUNNING) {
        tappedSide = eTapSide()
        printf("TAP ON SIDE %d\n", tappedSide)
        if(tappedSide == sequence_p2[seqIndex] || activeState == STATE_DONE) {
            if((seqIndex + 1) < sizeof(sequence_p2)) {
                // New input is correct
                activeState = STATE_GOOD
                activeStateTimer = 100
                seqIndex++
                printf("SIDE OK\n")
            } else {
                printf("WON!\n")
                activeState = STATE_DONE
                playNote(tappedSide,true)
                playVictoryP2()
                return
            }
        } else {
            // Incorrect change, reset
            //Play("wrong_move")
            activeState = STATE_BAD
            activeStateTimer = 100
            printf("SIDE BAD, EXPECTED %d, RESETTING\n", sequence_p2[seqIndex])
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

playVictoryP1() {
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

playVictoryP2() {
    Quiet()
    SetVolume(17000)
    Play("@_c_SIMULATION")
    WaitPlayOver()
}
