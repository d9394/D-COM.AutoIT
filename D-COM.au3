#RequireAdmin

if processexists("北京结算通信网关.exe") then
  exit
endif

run("D:\Program Files (x86)\SSCC\北京结算通信网关\北京结算通信网关.exe","D:\Program Files (x86)\SSCC\北京结算通信网关\")

msgbox(0, "", "等待程序启动", 10)

local $handle = winwait( "北京结算通信网关" , "" )

if $handle <> 0 then
  while not winactive( $handle )
    msgbox(0, "", "等待窗口:" & $handle & "激活", 1)
    winactivate( $handle )
  wend

  local $ClassList=wingetclasslist( $handle )
  local $sClassList=stringsplit( $ClassList, @LF)
  local $classnumber=stringsplit( $sClassList[1], ".")

  controlsettext( $handle , "", "[CLASS:WindowsForms10.EDIT.app.0." & $classnumber[5] & "; INSTANCE:2]" ,"xxxxxx")
  controlsettext( $handle , "", "[CLASS:WindowsForms10.EDIT.app.0." & $classnumber[5] & "; INSTANCE:1]" ,"yyyyyyy")
  controlclick( $handle , "", "[CLASS:WindowsForms10.BUTTON.app.0." & $classnumber[5] & "; INSTANCE:2]" )

else
  msgbox( 0, "AutoIt", "TimeOut for 北京结算通信网关")
  exit
endif

if winwait( "北京结算通信网关 ( 小站号： ZZZZZZZZZ , 本地用户名： xxxxx ) ","") then
  $handle=wingethandle("北京结算通信网关 ( 小站号： ZZZZZZZZ , 本地用户名： xxxxx ) ")

  while 1
    while not winactive( $handle )
      winactivate( $handle )
;    msgbox(0, "", "等待窗口:" & $handle & "激活...", 1)
    wend
    WinSetState( $handle ,"", @SW_MAXIMIZE)

;   winmenuselectitem( $handle , "", "登录", "登录服务器")
    send("^+D")
    sleep(1000)
    if winexists( "[CLASS:#32770]" ) then
      local $nocertwarning = fine_spec_windows( "[CLASS:#32770]" , "[CLASS:Static; INSTANCE:1]" , "用户没有插入eKey")
      if $nocertwarning <> "" then
        winactivate ( $nocertwarning )
        sleep(500)
        send("{ENTER}")
        msgbox(0, "", "等待证书就绪...", 10)
        continueloop
      else
        exitloop
      endif
    endif
  wend
  if winwait("Windows 安全", "",10) then
    while not winactive("Windows 安全")
      winactivate("Windows 安全")
      sleep(1000)
    wend
    send("{ENTER}")
  else
    msgbox( 0 , "", "没有证书选择", 5)
  endif

  if winwait("北京结算通信网关" , "") then
    while not winactive("北京结算通信网关") 
      winactivate("北京结算通信网关")
      sleep(1000)
    wend
    local $Station_ID=controlgettext("北京结算通信网关","", "[CLASS:WindowsForms10.EDIT.app.0." & $classnumber[5] & "; INSTANCE:1]")
    if $Station_ID<>"" then
      controlsettext("北京结算通信网关", "", "[CLASS:WindowsForms10.EDIT.app.0." & $classnumber[5] & "; INSTANCE:2]" , $Station_ID)
      send("{ENTER}")
    endif
  endif

  if winwait("验证用户密码", "") then
    while not winactive("验证用户密码")    
      winactivate("验证用户密码")
      sleep(1000)
    wend
    controlsettext("验证用户密码", "" , "[CLASS:WindowsForms10.EDIT.app.0." & $classnumber[5] & "; INSTANCE:1]" , "zzzzzzzz")
    send("{ENTER}")
  endif
  msgbox( 0, "", "程序启动完成", 5)
else
  msgbox(0, "", "主程序窗口未创建")
endif

exit

func fine_spec_windows($spec_title, $spec_ID, $spec_string)
  $str_return=""
  $all_wins=winlist()
  for $i=1 to $all_wins[0][0]
    if $spec_title<>"" then
      if $all_wins[$i][0]=$spec_title or $all_wins[$i][0] = "" then
        local $get_text=controlgettext( $all_wins[$i][1] , "", $spec_ID)
        if stringinstr( $get_text, $spec_string)>0 then
          $str_return=$all_wins[$i][1]
          exitloop
        endif
      endif
    else
      local $get_text=controlgettext( $all_wins[$i][1] , "", $spec_ID)
      if stringinstr( $get_text, $spec_string)>0 then
        $str_return=$all_wins[$i][1]
        exitloop
      endif
    endif
  next
  return $str_return
endfunc
