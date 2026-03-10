extends CharacterBody3D

enum MoveState { WALK, SPRINT, SLIDE, AIR, LAND }

@export var walk_speed := 5.0
@export var sprint_speed := 10.0
@export var slide_start_speed := 14.0
@export var crouch_speed := 2.5
@export var accel := 16.0
@export var jump_velocity := 7.8
@export var mouse_sensitivity := 0.0018
@export var coyote_time := 0.15
@export var slide_duration := 0.75

@onready var pivot: Node3D = $Pivot
@onready var camera: Camera3D = $Pivot/Camera3D
@onready var weapon_socket: Node3D = $Pivot/WeaponSocket

var state: MoveState = MoveState.WALK
var gravity := ProjectSettings.get_setting("physics/3d/default_gravity") as float
var coyote_timer := 0.0
var slide_timer := 0.0
var slide_vector := Vector3.ZERO
var look_x := 0.0
var active_weapon: Node = null
var weapons: Array[Node] = []
var hp := 100.0
var shield := 50.0

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	GameManager.register_player(self)
	_collect_weapons()
	_set_weapon(0)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		look_x = clamp(look_x - event.relative.y * mouse_sensitivity, -1.35, 1.35)
		pivot.rotation.x = look_x
	if event.is_action_pressed("pause"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	_update_state(delta)
	_apply_gravity(delta)
	_handle_jump()
	_handle_move(delta)
	_handle_camera(delta)
	_handle_actions()
	move_and_slide()

func _update_state(delta: float) -> void:
	if is_on_floor():
		coyote_timer = coyote_time
		if state == MoveState.AIR:
			state = MoveState.LAND
	elif coyote_timer > 0.0:
		coyote_timer -= delta
	else:
		state = MoveState.AIR

	if state == MoveState.SLIDE:
		slide_timer -= delta
		if slide_timer <= 0.0:
			state = MoveState.WALK

	if Input.is_action_pressed("sprint") and is_on_floor() and state != MoveState.SLIDE:
		state = MoveState.SPRINT
	elif state in [MoveState.SPRINT, MoveState.LAND] and not Input.is_action_pressed("sprint"):
		state = MoveState.WALK

	if Input.is_action_just_pressed("slide") and is_on_floor() and state == MoveState.SPRINT:
		state = MoveState.SLIDE
		slide_timer = slide_duration
		slide_vector = -global_transform.basis.z

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

func _handle_jump() -> void:
	if Input.is_action_just_pressed("jump") and (is_on_floor() or coyote_timer > 0.0):
		var was_sliding := state == MoveState.SLIDE
		velocity.y = jump_velocity
		state = MoveState.AIR
		if was_sliding:
			velocity += slide_vector * 4.0

func _handle_move(delta: float) -> void:
	var input_vec := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (global_transform.basis * Vector3(input_vec.x, 0.0, input_vec.y))
	direction.y = 0.0
	direction = direction.normalized()
	var target_speed := walk_speed
	match state:
		MoveState.SPRINT:
			target_speed = sprint_speed
		MoveState.SLIDE:
			target_speed = crouch_speed
		MoveState.AIR:
			target_speed = walk_speed
	if state == MoveState.SLIDE:
		var slide_vel := slide_vector * slide_start_speed
		slide_vel.y = velocity.y
		velocity = velocity.lerp(slide_vel, delta * 5.0)
	else:
		var target_vel := direction * target_speed
		target_vel.y = velocity.y
		velocity = velocity.lerp(target_vel, delta * accel)

func _handle_camera(delta: float) -> void:
	var target_fov := 60.0 if Input.is_action_pressed("ads") else 90.0
	camera.fov = lerp(camera.fov, target_fov, delta * 10.0)
	var slide_tilt := -0.08 if state == MoveState.SLIDE else 0.0
	var land_bounce := 0.03 if state == MoveState.LAND else 0.0
	pivot.rotation.z = lerp(pivot.rotation.z, slide_tilt, delta * 12.0)
	camera.position.y = lerp(camera.position.y, 0.0 + land_bounce, delta * 10.0)

func _handle_actions() -> void:
	if active_weapon == null:
		return
	if Input.is_action_pressed("fire"):
		active_weapon.try_fire(self)
	if Input.is_action_just_pressed("reload"):
		active_weapon.reload()
	if Input.is_action_just_pressed("weapon_1"):
		_set_weapon(0)
	if Input.is_action_just_pressed("weapon_2"):
		_set_weapon(1)
	if Input.is_action_just_pressed("weapon_3"):
		_set_weapon(2)
	if Input.is_action_just_pressed("weapon_4"):
		_set_weapon(3)

func _collect_weapons() -> void:
	for child in weapon_socket.get_children():
		weapons.append(child)
		child.visible = false

func _set_weapon(index: int) -> void:
	if index < 0 or index >= weapons.size():
		return
	for w in weapons:
		w.visible = false
	active_weapon = weapons[index]
	active_weapon.visible = true
	GameManager.report_weapon(active_weapon.weapon_name, active_weapon.current_ammo, active_weapon.magazine_size)

func apply_damage(amount: float) -> void:
	var remainder := amount
	if shield > 0.0:
		var absorbed := min(shield, remainder)
		shield -= absorbed
		remainder -= absorbed
	hp = max(0.0, hp - remainder)
	GameManager.report_player_health(hp, shield)
