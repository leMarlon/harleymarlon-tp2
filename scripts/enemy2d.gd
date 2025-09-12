extends CharacterBody2D

var speed = 65
var player_chase = false
var player = null



var health = 30
var player_inattack_zone = false

var can_take_damage = true
var enemy_alive = true

func _physics_process(delta):
	if not enemy_alive:
		return

	update_health()
	deal_with_damage()

	if health <= 0:
		die()
		return

	if player_chase:
		position += (player.position - position) / speed
		$AnimatedSprite2D.play("side_walk")
		
		if (player.position.x - position.x) < 0:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
	else:
		$AnimatedSprite2D.play("side_idle")


func _on_detection_area_body_entered(body: Node2D) -> void:
	player = body
	player_chase = true
	
func _on_detection_area_body_exited(body: Node2D) -> void:
	player = null
	player_chase = false
	
	
func enemy():
	pass


func _on_enemy_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_inattack_zone = true


func _on_enemy_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_inattack_zone = false
		

func deal_with_damage():
	if player_inattack_zone and global.player_current_attack == true:
		if can_take_damage and enemy_alive:
			health -= 10
			$take_damage_cooldown.start()
			can_take_damage = false
			print("slime health = ", health)


func _on_take_damage_cooldown_timeout() -> void:
	can_take_damage = true


func update_health():
	var healthbar = $healthbar
	healthbar.value = health
	if health >= 30:
		healthbar.visible = false
	else:
		healthbar.visible = true


func die():
	if not enemy_alive:
		return

	enemy_alive = false
	health = 0
	player_chase = false
	player_inattack_zone = false
	can_take_damage = false

	if $take_damage_cooldown and not $take_damage_cooldown.is_stopped():
		$take_damage_cooldown.stop()

	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred("disabled", true)
	if has_node("enemy_hitbox/CollisionShape2D"):
		$enemy_hitbox/CollisionShape2D.set_deferred("disabled", true)

	update_health()
	$AnimatedSprite2D.play("death")

	await get_tree().create_timer(1.0).timeout
	queue_free()
