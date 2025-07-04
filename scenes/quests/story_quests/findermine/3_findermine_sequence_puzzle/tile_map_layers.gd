# SPDX-FileCopyrightText: The Threadbare Authors
# SPDX-License-Identifier: MPL-2.0
## Script para configurar automáticamente los TileMapLayers en SequencePuzzleTemplate
## Coloca este script en el nodo TileMapLayers para configuración automática
class_name SequencePuzzleTileMapSetup
extends Node

## Referencias a los TileMapLayers
@onready var fondo_tilemap: TileMapLayer = $fondo
@onready var walkable_tilemap: TileMapLayer = $WalkableTileMap
@onready var collision_tilemap: TileMapLayer = $CollisionTileMap
@onready var object_tilemap: TileMapLayer = $ObjectTileMap

func _ready() -> void:
	setup_tilemap_layers()
	verify_setup()

func setup_tilemap_layers() -> void:
	"""Configura automáticamente las propiedades de los TileMapLayers"""
	
	# Configurar fondo (solo visual, sin colisiones)
	if fondo_tilemap:
		fondo_tilemap.collision_enabled = false
		print("✓ Fondo configurado (sin colisiones)")
	
	# Configurar área transitable (sin colisiones, solo para validación)
	if walkable_tilemap:
		walkable_tilemap.collision_enabled = false
		print("✓ WalkableTileMap configurado (sin colisiones)")
	
	# Configurar barreras/colisiones (CON colisiones habilitadas)
	if collision_tilemap:
		collision_tilemap.collision_enabled = true
		collision_tilemap.collision_layer = 2  # Layer de barreras
		collision_tilemap.collision_mask = 0   # No necesita detectar nada
		print("✓ CollisionTileMap configurado (con colisiones)")
	
	# Configurar objetos (puede tener colisiones dependiendo del uso)
	if object_tilemap:
		object_tilemap.collision_enabled = false  # Por defecto sin colisiones
		print("✓ ObjectTileMap configurado")

func verify_setup() -> bool:
	"""Verifica que todos los TileMapLayers estén configurados correctamente"""
	var all_good = true
	
	print("=== VERIFICACIÓN DE TILEMAPLAYERS ===")
	
	if not fondo_tilemap:
		print("❌ ERROR: fondo TileMapLayer no encontrado")
		all_good = false
	
	if not walkable_tilemap:
		print("❌ ERROR: WalkableTileMap no encontrado")
		all_good = false
	
	if not collision_tilemap:
		print("❌ ERROR: CollisionTileMap no encontrado")
		all_good = false
	else:
		if not collision_tilemap.collision_enabled:
			print("⚠️ ADVERTENCIA: CollisionTileMap no tiene colisiones habilitadas")
		if not collision_tilemap.tile_set:
			print("⚠️ ADVERTENCIA: CollisionTileMap no tiene TileSet asignado")
	
	if not object_tilemap:
		print("❌ ERROR: ObjectTileMap no encontrado")
		all_good = false
	
	if all_good:
		print("✅ Todos los TileMapLayers configurados correctamente")
	
	print("=====================================")
	return all_good

func get_player_reference() -> CharacterBody2D:
	"""Obtiene referencia al jugador para configuración automática"""
	var player = get_node_or_null("../OnTheGround/Player")
	if player and player is CharacterBody2D:
		return player
	else:
		print("⚠️ ADVERTENCIA: Player no encontrado en OnTheGround")
		return null

func auto_configure_player() -> void:
	"""Configura automáticamente las referencias del jugador"""
	var player = get_player_reference()
	if not player:
		return
	
	# Si el player tiene el script correcto, configurar las referencias
	if player.has_method("teleport_to_position"):
		if player.has_property("collision_tilemap"):
			player.collision_tilemap = collision_tilemap
		if player.has_property("walkable_tilemap"):
			player.walkable_tilemap = walkable_tilemap
		
		print("✅ Player configurado automáticamente con referencias de TileMapLayers")
	else:
		print("⚠️ Player no tiene el script de movimiento correcto")
