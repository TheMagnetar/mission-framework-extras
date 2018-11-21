#include "script_component.hpp"
/*
 * Author: TheMagnetar
 * Spawns pursuing groups in the given area
 *
 * Arguments:
 * 0: Target <OBJECT, GROUP> (default: objNull)
 * 1: Spawn area <MARKER, TRIGGER, LOCATION, ARRAY> (default: [])
 * 2: Units <STRING, ARRAY> (default: [])
 * 3: Number of groups to spawn. In case an array is given, the number of groups that will be spawned will be
 *    random between [a,b] <NUMBER, ARRAY> (default: 1)
 * 4: Side to spawn <SIDE> (default: east)
 * 5: Radius around the pursued where the pursuer will move at. The smaller, the more precise the pursuer will hunt.
 *    In case an array is given, the radius will be random between [a,b] <NUMBER, ARRAY> (default: 240)
 * 6: Timeout used by the pursuer to move to a new position. In case an array is given, the radius will be random
 *    between [a,b] <NUMBER, ARRAY> (default: 30)
 * 7: Spawn delay in seconds <NUMBER> (default: 1)
 *
 * Return Value:
 * None
 *
 * Example:
 * - Spawn one group at a random position in the marker "marker"
 *   [player, "marker", ["CUP_O_TK_INS_Soldier_GL","CUP_O_TK_INS_Soldier_GL"]] call umfx_spawn_fnc_pursuingGroups;
 * - Spawn between 1 and four groups at a random position in the marker "marker", the radius will be random between 5 and 15 meters
 *   [player, "marker", ["CUP_O_TK_INS_Soldier_GL","CUP_O_TK_INS_Soldier_GL"], [1, 4], east, [5, 15], 30] call umfx_spawn_fnc_pursuingGroups;
 * - Spawn one group at the defined area
 *   [player, [center, a, b, angle, isRectangle], ["CUP_O_TK_INS_Soldier_GL","CUP_O_TK_INS_Soldier_GL"]] call umfx_spawn_fnc_pursuingGroups;
 *
 * Public: Yes
 */

if (!isServer) exitWith {};


params [
    ["_target", objNull, [objNull, grpNull]],
    ["_position", [], ["",objNull,locationNull,[]], 5],
    ["_units", [], [[], ""]],
    ["_numGroups", 1, [0, []], [2]],
    ["_side", east, [sideUnknown]],
    ["_radius", 240, [0, []]],
    ["_timeout", 30, [0, []]],
    ["_spawnDelay", 1, [0]]
];

if (isNull _target) exitWith {
    ERROR("Null target specified");
};

private _acceptedSides = [west, east, resistance, civilian, sideUnknown];
if !(_side in _acceptedSides) exitWith {
    ERROR_2("Invalid side specified %1. Accepted sides %2",_side,_acceptedSides);
};

if (_numGroups isEqualType []) then {
    _numGroups = [_numGroups] call EFUNC(core,getRandomMinMax);
};

if (_units isEqualType "") then {
    _units = [_units];
};

[{
    params ["_handleArray", "_handleId"];
    _handleArray params ["_target", "_position", "_units", "_radius", "_timeout", "_numGroups", "_side"];

    if (_radius isEqualType []) then {
        _radius = [_radius] call EFUNC(core,getRandomMinMax);
    };

    if (_timeout isEqualType []) then {
        _timeout = [_timeout] call EFUNC(core,getRandomMinMax);
    };

    private _group = [[_position] call CBA_fnc_randPosArea, _side, _units] call BIS_fnc_spawnGroup;
    [_group, _target, _radius, _timeout] call EFUNC(ai,pursue);

    _numGroups = _numGroups - 1;
    if (_numGroups == 0) then {
        [_handleId] call CBA_fnc_removePerFrameHandler;
    } else {
        _handleArray set [5, _numGroups];
    };
}, _spawnDelay, [_target, _position, _units, _radius, _timeout, _numGroups, _side]] call CBA_fnc_addPerFrameHandler;
