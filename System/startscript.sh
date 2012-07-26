#!/bin/bash
while :
do
  ./ucc-bin server CTF-Face?game=Botpack.CTFGame ini=ut.ini log=ut.log -nohomedir
  cp ./ut.log ./crash.log 
done
