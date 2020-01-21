function isInFront = isTriangleInFrontOfTriangle(t1, t2, strict)
%ISTRIANGLEINFRONTOFTRIANGLE Check if any point of t1 is in the positive
%half-plane described by triangle t2 and its normal vector.
%
% SEE ALSO: SIGNEDDISTANCEOFPOINTFROMPLANE
points = [t1(1:3);...
    t1(4:6);...
    t1(7:9)];
plane = t2(10:13);

dist = signedDistanceOfPointFromPlane(points, plane);
if strict
    isInFront = any(dist > 0);
else
    isInFront = any(dist >= 0);
end

end