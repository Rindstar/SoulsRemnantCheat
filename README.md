因为大小号都被封了，所以退游公布出来。

### 用法：替换游戏目录（SteamLibrary\steamapps\common\Soul's Remnant）的pck即可
#### 防止游戏后续更新失效，可参考教程自行更新：https://www.youtube.com/watch?v=5ntZ0Ct31bI

## 战斗

- **自动战斗** [`auto_combat`]
  - **玩家检测** [`player_detect`] — 检测到非队伍玩家时自动关闭自动战斗
  - **传送水晶** [`auto_tp_crystal`] — 自动传送到光之水晶 / 黑暗水晶
  - **自动攻击** [`auto_attack`] — 自动使用左键
  - **全图拾取** [`full_map_pickup`] — 玩家传送到最近掉落物旁并拾取
  - **吸怪模式** [`vacuum_mode`]
    - `0` — 无
    - `1` — 传送怪：将玩家传送到最近 BOSS/怪物身边
    - `2` — 全图吸怪：将范围内怪物拉到玩家面前
      - **数量** [`vacuum_count`] — 滑块 (1~99)，最多吸怪数

## 视觉

- **敌人血条常显** [`hp_bars_on`] — 强制显示所有敌人血条，禁用血条淡出
- **去除黑暗** [`no_darkness`] — 禁用黑暗光照节点，昼夜循环设为白昼
- **世界时间** [`eternal_night`]
  - **时间** [`eternal_night_time`]
- **解锁帧率** [`uncapped_fps`] — 移除帧率上限
- **隐藏天气** [`hide_weather`]
- **禁用后处理** [`postfx_off`]

## 玩家

- **拾取无CD** [`no_pickup_cd`]
- **范围拾取** [`pickup_range_on`] — 增大拾取范围
- **无敌模式** [`god_mode`] 

## 远程

- **拍卖行** — 远程打开拍卖行

## 快捷键

| 操作 | 说明 |
|------|------|
| `INSERT` / `L` | 打开/关闭作弊菜单 |
| 拖拽标题栏 | 移动窗口位置 |
| **右键** 点击复选框标签 | 展开/收起子选项（自动战斗、世界时间） |
