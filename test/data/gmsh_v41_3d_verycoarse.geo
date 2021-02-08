g=2;

Point(0) = {0,0,0,g};
Point(1) = {1,0,0,g};
Point(2) = {1,1,0,g};
Point(3) = {0,1,0,g};
Point(4) = {0,0,1,g};
Point(5) = {1,0,1,g};
Point(6) = {1,1,1,g};
Point(7) = {0,1,1,g};

Line(1) = {0, 1};
Line(2) = {1, 2};
Line(3) = {2, 3};
Line(4) = {3, 0};

Line(5) = {4, 5};
Line(6) = {5, 6};
Line(7) = {6, 7};
Line(8) = {7, 4};

Line(9) = {0, 4};
Line(10) = {1, 5};
Line(11) = {2, 6};
Line(12) = {3, 7};

Curve Loop(1) = {1, 2, 3, 4};
Plane Surface(1) = {1};
Curve Loop(2) = {5, 6, 7, 8};
Plane Surface(2) = {2};
Curve Loop(3) = {1, 10, -5, -9};
Plane Surface(3) = {3};
Curve Loop(4) = {2, 11, -6, -10};
Plane Surface(4) = {4};
Curve Loop(5) = {3, 12, -7, -11};
Plane Surface(5) = {5};
Curve Loop(6) = {4, 9, -8, -12};
Plane Surface(6) = {6};

Surface Loop(1) = {2, 3, 1, 4, 5, 6};
Volume(1) = {1};

Physical Point("Point0") = {0};
Physical Point("Point1") = {1};
Physical Point("Point2") = {2};
Physical Point("Point3") = {3};
Physical Point("Point4") = {4};
Physical Point("Point5") = {5};
Physical Point("Point6") = {6};
Physical Point("Point7") = {7};

Physical Curve("Line1") = {1};
Physical Curve("Line2") = {2};
Physical Curve("Line3") = {3};
Physical Curve("Line4") = {4};
Physical Curve("Line5") = {5};
Physical Curve("Line6") = {6};
Physical Curve("Line7") = {7};
Physical Curve("Line8") = {8};
Physical Curve("Line9") = {9};
Physical Curve("Line10") = {10};
Physical Curve("Line11") = {11};
Physical Curve("Line12") = {12};

Physical Surface("Surface1") = {1};
Physical Surface("Surface2") = {2};
Physical Surface("Surface3") = {3};
Physical Surface("Surface4") = {4};
Physical Surface("Surface5") = {5};
Physical Surface("Surface6") = {6};

Physical Volume("Volume1") = {1};
