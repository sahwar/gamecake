

local core=require("wetgenes.aelua.img.core")

module("wetgenes.aelua.img")


function get(...)

	return core.get(...)

end

function resize(...)

	return core.resize(...)

end

function composite(...)

	return core.composite(...)

end
