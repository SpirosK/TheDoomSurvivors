## The Player (includes the Sprite too).
# Also carries the ammo. Iinitially had it in the game object, but felt more "natural" to be here. (design choices)
#
extends CharacterBody2D

const PLAYER_HEALTH = 100
const PLAYER_SPEED = 600

signal player_died   #custom signal to activate "Death Screen"

var health = PLAYER_HEALTH
#(design notes) Initially I had the ammo tied to the game.
#This way one can have other-player-models (in imaginary scenario) with different ammo payloads!
#Ammo Array ==> pistol (INF), shotgun, machinegun, rockets, plasma, BFG blasts
var ammo_now = [-1, 5, 0, 0, 0 ,0]

#These consts would normally be in singleton, as they need to be the same in game too
const MGUN_AMMO = 1
const SHOTGUN_AMMO = 2
const ROCKET_AMMO = 3
const PLASMA = 4
const BFG_AMMO = 5
const MAX_WEAPONS_AMMO_NUM = 5

## Beginning: We set all weapons except pistol to disabled
#
func _ready():
	switch_to_pistol()

## If ammo is done? ==> switch to pistol (infinite ammo)
#
func ammo_done():
	switch_to_pistol()

## Adds ammo to the weapon (no max capacity, design notes)
#
func add_ammo(weapon:int, quantity:int) -> void:
	if weapon > MAX_WEAPONS_AMMO_NUM or weapon <= 0:
		printerr ("There must be a bug here! P1aa")
		return
	ammo_now[weapon] = ammo_now[weapon] + quantity

## Adds Health to the player
#
func add_health(added_health:int) -> void:
	health = clampi(health + added_health, 0, 100) #max=100 no matter what (design notes)
	%PlayerHealthBar.value = health

## Returns the ammo of the weapon (or 0 if wrong weapon)
#
func get_ammo(weapon:int) -> int:
	if weapon > MAX_WEAPONS_AMMO_NUM or weapon <= 0:
		printerr ("There must be a bug here! P1ga")
		return 0
	return ammo_now[weapon]

## Have it in a function in order to enable (possible future) powerups (e.g. quad shot)
#  or to enable, for example, the BFG spending 40 cells, instead of 1 BFG blast
#
func spend_ammo (weapon:int, quantity:int) -> void:
	if weapon > MAX_WEAPONS_AMMO_NUM or weapon <= 0 or quantity <= 0:
		printerr ("There must be a bug here! P1sa1")
		return
	ammo_now[weapon] = ammo_now[weapon] - quantity
	if ammo_now[weapon] < 0:
		printerr ("There might be a bug here! P1sa2")
		ammo_now[weapon] = 0
	get_parent().draw_ammo()

## Setting all weapons to disabled and pistol to enabled
#
func switch_to_pistol() -> void:
	%weapon_shotgun.disable_me()
	%weapon_mgun.disable_me()
	%weapon_rocket.disable_me()
	%weapon_plasma.disable_me()
	%weapon_bfg.disable_me()
	%weapon_pistol.enable_me()

## Setting all weapons to disabled and shotgun to enabled
#
func switch_to_shotgun() -> void:
	%weapon_pistol.disable_me()
	%weapon_mgun.disable_me()
	%weapon_rocket.disable_me()
	%weapon_plasma.disable_me()
	%weapon_bfg.disable_me()
	%weapon_shotgun.enable_me()

## Setting all weapons to disabled and machine gun to enabled
#
func switch_to_mgun() -> void:
	%weapon_pistol.disable_me()
	%weapon_shotgun.disable_me()
	%weapon_rocket.disable_me()
	%weapon_plasma.disable_me()
	%weapon_bfg.disable_me()
	%weapon_mgun.enable_me()

## Setting all weapons to disabled and rocket launcher to enabled
#
func switch_to_rocket() -> void:
	%weapon_pistol.disable_me()
	%weapon_shotgun.disable_me()
	%weapon_mgun.disable_me()
	%weapon_plasma.disable_me()
	%weapon_bfg.disable_me()
	%weapon_rocket.enable_me()

## Setting all weapons to disabled and plasma gun to enabled
#
func switch_to_plasma() -> void:
	%weapon_pistol.disable_me()
	%weapon_shotgun.disable_me()
	%weapon_mgun.disable_me()
	%weapon_rocket.disable_me()
	%weapon_bfg.disable_me()
	%weapon_plasma.enable_me()
	
## Setting all weapons to disabled and bfg to enabled
#
func switch_to_bfg() -> void:
	%weapon_pistol.disable_me()
	%weapon_shotgun.disable_me()
	%weapon_mgun.disable_me()
	%weapon_rocket.disable_me()
	%weapon_plasma.disable_me()
	%weapon_bfg.enable_me()
	

## This function handles the weapon change
# Basically switches to the proper weapon, 
# unless there is no ammo, in which case: to the "infinite" pistol
#
func _input(event):
	if event.is_action_pressed("weapon2"):
		switch_to_pistol()
	if event.is_action_pressed("weapon3"):
		if ammo_now[SHOTGUN_AMMO] <= 0:
			switch_to_pistol()
		else:
			switch_to_shotgun()
	if event.is_action_pressed("weapon4"):
		if ammo_now[MGUN_AMMO] <= 0:
			switch_to_pistol()
		else:
			switch_to_mgun()
	if event.is_action_pressed("weapon5"):
		if ammo_now[ROCKET_AMMO] <= 0:
			switch_to_pistol()
		else:
			switch_to_rocket()
	if event.is_action_pressed("weapon6"):
		if ammo_now[PLASMA] <= 0:
			switch_to_pistol()
		else:
			switch_to_plasma()
	if event.is_action_pressed("weapon7"):
		if ammo_now[BFG_AMMO] <= 0:
			switch_to_pistol()
		else:
			switch_to_bfg()


## At each tick: moves according to the button input
# move_and_slide ==> does the move (irrespective of animation)
# DoomGuy ==> plays the appropriate animation
#
func _physics_process(_delta):
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * PLAYER_SPEED
	move_and_slide()
	
	var LR_dir = " "
	var UD_dir = " "
	if velocity.length() > 0.0:
		if direction[0] < 0:
			LR_dir = "L"
		elif direction[0] > 0:
			LR_dir = "R"
		else:
			LR_dir = " "

		if direction[1] < 0:
			UD_dir = "U"
		elif direction[1] > 0:
			UD_dir = "D"
		else:
			UD_dir = " "
		
		%DoomGuy.play_walk_animation(UD_dir+LR_dir)
	else:
		%DoomGuy.play_idle_animation()

	#An idea for possible future chainsaw use
	#const DMG_RATE = 6.66
	#var overlapping_enemies = %HurtBox.get_overlapping_bodies()
	#if overlapping_enemies.size() > 0:
	#	health -= DMG_RATE * overlapping_enemies.size() * delta
	#	%PlayerHealthBar.value = health
	#	if health <= 0.0:
	#		player_died.emit()


## Damage to the player is:
#  1.subtracted from health, 2.shown on bar and 3.death-checked
#
func take_damage(dmg: int) -> void:
	health = clampi(health-dmg, 0, 1000)
	%PlayerHealthBar.value = health
	if health <= 0.0:
		player_died.emit()
