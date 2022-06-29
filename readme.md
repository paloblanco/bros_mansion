# The Bros' Mini Mansion

This is a tiny game I am making to teach my nephew about game programming. You will need pico8 to run these files. 

![mini-mansion. Avoid the ghosts!](luigimario_1.gif)

## How to play and edit online:

If you just want to play, I keep updated web builds here: https://www.lexaloffle.com/bbs/?tid=47952

If you also want to be able to edit the game through your web browser, you can do the following:

1. Navigate to the pico-8 education edition. This link will automatically load this game: https://www.pico-8-edu.com/?c=bG9hZCAjdGhlX2Jyb3NfbWluaV9tYW5zaW9uLTM=&g=w-w-w-w1HQHw-w2Xw-w3Xw-w2HQH

    ![You should see this when you start](pictures/the%20bros%20mini%20mansion_0.png)

    *You should see this when you click the link*

2. You can play the game normally - it should accept keyboard (press X to use your vacuum, arrows to move) or gamepad inputs. If you want to edit the game, press ESC. This will stop the game, and you will see a blinking cursor.

    ![Escaped](pictures/the%20bros%20mini%20mansion_1.png)

    *Game stops when you press escape*

3. If you press ESC again, you will go into edit mode. If you look in the upper-right, you will see 5 icons - they stand for:
    1. Code
    2. Sprite (this is for drawing characters or bad guys or powerups)
    3. Map (this is for editing the map)
    4. Sound Effects
    5. Music

    ![Escaped](pictures/the%20bros%20mini%20mansion_2.png)

    *Game stops when you press escape*

4. If you just want to do some drawing, I recommend going to the sprite editor. This works like any paint program - just click a cell on the bottom of the screen to draw in, and then use the various tools to paint.

    ![Sprites](pictures/the%20bros%20mini%20mansion_4.png)

    *This works like paint*

5. The map editor lets you draw out the level. This is a little trickier - you may need to use the mouse wheel to zoom out, and you will need the "hand" tool to drag the view downwards so you can see the level. Then, you just use the little pictures like stamps and draw a level.

    ![Mapping](pictures/the%20bros%20mini%20mansion_5.png)

    *Mapping is trickier*

6. If you actually want to sav your work, press ESC to go back to the game screen, then type "SAVE *some_name*". This will download a file for you. You can load this into the editor later, or you can share it with me and I can incorporate it into the game later.

    ![saving](pictures\web_interface.png)

    *Saving*



## To do:
- ~~make stomping bad guy (sprite 60)~~
- ~~add playable characters~~
- ~~change characters at game start~~
- ~~make sprites stop dissappearing in walls~~
- ~~add effects and sfx when spraying walls~~
- ~~add pre-routine to make hidden wall sprites match normal sprites~~
- ~~biggie health from 500 to 400~~
- ~~sfx when coins bounce~~
- ~~extra graphics on bookcases~~, 
- ~~king boo cannot leave fight rooms~~
- ~~title screen~~
- ~~graphics screen~~
- ~~camera only follows lead bro~~
- ~~offscreen bros snap to lead bro~~
- ~~finilaze block layout of level~~
    - ~~clean up tiling~~
- ~~vacuum things close to you~~
- ~~flip ghosts corrrectly~~
- ~~both action buttons vacuum~~
- ~~fix big wall going solid~~
- ~~hallway near pond looks bad~~
- ~~can see wall from upper right secret room~~
- ~~put king boos near uppr right in final room~~
- ~~random bouncing for king boo~~
- ~~ball boos clipping through corners~~
- ~~king boos eyes are transparent~~
- ~~big boo should always face mainbro~~
- ~~big print text~~


## nice to have
- ~~correct floor appears when killing walls, big boo~~
- ~~better reward from big boos~~
- continue at gameover
    - cost 50 coins
    - another scene transition
- fix enemy placement on blind corners
- ~~only display health of damaged enemies~~
- ~~better sound for beating big boos~~
- ~~fix broken walls from re breaking~~
- better arena graphic
- ~~option to toggle kid mode~~
- ~~reduce fire rate of ball boos~~
- ~~animated water~~
- ~~make collision code more efficient? its starting to get CPU heavy~~
- ~~helth displays for more than 2 players~~
- ~~maze graphics (maybe stairs for floor texture?)~~
- ~~hidden collectibles~~

- ~~camera catches up to walking bro properly~~
- ~~8 playable characters~~
- ~~draw tails' tails~~
- more kinds of furniture 
- function that pauses game and lets you switch characters
    - a dedicated character switch screen would be good, then i can transition in and out
- level music
- pretty up title and ending screens
- better scene transition graphic
- Stars for finishing game under certain conditions


## Canceled Ideas
- run button


### cheatsheet
To run the mapper cart:
```
pico8 -displays_x 2 -displays_y 2 mapper.p8
```