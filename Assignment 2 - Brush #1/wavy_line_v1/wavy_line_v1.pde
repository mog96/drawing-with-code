float cpBoundingBoxWidth = 100;
float cpBoundingBoxHeight = 100;
float endpointBoundingBoxDefaultWidth = 100;
float endpointBoundingBoxDefaultHeight = 100;
float traveledByMouseThreshold = 10;
float traveledByMouseBaseStepSize = 15;

public class Point {
  public float x;
  public float y;
}

Point curveStartPoint;
float traveledByMouse = 0;
float endpointBoundingBoxWidth = endpointBoundingBoxDefaultWidth;
float endpointBoundingBoxHeight = endpointBoundingBoxDefaultHeight;

void setup() {
  curveStartPoint = new Point();
  fullScreen();
  // size(500, 500);
  background(255);
  smooth();
  // noFill();
}

void draw() {
}

void mouseMoved() {
  if (traveledByMouse >= traveledByMouseThreshold) {
    drawCurve();
    traveledByMouse = 0;
  }
  endpointBoundingBoxWidth = endpointBoundingBoxDefaultWidth;
  endpointBoundingBoxHeight = endpointBoundingBoxDefaultHeight;
  
  // Bounding box of random endpoint is larger if cursor is moving faster.
  // This makes curves larger when cursor speed is faster.
  float traveled = dist(pmouseX, pmouseY, mouseX, mouseY);
  float boundMultiplier = .5 + (traveled / traveledByMouseBaseStepSize) / 2;
  endpointBoundingBoxWidth = endpointBoundingBoxDefaultWidth * boundMultiplier;
  endpointBoundingBoxHeight = endpointBoundingBoxDefaultHeight * boundMultiplier;
  
  println(traveled);
  
  traveledByMouse += traveled;
}

void drawCurve() {
  Point startPoint = curveStartPoint;
  Point cp1 = getRandomPoint(startPoint.x, startPoint.y, cpBoundingBoxWidth, cpBoundingBoxHeight);
  Point endPoint = getRandomPoint(mouseX, mouseY, endpointBoundingBoxWidth, endpointBoundingBoxHeight);
  Point cp2 = getRandomPoint(endPoint.x, endPoint.y, cpBoundingBoxWidth, cpBoundingBoxHeight);
  
  stroke(0);
  curve(cp1.x, cp1.y, startPoint.x, startPoint.y, endPoint.x, endPoint.y, cp2.x, cp2.y);
  fill(255, 105, 180);
  ellipse(cp1.x, cp1.y, 2, 2);
  ellipse(cp2.x, cp2.y, 2, 2);
  
  curveStartPoint = endPoint;
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