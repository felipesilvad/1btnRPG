extends Area2D

@export var char_scene: PackedScene
@export var side: int = 1
@onready var main: Node2D = $"../.."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var char_i = char_scene.instantiate()
	char_i.side = side
	if side == 2:
		char_i.get_node("Sprite2D").flip_h = true
	main.turn_queue.append(char_i)
	add_child(char_i)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
