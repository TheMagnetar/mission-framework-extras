#include "script_component.hpp"
/*
 * Author: TheMagnetar
 * Checks if a unit has a weapon ready and makes the nearby units of the specified side hostile.
 *
 * Arguments:
 * 0: Side to turn hostile <ARRAY><SIDE> (default: civilian)
 * 1: Radius <NUMBER> (default: 30)
 * 2: Stop condition <CODE> (default: {false})
 *
 * Return Value:
 * None
 *
 * Example:
 * [cursorTarget, player, 45, 20] call umfx_ai_fnc_checkWeaponReady
 *
 * Public: Yes
 */

params [
    ["_side", civilian, [civilian,  []]],
    ["_radius", 30, [0]],
    ["_stopCondition", {false}, [{}]]
];

if (!hasInterface) exitWith {};

if !(_side isEqualType []) then {
    _side = [_side];
};

[{
    params ["_handleArray", "_handleId"];
    _handleArray params ["_side", "_radius", "_stopCondition", "_enemySide", ["_enemyGroup", grpNull]];

    if ([] call _stopCondition) exitWith {[_handleId] call CBA_fnc_removePerFrameHandler;};
    if (weaponLowered player) exitWith {};

    private _nearUnits = ((getPosATL player) nearEntities ["CAManBase", _radius]) select {(side _x) in _side && {_x knowsAbout player > 0.6}};

    {
        private _inSector = [position _x, eyeDirection _x, 160, position player] call BIS_fnc_inAngleSector;

        if (_inSector && {[objNull, "VIEW"] checkVisibility [eyePos player, eyePos _x] > 0.4}) then {
            if (isNull _enemyGroup) then {
                _enemyGroup = createGroup _enemySide;
                _enemyGroup setBehaviour "COMBAT";
                _enemyGroup setCombatMode "RED";
            };

            [QGVAR(onRevealUnit), [player, _x], _x] call CBA_fnc_targetEventHandler;
            [_x] joinSilent _enemyGroup;
            _handleArray set [4, _enemyGroup];
        };
    } forEach _nearUnits;
}, 1, [_side, _radius, _stopCondition]] call CBA_fnc_addPerFrameHandler;
