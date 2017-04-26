/**
ARTSTUDI 163: Drawing with Code
06 April 12 homework - Expanded Composition - due April 17

Add a rule into your Processing sketch/system that creates a “second order”
or “emergent” type mark or behavior that is not obvious based on the rule
you develop. If you are getting tired of your current composition, please
feel free to build up something new, but it should have all the richness
of your current sketch!

-----

Author: Mateo Garcia
Date Submitted: 2017-04-25
Description:

In this version of my 'wavy-line' program, the mouse no longer controls
the direction of the line, making the general composition of the
resulting work 'emergent'. However, movement of the mouse is still required
to generate the line. Its speed still controls the distance between the
endpoints of the Catmul-Rom spline curves that comprise the line.

Also new in this version the is code in the 'Preventing Intersecting Lines'
section, which comprises a failed attempt at preventing new curves added to
the line from intersecting with the curves that already comprise the line.
My approach was to check each proposed new curve for whether it intersects
with any other curve in the line, using the algorithm explained in the
comments above each function in the 'Preventing Intersecting Lines' section.

Lastly, as can be seen in the 'wavy-line' numbered 7 and up, this version
noe shifts the center of the bounding bowx for the random endpoint of a new
curve in the projected direction of the previous curve's endpoints. This
reduces the randomness of new curves added to the line, as well as their
abruptness.

*/

import processing.pdf.*;

float kCPBoundingBoxWidth = 100;
float kCPBoundingBoxHeight = 100;
float kEndpointBoundingBoxDefaultWidth = 100;
float kEndpointBoundingBoxDefaultHeight = 100;
// Multiplies x and y distances between endpoints of last curve to determine center of bounding box of new curve random endpoint.
float kEndpointBoundingBoxCenterShiftMultiplier = 0.6;
float kTraveledByMouseThreshold = 20;
float kTraveledByMouseBaseStepSize = 25;

public class Point {
  public float x;
  public float y;
  
  public Point() {
  }
  
  public Point(float x, float y) {
    this.x = x;
    this.y = y;
  }
}

// Represents a curve by storing its start and end points,
// as well as its two control points.
public class Curve {
  public Point startPoint;
  public Point endPoint;
  public Point cp1;
  public Point cp2;
}

float traveledByMouse = 0;
float endpointBoundingBoxWidth = kEndpointBoundingBoxDefaultWidth;
float endpointBoundingBoxHeight = kEndpointBoundingBoxDefaultHeight;
ArrayList<Curve> curves;

void setup() {
  curves = new ArrayList<Curve>();
  size(700, 700);
  background(255);
  smooth();
}

void draw() {}

void mouseMoved() {  
  if (traveledByMouse >= kTraveledByMouseThreshold) {
    addCurve();
    traveledByMouse = 0;
    background(255);
    
    beginRecord(PDF, "wavy-line.pdf");          // NOTE: MUST RENAME SAVED PDF TO AVOID IT BEING OVERWRITTEN BY FUTURE PROGRAM EXECUTION
    for (int i = 0; i < curves.size(); i++) {    
      drawCurve(curves.get(i));
    }
    endRecord();
  }
  
  // Bounding box of random endpoint is larger if cursor is moving faster.
  // This makes curves larger when cursor speed is faster.
  endpointBoundingBoxWidth = kEndpointBoundingBoxDefaultWidth;
  endpointBoundingBoxHeight = kEndpointBoundingBoxDefaultHeight;
  float traveled = dist(pmouseX, pmouseY, mouseX, mouseY);
  float boundMultiplier = .5 + (traveled / kTraveledByMouseBaseStepSize) / 2;
  endpointBoundingBoxWidth = kEndpointBoundingBoxDefaultWidth * boundMultiplier;
  endpointBoundingBoxHeight = kEndpointBoundingBoxDefaultHeight * boundMultiplier;
    
  traveledByMouse += traveled;
}


// MARK: - Create Curve

void addCurve() {  
  Curve newCurve = new Curve();
  
  if (curves.isEmpty()) {
    newCurve.startPoint = getRandomPoint(0, 0, width, height);
    newCurve.endPoint = getRandomPoint(max(0, newCurve.startPoint.x - endpointBoundingBoxWidth / 2),
                                     max(0, newCurve.startPoint.y - endpointBoundingBoxHeight / 2),
                                     endpointBoundingBoxWidth,
                                     endpointBoundingBoxHeight);
    newCurve.cp1 = getRandomPoint(newCurve.endPoint.x, newCurve.endPoint.y, kCPBoundingBoxWidth, kCPBoundingBoxHeight);
    newCurve.cp2 = getRandomPoint(newCurve.startPoint.x, newCurve.startPoint.y, kCPBoundingBoxWidth, kCPBoundingBoxHeight);
    curves.add(newCurve);
    
    println("NEW END POINT:", newCurve.endPoint.x, newCurve.endPoint.y);
    
    return;
  }
  
  Curve lastCurve = curves.get(curves.size() - 1);
  
  newCurve.startPoint = lastCurve.endPoint;
  
  // Center of bounding box for random endpoint is shifted in the direction of the preceding curve,
  // to help direct the line and reduce the abruptness of change in direction.
  newCurve.endPoint = getRandomPoint(min(max(0, newCurve.startPoint.x + kEndpointBoundingBoxCenterShiftMultiplier * (newCurve.startPoint.x - lastCurve.startPoint.x)), width),
                                     min(max(0, newCurve.startPoint.y + kEndpointBoundingBoxCenterShiftMultiplier * (newCurve.startPoint.y - lastCurve.startPoint.y)), height),
                                     endpointBoundingBoxWidth,
                                     endpointBoundingBoxHeight);
  
  
  println("ENDPOINT:", newCurve.endPoint.x, newCurve.endPoint.y);   
  
  // TODO: Make sure endpoint doesn't cause new curve to overlap existing curves. (As is, this code takes too long to execute.) 
  /*
  do {
    newCurve.endPoint = getRandomPoint(max(0, lastCurve.endPoint.x - endpointBoundingBoxWidth / 2),
                                     max(0, lastCurve.endPoint.y - endpointBoundingBoxHeight / 2), endpointBoundingBoxWidth, endpointBoundingBoxHeight);
  } while (intersectsExistingCurves(newCurve)); // NOTE: This check takes O(N) time, where N is number of curves.
  */
  
  // First control point the of new curve is the reflection of the second control point of the old curve,
  // across the line that passes through the endpoint of the old curve perpendicular to the line between the
  // control points in question.
  newCurve.cp1 = new Point(lastCurve.endPoint.x + (lastCurve.endPoint.x - lastCurve.cp2.x),
                           lastCurve.endPoint.y + (lastCurve.endPoint.y - lastCurve.cp2.y));
  
  newCurve.cp2 = getRandomPoint(newCurve.endPoint.x, newCurve.endPoint.y, kCPBoundingBoxWidth, kCPBoundingBoxHeight);
  curves.add(newCurve);  
}

void drawCurve(Curve curve) {
  stroke(0);
  curve(curve.cp1.x, curve.cp1.y,
        curve.startPoint.x, curve.startPoint.y,
        curve.endPoint.x, curve.endPoint.y,
        curve.cp2.x, curve.cp2.y);
  // fill(255, 105, 180); // Pink
  fill(83, 145, 234); 
  ellipse(curve.cp1.x, curve.cp1.y, 2, 2);
  ellipse(curve.cp2.x, curve.cp2.y, 2, 2);  
}

Point getRandomPoint(float centerX, float centerY, float boundingBoxWidth, float boundingBoxHeight) {
  float xMin = max(0, centerX - boundingBoxWidth / 2);
  float xMax = min(xMin + boundingBoxWidth, width);
  float x = random(xMin, xMax);
  float yMin = max(0, centerY - boundingBoxHeight / 2);
  float yMax = min(yMin + boundingBoxHeight, height);
  float y = random(yMin, yMax);
  
  Point point = new Point();
  point.x = x;
  point.y = y;
  return point;
}


// MARK: - Preventing Intersecting Lines

// Checks whether the direct line beteween the start and end points of CURVE will intersect
// the direct line beteween the start and end points of any existing curves.
boolean intersectsExistingCurves(Curve curve) {
  for (int i = 0; i < curves.size(); i++) {
    if (endpointLinesIntersect(curve, curves.get(i))) {
      return false;
    }
  }
  return true;
}

// As demonstrated below, two lines intersect if:
//
//        q1
//   p2  /
//     \/
//     /\
//    /  \
// p1     \
//         q2
//
// - (p1, q1, p2) and (p1, q1, q2) have different orientations AND
// - (p2, q2, p1) and (p2, q2, q1) have different orientations.
//
// Source: http://www.geeksforgeeks.org/orientation-3-ordered-points/
boolean endpointLinesIntersect(Curve curve1, Curve curve2) {
  return (hasClockwiseOrientation(curve1.startPoint, curve1.endPoint, curve2.startPoint)
          != hasClockwiseOrientation(curve1.startPoint, curve1.endPoint, curve2.endPoint))
         && (hasClockwiseOrientation(curve2.startPoint, curve2.endPoint, curve1.startPoint)
             != hasClockwiseOrientation(curve2.startPoint, curve2.endPoint, curve1.endPoint));
}

// Algorithm found at the below link, on slide 10:
// http://www.dcs.gla.ac.uk/~pat/52233/slides/Geometry1x1.pdf
boolean hasClockwiseOrientation(Point p1, Point p2, Point p3) {
  return (p2.y - p1.y) * (p3.x - p2.x) - (p2.x - p1.x) * (p3.y - p2.y) > 0;
}


// MARK: - Key Press Detection

void keyPressed() {
  if (key == ESC) {
    saveFrame("wavy-line-######.tif");
    // endRecord();
  }
}