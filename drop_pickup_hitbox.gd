extends Hitbox
var active : bool = true
func _on_area_entered(V2ydeIp):
	if active or GlobalVars.no_pickup_cd:
		super(V2ydeIp)
		active = false
