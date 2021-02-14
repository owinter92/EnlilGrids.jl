g=0.1;

Point(0) = {0,0,0,g};
Point(1) = {1,0,0,g};
Point(2) = {1,1,0,g};
Point(3) = {0,1,0,g};

Line(1) = {0, 1};
Line(2) = {1, 2};
Line(3) = {2, 3};
Line(4) = {3, 0};

Curve Loop(1) = {4, 1, 2, 3};
Plane Surface(1) = {1};

Physical Curve("Line1") = {1};
Physical Curve("Line2") = {2};
Physical Curve("Line3") = {3};
Physical Curve("Line4") = {4};
Physical Surface("Surface1") = {1};
