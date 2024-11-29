extends Control

var dmg: int
@onready var label: Label = $Label
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = str(dmg)
	await get_tree().create_timer(0.3).timeout
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
