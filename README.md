# coordinate-algorithm

## Handwerker_TCS.m <br>
Creates the technical coordinate system (TCS) based on 
 rigid body markers in specified order. Right-hand-rule nomenclature is
 used to determine vector coordinates in XYZ. i j k are unit vectors and
 then creates orthonormal right hand coordinate systems.

## Handwerker_ACS.m <br>
Creates an anatomical coordinate system (ACS) based on
 anatomical markers on the iliac crests, left and right greater
 trochanter, medial and lateral femoral epicondyles, medial and lateral
 malleolus, first and fifth metatarsals.
 
 The combination of these functions, plus filtering parameters, is used to
 track joint angles in the hip, knee, and ankle based on raw marker coordinates from high-speed
 cameras. 
