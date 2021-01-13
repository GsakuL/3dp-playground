$fn = 50;

/*[Cubes]*/
// the type of block to generate
tetronimo = "T"; // ["I", "J", "L", "O", "S", "T", "Z", "*"]

// the "roundnes" of the blocks
roundRadius = 4.5; // [0:0.1:10]

// size of the individual cubes
blockSize = 15;

// position offset (to account for more rounded cubes)
blockOffset = -0.2; // [-100:0.1:100]

blockSpace = 4;

/*[Magnet]*/
magnetGeneration = true;
// diameter of the magnet (including tollerance)
magnetDiameter = 10.2; // [1:0.1:100]
// thicknes of the magnet (including tollerance)
magnetThicknes = 3.2; // [0.1:0.1:10]
// distance of magnets to bottom layer (use M600/M25 when placing magnets inside)
magnetBottomDistance = 0.8; // [0.1:0.1:10]

/*[Misc]*/
// echo auto-generated filename/suffix based on parameters
generateFileSuffix = true;

{
    assert(magnetDiameter < blockSize, "magnet must fit in block");
    assert(magnetThicknes+magnetBottomDistance < blockSize, "magnet must fit in block");
}

function file_name() = str("file suffix:\n\n",
    "_", tetronimo,
    "_B", blockSize, "+", roundRadius,
    "_M", magnetDiameter, "+", magnetThicknes, "+", magnetBottomDistance,
    "\n\n");

blockDelta = blockSize + blockOffset;
module round_cube(size, d) {
    if (roundRadius == 0) {
        cube(size);
    }
    else {
        hull() {
            translate([d/2, d/2, d/2])
                sphere(d = d);
            translate([size-d/2, size-d/2, size-d/2])
                sphere(d = d);
            translate([size-d/2, size-d/2, d/2])
                sphere(d = d);
            translate([size-d/2, d/2, d/2])
                sphere(d = d);

            translate([d/2, size-d/2, d/2])
                sphere(d = d);
            translate([d/2, size-d/2, size-d/2])
                sphere(d = d);
            translate([size-d/2, d/2, size-d/2])
                sphere(d = d);
            translate([d/2, d/2, size-d/2])
                sphere(d = d);
        }
    }
}

module tetris_block(t = [0, 0, 0]){
    translate(t) difference(){
        round_cube(blockSize, roundRadius);
        union(){
            if (magnetGeneration == true) {
                translate([blockSize/2, blockSize/2, magnetBottomDistance])
                    cylinder(magnetThicknes, d = magnetDiameter);
            }
            else {
                cube(0);
            }
        }
    }
}


module letter(l) {
    union() {
        if (l == "O") {
            tetris_block();
            tetris_block([0, blockDelta, 0]);
            tetris_block([blockDelta, 0, 0]);
            tetris_block([blockDelta, blockDelta, 0]);
        }
        else if (l == "I"){
            for (i = [0:3])
                tetris_block([0, blockDelta*i, 0]);
        }
        else if (l == "L"){
            for (i = [0:2])
                tetris_block([0, blockDelta*i, 0]);
            tetris_block([blockDelta, 0, 0]);
        }
        else if (l == "J"){
            for (i = [0:2])
                tetris_block([0, blockDelta*i, 0]);
            tetris_block([-blockDelta, 0, 0]);
        }

        else if (l == "T"){
            for (i = [0:2])
                tetris_block([0, blockDelta*i, 0]);
            tetris_block([blockDelta, blockDelta, 0]);
        }
        else if (l == "Z"){
            tetris_block();
            tetris_block([0, blockDelta, 0]);
            tetris_block([blockDelta, blockDelta*2, 0]);
            tetris_block([blockDelta, blockDelta, 0]);
        }
        else if (l == "S"){
            tetris_block();
            tetris_block([0, blockDelta, 0]);
            tetris_block([blockDelta, 0, 0]);
            tetris_block([blockDelta, -blockDelta, 0]);
        }
        else assert(false, str("unknown piece! '", l, "'"));
    }
}

if (tetronimo == "*"){
    bds = blockDelta + blockSpace;
    color("cyan") letter("I");
    color("yellow") translate([bds, 0, 0]) letter("O");
    color("darkblue") translate([bds+blockDelta, bds*2, 0]) letter("J");
    color("orange") translate([2*bds+blockDelta, bds*2, 0]) letter("L");
    color("green") translate([0, bds+4*blockDelta, 0]) letter("S");
    color("purple") translate([bds, 2*bds+4*blockDelta, 0]) letter("T");
    color("red") translate([bds*2+blockDelta, 2*bds+4*blockDelta, 0]) letter("Z");
}
else
    letter(tetronimo);

if (generateFileSuffix) { echo(file_name()); }