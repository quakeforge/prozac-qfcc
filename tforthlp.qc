#include "defs.qh"
#include "messages.qh"
#include "menu.qh"
/*======================================================
	TFORTHLP.QC			CustomTeamFortress v3.1	

	(c) TeamFortress Software Pty Ltd 	29/2/97
	(c) William Kerney			5/22/00
	parts (c) Craig Hauser
========================================================
Functions handling all the help displaying for TeamFortress. 
========================================================*/
// Prototypes
// Help Functions
void() TeamFortress_MOTD;
void() TeamFortress_HelpMap;
void() AliasTimer;

//ofN
void() bprintline;

//=========================================================================
// HELP FUNCTIONS
//=========================================================================
void() TeamFortress_MOTD =
{
	local string ya;
	local string st;
	local entity atimer;

	// check if player already has aliases
	if (self.motd == 4) {
		stuffcmd(self,"prozacalias\n");
		self.show_hostile = 0;
	}

	if (self.motd <= MOTD_FINISHED - 2)
	{
		if (self.show_hostile < time) {
			PrintMOTD ();
			self.show_hostile = time + MOTD_REFRESHRATE; //was 1 //.5? 
		}
		self.menu_count = MENU_REFRESH_RATE;
		self.current_menu = MENU_DEFAULT;

		self.motd = self.motd + 1;
		return;
	}

	if (self.motd == MOTD_FINISHED - 1)
	{
		//WK CHECK TO SEE IF WE ARE REDIRECTING PLAYERS
		st = infokey(world, "redir");
		if (st != string_null && st != "off") {
			stuffcmd(self,"connect ");
			stuffcmd(self,st);
			stuffcmd(self,"\n");
		}

		// Set Default autozoom
		if (DEFAULT_AUTOZOOM == OFF)
			self.tfstate = self.tfstate | TFSTATE_ZOOMOFF;

		// Set their color to white, so they stand out from teams
		if ((teamplay != 0) && (self.team_no == 0))
			SetPlayerColor (self, WHITE - 1, WHITE - 1);

/*		if (self.got_aliases == FALSE)
			sprint(self, PRINT_HIGH, "\n\n\n");*/

//CH prints customTF version.  Edit in messages.qc
        sprint (self, PRINT_HIGH, "\n");
        sprint (self, PRINT_HIGH,MSG_OFTEN_CUTFVERSION);

        sprint (self, PRINT_HIGH, "\nžžŸ ");        // was \n
        sprint (self, PRINT_HIGH, MSG_CUTFVERSION);
        sprint (self, PRINT_HIGH, " žžžŸ\n");       
		
        sprint (self, PRINT_HIGH, "       Éîæïòíáôéïî èïíåðáçå:\n");
		sprint (self, PRINT_HIGH, "     www®telefragged®com¯shaka");
        //sprint (self, PRINT_HIGH, "žžžžžžŸ Modified by ÏfteÎ žžžžžžžŸ\n\n");
        
        
        
        sprint (self, PRINT_HIGH, "\nžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžŸ\n\n");

		self.current_menu = MENU_INTRO;
		self.menu_count = MENU_REFRESH_RATE;
   
		self.motd = MOTD_FINISHED;

		//WK CustomTF Commands
		TeamFortress_Alias("custom", (TF_CHANGEPC + PC_CUSTOM), 0);
		TeamFortress_Alias("upgrade", (TF_SELL), 0);
		TeamFortress_Alias("skill", (TF_SKILL), 0);
		TeamFortress_Alias("throwdet", (THROW_DETPACK), 0); // SB new impulse aliases
		//TeamFortress_Alias("buildsensor", (BUILD_SENSOR), 0);
		//TeamFortress_Alias("interface", (IMPULSE_INTERFACE), 0);
        TeamFortress_Alias("holo", (IMPULSE_HOLO), 0);
        //TeamFortress_Alias("debug", (IMPULSE_DEBUG), 0); 193
		

		// check if player already has aliases
	   	if (self.got_aliases == TRUE)
			return;

		//WK If not, spawn off a timer to slowly send the aliases to
		//prevent overflow
		atimer = spawn ();
		atimer.classname = "timer";
		atimer.owner = self;
		atimer.nextthink = time + 0.5;
		atimer.heat = 0;
		atimer.think = AliasTimer;
	}
};

#ifndef MSG_INTRO1
# define MSG_INTRO1 ""
#endif
#ifndef MSG_INTRO2
# define MSG_INTRO2 ""
#endif
#ifndef MSG_INTRO3
# define MSG_INTRO3 ""
#endif

void() PrintMOTD =
{
	local string intro = "";
	local string infostring;

	if (MSG_INTRO1 != "")
		intro = intro + MSG_INTRO1;
	if (MSG_INTRO2 != "") {
		if (intro != "")
			intro = intro + MSG_INTROBAR;
		intro = intro + MSG_INTRO2;
	}
	if (MSG_INTRO3 != "") {
		if (intro != "")
			intro = intro + MSG_INTROBAR;
		intro = intro + MSG_INTRO3;
	}
	infostring = infokey (world, "motd");
	if (infostring != "") {
		if (intro != "")
			intro = intro + MSG_INTROBAR;
		intro = intro + infostring;
	}

	intro = "\n\n" + intro; // prepend a newline, to make it center better :/

	CenterPrint(self, intro);
};

//=========================================================================
// Help displayed when someone types the alias "maphelp"
void() TeamFortress_HelpMap =
{
	local entity te;

	te = find(world, classname, "info_tfdetect");
	if (te)
	{
		if (te.non_team_broadcast != string_null)
		{
			sprint (self, PRINT_HIGH, te.non_team_broadcast);
			return;
		}
	}

	sprint (self, PRINT_HIGH, "There is no help for you.\n");
};

void() AliasTimer = {
	local entity oself;
	local float myheat;

	self.heat = self.heat + 1;
	myheat = self.heat;
	if (self.heat > 5) {
		self.think = SUB_Remove;
		self.nextthink = time + 0.1;
	}
	oself = self;
	self = self.owner;

	if (myheat == 1) {
		sprint (self, PRINT_HIGH, "binding aliases...\n");

		// Stuff Aliases

		// Grenades
		TeamFortress_Alias("primeone", TF_GRENADE_1, 0);
		TeamFortress_Alias("primetwo", TF_GRENADE_2, 0);
		TeamFortress_Alias("throwgren", TF_GRENADE_T, 0);
		TeamFortress_Alias("+gren1", TF_GRENADE_1, 0);
		TeamFortress_Alias("+gren2", TF_GRENADE_2, 0);
		TeamFortress_Alias("-gren1", TF_GRENADE_T, 0);
		TeamFortress_Alias("-gren2", TF_GRENADE_T, 0);

		// Pipebombs
		TeamFortress_Alias("detpipe", TF_PB_DETONATE, 0);
		TeamFortress_Alias("uncustom", TF_UNCUSTOM, 0);
	}
	else if (myheat == 2) {
		// Reloading
		TeamFortress_Alias("reload", TF_RELOAD, 0);

		// Actions
		TeamFortress_Alias("special", TF_SPECIAL_SKILL, 0);
		TeamFortress_Alias("saveme", TF_MEDIC_HELPME, 0);
		TeamFortress_Alias("discard", TF_DISCARD, 0);
		TeamFortress_Alias("id", TF_ID, 0);
		TeamFortress_Alias("inv",TF_INVENTORY, 0);

		// Class Ability Impulses
		TeamFortress_Alias("disguise", TF_SPY_SPY, 0);
		TeamFortress_Alias("feign", TF_SPY_DIE, 0);
		TeamFortress_Alias("sfeign", TF_SPY_DIE2, 0);
		TeamFortress_Alias("build", TF_ENGINEER_BUILD, 0);
		TeamFortress_Alias("detdispenser", (TF_ENGINEER_BUILD), 7);

		// General
		TeamFortress_Alias("dropammo", TF_DROP_AMMO, 0);
		TeamFortress_Alias("flaginfo", FLAG_INFO, 0);
		TeamFortress_Alias("autozoom", TF_AUTOZOOM, 0);
		TeamFortress_Alias("showloc", TF_DISPLAYLOCATION, 0);
		//TeamFortress_Alias("changeclass",TF_CHANGECLASS, 0);
                                    //- OfN - it was(TF_CHANGEPC + PC_CUSTOM)
	}
	else if (myheat == 3) {
		//Taunts
		TeamFortress_Alias("taunt1", TF_TAUNT, 0);
		TeamFortress_Alias("taunt2", TF_TAUNT2, 0);
		TeamFortress_Alias("taunt3", TF_TAUNT3, 0);
		TeamFortress_Alias("taunt4", TF_TAUNT4, 0);
		TeamFortress_Alias("taunt5", TF_TAUNT5, 0);

		// Class Changing
		TeamFortress_Alias("scout",(TF_CHANGEPC + PC_SCOUT), 0);
		TeamFortress_Alias("sniper",(TF_CHANGEPC + PC_SNIPER), 0);
		TeamFortress_Alias("soldier",(TF_CHANGEPC + PC_SOLDIER), 0);
		TeamFortress_Alias("demoman",(TF_CHANGEPC + PC_DEMOMAN), 0);
		TeamFortress_Alias("medic",(TF_CHANGEPC + PC_MEDIC), 0);
		TeamFortress_Alias("hwguy",(TF_CHANGEPC + PC_HVYWEAP), 0);
		TeamFortress_Alias("pyro",(TF_CHANGEPC + PC_PYRO), 0);
		TeamFortress_Alias("spy",(TF_CHANGEPC + PC_SPY), 0);
		TeamFortress_Alias("engineer",(TF_CHANGEPC + PC_ENGINEER), 0);
		TeamFortress_Alias("randompc",(TF_CHANGEPC + PC_RANDOM), 0);

		TeamFortress_Alias("showtf",TF_SHOWTF, 0);
		TeamFortress_Alias("maphelp", TF_HELP_MAP, 0);			
		TeamFortress_Alias("dropkey", TF_DROPKEY, 0);
	}
	else if (myheat == 4) {
		// Sample aliases for the Scanner
		TeamFortress_Alias("scan10", TF_SCAN_10, 0);
		TeamFortress_Alias("scan30", TF_SCAN_30, 0);
		TeamFortress_Alias("scan100", TF_SCAN_100, 0);
		TeamFortress_Alias("scanf", TF_SCAN_FRIENDLY, 0);
		TeamFortress_Alias("scane", TF_SCAN_ENEMY, 0);

		// Team handlers
		TeamFortress_Alias("showscores",TF_TEAM_SCORES, 0);
		TeamFortress_Alias("showclasses",TF_TEAM_CLASSES, 0);
		TeamFortress_Alias("query", TF_STATUS_QUERY, 0);

		// Sample aliases for the Detpack
		TeamFortress_Alias("det5", TF_DETPACK_5, 0);
		TeamFortress_Alias("det20", TF_DETPACK_20, 0);
		TeamFortress_Alias("det50", TF_DETPACK_50, 0);
		TeamFortress_Alias("+det5", TF_DETPACK_5, 0);
		TeamFortress_Alias("-det5", TF_DETPACK_STOP, 0);
		TeamFortress_Alias("+det20", TF_DETPACK_20, 0);
		TeamFortress_Alias("-det20", TF_DETPACK_STOP, 0);
		TeamFortress_Alias("+det50", TF_DETPACK_50, 0);
		TeamFortress_Alias("-det50", TF_DETPACK_STOP, 0);
	}
	else if (myheat == 5) {
		//Get rid of silly MegaTF 10 year olds
		TeamFortress_Alias("lay", TF_LAY, 0);
		//CH allow dropitems
		//TeamFortress_Alias("dropitems", TF_DROPITEMS, 0);
        //TeamFortress_Alias("get", TF_ADMIN_KICK_CYCLE, 0);
		//TeamFortress_Alias("kick", TF_ADMIN_KICK_PERSON, 0);
		//TeamFortress_Alias("ban", TF_ADMIN_BAN_PERSON, 0);
		//TeamFortress_Alias("ceasefire", TF_ADMIN_CEASEFIRE, 0);
        //TeamFortress_Alias("cmnd", IMPULSE_STUFFCMD, 0);

#ifdef STATUSBAR
		TeamFortress_Alias("sbar_on", TF_STATUSBAR_ON, 0);
		TeamFortress_Alias("sbar_off", TF_STATUSBAR_OFF, 0);
		TeamFortress_Alias("sbar_200", TF_STATUSBAR_RES_START, 0);
		TeamFortress_Alias("sbar_240", TF_STATUSBAR_RES_START + 1, 0);
		TeamFortress_Alias("sbar_300", TF_STATUSBAR_RES_START + 2, 0);
		TeamFortress_Alias("sbar_350", TF_STATUSBAR_RES_START + 3, 0);
		TeamFortress_Alias("sbar_384", TF_STATUSBAR_RES_START + 4, 0);
		TeamFortress_Alias("sbar_400", TF_STATUSBAR_RES_START + 5, 0);
		TeamFortress_Alias("sbar_480", TF_STATUSBAR_RES_START + 6, 0);
		TeamFortress_Alias("sbar_600", TF_STATUSBAR_RES_START + 7, 0);
		TeamFortress_Alias("sbar_768", TF_STATUSBAR_RES_START + 8, 0);
#endif
		// Set up the alias check
		TeamFortress_Alias("prozacalias", TF_ALIAS_CHECK, 0);

		// Do the binds
		stuffcmd(self, "bind 9 \"impulse 9\"\n");
		stuffcmd(self, "bind 0 \"impulse 10\"\n");

		//WK INTRO THUNDER
		stuffcmd(self, "play ambience/thunder1\n");
	}
	self = oself;
	self.nextthink = time + 1;
};
