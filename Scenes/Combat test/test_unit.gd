extends CharacterBody2D

enum Faction { FRIENDLY = 1, ENEMY = 2 }
@export var faction: Faction = Faction.FRIENDLY
@export var stats: UnitStats #script
@export var unit_type: String
var Unit_in_Battle: bool = false
@export var target: Node2D = null  # the unit’s current target
@export var Current_hp: int
@export var Projectile: PackedScene
@export var sprite: AnimatedSprite2D
@onready var health_bar = $HealthBar
@onready var camera2D : Camera2D = get_tree().current_scene.get_node("Camera2D")
@export var cameraShakeNoise : FastNoiseLite

func _ready():
	cameraShakeNoise = FastNoiseLite.new()
	# Load stats if none assigned
	if stats == null:
		var path = "res://Resources/units/%s.tres" % unit_type
		var res = load(path)
		if res and res is UnitStats:
			stats = res
		else:
			push_warning("UnitStats resource not found at %s" % path)
	var file_name = stats.resource_path.get_file().get_basename()

	if faction == 1:
		name = "Player_" + file_name + "_unit"

	else:
		name = "Enemy_" + file_name + "_unit"
	Current_hp = stats.max_hp
	sprite = $AnimatedSprite2D
	#match unit_type:
		#"Archer":
			#sprite.modulate = Color(0.197, 0.596, 0.148, 1.0)
		#"Knight":
			#sprite.modulate = Color(0.478, 0.369, 0.369, 1.0)
		#"Warrior":
			#sprite.modulate = Color(0.5, 0.5, 0.5)
		#"Pirate":
			#sprite.modulate = Color(0.462, 0.0, 0.484, 1.0)
	sprite.sprite_frames = stats.sprite_frames
	sprite.play("default")
	var ring1: Sprite2D = $faction_Ring1
	var ring2: Sprite2D = $faction_Ring2

	# Flip the unit if it's an enemy
	sprite.flip_h = (faction == Faction.ENEMY)
	if faction == Faction.ENEMY:
		health_bar.position = Vector2(8,-4)
	# Show correct faction ring
	ring1.visible = (faction == Faction.FRIENDLY)
	ring2.visible = (faction == Faction.ENEMY)

	# Connect to battle start
	var combat_system_node = get_tree().get_current_scene()
	if combat_system_node:
		var combat_system = combat_system_node as CombatSystem  # cast to your script type
		if combat_system:
			if combat_system.Battle_has_begun:
				_on_battle_start()
			else:
				set_process(true)  # start polling in _process()

func _process(delta):
	var combat_system_node = get_tree().get_current_scene()
	if combat_system_node:
		var combat_system = combat_system_node as CombatSystem
		if combat_system and combat_system.Battle_has_begun:
			_on_battle_start()
			set_process(false)  # stop checking after battle starts
			
var target_cooldown: float = 0.8  # seconds between target checks
var time_since_last_target: float = 0.0


var time_since_last_attack: float = 0.0
func _physics_process(delta):
	if not Unit_in_Battle or Current_hp <= 0:
		return

	# Update cooldown timer
	time_since_last_target += delta

	# Only pick a new target if cooldown has passed
	if time_since_last_target >= target_cooldown or target == null or not is_instance_valid(target):
		_choose_target()
		time_since_last_target = 0.0

	if target == null:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	var distance_to_target = global_position.distance_to(target.global_position)
	var direction = (target.global_position - global_position).normalized()
	
	if distance_to_target > stats.range:
		velocity = direction * stats.movement_speed
		if sprite.animation == "default":
			sprite.play("run")
	else:
		if sprite.animation == "run":
			sprite.play("default")
		velocity = Vector2.ZERO
		time_since_last_attack += delta
		if time_since_last_attack >= stats.attack_speed or target == null or not is_instance_valid(target):
			time_since_last_attack = 0.0
			if Current_hp > 0:
				_on_target_in_range()
	
	move_and_slide()


func _on_battle_start():
	#print(name, " battle has started!")
	Unit_in_Battle = true
	_choose_target()
	# Enable AI, start moving/attacking, etc.
	
func _choose_target():
	var enemies := []
	for unit in get_tree().get_nodes_in_group("units"):
		if unit == self:
			continue
		if unit.faction != faction:
			enemies.append(unit)

	if enemies.is_empty():
		target = null
		return

	var nearest_target: Node2D = enemies[0]
	var nearest_dist := global_position.distance_to(nearest_target.global_position)

	for enemy in enemies:
		var dist = global_position.distance_to(enemy.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest_target = enemy

	target = nearest_target
	#if target:
		#print(name, " is targeting ", target.name)
	#sprite.play("run")

func _on_target_in_range():
	if not Unit_in_Battle or Current_hp <= 0:
		return
	if target == null or not is_instance_valid(target):
		return
	if faction == Faction.ENEMY:
		await get_tree().create_timer(0.25).timeout
	else:
		await  get_tree().create_timer(0.1).timeout
	# Basic attack printout
	if not Unit_in_Battle or Current_hp <= 0:
		return
	if Current_hp <= 0 or not is_instance_valid(self):
		return
	if stats.type == "melee":
			# Deal damage
		sprite.play("attack")
		if target == null or not is_instance_valid(target):
			return
		if target.has_method("take_damage"):
			if(target.Current_hp > 0):
				target.take_damage(stats.damage)
		#print(target.name, " HP:", target.Current_hp, "/", target.stats.max_hp)
		#print(name, " has stabbed ", target.name)
	else:
		on_shoot()
		
		#print(name, " has shot ", target.name)
		
	# Check for death
	#if target.Current_hp <= 0:
		##print(target.name, " has been defeated!")
		#target.queue_free()
		#target = null
func on_shoot():

	var i = 0
	while i < stats.attack_amount:
		sprite.play("attack")
		await sprite.animation_finished
		if target == null or not is_instance_valid(target):
			return
		var Fired_Projectile = Projectile.instantiate()
		if faction == 1:
			Fired_Projectile.collision_layer = 1   # Layer: PlayerUnits
			Fired_Projectile.collision_mask = 2    # Mask: collides with EnemyUnits
		else:
			Fired_Projectile.collision_layer = 2   # Layer: PlayerUnits
			Fired_Projectile.collision_mask = 1    # Mask: collides with EnemyUnits
		Fired_Projectile.projectile = stats.projectile
		Fired_Projectile.position = global_position + Vector2(0,10)
		Fired_Projectile.direction = (target.global_position - Fired_Projectile.position).normalized()
		#Fired_Projectile.speed = stats.attack_speed
		#Fired_Projectile.owner_faction = faction
		Fired_Projectile.damage = stats.damage
		Fired_Projectile.target = target
		get_parent().add_child(Fired_Projectile)
		await get_tree().create_timer(0.1).timeout
		i += 1

func take_damage(amount):
	#print(name, " took ", amount, " damage!")
	Current_hp -= amount
	if Current_hp < 0:
		Current_hp = 0
	var tween = get_tree().create_tween()
	tween.tween_method(setshader_BlinkIntensity, 1.0, 0.0, 0.5)
	
	var camera_tween = get_tree().create_tween()
	camera_tween.tween_method(Callable(self, "StartCameraShake"), 5.0, 0.0, 0.5)

	update_health_bar()
	if Current_hp <= 0:
		#Log_combat(1,amount)
		if sprite.animation != "dead":
			sprite.play("dead")
		await sprite.animation_finished
		free()
	# TODO: Subtract health, trigger animation, check death, etc.

func update_health_bar():
	if health_bar and health_bar.has_node("Foreground"):
		var health_ratio = float(Current_hp) / float(stats.max_hp)
		var foreground = health_bar.get_node("Foreground")
		foreground.scale.x = health_ratio
		
		# Change color based on health
		if health_ratio > 0.6:
			foreground.modulate = Color.GREEN
		elif health_ratio > 0.3:
			foreground.modulate = Color.YELLOW
		else:
			foreground.modulate = Color.RED

func StartCameraShake(intensity: float) -> void:
	if camera2D == null:
		return

	# Time in seconds, scaled so noise changes quickly
	var t := float(Time.get_ticks_msec()) * 0.01

	var noise_x := cameraShakeNoise.get_noise_1d(t)
	var noise_y := cameraShakeNoise.get_noise_1d(t + 200.0) # offset so x & y differ

	# noise is usually in -1..1, so multiply by intensity for pixels
	camera2D.offset.x = noise_x * intensity
	camera2D.offset.y = noise_y * intensity

func setshader_BlinkIntensity(newValue : float):
	sprite.material.set_shader_parameter("blink_intensity", newValue)

#func Log_combat(event, ammount):
	#print("COMBAT LOG: event " , event, " caused ", ammount, " damage")
