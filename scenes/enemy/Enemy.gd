extends CharacterBody3D

enum AIState { PATROL, ALERT, ATTACK, DEAD }

@export var move_speed := 3.5
@export var attack_range := 20.0
@export var fire_interval := 1.0

@onready var nav: NavigationAgent3D = $NavigationAgent3D
@onready var waypoints: Node3D = $Waypoints

var state: AIState = AIState.PATROL
var hp := 100.0
var player: Node3D = null
var _fire_cd := 0.0
var _waypoint_idx := 0

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player") as Node3D
	_set_next_waypoint()

func _physics_process(delta: float) -> void:
	if state == AIState.DEAD:
		return
	if player == null:
		player = get_tree().get_first_node_in_group("player") as Node3D
		return
	_fire_cd -= delta
	match state:
		AIState.PATROL:
			_patrol(delta)
			if _can_see_player():
				state = AIState.ALERT
		AIState.ALERT:
			look_at(player.global_position, Vector3.UP)
			state = AIState.ATTACK if global_position.distance_to(player.global_position) < attack_range else AIState.PATROL
		AIState.ATTACK:
			_attack(delta)
	move_and_slide()

func _patrol(delta: float) -> void:
	if nav.is_navigation_finished():
		_set_next_waypoint()
	var next := nav.get_next_path_position()
	var dir := (next - global_position).normalized()
	velocity.x = dir.x * move_speed
	velocity.z = dir.z * move_speed
	look_at(global_position + Vector3(dir.x, 0, dir.z), Vector3.UP)

func _attack(_delta: float) -> void:
	look_at(player.global_position, Vector3.UP)
	velocity.x = 0
	velocity.z = 0
	if global_position.distance_to(player.global_position) > attack_range * 1.2:
		state = AIState.PATROL
		return
	if _fire_cd <= 0.0:
		_fire_cd = fire_interval
		if player.has_method("apply_damage"):
			player.apply_damage(8.0)

func _can_see_player() -> bool:
	if player == null:
		return false
	if global_position.distance_to(player.global_position) > 30.0:
		return false
	var query := PhysicsRayQueryParameters3D.create(global_position + Vector3.UP, player.global_position + Vector3.UP)
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	return hit.has("collider") and hit["collider"] == player

func _set_next_waypoint() -> void:
	if waypoints.get_child_count() == 0:
		return
	var point := waypoints.get_child(_waypoint_idx % waypoints.get_child_count()) as Node3D
	nav.target_position = point.global_position
	_waypoint_idx += 1

func take_damage(amount: float) -> void:
	if state == AIState.DEAD:
		return
	hp -= amount
	if hp <= 0.0:
		state = AIState.DEAD
		GameManager.report_enemy_killed(name)
		queue_free()
