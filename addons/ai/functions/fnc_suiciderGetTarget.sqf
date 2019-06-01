#include "script_component.hpp"
/*
 * Author: TheMagnetar
 * Target aquisition for suicider script.
 *
 * Arguments:
 * 0: Suicider <OBJECT>
 * 1: Target side <SIDE>
 * 2: Target acquisition distance <NUMBER>
 *
 * Return Value:
 * Target <OBJECT>
 *
 * Example:
 * [cursorTarget, player, 45] call mfx_ai_fnc_suiciderGetTarget
 *
 * Public: No
 */

params ["_suicider", "_side", "_targetDist"];

private _potentialTargets = (_suicider nearTargets _targetDist) select {isPlayer (_x select 4) && {(_x select 2) isEqualTo _side}};

private _targets = [];
{
    private _playerUnit = (_x select 4);
    if ((_suicider knowsAbout _playerUnit) > 1) then {
        // Evaluate potential damage
        private _estimatedDamage = 0;
        private _damagedTargets = _potentialTargets select {(_x select 4) inArea [getPosATL _suicider, 15, 15, 0, false]};
        {
            _estimatedDamage = _estimatedDamage + (_x select 3);
        } forEach _damagedTargets;

        _targets pushBack [_estimatedDamage, _playerUnit];
    }
} forEach _potentialTargets;

_targets sort false;

if (_targets isEqualTo []) then {
    objNull
} else {
    (_targets select 0) select 1
};
