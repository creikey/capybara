extends Node3D

@export var player: Node3D

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta: float) -> void:
	global_position = lerp(global_position, player.global_position + player.global_transform.basis.y*1.0, exp(-5.0 * delta))
	global_transform.basis = lerp(global_transform.basis, player.global_transform.basis, 5.0 * delta)

func _input(event: InputEvent):
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and event is InputEventMouseMotion:
		$Horizontal.rotation.y -= event.relative.x * 0.005
		$Horizontal/Vertical.rotation.x -= event.relative.y * 0.005
		$Horizontal/Vertical.rotation.x = clamp($Horizontal/Vertical.rotation.x, -PI*0.45, PI*0.05)
	
	if event.is_action_pressed("focus"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("escape_mouse"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
