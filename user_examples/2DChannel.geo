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
L=0.05;

//Total diameter of the monolith
D=0.02;

//Diameter of the outer shape of single channel
dt = 0.00127;

//Avg distance from edge
dw = 0.00026975;



//Starting position
x=0; y=0; z=0;


//Add the points
Point(1) = {x, y, z, 1.0};
Point(2) = {x, y+0.0245, z, 1.0};
Point(3) = {x, y+0.0255, z, 1.0};
Point(4) = {x, y+0.05, z, 1.0};


Point(5) = {x, y+0.05, z+dw, 1.0};
Point(6) = {x, y+0.05, z+dt-dw, 1.0};

Point(7) = {x, y+0.05, z+dt, 1.0};
Point(8) = {x, y+0.0255, z+dt, 1.0};

Point(9) = {x, y+0.0245, z+dt, 1.0};
Point(10) = {x, y, z+dt, 1.0};

Point(11) = {x, y, z+dt-dw, 1.0};
Point(12) = {x, y, z+dw, 1.0};

Point(13) = {x, y+0.02425, z+dw, 1.0};
Point(14) = {x, y+0.02575, z+dw, 1.0};

Point(15) = {x, y+0.02575, z+dt-dw, 1.0};
Point(16) = {x, y+0.02425, z+dt-dw, 1.0};


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


/// NOTE: These commands did not all work

// Create a curve for the channel
//Curve Loop(1) = {13, 14, 2, 15, 16, 5, 17, 18, 8, 19, 20, 11};

// Create a curve for each washcoat segment
//Curve Loop(2) = {1, 14, 13, 12};
//Curve Loop(3) = {15, 16, 4, 3};
//Curve Loop(4) = {6, 7, 18, 17};
//Curve Loop(5) = {19, 20, 10, 9};

// Create a surface for the channel
//Plane Surface(1) = {1};

// Create a surface for each washcoat segment
//Plane Surface(2) = {2};
//Plane Surface(3) = {3};
//Plane Surface(4) = {4};
//Plane Surface(5) = {5};

//Add in the physical groups (Curves and Surfaces) [Use Gmsh for this]


// Had to go into Gmsh to create the correct curve loops (not sure why)
//		Negative signs indicate direction?

//+
Curve Loop(1) = {11, 13, 14, 2, 15, 16, 5, 17, 18, 8, 19, 20};
//+
Plane Surface(1) = {1};
//+
Curve Loop(2) = {10, -20, -19, 9};
//+
Plane Surface(2) = {2};
//+
Curve Loop(3) = {18, -7, -6, 17};
//+
Plane Surface(3) = {3};
//+
Curve Loop(4) = {16, -4, -3, 15};
//+
Plane Surface(4) = {4};
//+
Curve Loop(5) = {12, 1, -14, -13};
//+
Plane Surface(5) = {5};



//+
Physical Curve("inlet") = {11};
//+
Physical Curve("outlet") = {5};
//+
Physical Curve("inner_walls") = {13, 14, 15, 16, 17, 18, 19, 20, 8, 2};
//+
Physical Curve("outer_walls") = {10, 9, 7, 6, 4, 3, 1, 12};
//+
Physical Surface("channel") = {1};
//+
Physical Surface("washcoat") = {5, 2, 3, 4};
