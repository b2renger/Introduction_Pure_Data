/*
Ce programme permet d'illustrer la communication entre processing et pure-data via la librairie OSC

Nous allons envoyer les coordonnées des click de souris dans la fenêtre processing, vers pure-data pour
déclencher des notes de musique. Le flux audio stéréo sera analysé en hauteur et intensité dans pure-data et
le résultat de cette analyse est renvoyé vers processing pour animer deux ellipses.

Le rayon de chaque ellipse dépends de l'intensité sonore, sa couleur dépend de la hauteur de la note.
*/


// librairies
import oscP5.*;
import netP5.*;
  
OscP5 oscP5; // objet osc pour envoyer des messages
NetAddress myRemoteLocation; // adresse de l'ordinateur ou programme distant

float huel = 0; // couleur de l'ellipse de gauche
float huer = 0; // couleur de l'ellipse de droite
float radl = 20; // rayon de l'ellipse de gauche
float radr = 20; // rayon de l'ellipse de droite

void setup() {
  size(800,400);
  colorMode(HSB,360,100,100);
  
  // initialiser les objet osc
  oscP5 = new OscP5(this,12000); // en écoute sur le port 12000, pure-data devra donc envoyer sur ce port
  myRemoteLocation = new NetAddress("127.0.0.1",1234); // on envoit en local sur le port 1234, pure-data 
                                                       // devra donc écouter sur ce port
}


void draw() {
  background(0);  
  noStroke();
  fill(huel,100,100);
  ellipse(width/4,height/2,radl,radl);
  fill(huer,100,100);
  ellipse(width*3/4,height/2,radr,radr);
}

void mousePressed() {
  // on crée un nouveau message
  OscMessage myMessage = new OscMessage("/coordinates"); // le préfixe sera coordinates
                                                          // dans pd en écoute il faudra router ce préfixe
  // on ajoute une valeur pouvant être interprété comme une note midi (hauteur et durée)
  myMessage.add(int(map(mouseY,height,0,48,72))); // hauteur midi
  myMessage.add(map(mouseX,0,width,10,300));  // durée en msec
  oscP5.send(myMessage, myRemoteLocation);  // on envoit le message
}


// les messages entrants sont filtrés par cette méthode
void oscEvent(OscMessage theOscMessage) {
 
    if(theOscMessage.checkAddrPattern("/envleft")==true) { // vérifier le préfixe osc
      radl =  theOscMessage.get(0).floatValue()*2;  // assigner la valeur reçue   
    }
    else if (theOscMessage.checkAddrPattern("/pitchleft")==true) {
       huel =  map(theOscMessage.get(0).floatValue(),48,72,0,180);  
    }
    else if(theOscMessage.checkAddrPattern("/envright")==true) {
      radr =  theOscMessage.get(0).floatValue()*2;    
    }
    else if (theOscMessage.checkAddrPattern("/pitchright")==true) {
       huer =  map(theOscMessage.get(0).floatValue(),48,72,0,180);  
    }
}