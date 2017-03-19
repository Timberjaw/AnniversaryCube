/*
Anniversary Puzzle: Roller

Roll cube along predetermined path to unlock clue.
*/

#include <futurocube>

new i
new c

new icon[]=[ICON_MAGIC1,ICON_MAGIC2,1,1,
    GREEN,GREEN,GREEN,
    WHITE,WHITE,WHITE,
    GREEN,GREEN,GREEN,
    ''ROLLER'',''woodblock''] //icon,icon,menu,side,9cells,name,info

// Active state
new STATE_RUNNING = 0
new STATE_GOOD = 1
new STATE_BAD = 2
new STATE_DONE = 3

new activeState = 0 // 0 running | 1 good | 2 bad
new activeStateTimer = 0

// Path (0-5 corresponding to side #s)
// 0 is always original top, 1 is next side player rotates to
// Remaining side #s inferred from first two
//
// Sides:           Futuro IDs (0 is bottom):
//       [1]              [5]
// [3][2][0][5]     [0][2][1][3]
//       [4]              [4]
//
// Path:
// [0]      [3]
// [1][2]   [5]
//    [3][4][0]
//
//new path[] = [0,1,2,3,4,0,2,3]
new path[] =   [1,5,2,0,4,1,2,0]

// Current position on the track
new pathIndex = 1

// Starting side
new startingSide = 1

// Most recently accepted side
new lastSide = 1

// Current side
new currentSide = 1

new motion

main()
{
  ICON(icon)
  RegAllSideTaps()
  RegMotion(SHAKING)

  for (;;)
  {
    i+=5;
    SetRgbColor(100,200,100)
    ClearCanvas()
    c=GetCursor()
    DrawPoint(c)

    //printf("side: %d, square: %d, index: %d\r\n",_side(c), _square(c), _i(c))

    currentSide = _side(c);

    motion = Motion()
    if(motion && _is(motion, SHAKING)) {
        printf("RESET\n");
        Restart()
    }
    AckMotion()

    if(activeState == STATE_RUNNING && lastSide != currentSide) {
        if(currentSide == path[pathIndex]) {
            if((pathIndex + 1) < sizeof(path)) {
                // Side has changed and new side is correct
                activeState = STATE_GOOD
                activeStateTimer = 100
                pathIndex++
                lastSide = currentSide
                Play("woodblock")
                printf("SIDE OK\n")
            } else {
                printf("WON!\n")
                activeState = STATE_DONE
                activeStateTimer = 100
            }
        } else {
            // Incorrect change, reset
            activeState = STATE_BAD
            activeStateTimer = 100
            pathIndex = 1
            lastSide = 1
            printf("SIDE BAD, RESETTING\n")
        }
    }

    if(activeState == STATE_GOOD) {
        SetRgbColor(0,255,0)
        DrawSide(currentSide)
        activeStateTimer--

        if(activeStateTimer <= 0) {
            activeState = STATE_RUNNING
        }
    }

    if(activeState == STATE_BAD) {
        SetRgbColor(255,0,0)
        DrawSide(currentSide)
        activeStateTimer--

        if(activeStateTimer <= 0) {
            activeState = STATE_RUNNING
        }
    }

    if(activeState == STATE_DONE) {
        SetRgbColor(100,255,100+GetRnd(156))
        DrawCube()
        activeStateTimer--;

        if(activeStateTimer <= 0) {
            StartGameMenu()
        }
    }

    PrintCanvas()
    Sleep()
  }
}
