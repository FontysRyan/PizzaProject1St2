extends Label
@onready var rounds_label: Label = $"."


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rounds_label.text = "Round " + str(Stats.round)
