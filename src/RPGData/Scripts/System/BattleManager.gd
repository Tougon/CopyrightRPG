extends Node

# Class that defines constant variables for the battle system
const INSTANCE_BATTLE_WINDOW : bool = false;

# Determines the length of the tweens for enemy repositioning
const ENEMY_REPOSITION_TIME : float = 0.35;

# Determines if text should print asynchonously
# TODO: change to const
var async_damage_text : bool = false;
var async_crit_text : bool = true;
var seal_before_attacking : bool = true;

# Determines level cap
# TODO: change to const
var level_cap : int = 99;

# Determines if a battle is active
var is_battle_active : bool = false;

# Reference to the SealManager so it can be grabbed easily
var seal_manager : SealManager;

# Reference to the Dialogue Canvas so it can be grabbed easily
var dialogue_canvas : DialogueCanvas;
