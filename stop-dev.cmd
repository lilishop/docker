@echo off
setlocal
node "%~dp0scripts\dev-env.mjs" stop %*
