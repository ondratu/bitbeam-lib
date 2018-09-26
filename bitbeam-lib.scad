BIT = 8;    // Standard Bitbeam size
CLE = 9;    // Size for Clemmenti

unit = 8;
hole = 4.8;
rim_h = 1;
rim_d = 6;

rim = false;

$fn=25;

module holes(size, h=1, skip=[]){
    for(i = [0:size-1]){
        if (!search(i, skip)){
            translate([i*unit, 0, 0])
                cylinder(d=hole, h=unit*h+0.1, center=true);
            }
    }
    if (rim && h > 0.26){
        for(i = [0:size-1]){
             if (!search(i, skip)){
                translate([i*unit, 0, h*unit/2-rim_h/2])
                    cylinder(d=rim_d, h=rim_h+0.1, center=true);
                translate([i*unit, 0, -h*unit/2+rim_h/2])
                    cylinder(d=rim_d, h=rim_h+0.1, center=true);

            }
        }
    }
}

module cube_arm(size, h=1, side_holes=true, skip=[], skip_side=[]){
    difference(){
        hull(){
            cube([unit, unit, unit*h], center=true);
            translate([(size-1)*unit, 0, 0])
                cube([unit, unit, unit*h], center=true);
        }

        holes(size, h, skip);
        if (side_holes && h >= 1){
            rotate([90, 0, 0])
                holes(size, 1, skip_side);
        }
    }
}

module cylinder_arm(holes, h=1, side_holes=true, skip=[], skip_side=[]){
    difference(){
        hull(){
            cylinder(d=unit, h=unit*h, center=true);
            translate([(holes-1)*unit, 0, 0])
                cylinder(d=unit, h=unit*h, center=true);
        }

        holes(holes, h, skip);
        if (side_holes && h >= 1){
            rotate([90, 0, 0])
                holes(holes, 1, skip_side);
        }
    }
}

module cylinder_angle(left, right, angle=45, h=1, side_holes=true){
    rotate([0, 0, 180-angle])
        cylinder_arm(left, h=h, side_holes=side_holes, skip_side=[0]);
    cylinder_arm(right, h=h, side_holes=side_holes, skip_side=[0]);

}

module cube_angle(left, right, angle=45, h=1, side_holes=true){
    difference(){
        union(){
            rotate([0, 0, 180-angle])
                cube_arm(left, 1, h=h, side_holes=side_holes, skip_side=[0]);
            cube_arm(right, 1, h=h, side_holes=side_holes, skip_side=[0]);
        }

        if (angle > 90 || angle < -90){
            translate([-unit, 0, 0])
                cube([unit, unit, unit*h+0.1], center=true);
        }

        translate([0,  (angle > 0) ? -unit : unit, 0])
            cube([unit, unit, unit*h+0.1], center=true);

        rotate([0, 0, 180-angle])
            translate([-0, (angle > 0) ? unit : -unit, 0])
                cube([unit, unit, unit*h+0.1], center=true);

        if (rim){
            translate([unit, 0, 0])
                holes(1, h);
            rotate([0, 0, angle])
                translate([unit, 0, 0])
                    holes(1, h);
        }
    }
}


module cube_frame(x, y, h=1, side_holes=true){
    cube_arm(x, h=h, side_holes=side_holes, skip_side=[0, x-1]);
    rotate([0, 0, 90])
        cube_arm(y, h=h, side_holes=side_holes, skip_side=[0, y-1]);
    translate([(x-1)*unit, 0, 0])
        rotate([0, 0, 90])
            cube_arm(y, h=h, side_holes=side_holes, skip_side=[0, y-1]);
    translate([0, (y-1)*unit, 0])
        cube_arm(x, h=h, side_holes=side_holes, skip_side=[0, x-1]);
}

module cylinder_frame(x, y, h=1, side_holes=true){
    cylinder_arm(x, h=h, side_holes=side_holes, skip_side=[0, x-1]);
    rotate([0, 0, 90])
        cylinder_arm(y, h=h, side_holes=side_holes, skip_side=[0, y-1]);
    translate([(x-1)*unit, 0, 0])
        rotate([0, 0, 90])
            cylinder_arm(y, h=h, side_holes=side_holes, skip_side=[0, y-1]);
    translate([0, (y-1)*unit, 0])
        cylinder_arm(x, h=h, side_holes=side_holes, skip_side=[0, x-1]);
}

module cube_base(x, y, h=1, quad=true, fill_holes=true){
    difference(){
        hull(){
            cube([unit, unit, unit*h], center=true);
            translate([(x-1)*unit, 0, 0])
                cube([unit, unit, unit*h], center=true);
            translate([0, (y-1)*unit, 0])
                cube([unit, unit, unit*h], center=true);

            if (quad){
                translate([(x-1)*unit, (y-1)*unit, 0])
                    cube([unit, unit, unit*h], center=true);

            }
        }

        holes(x, h);
        rotate([0, 0, 90])
            holes(y, h);
        if (quad || fill_holes){
            translate([0, (y-1)*unit, 0])
                holes(x, h);

            translate([(x-1)*unit, 0, 0])
                rotate([0, 0, 90])
                    holes(y, h);

        }

        if (fill_holes) {
            for (i = [1: y-2]) {
                translate([unit, i*unit, 0])
                    holes(x-2, h);
            }
        }
    }
}

module cylinder_base(x, y, h=1, quad=true, fill_holes=true){
    difference(){
        hull(){
            cylinder(d=unit, h=unit*h, center=true);
            translate([(x-1)*unit, 0, 0])
                cylinder(d=unit, h=unit*h, center=true);
            translate([0, (y-1)*unit, 0])
                cylinder(d=unit, h=unit*h, center=true);

            if (quad){
                translate([(x-1)*unit, (y-1)*unit, 0])
                    cylinder(d=unit, h=unit*h, center=true);

            }
        }

        holes(x, h);
        rotate([0, 0, 90])
            holes(y, h);
        if (quad || fill_holes){
            translate([0, (y-1)*unit, 0])
                holes(x, h);

            translate([(x-1)*unit, 0, 0])
                rotate([0, 0, 90])
                    holes(y, h);

        }

        if (fill_holes) {
            for (i = [1: y-2]) {
                translate([unit, i*unit, 0])
                    holes(x-2, h);
            }
        }
    }
}
