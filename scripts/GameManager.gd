extends Node

signal player_damaged(current_hp: float, shield: float)
signal weapon_changed(name: String, ammo: int, magazine: int)
signal killfeed_updated(lines: PackedStringArray)

var player: Node = null
var enemies_killed: int = 0
var killfeed: PackedStringArray = []

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func register_player(p: Node) -> void:
	player = p

func report_player_health(hp: float, shield: float) -> void:
	player_damaged.emit(hp, shield)

func report_weapon(name: String, ammo: int, magazine: int) -> void:
	weapon_changed.emit(name, ammo, magazine)

func report_enemy_killed(enemy_name: String = "Enemy") -> void:
	enemies_killed += 1
	var line := "%s eliminated (%d)" % [enemy_name, enemies_killed]
	killfeed.append(line)
	if killfeed.size() > 5:
		killfeed.remove_at(0)
	killfeed_updated.emit(killfeed)
