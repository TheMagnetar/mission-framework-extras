---
title: Public functions
---

## List of functions
- ACE3: Assign wound
- Artillery Fire
- Pursue
- Spawn pursuing groups

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

### Artillery Fire

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
- ["Sh_155mm_AMOS", player, 100, 35, 4, 0.5, west, "explosive"] call umfx_support_fnc_artilleryFire
- [["Sh_155mm_AMOS", "Sh_120mm_HE"], player, 100, 35, 4, 0.5, [west, civillian], "explosive"] call umfx_support_fnc_artilleryFire

### Pursue

**Description**: Makes a group hunt another one.

**Arguments:**
- 0: Pursuer <OBJECT><GROUP>
- 1: Pursued <OBJECT><GROUP>
- 2: Radius around the pursued where the pursuer will move at. The smaller, the more precise the pursuer will hunt <NUMBER> (default: 240)
- 3: Timeout used by the pursuer to move to a new position <NUMBER> (default: 30)

**Return Value:** None

**Examples:**
- [cursorTarget, player, 45, 20] call umfx_ai_fnc_pursue

### Spawn pursuing roups

**Description**: Spawns pursuing groups in the given area.

**Arguments:**
- 0: Target <OBJECT, GROUP> (default: objNull)
- 1: Spawn area <MARKER, TRIGGER, LOCATION, ARRAY> (default: [])
- 2: Units <STRING, ARRAY> (default: [])
- 3: Number of groups to spawn. In case an array is given, the number of groups that will be spawned will be
     random between [a,b] <NUMBER, ARRAY> (default: 1)
- 4: Side to spawn <SIDE> (default: east)
- 5: Radius around the pursued where the pursuer will move at. The smaller, the more precise the pursuer will hunt.
    In case an array is given, the radius will be random between [a,b] <NUMBER, ARRAY> (default: 240)
- 6: Timeout used by the pursuer to move to a new position. In case an array is given, the radius will be random
     between [a,b] <NUMBER, ARRAY> (default: 30)
- 7: Spawn delay in seconds <NUMBER> (default: 1)

**Return Value:** None

**Examples:**
- Spawn one group at a random position in the marker "marker"
  `[player, "marker", ["CUP_O_TK_INS_Soldier_GL","CUP_O_TK_INS_Soldier_GL"]] call umfx_ai_fnc_pursuingGroups;`
- Spawn between 1 and four groups at a random position in the marker "marker", the radius will be random between 5 and 15 meters
  `[player, "marker", ["CUP_O_TK_INS_Soldier_GL","CUP_O_TK_INS_Soldier_GL"], [1, 4], east, [5, 15], 30] call umfx_spawn_fnc_pursuingGroups;`
- Spawn one group at the defined area
  `[player, [center, a, b, angle, isRectangle], ["CUP_O_TK_INS_Soldier_GL","CUP_O_TK_INS_Soldier_GL"]] call umfx_ai_fnc_pursuingGroups;`


### Move to random position

**Description**: Make the position of a unit to be randomly selected from an array of points

**Arguments:**
- 0: Unit <OBJECT> (default: objNull)
- 1: Random locations. Accepted values are arrays, tasks, locations, objects or markers <ARRAY> (default: [])

**Return Value:** None

**Example:**
[this, [p1, p2, p3, p4]] call umfx_spawn_fnc_unitRandomPos

### Road traffic

**Description**:Generates road traffic between two points.

**Arguments:**
- 0: Path. Array of <MARKER, TRIGGER, LOCATION, ARRAY> (default: [[0, 0, 0], [0,0,0]])
- 1: Units to spawn. First array contains vehicle classames, second array
     contains driver classnames <ARRAY> (default: [])
- 2: Spawn interval in seconds. In case an array is given, the spawn interval will be random between [a,b] <NUMBER, ARRAY> (default: 20)
- 3: Stop condition <CODE> (default: {false})

**Return Value:** None

**Example:**
[["markerStart", "markerEnd"], [["C_Van_01_fuel_F"], ["C_man_1", "C_Man_casual_1_F"]], 40, {stopRoadTraffic}] call umfx_spawn_fnc_roadTraffic

### Suicider

**Description:** Makes a suicide unit.

** Arguments:**
- 0: Suicider <OBJECT> (default: objNull)
- 1: Target side <SIDE> (default: west)
- 2: Target acquisition distance <NUMBER> (default: 100)
- 3: Minimum attack distance <NUMBER> (default: 10)
- 4: Explosive type <STRING> (default: "IEDLandSmall_Remote_Ammo")
- 5: Dead man switch (default: false)
- 6: Sound defined in CfgSounds <STRING> (default: "allahu")

**Return Value:** None

**Example:**
[cursorTarget, west, 100, 10, "IEDLandSmall_Remote_Ammo", true] call umfx_ai_fnc_suicider
