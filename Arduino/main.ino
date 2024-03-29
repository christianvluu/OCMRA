/***********************************************************************************
    }--\     RobotGeek Snapper Robotic Arm     /--{
        |       Analog IK Control Code        |
     __/                                       \__
    |__|                                       |__|


    The following sketch will move the arm to an X/Y/Z coordinate based on the inputs
    from the analog inputs (joysticks and knob). This sketch can also be used to play
    back a pre-programmed sequence.

    Snapper Arm Getting Started Guide
     http://learn.robotgeek.com/getting-started/33-robotgeek-snapper-robot-arm/63-robotgeek-snapper-arm-getting-started-guide.html
    Using the IK Firmware
      http://learn.robotgeek.com/demo-code/demo-code/154-robotgeek-snapper-joystick-inverse-kinematics-demo.html


    WIRING
      Servos
        Digital I/O 3 - Base Rotation - Robot Geek Servo
        Digital I/O 5 - Shoulder Joint - Robot Geek Servo
        Digital I/O 6 - Elbow Joint - Robot Geek Servo
        Digital I/O 9 - Wrist Joint - Robot Geek Servo
        Digital I/O 10 - Gripper Servo - 9g Servo

      Analog Inputs
        Analog 0 - Joystick (Horizontal)
        Analog 1 - Joystick (Vertical)
        Analog 2 - Joystick (Vertical)
        Analog 3 - Joystick (Vertical)
        Analog 4 - Rotation Knob

      Digital Inputs
        Digital 2 - Button 1
        Digital 4 - Button 2


      Use an external power supply and set both PWM jumpers to 'VIN'

    CONTROL
        Analog 0 - Joystick - Control the Y Axis (forward/back)
        Analog 1 - Joystick - Control the X Axis (left/right)
        Analog 2 - Joystick - Control the Z Axis (up/down)
        Analog 3 - Joystick - Control the Wrist Angle
        Analog 4 - Rotation Knob - Control the Gripper
      http://learn.robotgeek.com/demo-code/demo-code/154-robotgeek-snapper-joystick-inverse-kinematics-demo.html



    NOTES

      SERVO POSITIONS
        The servos' positions will be tracked in microseconds, and written to the servos
        using .writeMicroseconds()
          http://arduino.cc/en/Reference/ServoWriteMicroseconds
        For RobotGeek servos, 600ms corresponds to fully counter-clockwise while
        2400ms corresponds to fully clock-wise. 1500ms represents the servo being centered

        For the 9g servo, 900ms corresponds to fully counter-clockwise while
        2100ms corresponds to fully clock-wise. 1500ms represents the servo being centered


    This code is a Work In Progress and is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
    FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more details.
   Sources used:
   https://github.com/KurtE

   http://www.circuitsathome.com/mcu/robotic-arm-inverse-kinematics-on-arduino

   Application Note 44 - Controlling a Lynx6 Robotic Arm
   http://www.micromegacorp.com/appnotes.html
   http://www.micromegacorp.com/downloads/documentation/AN044-Robotic%20Arm.pdf


     This code is a Work In Progress and is distributed in the hope that it will be useful,
     but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
     FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more details.

 ***********************************************************************************/
#define ROBOT_GEEK_9G_GRIPPER 1
#define ROBOT_GEEK_PARALLEL_GRIPPER 2

//The 9G gripper is the gripper with the small blue 9g servo
//The Parralle gripper has a full robotgeek servo and paralle rails
//Uncomment one of the following lines depending on which gripper you are using.
//#define GRIPPER_TYPE ROBOT_GEEK_9G_GRIPPER
#define GRIPPER_TYPE ROBOT_GEEK_PARALLEL_GRIPPER

#ifndef GRIPPER_TYPE
#error YOU HAVE TO SELECT THE GRIPPER YOU ARE USING! Uncomment the correct line above for your gripper
#endif

#include <ServoEx.h>
#include "InputControl.h"
#include <ArduinoJson.h>

ServoEx    ArmServo[5];

int x;
int y;
int z;
int grip;
int pinch;

volatile boolean shouldSend = false;
volatile boolean isSend = false;

void interrupted() {
  if (shouldSend == false) {
    shouldSend = true;
  }
}

//===================================================================================================
// Setup
//===================================================================================================


void setup() {
  // Attach servo and set limits
  ArmServo[BAS_SERVO].attach(3, BASE_MIN, BASE_MAX);
  ArmServo[SHL_SERVO].attach(5, SHOULDER_MIN, SHOULDER_MAX);
  ArmServo[ELB_SERVO].attach(6, ELBOW_MIN, ELBOW_MAX);
  ArmServo[WRI_SERVO].attach(9, WRIST_MIN, WRIST_MAX);
  ArmServo[GRI_SERVO].attach(10, GRIPPER_MIN, GRIPPER_MAX);

  // initialize the pins for the pushbutton as inputs:


  pinMode(RECORD, INPUT);
  pinMode(PLAYBACK, INPUT);



  // send arm to default X,Y,Z coord
  doArmIK(true, g_sIKX, g_sIKY, g_sIKZ, g_sIKGA);
  SetServo(sDeltaTime);

  // start serial
  Serial.begin(115200);
  attachInterrupt(digitalPinToInterrupt(RECORD), interrupted, RISING);

  delay(2000);

  /*for (int i = 20; i < 150; i+=5){
    doArmIK(true, 0, 100, i, 20);
    MoveArmTo(sBase, sShoulder, sElbow, sWrist, sWristRot, sGrip, sDeltaTime, true);
    SetServo(0);
    delay(300);
    }
  */




}


void inputProcessing() {
  String input;

  if (Serial.available()) {
    input = Serial.readStringUntil('!'); //! used as end point

    StaticJsonBuffer<400> jsonBuffer;
    JsonObject& root = jsonBuffer.parseObject(input);

    x = root["x"];
    y = root["y"];
    z = root["z"];
    grip = root["grip"];
    pinch = root["pinch"];

  }

  x = min(max(x, IK_MIN_X), IK_MAX_X);
  y = min(max(y, IK_MIN_Y), IK_MAX_Y);
  z = min(max(z, IK_MIN_Z), IK_MAX_Z);
}

void loop() {
  if (Serial.available()) {
    inputProcessing();
    doArmIK(true, x, y, z, -70);



    MoveArmTo(sBase, sShoulder, sElbow, sWrist, sWristRot, pinch, sDeltaTime, true); //not sGrip because already mapped
    SetServo(0);
  }


  if (digitalRead(RECORD) == HIGH) {
    Serial.write(1);
    delay(400);
  }

  if (digitalRead(PLAYBACK) == HIGH) {
    Serial.write(2);
    delay(400);
  }


  /*
    while (1) {
    for (int i = 30; i < 150 ; i++) {
      doArmIK(true, 100, 100, i, -70);
      MoveArmTo(sBase, sShoulder, sElbow, sWrist, sWristRot, sGrip, sDeltaTime, true);
      SetServo(0);
      delay(25);
    }
    for (int i = 150; i >= 30; i = i - 1) {
      doArmIK(true, 100, 100, i, -70);
      MoveArmTo(sBase, sShoulder, sElbow, sWrist, sWristRot, sGrip, sDeltaTime, true);
      SetServo(0);
      delay(25);
    }
    }
  */


}




