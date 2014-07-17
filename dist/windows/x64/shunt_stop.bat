@echo off

set PIDFILE=shunt.pid

set /p PID=<%PIDFILE%

taskkill /pid %PID%
type nul > %PIDFILE%
