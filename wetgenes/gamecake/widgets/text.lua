-- copy all globals into locals
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require


module("wetgenes.gamecake.widgets.text")

function bake(oven,wtext)
wtext=wtext or {}

function wtext.mouse(widget,act,x,y,key)
--	widget.master.focus=widget
	return widget.meta.mouse(widget,act,x,y,key)
end


function wtext.key(widget,ascii,key,act)
	return widget.meta.key(widget,ascii,key,act)
end


function wtext.update(widget)

	if widget.data then
		widget.text=widget.data:get_string()
	end

	return widget.meta.update(widget)
end

function wtext.draw(widget)
	return widget.meta.draw(widget)
end


function wtext.setup(widget,def)
--	local it={}
--	widget.button=it
	widget.class="text"
	
	widget.key=wtext.key
	widget.mouse=wtext.mouse
	widget.update=wtext.update
	widget.draw=wtext.draw

	return widget
end

return wtext
end
