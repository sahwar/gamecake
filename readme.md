
| Provider | Type | Result |
| --- | --- | --- |
| CircleCI | test | [![CircleCI](https://circleci.com/gh/xriss/gamecake.svg?style=svg)](https://circleci.com/gh/xriss/gamecake) |

BTW CircleCI seems to be having issues so check the build logs before 
you believe its opinion on a broken build.

Be sure to clone repo with submodules as the engine binaries live in a 
permanently orphaned branch. The following is the optimal way to git 
clone so that the submodule references master rather than downloading 
the repo twice.

	git clone https://github.com/xriss/gamecake.git
	cd gamecake
	./git-pull

The submodules also need care when pulling updates, use this script to 
get the latest everything.

	./git-pull


Autogenerated lua code documentation can be found at 
https://xriss.github.io/gamecake/ but not everything is fully 
documented yet.

Releases are cross compiled inside the vbox_* directories 
(linux32/linux64/osx64/raspi/etc) which contain vagrant or qemu boxes 
setup to build the code in a controlled environment via a ./make 
script. The latest code built this way can be found in the exe branch 
and a zip of them all can be downloaded from 
https://github.com/xriss/gamecake/archive/exe.zip

For a linuxy build, the required build/lib dependencies are premake, 
luajit and SDL2. Install these via a package manager the following 
script will try and install everything needed for a build.

	./apt-gets

If packages are out of date (SDL2 probably) you may build and install 
included versions that have been tested to work using this script.

	build/depends/install

Then you may use the following scripts to make and install.

	./make
	sudo ./install

Once built the engine lives in one single fat binary that includes many 
lua libraries. For convenience gamecake is a command line compatible 
replacement for lua. The only diference is we have C libraries and Lua 
libraries from this repository embedded and ready to be required by 
your lua code.


We are now setup to auto build snaps via 
https://code.launchpad.net/~xriss/+snap/gamecake the following should 
get you a snap install of gamecake.

	sudo snap install gamecake

Because of the way snaps work you may need to enable some interfaces, 
best you take a look at all the snap documentation for that sort of 
thing. Run the following to check everything is connected OK if you are 
having problems, the joystick insterface does not currently connect by 
default so needs to be connected manually.

	sudo snap interfaces gamecake

Gamecake is now slowly becoming fully available as a luarock, all our 
custom libraries can be installed at once with.

	sudo luarocks install gamecake
	
This is also the replacement for pagecake, use openresty combined with 
a luarocks gamecake install. This way your nginx will no longer be so 
out of date.

