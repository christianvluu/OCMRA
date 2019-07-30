import de.voidplus.leapmotion.*;
import processing.serial.*;

// ======================================================
// Table of Contents:
// ├─ 1. Callbacks
// ├─ 2. Hand
// ├─ 3. Arms
// ├─ 4. Fingers
// ├─ 5. Bones
// ├─ 6. Tools
// └─ 7. Devices
// ======================================================


LeapMotion leap;
Serial geekduino;

//to be more accurate, create these max/min values by recording init position then addint half of difference
int LM_MAX_Y = 400; //foward center
int LM_MIN_Y = 0; //reverse center
int LM_MAX_X = 650; //right center
int LM_MIN_X = 150; //left center
int LM_MAX_Z = 450; //low center
int LM_MIN_Z = 50; //high center

int IK_MAX_X = 150;
int IK_MIN_X = -150;
int IK_MAX_Y = 150;
int IK_MIN_Y = 50;
int IK_MAX_Z = 130;
int IK_MIN_Z = 20;
int IK_MAX_GA = 5;
int IK_MIN_GA = -70;

int initX;
int initY;
int initZ;
boolean isLive = false;

int centeredX;
int centeredY;
int centeredZ;

ArrayList <String> coordinate = new ArrayList<String>();
boolean needSave = false;
boolean toPlay = false;



void setup() {
  size(800, 500);
  background(255);
  String portName = Serial.list()[8]; //port of geekduino board
  println(portName); //check which board is correct in console
  geekduino = new Serial(this, portName, 115200);


  /* draw straight line
   while (true) {
   for (int x = -100; x < 100; x += 1) {
   JSONObject json = new JSONObject();
   json.setInt("x", x);
   json.setInt("y", 200);
   json.setInt("z", 100);
   
   geekduino.write(json.toString() + '!'); //! used as end point
   delay(10);
   }
   for (int x = 100; x > -100; x -= 1) {
   JSONObject json = new JSONObject();
   json.setInt("x", x);
   json.setInt("y", 200);
   json.setInt("z", 100);
   
   geekduino.write(json.toString() + '!'); //! used as end point
   delay(10);
   }
   }
   */

  leap = new LeapMotion(this);
}


// ======================================================
// 1. Callbacks

void leapOnInit() {
  // println("Leap Motion Init");
}
void leapOnConnect() {
  // println("Leap Motion Connect");
}
void leapOnFrame() {
  // println("Leap Motion Frame");
}
void leapOnDisconnect() {
  // println("Leap Motion Disconnect");
}
void leapOnExit() {
  // println("Leap Motion Exit");
}

Hand left;
Hand right;


void draw() {
  background(255);
  // ...


  /*Hand temp = leap.getHand(0);
   
   
   //println("right? ", temp.isRight());
   
   if (temp != null){
   if (temp.isLeft()){
   left = temp;
   int     leftHandId             = left.getId();
   PVector leftPosition       = left.getPosition();
   PVector leftStabilized     = left.getStabilizedPosition();
   PVector leftDirection      = left.getDirection();
   PVector leftDynamics       = left.getDynamics();
   float   leftRoll           = left.getRoll();
   float   leftPitch          = left.getPitch();
   float   leftYaw            = left.getYaw();
   boolean leftIsLeft         = left.isLeft();
   boolean leftIsRight        = left.isRight();
   float   leftGrab           = left.getGrabStrength();
   float   leftPinch          = left.getPinchStrength();
   float   leftTime           = left.getTimeVisible();
   PVector leftSpherePosition = left.getSpherePosition();
   float   leftSphereRadius   = left.getSphereRadius();
   }
   
   else if (temp.isRight()){
   right = temp;
   int     rightHandId             = right.getId();
   PVector rightPosition       = right.getPosition();
   PVector rightStabilized     = right.getStabilizedPosition();
   PVector rightDirection      = right.getDirection();
   PVector rightDynamics       = right.getDynamics();
   float   rightRoll           = right.getRoll();
   float   rightPitch          = right.getPitch();
   float   rightYaw            = right.getYaw();
   boolean rightIsright        = right.isLeft();
   boolean rightIsRight        = right.isRight();
   float   rightGrab           = right.getGrabStrength();
   float   rightPinch          = right.getPinchStrength();
   float   rightTime           = right.getTimeVisible();
   PVector rightSpherePosition = right.getSpherePosition();
   float   rightSphereRadius   = right.getSphereRadius();
   }
   }
   */

  if (geekduino.available() > 0) {
    int read = geekduino.read();
    if (read == 1) { //"1" is RECORD BUTTON
      needSave = !needSave;
      if (needSave == true) {
        coordinate.clear();
      }
      /*while (geekduino.available() > 0) {
       geekduino.read();
       }
       */
    } else if (read == 2) { //"2" is PLAYBACK BUTTON
      toPlay = !toPlay;
      /*while (geekduino.available() > 0) { 
       geekduino.read();
       }*/
    }
  }

  print("Need Save? ");
  println(needSave);
  print("To Play? ");
  println(toPlay);


  if (!toPlay) {
    for (Hand hand : leap.getHands ()) { //there has to be a way to differentiate between left and right hands instead of making a variable for each... (like a class/object system?)


      // ==================================================
      // 2. Hand
      int     handId             = hand.getId();
      PVector handPosition       = hand.getPosition();
      PVector handStabilized     = hand.getStabilizedPosition();
      PVector handDirection      = hand.getDirection();
      PVector handDynamics       = hand.getDynamics();
      float   handRoll           = hand.getRoll();
      float   handPitch          = hand.getPitch();
      float   handYaw            = hand.getYaw();
      boolean handIsLeft         = hand.isLeft();
      boolean handIsRight        = hand.isRight();
      float   handGrab           = hand.getGrabStrength();
      float   handPinch          = hand.getPinchStrength();
      float   handTime           = hand.getTimeVisible();
      PVector spherePosition     = hand.getSpherePosition();
      float   sphereRadius       = hand.getSphereRadius();

      // --------------------------------------------------
      // Drawing
      hand.draw();





      int rawX = int(handStabilized.x);
      int rawY = int(handPosition.z * 5);//z and y flipped to be the same with robotic arm cartesian coordinates
      int rawZ = int(handStabilized.y);
      int grip = int(handGrab * 1000);
      int pinch = int(handPinch * 1000);

      //Inverse Z so that higher value z = higher up (CLEAN UP CODE)
      int midZ = ((LM_MAX_Z - LM_MIN_Z)/2) + LM_MIN_Z;
      int tempZ = midZ; //default values in case of error
      tempZ = LM_MAX_Z - rawZ + LM_MIN_Z;   
      rawZ = tempZ;

      print ("Grip: ");
      println (grip);
      print ("Pinch: ");
      println (pinch);
      /*
    if (handIsRight) { //data diag with RIGHT HAND
       JSONObject json = new JSONObject();
       json.setInt("x", rawX);
       json.setInt("y", rawY); 
       json.setInt("z", rawZ);
       json.setInt("grip", grip);
       
       println (json.toString());
       }
       */

      ///ARM CALIBRATION/ZEROING



      if (grip > 800 && isLive == false) {
        initX = rawX;
        initY = rawY;
        initZ = rawZ;
      }

      if (grip <= 800 && isLive == false) {
        isLive = true;
      }

      if (grip <= 800 && isLive == true) {
        //centering to "0" as center
        centeredX = rawX - initX;
        centeredY = rawY - initY;
        centeredZ = rawZ - initZ;

        //scaling down data to increase resolution and adjust to midpoint of IK values
        centeredX = int(centeredX/1.5);
        centeredY = int(centeredY/4.5 + 100);
        centeredZ = int(centeredZ/(400/175) + 110);

        centeredX = max(min(centeredX, IK_MAX_X), IK_MIN_X);
        centeredY = max(min(centeredY, IK_MAX_Y), IK_MIN_Y);
        centeredZ = max(min(centeredZ, IK_MAX_Z), IK_MIN_Z);



        JSONObject json = new JSONObject();
        json.setInt("x", centeredX);
        json.setInt("y", centeredY); 
        json.setInt("z", centeredZ);
        json.setInt("grip", grip);
        json.setInt("pinch", int(map(pinch, 0, 1000, 2100, 750))); //invert grip values

        println (json.toString());

        if ((centeredX*centeredX + centeredY*centeredY) < 27000) {
          geekduino.write(json.toString() + '!'); //! used as end point
          if (needSave && !toPlay) {
            coordinate.add(json.toString() + '!');
          }
        } else {
          println("MAX REACH! PROCEED WITH CAUTION");
        }
      }

      if (grip > 800 && isLive == true) { //removal of arms, reset coordinates to init values
        JSONObject json = new JSONObject();
        json.setInt("x", 0);
        json.setInt("y", 150);
        json.setInt("z", 150);
        json.setInt("grip", grip);
        json.setInt("pinch", pinch);

        //println (json.toString());
        isLive = false;
      }









      /*
    if (handIsRight) {
       println ("Right X, Y, Z: ", handStabilized.x, ", ", handStabilized.y, ", ", handPosition.z);
       }
       if (handIsLeft) {
       println ("Left X, Y, Z: ", handStabilized.x, ", ", handStabilized.y, ", ", handPosition.z);
       }
       */
    }
  } else {
    for (String json : coordinate) {
      geekduino.write(json);
      delay(30);
      if (leap.getHands().size() > 0){
        break;
      }
      
    }
    toPlay = false;
  }
}
