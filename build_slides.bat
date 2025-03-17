@echo off
if exist presentation.pdf del presentation.pdf
set TEXINPUTS=.;memory-bank
pdflatex -interaction=nonstopmode presentation.tex
if %errorlevel% equ 0 (
   echo PDF generated successfully
   start presentation.pdf
) else (
   echo Compilation failed - check presentation.log
   type presentation.log
)
