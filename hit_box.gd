# MovingObject.gd
extends Area2D

@export var speed : float = 500.0
@export var screen_width : float = 780 
var user: Player

func _ready():
	#set_collision_layer(1)  # Set the layer for collision
	#set_collision_mask(1)   # Set the mask for collision
	pass

func _process(delta):
	position.x += speed * delta

	if position.x >= screen_width:
		position.x = screen_width

func stop_moving():
	speed = 0  # Stop the object's movement
	await get_tree().create_timer(1).timeout
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.side != user.side:
		body.hp_bar.value = body.hp_bar.value - 10
		body.animation_player.play('hurt')
		body.animation_player.queue('idle')
		stop_moving()
