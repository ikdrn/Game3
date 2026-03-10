extends CanvasLayer

@onready var hp_bar: ProgressBar = $Control/BottomLeft/HP
@onready var shield_bar: ProgressBar = $Control/BottomLeft/Shield
@onready var weapon_label: Label = $Control/BottomRight/Weapon
@onready var ammo_label: Label = $Control/BottomRight/Ammo
@onready var crosshair: Label = $Control/Center/Crosshair
@onready var kill_feed: RichTextLabel = $Control/TopRight/KillFeed

func _ready() -> void:
	GameManager.player_damaged.connect(_on_player_damaged)
	GameManager.weapon_changed.connect(_on_weapon_changed)
	GameManager.killfeed_updated.connect(_on_killfeed_updated)
	_on_player_damaged(100, 50)

func _process(_delta: float) -> void:
	var grow := 18 if Input.is_action_pressed("fire") else 12
	crosshair.text = "+".lpad(grow, " ")

func _on_player_damaged(hp: float, shield: float) -> void:
	hp_bar.value = hp
	shield_bar.value = shield

func _on_weapon_changed(name: String, ammo: int, magazine: int) -> void:
	weapon_label.text = "Weapon: %s" % name
	ammo_label.text = "Ammo: %d / %d" % [ammo, magazine]

func _on_killfeed_updated(lines: PackedStringArray) -> void:
	kill_feed.clear()
	for line in lines:
		kill_feed.append_text(line + "\n")
