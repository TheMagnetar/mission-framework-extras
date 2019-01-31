#include "script_component.hpp"

[QGVAR(suicider), {
    params ["_unit", "_sound"];

    _unit say [_sound, 5];
}] call CBA_fnc_addEventHandler;

[QGVAR(onRevealUnit), DFUNC(onRevealUnit)] call CBA_fnc_addEventHandler;
[QGVAR(pursueChangeLocality), DFUNC(pursue)] call CBA_fnc_addEventHandler;
[QGVAR(suiciderChangeLocality), DFUNC(suicider)] call CBA_fnc_addEventHandler;
