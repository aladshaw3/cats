//+
SetFactory("Built-in");

// Total length NOTE: All lengths in cm 
L = 0.2;

// wall thickness 
dwall = 0.0111;

// washcoat thickness
dcoat = 0.00231;

// channel width 
dc = 0.09128; 

// starting position 

x=0; y=0; z=0;

// Number of channels 
n=2;

// First front line of 1 full channel (x-y plane)
Point(1) = {x, y, z, 1.0};
Point(2) = {x, y+dwall, z, 1.0};
Point(3) = {x, y+dwall+dcoat, z, 1.0};
Point(4) = {x, y+dwall+dcoat+dc, z, 1.0};
Point(5) = {x, y+dwall+dcoat+dc+dcoat, z, 1.0};
Point(6) = {x, y+dwall+dcoat+dc+dcoat+dwall, z, 1.0};

p=7;
y=y+dwall+dcoat+dc+dcoat+dwall;
For i In {2:n}
	Point(p) = {x, y+dcoat, z, 1.0};
	Point(p+1) = {x, y+dcoat+dc, z, 1.0};
	Point(p+2) = {x, y+dcoat+dc+dcoat, z, 1.0};
	Point(p+3) = {x, y+dcoat+dc+dcoat+dwall, z, 1.0};
	p=p+4;
	y=y+dcoat+dc+dcoat+dwall;
EndFor

y=0;
x=x+L;

Point(p) = {x, y, z, 1.0};
Point(p+1) = {x, y+dwall, z, 1.0};
Point(p+2) = {x, y+dwall+dcoat, z, 1.0};
Point(p+3) = {x, y+dwall+dcoat+dc, z, 1.0};
Point(p+4) = {x, y+dwall+dcoat+dc+dcoat, z, 1.0};
Point(p+5) = {x, y+dwall+dcoat+dc+dcoat+dwall, z, 1.0};

p=p+6;
y=y+dwall+dcoat+dc+dcoat+dwall;
For i In {2:n}
	Point(p) = {x, y+dcoat, z, 1.0};
	Point(p+1) = {x, y+dcoat+dc, z, 1.0};
	Point(p+2) = {x, y+dcoat+dc+dcoat, z, 1.0};
	Point(p+3) = {x, y+dcoat+dc+dcoat+dwall, z, 1.0};
	p=p+4;
	y=y+dcoat+dc+dcoat+dwall;
EndFor

// Horizontal lines LS point (pl) connects to RS point (pr=7+(n-1)*4+(pl-1))

// First 6 lines are always given 
pl=1;
pr=7+(n-1)*4+(pl-1);
Line(1) = {pl,pr};

pl=2;
pr=7+(n-1)*4+(pl-1);
Line(2) = {pl,pr};

pl=3;
pr=7+(n-1)*4+(pl-1);
Line(3) = {pl,pr};

pl=4;
pr=7+(n-1)*4+(pl-1);
Line(4) = {pl,pr};

pl=5;
pr=7+(n-1)*4+(pl-1);
Line(5) = {pl,pr};

pl=6;
pr=7+(n-1)*4+(pl-1);
Line(6) = {pl,pr};

// Extra horizontal lines 
pl=7;
pr=7+(n-1)*4+(pl-1);
For i In {2:n}
	Line(pl) = {pl,pr};
	
	pl=pl+1;
	pr=7+(n-1)*4+(pl-1);
	Line(pl) = {pl,pr};
	
	pl=pl+1;
	pr=7+(n-1)*4+(pl-1);
	Line(pl) = {pl,pr};
	
	pl=pl+1;
	pr=7+(n-1)*4+(pl-1);
	Line(pl) = {pl,pr};
	
	pl=pl+1;
	pr=7+(n-1)*4+(pl-1);
EndFor

// Vertical lines - there will always be at least 10 

// LHS 
p=1;
Line(pl) = {p, p+1};
pl=pl+1;
pr=7+(n-1)*4+(p-1);
Line(pl) = {pr,pr+1};

p=p+1;
pl=pl+1;
Line(pl) = {p, p+1};
pl=pl+1;
pr=7+(n-1)*4+(p-1);
Line(pl) = {pr,pr+1};

p=p+1;
pl=pl+1;
Line(pl) = {p, p+1};
pl=pl+1;
pr=7+(n-1)*4+(p-1);
Line(pl) = {pr,pr+1};

p=p+1;
pl=pl+1;
Line(pl) = {p, p+1};
pl=pl+1;
pr=7+(n-1)*4+(p-1);
Line(pl) = {pr,pr+1};

p=p+1;
pl=pl+1;
Line(pl) = {p, p+1};
pl=pl+1;
pr=7+(n-1)*4+(p-1);
Line(pl) = {pr,pr+1};

// Extra vertical lines 
For i In {2:n}
	p=p+1;
	pl=pl+1;
	Line(pl) = {p, p+1};
	pl=pl+1;
	pr=7+(n-1)*4+(p-1);
	Line(pl) = {pr,pr+1};
	
	p=p+1;
	pl=pl+1;
	Line(pl) = {p, p+1};
	pl=pl+1;
	pr=7+(n-1)*4+(p-1);
	Line(pl) = {pr,pr+1};
	
	p=p+1;
	pl=pl+1;
	Line(pl) = {p, p+1};
	pl=pl+1;
	pr=7+(n-1)*4+(p-1);
	Line(pl) = {pr,pr+1};
	
	p=p+1;
	pl=pl+1;
	Line(pl) = {p, p+1};
	pl=pl+1;
	pr=7+(n-1)*4+(p-1);
	Line(pl) = {pr,pr+1};
EndFor

// NOTE: From this point on, it is best to use the GUI to make physical groups and name boundaries 
