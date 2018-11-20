#include "script_component.hpp"
/*
 * Author: TheMagnetar
 * Assigns a wond manually.
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
 * [cursorTarget, player , 45, 20] call umfx_ai_fnc_pursue
 * [cursorTarget, player , 45, 20] call umfx_ai_fnc_pursue
 *
 * Public: Yes
 */

params [
    ["_pursuer", objNull, [objNull, grpNull]],
    ["_pursued", objNull, [objNull, grpNull]],
    ["_radius", 240, [0]],
    ["_timeout", 30, [0]]
];

private _grpPursuer = grpnull;
private _grpPursued = grpnull;
if (_pursuer isEqualType grpNull)then{
    _grpPursuer = _pursuer;
} else {
    _grpPursuer = group _pursuer;
};

if(_pursued isEqualType grpNull)then{
    _grpPursued =  _pursued;
} else {
    _grpPursued = group _pursued;
};

private _time = CBA_missionTime;

[{
    params ["_handleArray", "_handleId"];
    _handleArray params ["_grpPursuer", "_grpPursued", "_radius", "_timeout", "_time"];

    private _leaderPursuer = leader _grpPursuer;
    private _leaderPursued = leader _grpPursued;

    if (units _grpPursuer isEqualTo [] || {units _grpPursued isEqualTo []}) exitWith {
        [_handleId] call CBA_fnc_removePerFrameHandler;
    };

    if (moveToCompleted _leaderPursuer || {moveToFailed _leaderPursuer} || {!alive _leaderPursuer} || {CBA_missionTime < _time}) exitWith {};

    private _dir = _leaderPursued getDir _leaderPursuer;
    private _pos= _leaderPursued getPos [_radius, _dir];

    if ((_leaderPursued distance _leaderPursuer) > _radius ) then {
        _leaderPursuer move _pos;
    };

    _time = CBA_missionTime + _timeout;
    _handleArray set [4, _time];

}, 1, [_grpPursuer, _grpPursued, _radius, _timeout, _time]] call CBA_fnc_addPerFrameHandler;
