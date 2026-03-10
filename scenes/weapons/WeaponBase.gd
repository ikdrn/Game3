extends Node3D
class_name WeaponBase

@export var weapon_name := "Weapon"
@export var profile := "AR"
@export var magazine_size := 20
@export var damage := 10.0
@export var fire_rate := 8.0
@export var reload_time := 1.5
@export var spread := 0.004

var current_ammo := 0
var _cooldown := 0.0
var _reloading := false

func _ready() -> void:
	current_ammo = magazine_size

func _process(delta: float) -> void:
	if _cooldown > 0.0:
		_cooldown -= delta

func try_fire(owner: Node3D) -> void:
	if _cooldown > 0.0 or _reloading:
		return
	if current_ammo <= 0:
		reload()
		return
	current_ammo -= 1
	_cooldown = 1.0 / fire_rate
	_fire_hitscan(owner)
	AudioManager.play_gunshot(profile)
	_apply_recoil(owner)
	GameManager.report_weapon(weapon_name, current_ammo, magazine_size)

func reload() -> void:
	if _reloading or current_ammo == magazine_size:
		return
	_reloading = true
	await get_tree().create_timer(reload_time).timeout
	current_ammo = magazine_size
	_reloading = false
	GameManager.report_weapon(weapon_name, current_ammo, magazine_size)

func _fire_hitscan(owner: Node3D) -> void:
	var camera := owner.get_node("Pivot/Camera3D") as Camera3D
	var from := camera.global_position
	var dir := -camera.global_transform.basis.z
	dir += Vector3(randf_range(-spread, spread), randf_range(-spread, spread), 0.0)
	dir = dir.normalized()
	var query := PhysicsRayQueryParameters3D.create(from, from + dir * 2000.0)
	query.collide_with_areas = true
	var result := get_world_3d().direct_space_state.intersect_ray(query)
	if result.has("collider"):
		var collider := result["collider"]
		if collider.has_method("take_damage"):
			var mult := 1.5 if String(result.get("collider_shape", "")).contains("Head") else 1.0
			collider.take_damage(damage * mult)

func _apply_recoil(owner: Node3D) -> void:
	var pivot := owner.get_node("Pivot") as Node3D
	match weapon_name:
		"R301":
			pivot.rotate_x(-0.01)
			owner.rotate_y(randf_range(0.002, 0.006))
		"Wingman":
			pivot.rotate_x(-0.03)
		_:
			pivot.rotate_x(-0.015)
