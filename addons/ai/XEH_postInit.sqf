#include "script_component.hpp"

[GVAR(suicider), {
    params ["_unit", "_sound"];

    _unit say [_sound, 5];
}] call CBA_fnc_addEventHandler;

[QGVAR(onRevealUnit), DFUNC(onRevealUnit)] call CBA_fnc_addEventHandler;
