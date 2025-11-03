# Unit.gd
extends CharacterBody2D
class_name Unit

@export var unit_resource: UnitResource
@onready var animation_player = $AnimationPlayer
@onready var sprite = $AnimatedSprite2D
@onready var health_bar = $HealthBar
@onready var camera: Camera2D = $Camera2D

enum STATE { IDLE, MOVING, ATTACKING, DEAD }
var current_state: STATE = STATE.IDLE
var target: Unit = null
var team: String = "player"
var current_health: int = 0
var max_health: int = 0
var attack_cooldown: float = 0.0
var formation_position: Vector2 = Vector2.ZERO
var is_initialized: bool = false

func _ready():
	# If already initialized, set up normally
	if is_initialized:
		setup_from_resource()
		change_state(STATE.IDLE)
	else:
		# Wait until we're initialized
		set_physics_process(false)

func initialize(resource: UnitResource, unit_team: String, start_position: Vector2):
	unit_resource = resource
	team = unit_team
	position = start_position
	formation_position = start_position
	is_initialized = true
	
	# Setup will happen in _ready() now that we're initialized
	setup_from_resource()
	
	# Enable physics processing now that we're set up
	set_physics_process(true)

func setup_from_resource():
	if not unit_resource:
		push_error("Unit: No unit resource assigned!")
		return
	
	max_health = unit_resource.health
	current_health = max_health
	
	# Safety check for sprite node
	if not sprite:
		push_error("Unit: AnimatedSprite2D node not found! Check scene structure.")
		return
	
	# Set sprite frames if available
	if unit_resource.sprite_frames:
		sprite.sprite_frames = unit_resource.sprite_frames
		sprite.scale = unit_resource.scale
	else:
		push_error("Unit: No sprite frames in resource for " + unit_resource.unit_name)
	
	update_health_bar()

func get_team() -> String:
	return team

func change_state(new_state: STATE):
	if current_state == STATE.DEAD:
		return
		
	current_state = new_state
	
	match current_state:
		STATE.IDLE:
			play_animation(unit_resource.idle_anim)
		STATE.MOVING:
			play_animation(unit_resource.run_anim)
		STATE.ATTACKING:
			play_animation(unit_resource.attack_anim)
		STATE.DEAD:
			play_animation(unit_resource.dead_anim)

func _physics_process(delta):
	if not is_initialized or current_state == STATE.DEAD:
		return
	
	# Handle attack cooldown
	if attack_cooldown > 0:
		attack_cooldown -= delta
	
	match current_state:
		STATE.IDLE, STATE.MOVING:
			handle_combat_movement(delta)
		STATE.ATTACKING:
			# Wait for attack animation to complete
			if animation_player and not animation_player.is_playing():
				find_target()
			elif sprite and not sprite.is_playing():
				find_target()

func handle_combat_movement(delta):
	if not target or (target.has_method("is_dead") and target.is_dead()):
		find_target()
		return
	
	var distance_to_target = position.distance_to(target.position)
	
	if distance_to_target <= unit_resource.attack_range:
		# In range to attack
		velocity = Vector2.ZERO
		change_state(STATE.IDLE)
		
		# Face the target based on team
		update_sprite_direction_to_target()
		
		if attack_cooldown <= 0:
			change_state(STATE.ATTACKING)
			attack_target()
	else:
		# Move towards target
		var direction = (target.position - position).normalized()
		velocity = direction * unit_resource.move_speed
		change_state(STATE.MOVING)
		
		# Update sprite direction while moving
		update_sprite_direction_movement(direction)
	
	move_and_slide()

func update_sprite_direction_to_target():
	if not sprite or not target:
		return
	
	# Simple rule: players face right, enemies face left
	if team == "player":
		sprite.flip_h = target.position.x < position.x
	else:
		sprite.flip_h = target.position.x > position.x

func update_sprite_direction_movement(direction: Vector2):
	if not sprite:
		return
	
	# Simple rule: players face movement direction, enemies face opposite
	if team == "player":
		sprite.flip_h = direction.x < 0
	else:
		sprite.flip_h = direction.x > 0

func attack_target():
	if not target or (target.has_method("is_dead") and target.is_dead()):
		change_state(STATE.IDLE)
		return
	
	attack_cooldown = 1.0 / unit_resource.attack_speed
	
	if unit_resource.has_projectile and unit_resource.projectile_scene:
		spawn_projectile()
	else:
		# Melee attack - immediate damage
		if target.has_method("take_damage"):
			target.take_damage(unit_resource.damage)

func spawn_projectile():
	var projectile = unit_resource.projectile_scene.instantiate()
	
	# Get the projectiles container from the test space
	var test_space = get_tree().get_first_node_in_group("test_space")
	if test_space and test_space.has_node("Projectiles"):
		test_space.get_node("Projectiles").add_child(projectile)
	else:
		# Fallback: add to current scene
		get_parent().add_child(projectile)
	
	# Calculate spawn position with offset
	var spawn_offset = unit_resource.projectile_offset
	if sprite and sprite.flip_h:
		spawn_offset.x *= -1
	
	projectile.position = position + spawn_offset
	if projectile.has_method("initialize"):
		projectile.initialize(team, unit_resource.damage, unit_resource.projectile_speed, target)

func take_damage(amount: int):
	if current_state == STATE.DEAD:
		return
		
	current_health -= amount
	update_health_bar()

	# Trigger camera shake
	
	
	if current_health <= 0:
		die()

func update_health_bar():
	if health_bar and health_bar.has_node("Foreground"):
		var health_ratio = float(current_health) / float(max_health)
		var foreground = health_bar.get_node("Foreground")
		foreground.scale.x = health_ratio
		
		# Change color based on health
		if health_ratio > 0.6:
			foreground.modulate = Color.GREEN
		elif health_ratio > 0.3:
			foreground.modulate = Color.YELLOW
		else:
			foreground.modulate = Color.RED

func die():
	change_state(STATE.DEAD)
	set_physics_process(false)
	collision_layer = 0
	collision_mask = 0
	if health_bar:
		health_bar.visible = false
	
	# Wait for death animation then remove
	await get_tree().create_timer(1.5).timeout
	queue_free()

func find_target():
	var units = get_tree().get_nodes_in_group("units")
	var closest_distance = INF
	var closest_unit: Unit = null
	
	for unit in units:
		if unit.has_method("get_team") and unit.get_team() != team and unit.has_method("is_dead") and not unit.is_dead():
			var distance = position.distance_to(unit.position)
			if distance < closest_distance:
				closest_distance = distance
				closest_unit = unit
	
	target = closest_unit
	if target:
		change_state(STATE.MOVING)

func is_dead() -> bool:
	return current_state == STATE.DEAD

func play_animation(anim_name: String):
	if animation_player and animation_player.has_animation(anim_name):
		animation_player.play(anim_name)
	elif sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation(anim_name):
		sprite.play(anim_name)

func debug_movement():
	if target:
		var distance = position.distance_to(target.position)
		print(unit_resource.unit_name, " [", team, "] - State: ", current_state, 
			  " | Target: ", target.unit_resource.unit_name, 
			  " | Distance: ", distance, 
			  " | Attack Range: ", unit_resource.attack_range,
			  " | Velocity: ", velocity)
	else:
		print(unit_resource.unit_name, " [", team, "] - State: ", current_state, " | No target")
