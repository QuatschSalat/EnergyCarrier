extends Node

var sound_on = true
var music_on = true

var debug_mode = true

# Called when the node enters the scene tree for the first time.
func _ready():
	if debug_mode:
		OS.window_position.y = 0


# TODO
# - Car collision

# Possibles future Updates
#
# - Better collision detection between cars to avoid spending power in traffic jams.
# - More NPC people and cars to fill the scene with life.
# - Maybe some random power ups. e.g. run faster, faster cars, bigger batteries, etc.
# - Reduce car nodes to a single one
# - -> Change car color randomly
# - Music can be disabled
# - Sound can be disabled 
