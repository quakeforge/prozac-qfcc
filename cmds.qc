#include "defs.qh"
#include "menu.qh"

#ifdef NO_USER_CMDS

void() AddCommands = { };
void(entity client) AddCommandAliases = { };

#else

integer commands_added;

void() Cmd_Weapon_f;
void() Cmd_Build_f;
void() Cmd_Detonate_f;

void() AddCommands = 
{
	if (!commands_added)
	{
		SV_AddUserCommand ("weapon", Cmd_Weapon_f, TRUE);
		SV_AddUserCommand ("build", Cmd_Build_f, TRUE);
		SV_AddUserCommand ("detonate", Cmd_Detonate_f, TRUE);
	}

	commands_added = TRUE;
	return;
};

void(entity client) AddCommandAliases =
{
	switch (client.got_aliases_num)
	{
		case 4:
			stuffcmd (client, "alias reload \"cmd weapon reload\"\n");
			stuffcmd (client, "alias detpipe \"cmd detonate pipes\"\n");
			break;
		case 6:
			stuffcmd (client, "alias build \"cmd build menu\"\n");
			stuffcmd (client, "alias detdispenser \"cmd detonate dispenser\"\n");
			break;
	}

};

void() Cmd_Build_f =
{
	if (Cmd_Argc () < 2 || Cmd_Argv (1) == "menu")
	{
		self.current_menu = MENU_ENGINEER;
		self.menu_count = MENU_REFRESH_RATE;

		return;
	}

	local float what_to_build = 0;

	switch (Cmd_Argv (1))
	{
		case "sensor":
			SBBuildSensor ();
			break;

		case "dispenser":
			what_to_build = BUILD_DISPENSER;
			break;

		case "sentrygun":
			what_to_build = BUILD_SENTRYGUN;
			break;

		case "tesla":
			what_to_build = BUILD_TESLA;
			break;

		case "fieldgen":
			what_to_build = BUILD_FIELDGEN;
			break;

		case "teleporter":
			what_to_build = BUILD_TELEPORTER;
			break;

		case "camera":
			what_to_build = BUILD_SECURITY_CAMERA;
			break;

	}

	if (what_to_build)
	{
		TeamFortress_Build (what_to_build);
	}

	return;
};

void() Cmd_Detonate_f =
{
	if (Cmd_Argc () < 2)
		return;

	switch (Cmd_Argv (1))
	{
		case "pipes":
			TeamFortress_DetonatePipebombs ();
			break;

		case "dispenser":
			Find_And_Dmg ("building_dispenser", self, 1);
			break;

		case "sentrygun":
			Find_And_Dmg ("building_sentrygun", self, 1);
			break;

		case "tesla":
			Find_And_Dmg ("building_tesla", self, 1);
			break;

		case "fieldgen":
			Find_And_Dmg ("building_fieldgen", self, 1);
			break;

		case "sensor":
			Find_And_Dmg ("building_sensor", self, 1);
			break;

		case "camera":
			Find_And_Dmg ("building_camera", self, 1);
			break;

		case "teleporter":
			Find_And_Dmg ("building_teleporter", self, 1);
			break;
	}

};	

void() Cmd_Weapon_f = 
{
	if (Cmd_Argc () < 2)
	{
		// do something here
	}
	else if (Cmd_Argv (1) == "reload")
	{
		TeamFortress_ReloadCurrentWeapon ();
	}
};

#endif
