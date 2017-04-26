void setup() {
  size(1050, 100);
  background(0);
  smooth();
  noLoop();
  noFill();
}

void draw() {
  for (int i = 0; i < 10; i++) {
    drawWaveSegment(50 + i * 100, 50, 50);
  }
  save("arc_wave.png");
}

void drawWaveSegment(float x, float y, float wh) {
  stroke(255);
  arc(x, y, wh, wh, -PI, 0);
  stroke(255);
  arc(x + wh, y, wh, wh, 0, PI);
}