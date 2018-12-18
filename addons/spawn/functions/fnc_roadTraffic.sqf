#include "script_component.hpp"
/*
 * Author: TheMagnetar
 * Generates road traffic between two points.
 *
 * Arguments:
 * 0: Start position <MARKER, TRIGGER, LOCATION, ARRAY> (default: [0, 0, 0])
 * 1: End position <MARKER, TRIGGER, LOCATION, ARRAY> (default: [0, 0, 0])
 * 2: Units to spawn. First array contains vehicle classames, second array
      contains driver classnames <ARRAY> (default: [])
 * 3: Spawn interval in seconds. In case an array is given, the spawn interval will be random between [a,b] <NUMBER, ARRAY> (default: 20)
 * 4: Stop condition <BOOL, CODE> (default: false)
 *
 * Return Value:
 * None
 *
 * Example:
 * - ["markerStart", "markerEnd", [["car_1"], ["driver1", "driver2"]], 40, {stopRoadTraffic}] call umfx_spawn_fnc_roadTraffic
 *
 * Public: Yes
 */



params [
    ["_startPos", [0, 0, 0], ["", objNull, locationNull, []], [2, 3]],
    ["_endPos", [0, 0, 0], ["", objNull, locationNull, []], [2, 3]],
    ["_units", [[], []], ["", []], 2],
    ["_interval", 20, [0, []], 2],
    ["_stopCondition", false, [false, {}]]
];

_startPos = [_startPos] call CBA_fnc_getPos;
_endPos = [_endPos] call CBA_fnc_getPos;
private _time = CBA_missionTime;
private _args = [_startPos, _endPos, _units, _interval, _stopCondition, _time];


[{
    params ["_args", "_pfhId"];

    _args params ["_startPos", "_endPos", "_units", "_interval", "_stopCondition", "_time"];

    if (_stopCondition) exitWith {
        [_pfhId] call CBA_fnc_removePerFrameHandler;
    };

    if (_time > CBA_missionTime) then {
        private _grp = createGroup civilian;
        private _vehicle = (selectRandom (_units select 0)) createVehicle [0, 0, 0];
        private _driver = (selectRandom (_units select 1)) createUnit [[0, 0, 0], _grp];
        _driver assignAsDriver _vehicle;
        _driver moveInDriver _vehicle;
        _vehicle setPos _startPos;

        _grp setBehaviour "CARELESS";
        _grp setSpeedMode "NORMAL";
        _grp setCombatMode "GREEN";
        _driver forceFollowRoad true;

        private _wp = _grp addWaypoint [_endPos, 0];
        _wp setWaypointStatements ["true",QUOTE([ARR_1(vehicle this)] call QQEFUNC(core,deleteVehicle))];

        _time = CBA_missionTime + [_interval] call EFUNC(core,getRandomMinMax);
        _args set [5, _time];
    };
}, 1, _args] call CBA_fnc_addPerFrameHandler;
