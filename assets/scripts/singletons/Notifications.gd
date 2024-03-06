extends CanvasLayer

var checkmarkTexture := preload("res://assets/scripts/singletons/notifs/accept_button.png")
var warning_texture := preload("res://assets/scripts/singletons/notifs/warninghd.pmg.png")
var notif_fade : PackedScene = preload("res://assets/scripts/singletons/notifs/notif_fade.tscn")
var notifCheck : PackedScene = preload("res://assets/scripts/singletons/notifs/notifCheck.tscn")
var notif_warn : PackedScene = preload("res://assets/scripts/singletons/notifs/notif_warn.tscn")
var notif_click : PackedScene = preload("res://assets/scripts/singletons/notifs/notif_click.tscn")
@export var hudPositions : Array[Node] = [$Notifications/Margins/topleft_notifs, $Notifications/Margins/topcenter_notifs, $Notifications/Margins/topright_notifs, $Notifications/Margins/bottomleft_notifs, $Notifications/Margins/bottomcenter_notifs, $Notifications/Margins/bottomright_notifs]
