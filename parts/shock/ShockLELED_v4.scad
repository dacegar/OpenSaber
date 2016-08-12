include <dim.scad>
use <../shapes.scad>
use <vents.scad>

// LED holder for Shock LE
// Designed for Dynamic (LED Supply) heatsink

FACES = 180;
EPSILON = 0.1;

// Inches. I hate imperial.
D_RING      = 1.312 * INCHES_TO_MM;   // correct, outer ring holds it in place.
D_LED       = 20.000;                 // hole where the light shines.
D_HEATSINK  = 1.000 * INCHES_TO_MM;

H_RING      = 0.280 * INCHES_TO_MM;    // measured at 279
H_HEATSINK  = 0.5 + 0.890 * INCHES_TO_MM;
H_OUTER     = 0.700 * INCHES_TO_MM;    // correct. height below ring.

H_CONNECTOR = 13.4;
H_CAP       = 3;
D_INNER_CAP = 0.5 + 0.800 * INCHES_TO_MM;                       // end cap holds the emitter in place

H_TEETH = 2;

// Top part (emitter)
*difference() {
    union() {
        // Top cap
        translate([0, 0, H_OUTER]) {
            difference() {
                cylinder(h=H_RING, r=D_RING/2, $fn=FACES);
                cylinder(h=H_RING, r=D_LED/2, $fn=FACES);
            }
        };
    
        // LED
        cylinder(h=H_OUTER, r=D_INNER/2, $fn=FACES);
    }
    cylinder(h=H_HEATSINK, r=D_HEATSINK/2, $fn=FACES);

    // Vents / decoration / volume reduction
    for(r=[0:5]) {
        translate([0, 0, 16]) {
            rotate([180, 0, r*60]) {
                vent1(11, 4, 12, 20);
            }
        }
    }

    for(r=[0:(N_TEETH-1)]) {
        rotate([0, 0, r*TEETH_ANGLE]) {
            lock(H_TEETH);
        }   
    }

}

// Bottom part (connects to mainRing)
color("gray") {
    for(r=[0:(N_TEETH-1)]) {
        rotate([0, 0, r*TEETH_ANGLE]) {
            intersection() {
                tube(H_TEETH, D_HEATSINK/2, D_INNER/2);
                lock(H_TEETH);
            }
        }
    }
    
    intersection()
    {
        translate([0, 0, -H_CONNECTOR]) {
            cylinder(h=H_CONNECTOR, r=D_INNER/2, $fn=FACES);
        }
        union() {
            // End cap.
            translate([0, 0, -H_CAP]) {
                tube(H_CAP, D_INNER_CAP/2, D_INNER/2);
            }

            // Pin holder & alignment
            // Note that the end cap consumes the bottom of this part.
            difference() {
                // Emitter port.
                translate([0, 0, -H_CONNECTOR]) {
                    difference() {
                        emitterHolder(H_CONNECTOR);
                        emitterPin(H_CONNECTOR, true);
                    }
                }
                translate([-X_EMITTER * PIN /2, 0, -H_CONNECTOR/2]) {
                    cube(size=[X_EMITTER * PIN, 40, H_CONNECTOR/2]);
                }
            }       
            
            rotate([0, 0, 180]) {
                translate([0, 0, -H_CONNECTOR]) {
                    emitterHolder(H_CONNECTOR);
                }
            }
        }                 
    }
}