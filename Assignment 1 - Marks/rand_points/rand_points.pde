void setup() {
  size(180, 180);
  background(0);
  noLoop();
}

void draw() {
  for (int i = 0; i < 300; i++) {
    drawRandomPoint();
  }
  save("rand_points.png");
}

void drawRandomPoint() {
  float randomX = random(0, 1) * width;
  float randomY = random(0, 1) * height;
  point(randomX, randomY);
  stroke(255);
}