/*
Pour que ce sketch fonctionne vous avez besoin des bibliothèques :
 - openCV
 - video (processing foundation)
 - sound (processing foundation)
 - oscP5
 
 Ce sketch permet de récupérer différents types de valeur depuis la webcam, le micro et les input clavier souris 
 et de les envoyer via osc (en local ou à un ordinateur distant)
 
 */



import gab.opencv.*;
import processing.video.*;
import oscP5.*;
import netP5.*;
import processing.sound.*;


OscP5 oscP5;
NetAddress myRemoteLocation;

Capture cam;
OpenCV opencvMov;

AudioIn input;
Amplitude rms;


void setup() {
  size(320, 240);
  frameRate(25);


  String[] cameras = Capture.list();

  if (cameras == null) {
    println("Failed to retrieve the list of available cameras, will try the default...");
    cam = new Capture(this, 320, 240);
  } 
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    printArray(cameras);
    cam = new Capture(this, cameras[0]);
    cam.start();
  }

  opencvMov = new OpenCV(this, 320, 240);

  input = new AudioIn(this, 0);
  input.start();
  rms = new Amplitude(this);
  rms.input(input);



  oscP5 = new OscP5(this, 1234);
  myRemoteLocation = new NetAddress("127.0.0.1", 12000); // pensez à changer l'ip !
}

void draw() {
  if (cam.available() == true) {
    cam.read();

    cam.loadPixels();
    float sum = 0;
    for (int i = 0; i <cam.pixels.length; i++) {
      sum += brightness(cam.pixels[i]);
    }
    float light = sum / cam.pixels.length;
    sendOscMessage("/light", light);
    println("light", light);


    opencvMov.loadImage(cam);
    opencvMov.calculateOpticalFlow();
    PVector aveFlow = opencvMov.getAverageFlow();
    float movement = (abs(aveFlow.x)+abs(aveFlow.y))/2;
    sendOscMessage("/movement", movement);
    println("movement", movement);
  }

  float vol = rms.analyze();
  sendOscMessage("/vol", vol);
  println("volume", vol);



  sendOscMessage("/mouseX", mouseX/width);
  sendOscMessage("/mouseY", mouseY/height);
}

void keyPressed() {
  if (key == 'a'|| key =='A') sendOscMessage("/a", random(5));  
  if (key == 'z'|| key =='Z') sendOscMessage("/z", random(5));  
  if (key == 'e'|| key =='E') sendOscMessage("/e", random(5));  
  if (key == 'r'|| key =='R') sendOscMessage("/r", random(5));
}


void sendOscMessage(String id, float value) {
  OscMessage myMessage = new OscMessage(id);
  myMessage.add(value); 
  oscP5.send(myMessage, myRemoteLocation);
}