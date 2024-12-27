extends CharacterBody3D

class_name Capybara

@onready var anim: AnimationPlayer = $visual/capybara/AnimationPlayer

const SPEED = 7.0
const JUMP_VELOCITY = 13.0

@export var camera_horizontal_angle: Node3D

@onready var visual = $visual
var high_jumping = false
var target_basis = Basis()
var was_just_on_wall = false
var target_visual_basis = Basis(
	Vector3(0,0,-1),
	Vector3(0,1,0),
	Vector3(1,0,0),
)
var killed = false

func _ready():
	anim.playback_default_blend_time = 0.5

func _process(delta: float) -> void:
	if killed:
		Engine.time_scale = lerp(Engine.time_scale, 0.05, (delta / Engine.time_scale) * 5.0)
		if Engine.time_scale < 0.1:
			get_tree().paused = true
	visual.global_basis = lerp(visual.global_basis.orthonormalized(), target_visual_basis, delta * 9.0).orthonormalized()

func kill():
	killed = true

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		var gravity = 20.0 if high_jumping else 40.0
		velocity += -up_direction * gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity += JUMP_VELOCITY * -up_direction * -1
		high_jumping = true
	if Input.is_action_just_released("jump"):
		high_jumping = false


	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var flattened_forward = -target_basis.z.rotated(up_direction, camera_horizontal_angle.rotation.y)
	var flattened_right = target_basis.x.rotated(up_direction, camera_horizontal_angle.rotation.y)
	var velocity_in_gravity_direction = velocity.project(up_direction)
	var movement_direction_on_plane = (flattened_forward*-input_dir.y + flattened_right*input_dir.x).normalized()
	if movement_direction_on_plane.length_squared() > 0.0001:
		target_visual_basis = visual.global_basis.looking_at(-movement_direction_on_plane, up_direction)
	var wanted_new_velocity = movement_direction_on_plane * (SPEED if is_on_floor() else SPEED*0.5) + velocity_in_gravity_direction
	velocity = lerp(velocity, wanted_new_velocity, delta * (45.0 if input_dir else 15.0))
	
	if input_dir:
		anim.play("Running")
	else:
		anim.play("Idle")

	move_and_slide()

	if is_on_wall() and not was_just_on_wall:
		var snapped_wall_normal = snap_to_cardinal_direction(get_wall_normal())
		if wanted_new_velocity.normalized().dot(-snapped_wall_normal) > 0.8:
			was_just_on_wall = true
			var old_up_direction = up_direction
			up_direction = snapped_wall_normal
			
			var around_axis = old_up_direction.cross(up_direction)
			
			target_basis = Basis(
				snap_to_cardinal_direction(target_basis.x.rotated(around_axis, PI/2.0)),
				snap_to_cardinal_direction(target_basis.y.rotated(around_axis, PI/2.0)),
				snap_to_cardinal_direction(target_basis.z.rotated(around_axis, PI/2.0)),
			)

			target_visual_basis = Basis(
				target_visual_basis.x.rotated(around_axis, PI/2.0),
				target_visual_basis.y.rotated(around_axis, PI/2.0),
				target_visual_basis.z.rotated(around_axis, PI/2.0),
			)
	if not is_on_wall(): was_just_on_wall = false

	global_transform.basis = lerp(global_transform.basis, target_basis, 9.0 * delta)

func snap_to_cardinal_direction(v: Vector3) -> Vector3:
	v = v.normalized()
	var closest = Vector3.FORWARD
	var closest_dist = INF
	for direction in [
		Vector3(1, 0, 0),
		Vector3(-1, 0, 0),
		Vector3(0, 1, 0),
		Vector3(0, -1, 0),
		Vector3(0, 0, 1),
		Vector3(0, 0, -1)
	]:
		var d = (direction - v).length_squared()
		if d < closest_dist:
			closest_dist = d
			closest = direction
	return closest
