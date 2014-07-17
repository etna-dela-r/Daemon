@echo off

set PIDFILE=shunt.pid
START /MIN node .

set task=tasklist /FI "USERNAME eq %USERNAME%" /FI "IMAGENAME eq node.exe" /NH

for /F "tokens=1-6 delims= " %%i IN ('%task%') do (
	echo %%j > %PIDFILE%
)
