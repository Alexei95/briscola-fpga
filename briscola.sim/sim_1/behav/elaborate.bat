@echo off
set xv_path=C:\\Xilinx\\Vivado\\2016.1\\bin
call %xv_path%/xelab  -wto 06a01173f4f44d7392ac25a7bf8c3e16 -m64 --debug all --relax --mt 8 -L briscola -L xpm -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip --snapshot test_signals_behav briscola.test_signals briscola.glbl -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
