extends CharacterBody2D

const speed = 100
var current_dir = "none"

var enemy_inattack_range = false
var enemy_attack_cooldown = true
var health = 100
var player_alive = true

var attack_ip = false


func _ready():
	$AnimatedSprite2D.play("down_idle")
	
	
func _physics_process(delta):
		player_movement(delta)
		enemy_attack()
		if health <= 0:
			player_alive = false
			health = 0
			print("Player has died.")
			self.queue.free() #TO CHANGE WHEN WE HAVE GAME OVER SCENE
		
		
func player_movement(delta):
	
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
			if attack_ip == false:
				anim.play("side_walk")
		elif movement == 0:
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
	if enemy_inattack_range and enemy_attack_cooldown == true:
		health = health - 10
		enemy_attack_cooldown = false
		$attack_cooldown.start()
		print("Player health : ", health)
		



func _on_attack_cooldown_timeout() -> void:
	enemy_attack_cooldown = true
	
func attack():
	var dir = current_dir
	
	if input.is_action_just_pressed("attack"):
		global.player_current_attack = true
		attack.ip = true
		if dir == "right":
			
		
