--+-----------------------------------------------------------------------------------------------------------------+--
--
-- (C) Kriss Daniels 2005 http://www.XIXs.com
--
-- This file made available under the terms of The MIT License : http://www.opensource.org/licenses/mit-license.php
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--
--+-----------------------------------------------------------------------------------------------------------------+--

-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

--
-- A thrown together build toool, well some useful lua functions for making a build.
--
-- The intent is to optimise a fullbuild rather than a partial build,
--
-- it is the times you have to rebuild everything that causes you to go make a cup of tea, after all.
--
-- This is exceptionally true of windows where process creation has a huge overhead
--
-- Hopefully things are kept shrinkwrapped enough here to enable an easy unixy port when I need it (theywoz)
--

local lfs=require("lfs")
local wstr=require("wetgenes.string")

module("wetgenes.bake")

osflavour="win"
	
local os_shell=os.getenv("SHELL")
if os_shell and string.sub(os_shell,1,5)== "/bin/" then
	osflavour="nix"
end

-- fullpaths to usefull commands

cmd={}


-- place to store options

opt={}




--
-- get/set current dir
--
get_cd=function()

	return string.gsub(lfs.currentdir(),'\\','/')

end
set_cd=function(str)

	lfs.chdir(str)

end


--
-- combine strings and resolve . or .. and cancel out multiple // and switch \ to /
-- so we should end up with a valid clean path
--
path_clean=function(...)

local str

	str=table.concat({...})
	str=string.gsub(str,'\\','/')

	return(str)

end

--
-- as path_clean but add .exe (so we can easily not do this later if under unix)
--
path_clean_exe=function(...)

if osflavour=="nix" then
	return(path_clean(...))
else
	return(path_clean(...)..'.exe')
end

end


--
-- return the substring after the last .
--
path_ext=function(str)

	return(str)

end

--
-- perform some substitutions and then execute the command from the given cwd
--
execute=function(cwd,cmd,arg)

	if cwd then
	
		lfs.chdir(cwd)
	
	end
	
	if arg then
	
		os.execute(cmd..' '..arg)
		
	else
	
		os.execute(cmd)

	end

end



--
-- given a filename make sure that its containing directory exists
--
create_dir_for_file=function(n)
	local t={}
	for w in string.gmatch(n, "[^/]+") do t[#t+1]=w end
	local s=""
	t[#t]=nil -- remove the filename
	for i,v in ipairs(t) do
		s=s..v
		lfs.mkdir(s)
		s=s.."/"
	end
end

--
-- get the filenames (relative to the basedir) of all files matching the filter
--
findfiles=function(opts)
if not opts then return end
if not opts.dir then return end
opts.basedir=opts.basedir or "." -- "." for current
opts.filter=opts.filter or "." -- include all files by default
opts.ret=opts.ret or {} -- return value is in opts.ret

	local subdirs={}
	local d=opts.basedir.."/"..opts.dir
	if lfs.attributes(d) then -- only if dir exists
		for v in lfs.dir(d) do
			local a=lfs.attributes(d.."/"..v)
	--print("test",v,a.mode)
			if a.mode=="file" then
				if string.find(v,opts.filter) then
	--print("found",v)
					opts.ret[#opts.ret+1]=opts.dir.."/"..v
				end
			end
			if a.mode=="directory" then
				if v:sub(1,1)~="." then
					subdirs[#subdirs+1]=v
				end
			end
		end
	end
	
-- recurse
	local dir=opts.dir
	for i,v in ipairs(subdirs) do
		opts.dir=dir.."/"..v
		findfiles(opts)
	end

	return opts
end



readfile=function(name)
	local fp=assert(io.open(name,"r"))
	local d=fp:read("*all")
	fp:close()
	return d
end

file_exists=function(name)
	local fp=(io.open(name,"r"))
--print(fp)
	if fp then fp:close() return true end
	return false
end

writefile=function(name,data)
	local fp=assert(io.open(name,"w"))
	fp:write(data)
	fp:close()
end

copyfile=function(frm,too)
	local text=readfile(frm)
	writefile(too,text)
end

-- copy but with macro replacements
replacefile=function(frm,too,opts)
	local text=readfile(frm)
	text=wstr.replace(text,opts)
	writefile(too,text)
end

-----------------------------------------------------------------------------
--
-- convert time stamp into a 2.3 version string like so vv.mmm
--
-- this gives us space for about 3 unique releases a day based on time
-- lets try not to releasemore than that, mkay :)
--
-----------------------------------------------------------------------------
function version_from_time(t,vplus)

	vplus=vplus or 0 -- slight tweak if we need it

	t=t or os.time()

	local d=os.date("*t",t)

-- how far through the year are we
	local total=os.time{year=d.year+1,day=1,month=1} - os.time{year=d.year,day=1,month=1}
	local part=t - os.time{year=d.year,day=1,month=1}

-- build major and minor version numbers
	local maj=math.floor(d.year-2000)
	local min=math.floor((part/total)*1000)+vplus

	if min>=1000 then min=min-1000 maj=maj+1 end -- paranoia fix

	return string.format("%02d.%03d",maj,min)
end

