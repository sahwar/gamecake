

project "lua_zlib"
language "C"
files { "src/lua_zlib.c" }

links { "lib_lua" , "lib_z" }

if os.get() == "windows" then

else -- nix

end


includedirs { "." , "../lib_z" }


SET_KIND("lua","zlib","zlib")
SET_TARGET("","zlib")

