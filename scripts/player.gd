extends CharacterBody2D

const speed = 140
var current_dir = "none"
@onready var deathsound = $death
@onready var slashsound = $slash



var enemy_inattack_range = false
var enemy_attack_cooldown = true
var health = 100
var player_alive = true

var attack_ip = false


func _ready():
	$AnimatedSprite2D.play("down_idle")
	$Camera2D.make_current()
	_set_camera_limits()
	
	
func _physics_process(delta):
	player_movement(delta)
	attack()
	enemy_attack()
	update_health()
	if health <= 0 and player_alive:
		die()
		
		
func player_movement(delta):
	if not player_alive:
		return
	
	if attack_ip:
		velocity = Vector2.ZERO
		return
		
		

	if Input.is_action_pressed("ui_right"):
		current_dir = "right"
		play_anim(1)
		velocity.x = speed
		velocity.y = 0
	elif Input.is_action_pressed("ui_left"):
		current_dir = "left"
		play_anim(1)
		velocity.x = -speed
		velocity.y = 0
	elif Input.is_action_pressed("ui_down"):
		current_dir = "down"
		play_anim(1)
		velocity.x = 0
		velocity.y = speed
	elif Input.is_action_pressed("ui_up"):
		current_dir = "up"
		play_anim(1)
		velocity.x = 0
		velocity.y = -speed
	else:
		play_anim(0)
		velocity.x = 0
		velocity.y = 0
			
	move_and_slide()
		
func play_anim(movement):
	var dir = current_dir
	var anim = $AnimatedSprite2D
	
	if dir == "right":
		anim.flip_h = false
		if movement == 1:
			anim.play("side_walk")
		elif movement == 0:
			if attack_ip == false:
				anim.play("side_idle")
	if dir == "left":
		anim.flip_h = true
		if movement == 1:
				anim.play("side_walk")
		elif movement == 0:
			if attack_ip == false:
				anim.play("side_idle")
	if dir == "up":
		anim.flip_h = true
		if movement == 1:
			anim.play("walk_up")
		elif movement == 0:
			if attack_ip == false:
				anim.play("up_idle")
	if dir == "down":
		anim.flip_h = true
		if movement == 1:
			anim.play("walk_down")
		elif movement == 0:
			if attack_ip == false:
				anim.play("down_idle")

func player():
	pass


func _on_player_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_inattack_range = true
		


func _on_player_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_inattack_range = false
		
func enemy_attack():
	if not player_alive:
		return

	if enemy_inattack_range and enemy_attack_cooldown == true:
		health = health - 10
		enemy_attack_cooldown = false
		$attack_cooldown.start()
		print("Player health : ", health)
		


func _on_attack_cooldown_timeout() -> void:
	enemy_attack_cooldown = true
	
func attack():
	if not player_alive:
		return
		

	var dir = current_dir
	
	if Input.is_action_just_pressed("attack"):
		global.player_current_attack = true
		attack_ip = true
		if dir == "right":
			$AnimatedSprite2D.flip_h = false
			$AnimatedSprite2D.play("side_slash")
			slashsound.play()
			$deal_attack_timer.start()
		if dir == "left":
			$AnimatedSprite2D.flip_h = true
			$AnimatedSprite2D.play("side_slash")
			slashsound.play()
			$deal_attack_timer.start()
		if dir == "down":
			$AnimatedSprite2D.play("downslash")
			slashsound.play()
			$deal_attack_timer.start()
		if dir == "up":
			$AnimatedSprite2D.play("upslash")
			slashsound.play()
			$deal_attack_timer.start()


func _on_deal_attack_timer_timeout() -> void:
	$deal_attack_timer.stop()
	global.player_current_attack = false
	attack_ip = false
	play_anim(0)


func _set_camera_limits():
	var tilemap = get_tree().get_first_node_in_group("world_map")
	if tilemap and tilemap is TileMap:
		var used_rect = tilemap.get_used_rect()
		var cell_size = tilemap.tile_set.tile_size

		$Camera2D.limit_left = int(used_rect.position.x * cell_size.x)
		$Camera2D.limit_top = int(used_rect.position.y * cell_size.y)
		$Camera2D.limit_right = int((used_rect.position.x + used_rect.size.x) * cell_size.x)
		$Camera2D.limit_bottom = int((used_rect.position.y + used_rect.size.y) * cell_size.y)



func update_health():
	var healthbar = $healthbar
	
	healthbar.value = health
	
	if health >= 100:
		healthbar.visible = false
	else:
		healthbar.visible = true
		
		
func _on_regin_timer_timeout():
	if health < 100:
		health = health + 20
		if health > 100:
			health = 100
		if health == 0:
			health = 0


func die():
	if not player_alive:
		return

	player_alive = false
	health = 0
	velocity = Vector2.ZERO
	global.player_current_attack = false
	attack_ip = false

	print("Player has died.")

	if $attack_cooldown:
		$attack_cooldown.stop()
	if $deal_attack_timer:
		$deal_attack_timer.stop()
	if $regin_timer:
		$regin_timer.stop()

	if $AnimatedSprite2D:
		$AnimatedSprite2D.play("death")
	
	deathsound.play()
	await get_tree().create_timer(2.0).timeout
	
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")
	
