extends Node2D

#################
#GAME DESIGN NOTE
#################
# I have set every config in global variables so that it is as extensible as possible (also for easy debegging).
# Sadly, I only learned about Singletons during the end of making this :( (and it's Out-Of-Scope rebuilding around it)
# My final design is 10 levels total with 4 sublevels each (except the two boss levels)
#
var level = 1
var sublevel = 1
const TOTAL_LEVELS_IN_GAME = 10
const SUBLEVELS_PER_LEVEL = [4, 4, 4, 4, 4, 4, 1, 4, 4, 1]

## How much health is added per successful Sublevel and Level
# Without medikits, this was much needed (Design notes)
#
const ADD_HEALTH_PER_SUBLEVEL = 10
const ADD_HEALTH_PER_LEVEL = 30

## The number of enemies needed to kill in order to change the sublevel per level
# Adjust to adjust difficulty! (Design notes)
#
var sublevel_kills = 0
const ENEMIES_TO_CHANGE_SUBLEVEL = [5, 5, 6, 6, 7, 7, 1, 8, 9, 3]

const INITIAL_TIMER_TIMOUT = 0.96
const MAX_ENEMIES_AT_ONCE_BASE = 11 #more than that  (+level added) it's a bit overkill

const BOSS_LEVELS = [7, 10] #where the bosses appear
const BOSS_NUMBERS = [1, 3] #how many bosses appear (1-to-1 with above)

## These would normally be in singleton, as they need to be the same in player1 too
const PISTOL_AMMO = 0
const MGUN_AMMO = 1
const SHOTGUN_AMMO = 2
const ROCKETS = 3
const PLASMA = 4
const BFG_AMMO = 5
## How many of its ammo are added per level completion! 
# This was needed as I have no ammo clips. I explored the option of them appearing randomly, I didn't like it
#pistol bullets(INF), mgun bullets, shells, rockets, cells, BFG cells
const LEVEL_AMMO_ADD =[
	[0, 000, 10, 0, 0, 0],
	[0, 100, 10, 0, 0, 0],
	[0, 100, 20, 0, 0, 0],
	[0, 150, 20, 2, 0, 0],
	[0, 200, 30, 5, 0, 0],
	[0, 200, 30, 5, 0, 0],
	[0, 200, 30, 5, 50, 1],
	[0, 300, 40, 5, 50, 1],
	[0, 300, 40, 10, 50, 1],
	[0, 300, 50, 10, 100, 2],
]


## This functions draws the ammo labels on screen
func draw_ammo():
	var ammo_now = %Player1.ammo_now
	%lbl_bullets.text = str(ammo_now[1])
	%lbl_shells.text = str(ammo_now[2])
	%lbl_rockets.text = str(ammo_now[3])
	%lbl_cells.text = str(ammo_now[4])
	%lbl_blasts.text = str(ammo_now[5])

## This functions adds the ammo for the current level!
func add_level_ammo(level_num):
	%Player1.add_ammo(MGUN_AMMO, LEVEL_AMMO_ADD[level_num-1][MGUN_AMMO])
	%Player1.add_ammo(SHOTGUN_AMMO, LEVEL_AMMO_ADD[level_num-1][SHOTGUN_AMMO])
	%Player1.add_ammo(ROCKETS, LEVEL_AMMO_ADD[level_num-1][ROCKETS])
	%Player1.add_ammo(PLASMA, LEVEL_AMMO_ADD[level_num-1][PLASMA])
	%Player1.add_ammo(BFG_AMMO, LEVEL_AMMO_ADD[level_num-1][BFG_AMMO])
	draw_ammo()

## This functions heals the player for the current level!
func add_player_health(health):
	%Player1.add_health(health)
	
## Ready, set, go!
func _ready():
	%GameTimer.wait_time = INITIAL_TIMER_TIMOUT
	add_level_ammo(1)
	spawn_enemy()
	spawn_enemy()
	spawn_enemy()


## This functions spawns enemies in the level. Check inline comments for more info
#
func spawn_enemy():
	#Enemies killed updated.
	%enemies_killed_label2.text = "L" + str(level) + "-" + str(sublevel) + ":" + str(sublevel_kills)

	var enm_pistol = preload("res://characters/enemies/zombie1.tscn").instantiate()
	var enm_shotgun = preload("res://characters/enemies/zombie2.tscn").instantiate()
	var enm_pinkie = preload("res://characters/enemies/pinkie.tscn").instantiate()
	var enm_imp = preload("res://characters/enemies/imp.tscn").instantiate()
	var enm_knight = preload("res://characters/enemies/knight.tscn").instantiate()
	var enm_cyberdemon = preload("res://characters/enemies/CyberD.tscn").instantiate()
	var new_enemy
	
	## The chance of enemies appearing is handled by this matrix. Each position gives a 10% matrix.
	# I also experimented with absolute possibility per enemy, but it was a big fuss to keep checking if they add up to 100%
	#
	# LEVEL1: 100% chance for pistol-zombie
	# LEVEL2: 60% chance for pistol-zombie, 40% for shotgun-zombie
	# LEVEL3: 50% chance for pistol-zombie, 30% for shotgun-zombie, 20% for pinkie
	# LEVEL4: 40% chance for pistol-zombie, 20% for shotgun-zombie  20% pinkie, 20% imp
	# LEVEL5: 20% chance for pistol-zombie, 20% for shotgun-zombie  30% pinkie, 30% imp
	# LEVEL6: 50% pinkie, 50% imp
	# LEVEL8: 40% pinkie, 40% imp, 20% barons
	# LEVEL9: 50% barons, 50% pinkie
	var enemies_in_levels_probability =[
		[enm_pistol, enm_pistol, enm_pistol, enm_pistol, enm_pistol, enm_pistol, enm_pistol, enm_pistol, enm_pistol, enm_pistol],
		[enm_pistol, enm_pistol, enm_pistol, enm_pistol, enm_pistol, enm_pistol, enm_shotgun, enm_shotgun, enm_shotgun, enm_shotgun],
		[enm_pistol, enm_pistol, enm_pistol, enm_pistol, enm_pistol, enm_pinkie, enm_pinkie, enm_shotgun, enm_shotgun, enm_shotgun],
		[enm_pistol, enm_pistol, enm_pistol, enm_pistol, enm_pinkie, enm_pinkie, enm_imp, enm_imp, enm_shotgun, enm_shotgun],
		[enm_pistol, enm_pistol, enm_pinkie, enm_pinkie, enm_pinkie, enm_imp, enm_imp, enm_imp, enm_shotgun, enm_shotgun],
		[enm_pinkie, enm_pinkie, enm_pinkie, enm_pinkie, enm_pinkie, enm_imp, enm_imp, enm_imp, enm_imp, enm_imp],
		[], #boss level
		[enm_pinkie, enm_pinkie, enm_pinkie, enm_pinkie, enm_knight, enm_knight, enm_imp, enm_imp, enm_imp, enm_imp],
		[enm_pinkie, enm_pinkie, enm_pinkie, enm_pinkie, enm_pinkie, enm_knight, enm_knight, enm_knight, enm_knight, enm_knight],
		[] #boss level
	]
	
	#not spwaning more than (Max Enemies for this level + Base Number)  enemies
	# Essentially: Bigger levels ==> More enemies
	if get_tree().get_nodes_in_group("enemies").size() >= MAX_ENEMIES_AT_ONCE_BASE + level:
		return

	#ONLY HAPPENS WHEN DEBUGGING!! 
	#(doesn't hurt, so I left it in, in case I need to debug in the future)
	if level == BOSS_LEVELS[0] and get_tree().get_nodes_in_group("enemies").size() >= BOSS_NUMBERS[0]:
		return
	if level == BOSS_LEVELS[1] and get_tree().get_nodes_in_group("enemies").size() >= BOSS_NUMBERS[1]:
		return

	## First Boss Level: 1 Cyberdemon and pause the spawn timer
	if level == BOSS_LEVELS[0] and get_tree().get_nodes_in_group("enemies").size() < BOSS_NUMBERS[0]:
		%GameTimer.set_paused(true)
		new_enemy = enm_cyberdemon
		%PathFollow2D.progress_ratio = randf()
		new_enemy.global_position = %PathFollow2D.global_position
		new_enemy.enemy_died.connect(_on_enemy_died)
		new_enemy.add_to_group("enemies")
		add_child(new_enemy)
		return

	## Last Boss Level: 3 Cyberdemons and pause the spawn timer
	if level == BOSS_LEVELS[1] and get_tree().get_nodes_in_group("enemies").size() < BOSS_NUMBERS[1]:
		new_enemy = enm_cyberdemon
		%PathFollow2D.progress_ratio = randf()
		new_enemy.global_position = %PathFollow2D.global_position
		new_enemy.enemy_died.connect(_on_enemy_died)
		new_enemy.add_to_group("enemies")
		add_child(new_enemy)
		if get_tree().get_nodes_in_group("enemies").size() == BOSS_NUMBERS[1]:
			%GameTimer.set_paused(true) #spawn no more
		return
		
	## Not in Boss Levels: Spawn Enemies based on above probability!
	if BOSS_LEVELS.find(level) == -1: 
		var next_enemy = randi() % 10 # 0 to 9 --> array positions
		new_enemy = enemies_in_levels_probability[level-1][next_enemy]

	%PathFollow2D.progress_ratio = randf()
	new_enemy.global_position = %PathFollow2D.global_position
	new_enemy.enemy_died.connect(_on_enemy_died)
	new_enemy.add_to_group("enemies")
	add_child(new_enemy)

## Timer Function: Spawns enemies when it's time!
#
func _on_timer_timeout():
	spawn_enemy()

## Oh no, how horrible!
#
func _on_player_1_player_died():
	%GameOver.visible = true
	get_tree().paused = true

## Logistics for enemy death: Did we pass to new sublevel/level?
#
func _on_enemy_died():
	sublevel_kills += 1
	%enemies_killed_label2.text = "L" + str(level) + "-" + str(sublevel) + ":" + str(sublevel_kills)

	# Initially had a special case for boss levels. With the new structure, it's handled automatically!
	if sublevel_kills >= ENEMIES_TO_CHANGE_SUBLEVEL[level-1]:
		%GameTimer.wait_time = %GameTimer.wait_time / 2
		sublevel += 1
		add_player_health(ADD_HEALTH_PER_SUBLEVEL)

		sublevel_kills = 0
		%GameTimer.set_paused(false)
		if sublevel > SUBLEVELS_PER_LEVEL[level-1]:
			inc_level()
	%enemies_killed_label2.text = "L" + str(level) + "-" + str(sublevel) + ":" + str(sublevel_kills)

## This function makes all changes required when changing a level:
# set new sublevel number, set level number, reset timer, kill_all_existing_enemies + projectiles, change music
# and (of course) before all else --> end game if we did all levels!!
func inc_level():
	#The end if we reached the max lavel
	if level == TOTAL_LEVELS_IN_GAME:
		%TheEnd.visible = true
		%the_end_anim.play("the_end") #welcome to the infinite loop
		%GameTimer.set_paused(true)
		return

	#destroy all existing enemies and projectiles, as new ones will come!
	for node in  get_tree().get_nodes_in_group("enemies"):
		node.queue_free()
	for node in  get_tree().get_nodes_in_group("projectiles"):
		node.queue_free()
	
	#If not, let's reset sublevels and heal/equip the player!	
	sublevel = 1
	level += 1
	add_player_health(ADD_HEALTH_PER_LEVEL)
	# Shouldn't be possible anymore.... :)
	if level > TOTAL_LEVELS_IN_GAME:
		%GameOver.visible = true
		get_tree().paused = true
		
	add_level_ammo(level)
	%GameTimer.wait_time = INITIAL_TIMER_TIMOUT
	%level_music.stream  = load("res://music/level"+ str(level) +".mp3")
	%level_music.play()
