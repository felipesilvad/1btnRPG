extends Area2D

var user: Player

func _on_body_entered(body: Node2D) -> void:
	await get_tree().create_timer(0.2).timeout
	if body.side != user.side:
		body.hp_bar.value = body.hp_bar.value - 30
		body.animation_player.play('hurt')
		body.animation_player.queue('idle')
		await get_tree().create_timer(0.2).timeout
		queue_free()
