
project "lua_fenestra"
language "C++"
files { "code/**.cpp" , "code/**.c" , "code/**.h" , "all.h" }

includedirs { "../lua_freetype/freetype/include/" }
includedirs { "../lib_sx/src/" }

links { "lib_lua" }

defines { "LUA_LIB" }

if os.get() == "windows" then
	links { "opengl32" , "glu32" }
else -- nix
	links { "GL" , "GLU"  }
--[[
	local fp=assert(io.popen("pkg-config --cflags libsx"))
	local s=assert(fp:read("*l"))
	buildoptions { s }
	fp:close()

	local fp=assert(io.popen("pkg-config --libs libsx"))
	local s=assert(fp:read("*l"))
	linkoptions { s }
	fp:close()
]]

end


includedirs { "." }

SET_KIND("lua","fenestra.core","fenestra_core")
SET_TARGET("/fenestra","core")

