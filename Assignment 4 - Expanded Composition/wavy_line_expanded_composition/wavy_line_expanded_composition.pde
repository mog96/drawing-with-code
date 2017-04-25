import processing.pdf.*;

float kCPBoundingBoxWidth = 100;
float kCPBoundingBoxHeight = 100;
float kEndpointBoundingBoxDefaultWidth = 100;
float kEndpointBoundingBoxDefaultHeight = 100;
float kTraveledByMouseThreshold = 10;
float kTraveledByMouseBaseStepSize = 15;

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
  size(500, 500);
  background(255);
  smooth();
}

void draw() {}

void mouseMoved() {  
  if (traveledByMouse >= kTraveledByMouseThreshold) {
    addCurve();
    traveledByMouse = 0;
    background(255);
    
    beginRecord(PDF, "wavy-line.pdf");
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

void addCurve() {
  
  println("NEW CURVE");
  
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
  newCurve.endPoint = getRandomPoint(lastCurve.endPoint.x, lastCurve.endPoint.y, endpointBoundingBoxWidth, endpointBoundingBoxHeight);
  newCurve.cp1 = lastCurve.cp2;
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
  fill(255, 105, 180);
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

void keyPressed() {
  if (key == ESC) {
    saveFrame("wavy-line-######.tif");
    // endRecord();
  }
}