extends CharacterBody3D

@onready var tree: AnimationTree = $AnimationTree

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var target: Node3D = null
var target_rot = 0.0

var killed = false

func kill():
	killed = true
	tree.active = false
	$CollisionShape3D.disabled = true
	$man/Skeleton3D/PhysicalBoneSimulator3D.active = true
	$man/Skeleton3D/PhysicalBoneSimulator3D.physical_bones_start_simulation()

func _physics_process(delta: float) -> void:
	if not killed:
	
		if not is_on_floor():
			velocity += get_gravity() * delta

		var input := Vector3()
		
		if target != null and (target.global_position - global_position).length() > 1.0:
			input = (target.global_position - global_position)
		
		input.y = 0.0
		if input.length_squared() > 0:
			input = input.normalized()
			target_rot = -atan2(input.z, input.x) + PI/2.0
			tree.set("parameters/conditions/run", true)
			tree.set("parameters/conditions/idle", false)
		else:
			tree.set("parameters/conditions/run", false)
			tree.set("parameters/conditions/idle", true)

		$man.rotation.y = lerp_angle($man.rotation.y, target_rot, 9.0 * delta)
		var target_velocity = input * SPEED + velocity.project(Vector3.DOWN)
		velocity = lerp(velocity, target_velocity, 9.0 * delta)
		move_and_slide()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("man_targets"):
		target = body
