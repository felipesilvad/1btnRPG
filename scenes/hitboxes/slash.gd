extends Hitbox_Class

func _on_body_entered(body: Node2D) -> void:
	await get_tree().create_timer(0.2).timeout
	if body.side != user.side:
		body.hp_bar.value = body.hp_bar.value - dmg
		show_dmg(body)
		body.main_sm.dispatch(&"to_hurt")
		await get_tree().create_timer(duration).timeout
		queue_free()
