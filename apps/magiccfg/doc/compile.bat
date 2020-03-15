SET SRCNAME=MagiCCfg
SET DSTNAME=MagiCCfg
SET LOCALDRIVE=H:
SET LOCALDIR=\Sourcen\MagiC-Configurator\DOC
SET GUIDESPATH=C:\Gemsys\Guides\
SET UDOPATH=D:\UDO\BIN\

echo šbersetze %LOCALDRIVE%%LOCALDIR%\%SRCNAME%.u
echo nach   %LOCALDRIVE%%LOCALDIR%\%DSTNAME%.txt
echo und    %LOCALDRIVE%%LOCALDIR%\%DSTNAME%.hyp

%LOCALDRIVE%
del *.uha < bin\G.TXT
bin\udo.ttp -a -l -o %DSTNAME%.txt %LOCALDIR%\%SRCNAME%.u
bin\udo.ttp -s -l -y -o %DSTNAME%.stg %LOCALDIR%\%SRCNAME%.u
bin\hcp.ttp +a +z %DSTNAME%.STG
exit

copy %GUIDESPATH%\%DSTNAME%.HYP .
