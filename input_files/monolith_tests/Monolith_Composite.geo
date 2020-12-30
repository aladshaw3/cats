// Gmsh project created on Wed May 27 14:48:41 2020
SetFactory("OpenCASCADE");


//+
Point(1) = {0, 0, 0, 1.0};
//+
Point(2) = {0.127, 0, 0, 1.0};
//+
Point(3) = {0.127, 0, 0.127, 1.0};
//+
Point(4) = {0, 0, 0.127, 1.0};

//+
Point(5) = {0, 5, 0, 1.0};
//+
Point(6) = {0.127, 5, 0, 1.0};
//+
Point(7) = {0.127, 5, 0.127, 1.0};
//+
Point(8) = {0, 5, 0.127, 1.0};

//+
Point(9) = {0.025, 0, 0.04377, 1.0};
//+
Point(10) = {0.04377, 0, 0.025, 1.0};
//+
Point(11) = {0.081327, 0, 0.025, 1.0};
//+
Point(12) = {0.100097, 0, 0.04377, 1.0};
//+
Point(13) = {0.100097, 0, 0.081327, 1.0};
//+
Point(14) = {0.081327, 0, 0.100097, 1.0};
//+
Point(15) = {0.04377, 0, 0.100097, 1.0};
//+
Point(16) = {0.025, 0, 0.081327, 1.0};

//+
Point(17) = {0.025, 5, 0.04377, 1.0};
//+
Point(18) = {0.04377, 5, 0.025, 1.0};
//+
Point(19) = {0.081327, 5, 0.025, 1.0};
//+
Point(20) = {0.100097, 5, 0.04377, 1.0};
//+
Point(21) = {0.100097, 5, 0.081327, 1.0};
//+
Point(22) = {0.081327, 5, 0.100097, 1.0};
//+
Point(23) = {0.04377, 5, 0.100097, 1.0};
//+
Point(24) = {0.025, 5, 0.081327, 1.0};




//+
Line(1) = {5, 1};
//+
Line(2) = {6, 2};
//+
Line(3) = {8, 4};
//+
Line(4) = {7, 3};
//+
Line(5) = {17, 9};
//+
Line(6) = {18, 10};
//+
Line(7) = {19, 11};
//+
Line(8) = {20, 12};
//+
Line(9) = {24, 16};
//+
Line(10) = {23, 15};
//+
Line(11) = {21, 13};
//+
Line(12) = {22, 14};
//+
Line(13) = {5, 6};
//+
Line(14) = {6, 7};
//+
Line(15) = {7, 8};
//+
Line(16) = {8, 5};
//+
Line(17) = {1, 2};
//+
Line(18) = {2, 3};
//+
Line(19) = {3, 4};
//+
Line(20) = {4, 1};
//+
Line(21) = {18, 19};
//+
Line(22) = {23, 22};
//+
Line(23) = {17, 24};
//+
Line(24) = {20, 21};
//+
Line(25) = {10, 11};
//+
Line(26) = {12, 13};
//+
Line(27) = {9, 16};
//+
Line(28) = {15, 14};


//+
Line(29) = {9, 10};
//+
Line(30) = {11, 12};
//+
Line(31) = {16, 15};
//+
Line(32) = {14, 13};
//+
Line(33) = {19, 20};
//+
Line(34) = {18, 17};
//+
Line(35) = {24, 23};
//+
Line(36) = {22, 21};




//+
Curve Loop(1) = {17, 18, 19, 20};
//+
Curve Loop(2) = {25, 30, 26, -32, -28, -31, -27, 29};
//+
Plane Surface(1) = {1, 2};
//+
Curve Loop(3) = {13, 14, 15, 16};
//+
Curve Loop(4) = {21, 33, 24, -36, -22, -35, -23, -34};
//+
Plane Surface(2) = {3, 4};
//+
Curve Loop(5) = {21, 33, 24, -36, -22, -35, -23, -34};
//+
Plane Surface(3) = {5};
//+
Curve Loop(6) = {25, 30, 26, -32, -28, -31, -27, 29};
//+
Plane Surface(4) = {6};
//+
Curve Loop(7) = {28, -12, -22, 10};
//+
Plane Surface(5) = {7};
//+
Curve Loop(8) = {12, 32, -11, -36};
//+
Plane Surface(6) = {8};
//+
Curve Loop(9) = {11, -26, -8, 24};
//+
Plane Surface(7) = {9};
//+
Curve Loop(10) = {30, -8, -33, 7};
//+
Plane Surface(8) = {10};
//+
Curve Loop(11) = {6, 25, -7, -21};
//+
Plane Surface(9) = {11};
//+
Curve Loop(12) = {29, -6, 34, 5};
//+
Plane Surface(10) = {12};
//+
Curve Loop(13) = {5, 27, -9, -23};
//+
Plane Surface(11) = {13};
//+
Curve Loop(14) = {31, -10, -35, 9};
//+
Plane Surface(12) = {14};
//+
Curve Loop(15) = {2, 18, -4, -14};
//+
Plane Surface(13) = {15};
//+
Curve Loop(16) = {1, 17, -2, -13};
//+
Plane Surface(14) = {16};
//+
Curve Loop(17) = {1, -20, -3, 16};
//+
Plane Surface(15) = {17};
//+
Curve Loop(18) = {3, -19, -4, 15};
//+
Plane Surface(16) = {18};



//+
Surface Loop(1) = {2, 14, 15, 1, 13, 16, 5, 6, 7, 8, 9, 10, 11, 12};
//+
Volume(1) = {1};
//+
Surface Loop(2) = {3, 8, 7, 6, 5, 12, 11, 10, 9, 4};
//+
Volume(2) = {2};
//+
Physical Volume("washcoat") = {1};
//+
Physical Volume("channel") = {2};
//+
Physical Surface("outlet") = {3};
//+
Physical Surface("inlet") = {4};
//+
Physical Surface("interface") = {5, 6, 12, 7, 8, 9, 10, 11};
//+
Physical Surface("wash_in") = {1};
//+
Physical Surface("wash_out") = {2};
//+
Physical Surface("washcoat_walls") = {13, 14, 15, 16};