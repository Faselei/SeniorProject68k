@echo OFF

::make a temporary path update to include our development tools
set MakeTestRoot=C:\GenesisRoot
path=%path%;%MakeTestRoot%\bin

make
pause