include <../bitbeam-lib.scad>

translate([unit*4, 0, 0])
    cylinder_base(4, 6);

translate([unit*-2, 0, 0])
    cube_base(4, 6, quad=false, fill_holes=false);
