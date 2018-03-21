#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance force
SendMode input
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


;第一次使用脚本需要跳一次崖初始化朝向和位置
;关闭鼠标加速度使用（提高精确度的选项）
F1::
  while 1
  {
    ;城堡的入口走向选择任务，以及走进传送门
    Begin_game()
    Sleep 40000
    
    ;进入地图后走向悬崖边缘的部分
    Walk_to_edge()
    Sleep 200
    
    ;跳崖的部分
    Jump()
    Sleep 45000
    
    ;进入结算页面点击继续游戏的部分
    Click_save()
    Sleep 5000
  }
return


;关闭挂机脚本
#p::ExitApp


;以下是具体实现，可以根据自己需要调整
Begin_game()
{
  LLMouse.Move(164,0,1,2)
  Sleep 40
  Send {w down}
  Sleep 6190
  Send {w up}
  Sleep 300
  Send {e down}
  Sleep 300
  Send {e up}
  Sleep 300
  Click,1490,890
  Sleep 200
  Send {a down}
  Sleep 650
  Send {a up}
  Sleep 200
  Send {w down}
  Sleep 3500
  Send {w up}
  return
}
Walk_to_edge()
{
  LLMouse.Move(165,0,1,2)
  Send {w down}
  Sleep 4000
  Send {w up}
  LLMouse.Move(165,0,10,2)
  return
}

Jump()
{
  Send {w down}
  Sleep 100
  Send {Space}
  Sleep 300
  Send {w up}
  return 
}

Click_save() {
  MouseGetPos, xpos, ypos
  LLMouse.Move(956-xpos, 964-ypos, 1, 2)
  Sleep 30
  Click
  Sleep 30
  LLMouse.Move(xpos-956, ypos-964, 1, 2)
  return
}

;这个函数弃用了。最开始是在有鼠标加速度的情况下使用的
;在开启鼠标加速度的情况下，模拟鼠标移动的精确性不容易保证
;所以在关闭鼠标加速度后，使用上Click_save的版本
Click_save_acc()
{
  CoordMode, Mouse, Screen
  xc := 0
  yc := 0
  Loop 5
    {
      MouseGetPos, xpos, ypos
      xc := xc + xpos - 956
      yc := yc + ypos - 964
      LLMouse.Move((956-xpos)/1.5,(964-ypos)/1.5, 1,2)
      Sleep 10
      Click
    }
  LLMouse.Move(xc/1.51,yc/1.51,1,2)
  return
}


; =======================================================================================
; LLMouse - A library to send Low Level Mouse input

; Note that many functions have time and rate parameters.
; These all work the same way:
; times	- How many times to send the requested action. Optional, default is 1
; rate	- The rate (in ms) to send the action at. Optional, default rate varies
; Note that if you use a value for rate of less than 10, special code will kick in.
; QPX is used for rates of <10ms as the AHK Sleep command does not support sleeps this short
; More CPU will be used in this mode.
class LLMouse {
	static MOUSEEVENTF_MOVE := 0x1
	static MOUSEEVENTF_WHEEL := 0x800
	
	; ======================= Functions for the user to call ============================
	; Move the mouse
	; All values are Signed Integers (Whole numbers, Positive or Negative)
	; x		- How much to move in the x axis. + is right, - is left
	; y		- How much to move in the y axis. + is down, - is up
	Move(x, y, times := 1, rate := 1){
		this._MouseEvent(times, rate, this.MOUSEEVENTF_MOVE, x, y)
	}
	
	; Move the wheel
	; dir	- Which direction to move the wheel. 1 is up, -1 is down
	Wheel(dir, times := 1, rate := 10){
		static WHEEL_DELTA := 120
		this._MouseEvent(times, rate, this.MOUSEEVENTF_WHEEL, , , dir * WHEEL_DELTA)
	}
	
	; ============ Internal functions not intended to be called by end-users ============
	_MouseEvent(times, rate, dwFlags := 0, dx := 0, dy := 0, dwData := 0){
		Loop % times {
			DllCall("mouse_event", uint, dwFlags, int, dx ,int, dy, uint, dwData, int, 0)
			if (A_Index != times){	; Do not delay after last send, or if rate is 0
				if (rate >= 10){
					Sleep % rate
				} else {
					this._Delay(rate * 0.001)
				}
			}
		}
	}
	
	_Delay( D=0.001 ) { ; High Resolution Delay ( High CPU Usage ) by SKAN | CD: 13/Jun/2009
		Static F ; www.autohotkey.com/forum/viewtopic.php?t=52083 | LM: 13/Jun/2009
		Critical
		F ? F : DllCall( "QueryPerformanceFrequency", Int64P,F )
		DllCall( "QueryPerformanceCounter", Int64P,pTick ), cTick := pTick
		While( ( (Tick:=(pTick-cTick)/F)) <D ) {
			DllCall( "QueryPerformanceCounter", Int64P,pTick )
			Sleep -1
		}
		Return Round( Tick,3 )
	}
}