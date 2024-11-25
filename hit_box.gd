# MovingObject.gd
extends Area2D

@export var speed : float = 500.0
@export var screen_width : float = 1024.0 
var user: Player

func _ready():

	set_collision_layer(1)  # Set the layer for collision
	set_collision_mask(1)   # Set the mask for collision

# Called every frame.
func _process(delta):
	# Move the object towards the end of the screen
	position.x += speed * delta

	# Stop at the screen's end
	if position.x >= screen_width:
		position.x = screen_width

func stop_moving():
	speed = 0  # Stop the object's movement
	await get_tree().create_timer(1).timeout
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.side != user.side:
		stop_moving()
