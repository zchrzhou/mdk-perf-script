@REM Welcome to this bat script
@REM Test under "Git for Windows", Strawberry and ActiveState Perl under win8.1
@REM Recommend to use "Git for Windows".
@REM Strawberry and ActiveState maybe cause unstable under cmd.exe, please close cmd.exe windows and reopen cmd.exe

@REM Download "Git for Windows" with perl 5.8 from https://git-for-windows.github.io/
@REM Download Strawberry or Active Statue from  http://www.perl.org/get.html

@echo off

set PATH="tools\znix;%PATH%"
set PERL="C:\Strawberry\perl\bin\perl.exe"

%PERL% main.pl %1 %2 %3 %4 %5 %6 %7 %8 %9

set PATH=
set PERL=

@echo on
