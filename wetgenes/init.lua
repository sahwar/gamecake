-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

--[[#wetgenes

	local wetgenes=require("wetgenes")

Simple generic functions that are intended to be useful for all 
wetgenes.* modules.

]]
local M={ modname=(...) } ; package.loaded[M.modname]=M

-----------------------------------------------------------------------------
--[[#wetgenes.export

	... = wetgenes.export(table,...)

Export multiple names from this table as multiple returns, can be 
used to pull functions out of this module and into locals like so

	local export,lookup,set_env=require("wetgenes"):export("export","lookup","set_env")

Or copy it into other modules to provide them with the same functionality.

	M.lookup=require("wetgenes").lookup

]]
-----------------------------------------------------------------------------

function M.export(env,...)
	local tab={}
	for i,v in ipairs{...} do
		tab[i]=env[v]
	end
	return unpack(tab)
end

-----------------------------------------------------------------------------
--[[#wetgenes.lookup

	value = wetgenes.lookup(table,...)

Safe recursive lookup within a table that returns nil if any part of 
the lookup is nil so we never cause an error but just return nil. 
This is intended to replace the following sort of code

	a = b and b.c and b.c.d and b.c.d.e

To get e only if all of its parent bits exist and not to cause any 
error if they do not. instead use

	a = lookup(b,"c","d","e")

]]
-----------------------------------------------------------------------------
function M.lookup(tab,...)
	for i,v in ipairs{...} do
		if type(tab)~="table" then return nil end
		tab=tab[v]
	end
	return tab
end


-----------------------------------------------------------------------------
--[[#wetgenes.set_env

	local _ENV=set_env(new_environment)

Since setfenv is going away in lua 5.2 here is a plan to future 
proof code that wants to control its own environment

Specifically this is for loading functions sabdboxed into a given 
table, which we need to do from time to time.

we set the environment of the code that called us only if setfenv 
exists and we always return the new environment

So the following incantation can be used to change the current environment and 
it should work exactly the same in lua 5.1 or 5.2

	local _ENV=set_env(new_environment)

]]
-----------------------------------------------------------------------------
function M.set_env(env)
	if setfenv then setfenv(2,env) end
	return env
end
