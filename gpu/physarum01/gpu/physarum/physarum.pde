
PGraphics fieldGr;
PShader fieldShader;
PImage fieldImage;
PGraphics depositGr;

PGraphics particlesGr;
PShader particlesShader;
PImage particlesImage;

int nbParticles = 2000;

float floatingPrecision = 10000.0f;

void setup() {
  size(500, 500, P2D);
  frameRate(50);

  fieldImage = createImage(width, height, RGB);
  fieldImage.loadPixels();
  for (int i=0; i<fieldImage.pixels.length; i++) fieldImage.pixels[i] = color(random(0x100));
  fieldImage.updatePixels();

  depositGr = createGraphics(width, height, P2D);
  depositGr.beginDraw();
  depositGr.background(0);
  depositGr.endDraw();

  fieldGr = createGraphics(fieldImage.width, fieldImage.height, P2D);
  fieldGr.noSmooth();
  fieldShader = loadShader("field.glsl");
  fieldShader.set("nPX", (float)width);
  fieldShader.set("nPY", (float)height);
  fieldGr.shader(fieldShader);

  particlesImage = createImage(nbParticles, 3, RGB);
  particlesImage.loadPixels();
  for (int i=0; i<nbParticles; i++) {
    particlesImage.pixels[nbParticles*0+i] = floatToColor(floor(random(width)));// x
    particlesImage.pixels[nbParticles*1+i] = floatToColor(floor(random(height)));// y
    particlesImage.pixels[nbParticles*2+i] = floatToColor(random(TWO_PI));// a
  }
  particlesImage.updatePixels();

  particlesGr = createGraphics(particlesImage.width, particlesImage.height, P2D);
  particlesGr.noSmooth();
  particlesShader = loadShader("particles.glsl");
  particlesShader.set("floatingPrecision", (float)floatingPrecision);
  particlesShader.set("foresee", (float)15.0f);
  particlesShader.set("angleLerp", (float)0.2f);
  particlesShader.set("speed", (float)1.5f);
  particlesShader.set("resolution", float(particlesGr.width), float(particlesGr.height));
  particlesShader.set("width", width);
  particlesShader.set("height", height);
  particlesGr.shader(particlesShader);
}

void draw() {

  background(0);

  fieldShader.set("deposit", depositGr.get());
  fieldGr.beginDraw();
  fieldGr.image(fieldImage, 0, 0);
  fieldGr.endDraw();
  fieldImage = fieldGr.get();

  particlesShader.set("field", fieldImage);
  particlesShader.set("previousPixels", particlesImage);
  particlesGr.beginDraw();
  particlesGr.image(particlesImage, 0, 0);
  particlesGr.endDraw();
  particlesImage = particlesGr.get();

  depositGr.beginDraw();
  depositGr.background(0);
  depositGr.noStroke();
  for (int i=0; i<particlesImage.width; i++) {
    depositGr.fill(0x80);
    float valueX = colorToFloat(particlesImage.get(i, 0));
    float valueY = colorToFloat(particlesImage.get(i, 1));
    depositGr.ellipse(valueX, valueY, 2, 2);
  }
  depositGr.endDraw();
  
  image(fieldGr, 0, 0);
  blend(depositGr.get(), 0, 0, width, height, 0, 0, width, height, ADD);

  
}

float colorToFloat(color c) {  
  return ((float)red(c) + (float)green(c) * 256.0f + (float)blue(c) * 256.0f * 256.0f) / floatingPrecision;
}

color floatToColor(float f) {
  f *= floatingPrecision;
  int a = 255;
  int b = floor((f) / (256.0f * 256.0f));
  int g = floor((f- b * 256.0f * 256.0f) / (256.0f));
  int r = floor((f- b * 256.0f * 256.0f - g * 256.0f));
  color c = color(r, g, b, a);
  return c;
}

void mousePressed() {
  randomizeParameters();
}

void randomizeParameters() {
  float f = (float)random(random(random(0, 100)));
  float a = (float)random(random(0, HALF_PI));
  float s = (float)random(0.05, 5.0);
  // println(f+" "+a+" "+s);
  particlesShader.set("foresee", f);
  particlesShader.set("angleLerp", a);
  particlesShader.set("speed", s);
}

int lastMillis = 0;
void benchmark(String label) {
  println(millis()-lastMillis+" : "+label);
  lastMillis = millis();
}
