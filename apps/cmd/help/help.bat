:: MCMD HELP SYSTEM
SET HLP_PATH=C:\LANG\DE\GEMSYS\GEMDESK\HELP\
SET HELPFILE=%HLP_PATH%%1.hlp
IF NOT %HELPFILE% == %HLP_PATH%.hlp GOTO _help

:: THESE ARE THE HELP TOPICS
echo Welcome to (M)CMD help system
echo  Usage: help TOPIC
echo ""
echo Internal commands:
echo attrib,break,cd,cls,ck,copy,date,del,dir,echo,end,exit
echo find,for,free,goto,if,md,more,mv,path,pause,prompt
echo rd,ren,shift,set,sort,time,touch,tree,type,ver,verify
echo ""
echo External commands:
echo (currently none)
echo ""
echo Other topics:
echo acc,batch,cmdline,devices,edit,extcmd,redirect
echo ""
echo Current help text path is %HLP_PATH%.
end

:_help
echo ""
more <%HELPFILE%
echo ""
end
