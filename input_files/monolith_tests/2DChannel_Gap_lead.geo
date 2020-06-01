// Gmsh project created on Thu May 28 11:29:15 2020

// Before writing any script, user must specify the mesh factor
//	The default is "OpenCASCADE" and is usually written in
//	when you open the script. THIS NEEDS TO BE REPLACED IF
//	YOU PLAN ON USING THE "Duplicata" FUNCTION. 
//
// Set the factory to "Built-in" and Gmsh will automatically
//	remove any duplicate points lines or surfaces when using
//	the "Duplicata" function. NOTE: This will also result
//	in very strange numbering for all subsequent points, lines,
//	and surfaces. 

// Remove the line below
//SetFactory("OpenCASCADE");

// Replacement factory 
SetFactory("Built-in");

//Total length of channel/monolith
L=5;

//Total diameter of the monolith
D=2;

//Diameter of the outer shape of single channel
dt = 0.127;

//Avg distance from edge
dw = 0.026975;



//Starting position
x=0; y=0; z=0;


//Add the points
Point(1) = {x, y, z, 1.0};
Point(2) = {x, y+2.45, z, 1.0};
Point(3) = {x, y+2.55, z, 1.0};
Point(4) = {x, y+5, z, 1.0};


Point(5) = {x, y+5, z+dw, 1.0};
Point(6) = {x, y+5, z+dt-dw, 1.0};

Point(7) = {x, y+5, z+dt, 1.0};
Point(8) = {x, y+2.55, z+dt, 1.0};

Point(9) = {x, y+2.45, z+dt, 1.0};
Point(10) = {x, y, z+dt, 1.0};

Point(11) = {x, y, z+dt-dw, 1.0};
Point(12) = {x, y, z+dw, 1.0};

Point(13) = {x, y+2.425, z+dw, 1.0};
Point(14) = {x, y+2.575, z+dw, 1.0};

Point(15) = {x, y+2.575, z+dt-dw, 1.0};
Point(16) = {x, y+2.425, z+dt-dw, 1.0};

//New Points for the lead section
Point(17) = {x, y-0.1, z+dt, 1.0};
Point(18) = {x, y-0.1, z, 1.0};

Point(19) = {x, y-0.05, z+dt, 1.0};
Point(20) = {x, y-0.05, z, 1.0};

//All points for first face are complete, now draw lines from point to point

//Outer rim (manually)
Line(1) = {1,2};
Line(2) = {2,3};
Line(3) = {3,4};
Line(4) = {4,5};
Line(5) = {5,6};
Line(6) = {6,7};
Line(7) = {7,8};
Line(8) = {8,9};
Line(9) = {9,10};
Line(10) = {10,11};
Line(11) = {11,12};
Line(12) = {12,1};

Line(13) = {12,13};
Line(14) = {13,2};

Line(15) = {3,14};
Line(16) = {14,5};

Line(17) = {6,15};
Line(18) = {15,8};

Line(19) = {9,16};
Line(20) = {16,11};

//Add additional lines for the lead section
Line(21) = {10,19};
Line(22) = {20,1};

Line(23) = {17,19};
Line(24) = {20,18};

Line(25) = {17,18};

Line(26) = {11,19};
Line(27) = {20,12};


//Below here, rest is done in Gmsh GUI


//+
Curve Loop(1) = {25, -24, 27, 13, 14, 2, 15, 16, 5, 17, 18, 8, 19, 20, 26, -23};
//+
Plane Surface(1) = {1};
//+
Curve Loop(2) = {26, -21, -9, 19, 20};
//+
Plane Surface(2) = {2};
//+
Curve Loop(3) = {27, 13, 14, -1, -22};
//+
Plane Surface(3) = {3};
//+
Curve Loop(4) = {18, -7, -6, 17};
//+
Plane Surface(4) = {4};
//+
Curve Loop(5) = {4, -16, -15, 3};
//+
Plane Surface(5) = {5};
//+
Physical Curve("inlet") = {25};
//+
Physical Curve("outlet") = {5};
//+
Physical Curve("inner_walls") = {17, 16, 18, 15, 8, 2, 14, 19, 20, 13, 26, 27, 23, 24};
//+
Physical Curve("outer_walls") = {21, 9, 7, 6, 4, 3, 1, 22};
//+
Physical Surface("channel") = {1};
//+
Physical Surface("washcoat") = {2, 3, 4, 5};
