SRC = $(wildcard *.scad)
IMGS = $(SRC:%.scad=%.png)

all: $(IMGS)

# depend on imagemagick and optipng
%.png: %.scad
	openscad -o $@ -q --imgsize=1000,400 --projection=o --camera=0,0,10,70,0,-45,120 $<
	convert $@ -scale 50% $@
	optipng -o7 -silent $@
