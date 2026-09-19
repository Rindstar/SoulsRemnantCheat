class_name Player
extends Character
const C5kf__u := preload("res://Sprites/UI/Icons/Quest/icon_quest_completable.png")
const CdBDzeL := preload("res://Sprites/UI/Icons/Quest/icon_quest_completable_click-Sheet.png")
const jkOoACx := preload("res://Scenes/Player/navigation_arrow.tscn")
@onready var vPywtHx = $SendPositionTimer
@onready var ZDg5TFp = $CameraRemoteTransform2D
var rH5s_JK : float = 0.0
@onready var hurtbox = $Hurtbox
@onready var xe4qYvz = $InvincibilityAnimationPlayer
@onready var VGPxxA6 = $MeleeAttackNode2D/CenterHitbox
@onready var wXQVu6D = $ItemDropPickUpHitbox
@onready var fcyzCHP = $ItemDropPickUpHitbox/PickUpCooldownTimer
@onready var RxW8KOH = $EmoteTimer
@onready var DGrbDI8 = $OutOfBoundsTimer
@onready var _kWuwRF = $InteractCooldownTimer
@onready var CBpN8cG: SubViewportContainer = %UIContainer
@onready var i2lh69q: SubViewport = %UIViewport
var H77hocR = null
var Hj3ejZa = null
var VQzgkFr : bool = false
var _y25e_L : Array = []
var MIg_bmt : float = 0.0
var WLQKd50 = null
var EzsDipd : int = 0
var l8aBpxq : bool = false
var NsdpHXK : int = 0
var M988V7b : bool = false
const uzWyovj : int = 30
var Vw6gBFh : FileAccess = null
var TJ3urXA : Array = []
var Y5lLaYJ : bool = false
var XkJABwF : bool = false
const FqBFzl5 : int = 120
var yRud5g6 : QReTwRd = null : set = hII8DAH
var yQbttAB : TextureRect = null
var r7Sq4vV : String = ""
var nwd9V5_ : Array[Texture2D] = []
var ZbIfGuF : int = 0
var njF9F7V : Timer = null
func _enter_tree():
	MainInstances.player = self
func _exit_tree():
	MainInstances.player = null
	GhK36fa()
func _ready():
	super()
	if Client.N8FNn8I or Client.PYHTxkw:
		visible = !Client.N8FNn8I
	var bn30pLs = MainInstances.camera
	if bn30pLs is Camera2D:
		ZDg5TFp.remote_path = bn30pLs.get_path()
	rH5s_JK = ZDg5TFp.position.y
	jqIIzmo = Client.jqIIzmo
	account_id = Client.account_id
	mfOGRdQ = Client.XJ2Ni_n
	if Client.smhz4kI != "":
		g1PtIOu = Client.smhz4kI
	Events.pVfEG1e.connect(YeZZsez)
	Events.mnDOBvb.connect(J_GQK4s)
	SwhR9GP()
	Q2v_OO2()
	Events.mETxrGp.connect(BgPu261)
	Events.i87G2yV.connect(wIXffip)
	var Xx9wKJu = MainInstances.quest_window
	if Xx9wKJu is QuestWindow:
		BgPu261(Xx9wKJu.get_first_directly_completable_quest_id())
	var vyw2OY3 : int = int(Client.Bde90Hf.get("duration", 0))
	if vyw2OY3 > 0:
		get_tree().create_timer(float(vyw2OY3)).timeout.connect(JCgGE7d)
	var X3g6CpD : String = str(Client.Bde90Hf.get("command", ""))
	if X3g6CpD != "":
		Events.wKZAB4u.connect(func():
			await get_tree().create_timer(2.0).timeout
			var Gbh6J4V = f8zPDfg.new()
			Gbh6J4V.Ci0ICMz(7)
			Gbh6J4V.put_string(X3g6CpD)
			Client.wNmJul_(Gbh6J4V)
			print("[harness] auto-sent chat command: ", X3g6CpD)
		, CONNECT_ONE_SHOT)
func YeZZsez():
	if OaJoGwJ():
		wkrZ_rt()
	otwQJiS()
	BAGy4Xt()
	rnjD3EU()
	otlK8bu = 0.0
func wkrZ_rt():
	super()
	var Dsqf2JI = f8zPDfg.new()
	Dsqf2JI.Ci0ICMz(68)
	Client.wNmJul_(Dsqf2JI)
const cvZQgp6: int = 100
const JYKIZtz: int = 101
var EHIZOzV: bool = true
var cWUa6Ul: bool = false
func _physics_process(zalR3mw):
	if _y25e_L.has("invisible"):
		if MainInstances.ftDgoDH and !MainInstances.ftDgoDH.has_buff(30) :
			remove_iframe_status("invisible")
	if MIg_bmt > 0.0 and Time.get_ticks_msec() >= MIg_bmt:
		MIg_bmt = 0.0
		remove_iframe_status("blinking")
	xhtQxEy()
	super(zalR3mw)
	_db7VaN()
	KFydpyF()
	if Client.Bde90Hf.get("record", "") == "mover":
		TH8aIsP()
	if Client.Bde90Hf.get("follow", false):
		eYALttl()
	var P1tQpo3 = is_on_floor()
	if P1tQpo3 and not EHIZOzV:
		zKkjFYD(cvZQgp6)
		k1Dqydf()
	elif not P1tQpo3 and EHIZOzV:
		k1Dqydf()
	EHIZOzV = P1tQpo3
	var ZI4hlYe = is_on_wall()
	if ZI4hlYe and not cWUa6Ul:
		zKkjFYD(JYKIZtz)
	cWUa6Ul = ZI4hlYe
var Nx3qK_M : Dictionary = {}
var Vw23V5I : bool = false
func k9ugNHJ() -> Array:
	return [hat_sprite, gmoLZC4, topwear_sprite, pXaTxVR, weapon_sprite, UrXbbj5, fishing_rod]
func KFydpyF():
	var sblCCAe : bool = _y25e_L.has("general_iframe")
	if sblCCAe and not Vw23V5I:
		Nx3qK_M.clear()
		for LfjHofO in k9ugNHJ():
			if !is_instance_valid(LfjHofO): continue
			Nx3qK_M[LfjHofO] = LfjHofO.visible
	elif not sblCCAe and Vw23V5I:
		for LfjHofO in Nx3qK_M.keys():
			if !is_instance_valid(LfjHofO): continue
			LfjHofO.visible = Nx3qK_M[LfjHofO]
		Nx3qK_M.clear()
	if sblCCAe:
		var ZMavuTL : Node2D = $SubViewportContainer/SubViewport/Node2D
		if is_instance_valid(ZMavuTL):
			var PoyvxpT : bool = ZMavuTL.visible
			for LfjHofO in Nx3qK_M.keys():
				if !is_instance_valid(LfjHofO): continue
				LfjHofO.visible = bool(Nx3qK_M[LfjHofO]) and PoyvxpT
	Vw23V5I = sblCCAe
func i2EvNMG(lOA5nkI):
	super(lOA5nkI)
	zyYulzI()
	yKvQ1F0()
var cP_KQWi : int = 0
var krstx3N : bool = false
func yKvQ1F0() -> void:
	var B0kz5Rj = MainInstances.ftDgoDH
	if B0kz5Rj == null: return
	var _sgpXqt = B0kz5Rj.Gzp1wiA(Utils.cel77bE)
	var NKc53jB : bool = _sgpXqt != null and _sgpXqt.buff != null \
			and !_sgpXqt.buff.xSrpkCl
	cP_KQWi = shadow_step_lockout_after_invis_end(
			krstx3N, NKc53jB, Time.get_ticks_msec(),
			GlobalVars.azkzQSO, cP_KQWi)
	krstx3N = NKc53jB
static func shadow_step_press_blocked(HpKnplD : bool, Jwjv5KJ : int, jiv1MfZ : int) -> bool:
	if HpKnplD: return true
	return Jwjv5KJ < jiv1MfZ
static func shadow_step_lockout_after_invis_end(t_i3YJD : bool, GrhiDNG : bool,
		Y_ZXDi_ : int, vbYfWSX : float, TFCU8IS : int) -> int:
	if t_i3YJD and !GrhiDNG and vbYfWSX > 0.0:
		return Y_ZXDi_ + int(vbYfWSX)
	return TFCU8IS
func xhtQxEy():
	if Client.Bde90Hf.get("autopilot", "") != "":
		if Events.MYCRnYO():
			PT9D76k()
			if not M988V7b:
				M988V7b = true
				print("[harness] autopilot paused: player busy (UI open?)")
			return
		if M988V7b:
			M988V7b = false
			print("[harness] autopilot resumed")
		if H77hocR != null:
			gYfQ_ok()
		p4mdJHW()
		return
	if Events.MYCRnYO() or Events.h_2mw8B:
		PT9D76k()
	elif H77hocR != null:
		gYfQ_ok()
	if Utils.WL66ydI("left"):
		cHjVtNZ("left")
	if Input.is_action_just_released("left"):
		cHjVtNZ("left_released")
	if Utils.WL66ydI("right"):
		cHjVtNZ("right")
	if Input.is_action_just_released("right"):
		cHjVtNZ("right_released")
	if Utils.WL66ydI("up"):
		cHjVtNZ("up")
	if Input.is_action_just_released("up"):
		cHjVtNZ("up_released")
	if Utils.WL66ydI("down"):
		cHjVtNZ("down")
	if Input.is_action_just_released("down"):
		cHjVtNZ("down_released")
	if Utils.WL66ydI("jump"):
		cHjVtNZ("jump")
	if not Events.D6k65P9():
		if Utils.WL66ydI("strafe"):
			cHjVtNZ("strafe")
		if Input.is_action_just_released("strafe"):
			cHjVtNZ("strafe_released")
	FmwaEaa()
	if !Input.is_action_pressed("control"):
		if Utils.WL66ydI("emote_1"):
			NeWNMNl(0)
		if Utils.WL66ydI("emote_2"):
			NeWNMNl(1)
		if Utils.WL66ydI("emote_3"):
			NeWNMNl(2)
		if Utils.WL66ydI("emote_4"):
			NeWNMNl(3)
		if Utils.WL66ydI("emote_5"):
			NeWNMNl(4)
	DjERSK6()
const Pecxawk := 2.0
static func oob_claim_due(nOOJaXe : bool, AKZddbz : float) -> bool:
	if !nOOJaXe: return false
	return AKZddbz <= 0
func zyYulzI():
	var wn7g4IO = MainInstances.world
	if !wn7g4IO is World: return
	var R29pP_K : bool = global_position.y > wn7g4IO.Fkrumgi * 16
	if oob_claim_due(R29pP_K, DGrbDI8.time_left):
		DGrbDI8.start(Pecxawk)
		var q9JuW2K = f8zPDfg.new()
		q9JuW2K.Ci0ICMz(41)
		Client.wNmJul_(q9JuW2K)
	VQzgkFr = R29pP_K
func NeWNMNl(bqH3KmI : int):
	if RxW8KOH.time_left > 0: return
	RxW8KOH.start()
	var qhe8Kbf = f8zPDfg.new()
	qhe8Kbf.Ci0ICMz(94)
	qhe8Kbf.ZI1tHJY(bqH3KmI)
	Client.wNmJul_(qhe8Kbf)
func cHjVtNZ(nICy3L6 : String) -> void:
	if !Events.MYCRnYO() and !Events.h_2mw8B:
		yMrx5BO(nICy3L6, input)
	elif Hj3ejZa != null:
		yMrx5BO(nICy3L6, Hj3ejZa)
func DjERSK6():
	if pYNMJT9("left"):
		zKkjFYD(1)
	if OOhvF7T("left"):
		zKkjFYD(6)
	if pYNMJT9("right"):
		zKkjFYD(0)
	if OOhvF7T("right"):
		zKkjFYD(5)
	if pYNMJT9("up"):
		zKkjFYD(7)
	if OOhvF7T("up"):
		zKkjFYD(8)
	if pYNMJT9("down"):
		zKkjFYD(9)
	if OOhvF7T("down"):
		zKkjFYD(10)
	if pYNMJT9("jump"):
		zKkjFYD(4)
	if pYNMJT9("basic_attack"):
		zKkjFYD(2)
	if OOhvF7T("basic_attack"):
		zKkjFYD(11)
	if pYNMJT9("strafe"):
		zKkjFYD(12)
	if OOhvF7T("strafe"):
		zKkjFYD(13)
func gYfQ_ok():
	input = H77hocR.duplicate()
	H77hocR = null
	for X9hhB27 in input.values():
		var XF9ptzF = false
		if X9hhB27.pressed and Hj3ejZa[X9hhB27.name].pressed:
			XF9ptzF = true
		elif !X9hhB27.pressed and Hj3ejZa[X9hhB27.name].pressed:
			X9hhB27.pressed = true
			XF9ptzF = true
		else:
			X9hhB27.pressed = false
		if XF9ptzF:
			var _qpaLeD = str(X9hhB27.name)
			var ZT0FGLA = Utils.hg3HWnu(_qpaLeD)
			if ZT0FGLA == -1: return
			else: zKkjFYD(ZT0FGLA)
func PT9D76k():
	if H77hocR == null:
		H77hocR = input.duplicate(true)
		Hj3ejZa = input.duplicate(true)
	for lp6WBkn in input.values():
		if lp6WBkn.pressed:
			lp6WBkn.pressed = false
			var CcJ9HhJ = str(lp6WBkn.name) + "_released"
			var nHnYhky = Utils.hg3HWnu(CcJ9HhJ)
			if nHnYhky == -1: return
			else: zKkjFYD(nHnYhky)
		if lp6WBkn.just_pressed:
			lp6WBkn.just_pressed = false
		if lp6WBkn.just_released:
			lp6WBkn.just_released = false
var Nbk2xCH: Array = []
var O5l4vSo: int = 0
const cbBEpHO: int = 4
func zKkjFYD(N3SQfFF):
	Nbk2xCH.push_back({
		"seq": O5l4vSo,
		"control": N3SQfFF,
		"ts": Client.ZeHWzCN(),
		"x": int(global_position.x),
		"y": int(global_position.y),
	})
	O5l4vSo += 1
	if Nbk2xCH.size() > cbBEpHO:
		Nbk2xCH.pop_front()
	var NbsRfra : f8zPDfg = f8zPDfg.new()
	NbsRfra.Ci0ICMz(2)
	NbsRfra.GIe2Q4y(Nbk2xCH.size())
	for f60_yW2 in Nbk2xCH:
		NbsRfra.ZI1tHJY(f60_yW2.seq)
		NbsRfra.GIe2Q4y(f60_yW2.control)
		NbsRfra.GstR7Y4(f60_yW2.ts)
		NbsRfra.MErDRkw(f60_yW2.x)
		NbsRfra.MErDRkw(f60_yW2.y)
	Client.wNmJul_(NbsRfra)
func antYexL(aHHnCTX : int) -> void:
	var UWlV9QQ : int = 1 if aHHnCTX >= 0 else -1
	if animated_sprite_2d.scale.x == UWlV9QQ: return
	twsFj54(UWlV9QQ)
	zKkjFYD(14 if UWlV9QQ == 1 else 15)
func X1NLxlF():
	super()
var ezTx3WO := {"x": 0, "y": 0, "velx": 0, "vely": 0, "state": -1}
var GpTSo72 : int = 0
func _on_send_position_timer_timeout():
	var ym4MKID : int = int(global_position.x)
	var zm4MKID : int = int(global_position.y)
	var ZfEIlDK : int = int(velocity.x)
	var _fEIlDK : int = int(velocity.y)
	var tdxiyrZ : bool = animated_sprite_2d.scale.x > 0
	var em0ir1g : int = (1 if is_on_floor() else 0) | (2 if tdxiyrZ else 0)
	var W6VQShN : int = Time.get_ticks_msec()
	var i7f4HZ5 : bool = (
		ym4MKID == ezTx3WO.x and zm4MKID == ezTx3WO.y and
		ZfEIlDK == ezTx3WO.velx and _fEIlDK == ezTx3WO.vely and
		em0ir1g == ezTx3WO.state
	)
	if i7f4HZ5 and W6VQShN - GpTSo72 < 1000:
		return
	ezTx3WO.x = ym4MKID
	ezTx3WO.y = zm4MKID
	ezTx3WO.velx = ZfEIlDK
	ezTx3WO.vely = _fEIlDK
	ezTx3WO.state = em0ir1g
	GpTSo72 = W6VQShN
	var S0MZZMn = f8zPDfg.new()
	S0MZZMn.Ci0ICMz(1)
	S0MZZMn.MErDRkw(ym4MKID)
	S0MZZMn.MErDRkw(zm4MKID)
	S0MZZMn.MErDRkw(ZfEIlDK)
	S0MZZMn.MErDRkw(_fEIlDK)
	S0MZZMn.GIe2Q4y(em0ir1g)
	S0MZZMn.GstR7Y4(W6VQShN)
	Client.wNmJul_(S0MZZMn)
func MoZzUZP() -> Dictionary:
	_on_send_position_timer_timeout()
	vPywtHx.start()
	return ezTx3WO.duplicate()
var WGnVwEv : int = 0
func k1Dqydf() -> void:
	var G3KLfOG : int = Time.get_ticks_msec()
	if G3KLfOG - WGnVwEv < 50:
		return
	WGnVwEv = G3KLfOG
	_on_send_position_timer_timeout()
	vPywtHx.start()
func _on_hurtbox_hurt(iOn6W1o : Hitbox):
	match CaEM9kI.current_animation:
		"roll":
			return
	if iOn6W1o.hitbox_type == iOn6W1o.d_AJ4hS.jE6tAZ6:
		var MuXpPsA = f8zPDfg.new()
		MuXpPsA.Ci0ICMz(19)
		MuXpPsA.ZI1tHJY(iOn6W1o.source.enemy_id)
		Client.wNmJul_(MuXpPsA)
	elif iOn6W1o.hitbox_type == iOn6W1o.d_AJ4hS.cOXLFhc:
		var MuXpPsA = f8zPDfg.new()
		MuXpPsA.Ci0ICMz(54)
		MuXpPsA.ZI1tHJY(iOn6W1o.source.global_position.x)
		MuXpPsA.ZI1tHJY(iOn6W1o.source.Qh7y2Xq)
		MuXpPsA.GIe2Q4y(iOn6W1o.source.CJSG0DL)
		Client.wNmJul_(MuXpPsA)
func _QUt20m(kVr1IA0 : OgnvWA9) -> void:
	if GlobalVars.god_mode:
		return
	super(kVr1IA0)
	tuqfvde()
	Events.qchPzKi.emit(3, 0.1)
	if stats.Ylohbul() < 0.5:
		Events.XLA3p3l.emit()
		_A9_PSC()
func tuqfvde():
	xe4qYvz.play("flash")
func n8qsjJP() -> float:
	var kI6ZIEg : float = Client.jUZ7xu1.get("combat_footwork", 0.0)
	return max(GlobalVars.uXfCh89, kI6ZIEg / 100.0)
const jcvJbko : float = 0.1
const muEFlHF : float = 0.02
func FmwaEaa():
	if Events.MYCRnYO(): return
	if !wXQVu6D.monitoring and fcyzCHP.time_left <= 0:
		var auH8Vi8 : float = jcvJbko
		var acS2_Ue : float = Client.jUZ7xu1.get("pick_up_speed", 0.0)
		if acS2_Ue > 0.0:
			auH8Vi8 = max(muEFlHF, jcvJbko / (1.0 + acS2_Ue / 100.0))
		fcyzCHP.wait_time = auH8Vi8
		fcyzCHP.start()
		wXQVu6D.monitoring = true
		wXQVu6D.active = true
		await get_tree().create_timer(auH8Vi8).timeout
		wXQVu6D.monitoring = false
func hII8DAH(YCMkhwf):
	if yRud5g6 != YCMkhwf:
		for GCYcHyq in get_tree().get_nodes_in_group("interactable_object"):
			GCYcHyq.tbthNl5(false)
	yRud5g6 = YCMkhwf
	if yRud5g6 is QReTwRd:
		yRud5g6.tbthNl5(true)
func DobCuQz():
	match dwI_As0:
		"dash_strike":
			VGPxxA6.monitoring = false
	super()
func J_GQK4s():
	_kWuwRF.start()
func gIrDU1t():
	return _kWuwRF.time_left > 0
func QpnpTz9():
	var PdQyeng : float = GlobalVars.jUm8Ir_
	if PdQyeng <= 0.0:
		return
	MIg_bmt = Time.get_ticks_msec() + PdQyeng
	add_iframe_status("blinking")
func rnjD3EU():
	if MIg_bmt == 0.0 and !_y25e_L.has("blinking"):
		return
	MIg_bmt = 0.0
	remove_iframe_status("blinking")
func add_iframe_status(L5Jo4Av : String):
	if !_y25e_L.has(L5Jo4Av):
		_y25e_L.push_back(L5Jo4Av)
	cyndjkY()
func remove_iframe_status(jZheAyH : String):
	var tFa9bsg = _y25e_L.find(jZheAyH)
	if tFa9bsg != -1:
		_y25e_L.remove_at(tFa9bsg)
	cyndjkY()
func cyndjkY():
	A1Cs3Yq(_y25e_L.is_empty())
func A1Cs3Yq(spzLt3O : bool):
	hurtbox.monitorable = spzLt3O
func aG413tM():
	pass
func set_shadow_step_visual(oEO4mPZ : bool) -> void:
	super(oEO4mPZ)
	if oEO4mPZ:
		add_iframe_status("invisible")
	else:
		remove_iframe_status("invisible")
func gCDadvi(tB3EAfh : Skill = null) -> int:
	if tB3EAfh and tB3EAfh.skill_data and Enums.z8gRoDm.has(tB3EAfh.skill_data.skill_id):
		if tB3EAfh.QaurvLo(): return 1
		if !tB3EAfh.active: return 2
		if !tB3EAfh.qlm84cT(): return 1
		if Events.dwpxXBS(): return 2
		return 0
	if PlayerEffect.VmuuMVG and tB3EAfh and tB3EAfh.skill_data \
			and tB3EAfh.skill_data.skill_id == Enums.Skills.NpxzNO2 and lHpjANZ:
		if tB3EAfh.QaurvLo(): return 1
		return 0
	if tB3EAfh and tB3EAfh.skill_data and tB3EAfh.skill_data.skill_id == Enums.Skills.hE1jdyU \
			and MainInstances.ftDgoDH != null and MainInstances.ftDgoDH.sfb2tZb():
		return 0
	if tB3EAfh and tB3EAfh.skill_data and tB3EAfh.skill_data.skill_id == Enums.Skills.UosJ3PC:
		var Bw8XEpS : bool = MainInstances.ftDgoDH != null \
				and MainInstances.ftDgoDH.has_buff(Utils.cel77bE)
		if shadow_step_press_blocked(Bw8XEpS, Time.get_ticks_msec(), cP_KQWi):
			return 1
	if state == hzAttLc : return 1
	if state == ecFE5km : return 1
	if state == rAGmpFa : return 1
	if jZ2MPjJ(): return 1
	if tB3EAfh:
		if !tB3EAfh.skill_data: return 1
		if tB3EAfh.QaurvLo() and !Enums.M4RY9iB.has(tB3EAfh.skill_data.skill_id):
			return 1
		if !tB3EAfh.active: return 2
		if !tB3EAfh.qlm84cT(): return 1
		match tB3EAfh.skill_data.skill_id:
			Enums.Skills.BhEwgZT, Enums.Skills.Yr7W2O9:
				pass
			_:
				if MLYsge8():
					if Enums.xkyGk0d.has(tB3EAfh.skill_data.skill_id):
						return 1
					return 3
	else:
		if MLYsge8(): return 1
	if Events.dwpxXBS():
		return 2
	return 0
var _BhnHYx : Array = []
func ejdxwhm(Y1kGFy8 : Dictionary) -> void:
	_BhnHYx.push_back(Y1kGFy8)
func BAGy4Xt() -> void:
	_BhnHYx.clear()
const xr89YXZ := 0
const IcTle1O := 1
const mQLoE1a := 2
const o7UjxWC := 15000
static func effect_block_verdict(FliE4CE : bool, b11EjYH : bool, K_Kme9B : bool,
		yMW6uCI : int, hBPa4_4 : int) -> int:
	if !FliE4CE: return xr89YXZ
	if !b11EjYH: return xr89YXZ
	if K_Kme9B: return xr89YXZ
	if yMW6uCI != 0 and hBPa4_4 - yMW6uCI > o7UjxWC:
		return mQLoE1a
	return IcTle1O
func BmiMkNQ() -> bool:
	for ILBm5bM in duNZcYF:
		match effect_block_verdict(ILBm5bM.YRUChjm(),
				ILBm5bM.Mm4YOzi(), ILBm5bM.AbAybnb(),
				ILBm5bM.U06drwD, Utils.I8gfbeG()):
			mQLoE1a:
				ILBm5bM.clDPlOg()
			IcTle1O:
				return true
	return false
func _db7VaN() -> void:
	var _CzAWRm : bool = BmiMkNQ()
	if _BhnHYx.is_empty(): return
	if _CzAWRm: return
	mrvTNMu(_BhnHYx.pop_front())
func Q2v_OO2():
	add_child(jkOoACx.instantiate())
func SwhR9GP():
	var fMIH0GD : Control = IFo7aHf
	if !(fMIH0GD is Control): return
	var rTmyQIC := TextureRect.new()
	rTmyQIC.name = "QuestCompletableMarker"
	rTmyQIC.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rTmyQIC.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rTmyQIC.visible = false
	rTmyQIC.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rTmyQIC.z_index = 100
	fMIH0GD.add_child(rTmyQIC)
	rTmyQIC.set_anchors_preset(Control.PRESET_TOP_LEFT)
	rTmyQIC.offset_left = 4
	rTmyQIC.offset_top = -45
	rTmyQIC.offset_right = 20
	rTmyQIC.offset_bottom = -29
	yQbttAB = rTmyQIC
	nwd9V5_.clear()
	for Mp64Gfa in 2:
		var dTpDNg9 := AtlasTexture.new()
		dTpDNg9.atlas = CdBDzeL
		dTpDNg9.region = Rect2(Mp64Gfa * 16, 0, 16, 15)
		nwd9V5_.append(dTpDNg9)
	var cBUTxUb := Timer.new()
	cBUTxUb.wait_time = 0.5
	cBUTxUb.one_shot = false
	cBUTxUb.timeout.connect(paD_cN3)
	rTmyQIC.add_child(cBUTxUb)
	njF9F7V = cBUTxUb
	GHZK1pp()
func BgPu261(VhcFlsH : String):
	r7Sq4vV = VhcFlsH
	if yQbttAB is TextureRect:
		yQbttAB.visible = VhcFlsH != ""
	GHZK1pp()
func GHZK1pp() -> void:
	if !(yQbttAB is TextureRect): return
	var qWE6VL0 : bool = yQbttAB.visible and TutorialGuide.OYlfRqy
	if qWE6VL0:
		yQbttAB.texture = nwd9V5_[ZbIfGuF]
		yQbttAB.pivot_offset = Vector2.ZERO
		yQbttAB.scale = Vector2.ONE
		if njF9F7V != null and njF9F7V.is_stopped():
			njF9F7V.start()
	else:
		if njF9F7V != null:
			njF9F7V.stop()
		ZbIfGuF = 0
		yQbttAB.texture = C5kf__u
		yQbttAB.pivot_offset = Vector2(8, 8)
		yQbttAB.scale = Vector2(-1, 1)
func paD_cN3() -> void:
	ZbIfGuF = 1 - ZbIfGuF
	GHZK1pp()
func wIXffip(NHgVIYp : bool) -> void:
	GHZK1pp()
func get_quest_marker_world_rect() -> Rect2:
	if !(yQbttAB is TextureRect): return Rect2()
	if !yQbttAB.visible: return Rect2()
	var DsnkLPO := yQbttAB.get_parent() as Control
	if DsnkLPO == null: return Rect2()
	return Rect2(DsnkLPO.get_global_position() + yQbttAB.position,
		yQbttAB.size)
func _input(hmK8BQk : InputEvent):
	if !(hmK8BQk is InputEventMouseButton): return
	if !hmK8BQk.pressed: return
	if hmK8BQk.button_index != MOUSE_BUTTON_LEFT: return
	if hmK8BQk.double_click: return
	if !(yQbttAB is TextureRect): return
	if !yQbttAB.visible: return
	if r7Sq4vV == "": return
	if UiManager.z2u2j5v(Utils.uADBluO()): return
	var cR5y7VD := get_quest_marker_world_rect()
	if !cR5y7VD.has_point(get_global_mouse_position()): return
	YdAlZau()
	get_viewport().set_input_as_handled()
func YdAlZau():
	var k3MoXOw = MainInstances.quest_window
	if !(k3MoXOw is QuestWindow): return
	if !k3MoXOw.visible:
		k3MoXOw.ljeABXw()
	k3MoXOw.JyVXdT3(r7Sq4vV, false)
	var dRyOIEd = k3MoXOw.get_quest_list_quest_by_quest_id(r7Sq4vV)
	if dRyOIEd and dRyOIEd.has_method("color_as_selected"):
		dRyOIEd.call_deferred("color_as_selected")
func try_open_completable_quest() -> bool:
	if !(yQbttAB is TextureRect): return false
	if !yQbttAB.visible: return false
	if r7Sq4vV == "": return false
	YdAlZau()
	return true
func p4mdJHW() -> void:
	if l8aBpxq:
		if NsdpHXK > 0:
			NsdpHXK -= 1
			if NsdpHXK == 0:
				get_tree().quit()
		return
	if WLQKd50 == null:
		WLQKd50 = N9WJYeB.new(Client.Bde90Hf.get("autopilot", ""))
	var bz2xXXL : bool = WLQKd50.step(self, EzsDipd)
	EzsDipd += 1
	if not bz2xXXL:
		l8aBpxq = true
		NsdpHXK = uzWyovj
		GhK36fa()
func Hu9CMaF() -> void:
	if Y5lLaYJ or XkJABwF:
		return
	DirAccess.make_dir_recursive_absolute("user://harness")
	var Psjn1Ot : int = int(Time.get_unix_time_from_system() * 1000.0)
	var sREhKhr : String = "user://harness/mover_%d_%d.csv" % [account_id, Psjn1Ot]
	Vw6gBFh = FileAccess.open(sREhKhr, FileAccess.WRITE)
	if Vw6gBFh == null:
		XkJABwF = true
		return
	TJ3urXA.clear()
	TJ3urXA.append("t_ticks,t_server,x,y,velx,vely,on_floor")
	Y5lLaYJ = true
func TH8aIsP() -> void:
	if not Y5lLaYJ:
		Hu9CMaF()
		if not Y5lLaYJ:
			return
	var QV67CX_ : int = 1 if is_on_floor() else 0
	TJ3urXA.append("%d,%d,%f,%f,%f,%f,%d" % [
		Time.get_ticks_msec(),
		Client.ZeHWzCN(),
		global_position.x, global_position.y,
		velocity.x, velocity.y,
		QV67CX_,
	])
	if TJ3urXA.size() >= FqBFzl5:
		GhK36fa()
func GhK36fa() -> void:
	if Vw6gBFh == null:
		return
	for X7fxp2w in TJ3urXA:
		Vw6gBFh.store_line(X7fxp2w)
	TJ3urXA.clear()
	Vw6gBFh.flush()
func eYALttl() -> void:
	var Cm7C8EN = MainInstances.camera
	if not (Cm7C8EN is Camera2D):
		return
	var wHxoZXD = null
	for mf8fsyj in Utils.iAMI0Ft():
		if mf8fsyj is Character and not (mf8fsyj is Player):
			wHxoZXD = mf8fsyj
			break
	if wHxoZXD == null:
		return
	ZDg5TFp.update_position = false
	Cm7C8EN.global_position = wHxoZXD.global_position
func _step_gfx_apply() -> void:
	super()
	ZDg5TFp.position.y = rH5s_JK + p9No9OH
func JCgGE7d() -> void:
	GhK36fa()
	get_tree().quit()