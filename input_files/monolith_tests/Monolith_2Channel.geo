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

//Smaller distance from edge
de = 0.02445;

//Large distance from edge
dc = 0.043975;



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



// At this point, we have finished the construction of the face of 1 channel
//	Now we need to create the other channel faces...
//
// The next faces will be connected and thus share points, so we only need 
//	to create points that are not shared...


// Can manually add more points, or use the Translate and Duplicata commands
//	NOTE: The numbering follows the logical order ONLY IF you use OpenCASCADE

// Surface 1 is duplicated and translated over to become Surface 3
//	Use new_surf[] to return id tags for new surface
new_surf1[] = Translate {dt,0,0}{ Duplicata{Surface{1};} };

// Surface 2 is duplicated and translated over to become Surface 4
new_surf2[] = Translate {dt,0,0}{ Duplicata{Surface{2};} };

// Place new surface ids into a map (note: above returns list indexed from 0)
surf[1] = new_surf1[0];
surf[2] = new_surf2[0];

// You can print the surface values out to the console to view them
Printf("New surfaces '%g' and '%g'", surf[1], surf[2]);



// Repeat the above process until we have all the channels we want

//    PROBLEM: All points were duplicated, which means there are separate points
//		and separate curves at the SHARED boundaries!! We can't have this. 
//
//	See comments at top about the SetFactory options...
//
//	If you want separate subdomains, then using the default is fine


// For testing purposes, we will stop here and extrude the surfaces
//	NOTE: We may not know what surfaces there are beyond 1 and 2

// Place all surface IDs into a list? How do I iterate through a list?
//	I can't figure out how to iterate through a list in this language...
all_surf[0] = 1;
all_surf[1] = 2;
all_surf[2] = surf[1];
all_surf[3] = surf[2];

// Need a more iterative way of doing this...
//Extrude {0, L, 0} { Surface{1, 2, surf[1], surf[2]}; }

// IF the only surfaces are the faces that need to be extruded, 
//	THEN, you can use the {:} argument to extrude all surfaces
//		in the same way
Extrude {0, L, 0} { Surface{:}; }



//Open in Gmsh, then select the physical groups and mesh in 3D

// NOTE: If using OpenCASCADE, then the surfaces will not display correctly in Gmsh


//+
Physical Surface("interface") = {83, 87, 59, 63, 67, 71, 79, 75, 191, 187, 163, 183, 179, 175, 171, 167};
//+
Physical Surface("inlet") = {2, 26};
//+
Physical Surface("outlet") = {234, 130};
//+
Physical Surface("wash_in") = {1, 13};
//+
Physical Surface("wash_out") = {88, 192};
//+
Physical Surface("outer_walls") = {51, 155, 55, 43, 147, 151};
//+
Physical Surface("washcoat_interface") = {47};
//+
Physical Volume("channel") = {2, 4};
//+
Physical Volume("washcoat") = {1, 3};
