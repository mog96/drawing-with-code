float cpBoundingBoxWidth = 100;
float cpBoundingBoxHeight = 100;
float endpointBoundingBoxDefaultWidth = 100;
float endpointBoundingBoxDefaultHeight = 100;
float traveledByMouseThreshold = 10;
float traveledByMouseBaseStepSize = 15;

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
float endpointBoundingBoxWidth = endpointBoundingBoxDefaultWidth;
float endpointBoundingBoxHeight = endpointBoundingBoxDefaultHeight;
ArrayList<Curve> curves;

void setup() {
  curves = new ArrayList<Curve>();
  // fullScreen();
  size(500, 500);
  background(255);
  smooth();
  // noFill();
}

void draw() {  
  // background(255);
  for (int i = 0; i < curves.size(); i++) {    
    drawCurve(curves.get(i));
  }
}

void mouseMoved() {
  if (traveledByMouse >= traveledByMouseThreshold) {
    addCurve();
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

void addCurve() {
  Curve newCurve = new Curve();
  if (!curves.isEmpty()) {
    newCurve.startPoint = curves.get(curves.size() - 1).endPoint;
  } else {
    newCurve.startPoint = new Point(float(mouseX), float(mouseY));
  }
  newCurve.cp1 = getRandomPoint(newCurve.startPoint.x, newCurve.startPoint.y, cpBoundingBoxWidth, cpBoundingBoxHeight);
  newCurve.endPoint = getRandomPoint(mouseX, mouseY, endpointBoundingBoxWidth, endpointBoundingBoxHeight);
  newCurve.cp2 = getRandomPoint(newCurve.endPoint.x, newCurve.endPoint.y, cpBoundingBoxWidth, cpBoundingBoxHeight);
  curves.add(newCurve);
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