---
title: Public functions
---

## List of functions
- ACE3: Assign wound
- Artillery Fire

### ACE3: Assign wound

**Description:** Assigns a wound manually to a unit

**Arguments:**
- 0: Unit <OBJECT> (default: objNull)
- 1: Body part <STRING> (default: "")
- 2: Damage <NUMBER> (default: 0)
- 3: Injury type <STRING> (default: "bullet")
     Allowed entries: "head", "body", "hand_l", "hand_r", "leg_l" and "leg_r"

**Return Value:** None

**Example:**
- [player, "leg_r", 0.8, "bullet"] call umfx_ace_fnc_assignWound;

### Artillery Fire*

**Description:** Funtions that simulates artillery fire in a zone. This script can be used in order to avoid hitting units of a specific
side if a wide enough danger zone area is given. With Danger Area radius parameter set to 0, all units will be hit, independently
of the unit's side.

**Arguments:**
- 0: Ammo class name. If an array is given, each strike will select the ammo randomly <STRING><ARRAY> (default: "")
- 1: Position <ARRAY><OBJECT><LOCATION><GROUP> (default: [])
- 2: Radius in meters <NUMBER> (default: 50)
- 3: Danger Area (area that will be avoided around a unit that complies with parameter 6) <NUMBER> (default: 0)
- 4: Number of rounds <NUMBER> (default: 3)
- 5: Average delay between rounds in seconds <NUMBER> (default: 0.1)
- 6: Side that will be avoided by the artillery rounds (rounds will be avoided in the danger area) <SIDE><ARRAY> (default west)
- 7: Ammo Type. It can be "explosive", "flare" or "smoke" <STRING> (default: "explosive")
- 8: Make a unit on the map fire the rounds <OBJECT> (default: ojectNull)

**Return Value:** None

**Examples:**
- ["8Rnd_82mm_Mo_shells", player, 100, 35, 4, 0.5, west, "explosive"] call umfx_support_fnc_artilleryFire
- [["8Rnd_82mm_Mo_shells", "Sh_120mm_HE"], player, 100, 35, 4, 0.5, [west, civillian], "explosive"] call umfx_support_fnc_artilleryFire
