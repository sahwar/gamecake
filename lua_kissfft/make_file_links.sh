echo "linking .lua fles from the main lua dir so we dont accidently edit multiple copies"

#you will need to delete the local copies first...
rm code/*.lua

ln ../../bin/lua/kissfft.lua code
