import processing.pdf.*;

float kCPBoundingBoxWidth = 100;
float kCPBoundingBoxHeight = 100;
float kEndpointBoundingBoxDefaultWidth = 100;
float kEndpointBoundingBoxDefaultHeight = 100;
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
    newCurve.endPoint = getRandomPoint(newCurve.startPoint.x, newCurve.startPoint.y, endpointBoundingBoxWidth * 2, endpointBoundingBoxHeight * 2);
    newCurve.cp1 = getRandomPoint(newCurve.endPoint.x, newCurve.endPoint.y, kCPBoundingBoxWidth, kCPBoundingBoxHeight);
    newCurve.cp2 = getRandomPoint(newCurve.startPoint.x, newCurve.startPoint.y, kCPBoundingBoxWidth, kCPBoundingBoxHeight);
    curves.add(newCurve);
    
    println("NEW END POINT:", newCurve.endPoint.x, newCurve.endPoint.y);
    
    return;
  }
  
  Curve lastCurve = curves.get(curves.size() - 1);
  newCurve.startPoint = lastCurve.endPoint;
  
  // Make sure endpoint doesn't cause new curve to overlap existing curves. 
  do {
    newCurve.endPoint = getRandomPoint(max(0, lastCurve.endPoint.x - endpointBoundingBoxWidth / 2),
                                     max(0, lastCurve.endPoint.y - endpointBoundingBoxHeight / 2), endpointBoundingBoxWidth, endpointBoundingBoxHeight);
  } while (intersectsExistingCurves(newCurve)); // NOTE: This check takes O(N) time, where N is number of curves.
  
  // First control point the of new curve is the reflection of the second control point of the old curve,
  // across the line that passes through the endpoint of the old curve perpendicular to the line between the
  // control points in question.
  newCurve.cp1 = new Point(lastCurve.endPoint.x + (lastCurve.endPoint.x - lastCurve.cp2.x),
                           lastCurve.endPoint.y + (lastCurve.endPoint.y - lastCurve.cp2.y));
  
  newCurve.cp2 = getRandomPoint(newCurve.endPoint.x, newCurve.endPoint.y, kCPBoundingBoxWidth, kCPBoundingBoxHeight);
  curves.add(newCurve);
  
  println("NEW END POINT:", newCurve.endPoint.x, newCurve.endPoint.y);
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
  
  println("SHOULD HAVE DRAWN");
}

Point getRandomPoint(float originX, float originY, float boundingBoxWidth, float boundingBoxHeight) {
  float xMin = max(0, originX - boundingBoxWidth / 2);
  float xMax = min(xMin + boundingBoxWidth, width);
  float x = random(xMin, xMax);
  float yMin = max(0, originY - boundingBoxHeight / 2);
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
boolean endpointLinesIntersect(Curve curve1, Curve curve2) {
  return (hasClockwiseOrientation(curve1.startPoint, curve1.endPoint, curve2.startPoint)
          != hasClockwiseOrientation(curve1.startPoint, curve1.endPoint, curve2.endPoint))
         && (hasClockwiseOrientation(curve2.startPoint, curve2.endPoint, curve1.startPoint)
             != hasClockwiseOrientation(curve2.startPoint, curve2.endPoint, curve1.endPoint));
}

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