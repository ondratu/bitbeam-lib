BIT = 8;    // Standard Bitbeam size
CLE = 9;    // Size for Clemmenti

unit = 8;
hole = 4.8;
rim_h = 1;
rim_d = 6;

rim = false;

$fn=25;

module holes(size, h=1, skip=[]){
    if (size > 0) {
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

module mix_arm(holes, h=1, side_holes=true, skip=[], skip_side=[]){
    difference(){
        hull(){
            translate([-unit/2, 0, 0])
                cube([0.01, unit, unit*h], center=true);
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
                cube_arm(left, h=h, side_holes=side_holes, skip_side=[0]);
            cube_arm(right, h=h, side_holes=side_holes, skip_side=[0]);
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

module cube_base(x, y, x2=0, h=1, fill_holes=true){
    x2 = (x2 == 0) ? x : x2;
    difference(){
        hull(){
            hull(){
                cube([unit, unit, unit*h], center=true);
                translate([(x-1)*unit, 0, 0])
                    cube([unit, unit, unit*h], center=true);
            }
            translate([0, (y-1)*unit, 0])
            hull(){
                cube([unit, unit, unit*h], center=true);
                translate([(x2-1)*unit, 0, 0])
                    cube([unit, unit, unit*h], center=true);
            }
        }

        holes(x, h);
        rotate([0, 0, 90])
            holes(y, h);
        translate([0, (y-1)*unit, 0])
            holes(x2, h);

        if (x == x2){
            translate([(x-1)*unit, 0, 0])
                rotate([0, 0, 90])
                    holes(y, h);

            if (fill_holes && y > 2){
                for (i = [1: y-2]) {
                    translate([unit, i*unit, 0])
                        holes(x-2, h);
                }
            }

        } else {
            if (fill_holes) {
                a = y - 1;
                b = x - x2;
                c = sqrt(b*b+a*a);
                alpha = asin(b/c);

                for (i = [1: y-2]) {
                    translate([unit, i*unit, 0])
                        holes(ceil(x-2-tan(alpha)*i), h);
                }
            }
        }
    }
}

module cylinder_base(x, y, x2=0, h=1, fill_holes=true){
    x2 = (x2 == 0) ? x : x2;
    difference(){
        hull(){
            hull(){
                cylinder(d=unit, h=h*unit, center=true);
                translate([(x-1)*unit, 0, 0])
                    cylinder(d=unit, h=h*unit, center=true);
            }
            translate([0, (y-1)*unit, 0])
            hull(){
                cylinder(d=unit, h=h*unit, center=true);
                translate([(x2-1)*unit, 0, 0])
                    cylinder(d=unit, h=h*unit, center=true);
            }
        }
 
        holes(x, h);
        rotate([0, 0, 90])
            holes(y, h);

        translate([0, (y-1)*unit, 0])
                holes(x2, h);

        if (x == x2){
            translate([(x-1)*unit, 0, 0])
                rotate([0, 0, 90])
                    holes(y, h);

            if (fill_holes) {
                for (i = [1: y-2]) {
                    translate([unit, i*unit, 0])
                        holes(x-2, h);
                }
            }

        } else {
            if (fill_holes) {
                a = y - 1;
                b = x - x2;
                c = sqrt(b*b+a*a);
                alpha = asin(b/c);

                for (i = [1: y-2]) {
                    translate([unit, i*unit, 0])
                        holes(ceil(x-2-tan(alpha)*i), h);
                }
            }
        }
    }
}

module cube_plate(x, y, x2=0, h=1, holes=[0, 1, 2, 3]){
    x2 = (x2 == 0) ? x : x2;
    difference(){
        hull(){
            hull(){
                cube([unit, unit, unit*h], center=true);
                translate([(x-1)*unit, 0, 0])
                    cube([unit, unit, unit*h], center=true);
            }
            translate([0, (y-1)*unit, 0])
            hull(){
                cube([unit, unit, unit*h], center=true);
                translate([(x2-1)*unit, 0, 0])
                    cube([unit, unit, unit*h], center=true);
            }
        }
        if (search(0, holes)){
            holes(x, h);
        }
        if (search(1, holes)){
            rotate([0, 0, 90])
                holes(y, h);
        }
        if (search(2, holes)){
            translate([0, (y-1)*unit, 0])
                holes(x2, h);
        }
        if (search(3, holes)){
            if (x != x2){
                a = y - 1;
                b = x - x2;
                c = sqrt(b*b+a*a);
                alpha = asin(b/c);
                translate([(x-1)*unit, 0, 0])
                    rotate([0, 0, 90+alpha])
                        holes(c, h);
            } else {
                translate([(x-1)*unit, 0, 0])
                    rotate([0, 0, 90])
                        holes(y, h);
            }
        }
    }
}

module cylinder_plate(x, y, x2=0, h=1, holes=[0, 1, 2, 3]){
    x2 = (x2 == 0) ? x : x2;
    difference(){
        hull(){
            hull(){
                cylinder(d=unit, h=h*unit, center=true);
                translate([(x-1)*unit, 0, 0])
                    cylinder(d=unit, h=h*unit, center=true);
            }
            translate([0, (y-1)*unit, 0])
            hull(){
                cylinder(d=unit, h=h*unit, center=true);
                translate([(x2-1)*unit, 0, 0])
                    cylinder(d=unit, h=h*unit, center=true);
            }
        }
        if (search(0, holes)){
            holes(x, h);
        }
        if (search(1, holes)){
            rotate([0, 0, 90])
                holes(y, h);
        }
        if (search(2, holes)){
            translate([0, (y-1)*unit, 0])
                holes(x2, h);
        }
        if (search(3, holes)){
            if (x != x2){
                a = y - 1;
                b = x - x2;
                c = sqrt(b*b+a*a);
                alpha = asin(b/c);
                translate([(x-1)*unit, 0, 0])
                    rotate([0, 0, 90+alpha])
                        holes(c, h);
            } else {
                translate([(x-1)*unit, 0, 0])
                    rotate([0, 0, 90])
                        holes(y, h);
            }
        }
    }
}

module cube_t(x, y, h=1){
    x2 = x/2;
    cx2 = ceil(x2);
    if (cx2 > x2) {
        cube_arm(x, h=h, skip_side=[cx2-1]);
    } else {
        cube_arm(x, h=h, skip_side=[cx2-1, cx2]);
    }

    translate([(x2-0.5)*unit, unit, 0])
    rotate([0, 0, 90])
        cube_arm(y-1, h=h);
}

module cylinder_t(x, y, h=1){
    x2 = x/2;
    cx2 = ceil(x2);
    if (cx2 > x2) {
        cylinder_arm(x, h=h, skip_side=[cx2-1]);
    } else {
        cylinder_arm(x, h=h, skip_side=[cx2-1, cx2]);
    }

    translate([(x2-0.5)*unit, unit-0.01, 0])
    rotate([0, 0, 90])
        mix_arm(y-1, h=h);
}

module cube_h(x, y, shift=1, h=1){
    cube_arm(x, h=h, skip_side=[shift, x-shift-1]);
    translate([0, unit*(y-1), 0])
        cube_arm(x, h=h, skip_side=[shift, x-shift-1]);

    translate([unit*shift, 0, 0])
        rotate([0, 0, 90])
        cube_arm(y);
    translate([unit*(x-shift-1), 0, 0])
        rotate([0, 0, 90])
        cube_arm(y);
}

module cylinder_h(x, y, shift=1, h=1){
    cylinder_arm(x, h=h, skip_side=[shift, x-shift-1]);
    translate([0, unit*(y-1), 0])
        cylinder_arm(x, h=h, skip_side=[shift, x-shift-1]);

    translate([unit*shift, 0, 0])
        rotate([0, 0, 90])
        cylinder_arm(y, skip_side=[0, x]);
    translate([unit*(x-shift-1), 0, 0])
        rotate([0, 0, 90])
        cylinder_arm(y, skip_side=[0, x]);
}

module cube_y(x, y, z, h=1){
    cube_arm(x, h=h, skip=[0], skip_side=[0]);
    rotate([0, 0, 90])
        cube_arm(y, h=h, skip=[0], skip_side=[0]);
    translate([-unit/2+unit*h/2, 0, unit/2-unit*h/2])
        rotate([0, -90, 0])
        cube_arm(z, h=h, skip=[0], skip_side=[0]);
}

module cylinder_y(x, y, z, h=1){
    mix_arm(x, h=h, skip=[0], skip_side=[0]);
    rotate([0, 0, 90])
        mix_arm(y, h=h, skip=[0], skip_side=[0]);
    translate([-unit/2+unit*h/2, 0, unit/2-unit*h/2])
        rotate([0, -90, 0])
        mix_arm(z, h=h, skip=[0], skip_side=[0]);
}

module cube_x(x, y, h=1){
    x2 = x/2;
    cx2 = ceil(x2);
    if (cx2 > x2) {
        cube_arm(x, h=h, skip_side=[cx2-1]);
    } else {
        cube_arm(x, h=h, skip=[cx2-1, cx2], skip_side=[cx2-1, cx2]);
    }

    y2 = y/2;
    cy2 = ceil(y2);

    translate([(x2-0.5)*unit, -(y2-0.5)*unit, 0])
        rotate([0, 0, 90])
        if (cy2 > y2) {
            cube_arm(y, h=h, skip_side=[cy2-1]);
        } else {
            cube_arm(y, h=h, skip=[cy2-1, cy2], skip_side=[cy2-1, cy2]);
        }
}

module cylinder_x(x, y, h=1){
    x2 = x/2;
    cx2 = ceil(x2);
    if (cx2 > x2) {
        cylinder_arm(x, h=h, skip_side=[cx2-1]);
    } else {
        cylinder_arm(x, h=h, skip=[cx2-1, cx2], skip_side=[cx2-1, cx2]);
    }

    y2 = y/2;
    cy2 = ceil(y2);

    translate([(x2-0.5)*unit, -(y2-0.5)*unit, 0])
        rotate([0, 0, 90])
        if (cy2 > y2) {
            cylinder_arm(y, h=h, skip_side=[cy2-1]);
        } else {
            cylinder_arm(y, h=h, skip=[cy2-1, cy2], skip_side=[cy2-1, cy2]);
        }
}

