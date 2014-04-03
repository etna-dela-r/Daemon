@echo off
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
	"%ProgramFiles(x86)%\Shunt\npm.cmd" install
) else (
	"%ProgramFiles%\Shunt\npm.cmd" install
	)
