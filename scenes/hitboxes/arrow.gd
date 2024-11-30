extends Hitbox_Class

@export var speed : float = 500.0
@export var screen_width : float = 780 
@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready():
	if user.side == 2:
		sprite_2d.flip_h = true

func _process(delta):
	if user.side == 1:
		position.x += speed * delta
	else:
		position.x -= speed * delta
	
	if position.x >= screen_width:
		position.x = screen_width

func stop_moving():
	speed = 0  # Stop the object's movement
	await get_tree().create_timer(0.2).timeout
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.side != user.side:
		body.hp_bar.value = body.hp_bar.value - dmg
		show_dmg(body)
		
		stop_moving()
