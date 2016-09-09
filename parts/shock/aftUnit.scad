include <dim.scad>
use <vents.scad>
use <../shapes.scad>
use <buttress.scad>

EPS = 0.1;
EPS2 = EPS * 2;
$fn = 90;

H_AFT_RING = 31;
H_AFT = 56;         // inclusive of speaker mount
D_AFT_RING = 33.5;

H_SPEAKER = 3.6 + 0.2;
X_SPEAKER = 20;
Y_SPEAKER = 14.2;
Y_SPEAKER_INNER = 8.4;

H_BACK = H_AFT - H_SPEAKER - H_BUTTRESS;

SPACE = DISPLAY_MOUNT_L;
DISPLAY_Y = 9.5;

R_THREAD = 1.2;         // M2.5 bolt
R_THREAD_HEAD = 2.4;

R_DISPLAY_THREAD = 0.8; // M2 bolt
DEPTH_DISPLAY_THREAD = 4;

module displayBolt() 
{
    // Pins are challenging to print small & accurate.
    // Trying holes for M2 bolts instead.
    translate([0, -DEPTH_DISPLAY_THREAD, 0]) {
        rotate([-90, 0, 0]) cylinder(r=R_DISPLAY_THREAD, h=20);
    }
}

module display()
{
    DW = (DISPLAY_W - DISPLAY_MOUNT_W)/2;
    DL = (DISPLAY_L - DISPLAY_MOUNT_L)/2;

    cube(size=[DISPLAY_W, 10, DISPLAY_L+0.5]);
    
    translate([DW, 0, DL])                          displayBolt();
    translate([DISPLAY_W - DW, 0, DL])              displayBolt();
    translate([DISPLAY_W - DW, 0, DISPLAY_L - DL])  displayBolt();
    translate([DW, 0, DISPLAY_L - DL])              displayBolt();
    
    translate([0, -1, 6]) {
        cube(size=[DISPLAY_W, 1, DISPLAY_L - 12]);
    }
}

module aft()
{
    // rear lock
    color("red") {
        translate([0, 0, H_AFT_RING]) {
            tube(7, D_BATTERY/2, D_AFT_RING/2);
        }
    }

    translate([0, 0, SPACE + H_BUTTRESS]) {
        difference() {
            tube(H_BACK, D_BATTERY/2, D_AFT/2);  

            H = H_BACK - H_BUTTRESS - 11;
            translate([0, 0, 11]) {
                vent1(7, H, 8, 20);
            }
        }
    }
}

module speaker()
{
    difference() {
        translate([0, 0, SPACE + H_BUTTRESS + H_BACK]) {
            cylinder(h=H_BUTTRESS + H_SPEAKER, d=D_AFT);
        }
        translate([-X_SPEAKER/2, -Y_SPEAKER/2, SPACE + H_BUTTRESS*2 + H_BACK]) {
            cube(size=[X_SPEAKER, Y_SPEAKER, 20]);
        }
        translate([-20, -Y_SPEAKER_INNER/2, SPACE + H_BUTTRESS*2 + H_BACK]) {
            cube(size=[40, Y_SPEAKER_INNER, 20]);
        }
    }
}

module stage1rods()
{
    intersection()
    {
        LEN = SPACE + H_BUTTRESS / 2;
        cylinder(h=100, d=D_INNER);
        union() {
            translate([-20, -D_INNER/2, 0]) {
                cube(size=[40, 4, LEN]);
            }
            translate([-17, -4, 0]) cube(size=[4, 3, LEN]);
            translate([13, -4, 0]) cube(size=[4, 3, LEN]);
        }
    }
}

module stage2threads()
{
    H = 10;
    translate([0, 0, SPACE]) {
        for(bias=[-1,2,1]) {
            translate([9*bias, -7, 0]) {
                cylinder(h=H, r=R_THREAD);
            }
        }
    }
}

module stage3threads()
{
    H = 5;
    D = 4;
    Y = 11;
    BACK = SPACE + H_BUTTRESS*2 + H_BACK + H_SPEAKER - H - D;
    translate([0, 0, BACK]) {
        for(bias=[-1,2,1]) {
            translate([ 0, Y*bias, 0]) {
                cylinder(h=10, r=R_THREAD);
                translate([0, 0, H]) {
                    cylinder(h=10, r=R_THREAD_HEAD);
                }
            }
        }
    }
}

module wireHoles()
{   
    translate([0, 0, H_BUTTRESS]) {
        for(bias=[-1,2,1]) {
            translate([11.2*bias, 0, 0]) cylinder(h=100, r=1.2);
        }
    }               
}

// Excludes speaker. Drawn separately.
module aftPart() {
    difference() {
        union() {
            buttress(pcb=7, showBolt=false);
            translate([0, 0, SPACE]) {
                buttress(rods=false, battery=true);
            }
            aft();
        }   
        // Space for display.
        CUT = 7;
        translate([-CUT, DISPLAY_Y-2, SPACE]) {
            cube(size=[CUT*2, 10, 9]);
        }
        translate([-DISPLAY_W/2, DISPLAY_Y, -H_BUTTRESS/2]) {
            display();
        }
        wireHoles();
    }
}

// STAGE 1
union() {
    intersection() {
        translate([-20, -20, 0]) cube(size=[40, 40, SPACE-0.01]);
        union() {
            aftPart();
        }
    }
    stage1rods();
}

// STAGE 2
union() {
    intersection() {
        translate([-20, -20, SPACE]) cube(size=[40, 40, H_AFT_RING - SPACE-0.01]);
        difference() {
            aftPart();
            stage1rods();
            stage2threads();
        }
    }
}

// STAGE 3
union() {
    difference() {
        intersection() {
            translate([-20, -20, H_AFT_RING]) cube(size=[40, 40, 100]);
            aftPart();
        }
        stage2threads();
        stage3threads();
    }
}

// STAGE 4 
union()
{
    difference() {
        color("yellow") {
            speaker();
        }
        stage3threads();
        wireHoles();
    }
}