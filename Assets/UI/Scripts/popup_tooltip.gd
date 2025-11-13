extends Control

var parent = null
var opacity_tween: Tween = null
@onready var name_text = $BackgroundContainer/VBoxContainer/NameLabel
@onready var type_text = $BackgroundContainer/VBoxContainer/HSplitContainer/TypeLabel
@onready var damage_text = $BackgroundContainer/VBoxContainer/HSplitContainer2/DamageLabel
@onready var max_hp_text = $BackgroundContainer/VBoxContainer/HSplitContainer3/MaxHPLabel
@onready var attack_speed_text = $BackgroundContainer/VBoxContainer/HSplitContainer4/AttackSpeedLabel
@onready var range_text = $BackgroundContainer/VBoxContainer/HSplitContainer5/RangeLabel
@onready var crit_text = $BackgroundContainer/VBoxContainer/HSplitContainer6/CritLabel
@onready var description_text = $BackgroundContainer/VBoxContainer/RichTextLabel
@onready var rich_text = $BackgroundContainer/VBoxContainer/RichTextRarityLabel

func _input(event: InputEvent) -> void:
	if not visible or not (event is InputEventMouseMotion):
		return

	var mouse_pos = get_global_mouse_position()
	var viewport_size = get_viewport_rect().size
	var tooltip_size = size

	# Default: place tooltip above the cursor (your -316 offset)
	var pos = mouse_pos + Vector2(16, -316)

	# # --- Vertical adjustments ---
	if pos.y < 4:
		pos.y = mouse_pos.y + 16   # flip below cursor if no room above


	# --- Horizontal adjustments ---
	if pos.x + tooltip_size.x > viewport_size.x - 300:
		pos.x = mouse_pos.x - tooltip_size.x - 316  # flip to left if too far right


	global_position = pos


func toggle (on: bool):
	if on:
		show()
		modulate.a = 0.0
		tween_opacity(1.0)
		set_text_effect_rarity(rich_text.text)
	else:
		modulate.a = 1.0
		await tween_opacity(0.0).finished
		hide()

func tween_opacity(to: float):
	if opacity_tween: opacity_tween.kill()
	opacity_tween = create_tween()
	opacity_tween.tween_property(self, "modulate:a", to, 0.3)
	return opacity_tween




func set_text_effect_rarity(rarity: String):
	if not rich_text:
		print("RichTextLabel not found!")
		return

	match rarity.strip_edges().capitalize():
		"Common":
			rich_text.bbcode_text = "[wave amp=10 freq=2][color=gray]Common[/color][/wave]"  # subtle wave effect
		"Uncommon":
			rich_text.bbcode_text = "[wave amp=15 freq=3][color=#00FF00]Uncommon[/color][/wave]"  # green with a stronger wave
		"Rare":
			rich_text.bbcode_text = "[wave amp=20 freq=4][color=#0000FF]Rare[/color][/wave]"  # blue with a noticeable wave
		"Epic":
			rich_text.bbcode_text = "[shake amp=5 freq=10][color=orange]Epic[/color][/shake]"  # orange with a shaking effect
		"Legendary":
			rich_text.bbcode_text = "[rainbow freq=0.5][shake amp=10 freq=15]Legendary[/shake][/rainbow]"  # rainbow color with a strong shake
		_:
			rich_text.text = rarity

			
func _ready():
	if parent != null:
		name_text.text = str(parent.panel.unit_name).capitalize()
		type_text.text = str(parent.panel.unit_stats.type).capitalize()
		damage_text.text = str(parent.panel.unit_stats.damage)
		max_hp_text.text = str(parent.panel.unit_stats.max_hp)
		attack_speed_text.text = str(parent.panel.unit_stats.attack_speed)
		range_text.text = str(parent.panel.unit_stats.range)
		crit_text.text = str(parent.panel.unit_stats.crit_chance) + "%"
		description_text.text = str(parent.panel.unit_stats.description).capitalize()
		set_text_effect_rarity(parent.panel.rarity.name)
	else:
		pass
	
