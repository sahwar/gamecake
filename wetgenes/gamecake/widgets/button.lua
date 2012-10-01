-- copy all globals into locals
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require


module("wetgenes.gamecake.widgets.button")

function bake(state,wbutton)
wbutton=wbutton or {}


function wbutton.mouse(widget,act,x,y,key)
--	widget.master.focus=widget
	return widget.meta.mouse(widget,act,x,y,key)
end


function wbutton.key(widget,ascii,key,act)
	return widget.meta.key(widget,ascii,key,act)
end


function wbutton.update(widget)

	if widget.data then
		widget.text=widget.data:get_string()
	end

	return widget.meta.update(widget)
end

function wbutton.draw(widget)
	return widget.meta.draw(widget)
end


function wbutton.setup(widget,def)
--	local it={}
--	widget.button=it
	widget.class="button"
	
	widget.key=key
	widget.mouse=mouse
	widget.update=update
	widget.draw=draw

	return widget
end

return wbutton
end
