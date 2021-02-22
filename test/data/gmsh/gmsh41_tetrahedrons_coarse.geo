G=0.25;

Point(1) = {0.0, 0.0, 0.0, G};
Point(2) = {1.0, 0.0, 0.0, G};
Point(3) = {1.0, 1.0, 0.0, G};
Point(4) = {0.0, 1.0, 0.0, G};
Point(5) = {0.0, 0.0, 1.0, G};
Point(6) = {1.0, 0.0, 1.0, G};
Point(7) = {1.0, 1.0, 1.0, G};
Point(8) = {0.0, 1.0, 1.0, G};

Line(1) = {1, 2};
Line(2) = {2, 3};
Line(3) = {3, 4};
Line(4) = {4, 1};
Line(5) = {5, 6};
Line(6) = {6, 7};
Line(7) = {7, 8};
Line(8) = {8, 5};
Line(9) = {1, 5};
Line(10) = {2, 6};
Line(11) = {3, 7};
Line(12) = {4, 8};

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

Surface Loop(1) = {5, 1, 3, 4, 2, 6};
Volume(1) = {1};

Physical Point("Point1") = {1};
Physical Point("Point2") = {2};
Physical Point("Point3") = {3};
Physical Point("Point4") = {4};
Physical Point("Point5") = {5};
Physical Point("Point6") = {6};
Physical Point("Point7") = {7};
Physical Point("Point8") = {8};

Physical Curve("Curve1") = {1};
Physical Curve("Curve2") = {2};
Physical Curve("Curve3") = {3};
Physical Curve("Curve4") = {4};
Physical Curve("Curve5") = {5};
Physical Curve("Curve6") = {6};
Physical Curve("Curve7") = {7};
Physical Curve("Curve8") = {8};
Physical Curve("Curve9") = {9};
Physical Curve("Curve10") = {10};
Physical Curve("Curve11") = {11};
Physical Curve("Curve12") = {12};

Physical Surface("Surface1") = {1};
Physical Surface("Surface2") = {2};
Physical Surface("Surface3") = {3};
Physical Surface("Surface4") = {4};
Physical Surface("Surface5") = {5};
Physical Surface("Surface6") = {6};

Physical Volume("Volume1") = {1};
