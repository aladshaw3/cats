// Gmsh project created on Thu May 28 11:29:15 2020
SetFactory("OpenCASCADE");

//Total length of channel/monolith
L=5;

//Total diameter of the monolith
D=2;

//Diameter of the outer shape of single channel
dt = 0.127;

//Starting positions
x[1]=0; y[1]=0; z[1]=0;
x[2]=x[1]+dt; y[2]=y[1]; z[2]=z[1];
x[3]=x[1]+dt; y[3]=y[1]; z[3]=z[1]+dt;
x[4]=x[1]; y[4]=y[1]; z[4]=z[1]+dt;

//Add the outer rim points (y=0)
Point(1) = {x[1], y[1], z[1], 1.0};
Point(2) = {x[2], y[2], z[2], 1.0};
Point(3) = {x[3], y[3], z[3], 1.0};
Point(4) = {x[4], y[4], z[4], 1.0};

//Smaller distance from edge
de = 0.02445;

//Large distance from edge
dc = 0.043975;


//Interior points for 1 channel (y=0)

//Point 5 and 6 based on Point 1
Point(5) = {x[1]+de, y[1], z[1]+dc, 1.0};
Point(6) = {x[1]+dc, y[1], z[1]+de, 1.0};

//Point 7 and 8 based on Point 2
Point(7) = {x[2]-dc, y[2], z[2]+de, 1.0};
Point(8) = {x[2]-de, y[2], z[2]+dc, 1.0};

//Point 9 and 10 based on Point 3
Point(9) = {x[3]-de, y[3], z[3]-dc, 1.0};
Point(10) = {x[3]-dc, y[3], z[3]-de, 1.0};

//Point 11 and 12 based on Point 4
Point(11) = {x[4]+dc, y[4], z[4]-de, 1.0};
Point(12) = {x[4]+de, y[4], z[4]-dc, 1.0};


//All points for first face are complete, now draw lines from point to point

//Outer rim (manually)
Line(1) = {1,2};
Line(2) = {2,3};
Line(3) = {3,4};
Line(4) = {4,1};

//Inner rim (with a loop)
For i In {5:12}
	If (i==12)
		Line(i) = {i,5};
	Else
		Line(i) = {i,i+1};
	EndIf
EndFor


// Create a curve from the outer rim lines
Curve Loop(1) = {1, 2, 3, 4};

// Create a curve from the inner rim lines
Curve Loop(2) = {5, 6, 7, 8, 9, 10, 11, 12};

// Create a surface from Curves 1 and 2. (i.e., 1 is main and 2 is the "hole")
Plane Surface(1) = {1, 2};

// Create a surface from only Curve 2
Plane Surface(2) = {2};

// Extrude the surfaces for the length of the monolith
//    NOTE: This will automatically create all needed volumes and other surfaces
//		YOU SHOULD ONLY EXTRUDE AS THE FINAL STEP!!!
Extrude {0, L, 0} { Surface{1,2}; }

// At this point, if you want to create "Physical Groups", you may
//	have to open the script in Gmsh and manually add the groups
//	by hand. This is because the surfaces and volumes from Extrude 
//	get numbered automatically by the routines, so we may not know
//	which surface or volume ID is associated with which actual 
//	physical representation. 

// Selected Surfaces from Gmsh GUI
//+
Physical Surface("wash_out") = {15};
//+
Physical Surface("outlet") = {16};
//+
Physical Surface("washcoat_walls") = {4, 3, 5, 6};
//+
Physical Surface("inlet") = {2};
//+
Physical Surface("wash_in") = {1};
//+
Physical Surface("interface") = {8, 9, 10, 7, 14, 13, 12, 11};

// Selected Volumes from Gmsh GUI
//+
Physical Volume("channel") = {2};
//+
Physical Volume("washcoat") = {1};

//After selection of the Physical groups, you are done. Open in Gmsh and mesh in 3D
//	Save the mesh in .msh format using ASCII version 4
