# OCMRA
## Optically Controlled Miniature Robotic Arm

Created as part of a research internship at the Ho Chi Minh University of Sciences by Christian Luu and Thien Thai Vu.

PLEASE READ EVERYTHING BELOW

## Materials:
- RobotGeek Snapper Arduino Robotic Arm (https://www.robotgeek.com/robotgeek-snapper-robotic-arm)
- Leap Motion Device
- Host Computer (development completed on Mac OS)

## Notes:
 - RobotGeek Snapper Arm Assembly and Getting Started Guide (http://learn.robotgeek.com/getting-started/33-robotgeek-snapper-robot-arm/63-robotgeek-snapper-arm-getting-started-guide.html)
 - Install Processing IDE (include the Leap Motion library available in the library Contribution Manager in Processing)
 - Install Arduino IDE (install the RobotGeek Snapper Arm Library: http://learn.robotgeek.com/robotgeek-101-1/228-geekduino-getting-started-guide-2.html?kit=snapper)
 - Install Leap Motion SDK (https://developer.leapmotion.com/get-started)
 
 ## How it works:
 Leap Motion provides output to Processing. Processing then extrapolates the data from the Leap Motion sensor and sends data via Serial to the Arduino (which is part of the robotic arm). The Arduino takes in the outputs of Processing and then interprets it to become Servo commands. These servo commands are the movements that the robotic arm will conduct - a duplicate of the human hand that the Leap Motion device sees. Using the buttons on the robotic arm, the user can record and replay actions that the robotic arm can repeat.
