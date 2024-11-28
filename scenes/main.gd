extends Node2D

@onready var current_player_1: Player
@onready var current_player_2: Player
@onready var cursor: ColorRect = ColorRect.new()
@onready var bar_1: Control = $Bar1
@onready var bar_2: Control = $Bar2

var value: float = 0.0
var chars_spots_1: Array
var chars_spots_2: Array
var turn_queue_1: Array
var turn_queue_2: Array

func _ready() -> void:
	current_player_1 = turn_queue_1[0]
	current_player_2 = turn_queue_2[0]
	create_threshold_bars(bar_1)
	create_threshold_bars(bar_2)
	setup_cursor(bar_1)
	setup_cursor(bar_2)
	
func _process(delta: float) -> void:
	process_ai(delta)
	
	if Input.is_action_pressed("ui_select"):
		current_player_1.is_holding = true
		current_player_1.hold_time += delta
		update_cursor(bar_1)
	else:
		if current_player_1.is_holding:
			current_player_1.evaluate_hold_time()
		current_player_1.is_holding = false
		current_player_1.hold_time = 0.0

func process_ai(delta) -> void:
	if current_player_2.hold_time < (current_player_2.THRESHOLDS[1].value+0.05):
		current_player_2.is_holding = true
		current_player_2.hold_time += delta
		update_cursor(bar_2)
	else:
		if current_player_2.is_holding:
			current_player_2.evaluate_hold_time()
		current_player_2.is_holding = false
		current_player_2.hold_time = 0.0
		
func update_cursor(bar) -> void:
	var position_x = (current_player_1.hold_time / current_player_1.MAX_THRESHOLD) * bar.size.x
	position_x = clamp(position_x, 0, bar.size.x)  # Prevent overflow
	cursor.position = Vector2(position_x, 0)
	
func create_threshold_bars(bar) -> void:
	var previous_position: float = 0.0

	for i in current_player_1.THRESHOLDS.size():
		var threshold = current_player_1.THRESHOLDS[i]
		var rect = ColorRect.new()
		# Calculate width based on the threshold value
		var threshold_width = ((threshold["value"] * bar.size.x) / current_player_1.MAX_THRESHOLD) - previous_position
		rect.position = Vector2(previous_position, 0)
		previous_position += threshold_width
		# Set size based on threshold width
		rect.size = Vector2(threshold_width, bar.size.y)  # Fill the parent's height
		# Set the color using Modulate
		rect.modulate = threshold["color"]
		rect.name = threshold["action"]
		bar.add_child(rect)

func move_to_target(object, start:Vector2, end:Vector2, speed:float):
	var tween = create_tween()
	tween.tween_property(object, "position", end, speed)
	await tween.finished
	#emit_signal(signal_name)

func setup_cursor(bar) -> void:
	# Set up the cursor node
	cursor.z_index = 11
	cursor.size = Vector2(1, bar.size.y)
	cursor.modulate = Color.WHITE
	cursor.position = Vector2(0, 0)
	bar.add_child(cursor)
