extends SubViewport

@export var scene_camera: Camera3D

func _ready():
	world_3d = get_window().world_3d

func _process(_delta: float) -> void:
	$Camera3D.global_transform = scene_camera.global_transform
