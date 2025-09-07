# Godot 4.x
extends Camera2D

@export var tilemap_path: NodePath
@export var margin_px: float = 0.0   # extra padding around the map (in pixels)

func _ready():
	make_current()
	if tilemap_path == NodePath():
		push_error("Assign your TileMap to 'tilemap_path' in the inspector.")
		return
	var tm := get_node_or_null(tilemap_path) as TileMap
	if tm == null:
		push_error("TileMap not found at the given path.")
		return

	# wait a frame so the viewport has the correct size
	await get_tree().process_frame
	_fit_to_tilemap(tm)

	# re-fit if the window/viewport size changes
	get_viewport().size_changed.connect(func(): _fit_to_tilemap(tm))

func _fit_to_tilemap(tm: TileMap) -> void:
	var used: Rect2i = tm.get_used_rect()
	if used.size == Vector2i.ZERO:
		push_warning("TileMap has no used cells.")
		return

	# Convert used cell rect to local pixel-space corners.
	# map_to_local() returns the CENTER of a cell, so offset by half a cell.
	var cell: Vector2 = tm.tile_set.tile_size
	var half: Vector2 = cell * 0.5

	var tl_center: Vector2 = tm.map_to_local(used.position)
	var br_center: Vector2 = tm.map_to_local(used.position + used.size - Vector2i.ONE)

	var tl: Vector2 = tl_center - half   # top-left corner in TM local pixels
	var br: Vector2 = br_center + half   # bottom-right corner in TM local pixels

	# Map size & center in pixels
	var map_size_px: Vector2 = br - tl
	if margin_px > 0.0:
		map_size_px += Vector2(margin_px * 2.0, margin_px * 2.0)
	var center_local: Vector2 = tl + (br - tl) * 0.5
	global_position = tm.to_global(center_local)

	# Compute zoom so the whole map fits. (zoom < 1 = zoom out)
	var vp: Vector2 = get_viewport().get_visible_rect().size
	var zx: float = vp.x / map_size_px.x
	var zy: float = vp.y / map_size_px.y
	var z: float = min(zx, zy)

	# Don't zoom in past 1:1 unless you want to fill the screen with a small map.
	if z > 1.0:
		z = 1.0
	zoom = Vector2(z, z)
