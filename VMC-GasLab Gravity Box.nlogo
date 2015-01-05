__includes [ "./GasLab-collision-and-collide.nls" "./GasLab-tick-delta.nls" ]


globals
[
  box-edge                                    ;; distance of box edge from axes
  aggregate-list                              ;; list of the sums of the temperature at each height
]

breed [ particles particle ]

particles-own[ speed mass energy last-collision]

to setup
  clear-all
  set-default-shape particles "circle"
  GasLab-init-tick-delta
 
  ;; box has constant size...
  set box-edge (max-pxcor)
  make-particles
  ask patches with [ pycor = min-pycor or pycor = max-pycor] [ set pcolor yellow ]
  reset-ticks
end

to go
  ask particles [ 
    bounce 
    move 
    check-for-collision-and-collide
    recolor] 
  
  GasLab-new-tick-delta
  update-plots
  display
end

to bounce  ;; particle procedure  ;; get the coordinates of the patch we will be on if we go forward 1
  let new-patch patch-ahead 1
  let new-px [pxcor] of new-patch
  let new-py [pycor] of new-patch
  ;; if we're not about to hit a wall, we don't need to do any further checks
  if [pcolor] of new-patch != yellow [ stop ]
  ;; if hitting the top or bottom, reflect heading around y axis
  if (new-py = max-pycor or new-py = min-pycor ) [ set heading (180 - heading)]
end

to move  ;; particle procedure
  ;; In other GasLab models, we use "jump speed * tick-delta" to move the
  ;; turtle the right distance along its current heading.  In this
  ;; model, though, the particles are affected by gravity as well, so we
  ;; need to offset the turtle vertically by an additional amount.  The
  ;; easiest way to do this is to use "setxy" instead of "jump".
  ;; Trigonometry tells us that "jump speed * tick-delta" is equivalent to:
  ;;   setxy (xcor + dx * speed * tick-delta)
  ;;         (ycor + dy * speed * tick-delta)
  ;; so to take gravity into account we just need to alter ycor
  ;; by an additional amount given by the classical physics equation:
  ;;   y(t) = 0.5*a*t^2 + v*t + y(t-1)
  ;; but taking tick-delta into account, since tick-delta is a multiplier of t.
  setxy (xcor + dx * speed * tick-delta)
        (ycor + dy * speed * tick-delta - gravity-acceleration * (0.5 * tick-delta * tick-delta))
  ;;factor-gravity
  let vx (dx * speed)
  let vy (dy * speed) - (gravity-acceleration * tick-delta)

  set speed sqrt ((vy ^ 2) + (vx ^ 2))
  set heading atan vx vy
end

;; creates initial particles
to make-particles
  create-particles number-of-particles
  [ set speed init-particle-speed
    set mass particle-mass
    set energy (0.5 * mass * speed * speed)
    set last-collision nobody
    setxy random-xcor random-float (world-height - 3) + 1
    set heading random-float 360
    recolor
  ]
  calculate-tick-delta
end

to recolor  ;; particle procedure
  ifelse speed < (0.5 * 10)
  [ set color blue ]
  [ ifelse speed > (1.5 * 10)
      [ set color red ]
      [ set color green ]]
end

to-report avg-kinetic
  report sum [energy] of particles / number-of-particles
end

to-report avg-potential
  report sum [ycor * mass * gravity-acceleration] of particles / number-of-particles
end


; Copyright 2002 Uri Wilensky.
; See Info tab for full copyright and license.


@#$#@#$#@
GRAPHICS-WINDOW
312
10
646
365
40
-1
4.0
1
10
1
1
1
0
1
0
1
-40
40
0
80
1
1
1
ticks
30.0

BUTTON
7
43
93
76
go/stop
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
7
10
93
43
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
96
10
302
43
number-of-particles
number-of-particles
1
1000
1000
1
1
NIL
HORIZONTAL

SLIDER
7
163
180
196
gravity-acceleration
gravity-acceleration
0
15
9.8
0.2
1
NIL
HORIZONTAL

SLIDER
7
85
180
118
init-particle-speed
init-particle-speed
1
20
10
1
1
NIL
HORIZONTAL

SLIDER
7
124
180
157
particle-mass
particle-mass
1
20
1
1
1
NIL
HORIZONTAL

PLOT
54
393
722
653
plot 1
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -2674135 true "" "plot avg-kinetic"
"pen-1" 1.0 0 -13345367 true "" "plot avg-potential"
"pen-2" 1.0 0 -16777216 true "" "plot avg-kinetic + avg-potential"

@#$#@#$#@
## WHAT IS IT?

This model is one in a series of GasLab models. They use the same basic rules for simulating the behavior of gases.  Each model integrates different features in order to highlight different aspects of gas behavior.

The basic principle of the models is that gas particles are assumed to have two elementary actions: they move and they collide --- either with other particles or with any other objects such as walls.

This model simulates the effect of gravity on gas particles.  It is very similar to GasLab Atmosphere, but with a "ceiling" over the gas, so particles can never escape.

This model is part of the Connected Mathematics "Making Sense of Complex Phenomena" Modeling Project.

## HOW IT WORKS

The particles are modeled as hard balls with no internal energy except that which is due to their motion.  Collisions between particles are elastic.  Particles are colored according to speed --- blue for slow, green for medium, and red for high speeds.

Coloring of the particles is with respect to one speed (10).  
Particles with a speed less than 5 are blue, ones that are more than  
15 are red, while all in those in-between are green.

The exact way two particles collide is as follows:  
1. A particle moves in a straight line without changing its speed, unless it collides with another particle or bounces off the wall.  
2. Two particles "collide" if they find themselves on the same patch.  
3. A random axis is chosen, as if they are two balls that hit each other and this axis is the line connecting their centers.  
4. They exchange momentum and energy along that axis, according to the conservation of momentum and energy.  This calculation is done in the center of mass system.  
5. Each particle is assigned its new velocity, energy, and heading.  
6. If a particle finds itself on or very close to a wall of the container, it "bounces" --- that is, reflects its direction and keeps its same speed.

In this model the particles behave exactly as in the basic Gas in a Box model except for now gravity acts on the particles.  Every particle is given additional velocity downward during each tick, as it would get in a gravitational field.  The particles bounce off the "ground" as well as the ceiling.

## HOW TO USE IT

Initial settings:  
- GRAVITY: strength of the gravitational acceleration  
- NUMBER-OF-PARTICLES: number of gas particles  
- INIT-PARTICLE-SPEED: initial speed of each particle  
- PARTICLE-MASS: mass of each particle

Other settings:  
- TRACE?: Traces the path of one of the particles.  
- COLLIDE?: Turns collisions between particles on and off.

The SETUP button will set the initial conditions.  
The GO button will run the simulation.

Monitors:  
- FAST, MEDIUM, SLOW: numbers of particles with different speeds: fast (red), medium (green), and slow (blue).  
- AVERAGE SPEED: average speed of the particles.  
- AVERAGE ENERGY: average energy of the particles.

Plots:  
- SPEED COUNTS: plots the number of particles in each range of speed.  
- SPEED HISTOGRAM: speed distribution of all the particles.  The gray line is the average value, and the black line is the initial average.  
- ENERGY HISTOGRAM: distribution of energies of all the particles, calculated as m*(v^2)/2.  
- HEIGHT VS. TEMPERATURE: shows the temperature of the particles at each 'layer' of the box.  
- DENSITY HISTOGRAM: shows the number of particles at each 'layer' of the box, i.e. its local density.  
- AGGREGATE TEMPERATURE: shows the aggregate sum of the HEIGHT VS. TEMPERATURE plot for the entire model run.

## THINGS TO NOTICE

Try to predict what the view will look like after a while, and why.

Watch the gray path of one particle. What can you say about its motion?

Watch the change in density distribution as the model runs.

As the model runs, what happens to the average speed and kinetic energy of the particles?  If they gain energy, where does it come from?   What happens to the speed and energy distributions?

What is the shape of the path of individual particles?

What happens to the aggregate temperature plot over time? Is the temperature uniform over the box?

## THINGS TO TRY

What happens when gravity is increased or decreased?

Change the initial number, speed and mass.  What happens to the density distribution?

Does this model come to some sort of equilibrium?  How can you tell when it has been reached?

Try and find out if the distribution of the particles in this model is the same as what is predicted by conventional physical laws.

Try making gravity negative.

Varying model parameters such as NUMBER and GRAVITY, what do you observe about the aggregate temperature graph?  Can you explain these results?  How would you square these results with a) the fact that "hot air rises" in a room and b) that it is colder as you go higher in elevation?

## EXTENDING THE MODEL

Try this model with particles of different masses.  You could color each mass differently to be able to see where they go.  Are their distributions different?  Do the different masses tend to have different average heights?  What does this suggest about the composition of an atmosphere?

This basic model could be used to explore other situations where freely moving particles have forces on them --- e.g. a centrifuge or charged particles (ions) in an electrical field.

## NETLOGO FEATURES

Because of the influence of gravity, the particles follow curved paths.  Since NetLogo models time in discrete steps, these curved paths must be approximated with a series of short straight lines.  This is the source of a slight inaccuracy where the particles gradually lose energy if the model runs for a long time.  (The effect is as though the collisions with the ground were slightly inelastic.)  The inaccuracy can be reduced by increasing `vsplit`, but the model will run slower.

## RELATED MODELS

This model is part of the GasLab suite and curriculum.  See, in particular, Gas in a Box and GasLab Atmosphere.

## CREDITS AND REFERENCES

This model was developed as part of the GasLab curriculum (http://ccl.northwestern.edu/curriculum/gaslab/) and has also been incorporated into the Connected Chemistry curriculum (http://ccl.northwestern.edu/curriculum/ConnectedChemistry/)


## HOW TO CITE

If you mention this model in a publication, we ask that you include these citations for the model itself and for the NetLogo software:

* Wilensky, U. (2002).  NetLogo GasLab Gravity Box model.  http://ccl.northwestern.edu/netlogo/models/GasLabGravityBox.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.
* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

## COPYRIGHT AND LICENSE

Copyright 2002 Uri Wilensky.

![CC BY-NC-SA 3.0](http://i.creativecommons.org/l/by-nc-sa/3.0/88x31.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.

This model was created as part of the projects: PARTICIPATORY SIMULATIONS: NETWORK-BASED DESIGN FOR SYSTEMS LEARNING IN CLASSROOMS and/or INTEGRATED SIMULATION AND MODELING ENVIRONMENT. The project gratefully acknowledges the support of the National Science Foundation (REPP & ROLE programs) -- grant numbers REC #9814682 and REC-0126227.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

clock
true
0
Circle -7500403 true true 30 30 240
Polygon -16777216 true false 150 31 128 75 143 75 143 150 158 150 158 75 173 75
Circle -16777216 true false 135 135 30

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plane
false
0
Rectangle -7500403 true true 30 30 270 270

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.1.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
