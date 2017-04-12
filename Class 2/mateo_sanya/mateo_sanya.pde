PImage img;

void setup() {
  // Images must be in the "data" directory to load correctly
  img = loadImage("My Mark 2.jpg");
}

void draw() {
  image(img, 0, 0);
}