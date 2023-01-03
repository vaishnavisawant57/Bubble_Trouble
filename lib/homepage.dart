import 'dart:async';

import 'package:bubble_trouble/ball.dart';
import 'package:bubble_trouble/button.dart';
import 'package:bubble_trouble/missile.dart';
import 'package:bubble_trouble/player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

enum direction {LEFT,RIGHT}

class _HomePageState extends State<HomePage> {
  //player variable
  static double playerX=0;

  //missile variables
  double missileX=playerX;
  double missileHeight=10;
  bool midShot=false;

  //ball variables
  double ballX=0.5;
  double ballY=0;
  var ballDirection=direction.LEFT;

  void startGame(){
    //velocity tells us how strong the jump is
    double time=0,height=0,velocity=70;
    Timer.periodic(Duration(milliseconds: 10), (timer) {
      //quadratic equation that models a bounce (upside down parabola)
      height=-5*time*time+velocity*time;

      //if the ball reaches the ground, reset the jump
      if(height<0){
        time=0;
      }

      setState(() {
        ballY=heightToCoordinate(height);
      });
      time+=0.1;
      //if the ball hits the left wall, change direction to right
      if(ballX-0.05<-1){
        ballDirection=direction.RIGHT;
      }
      else if(ballX+0.05>1){
        ballDirection=direction.LEFT;
      }
      if(ballDirection==direction.LEFT){
        setState(() {
          ballX-=0.05;
        });
      }
      else if(ballDirection==direction.RIGHT){
        setState(() {
          ballX+=0.05;
        });
      }
      //check if player dies
      if(playerDies()){
        timer.cancel();
        // print("DEAD");
        _showDialog();
      }
    });
  }
  void _showDialog(){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            backgroundColor: Colors.grey,
            title: Text("You are dead"),
          );
        }
    );
  }
  void moveLeft(){
      setState(() {
        if(playerX-0.1>=-1)
          playerX-=0.1;
        if(!midShot)
          missileX=playerX;
      });
  }
  void moveRight(){
      setState(() {
        if(playerX+0.1<=1)
         playerX+=0.1;
        if(!midShot)
          missileX=playerX;
      });
  }
  void fireMissile(){
    if(midShot==false){
      Timer.periodic(Duration(milliseconds: 100), (timer) {

        //shots fired
        midShot=true;

        //missile grows till it hits the top of the screen
        setState(() {
          missileHeight+=10 ;
        });

        //stop missile when it reaches the top
        if(missileHeight>MediaQuery.of(context).size.height*3/4){
          resetMissile();
          timer.cancel();
        }

        //check if missile has hit the ball
        if(ballY>heightToCoordinate(missileHeight) && (ballX-missileX).abs()<0.03){
          resetMissile();
          ballX =5;
          timer.cancel();
        }
      });
    }
  }

  bool playerDies(){
    //if the ball position and player position is the same, then the player dies
    if((ballX-playerX).abs()<0.05 && ballY>0.95){
      return true;
    }
    return false;
  }
  double heightToCoordinate(double height){
    double totalHeight=MediaQuery.of(context).size.height *3 /4;
    double position=1 - 2 * height / totalHeight;
    return position ;
  }
  void resetMissile(){
    missileX=playerX;
    missileHeight=10;
    midShot=false;
  }
  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (event){
        if(event.isKeyPressed(LogicalKeyboardKey.arrowLeft)){
          moveLeft();
        }
        else if(event.isKeyPressed(LogicalKeyboardKey.arrowRight)){
          moveRight();
        }
        else if(event.isKeyPressed(LogicalKeyboardKey.space)){
          fireMissile();
        }
      },
      child: Column(
        children: [
          Expanded(
            //some scale to share the free space
            flex: 3,
              child: Container(
                color: Colors.pink[100],
                child: Center(
                  child: Stack(
                    children: [
                      MyBall(ballX: ballX, ballY: ballY),
                      MyMissile(missileX: missileX,height: missileHeight,),
                      MyPlayer(playerX: playerX,),

                    ],
                  ),
                ),
              )
          ),
          Expanded(
              child: Container(
                color: Colors.grey,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    MyButton(icon: Icons.play_arrow,function: startGame,),
                    MyButton(icon: Icons.arrow_back,function: moveLeft,),
                    MyButton(icon: Icons.arrow_upward,function: fireMissile,),
                    MyButton(icon: Icons.arrow_forward,function: moveRight,),
                  ],
                ),
              )
          ),
        ],
      ),
    );
  }
}
