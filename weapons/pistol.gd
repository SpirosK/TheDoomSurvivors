extends Area2D

var enemies_in_range_now = 0

## Each tick it gets the enemies in range and targets the closest one
#
func _physics_process(_delta):
	var enemies_in_range = get_overlapping_bodies()
	
	if enemies_in_range.size() > 0:
		var target_enemy = enemies_in_range[0]
		look_at(target_enemy.global_position)
	
	enemies_in_range_now = enemies_in_range.size()
	
## Function that is called in order to disable itself.
# Actually stopes the timer (no shooting) and becomes invisible
func disable_me():
	$pistol_pivot/Pistol_model.set_deferred("visible", false)
	%pistol_timer.stop()

## Function that is called in order to enable itself.
# Becomes visible and timer starts again!
func enable_me():
	$pistol_pivot/Pistol_model.set_deferred("visible", true)
	%pistol_timer.start()
	
## This function shoots the gun (is called on timer event)
#  It: checks for enemies, checks and spends the ammo, plays the sound, creates the rocket!
#
func shoot():
	const BULLET = preload("res://weapons/projectiles/bullet.tscn")
	
	#not shooting if noone to shoot
	if enemies_in_range_now <= 0:
		return
	
	%pistol_sound.global_position = %pistol_muzzle.global_position
	%pistol_sound.play()
	
	var new_bullet = BULLET.instantiate()
	new_bullet.global_position = %pistol_muzzle.global_position
	new_bullet.global_rotation = %pistol_muzzle.global_rotation
	#Adding to parent (the player) so they don't disappear when weapon changes etc
	get_parent().add_child(new_bullet)

## Shoot timer timeout
#
func _on_timer_timeout():
	shoot()
