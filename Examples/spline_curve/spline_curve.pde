void setup() {
  size(200, 200);
  background(255);
  smooth();
  stroke(0);
  
  float cpx1 = 80;
  float cpy1 = 7;
  float cpx2 = 0;
  float cpy2 = 120;
  curve(cpx1, cpy1, 80, 60, 100, 100, cpx2, cpy2);
  
  noStroke();
  fill(255, 0, 0);
  ellipse(cpx1, cpy1, 3, 3);
  fill(0, 0, 255, 192);
  ellipse(100, 100, 3, 3);
  ellipse(80, 60, 3, 3);
  fill(255, 0, 0);
  ellipse(cpx2, cpy2, 3, 3);  
}