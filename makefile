SOURCE = main.lua entity.lua engine.lua conf.lua scenes/scene1.lua scenes/scene2.lua scenes/scene3.lua systems/construction.lua systems/display.lua systems/init.lua systems/physics.lua systems/player.lua utils/color.lua utils/integrators.lua utils/interpolaters.lua utils/matrix.lua utils/transform.lua

../build:
	mkdir ../build

../build/love-construction.love: ../build $(SOURCE)
	zip -9 -q -r ../build/love-construction.love .

../build/windows: ../build/love-construction.love
	cp -r ../love/love-0.8.0-win-x86/ ../build/
	mv ../build/love-0.8.0-win-x86/ ../build/windows/
	cat ../build/windows/love.exe ../build/love-construction.love > ../build/windows/love-construction.exe
	rm ../build/windows/love.exe

all: ../build/windows

clean:
	rm -r ../build/
