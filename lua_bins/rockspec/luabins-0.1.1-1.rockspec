package = "luabins"
version = "0.1.1-1"
source = {
   url = "http://cloud.github.com/downloads/agladysh/luabins/luabins-0.1.1.tar.gz"
}
description = {
   summary = "Trivial Lua Binary Serialization Library",
   detailed = [[
      Luabins allows to save tuples of primitive Lua types into binary chunks and to load saved data back.
   ]],
   homepage = "http://github.com/agladysh/luabins",
   license = "MIT/X11"
}
dependencies = {
   "lua >= 5.1"
}
build = {
   type = "make"
}
