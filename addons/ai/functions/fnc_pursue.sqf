#include "script_component.hpp"
/*
 * Author: TheMagnetar
 * Makes a group pursue another group.
 *
 * Arguments:
 * 0: Pursuer <OBJECT><GROUP>
 * 1: Pursued <OBJECT><GROUP>
 * 2: Radius around the pursued where the pursuer will move at. The smaller, the more precise the pursuer will hunt <NUMBER> (default: 240)
 * 3: Timeout used by the pursuer to move to a new position <NUMBER> (default: 30)
 *
 * Return Value:
 * None
 *
 * Example:
 * [cursorTarget, player, 45, 20] call umfx_ai_fnc_pursue
 *
 * Public: Yes
 */

params [
    ["_pursuer", objNull, [objNull, grpNull]],
    ["_target", objNull, [objNull, grpNull, "", locationNull, taskNull, [], 0]], // Same as CBA_fnc_getPos
    ["_radius", 240, [0]],
    ["_timeout", 30, [0]]
];

private _grpPursuer = grpnull;
if (_pursuer isEqualType grpNull)then{
    _grpPursuer = _pursuer;
} else {
    _grpPursuer = group _pursuer;
};

_grpPursuer setSpeedMode "FULL";
private _time = CBA_missionTime;

[{
    params ["_handleArray", "_handleId"];
    _handleArray params ["_grpPursuer", "_target", "_radius", "_timeout", "_time"];

    if (isNull _grpPursuer || {units _grpPursuer isEqualTo []}) exitWith {[_handleId] call CBA_fnc_removePerFrameHandler;};
    if (isNull _target || {_target isEqualTo ""} || {_target isEqualType grpNull && {units _target isEqualTo []}}) exitWith {[_handleId] call CBA_fnc_removePerFrameHandler;};

    private _leaderPursuer = leader _grpPursuer;
    if (moveToCompleted _leaderPursuer || {moveToFailed _leaderPursuer} || {!alive _leaderPursuer} || {CBA_missionTime < _time}) exitWith {};

    private _pos = [_target] call CBA_fnc_getPos;
    private _pos = [_pos, _radius] call CBA_fnc_getPos;

    if ((_pos distance _leaderPursuer) > _radius) then {
        _leaderPursuer move _pos;
    };

    _time = CBA_missionTime + _timeout;
    _handleArray set [4, _time];

}, 1, [_grpPursuer, _target, _radius, _timeout, _time]] call CBA_fnc_addPerFrameHandler;
