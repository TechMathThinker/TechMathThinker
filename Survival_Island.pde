/*
  figure out how to make the scenes load faster
  make a timer countdown for decision making (1 minute)
*/
boolean gameStart = false, gameOver = false;
int currentScene = 0;
Scene[] scenes = new Scene[25];
PImage currentBackground;
int itemCnt = 1;
int health = 100, saturation = 100, hydration = 100;
PImage healthFull, healthEmpty, healthHalf, saturationFull, saturationEmpty, saturationHalf, hydrationFull, hydrationEmpty, hydrationHalf;

PImage inventoryBox;
boolean viewInventory;

boolean restPopup = false, drinkPopup = false, eatPopup = false;
boolean noRest = false, noDrink = false, noEat = false;

PFont HammersmithOne_Regular;

import processing.sound.*;
SoundFile currentSound;
boolean isSoundPlaying = false;
SoundFile click;

int currentTime = millis();
int decisionStartTime = 0, decisionTimeLimit = 60000;

class Scene{
  String text;
  String choice1, choice2;
  int nextScene1, nextScene2;
  String itemRewarded1, itemRewarded2;
  int item1Quantity, item2Quantity;
  String itemLost1, itemLost2;
  int healthChange, hungerChange, thirstChange;
  
  Scene(String tempText, String tempChoice1, String tempChoice2, int tempNextScene1, int tempNextScene2, String tempItemRewarded1, int tempItem1Quantity, String tempItemRewarded2, int tempItem2Quantity, String tempItemLost1, String tempItemLost2, int tempHealthChange, int tempHungerChange, int tempThirstChange){
    text = tempText;
    choice1 = tempChoice1;
    choice2 = tempChoice2;
    nextScene1 = tempNextScene1;
    nextScene2 = tempNextScene2;
    itemRewarded1 = tempItemRewarded1;
    item1Quantity = tempItem1Quantity;
    itemRewarded2 = tempItemRewarded2;
    item2Quantity = tempItem2Quantity;
    itemLost1 = tempItemLost1;
    itemLost2 = tempItemLost2;
    healthChange = tempHealthChange;
    hungerChange = tempHungerChange;
    thirstChange = tempThirstChange;
  }
}

class textBox{
  String text;
  float x, y, w, h;
  
  textBox(String text, float x, float y, float w, float h){
    this.text = text;
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }
  
  void display(){
    text(text, x, y, w, h);
  }
}

class Inventory{
  String item = "";
  int quantity;
  PImage box;
  float x, y;
  
  Inventory(String item, int quantity, PImage box, float x){
    this.item = item;
    this.quantity = quantity;
    this.box = box;
    this.x = x;
  }
  
  void display(){
    image(box, x, height/2-125);
    if(item != ""){
      PImage tmp = loadImage(item + ".png");
      image(tmp, x, height/2-125, 64, 64);
      textSize(16);
      fill(255);
      textAlign(RIGHT, BOTTOM);
      text(quantity, x + 30, height/2 - 95);
      textAlign(CENTER, CENTER);
    }
  }
}

Inventory[] inventory = new Inventory[15];

void setup(){
  fullScreen();//screen
  
  click = new SoundFile(this, "click.mp3");
  
  HammersmithOne_Regular = createFont("HammersmithOne-Regular.ttf", 128);
  
  currentBackground = loadImage("bg0.png");
  
  healthFull = loadImage("healthFull.png");
  healthEmpty = loadImage("healthEmpty.png");
  healthHalf = loadImage("healthHalf.png");
  saturationFull = loadImage("saturationFull.png");
  saturationEmpty = loadImage("saturationEmpty.png");
  saturationHalf = loadImage("saturationHalf.png");
  hydrationFull = loadImage("hydrationFull.png");
  hydrationEmpty = loadImage("hydrationEmpty.png");
  hydrationHalf = loadImage("hydrationHalf.png");
  
  inventoryBox = loadImage("inventory.png");
  for (int i = 1; i <= 9; i++) {
    inventory[i] = new Inventory("", 0, inventoryBox, width/2 + ((i-5)*72));
    inventory[i].item = "";
    inventory[i].quantity = 0;
  }
  
  scenes[1] = new Scene(
    "You wake up on a beach and realize that you were the only survivor of the shipwreck. The remains of the ship are nearby, and you are disorientated and injured. What do you do?",
    "Search the wreckage",
    "Explore the nearby jungle",
    2,
    3,
    "",
    0,
    "",
    0,
    "",
    "",
    -30,
    50,
    50
  );
  
  scenes[2] = new Scene(
    "You rummage through the wrekcage and find multiple items, but you only have space for a few. What do you take with you?",
    "A rusty knife and a length of sturdy rope",
    "Sealed canned food and contaminated fresh water",
    4,
    5,
    "",
    0,
    "",
    0,
    "",
    "",
    0,
    10,
    10
  );
  
  scenes[3] = new Scene(
    "Entering the jungle, you see a stream, and you also hear strange noises. What do you do?",
    "Follow the stream",
    "Head deeper into the jungle, towards the noise",
    6,
    7,
    "",
    0,
    "",
    0,
    "",
    "",
    0,
    5,
    5
  );
  
  scenes[4] = new Scene(
    "You return to the beach, and...",
    "build a small campsite with the knife and rope",
    "continue exploring the island",
    8,
    9,
    "Rusty Knife",
    1,
    "Rope",
    1,
    "",
    "",
    0,
    10,
    10
  );
  
  scenes[5] = new Scene(
    "The canned food tastes good, but you are starting to dehydrate. What do you do?",
    "Attemt to purify the water",
    "Continue exploring the island",
    10,
    11,
    "Contaminated Water",
    5,
    "Canned Food",
    5,
    "Canned Food",
    "",
    0,
    -30,
    10
  );
  
  scenes[6] = new Scene(
    "Following the stream, you see a part of it with really clear water. After drinking some water, what do you do?",
    "Build a campsite along the stream",
    "Continue following the stream",
    12,
    13,
    "",
    0,
    "",
    0,
    "",
    "",
    10,
    10,
    -30
  );
  
  scenes[7] = new Scene(
    "You see a cave, what now?",
    "Explore the cave",
    "Head back",
    14,
    15,
    "",
    0,
    "",
    0,
    "",
    "",
    0,
    15,
    10
  );
  
  scenes[8] = new Scene(
    "The campsite looks great! Now you have a safe place to rest. You're getting a little hungry and dehydrated though. What should you do?",
    "Reinforce the campsite",
    "Search for food and water",
    16,
    17,
    "",
    0,
    "",
    0,
    "Rope",
    "",
    0,
    20,
    20
  );
  
  scenes[9] = new Scene(
    "You spot marks on the nearby trees and realize there is a path. Do you search around for supplies or follow the trail?",
    "Search around for supplies",
    "Follow the trail",
    18,
    19,
    "Rusty Knife",
    1,
    "Rope",
    1,
    "",
    "",
    0,
    0,
    0
  );
  
  scenes[10] = new Scene(
    "Now you have clean drinking water, you can either ration it or explore the island.",
    "Stay and ration the water",
    "Continue exploring the island",
    20,
    11,
    "Clean Water",
    5,
    "",
    0,
    "Contaminated Water",
    "",
    0,
    5,
    5
  );
  
  scenes[11] = new Scene(
    "You discover a map left by an explorer, what do you do?",
    "Search around for more supplies",
    "Follow the map",
    18,
    19,
    "Map",
    1,
    "",
    0,
    "",
    "",
    0,
    10,
    10
  );
  
  scenes[12] = new Scene(
    "It's nightfall, and you've finally set up a small campsite. You hear rustling sounds. Do you inspect the sounds or go to sleep?",
    "Inspect the rustling",
    "Go to sleep",
    17,
    8,
    "",
    0,
    "",
    0,
    "",
    "",
    -5,
    10,
    10
  );
  
  scenes[13] = new Scene(
    "You arrive at a waterfall, and something is glowing inside of it. Do you dive in or head back?",
    "Dive in",
    "Head back",
    14,
    15,
    "",
    0,
    "",
    0,
    "",
    "",
    0,
    20,
    20
  );
  
  scenes[14] = new Scene(
    "You enter a cave and see many jewels. Do you take them or go deeper into the cave?",
    "Take the jewels and head back",
    "Go deeper",
    16,
    19,
    "",
    0,
    "",
    0,
    "",
    "",
    -10,
    0,
    0
  );
  
  scenes[15] = new Scene(
    "You head back form the waterfall and hear a growl from your stomach. A few meters from you are berries you've never seen before. What do you do?",
    "Eat the Berries",
    "Head Back",
    21, //gameover
    1,
    "",
    0,
    "",
    0,
    "",
    "",
    0,
    10,
    5
  );
  
  scenes[16] = new Scene(
    "You notice a helicopter in the sky. Do you try to signal it?",
    "Signal It",
    "Stay hidden",
    22, //good ending 1
    20,
    "",
    0,
    "",
    0,
    "",
    "",
    0,
    0,
    0
  );
  
  scenes[17] = new Scene(
    "You see boars nearby. Do you hunt them or run away?",
    "Hunt Boars",
    "Run Away",
    24, //bad ending
    5,
    "",
    0,
    "",
    0,
    "",
    "",
    0,
    10,
    10
  );
  
  scenes[18] = new Scene(
    "After searching, you find a small raft. Do you sail away, or continue searching the island?",
    "Sail away",
    "Continue searching",
    23, //good ending 2
    10,
    "",
    0,
    "",
    0,
    "",
    "",
    0,
    10,
    10
  );
  
  scenes[19] = new Scene(
    "You follow the trail, which leads you to the edge of a cliff. Do you try to go down the cliff or head back?",
    "Go down the cliff",
    "Head back",
    21, //game over
    1,
    "",
    0,
    "",
    0,
    "",
    "",
    0,
    15,
    15
  );
  
  scenes[20] = new Scene(
    "You have enough water to survive for days. Hopefully someone comes and find you! A ship passes by.",
    "Signal it",
    "Stay hidden",
    22, //good ending 1
    25, //neutral ending
    "",
    0,
    "",
    0,
    "",
    "",
    0,
    0,
    0
  );
}
void draw(){
  image(currentBackground, 0, 0, width, height); //background image
  if(isSoundPlaying == false){
    currentSound = new SoundFile(this, "sfx" + currentScene + ".mp3");
    currentSound.play(); //audio
    isSoundPlaying = true;
  }
  if(gameStart == true){
    health = min(health, 100);
    saturation = min(saturation, 100);
    hydration = min(hydration, 100);
    
    for(int i=1;i<=10;i++){
      if(i*10<=health) image(healthFull, 260-i*25, 10, 20, 20);
      else if(i*10<=health+5) image(healthHalf, 260-i*25, 10, 20, 20);
      else image(healthEmpty, 260-i*25, 10, 20, 20);
    }
    
    for(int i=1;i<=10;i++){
      if(i*10<=saturation) image(saturationFull, 260-i*25, 40, 20, 20);
      else if(i*10<=saturation+5) image(saturationHalf, 260-i*25, 40, 20, 20);
      else image(saturationEmpty, 260-i*25, 40, 20, 20);
    }
    
    for(int i=1;i<=10;i++){
      if(i*10<=hydration) image(hydrationFull, 260-i*25, 70, 20, 20);
      else if(i*10<=hydration+5) image(hydrationHalf, 260-i*25, 70, 20, 20);
      else image(hydrationEmpty, 260-i*25, 70, 20, 20);
    }
    
    rectMode(CENTER);
    textAlign(CENTER, CENTER);
    textFont(HammersmithOne_Regular);
    textSize(30);
    
    textBox descriptionBox, choice1Box, choice2Box;
    
    fill(217, 217, 217, 100); //grey
    rect(width/2, height-125, width, 250);
    fill(255,255,255);
    descriptionBox = new textBox(scenes[currentScene].text, width/2-150, height-125, width-400, 225); //scene description
    descriptionBox.display();
    
    textSize(20);
    stroke(255,204,0); //yellow
    
    fill(255, 204, 0); //yellow
    rect(width-200, height-175, 250, 75, 50);
    fill(0);
    choice1Box = new textBox(scenes[currentScene].choice1, width-200, height-175, 225, 75); //button 1
    choice1Box.display();
    
    fill(255, 204, 0); //yellow
    rect(width-200, height-75, 250, 75, 50);
    fill(0);
    choice2Box = new textBox(scenes[currentScene].choice2, width-200, height-75, 225, 75); //button 2
    choice2Box.display();
    
    toRest();
    toDrink();
    toEat();
    
    for (int i=1;i<=9;i++)
     if (inventory[i].quantity == 0) inventory[i].item = "";
    
    if ((key == 'e' || key == 'E') && millis() - currentTime > 800) {
       viewInventory = !viewInventory;
       key = 0;
       currentTime = millis();
     }

    if (viewInventory) {
      imageMode(CENTER);
      for (int i=1;i<=9;i++) {
        println(inventory[i].item);
        inventory[i].display();
      }
      imageMode(CORNER);
    }
    
    int timePassed = millis() - decisionStartTime;
    int timeLeft = max(0, decisionTimeLimit - timePassed);
    textSize(25);
    fill(0);
    text("Time left: " + (timeLeft / 1000) + "s", width / 2, 50);
    
    if(millis() - decisionStartTime >= decisionTimeLimit - 10000)
      timeLimitWarning();
  }
}
void mousePressed(){
  click.play();
  if(gameStart == false){
    gameStart = true;
    currentScene = 1;
    nextScene();
  }
  else{
    if(mouseX>=width-325 && mouseX<=width-75 && mouseY>height-212.5 && mouseY<height-137.5){
      currentScene = scenes[currentScene].nextScene1;
      nextScene();
    }
    else if(mouseX>=width-325 && mouseX<=width-75 && mouseY>height-112.5 && mouseY<height-37.5){
      currentScene = scenes[currentScene].nextScene2;
      nextScene();
    }
    
    if(restPopup){
      if(mouseX>=width/2-115 && mouseX<=width/2-35&& mouseY>=height/2+55 && mouseY<=height/2+105){
        restPopup = false;
        health += 30;
        hydration -= 10;
        saturation -= 10;
      }
      else if(mouseX>=width/2+35 && mouseX<=width/2+115&& mouseY>=height/2+55 && mouseY<=height/2+105)
        noRest = true;
    }
    if(drinkPopup){
      if(mouseX>=width/2-115 && mouseX<=width/2-35&& mouseY>=height/2+55 && mouseY<=height/2+105){
        drinkPopup = false;
        hydration += 30;
        if(inventory[isWater()].item == "Contaminated Water") health -= 20;
        inventory[isWater()].quantity--;
      }
      else if(mouseX>=width/2+35 && mouseX<=width/2+115&& mouseY>=height/2+55 && mouseY<=height/2+105)
        noDrink = true;
    }
  }
}

void nextScene(){
  currentBackground = loadImage("bg" + currentScene + ".png");
  isSoundPlaying = false;
  currentSound.stop();
  health += scenes[currentScene].healthChange;
  saturation -= scenes[currentScene].hungerChange;
  hydration -= scenes[currentScene].thirstChange;
  rewardItems();
  loseItems();
  
  if(health<=0) gameOver = true;
  if(saturation<=0) gameOver = true;
  if(hydration<=0) gameOver = true;
  
  noRest = false;
  noDrink = false;
  noEat = false;
  
  decisionStartTime = millis();
}

void rewardItems(){
  if(scenes[currentScene].itemRewarded1 != ""){
    addItem(scenes[currentScene].itemRewarded1, scenes[currentScene].item1Quantity);
  }
  if(scenes[currentScene].itemRewarded2 != ""){
    addItem(scenes[currentScene].itemRewarded2, scenes[currentScene].item1Quantity);
  }
}

void loseItems(){
  if(scenes[currentScene].itemLost1 != ""){
    for(int i=1;i<=itemCnt;i++){
      if(inventory[i].item == scenes[currentScene].itemLost1){
        if(currentScene == 10) inventory[i].quantity = 0; //special case
        else inventory[i].quantity--;
      }
    }
  }
  if(scenes[currentScene].itemLost2 != ""){
    for(int i=1;i<=itemCnt;i++){
      if(inventory[i].item == scenes[currentScene].itemLost2){
        inventory[i].quantity--;
      }
    }
  }
}

void toRest(){
  if(health<=30 && !noRest){
    restPopup = true;
    fill(255, 255, 255, 180);
    stroke(255, 255, 255);
    rect(width/2, height/2, 350, 225, 50);
    fill(255,204,0);
    rect(width/2-75, height/2+80, 80, 50, 20);
    rect(width/2+75, height/2+80, 80, 50, 20);
    fill(0);
    textSize(25);
    textBox restBox;  
    restBox = new textBox("Your health is running low. Do you want to rest?", width/2, height/2-40, 325, 200);
    restBox.display();
    text("Yes", width/2-75, height/2+80);
    text("No", width/2+75, height/2+80);
    textSize(20);
    textBox warningBox;
    warningBox = new textBox("(You will dehydrate and get hungrier while resting)", width/2, height/2+20, 325, 100);
    warningBox.display();
  }
}

void toDrink(){
  int waterPos = isWater();
  if(waterPos>0 && hydration<=30 && !noDrink){
    drinkPopup = true;
    fill(255, 255, 255, 180);
    stroke(255, 255, 255);
    rect(width/2, height/2, 350, 225, 50);
    fill(255,204,0);
    rect(width/2-75, height/2+80, 80, 50, 20);
    rect(width/2+75, height/2+80, 80, 50, 20);
    fill(0);
    textSize(25);
    textBox restBox;
    restBox = new textBox("Seems like you're getting thirsty, are you going to drink some water?", width/2, height/2-40, 325, 200);
    restBox.display();
    text("Yes", width/2-75, height/2+80);
    text("No", width/2+75, height/2+80);
    textSize(20);
    textBox warningBox;
    if(inventory[waterPos].item == "Clean Water")
      warningBox = new textBox("[Clean water found in inventory]", width/2, height/2+25, 325, 100);
    else
      warningBox = new textBox("[Contaminated water found in inventory, may affect health]", width/2, height/2+25, 325, 100);
    warningBox.display();
  }
}

void toEat(){
  int foodPos = isFood();
  if(foodPos>0 && saturation<=30 && !noEat && inventory[foodPos].item == "Canned Food"){
    eatPopup = true;
    fill(255, 255, 255, 180);
    stroke(255, 255, 255);
    rect(width/2, height/2, 350, 255, 50);
    fill(255, 204, 0);
    rect(width/2-75, height/2+80, 80, 50, 20);
    rect(width/2+75, height/2+80, 80, 50, 20);
    fill(0);
    textSize(25);
    textBox restBox;
    restBox = new textBox("Your hunger bar is low, do you want to eat some food?", width/2, height/2-40, 325, 200);
    restBox.display();
    text("Yes", width/2-75, height/2+80);
    text("No", width/2+75, height/2+80);
    textSize(20);
    textBox warningBox;
    warningBox = new textBox("[Canned food found in inventory]", width/2, height/2+25, 325, 100);
    warningBox.display();
  }
}

int isWater(){
  for(int i=1;i<=9;i++){
    if(inventory[i].item == "Clean Water" || inventory[i].item == "Contaminated Water") return i;
  }
  return -1;
}

int isFood(){
  for(int i=1;i<=9;i++){
    if(inventory[i].item == "Canned Food") return i;
  }
  return -1;
}

void timeLimitWarning(){
  int timeLeft = max(0, decisionTimeLimit - (millis() - decisionStartTime));
  
  fill(255, 0, 0, 200);
  rect(width / 2, height / 2, 400, 200, 20);
  fill(255);
  textSize(25);
  textAlign(CENTER, CENTER);
  text("You have " + floor(timeLeft/1000) + " seconds left to make a choice!", width / 2, height / 2);
  
  if(timeLeft == 0){
    gameOver = true;
    background(0);
    fill(255);
    textSize(50);
    textAlign(CENTER, CENTER);
    text("Time's up! You lost the game.", width / 2, height / 2);
  }
}

void addItem(String item, int quantity){
  boolean itemExists = false;
  
  for(int i=1;i<itemCnt;i++){
     if(inventory[i].item == item) {
      inventory[i].quantity += quantity;
      itemExists = true;
      break;
    }
  }
  
  if(!itemExists) {
    inventory[itemCnt].item = item;
    inventory[itemCnt].quantity = quantity;
    itemCnt++;
  }
}
