#include "script_component.hpp"
/*
 * Author: TheMagnetar
 * Generates road traffic between two points.
 *
 * Arguments:
 * 0: Path. Array of <MARKER, TRIGGER, LOCATION, ARRAY> (default: [[0, 0, 0], [0,0,0]])
 * 1: Units to spawn. First array contains vehicle classames, second array
      contains driver classnames <ARRAY> (default: [])
 * 2: Spawn interval in seconds. In case an array is given, the spawn interval will be random between [a,b] <NUMBER, ARRAY> (default: 20)
 * 3: Stop condition <CODE> (default: {false})
 *
 * Return Value:
 * None
 *
 * Example:
 * [["markerStart", "markerEnd"], [["C_Van_01_fuel_F"], ["C_man_1", "C_Man_casual_1_F"]], 40, {stopRoadTraffic}] call umfx_spawn_fnc_roadTraffic
 *
 * Public: Yes
 */

params [
    ["_path", [[], []], [[]]],
    ["_units", [[], []], ["", []], 2],
    ["_interval", 20, [0, []], 2],
    ["_stopCondition", {false}, [{}]]
];

{
    _path set [_forEachIndex, [_x] call CBA_fnc_getPos];
} forEach _path;

private _time = CBA_missionTime;
private _args = [_path, _units, _interval, _stopCondition, _time];

[{
    params ["_args", "_pfhId"];

    _args params ["_path", "_units", "_interval", "_stopCondition", "_time"];

    if ([] call _stopCondition) exitWith {
        [_pfhId] call CBA_fnc_removePerFrameHandler;
    };

    if (_time >= CBA_missionTime) then {
        private _grp = createGroup civilian;
        private _vehicle = (selectRandom (_units select 0)) createVehicle [0, 0, 0];
        private _driver = (selectRandom (_units select 1)) createUnit [[0, 0, 0], _grp];

        _driver assignAsDriver _vehicle;
        _driver moveInDriver _vehicle;
        _vehicle setPos (path select 0);

        _grp setBehaviour "CARELESS";
        _grp setSpeedMode "NORMAL";
        _grp setCombatMode "GREEN";
        _driver forceFollowRoad true;

        private _numPoints = count _path;
        for "_i" from 1 to (_numPoints - 1) do {
            private _wp = _grp addWaypoint [_i, 0];
            if (_i == (_numPoints - 1)) then {
                _wp setWaypointStatements ["true",QUOTE([ARR_1(vehicle this)] call QQEFUNC(core,deleteVehicle))];
            };
        };

        _time = CBA_missionTime + ([_interval] call EFUNC(core,getRandomMinMax));
        _args set [4, _time];
    };
}, 1, _args] call CBA_fnc_addPerFrameHandler;
