extends Node

# Class that defines constant variables for the battle system

# Determines if text should print asynchonously
var async_damage_text : bool = false;
var async_crit_text : bool = true;

# Determines starting level offset for stat calculations
var level_offset : int = 24;

# Reference to the SealManager so it can be grabbed easily
var seal_manager : SealManager;

# Reference to the Dialogue Canvas so it can be grabbed easily
var dialogue_canvas : DialogueCanvas;
