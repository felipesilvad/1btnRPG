extends Node2D

@onready var current_player: Player = $Character
@onready var player_bar: Control = $"Player Bar"
@onready var cursor: ColorRect = ColorRect.new()

func _ready() -> void:
	create_threshold_bars()
	setup_cursor()
	
func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_select"):
		current_player.is_holding = true
		current_player.hold_time += delta
		update_cursor()
	else:
		if current_player.is_holding:
			current_player.evaluate_hold_time()
		current_player.is_holding = false
		current_player.hold_time = 0.0

func update_cursor() -> void:
	var position_x = (current_player.hold_time / current_player.MAX_THRESHOLD) * player_bar.size.x
	position_x = clamp(position_x, 0, player_bar.size.x)  # Prevent overflow
	cursor.position = Vector2(position_x, 0)
	
func create_threshold_bars() -> void:
	var previous_position: float = 0.0

	for i in current_player.THRESHOLDS.size():
		var threshold = current_player.THRESHOLDS[i]
		var rect = ColorRect.new()
		# Calculate width based on the threshold value
		var threshold_width = ((threshold["value"] * player_bar.size.x) / current_player.MAX_THRESHOLD) - previous_position
		rect.position = Vector2(previous_position, 0)
		previous_position += threshold_width

		# Set size based on threshold width
		rect.size = Vector2(threshold_width, player_bar.size.y)  # Fill the parent's height

		# Set the color using Modulate
		rect.modulate = threshold["color"]

		# Optional: Assign a name for debugging
		rect.name = threshold["action"]

		# Add the TextureRect to the parent node
		player_bar.add_child(rect)

func move_to_target(object, start:Vector2, end:Vector2, speed:float):
	var tween = create_tween()
	tween.tween_property(object, "position", end, speed)
	await tween.finished
	#emit_signal(signal_name)

func setup_cursor() -> void:
	# Set up the cursor node
	cursor.size = Vector2(1, player_bar.size.y)
	cursor.modulate = Color.WHITE
	cursor.position = Vector2(0, 0)
	player_bar.add_child(cursor)
