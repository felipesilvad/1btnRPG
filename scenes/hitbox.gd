class_name Hitbox
extends Area2D

var user: Player
var dmg:int = 30
var duration:float = 0.2
const DMG_scene = preload("res://scenes/dmg.tscn")

func show_dmg(dmg_value, body):
	var i = DMG_scene.instantiate()
	i.dmg = dmg
	i.name = "dmg"
	body.add_child(i)
