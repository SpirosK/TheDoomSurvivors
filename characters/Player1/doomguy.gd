## The Doomguy Sprite
#
extends Node2D

## IDLE ANIMATION
#
func play_idle_animation():
	%doomguy_animation.play("walk_down")

## WALK ANIMATION (depends on direction sent)
#
func play_walk_animation(direction):
	match direction:
		"U ":
			%doomguy_animation.play("walk_up")
		"D ":
			%doomguy_animation.play("walk_down")
		" L":
			%doomguy_animation.play("walk_left")
		" R":
			%doomguy_animation.play("walk_right")
		"DL":
			%doomguy_animation.play("walk_down_left")
		"DR":
			%doomguy_animation.play("walk_down_right")
		"UL":
			%doomguy_animation.play("walk_up_left")
		"UR":
			%doomguy_animation.play("walk_up_right")

