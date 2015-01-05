GasLabModules
=============

Common files for GasLab-like models

I took a stab at creating GasLab modules that can be loaded and used for other GasLab-like models. The *nls files contain the common (and complex) routines and are loaded using the __include command. You can access these files in the code tab using the `Includes` pull down tab.

For now, I just use 3 new routines:
GasLab-init-tick-delta
GasLab-new-tick-delta
GasLab-collision-and-collide

I have modified a couple of GasLab codes to use these:
VMC-GasLab Adiabatic Piston.nlogo
VMC-GasLab Gravity Box.nlogo

