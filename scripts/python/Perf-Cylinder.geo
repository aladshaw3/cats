//Demos available at https://gitlab.onelab.info/gmsh/gmsh/tree/master/demos

// Gmsh project created on Thu Dec 12 09:48:20 2019
SetFactory("OpenCASCADE");

// Volume 1
Cylinder(1) = {0, 0, 0, 0, 0, 2, 0.5, 2*Pi};

// Volume 2 (to remove)
Cylinder(2) = {0, 0, .2, 0, 0, 0.1, 0.5, 2*Pi};

// Volume 3 (to remove)
Cylinder(3) = {0, 0, .5, 0, 0, 0.1, 0.5, 2*Pi};

// Volume 4 (to remove)
Cylinder(4) = {0, 0, .8, 0, 0, 0.1, 0.5, 2*Pi};

// Volume 5 (to remove)
Cylinder(5) = {0, 0, 1.1, 0, 0, 0.1, 0.5, 2*Pi};

// Volume 6 (to remove)
Cylinder(6) = {0, 0, 1.4, 0, 0, 0.1, 0.5, 2*Pi};

// Volume 7 (to remove)
Cylinder(7) = {0, 0, 1.7, 0, 0, 0.1, 0.5, 2*Pi};

// Remove Volume 2 through 7 from Volume 1
BooleanDifference{ Volume{1}; Delete; }{ Volume{2,3,4,5,6,7}; Delete; }
//NOTE: Once complete, the system automatically renumbers the volumes

// Add the pathways

// Volume 8 (to add)
Cylinder(8) = {0.12, 0.07, .2, 0, 0, 0.1, 0.075, 2*Pi};

// Volume 9 (to add)
Cylinder(9) = {0, .35, .2, 0, 0, 0.1, 0.1, 2*Pi};

// Volume 10 (to add)
Cylinder(10) = {0, -.35, .2, 0, 0, 0.1, 0.1, 2*Pi};

// Volume 11 (to add)
Cylinder(11) = {.35, 0, .2, 0, 0, 0.1, 0.1, 2*Pi};

// Volume 12 (to add)
Cylinder(12) = {-.35, 0, .2, 0, 0, 0.1, 0.1, 2*Pi};

// Volume 13 (to add)
Cylinder(13) = {-.25, -.25, .2, 0, 0, 0.1, 0.1, 2*Pi};

// Volume 14 (to add)
Cylinder(14) = {.25, -.25, .2, 0, 0, 0.1, 0.1, 2*Pi};

// Volume 15 (to add)
Cylinder(15) = {.25, .25, .2, 0, 0, 0.1, 0.1, 2*Pi};

// Volume 16 (to add)
Cylinder(16) = {-.25, .25, .2, 0, 0, 0.1, 0.1, 2*Pi};

// Volume 17 (to add)
Cylinder(17) = {-0.12, -0.07, .2, 0, 0, 0.1, 0.075, 2*Pi};

// Volume 18 (to add)
Cylinder(18) = {0.07, -0.12, .2, 0, 0, 0.1, 0.075, 2*Pi};

// Volume 19 (to add)
Cylinder(19) = {-0.07, 0.12, .2, 0, 0, 0.1, 0.075, 2*Pi};


// Union the pathways
// Unite Volume 7 with Volumes 8 - 19
BooleanUnion{ Volume{7}; Delete; }{ Volume{8,9,10,11,12,13,14,15,16,17,18,19}; Delete; }

//Unite Volume 7 with Volume 6
BooleanUnion{ Volume{7}; Delete; }{ Volume{6}; Delete; }


// Add more pathways (with some rotation)

// Volume 20 (to add)
Cylinder(20) = {0.12, 0.07, .5, 0, 0, 0.1, 0.075, 2*Pi};

// Volume 21 (to add)
Cylinder(21) = {0, .35, .5, 0, 0, 0.1, 0.1, 2*Pi};

// Volume 22 (to add)
Cylinder(22) = {0, -.35, .5, 0, 0, 0.1, 0.1, 2*Pi};

// Volume 23 (to add)
Cylinder(23) = {.35, 0, .5, 0, 0, 0.1, 0.1, 2*Pi};

// Volume 24 (to add)
Cylinder(24) = {-.35, 0, .5, 0, 0, 0.1, 0.1, 2*Pi};

// Volume 25 (to add)
Cylinder(25) = {-.25, -.25, .5, 0, 0, 0.1, 0.1, 2*Pi};

// Volume 26 (to add)
Cylinder(26) = {.25, -.25, .5, 0, 0, 0.1, 0.1, 2*Pi};

// Volume 27 (to add)
Cylinder(27) = {.25, .25, .5, 0, 0, 0.1, 0.1, 2*Pi};

// Volume 28 (to add)
Cylinder(28) = {-.25, .25, .5, 0, 0, 0.1, 0.1, 2*Pi};

// Volume 29 (to add)
Cylinder(29) = {-0.12, -0.07, .5, 0, 0, 0.1, 0.075, 2*Pi};

// Volume 30 (to add)
Cylinder(30) = {0.07, -0.12, .5, 0, 0, 0.1, 0.075, 2*Pi};

// Volume 31 (to add)
Cylinder(31) = {-0.07, 0.12, .5, 0, 0, 0.1, 0.075, 2*Pi};

//Unite Volume 5 with Volumes 20-31
BooleanUnion{ Volume{5}; Delete; }{ Volume{20,21,22,23,24,25,26,27,28,29,30,31}; Delete; }
//NOTE: This new volume becomes Volume 7 (not sure why the numbering updates)

//Rotate the union so that the holes don't line up
Rotate {{0, 0, 1}, {0, 0, 0}, Pi/8} {Volume{7}; }

//Unite Volume 7 with Volume 6
BooleanUnion{ Volume{7}; Delete; }{ Volume{6}; Delete; }


// Add more pathways (with some rotation)

// Volume 32 (to add)
Cylinder(32) = {0.12, 0.07, .8, 0, 0, 0.1, 0.075, 2*Pi};

// Volume 33 (to add)
Cylinder(33) = {0, .35, .8, 0, 0, 0.1, 0.1, 2*Pi};

// Volume 34 (to add)
Cylinder(34) = {0, -.35, .8, 0, 0, 0.1, 0.1, 2*Pi};

// Volume 35 (to add)
Cylinder(35) = {.35, 0, .8, 0, 0, 0.1, 0.1, 2*Pi};

// Volume 36 (to add)
Cylinder(36) = {-.35, 0, .8, 0, 0, 0.1, 0.1, 2*Pi};

// Volume 37 (to add)
Cylinder(37) = {-.25, -.25, .8, 0, 0, 0.1, 0.1, 2*Pi};

// Volume 38 (to add)
Cylinder(38) = {.25, -.25, .8, 0, 0, 0.1, 0.1, 2*Pi};

// Volume 39 (to add)
Cylinder(39) = {.25, .25, .8, 0, 0, 0.1, 0.1, 2*Pi};

// Volume 40 (to add)
Cylinder(40) = {-.25, .25, .8, 0, 0, 0.1, 0.1, 2*Pi};

// Volume 41 (to add)
Cylinder(41) = {-0.12, -0.07, .8, 0, 0, 0.1, 0.075, 2*Pi};

// Volume 42 (to add)
Cylinder(42) = {0.07, -0.12, .8, 0, 0, 0.1, 0.075, 2*Pi};

// Volume 43 (to add)
Cylinder(43) = {-0.07, 0.12, .8, 0, 0, 0.1, 0.075, 2*Pi};


//Unite Volume 4 with Volumes 32-43
BooleanUnion{ Volume{4}; Delete; }{ Volume{32,33,34,35,36,37,38,39,40,41,42,43}; Delete; }
//NOTE: This new volume becomes Volume 7 (not sure why the numbering updates)

//Rotate the union so that the holes don't line up
Rotate {{0, 0, 1}, {0, 0, 0}, Pi/4} {Volume{6}; }

//Unite Volume 5 with Volume 6
BooleanUnion{ Volume{5}; Delete; }{ Volume{6}; Delete; }


// Add more pathways (with some rotation)

// Volume 44 (to add)
Cylinder(44) = {0.12, 0.07, 1.1, 0, 0, 0.1, 0.075, 2*Pi};

// Volume 45 (to add)
Cylinder(45) = {0, .35, 1.1, 0, 0, 0.1, 0.1, 2*Pi};

// Volume 46 (to add)
Cylinder(46) = {0, -.35, 1.1, 0, 0, 0.1, 0.1, 2*Pi};

// Volume 47 (to add)
Cylinder(47) = {.35, 0, 1.1, 0, 0, 0.1, 0.1, 2*Pi};

// Volume 48 (to add)
Cylinder(48) = {-.35, 0, 1.1, 0, 0, 0.1, 0.1, 2*Pi};

// Volume 49 (to add)
Cylinder(49) = {-.25, -.25, 1.1, 0, 0, 0.1, 0.1, 2*Pi};

// Volume 50 (to add)
Cylinder(50) = {.25, -.25, 1.1, 0, 0, 0.1, 0.1, 2*Pi};

// Volume 51 (to add)
Cylinder(51) = {.25, .25, 1.1, 0, 0, 0.1, 0.1, 2*Pi};

// Volume 52 (to add)
Cylinder(52) = {-.25, .25, 1.1, 0, 0, 0.1, 0.1, 2*Pi};

// Volume 53 (to add)
Cylinder(53) = {-0.12, -0.07, 1.1, 0, 0, 0.1, 0.075, 2*Pi};

// Volume 54 (to add)
Cylinder(54) = {0.07, -0.12, 1.1, 0, 0, 0.1, 0.075, 2*Pi};

// Volume 55 (to add)
Cylinder(55) = {-0.07, 0.12, 1.1, 0, 0, 0.1, 0.075, 2*Pi};

//Unite Volume 3 with Volumes 44-55
BooleanUnion{ Volume{3}; Delete; }{ Volume{44,45,46,47,48,49,50,51,52,53,54,55}; Delete; }
//NOTE: This new volume becomes Volume 7 (not sure why the numbering updates)

//Rotate the union so that the holes don't line up
Rotate {{0, 0, 1}, {0, 0, 0}, Pi/2} {Volume{5}; }

//Unite Volume 4 with Volume 5
BooleanUnion{ Volume{4}; Delete; }{ Volume{5}; Delete; }


// Add more pathways (with some rotation)

// Volume 56 (to add)
Cylinder(56) = {0.12, 0.07, 1.4, 0, 0, 0.1, 0.075, 2*Pi};

// Volume 57 (to add)
Cylinder(57) = {0, .35, 1.4, 0, 0, 0.1, 0.1, 2*Pi};

// Volume 58 (to add)
Cylinder(58) = {0, -.35, 1.4, 0, 0, 0.1, 0.1, 2*Pi};

// Volume 59 (to add)
Cylinder(59) = {.35, 0, 1.4, 0, 0, 0.1, 0.1, 2*Pi};

// Volume 60 (to add)
Cylinder(60) = {-.35, 0, 1.4, 0, 0, 0.1, 0.1, 2*Pi};

// Volume 61 (to add)
Cylinder(61) = {-.25, -.25, 1.4, 0, 0, 0.1, 0.1, 2*Pi};

// Volume 62 (to add)
Cylinder(62) = {.25, -.25, 1.4, 0, 0, 0.1, 0.1, 2*Pi};

// Volume 63 (to add)
Cylinder(63) = {.25, .25, 1.4, 0, 0, 0.1, 0.1, 2*Pi};

// Volume 64 (to add)
Cylinder(64) = {-.25, .25, 1.4, 0, 0, 0.1, 0.1, 2*Pi};

// Volume 65 (to add)
Cylinder(65) = {-0.12, -0.07, 1.4, 0, 0, 0.1, 0.075, 2*Pi};

// Volume 66 (to add)
Cylinder(66) = {0.07, -0.12, 1.4, 0, 0, 0.1, 0.075, 2*Pi};

// Volume 67 (to add)
Cylinder(67) = {-0.07, 0.12, 1.4, 0, 0, 0.1, 0.075, 2*Pi};

//Unite Volume 2 with Volumes 56-67
BooleanUnion{ Volume{2}; Delete; }{ Volume{56,57,58,59,60,61,62,63,64,65,66,67}; Delete; }
//NOTE: This new volume becomes Volume 7 (not sure why the numbering updates)

//Rotate the union so that the holes don't line up
Rotate {{0, 0, 1}, {0, 0, 0}, Pi} {Volume{4}; }

//Unite Volume 3 with Volume 4
BooleanUnion{ Volume{3}; Delete; }{ Volume{4}; Delete; }


// Add more pathways (with some rotation)

// Volume 68 (to add)
Cylinder(68) = {0.12, 0.07, 1.7, 0, 0, 0.1, 0.075, 2*Pi};

// Volume 69 (to add)
Cylinder(69) = {0, .35, 1.7, 0, 0, 0.1, 0.1, 2*Pi};

// Volume 70 (to add)
Cylinder(70) = {0, -.35, 1.7, 0, 0, 0.1, 0.1, 2*Pi};

// Volume 71 (to add)
Cylinder(71) = {.35, 0, 1.7, 0, 0, 0.1, 0.1, 2*Pi};

// Volume 72 (to add)
Cylinder(72) = {-.35, 0, 1.7, 0, 0, 0.1, 0.1, 2*Pi};

// Volume 73 (to add)
Cylinder(73) = {-.25, -.25, 1.7, 0, 0, 0.1, 0.1, 2*Pi};

// Volume 74 (to add)
Cylinder(74) = {.25, -.25, 1.7, 0, 0, 0.1, 0.1, 2*Pi};

// Volume 75 (to add)
Cylinder(75) = {.25, .25, 1.7, 0, 0, 0.1, 0.1, 2*Pi};

// Volume 76 (to add)
Cylinder(76) = {-.25, .25, 1.7, 0, 0, 0.1, 0.1, 2*Pi};

// Volume 77 (to add)
Cylinder(77) = {-0.12, -0.07, 1.7, 0, 0, 0.1, 0.075, 2*Pi};

// Volume 78 (to add)
Cylinder(78) = {0.07, -0.12, 1.7, 0, 0, 0.1, 0.075, 2*Pi};

// Volume 79 (to add)
Cylinder(79) = {-0.07, 0.12, 1.7, 0, 0, 0.1, 0.075, 2*Pi};

//Unite Volume 1 with Volumes 68-79
BooleanUnion{ Volume{1}; Delete; }{ Volume{68,69,70,71,72,73,74,75,76,77,78,79}; Delete; }
//NOTE: This new volume becomes Volume 7 (not sure why the numbering updates)

//Rotate the union so that the holes don't line up
Rotate {{0, 0, 1}, {0, 0, 0}, 2*Pi} {Volume{3}; }

//Unite Volume 2 with Volume 3
BooleanUnion{ Volume{2}; Delete; }{ Volume{3}; Delete; }

//Scale the unit up or down in size
Dilate {{0, 0, 0}, {10, 10, 10}} {Volume{1}; }
//Main cylinder diameter = 10 cm, length = 20 cm

//+
Physical Surface("wall") = {91, 92, 77, 62, 47, 30, 1, 31, 78, 63, 48, 32, 2, 29, 76, 61, 46, 28, 3, 80, 83, 79, 74, 70, 72, 49, 51, 60, 34, 40, 35, 11, 10, 4, 5, 16, 17, 20, 90, 86, 69, 50, 36, 12, 23, 27, 19, 26, 22, 15, 14, 41, 43, 44, 45, 55, 57, 58, 59, 73, 66, 82, 89, 64, 85, 65, 42, 54, 71, 84, 87, 68, 56, 39, 9, 13, 21, 24, 7, 8, 25, 18, 6, 38, 37, 53, 75, 88, 52, 67, 81};
//+
Physical Surface("inlet") = {33};
//+
Physical Surface("outlet") = {93};
