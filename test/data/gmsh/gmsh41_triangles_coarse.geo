G=0.25;

Point(1) = {0.0, 0.0, 0, G};
Point(2) = {1.0, 0.0, 0, G};
Point(3) = {1.0, 1.0, 0, G};
Point(4) = {0.0, 1.0, 0, G};

Line(1) = {1, 2};
Line(2) = {2, 3};
Line(3) = {3, 4};
Line(4) = {4, 1};

Curve Loop(1) = {1, 2, 3, 4};
Plane Surface(1) = {1};

Physical Point("Point 1") = {1};
Physical Point("Point 2") = {2};
Physical Point("Point 3") = {3};
Physical Point("Point 4") = {4};

Physical Curve("Curve 1") = {1};
Physical Curve("Curve 2") = {2};
Physical Curve("Curve 3") = {3};
Physical Curve("Curve 4") = {4};

Physical Surface("Surface 1") = {1};
