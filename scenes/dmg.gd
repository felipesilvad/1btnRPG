extends Control

var dmg: int
@onready var label: Label = $Label
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var dynamic_font = $Label.get("custom_fonts/font") as Font
	if dynamic_font:
		# Enable outline and set its properties
		dynamic_font.outline_color = Color(1, 0, 0, 1)  # Red color
		dynamic_font.outline_size = 2  # Outline thickness

	label.text = str(dmg)
	await get_tree().create_timer(0.3).timeout
	queue_free()
