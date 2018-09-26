SRC = $(wildcard *.scad)
IMGS = $(SRC:%.scad=%.png)

all: $(IMGS)

%.png: %.scad
	openscad -o $@ --imgsize=500,200 --projection=o --camera=0,0,10,70,0,-45,120 $<
