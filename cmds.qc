#include "defs.qh"

#ifdef NO_USER_CMDS

void() AddCommands = { };
void(entity client) AddCommandAliases = { };

#else

integer commands_added;

void() Cmd_Weapon_f;

void() AddCommands = 
{
	if (!commands_added)
	{
		SV_AddUserCommand ("weapon", Cmd_Weapon_f, TRUE);
	}

	commands_added = TRUE;
	return;
};

void(entity client) AddCommandAliases =
{
	if (self.got_aliases_num == 4)
	{
		stuffcmd (client, "alias reload \"cmd weapon reload\"\n");
	}
};

void() Cmd_Weapon_f = 
{
	if (Cmd_Argc() < 2)
	{
		// do something here
	}
	else if (Cmd_Argv(1) == "reload")
	{
		TeamFortress_ReloadCurrentWeapon();
	}
};

#endif
