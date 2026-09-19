extends Node

# --- 原始 GlobalVars（不要删除；其他脚本会读取这些变量）---
var IXqPDbO : float = 0.1
var ZpPn0Ai : float = 0.2
var vCosXI_ : float = 1.0
var sxrdjxp : float = 1.5
var jUm8Ir_ : float = 250.0
var azkzQSO : float = 4000.0
var XV3jemg : float = 4000.0
var ydy5qL7 : float = 30000.0
var uXfCh89 : float = 0.5
var VX8gaBb : bool = true
var link_throw_enabled : bool = true
var link_throw_radius_px : float = 250.0
var link_throw_base_satellites : int = 5
var link_throw_max_satellites : int = 12
var link_throw_scale_per_satellite : float = 0.04
var link_throw_duration_ms : float = 10000.0
var auto_step_up_max_px : float = 16.0
var xAsIL5s : Dictionary = {}

# =============================================================================
# 作弊菜单 - 标签页式 UI
#   INSERT  - 打开/关闭菜单   |   拖拽标题栏移动   |   拖拽右下角缩放
# =============================================================================
const CHEAT_MIN_SIZE := Vector2(115, 128)
const TP_INTERVAL : float = 0.2

# --- 主题颜色 ---
const ACCENT      : Color = Color(0.20, 0.65, 0.95)
const ACCENT_DARK : Color = Color(0.08, 0.30, 0.46)
const BG_PANEL    : Color = Color(0.11, 0.11, 0.15, 0.96)
const BG_TITLE    : Color = Color(0.07, 0.07, 0.10, 0.98)
const BORDER      : Color = Color(0.0, 0.0, 0.0)
const TEXT        : Color = Color(0.93, 0.93, 0.95)
const TEXT_DIM    : Color = Color(0.72, 0.72, 0.78)
const ROW_ON_BG   : Color = Color(0.12, 0.35, 0.18, 0.95)
const ROW_ON_BORDER : Color = Color(0.20, 0.55, 0.28)
const ROW_OFF_BG  : Color = Color(0.35, 0.12, 0.12, 0.95)
const ROW_OFF_BORDER : Color = Color(0.55, 0.20, 0.20)

# --- 作弊开关状态（其他脚本会读取）---
var auto_combat      : bool = false
var auto_attack      : bool = false
var no_pickup_cd     : bool = true
var pickup_range_on  : bool = true
var god_mode         : bool = true
var mob_vacuum       : bool = false
var auto_tp_mob           : bool = false
var auto_tp_crystal        : bool = false
var vacuum_mode           : int = 0
var vacuum_count          : int = 10   # 全图吸怪数量上限
var player_detect         : bool = false  # 玩家检测：有非队伍玩家时自动关闭自动战斗
var full_map_pickup  : bool = false
var hp_bars_on       : bool = true
var no_darkness      : bool = false
var eternal_night    : bool = false
var eternal_night_time : float = 0.0
var uncapped_fps     : bool = true
var hide_weather         : bool = true
var postfx_off           : bool = true
# --- 可调参数 ---
var combat_range     : float = 9999.0  # 自动战斗 最大距离
var pickup_range_mult : float = 9999.0   # 玩家 ItemDropPickUpHitbox 缩放倍率
var vacuum_range     : float = 9999.0  # 全图吸怪范围

# --- 菜单管理变量 ---
var cheat_menu         : Control = null
var _menu_layer        : CanvasLayer = null
var _menu_root         : Control = null
var _cheat_panel       : PanelContainer = null
var _tab_pages         : Dictionary = {}
var _tab_buttons       : Dictionary = {}
var _checkbox_refs     : Dictionary = {}
var _slider_containers : Dictionary = {}
var _value_sliders     : Dictionary = {}
var _rows : Dictionary = {}
var _font_mono : SystemFont = null
var _font_ui   : SystemFont = null
var _dragging   : bool = false
var _drag_offset : Vector2 = Vector2.ZERO
var _ui_cheat_rect : Rect2 = Rect2(0, 0, 179, 198)
var _combat_elapsed : float = 0.0
var _pickup_held : bool = false
var _combat_panel : VBoxContainer = null
var _last_boss_id : int = -1
var _pickup_scale_original : Vector2 = Vector2.ZERO
var _forced_hp_bars : Dictionary = {}
var _visual_nodes   : Dictionary = {}
var _vis_elapsed    : float = 0.0
var _fps_original   : int = 0
var _postfx_saved   : Dictionary = {}

# --- 自动攻击 ---
var _attack_action : String = ""
var _attack_held   : bool = false
var _attack_tap_next : int = 0
var _attack_tap_hold : int = 0

func _ready() -> void:
	_fps_original = Engine.max_fps
	get_tree().node_added.connect(_on_node_added)
	call_deferred("_build_menu")
	print("[cheat] loaded. INSERT for menu.")


func _input(event: InputEvent) -> void:
	if event is InputEventKey and not event.echo:
		var ke: InputEventKey = event as InputEventKey
		if ke.pressed and (ke.keycode == KEY_INSERT or ke.keycode == KEY_L) and _menu_root != null:
			_menu_root.visible = not _menu_root.visible
			_menu_root.mouse_filter = Control.MOUSE_FILTER_STOP if _menu_root.visible else Control.MOUSE_FILTER_IGNORE
			get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	var mi = get_node_or_null("/root/MainInstances")
	if mi == null:
		return
	var player = mi.player
	if player == null or not is_instance_valid(player):
		return

	# 玩家检测（最高优先级）：地图中有非队伍的玩家时自动关闭自动战斗
	if auto_combat and player_detect and _has_non_party_players():
		auto_combat = false
		var _cb_data = _checkbox_refs.get("auto_combat", {})
		var _cb = _cb_data.get("cb") if _cb_data else null
		if _cb != null:
			_cb.button_pressed = false
		var _panel = _cb_data.get("panel") if _cb_data else null
		if _panel != null:
			_update_row_color(_panel, false)
		print("[cheat] player_detect: non-party player detected, auto-combat disabled")

	# 自动战斗：传送 + 全图拾取
	if auto_combat:
		_combat_elapsed += delta
		if _combat_elapsed >= TP_INTERVAL:
			_combat_elapsed = 0.0
			_auto_combat_tick(player)
			
			# _full_map_pickup(player)  # 已独立为"全图拾取"

	# 自动战斗：按住拾取键，覆盖需要按键才捡的物品
	if auto_combat:
		if not _pickup_held:
			Input.action_press("pick_up")
			_pickup_held = true
	elif _pickup_held:
		Input.action_release("pick_up")
		_pickup_held = false

	# 自动攻击
	if auto_combat:
		if auto_attack:
			_auto_attack_tick()
		elif _attack_held:
			_release_attack()

	# 拾取无CD：强制拾取 hitbox 常开
	if no_pickup_cd:
		if "wXQVu6D" in player and player.wXQVu6D != null:
			player.wXQVu6D.monitoring = true
			player.wXQVu6D.active = true

	# 拾取范围：缩放 ItemDropPickUpHitbox 的 CollisionShape2D
	if "wXQVu6D" in player and player.wXQVu6D != null:
		var shape_node = _find_collision_shape(player.wXQVu6D)
		if shape_node != null:
			if _pickup_scale_original == Vector2.ZERO:
				_pickup_scale_original = shape_node.scale
			shape_node.scale = _pickup_scale_original * pickup_range_mult if pickup_range_on else _pickup_scale_original

	# 无敌模式：双层防护
	# 第一层（player.gd _QUt20m）：if GlobalVars.god_mode: return，伤害不进处理流程
	# 第二层（本脚本）：碰撞盒不可命中
	if god_mode:
		if "hurtbox" in player and player.hurtbox != null:
			player.hurtbox.monitorable = false

	# 吸怪：将范围内怪物拉向玩家
	if auto_combat and vacuum_mode == 2:
		_vacuum_enemies(player)

	# 全图拾取
	if auto_combat and full_map_pickup:
		_full_map_pickup(player)

	# 视觉功能：每 0.25s 刷新
	_vis_elapsed += delta
	if _vis_elapsed >= 0.25:
		_vis_elapsed = 0.0
		_apply_enemy_hp_bars()
		_apply_tracked_visuals()

	# 永夜：每帧强制 DayNightManager.time 为晚上
	if eternal_night:
		DayNightManager.time = eternal_night_time

	# 解锁帧率：每帧重新应用，防止切地图被重置
	if uncapped_fps:
		Engine.max_fps = 0


# ----- 字体 ----------------------------------------------------------------

func _get_mono() -> SystemFont:
	if _font_mono == null:
		_font_mono = SystemFont.new()
		_font_mono.font_names = PackedStringArray(["Consolas", "Courier New", "monospace"])
	return _font_mono


func _get_ui() -> SystemFont:
	if _font_ui == null:
		_font_ui = SystemFont.new()
		_font_ui.font_names = PackedStringArray(["Segoe UI", "Tahoma", "sans-serif"])
	return _font_ui


# ----- 辅助函数 --------------------------------------------------------------

func get_skill_level(skill) -> int:
	if skill == null:
		return 0
	return skill.level

func _find_collision_shape(node: Node) -> Node2D:
	for c in node.get_children():
		if c is CollisionShape2D:
			return c
	return null


func _on_node_added(n: Node) -> void:
	if n.get_script() != null:
		var p: String = str(n.get_script().resource_path)
		_track_visual_node("day_night", p, "day_night_cycle.gd", n)
		_track_visual_node("dark_light", p, "darkness_light.gd", n)
		_track_visual_node("weather", p, "plains_night_particles.gd", n)


func _track_visual_node(key: String, path: String, suffix: String, n: Node) -> void:
	if path.ends_with(suffix):
		if not _visual_nodes.has(key):
			_visual_nodes[key] = []
		var arr: Array = _visual_nodes[key]
		arr.append(weakref(n))
		if arr.size() > 64:
			arr.pop_front()


func _apply_enemy_hp_bars() -> void:
	for c in get_tree().get_nodes_in_group("Enemies"):
		if not (c is Enemy) or not is_instance_valid(c):
			continue
		var bar = c.get("Bq8wXDn")
		if bar == null or not is_instance_valid(bar):
			continue
		var bid: int = bar.get_instance_id()
		if hp_bars_on:
			_forced_hp_bars[bid] = bar
			if "IJB0Azb" in bar and bar.IJB0Azb != null:
				bar.IJB0Azb.stop()
			bar.visible = true
			bar.modulate.a = 1.0
		elif _forced_hp_bars.has(bid):
			_forced_hp_bars.erase(bid)
			bar.visible = false
			bar.modulate.a = 0.0


func _apply_tracked_visuals() -> void:
	for w in _visuals("day_night"):
		if no_darkness:
			w.process_mode = Node.PROCESS_MODE_DISABLED
			if "color" in w:
				w.color = Color.WHITE
		else:
			w.process_mode = Node.PROCESS_MODE_INHERIT
	for w in _visuals("dark_light"):
		if no_darkness:
			w.visible = false
	for w in _visuals("weather"):
		w.visible = not hide_weather

	var mi = get_node_or_null("/root/MainInstances")
	if mi != null and "hd2d_postfx" in mi and mi.hd2d_postfx != null:
		var fx = mi.hd2d_postfx
		if postfx_off:
			if _postfx_saved.is_empty():
				_postfx_saved = {
					"visible": fx.visible,
					"pm": fx.process_mode,
				}
			fx.visible = false
			fx.process_mode = Node.PROCESS_MODE_DISABLED
		elif not _postfx_saved.is_empty():
			fx.visible = _postfx_saved["visible"]
			fx.process_mode = _postfx_saved["pm"]
			_postfx_saved.clear()


func _visuals(key: String) -> Array:
	var out: Array = []
	if not _visual_nodes.has(key):
		return out
	for w in _visual_nodes[key]:
		var n = w.get_ref()
		if n != null and is_instance_valid(n):
			out.append(n)
	return out


func _vacuum_enemies(player) -> void:
	var center : Vector2 = player.global_position
	# 落点：玩家面前 33px
	var front : float = 33.0
	if "animated_sprite_2d" in player and player.animated_sprite_2d != null:
		front = 33.0 if player.animated_sprite_2d.scale.x > 0 else -33.0
	var slot : Vector2 = center + Vector2(front, 0.0)

	# 先检查全图是否有 boss，有则仅吸 boss
	var boss_target : Node2D = _nearest_boss(player)
	if boss_target != null:
		_vacuum_one(boss_target, center, slot)
		return

	var count := 0
	for e in get_tree().get_nodes_in_group("Enemies"):
		if not (e is Enemy) or not is_instance_valid(e):
			continue
		if e.is_dead:
			continue
		var d : float = e.global_position.distance_to(center)
		if d > vacuum_range:
			continue

		# 改写怪物跟随目标点，清空服务器位置队列防止回弹
		e.set("NfmkwDo", slot)
		var q = e.get("dKjyZs6")
		if q is Array:
			q.clear()

		# 距离 > 150px 时瞬移拉近，每次最大步长 900px
		if d > 150.0:
			var hop : float = minf(d - 120.0, 900.0)
			e.global_position = e.global_position.move_toward(slot, hop)

		count += 1
		if count >= vacuum_count:
			break


func _vacuum_one(e: Node2D, center: Vector2, slot: Vector2) -> void:
	if not is_instance_valid(e) or e.is_dead:
		return
	var d: float = e.global_position.distance_to(center)
	if d > vacuum_range:
		return
	e.set("NfmkwDo", slot)
	var q = e.get("dKjyZs6")
	if q is Array:
		q.clear()
	if d > 150.0:
		var hop: float = minf(d - 120.0, 900.0)
		e.global_position = e.global_position.move_toward(slot, hop)


func _has_non_party_players() -> bool:
	"""检测地图上是否有非队伍的玩家"""
	if get_tree() == null:
		return false
	if not Utils.has_method("iAMI0Ft"):
		return false
	if MainInstances.party_member_list_ui == null:
		return false

	# 收集队伍成员 account_id
	var party_ids : Array = []
	for member in MainInstances.party_member_list_ui.v_box_container.get_children():
		if not member.is_queued_for_deletion() and "account_id" in member:
			party_ids.append(member.account_id)

	# 遍历地图上所有角色
	for character in Utils.iAMI0Ft():
		if not is_instance_valid(character):
			continue
		if not "account_id" in character:
			continue
		# 跳过自己
		if character.account_id == Client.account_id:
			continue
		# 跳过队伍成员
		if character.account_id in party_ids:
			continue
		# 找到非队伍玩家
		return true
	return false


# ----- 自动攻击 -----------------------------------------------------------

func _find_attack_action() -> String:
	if _attack_action != "":
		return _attack_action
	for slot in get_tree().get_nodes_in_group("hotslot"):
		if not slot is HotSlot:
			continue
		if slot.is_embedded:
			continue
		if not is_instance_valid(slot.connected_slot):
			continue
		var binding = slot.connected_slot
		if not (binding is SkillSlot or binding is ComboSlot):
			continue
		for ev in InputMap.action_get_events("hotkey_" + str(slot.key)):
			if ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT:
				_attack_action = "hotkey_" + str(slot.key)
				return _attack_action
	return ""


func _auto_attack_tick() -> void:
	_find_attack_action()
	if _attack_action == "":
		return
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if _attack_held:
			_release_attack()
		return
	var now := Time.get_ticks_msec()
	if _attack_tap_hold > 0:
		if now >= _attack_tap_hold:
			Input.action_press(_attack_action)
			_attack_tap_hold = 0
			_attack_tap_next = now
	else:
		Input.action_release(_attack_action)
		_attack_tap_hold = now
		_attack_held = false


func _release_attack() -> void:
	if _attack_action != "":
		Input.action_release(_attack_action)
	_attack_held = false
	_attack_tap_next = 0
	_attack_tap_hold = 0


# ----- 菜单构建 --------------------------------------------------------

func _build_menu() -> void:
	if _menu_root != null:
		return
	_menu_layer = CanvasLayer.new()
	_menu_layer.layer = 128
	add_child(_menu_layer)

	_menu_root = Control.new()
	_menu_root.name = "CheatMenu"
	_menu_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_menu_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_menu_root.visible = false
	_menu_root.gui_input.connect(_on_menu_root_gui)
	cheat_menu = _menu_root
	_menu_layer.add_child(_menu_root)

	var panel_wrapper = PanelContainer.new()
	panel_wrapper.mouse_filter = Control.MOUSE_FILTER_STOP
	panel_wrapper.clip_contents = true
	panel_wrapper.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_cheat_panel = panel_wrapper
	_apply_cheat_panel_rect()

	var style := StyleBoxFlat.new()
	style.bg_color = BG_PANEL
	style.border_color = BORDER
	style.set_border_width_all(2)
	style.set_corner_radius_all(2)
	style.content_margin_left = 4
	style.content_margin_right = 4
	style.content_margin_top = 2
	style.content_margin_bottom = 2
	panel_wrapper.add_theme_stylebox_override("panel", style)
	_menu_root.add_child(panel_wrapper)

	var stack := Control.new()
	stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stack.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stack.clip_contents = true
	panel_wrapper.add_child(stack)

	var outer_vb := VBoxContainer.new()
	outer_vb.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	outer_vb.offset_right = -2
	outer_vb.offset_bottom = -2
	outer_vb.add_theme_constant_override("separation", 2)
	outer_vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	outer_vb.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stack.add_child(outer_vb)

	# 标题栏
	var title_panel := PanelContainer.new()
	var title_style := StyleBoxFlat.new()
	title_style.bg_color = BG_TITLE
	title_style.border_color = Color(0.25, 0.25, 0.30)
	title_style.set_border_width_all(1)
	title_style.set_corner_radius_all(2)
	title_style.content_margin_left = 4
	title_style.content_margin_right = 4
	title_style.content_margin_top = 2
	title_style.content_margin_bottom = 2
	title_panel.add_theme_stylebox_override("panel", title_style)
	title_panel.mouse_default_cursor_shape = Control.CURSOR_MOVE
	title_panel.gui_input.connect(_on_cheat_title_gui)
	outer_vb.add_child(title_panel)

	var title := Label.new()
	title.text = "-ovo-"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title.add_theme_font_size_override("font_size", 6)
	title.add_theme_color_override("font_color", Color(1.0, 0.25, 0.25))
	title_panel.add_child(title)

	# 标签栏
	var tab_row := HBoxContainer.new()
	tab_row.add_theme_constant_override("separation", 2)
	outer_vb.add_child(tab_row)

	var content := Control.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	outer_vb.add_child(content)

	var player_page := _make_tab_page(content, "战斗")
	var visual_page := _make_tab_page(content, "视觉")
	var misc_page   := _make_tab_page(content, "玩家")
	var remote_page := _make_tab_page(content, "远程")

	_make_tab_button(tab_row, "战斗")
	_make_tab_button(tab_row, "视觉")
	_make_tab_button(tab_row, "玩家")
	_make_tab_button(tab_row, "远程")

	# ---------- 玩家标签页 ----------
	_add_combat_group(player_page)

	# ---------- 视觉标签页 ----------
	_add_simple_checkbox(visual_page, "hp_bars_on", "敌人血条常显")
	_add_simple_checkbox(visual_page, "no_darkness", "去除黑暗")
	_add_toggle_with_slider(visual_page, "eternal_night", "世界时间", "eternal_night_time", "时间", 0.0, 1.0, 0.01)
	_add_simple_checkbox(visual_page, "uncapped_fps", "解锁帧率")
	_add_simple_checkbox(visual_page, "hide_weather", "隐藏天气")
	_add_simple_checkbox(visual_page, "postfx_off", "禁用后处理")

	# ---------- 杂项标签页 ----------
	_add_simple_checkbox(misc_page, "no_pickup_cd", "拾取无CD")
	_add_simple_checkbox(misc_page, "pickup_range_on", "范围拾取")
	_add_simple_checkbox(misc_page, "god_mode", "无敌模式")

	# ---------- 远程标签页 ----------
	_add_remote_buttons(remote_page)

	_switch_tab("战斗")
	call_deferred("_apply_cheat_panel_rect")


func _add_remote_buttons(parent: VBoxContainer) -> void:
	var buttons := [
		["拍卖行", func(): _remote_open_auction_house()],
	]
	for entry in buttons:
		var btn := Button.new()
		btn.text = entry[0]
		btn.custom_minimum_size = Vector2(100, 20)
		btn.add_theme_font_size_override("font_size", 5)
		btn.focus_mode = Control.FOCUS_NONE
		var btn_bg := StyleBoxFlat.new()
		btn_bg.bg_color = Color(0.12, 0.35, 0.18, 0.95)
		btn_bg.border_color = Color(0.20, 0.55, 0.28)
		btn_bg.set_border_width_all(1)
		btn_bg.set_corner_radius_all(2)
		btn_bg.content_margin_left = 2
		btn_bg.content_margin_right = 2
		btn_bg.content_margin_top = 2
		btn_bg.content_margin_bottom = 2
		for st in ["normal", "pressed", "hover", "hover_pressed", "focus"]:
			btn.add_theme_stylebox_override(st, btn_bg)
		var btn_fc := Color(0.95, 0.95, 0.97)
		for ov in ["font_color", "font_hover_color", "font_pressed_color", "font_hover_pressed_color", "font_focus_color"]:
			btn.add_theme_color_override(ov, btn_fc)
		btn.pressed.connect(entry[1])
		parent.add_child(btn)


func _remote_open_auction_house() -> void:
	var w = MainInstances.auction_house_window
	if w != null: w.toggle_visibility()


func _make_tab_page(parent: Control, key: String) -> VBoxContainer:
	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(scroll)
	_style_scrollbar(scroll)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 2)
	vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(vb)

	_tab_pages[key] = scroll
	return vb


func _style_scrollbar(scroll: ScrollContainer) -> void:
	var grab := StyleBoxFlat.new()
	grab.bg_color = Color(1.0, 1.0, 1.0, 1.0)
	grab.set_corner_radius_all(2)
	grab.content_margin_left = 1
	grab.content_margin_right = 1
	grab.content_margin_top = 3
	grab.content_margin_bottom = 3

	var track := StyleBoxFlat.new()
	track.bg_color = Color(0.15, 0.15, 0.18, 0.85)
	track.set_corner_radius_all(2)

	call_deferred("_deferred_style_scrollbar", scroll, grab, track)


func _deferred_style_scrollbar(scroll: ScrollContainer, grab: StyleBoxFlat, track: StyleBoxFlat) -> void:
	if scroll == null or not is_instance_valid(scroll):
		return
	var vbar = scroll.get_v_scroll_bar()
	if vbar == null:
		return
	vbar.custom_minimum_size.x = 2
	vbar.add_theme_stylebox_override("grabber", grab)
	vbar.add_theme_stylebox_override("grabber_highlight", grab)
	vbar.add_theme_stylebox_override("grabber_pressed", grab)
	vbar.add_theme_stylebox_override("scroll", track)
	vbar.add_theme_stylebox_override("scroll_focus", track)


func _make_tab_button(row: HBoxContainer, key: String) -> void:
	var btn := Button.new()
	btn.text = key
	btn.focus_mode = Control.FOCUS_NONE
	btn.custom_minimum_size = Vector2(0, 11)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.add_theme_font_size_override("font_size", 5)
	btn.pressed.connect(func(): _switch_tab(key))
	row.add_child(btn)
	_tab_buttons[key] = btn


func _switch_tab(key: String) -> void:
	for t in _tab_pages:
		_tab_pages[t].visible = (t == key)
	for t in _tab_buttons:
		_style_tab_button(_tab_buttons[t], t == key)


func _style_tab_button(b: Button, active: bool) -> void:
	var bg := StyleBoxFlat.new()
	if active:
		bg.bg_color = Color(0.12, 0.35, 0.18, 0.95)
		bg.border_color = Color(0.20, 0.55, 0.28)
	else:
		bg.bg_color = Color(0.35, 0.12, 0.12, 0.95)
		bg.border_color = Color(0.55, 0.20, 0.20)
	bg.set_border_width_all(1)
	bg.set_corner_radius_all(2)
	bg.content_margin_left = 2
	bg.content_margin_right = 2
	bg.content_margin_top = 2
	bg.content_margin_bottom = 2
	for st in ["normal", "pressed", "hover", "hover_pressed", "focus"]:
		b.add_theme_stylebox_override(st, bg)
	var fc := Color(0.95, 0.95, 0.97) if active else Color(0.90, 0.75, 0.75)
	for ov in ["font_color", "font_hover_color", "font_pressed_color", "font_hover_pressed_color", "font_focus_color"]:
		b.add_theme_color_override(ov, fc)


# =============================================================================
# UI 辅助函数
# =============================================================================
func _make_row_panel(is_on: bool) -> PanelContainer:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	if is_on:
		style.bg_color = ROW_ON_BG
		style.border_color = ROW_ON_BORDER
	else:
		style.bg_color = ROW_OFF_BG
		style.border_color = ROW_OFF_BORDER
	style.set_border_width_all(1)
	style.set_corner_radius_all(2)
	style.content_margin_left = 3
	style.content_margin_right = 3
	style.content_margin_top = 1
	style.content_margin_bottom = 1
	panel.add_theme_stylebox_override("panel", style)
	return panel


func _update_row_color(panel: PanelContainer, is_on: bool) -> void:
	var style := StyleBoxFlat.new()
	if is_on:
		style.bg_color = ROW_ON_BG
		style.border_color = ROW_ON_BORDER
	else:
		style.bg_color = ROW_OFF_BG
		style.border_color = ROW_OFF_BORDER
	style.set_border_width_all(1)
	style.set_corner_radius_all(2)
	style.content_margin_left = 3
	style.content_margin_right = 3
	style.content_margin_top = 1
	style.content_margin_bottom = 1
	panel.add_theme_stylebox_override("panel", style)


func _style_checkbox(cb: CheckBox) -> void:
	var empty := StyleBoxEmpty.new()
	cb.add_theme_stylebox_override("normal", empty)
	cb.add_theme_stylebox_override("pressed", empty)
	cb.add_theme_stylebox_override("hover", empty)
	cb.add_theme_stylebox_override("hover_pressed", empty)
	cb.add_theme_stylebox_override("focus", empty)
	cb.add_theme_color_override("font_color", Color(0.93, 0.93, 0.95))
	cb.add_theme_color_override("font_pressed_color", Color(0.93, 0.93, 0.95))
	cb.add_theme_color_override("font_hover_color", Color(1, 1, 1))
	cb.add_theme_color_override("font_hover_pressed_color", Color(1, 1, 1))
	cb.add_theme_color_override("font_focus_color", Color(0.93, 0.93, 0.95))
	cb.add_theme_font_size_override("font_size", 5)


func _style_slider(slider: HSlider) -> void:
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.15, 0.15, 0.18)
	bg.set_corner_radius_all(2)
	bg.content_margin_top = 1
	bg.content_margin_bottom = 1

	var fill := StyleBoxFlat.new()
	fill.bg_color = Color(1.0, 1.0, 1.0)
	fill.set_corner_radius_all(2)
	fill.content_margin_top = 1
	fill.content_margin_bottom = 1

	var grabber := StyleBoxFlat.new()
	grabber.bg_color = Color(1.0, 1.0, 1.0, 1.0)
	grabber.set_corner_radius_all(6)
	grabber.set_border_width_all(0)
	grabber.content_margin_left = 2
	grabber.content_margin_right = 2
	grabber.content_margin_top = 2
	grabber.content_margin_bottom = 2

	slider.add_theme_stylebox_override("slider", bg)
	slider.add_theme_stylebox_override("grabber_area", fill)
	slider.add_theme_stylebox_override("grabber_area_highlight", fill)
	slider.add_theme_stylebox_override("grabber", grabber)
	slider.add_theme_stylebox_override("grabber_highlight", grabber)
	slider.add_theme_stylebox_override("grabber_disabled", grabber)


func _style_option_button(opt: OptionButton) -> void:
	var normal_bg := StyleBoxFlat.new()
	normal_bg.bg_color = Color(0.12, 0.12, 0.16, 0.95)
	normal_bg.border_color = Color(0.25, 0.25, 0.30)
	normal_bg.set_border_width_all(1)
	normal_bg.set_corner_radius_all(2)
	normal_bg.content_margin_left = 2
	normal_bg.content_margin_right = 2
	normal_bg.content_margin_top = 1
	normal_bg.content_margin_bottom = 1

	var hover_bg := StyleBoxFlat.new()
	hover_bg.bg_color = Color(0.18, 0.18, 0.22, 0.95)
	hover_bg.border_color = Color(0.35, 0.35, 0.40)
	hover_bg.set_border_width_all(1)
	hover_bg.set_corner_radius_all(2)
	hover_bg.content_margin_left = 2
	hover_bg.content_margin_right = 2
	hover_bg.content_margin_top = 1
	hover_bg.content_margin_bottom = 1

	var pressed_bg := StyleBoxFlat.new()
	pressed_bg.bg_color = Color(0.08, 0.25, 0.35, 0.95)
	pressed_bg.border_color = Color(0.15, 0.45, 0.60)
	pressed_bg.set_border_width_all(1)
	pressed_bg.set_corner_radius_all(2)
	pressed_bg.content_margin_left = 2
	pressed_bg.content_margin_right = 2
	pressed_bg.content_margin_top = 1
	pressed_bg.content_margin_bottom = 1

	opt.add_theme_stylebox_override("normal", normal_bg)
	opt.add_theme_stylebox_override("hover", hover_bg)
	opt.add_theme_stylebox_override("pressed", pressed_bg)
	opt.add_theme_stylebox_override("focus", normal_bg)
	opt.add_theme_stylebox_override("disabled", normal_bg)

	opt.add_theme_font_size_override("font_size", 5)
	opt.add_theme_color_override("font_color", Color(0.93, 0.93, 0.95))
	opt.add_theme_color_override("font_hover_color", Color(1, 1, 1))
	opt.add_theme_color_override("font_pressed_color", Color(0.93, 0.93, 0.95))
	opt.add_theme_color_override("font_focus_color", Color(0.93, 0.93, 0.95))
	opt.add_theme_color_override("font_disabled_color", Color(0.5, 0.5, 0.55))

	var popup := opt.get_popup()
	var popup_bg := StyleBoxFlat.new()
	popup_bg.bg_color = Color(0.10, 0.10, 0.14, 0.98)
	popup_bg.border_color = Color(0.25, 0.25, 0.30)
	popup_bg.set_border_width_all(1)
	popup_bg.set_corner_radius_all(2)
	popup_bg.content_margin_left = 1
	popup_bg.content_margin_right = 1
	popup_bg.content_margin_top = 1
	popup_bg.content_margin_bottom = 1
	popup.add_theme_stylebox_override("panel", popup_bg)

	var hover_item := StyleBoxFlat.new()
	hover_item.bg_color = Color(0.15, 0.35, 0.50, 0.95)
	hover_item.set_corner_radius_all(2)
	hover_item.content_margin_left = 2
	hover_item.content_margin_right = 2
	popup.add_theme_stylebox_override("hover", hover_item)

	popup.add_theme_font_size_override("font_size", 5)
	popup.add_theme_color_override("font_color", Color(0.93, 0.93, 0.95))
	popup.add_theme_color_override("font_hover_color", Color(1, 1, 1))
	popup.add_theme_color_override("font_accelerator_color", Color(0.6, 0.6, 0.7))


func _update_slider_label(l: Label, v, value_key: String) -> void:
	if v is float:
		l.text = "%.2f" % v
	else:
		l.text = str(v)


func _add_simple_checkbox(parent: VBoxContainer, key: String, label: String) -> void:
	var panel := _make_row_panel(get(key))
	parent.add_child(panel)

	var cb := CheckBox.new()
	cb.text = label
	cb.button_pressed = get(key)
	_style_checkbox(cb)
	panel.add_child(cb)

	_checkbox_refs[key] = {"cb": cb, "panel": panel}

	cb.toggled.connect(func(pressed: bool):
		set(key, pressed)
		_update_row_color(panel, pressed)
		if key == "god_mode":
			_apply_god_mode(pressed)
		if key == "uncapped_fps":
			_apply_fps_cap(pressed)
		print("[cheat] ", key, " -> ", pressed)
	)


func _add_toggle_with_slider(parent: VBoxContainer, toggle_key: String, toggle_label: String,
							 value_key: String, value_label: String,
							 min_v: float, max_v: float, step: float) -> void:
	var panel := _make_row_panel(get(toggle_key))
	parent.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 1)
	panel.add_child(vbox)

	var master_row := HBoxContainer.new()
	master_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(master_row)

	var cb := CheckBox.new()
	cb.text = toggle_label
	cb.button_pressed = get(toggle_key)
	_style_checkbox(cb)
	cb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	master_row.add_child(cb)

	var sub_icon := Label.new()
	sub_icon.text = "▼"
	sub_icon.add_theme_font_size_override("font_size", 5)
	sub_icon.add_theme_color_override("font_color", Color(0.6, 0.6, 0.7))
	sub_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	master_row.add_child(sub_icon)

	var slider_box := HBoxContainer.new()
	slider_box.add_theme_constant_override("separation", 2)
	slider_box.visible = false
	vbox.add_child(slider_box)
	_slider_containers[toggle_key] = slider_box

	var name_l := Label.new()
	name_l.text = value_label
	name_l.custom_minimum_size.x = 35
	name_l.add_theme_font_size_override("font_size", 5)
	name_l.add_theme_color_override("font_color", Color(0.78, 0.78, 0.82))
	slider_box.add_child(name_l)

	var slider := HSlider.new()
	slider.min_value = min_v
	slider.max_value = max_v
	slider.step = step
	slider.value = get(value_key)
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.custom_minimum_size.x = 26
	slider.custom_minimum_size.y = 9
	_style_slider(slider)
	slider_box.add_child(slider)

	var val_l := Label.new()
	val_l.custom_minimum_size.x = 19
	val_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	val_l.add_theme_font_size_override("font_size", 5)
	_update_slider_label(val_l, get(value_key), value_key)
	slider_box.add_child(val_l)
	_value_sliders[value_key] = {"slider": slider, "label": val_l}

	var right_pad := Control.new()
	right_pad.custom_minimum_size.x = 2
	slider_box.add_child(right_pad)

	_checkbox_refs[toggle_key] = {"cb": cb, "panel": panel}

	# 右键切换滑条显示
	cb.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
			var mb := event as InputEventMouseButton
			if mb.pressed:
				slider_box.visible = not slider_box.visible
				sub_icon.text = "▲" if slider_box.visible else "▼"
	)

	cb.toggled.connect(func(pressed: bool):
		set(toggle_key, pressed)
		_update_row_color(panel, pressed)
		print("[cheat] ", toggle_key, " -> ", pressed)
	)

	slider.value_changed.connect(func(v: float):
		if get(value_key) is int:
			set(value_key, int(round(v)))
		else:
			set(value_key, v)
		_update_slider_label(val_l, get(value_key), value_key)
	)


func _add_combat_group(parent: VBoxContainer) -> void:
	var panel := _make_row_panel(auto_combat)
	parent.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 1)
	panel.add_child(vbox)

	var master_row := HBoxContainer.new()
	master_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(master_row)

	var master_cb := CheckBox.new()
	master_cb.text = "自动战斗"
	master_cb.button_pressed = auto_combat
	master_cb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_style_checkbox(master_cb)
	master_row.add_child(master_cb)

	var sub_icon := Label.new()
	sub_icon.text = "▼"
	sub_icon.add_theme_font_size_override("font_size", 5)
	sub_icon.add_theme_color_override("font_color", Color(0.6, 0.6, 0.7))
	sub_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	master_row.add_child(sub_icon)

	var subs_margin := MarginContainer.new()
	subs_margin.add_theme_constant_override("margin_left", 9)
	subs_margin.visible = false
	vbox.add_child(subs_margin)

	var subs_box := VBoxContainer.new()
	subs_box.add_theme_constant_override("separation", 0)
	subs_margin.add_child(subs_box)

	_combat_panel = subs_box

	_checkbox_refs["auto_combat"] = {"cb": master_cb, "panel": panel}
	_slider_containers["auto_combat"] = subs_margin

	var sub_defs := [
		["player_detect", "玩家检测"],
		["auto_tp_crystal", "传送水晶"],
		["auto_attack", "自动攻击"],
		["full_map_pickup", "全图拾取"],
	]
	for def in sub_defs:
		var sub_key: String = def[0]
		var sub_label: String = def[1]
		var sub_cb := CheckBox.new()
		sub_cb.text = sub_label
		sub_cb.button_pressed = get(sub_key)
		_style_checkbox(sub_cb)
		subs_box.add_child(sub_cb)
		_checkbox_refs[sub_key] = {"cb": sub_cb, "panel": panel}
		var captured_key := sub_key
		sub_cb.toggled.connect(func(pressed: bool):
			set(captured_key, pressed)
			print("[cheat] ", captured_key, " -> ", pressed)
		)

	# 吸怪模式下拉框
	var mode_row := HBoxContainer.new()
	mode_row.add_theme_constant_override("separation", 2)
	subs_box.add_child(mode_row)

	var mode_l := Label.new()
	mode_l.text = "吸怪模式"
	mode_l.custom_minimum_size.x = 35
	mode_l.add_theme_font_size_override("font_size", 5)
	mode_l.add_theme_color_override("font_color", Color(0.78, 0.78, 0.82))
	mode_row.add_child(mode_l)

	var mode_opt := OptionButton.new()
	mode_opt.add_item("无", 0)
	mode_opt.add_item("传送怪", 1)
	mode_opt.add_item("全图吸怪", 2)
	mode_opt.select(vacuum_mode)
	mode_opt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mode_opt.custom_minimum_size.x = 26
	mode_opt.custom_minimum_size.y = 10
	_style_option_button(mode_opt)
	mode_row.add_child(mode_opt)

	# 吸怪数量滑条（仅全图吸怪模式显示）
	var count_row := HBoxContainer.new()
	count_row.add_theme_constant_override("separation", 2)
	count_row.visible = (vacuum_mode == 2)
	subs_box.add_child(count_row)

	var count_l := Label.new()
	count_l.text = "数量"
	count_l.custom_minimum_size.x = 35
	count_l.add_theme_font_size_override("font_size", 5)
	count_l.add_theme_color_override("font_color", Color(0.78, 0.78, 0.82))
	count_row.add_child(count_l)

	var count_slider := HSlider.new()
	count_slider.min_value = 1
	count_slider.max_value = 99
	count_slider.step = 1
	count_slider.value = vacuum_count
	count_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	count_slider.custom_minimum_size.x = 26
	count_slider.custom_minimum_size.y = 9
	_style_slider(count_slider)
	count_row.add_child(count_slider)

	var count_val_l := Label.new()
	count_val_l.custom_minimum_size.x = 19
	count_val_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	count_val_l.add_theme_font_size_override("font_size", 5)
	count_val_l.text = str(vacuum_count)
	count_row.add_child(count_val_l)

	var count_pad := Control.new()
	count_pad.custom_minimum_size.x = 2
	count_row.add_child(count_pad)

	count_slider.value_changed.connect(func(v: float):
		vacuum_count = int(round(v))
		count_val_l.text = str(vacuum_count)
		print("[cheat] vacuum_count -> ", vacuum_count)
	)

	mode_opt.item_selected.connect(func(idx: int):
		vacuum_mode = idx
		count_row.visible = (idx == 2)
		print("[cheat] vacuum_mode -> ", idx)
	)

	# 右键切换子项显示
	master_cb.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
			var mb := event as InputEventMouseButton
			if mb.pressed:
				subs_margin.visible = not subs_margin.visible
				sub_icon.text = "▲" if subs_margin.visible else "▼"
	)

	master_cb.toggled.connect(func(pressed: bool):
		set("auto_combat", pressed)
		_update_row_color(panel, pressed)
		print("[cheat] auto_combat -> ", pressed)
	)


# ----- 菜单状态刷新 ----------------------------------------------------

func _refresh_all_labels() -> void:
	pass


func _apply_god_mode(on: bool) -> void:
	pass


func _apply_fps_cap(on: bool) -> void:
	Engine.max_fps = 0 if on else _fps_original


# ----- 面板拖拽 ---------------------------------------------------

func _apply_cheat_panel_rect() -> void:
	if _cheat_panel == null or not is_instance_valid(_cheat_panel):
		return
	var r := _clamp_rect_to_view(_ui_cheat_rect, CHEAT_MIN_SIZE)
	_ui_cheat_rect = r
	_cheat_panel.custom_minimum_size = CHEAT_MIN_SIZE
	_cheat_panel.size = r.size
	_cheat_panel.position = r.position


func _clamp_rect_to_view(r: Rect2, min_size: Vector2) -> Rect2:
	var vp := get_viewport().get_visible_rect().size
	var out := r
	out.size.x = maxf(out.size.x, min_size.x)
	out.size.y = maxf(out.size.y, min_size.y)
	# 位置为 0 时自动居中
	if out.position == Vector2.ZERO:
		out.position = Vector2((vp.x - out.size.x) / 2, (vp.y - out.size.y) / 2)
	out.position.x = clampf(out.position.x, -out.size.x + 26, vp.x - 26)
	out.position.y = clampf(out.position.y, 0, vp.y - 26)
	return out


func _on_menu_root_gui(event: InputEvent) -> void:
	_menu_root.accept_event()


func _on_cheat_title_gui(event: InputEvent) -> void:
	if _cheat_panel == null:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var mb: InputEventMouseButton = event as InputEventMouseButton
		_dragging = mb.pressed
		if _dragging:
			_drag_offset = mb.global_position - _cheat_panel.global_position
	elif event is InputEventMouseMotion and _dragging:
		var mm: InputEventMouseMotion = event as InputEventMouseMotion
		_cheat_panel.global_position = mm.global_position - _drag_offset
		_ui_cheat_rect.position = _cheat_panel.position
	else:
		_cheat_panel.position = _ui_cheat_rect.position
	_menu_root.accept_event()


# ----- 传送辅助 -----------------------------------------------------

func _get_enemies() -> Array:
	var out : Array = []
	if get_tree() == null:
		return out
	for n in get_tree().get_nodes_in_group("Enemies"):
		if n is Enemy and is_instance_valid(n):
			out.append(n)
	return out


func _random_side_offset() -> Vector2:
	const SIDE_DIST : float = 20.0
	if randi() % 2 == 0:
		return Vector2(SIDE_DIST if randi() % 2 == 0 else -SIDE_DIST, 0.0)
	else:
		return Vector2(0.0, SIDE_DIST if randi() % 2 == 0 else -SIDE_DIST)


func _auto_combat_tick(player) -> void:
	var target : Node2D = null
	if auto_tp_crystal:
		if _is_minigame_visible():
			target = _nearest_light_crystal(player)
			if target != null:
				player.global_position = target.global_position
			return
		target = _nearest_darkness_crystal(player)
		if target != null:
			player.global_position = target.global_position
			if target.has_method("use_object"):
				target.use_object()
			return
		target = _nearest_light_crystal(player)
		if target != null:
			player.global_position = target.global_position
			return
	if vacuum_mode == 1:
		target = _nearest_boss(player)
		if target != null:
			player.global_position = target.global_position + _random_side_offset()
			if player.has_method("k1Dqydf"):
				player.k1Dqydf()
			return
	if vacuum_mode == 1:
		target = _nearest_mob(player)
		if target == null:
			return
		player.global_position = target.global_position + _random_side_offset()
		var face : int = 1 if (target.global_position.x >= player.global_position.x) else -1
		if player.has_method("antYexL"):
			player.antYexL(face)
		elif "animated_sprite_2d" in player and player.animated_sprite_2d != null:
			player.animated_sprite_2d.scale.x = absf(player.animated_sprite_2d.scale.x) * face


func _nearest_darkness_crystal(player) -> Node2D:
	var best : Node2D = null
	var best_d : float = INF
	if get_tree() == null:
		return best
	var client = get_node_or_null("/root/Client")
	var self_name : String = ""
	if client != null and "smhz4kI" in client:
		self_name = str(client.smhz4kI).strip_edges()
	for obj in get_tree().get_nodes_in_group("interactable_object"):
		if not is_instance_valid(obj):
			continue
		if not "object_type" in obj or int(obj.object_type) != 154:  # TutorialGuide.PHEkOkw 黑暗水晶
			continue
		var owner_str : String = ""
		if "owner_name" in obj:
			owner_str = str(obj.owner_name).strip_edges()
		if owner_str != "" and self_name != "" and owner_str != self_name:
			continue
		var d : float = obj.global_position.distance_squared_to(player.global_position)
		if d < best_d:
			best_d = d
			best = obj
	return best


func _nearest_light_crystal(player) -> Node2D:
	var best : Node2D = null
	var best_d : float = INF
	if get_tree() == null:
		return best
	for n in get_tree().get_nodes_in_group("interactable_object"):
		if not is_instance_valid(n):
			continue
		if not n is MapObject:
			continue
		if "object_type" in n and n.object_type != 262:  # Utils.VHuWfUB 光之水晶
			continue
		if "available" in n and not n.available:
			continue
		var d : float = n.global_position.distance_squared_to(player.global_position)
		if d < best_d:
			best_d = d
			best = n
	return best


func _is_minigame_visible() -> bool:
	if get_tree() == null:
		return false
	return _check_minigame_visible(get_tree().root)


func _check_minigame_visible(node: Node) -> bool:
	if node == null:
		return false
	if node is Control and node.visible and "keys" in node and "pos" in node:
		return true
	for c in node.get_children():
		if _check_minigame_visible(c):
			return true
	return false


func _nearest_boss(player) -> Node2D:
	const BOSS_HP_RATIO := 4.0
	var enemies := _get_enemies()
	if enemies.is_empty():
		return null
	var groups := {}
	for e in enemies:
		if "is_boss" in e and e.is_boss:
			var d: float = e.global_position.distance_squared_to(player.global_position)
			var best = e
			_debug_boss(best)
			return best
		if "monster_id" in e and "max_hp" in e:
			var mid = e.monster_id
			if not groups.has(mid):
				groups[mid] = []
			groups[mid].append(e)
	var best : Node2D = null
	var best_d : float = INF
	for mid in groups:
		var group = groups[mid]
		if group.size() < 2:
			continue
		group.sort_custom(func(a, b): return a.max_hp > b.max_hp)
		if group[0].max_hp > group[1].max_hp * BOSS_HP_RATIO:
			var d: float = group[0].global_position.distance_squared_to(player.global_position)
			if d < best_d:
				best_d = d
				best = group[0]
	if best != null:
		_debug_boss(best)
	return best


func _nearest_item_drop(player) -> Node2D:
	if get_tree() == null:
		return null
	var best : Node2D = null
	var best_d : float = combat_range * combat_range
	for d in get_tree().get_nodes_in_group("item_drops"):
		if not is_instance_valid(d):
			continue
		if not d is ItemDrop:
			continue
		if "KX4rXIK" in d and d.KX4rXIK:
			continue
		if "xjFf7F8" in d and d.xjFf7F8:
			continue
		if "picked_up_by_character" in d and d.picked_up_by_character != null:
			continue
		var dd : float = d.global_position.distance_squared_to(player.global_position)
		if dd < best_d:
			best_d = dd
			best = d
	return best


func _debug_boss(e) -> void:
	var mid : int = e.monster_id if ("monster_id" in e) else -1
	if mid == _last_boss_id:
		return
	_last_boss_id = mid
	var name : String = "?"
	var db = get_node_or_null("/root/MonsterCombatDB")
	if db != null and db.has_method("lFr7CWp"):
		name = str(db.lFr7CWp(mid).get("name", "?"))
	var hp : float = e.max_hp if ("max_hp" in e) else 0.0
	print("[cheat] boss 目标 monster_id=", mid, " name=", name, " max_hp=", hp)


func _nearest_mob(player) -> Node2D:
	var best : Node2D = null
	var best_d : float = combat_range * combat_range
	for e in _get_enemies():
		var d : float = e.global_position.distance_squared_to(player.global_position)
		if d < best_d:
			best_d = d
			best = e
	return best


func _full_map_pickup(player) -> void:
	if get_tree() == null:
		return
	if _nearest_light_crystal(player) != null:
		return
	var best : Node2D = null
	var best_d : float = INF
	for d in get_tree().get_nodes_in_group("item_drops"):
		if not is_instance_valid(d):
			continue
		if not d is ItemDrop:
			continue
		if "KX4rXIK" in d and d.KX4rXIK:
			continue
		if "xjFf7F8" in d and d.xjFf7F8:
			continue
		if "picked_up_by_character" in d and d.picked_up_by_character != null:
			continue
		var dd : float = d.global_position.distance_squared_to(player.global_position)
		if dd < best_d:
			best_d = dd
			best = d
	if best == null:
		return
	# 物品位置在服务端，所以移动玩家到物品旁并同步位置，服务端才会接受拾取
	player.global_position = best.global_position + Vector2(12.0, 0.0)
	if player.has_method("k1Dqydf"):
		player.k1Dqydf()
	if "wXQVu6D" in player and player.wXQVu6D != null and best.pickupable:
		best._on_hurtbox_hurt(player.wXQVu6D)