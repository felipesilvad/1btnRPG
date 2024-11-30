class_name Hitbox_Class
extends Area2D

var user: Player
var dmg:int = 30
var duration:float = 0.2
const DMG_scene = preload("res://scenes/dmg.tscn")

func show_dmg(body):
	var i = DMG_scene.instantiate()
	i.dmg = dmg
	i.name = "dmg"
	body.get_node("Control").add_child(i)
