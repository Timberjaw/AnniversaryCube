/*
Anniversary Puzzle: MYCUBE
*/

#include <futurocube>

new icon[]=[ICON_MAGIC1,ICON_MAGIC2,1,1,
    BLUE,GREEN,BLUE,
    GREEN,BLUE,GREEN,
    BLUE,GREEN,BLUE,
    ''MYCUBE'',''hitrims1''] //icon,icon,menu,side,9cells,name,info

main()
{
  ICON(icon)

  SetVolume(4000)

  SetColor(cBLUE)
  DrawCube()
  PrintCanvas()
  Play("beep")

  for (;;)
  {
    Sleep()
  }
}
