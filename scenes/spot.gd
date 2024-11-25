extends Area2D

@export var char: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var char_i = char.instantiate()
	char_i.side = 1
	$"../..".turn_queue.append(char_i)
	add_child(char_i)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
