import codeanticode.syphon.*;
import oscP5.*;
import java.io.File;

PImage heartImg;

PGraphics uglyMan;
int bodySum = 2;
int faceSetNum = 4;
int stop = 0;
int saved = 0;
PGraphics express;
PImage[] BodyArray = new PImage[bodySum];
PImage[] LeftEyesArray = new PImage[faceSetNum];
PImage[] RightEyesArray = new PImage[faceSetNum];
PImage[] LeftEyebrowsArray = new PImage[faceSetNum];
PImage[] RightEyebrowsArray = new PImage[faceSetNum];
PImage[] UpMouthsArray = new PImage[faceSetNum];
PImage[] DownMouthsArray = new PImage[faceSetNum];
int mouthNum;
int eyeNum;
int bodyNum;
int eyebrowNum;
float mouthHeight, mouthWidth;
float eyeLeft, eyeRight;
float eyebrowLeft, eyebrowRight;

color averageColor;

// for Syphon
PImage frame;
SyphonClient client;
// for OSC
OscP5 oscP5;
// our FaceOSC tracked face data
Face face = new Face();
PGraphics colorImage;

//void settings () {
//  size(720, 480, P3D);
//  PJOGL.profile = 1;
//}

void setup() {
  size(750, 800, P3D);

  for (int i=0; i < faceSetNum; i++) {
    String eyeright = "img/eye"+(i+1)+"right.png";
    String eyeleft = "img/eye"+(i+1)+"left.png";
    String eyebrowright = "img/eyebrow"+(i+1)+"right.png";
    String eyebrowleft = "img/eyebrow"+(i+1)+"left.png";
    String upmouth = "img/mouth"+(i+1)+"up.png";
    String downmouth = "img/mouth"+(i+1)+"down.png";
    String bodyString = "img/body"+(i+1)+"body.png";

    RightEyesArray[i] = loadImage(eyeright);
    LeftEyesArray[i] = loadImage(eyeleft);
    LeftEyebrowsArray[i] = loadImage(eyebrowright);
    RightEyebrowsArray[i] = loadImage(eyebrowleft);
    //if ( i + 1 <= 3 ) {
      UpMouthsArray[i] = loadImage(upmouth);
      DownMouthsArray[i] = loadImage(downmouth);
   // } else {
   //   UpMouthsArray[i] = loadImage("img/mouth"+3+"up.png");
   //   DownMouthsArray[i] = loadImage("img/mouth"+3+"down.png");
    //}

    if (i<=1) {
      BodyArray[i] = loadImage(bodyString);
    }
  }
  mouthNum = (int) random(faceSetNum);
  eyeNum = (int) random(faceSetNum);
  eyebrowNum = (int) random(faceSetNum);
  bodyNum = (int) random(bodySum);
  // create syhpon client to receive frames from FaceOSC
  client = new SyphonClient(this, "FaceOSC");
  // stat listening on OSC
  oscP5 = new OscP5(this, 8338);
}

public void draw() {    

  // grab syphon frame
  if (client.newFrame()) {
    frame = client.getImage(frame, true);
  }

  if (frame != null) {
    if (face.found > 0) {
      colorImage = createGraphics(width, height, JAVA2D);
      colorImage.beginDraw();
      colorImage.image(frame, 0, 0, width, height);
      colorImage.fill(255);
      colorImage.rect(0, 0, 230, 100);
      colorImage.ellipse(face.posePosition.x + 50, face.posePosition.y - 30, 60 * face.poseScale, 80 * face.poseScale);
      colorImage.endDraw();

      averageColor = getAverageColor(colorImage);
      background(averageColor);
    }
  } else {
    background(55);
  }

  if (face.found > 0) {
    if (stop==0) {
      translate(-face.posePosition.x + 500, face.posePosition.y);
      imageMode(CENTER); 
      mouthHeight = face.mouthHeight;
      eyebrowRight = face.eyebrowRight;
      eyebrowLeft = face.eyebrowLeft;
      image(UpMouthsArray[mouthNum], 125, 250 - mouthHeight * 8);
      image(DownMouthsArray[mouthNum], 125, 230 + mouthHeight * 8);
      LeftEyesArray[eyeNum].resize(0, 150);
      image(LeftEyesArray[eyeNum], 0, 70);
      RightEyesArray[eyeNum].resize(0, 150);
      image(RightEyesArray[eyeNum], 250, 70);
      image(RightEyebrowsArray[eyebrowNum], 0, (eyebrowRight- 6) * -20 );
      image(LeftEyebrowsArray[eyebrowNum], 250, (eyebrowLeft - 6) * -20 );
    } else {
      express = createGraphics(width, height);
      express.beginDraw();
      express.imageMode(CENTER); 
      express.image(UpMouthsArray[mouthNum], 225, 350 - mouthHeight * 8);
      express.image(DownMouthsArray[mouthNum], 225, 330 + mouthHeight * 8);
      LeftEyesArray[eyeNum].resize(0, 150);
      express.image(LeftEyesArray[eyeNum], 100, 170);
      RightEyesArray[eyeNum].resize(0, 150);
      express.image(RightEyesArray[eyeNum], 350, 170);
      express.image(RightEyebrowsArray[eyebrowNum], 100, 100 + (eyebrowRight- 6) * -20 );
      express.image(LeftEyebrowsArray[eyebrowNum], 350, 100 + (eyebrowLeft - 6) * -20 );
      express.endDraw();

      if ( saved == 0 ) {

        image(express, 550, 500);
        uglyMan = createGraphics(364, 594);

        uglyMan.beginDraw();
        uglyMan.imageMode(CENTER);
        uglyMan.image(BodyArray[bodyNum], 364/2, 594/2, 364, 594);
        uglyMan.image(express, 230, 150, 225, 240);

        heartImg = loadImage("img/heart.png");
        heartImg.loadPixels();
        int tempr = 0, tempg = 0, tempb = 0;
        for (int i=0; i<heartImg.pixels.length; i++) {
          color c = heartImg.pixels[i];
          tempr = c>>16&0xFF;
          tempg = c>>8&0xFF;
          tempb = c&0xFF;
          if ( tempr + tempg + tempb > 700) {
            heartImg.pixels[i] = averageColor;
          }
        }
        heartImg.updatePixels();
        uglyMan.image(heartImg, 240, 250, 50, 50);
        uglyMan.endDraw();
        uglyMan.save("uglyMan.png");
        String imgname=sketchPath("uglyMan.png");
        File img=sketchFile(imgname);
        if(img.exists()){
          img.delete();
        }
        saved = 1;
      } else {
        image(uglyMan, width/2, height/2);
      }
    }
  }
}

void keyPressed() {
  if ( stop == 0) {
    stop = 1;
  } else {
    saved = 0;
    stop = 0;
    mouthNum = (int) random(faceSetNum);
    eyeNum = (int) random(faceSetNum);
    eyebrowNum = (int) random(faceSetNum);
    bodyNum = (int) random(bodySum);
    //println(bodyNum);
  }
}

// OSC CALLBACK FUNCTIONS
void oscEvent(OscMessage m) {
  face.parseOSC(m);
}

color getAverageColor(PImage img) {
  img.loadPixels();
  int r = 0, g = 0, b = 0;
  int tempr = 0, tempg = 0, tempb = 0;
  int howManyColor = 0;
  for (int i=0; i<img.pixels.length; i++) {
    color c = img.pixels[i];
    tempr = c>>16&0xFF;
    tempg = c>>8&0xFF;
    tempb = c&0xFF;
    //r+= red(img.pixels[i]);
    //g+= green(img.pixels[i]);
    //b+= blue(img.pixels[i]);
    if ( tempr + tempg + tempb < 730) {
      r += tempr;
      g += tempg;
      b += tempb;
      howManyColor += 1;
    }
  }
  r /= howManyColor;
  g /= howManyColor;
  b /= howManyColor;
  return color(r, g, b);
}