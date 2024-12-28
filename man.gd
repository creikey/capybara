extends CharacterBody3D

@onready var tree: AnimationTree = $AnimationTree

const SPEED = 10.0
const JUMP_VELOCITY = 4.5

var target: Node3D = null
var target_rot = 0.0

var killed = false

func kill(_origin: Vector3, _kill_direction: Vector3):
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
		
		if target != null:
			if (target.global_position - global_position).length() > 1.5:
				input = (target.global_position - global_position)
				tree.set("parameters/conditions/kick", false)
				$man/MeshInstance3D.visible = false
				$man/Kill/CollisionShape3D.disabled = true
			else:
				tree.set("parameters/conditions/kick", true)
				var playback = (tree.get("parameters/playback") as AnimationNodeStateMachinePlayback)
				#print(playback.get_current_node())
				var do_kill = playback.get_current_node() == "Kick" and playback.get_current_play_position() > 0.1
				$man/Kill/CollisionShape3D.disabled = not (do_kill)
				$man/MeshInstance3D.visible = do_kill
		

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


func _on_kill_body_entered(body: Node3D) -> void:
	if body.is_in_group("killable"):
		body.kill(global_position, -global_transform.basis.z)
