/*======================================================
	CLIENT.QC			Custom TeamFortress v3.2

	(c) TeamFortress Software Pty Ltd 	29/2/97
	(c) William Kerney			16/9/00
	(c) Craig Hauser				19/3/00
========================================================
Handles obituaries, what happens when a client dies, respawns,
connects & disconnects, and when a map changes levels
======================================================*/

// prototypes
void () W_WeaponFrame;
void() W_SetCurrentAmmo;
void() player_pain;
void() player_stand1;
void (vector org) spawn_tfog;
void (vector org, entity death_owner) spawn_tdeath;
float modelindex_eyes, modelindex_player, modelindex_null;
float(float v) anglemod;

//void () SetUpChrisRound;//-
void () PrematchBegin;
void () TeamAllPlayers;
//void (float winner) RoundStop;//-
//void () UpdateScores;
//void () roundtimer_think;//-
//void () EndRound;//-

// TeamFortress prototypes
void() TeamFortress_MOTD;
void() TeamFortress_CheckTeamCheats;
//float(float tno) TeamFortress_TeamGetColor; //- OfN - not used here
void(entity Viewer, float pc, float rpc) TeamFortress_PrintClassName;
void(entity Viewer, float pc) TeamFortress_PrintJobName;
void() TeamFortress_RemoveTimers;
void(float Suicided) TeamFortress_SetupRespawn;
void() TeamFortress_ShowTF;
float(float pc) IsLegalClass;
void() SetupTeamEqualiser;
#ifdef QUAKE_WORLD
void(entity p) SetTeamName;
#endif
void (float number) decrement_team_ammoboxes;
void() TeamFortress_DetonatePipebombs;
void(float f) decrement_team_pipebombs;		
void () PlayerObserverMode;

// Hook prototypes
void () Service_Grapple;

// TeamFortressMap prototypes
void(entity AD) ParseTFDetect;
entity(float ino) Finditem;
void(entity Item, entity AP, entity Goal) tfgoalitem_GiveToPlayer;
void(entity Goal, entity AP, entity ActivatingGoal) AttemptToActivate;
void() CTF_FlagCheck;

//WK
void() DropToCustomClassGen;
void(entity p) TeamFortress_SetSpeed;
void () kill_my_demon;
void () DetonateAllGuns; // SB
void () Boot_Flamer_stream_touch;
void (entity foo,float bar) makeImmune;

// SB Extern
void (entity targ) GetRank;
//void() SwitchFromCamera;

//==============// ofn
void(entity mine_owner) DetonateMines;
void(entity player) RemoveHolo;
string(entity thebuilding) GetBuildingName;
string(entity themonster) GetMonsterName;
void(entity attacker) MonsterKill;
void() DetonateAllGunsForced;

/*
=============================================================================

				LEVEL CHANGING / INTERMISSION

=============================================================================
*/

string nextmap;

float	intermission_running;
float	intermission_exittime;

/*QUAKED info_intermission (1 0.5 0.5) (-16 -16 -16) (16 16 16)
This is the camera point for the intermission.
Use mangle instead of angle, so you can set pitch or roll as well as yaw.  'pitch roll yaw'
*/
void() info_intermission =
{
	if (CheckExistence() == #FALSE)
	{
		dremove(self);
		return;
	}
};


void() SetChangeParms =
{
	if (self.health <= 0)
 	{
 		SetNewParms ();
 		return;
 	}

	// remove items
	self.items = self.items - (self.items &	(#IT_KEY1 | #IT_KEY2 | #IT_INVISIBILITY | #IT_INVULNERABILITY | #IT_SUIT | #IT_QUAD) );
	
	// cap super health
	if (self.health > 100)
		self.health = 100;
	if (self.health < 50)
		self.health = 50;
	parm1 = self.items;
	parm2 = self.health;
	parm3 = self.armorvalue;
	if (self.ammo_shells < 25)
		parm4 = 25;
	else
		parm4 = self.ammo_shells;
	parm5 = self.ammo_nails;
	parm6 = self.ammo_rockets;
	parm7 = self.ammo_cells;
	parm8 = self.current_weapon;
	parm9 = self.armortype * 100;

	// TeamFortress Parameters
	parm10 = toggleflags;  // Store the global ToggleFlag settings
	parm11 = 0;   		   // Random Playerclass
	parm12 = 0;

#ifdef COOP_MODE
	if (toggleflags & #TFLAG_CLASS_PERSIST)
	{
		if (self.tfstate & #TFSTATE_RANDOMPC)
		{
			parm11 = (parm11 | #TFSTATE_RANDOMPC);
			self.playerclass = 1 + floor(random() * (#PC_RANDOM - 1));
			while(!IsLegalClass(self.playerclass))
				self.playerclass = 1 + floor(random() * (#PC_RANDOM - 1));
		}

		parm12 = self.playerclass;				// save the playerclass between levels in parm12
	}											// if the toggleflag CLASS_PERSIST is set
#endif

#ifdef STATUSBAR
	parm13 = self.StatusBarRes;
	parm14 = self.StatusBarSize;
#endif
#ifdef QUAKE_WORLD
	parm15 = self.admin_flag; //CH Pass along admin status :)
#endif
};

void() SetNewParms =
{
	parm1 = 0;
	parm2 = 100;
	parm3 = 0;
	parm4 = 25;
	parm5 = 0;
	parm6 = 0;
	parm6 = 0;
	parm8 = 1;
	parm9 = 0;

	// TeamFortress Parameters
	parm10 = 0;
	parm11 = 0;
	parm12 = 0;
	parm13 = 0;
	parm14 = 0;
	parm15 = 0;
};

// This think kicks in 30 seconds into the map to
// turn autoteam on.
void() autoteam_think =
{
	local float loopc;
	local entity other,oself;
	
//	if (chris)
//		SetUpChrisRound();
//	if (!chris)
		PrematchBegin();
	
	toggleflags = toggleflags | #TFLAG_AUTOTEAM;
	dremove(self);
};

void () PrematchBegin =
{
	if (prematch)
	{
		bprint(#PRINT_HIGH,"Ь The game has now started! Ь\n");
		other = find(world, classname, "player");
		while (other != world)
		{
			other.is_abouttodie = #TRUE;
			other.items = other.items - (other.items & #IT_INVULNERABILITY);
			other.invincible_time = 0;
			other.invincible_finished = 0;
			other.effects = other.effects - (other.effects & #EF_DIMLIGHT);
			TF_T_Damage(other, world, world, other.health + 20, #TF_TD_IGNOREARMOUR, #TF_TD_OTHER);
			other = find(other, classname, "player");
		}
		
        // - OfN - wtf
        /*other = find(world, classname, "grunty");
		while (other != world)
		{
			other.is_abouttodie = #TRUE;
			other.items = other.items - (other.items & #IT_INVULNERABILITY);
			other.invincible_time = 0;
			other.invincible_finished = 0;
			other.effects = other.effects - (other.effects & #EF_DIMLIGHT);
			TF_T_Damage(other, world, world, other.health + 20, #TF_TD_IGNOREARMOUR, #TF_TD_OTHER);
			other = find(other, classname, "grunty");
		}*/
	}
	
/*	if (chris)
	{
		if (self.classname == "prematch_timer")
			dremove(self);
		else
			SetUpChrisRound();
	}*/
};

/*void () SetUpChrisRound =
{
	local entity other, oself;
	
	// Make sure everyone is on a team
	TeamAllPlayers();
	
	// Clean up team player counts
	team1total = 0;
	team2total = 0;
	team3total = 0;
	team4total = 0;

	oself = self;
	
	other = find(world, classname, "player");
	while (other != world)
	{
		if (livesperguy > 0)
		{
			if (other.team_no == 1) team1total = team1total + livesperguy;
			if (other.team_no == 2) team2total = team2total + livesperguy;
			if (other.team_no == 3) team3total = team3total + livesperguy;
			if (other.team_no == 4) team4total = team4total + livesperguy;
			other.lives = livesperguy;
		}
		
		self = other;
		kill_my_demon();
		DetonateAllGuns();
		
		TF_T_Damage(other, world, world, other.health + 20, #TF_TD_IGNOREARMOUR, #TF_TD_OTHER);
		
		other = find(other, classname, "player");
	}
	
	newmis = spawn();
	newmis.classname = "chris_round_timer";
	newmis.nextthink = time + roundtime;
	newmis.think = roundtimer_think;
};*/

/*void() roundtimer_think =
{

	RoundStop(0);
	dremove(self);

};*/

void () TeamAllPlayers =
{
	local entity other, oself;
	
	other = find(world, classname, "player");
	while (other != world)
	{
		if (other.team_no <= 0 && !other.has_disconnected)
		{
			oself = self;
			self = other;
			Menu_Team_Input(5);
			self = oself;
		}
		other = find(other, classname, "player");
	}
};		

/*void (float winner) RoundStop =
{
	if (winner == 0)
		bprint(#PRINT_MEDIUM, "The round has ended due to time.\n");
	else
	{
		if (winner == 1)
		{
			team1rounds = team1rounds + 1;
			bprint(#PRINT_MEDIUM, "The blue team wins the round.\n");
		}
		if (winner == 2)
		{
			team2rounds = team2rounds + 1;
			bprint(#PRINT_MEDIUM, "This round goes to the red team.\n");
		}
		if (winner == 3)
		{
			team3rounds = team3rounds + 1;
			bprint(#PRINT_MEDIUM, "The yellow team are sponsored by SB-1 Tech and have won this round.\n");
		}
		if (winner == 4)
		{
			team4rounds = team4rounds + 1;
			bprint(#PRINT_MEDIUM, "The green team are the winners of this round.\n");
		}
	}
	
	UpdateScores();
	
	newmis = spawn();
	newmis.nextthink = time + 1;
	newmis.think = EndRound;
};*/

/*void() UpdateScores =
{
	local entity guy;
	
	guy = find(other, classname, "player");
	while (guy != world)
	{
		if (guy.team_no == 1)
		{
			guy.frags = team1rounds * 10;
			guy.real_frags = team1rounds * 10;
		}
		else if (guy.team_no == 2)
		{
			guy.frags = team2rounds * 10;
			guy.real_frags = team2rounds * 10;
		}
		else if (guy.team_no == 3)
		{
			guy.frags = team3rounds * 10;
			guy.real_frags = team3rounds * 10;
		}
		else if (guy.team_no == 4)
		{
			guy.frags = team4rounds * 10;
			guy.real_frags = team4rounds * 10;
		}
		guy = find(guy, classname, "other");
	}
};*/ /////////////??/////////////7

/*void() EndRound =
{
	local entity roundtimer, prematchtimer;
	local float winner, prematchtime;
	local string st;
	
	// Kill the round timer
	other = find(world, classname, "chris_round_timer");
	// I deliberately don't do a contingency check here - if it screws up I wanna know about it
	dremove(other);
	
	st = infokey(world, "pm");
	if (st == string_null) // if 'pm' isn't set, try 'prematch'
		st = infokey(world, "prematch");
	if (st == "on") // if it reads 'on', do a 30 second prematch
		prematchtime = time + 30;
	else // if it doesn't read 'on'...
		prematchtime = stof(st); // turn the string into a float
	if (prematchtime) // if we have prematch
	{
		prematch = time + prematchtime; // set it
	}
	else
		prematch = #FALSE; // otherwise, no prematch
	
	// Kill everyone
/*	other = find(world, classname, "player");
	while (other != world)
	{
		TF_T_Damage(other, world, world, other.health + 20, #TF_TD_IGNOREARMOUR, #TF_TD_OTHER);
		other = find(other, classname, "player");
	} Don't kill everyone here or it drops the flag
	*/
	// Set up the timer
/*-	if (team1rounds < roundstowin && team2rounds < roundstowin && team3rounds < roundstowin && team4rounds < roundstowin)
	{
		roundtimer = spawn();
		roundtimer.think = SetUpChrisRound;
		roundtimer.nextthink = time + 5;
		
		prematchtimer = spawn();
		prematchtimer.classname == "prematch_timer";
		prematchtimer.nextthink = time + prematch;
		prematchtimer.think = PrematchBegin;
	}
	else
	{
		newmis = spawn();
		newmis.nextthink = time + 5;
		newmis.think = execute_changelevel;
	}
};*/

void() DecodeLevelParms =
{
	local string st;
	local entity ent;
	local float prematchtime;

	if (serverflags)
	{
		if (world.model == "maps/start.bsp")
			SetNewParms ();		// take away all stuff on starting new episode
	}
	
	self.items = parm1;
	self.health = parm2;
	self.armorvalue = parm3;
	self.ammo_shells = parm4;
	self.ammo_nails = parm5;
	self.ammo_rockets = parm6;
	self.ammo_cells = parm7;
	self.current_weapon = parm8;
	self.armortype = parm9 * 0.01;

	// TeamFortress Parameters
	// Detect whether this is the first entrance into a map
	if (toggleflags == 0)
	{
		toggleflags = parm10;
		allow_hook = 0;
		invis_only = #SPY_INVIS_ONLY;

		if (coop || !deathmatch)
			toggleflags = toggleflags | #TFLAG_CLASS_PERSIST;

		nextmap = mapname;

	#ifdef GRAPPLING_HOOK
		allow_hook = #TRUE;
	#endif

		// Is this a FortressMap?
		ent = find(world, classname, "info_tfdetect");
		if (ent != world)
		{
			// Turn on Teamplay
			if (teamplay == 0)
				cvar_set("teamplay","21?TeamFortress");

			// Parse the rest of the Detection details
			ParseTFDetect(ent);

			// If the number_of_teams wasn't set, then there's not TF
			// spawnpoints on this lvl... so guess at 4 teams.
			if (number_of_teams <= 0 || number_of_teams >= 5)
				number_of_teams = 4;
		}
		else
		{
			// Is this a CTF map?
			ent = find(world, classname, "info_player_team1");
			if ((ent != world) || (CTF_Map == #TRUE))
			{
				// Turn on CTF MAP
				CTF_Map = #TRUE;

				// Turn on Teamplay
				if (teamplay == 0)
					cvar_set("teamplay","21?TeamFortress");

				// Setup the CTF FlagCheck Timer
				ent = spawn();
				ent.nextthink = time + 30;
				ent.think = CTF_FlagCheck;

				number_of_teams = 2;
			}
			else // Normal map
			{
				number_of_teams = 4;
			}

			// Set speed limits
#ifndef QUAKE_WORLD
			cvar_set("sv_maxspeed", "1000");
#endif
			// set aiming level
#ifndef NET_SERVER
			cvar_set("sv_aim", "1");
#endif
			// Set life limits
			team1lives = -1;
			team2lives = -1;
			team3lives = -1;
			team4lives = -1;

			// WK Clear our nextspam counters
			team1nextspam = -1;
			team2nextspam = -1;
			team3nextspam = -1;
			team4nextspam = -1;

			// Set illegal playerclasses
			illegalclasses1 = 0;
			illegalclasses2 = 0;
			illegalclasses3 = 0;
			illegalclasses4 = 0;

			// Set Team Limits
			team1maxplayers = 100;
			team2maxplayers = 100;
			team3maxplayers = 100;
			team4maxplayers = 100;
			civilianteams = 0;
		}

		bprint (#PRINT_HIGH, "Ќбр ќбне: ");
		bprint (#PRINT_HIGH, mapname);
		bprint (#PRINT_HIGH, "\n");

		SetupTeamEqualiser();

		if (#NEVER_TEAMFRAGS)
		{
			toggleflags = toggleflags - (toggleflags & #TFLAG_TEAMFRAGS);
		}
		
		if (#ALWAYS_TEAMFRAGS)
		{
			toggleflags = toggleflags | #TFLAG_TEAMFRAGS;
		}
		
		if (#CHECK_SPEEDS)
		{
			toggleflags = toggleflags | #TFLAG_CHEATCHECK;
		}

	#ifdef QUAKE_WORLD
		st = infokey(world, "temp1");
		toggleflags = (toggleflags | #TFLAG_FIRSTENTRY | stof(st));
	#else
		toggleflags = (toggleflags | #TFLAG_FIRSTENTRY | cvar("temp1"));
	#endif

		local float autoteam_time;
		autoteam_time = 30;

	#ifdef QUAKE_WORLD
		// check all serverinfo settings, to set the appropriate toggleflags
		local string st;

		// AUTOTEAM
		st = infokey(world, "a");
		if (st == string_null)
			st = infokey(world, "autoteam");
		if (st == "on")
			toggleflags = toggleflags | #TFLAG_AUTOTEAM;
		else if (st == "off")
			toggleflags = toggleflags - (toggleflags & #TFLAG_AUTOTEAM);
		else if (stof(st) != 0)
		{
			toggleflags = toggleflags | #TFLAG_AUTOTEAM;
			autoteam_time = stof(st);
		}

		// TEAMFRAGS
		st = infokey(world, "t");
		if (st == string_null)
			st = infokey(world, "teamfrags");
		if (st == "on")
			toggleflags = toggleflags | #TFLAG_TEAMFRAGS;
		else if (st == "off")
			toggleflags = toggleflags - (toggleflags & #TFLAG_TEAMFRAGS);

		//WK JELLO WATER
		st = infokey(world, "j");
		if (st == string_null)
			st = infokey(world, "jello");
		if (st == "on")
			jello = #TRUE;
		else {
			local float numba;
			numba = stof(st);
			if (numba)
				jello = numba;
			else
				jello = #FALSE;
		}

		//WK JELLO WATER
		light_damage = #FALSE;
		st = infokey(world, "ld");
		if (st == string_null)
			st = infokey(world, "lightdamage");
		if (st == "on")
			light_damage = #TRUE;

		// SB New, improved TF 2.9 fake prematch mode!
		// We can make a class, come in, run around, play tag the flag, but can't do anything
		// useful until the prematch is over!
		
		st = infokey(world, "pm");
		if (st == string_null) // if 'pm' isn't set, try 'prematch'
			st = infokey(world, "prematch");
		if (st == "on") // if it reads 'on', do a 30 second prematch
			prematchtime = time + 30;
		else // if it doesn't read 'on'...
			prematchtime = stof(st); // turn the string into a float
		if (prematchtime) // if we have prematch
		{
			prematch = time + prematchtime; // set it
			autoteam_time = prematchtime;
			toggleflags = toggleflags | #TFLAG_AUTOTEAM;
		}
		else
			prematch = #FALSE; // otherwise, no prematch
		
		//WK Bounty System
		st = infokey(world, "bounty");
		if (st == string_null)
			st = infokey(world, "moola");
		if (st == "on")
			bounty = #TRUE;
		else
			bounty = #FALSE;

		//CH Sets the starting amount of money :)
		st = infokey(world, "m");
		if (st == string_null)
			st = infokey(world, "money");
		local float numba;
		numba = stof(st);
		if (numba)
			custom_money = numba;
		else
			custom_money = #SPENDING_LIMIT;

		// GRAPPLING HOOK
		st = infokey(world, "g");
		if (st == string_null)
			st = infokey(world, "grapple");
		if (st == "off")
			allow_hook = #FALSE;
		if (!(toggleflags & #TFLAG_GRAPPLE) && st != "on")
			allow_hook = #FALSE;

		// SPY OFF
		st = infokey(world, "spy");
		if (st == "off")
			spy_off = #TRUE;

		// SPY INVIS ONLY
		st = infokey(world, "s");
		if (st == string_null)
			st = infokey(world, "spyinvis");
		if (st == "on" || toggleflags & #TFLAG_SPYINVIS)
			invis_only = #TRUE;
		else if (st == "off")
			invis_only = #FALSE;

		// RespawnDelay
		st = infokey(world, "rd");
		if (st == string_null)
			st = infokey(world, "respawn_delay");
		respawn_delay_time = stof(st);
		if (respawn_delay_time)
			toggleflags = toggleflags | #TFLAG_RESPAWNDELAY;
	#else
		// GRAPPLING HOOK
		if (!(toggleflags & #TFLAG_GRAPPLE) && (CTF_Map == #FALSE))
			allow_hook = #FALSE;
	#endif

		// If no Respawndelay has been specified, set the default
		if (toggleflags & #TFLAG_RESPAWNDELAY && respawn_delay_time == 0)
			respawn_delay_time = #RESPAWN_DELAY_TIME;

		// Prevent autoteam from kicking in for 30 seconds.
		// Allows restructuring of the teams from the last map nicely.
		if (toggleflags & #TFLAG_AUTOTEAM)
		{
			toggleflags = toggleflags - (toggleflags & #TFLAG_AUTOTEAM);
			ent = spawn();
			ent.nextthink = time + autoteam_time;
			ent.think = autoteam_think;
		}
	}

	if (parm11)
		self.tfstate = parm11;
	if (self.playerclass == 0)
		self.playerclass = parm12;

#ifdef STATUSBAR
	if (parm13)
		self.StatusBarRes = parm13;
	if (parm14)
		self.StatusBarSize = parm14;
#endif
#ifdef QUAKE_WORLD
	if (parm15)
		self.admin_flag = parm15; //CH Admin status :)
#endif
};

/*
============
FindIntermission

Returns the entity to view from
============
*/
entity() FindIntermission =
{
	local	entity spot;
	local	float cyc;

	// look for info_intermission first
	spot = find (world, classname, "info_intermission");
	if (spot)
	{	// pick a random one
		cyc = random() * 1;

		// Following removed for the observer code
		/*while (cyc > 1)
		{
			spot = find (spot, classname, "info_intermission");
			if (!spot)
				spot = find (spot, classname, "info_intermission");
			cyc = cyc - 1;
		}*/

		return spot;
	}

// then look for the start position
	spot = find (world, classname, "info_player_start");
	if (spot)
		return spot;

// then look through the deathmatch starts
	spot = find (world, classname, "info_player_deathmatch");
	if (spot)
	{	
		// pick a random one
		cyc = random() * 6;
		while (cyc > 1)
		{
			spot = find (spot, classname, "info_player_deathmatch");
			if (!spot)
				spot = find (spot, classname, "info_player_deathmatch");
			cyc = cyc - 1;
		}
		return spot;
	}
	
	
	objerror ("FindIntermission: no spot");
};

/*===========================
FindNextIntermission

returns the next intermission point
===========================*/
entity (entity start_point) FindNextIntermission =
{
	local	entity spot;
	local	float cyc;

	if (deathmatch)
	{
	// look through info_intermission first
		if (start_point.classname == "info_intermission" || start_point == world)
		{
			spot = find (start_point, classname, "info_intermission");
			if (spot)
				return spot;
			else
				start_point = world;
		}


	// then look through the deathmatch starts
		if (start_point.classname == "info_player_deathmatch" || start_point == world)
		{
			spot = find (start_point, classname, "info_player_deathmatch");
			if (spot)
				return spot;
		}

		// at the end of the list
		spot = find (world, classname, "info_intermission");
		if (spot)
			return spot;

		spot = find (world, classname, "info_player_deathmatch");
		if (spot)
			return spot;
	}
	else // do not cycle though in co-op or single
	{
		spot = find (world, classname, "info_player_start");
		if (spot)
			return spot;
	}

	// it should never reach this point
	return FindIntermission();	
};


/*==================================================

TF_MovePlayer
Moves the player to another intermission viewpoint

====================================================*/

void() TF_MovePlayer =
{
	local entity place;

	place = FindNextIntermission(self.observer_list);

	self.observer_list = place;

	setorigin(self, place.origin + '0 0 1');
	self.angles = place.angles;
	self.fixangle = #TRUE;		// turn this way immediately

};

float() GetNoPlayers;

#define CYCLED 2

float() DoExtraCycle =
{
    //-------------------------------------------------//
    //- OfN - I tried to make this work like in tf2.8 -//
    local string nfmap, temp;
    nfmap = infokey(world, "nmap");
    if (nfmap != string_null)
    {
        local float minplayers, maxplayers, itsok, currentpl;
        
        if (infokey(world,"minp")!="")
            minplayers = stof(infokey(world,"minp"));
        else
            minplayers = 0;

        if (infokey(world,"maxp")!="")
            maxplayers = stof(infokey(world,"maxp"));
        else
            maxplayers = 32;

        itsok = #TRUE;
        
        currentpl = GetNoPlayers();

        //check conditions
        
        if (minplayers > currentpl)
        {
            bprint(#PRINT_HIGH,"Map ");
            nfmap = infokey(world, "nmap");
            bprint(#PRINT_HIGH, nfmap);
            bprint(#PRINT_HIGH," skipped - minimum players ");
            temp = ftos(minplayers);
            bprint(#PRINT_HIGH, temp);
            bprint(#PRINT_HIGH," (currently ");
            temp = ftos(currentpl);
            bprint(#PRINT_HIGH, temp);
            bprint(#PRINT_HIGH,")\n");
            itsok = #FALSE;
        }
        else 
        {
            if (maxplayers < currentpl)
            {
                bprint(#PRINT_HIGH,"Map ");
                nfmap = infokey(world, "nmap");
                bprint(#PRINT_HIGH, nfmap);
                bprint(#PRINT_HIGH," skipped - maximum players ");
                temp = ftos(maxplayers);
                bprint(#PRINT_HIGH,temp);
                bprint(#PRINT_HIGH," (currently ");
                temp = ftos(currentpl);
                bprint(#PRINT_HIGH,temp);
                bprint(#PRINT_HIGH,")\n");
                itsok = #FALSE;
            }         
        }
  
        //cleanup..
        localcmd("localinfo minp \"\"\n");
        localcmd("localinfo maxp \"\"\n");
        //locals clean

        //execute map conditions ok
        if (itsok)
        {
            nfmap = infokey(world, "nmap");
            
            bprint(#PRINT_HIGH,"\nLoading ");
            bprint(#PRINT_HIGH,nfmap);
            bprint(#PRINT_HIGH," map file...\n");

            localcmd("localinfo nmap \"\"\n");

            localcmd("map ");
            localcmd(nfmap);
            localcmd("\n");
            
            return #TRUE;
        }
        else //conditions not passed...
        {
            localcmd("localinfo nmap \"\"\n");
            return #FALSE;
        }
    }

    return #FALSE;
};

void() GotoNextMap;

void() cycle_timer_think =
{
    GotoNextMap();
    dremove(self);
};

void() SetCycleTimer =
{
    newmis = spawn();
    newmis.classname = "cyclemap_timer";
    newmis.nextthink = time + 0.1;
    newmis.think = cycle_timer_think;
};

void() GotoNextMap =
{
    local float nextlevel;
	local string sl;
	local entity te;
	local string cyc;

	if (nextmap != mapname)
	{
		changelevel(nextmap);
		already_chosen_map = #TRUE;
	}

    if (already_chosen_map == #FALSE || already_chosen_map == #CYCLED)
    {
        if (DoExtraCycle())
      		already_chosen_map = #TRUE;
        else
            already_chosen_map = #FALSE;
    }

	//- OfN - super new map cycling code :)
	if (already_chosen_map == #FALSE)
	{
        // ------- - ------- //
		sl = infokey(world, "n");
		nextlevel = stof(sl);

		nextlevel = nextlevel + 1;  // next level
		sl = ftos(nextlevel);
		localcmd("serverinfo n ");
		localcmd(sl);
		localcmd("\n");
        
        
		// change map
        cyc = infokey(world, "cycledir");
        if ( cyc == string_null )
            localcmd("exec qwmcycle/map");
        else
        {
            localcmd("exec ");
            localcmd(cyc);
            localcmd("/map");
        } //.................//

		localcmd(sl);
		localcmd(".cfg\n");

		already_chosen_map = #CYCLED;
	}

	if (infokey(world, "n") == "0")
        already_chosen_map = #FALSE;

    if (already_chosen_map == #FALSE) // nothing was done yet, so set the damn timer..
    {
        SetCycleTimer();
        return;
    }
    
    if (already_chosen_map == #CYCLED) // if we executed a mapx.cfg
        SetCycleTimer(); // set the timer to check the real map afte 0.1 seconds
};


void() ExitIntermission =
{
	RPrint("Exiting intermission...\n");
// skip any text in deathmatch
	if (deathmatch)
	{
		RPrint("Exit Intermission in Deathmatch.\n");
        GotoNextMap ();
		return;
	}
	
	intermission_exittime = time + 1;
	intermission_running = intermission_running + 1;

//
// run some text if at the end of an episode
//
	if (intermission_running == 2)
	{
		if (world.model == "maps/e1m7.bsp")
		{
			WriteByte (#MSG_ALL, #SVC_CDTRACK);
			WriteByte (#MSG_ALL, 2);
			WriteByte (#MSG_ALL, 3);
			if (!cvar("registered"))
			{
				WriteByte (#MSG_ALL, #SVC_FINALE);
				WriteString (#MSG_ALL, "As the corpse of the monstrous entity\nChthon sinks back into the lava whence\nit rose, you grip the Rune of Earth\nMagic tightly. Now that you have\nconquered the Dimension of the Doomed,\nrealm of Earth Magic, you are ready to\ncomplete your task in the other three\nhaunted lands of Quake. Or are you? If\nyou don't register Quake, you'll never\nknow what awaits you in the Realm of\nBlack Magic, the Netherworld, and the\nElder World!");
			}
			else
			{
				WriteByte (#MSG_ALL, #SVC_FINALE);
				WriteString (#MSG_ALL, "As the corpse of the monstrous entity\nChthon sinks back into the lava whence\nit rose, you grip the Rune of Earth\nMagic tightly. Now that you have\nconquered the Dimension of the Doomed,\nrealm of Earth Magic, you are ready to\ncomplete your task. A Rune of magic\npower lies at the end of each haunted\nland of Quake. Go forth, seek the\ntotality of the four Runes!");
			}
			return;
		}
		else if (world.model == "maps/e2m6.bsp")
		{
			WriteByte (#MSG_ALL, #SVC_CDTRACK);
			WriteByte (#MSG_ALL, 2);
			WriteByte (#MSG_ALL, 3);

			WriteByte (#MSG_ALL, #SVC_FINALE);
			WriteString (#MSG_ALL, "The Rune of Black Magic throbs evilly in\nyour hand and whispers dark thoughts\ninto your brain. You learn the inmost\nlore of the Hell-Mother; Shub-Niggurath!\nYou now know that she is behind all the\nterrible plotting which has led to so\nmuch death and horror. But she is not\ninviolate! Armed with this Rune, you\nrealize that once all four Runes are\ncombined, the gate to Shub-Niggurath's\nPit will open, and you can face the\nWitch-Goddess herself in her frightful\notherworld cathedral.");
			return;
		}
		else if (world.model == "maps/e3m6.bsp")
		{
			WriteByte (#MSG_ALL, #SVC_CDTRACK);
			WriteByte (#MSG_ALL, 2);
			WriteByte (#MSG_ALL, 3);

			WriteByte (#MSG_ALL, #SVC_FINALE);
			WriteString (#MSG_ALL, "The charred viscera of diabolic horrors\nbubble viscously as you seize the Rune\nof Hell Magic. Its heat scorches your\nhand, and its terrible secrets blight\nyour mind. Gathering the shreds of your\ncourage, you shake the devil's shackles\nfrom your soul, and become ever more\nhard and determined to destroy the\nhideous creatures whose mere existence\nthreatens the souls and psyches of all\nthe population of Earth.");
			return;
		}
		else if (world.model == "maps/e4m7.bsp")
		{
			WriteByte (#MSG_ALL, #SVC_CDTRACK);
			WriteByte (#MSG_ALL, 2);
			WriteByte (#MSG_ALL, 3);

			WriteByte (#MSG_ALL, #SVC_FINALE);
			WriteString (#MSG_ALL, "Despite the awful might of the Elder\nWorld, you have achieved the Rune of\nElder Magic, capstone of all types of\narcane wisdom. Beyond good and evil,\nbeyond life and death, the Rune\npulsates, heavy with import. Patient and\npotent, the Elder Being Shub-Niggurath\nweaves her dire plans to clear off all\nlife from the Earth, and bring her own\nfoul offspring to our world! For all the\ndwellers in these nightmare dimensions\nare her descendants! Once all Runes of\nmagic power are united, the energy\nbehind them will blast open the Gateway\nto Shub-Niggurath, and you can travel\nthere to foil the Hell-Mother's plots\nin person.");
			return;
		}

        GotoNextMap();
	}
	
	if (intermission_running == 3)
	{
		if (!cvar("registered"))
		{	// shareware episode has been completed, go to sell screen
			WriteByte (#MSG_ALL, #SVC_SELLSCREEN);
			return;
		}
		
		if ( (serverflags&15) == 15)
		{
			WriteByte (#MSG_ALL, #SVC_FINALE);
			WriteString (#MSG_ALL, "Now, you have all four Runes. You sense\ntremendous invisible forces moving to\nunseal ancient barriers. Shub-Niggurath\nhad hoped to use the Runes Herself to\nclear off the Earth, but now instead,\nyou will use them to enter her home and\nconfront her as an avatar of avenging\nEarth-life. If you defeat her, you will\nbe remembered forever as the savior of\nthe planet. If she conquers, it will be\nas if you had never been born.");
			return;
		}
		
	}

	RPrint("Exit Intermission.\n");
	
    GotoNextMap();
};

/*
============
IntermissionThink

When the player presses attack or jump, change to the next level
============
*/
void() IntermissionThink =
{
	if (time < intermission_exittime)
		return;

	if (!self.button0 && !self.button1 && !self.button2)
		return;

#ifdef QUAKE_WORLD
	
	if (!triggered_cycle)
    {
        RPrint("Intermission think.\n");
        triggered_cycle = #TRUE;
        GotoNextMap();
    }
#else
	ExitIntermission ();
#endif
};

#ifndef QUAKE_WORLD
void() execute_changelevel =
{
	local entity	pos;

	intermission_running = 1;
	
// enforce a wait time before allowing changelevel
	if (deathmatch)
		intermission_exittime = time + 5;
	else
		intermission_exittime = time + 2;

// OfN TODO: remove this?

/*    WriteByte (#MSG_ALL, #SVC_CDTRACK);
	WriteByte (#MSG_ALL, 3);
	WriteByte (#MSG_ALL, 3);*/
	
	pos = FindIntermission ();

	other = find (world, classname, "player");
	while (other != world)
	{
		other.view_ofs = '0 0 0';
		other.angles = other.v_angle = pos.mangle;
		other.fixangle = #TRUE;		// turn this way immediately
		other.nextthink = time + 0.5;
		other.takedamage = #DAMAGE_NO;
		other.solid = #SOLID_NOT;
		other.movetype = #MOVETYPE_NONE;
		other.modelindex = 0;
		setorigin (other, pos.origin);
		other = find (other, classname, "player");
	}	

	WriteByte (#MSG_ALL, #SVC_INTERMISSION);
};

#else

void() PrintResults;

void() execute_changelevel =
{
	local entity	pos;
	RPrint("execute_changelevel()\n");

    PrintResults();

	intermission_running = 1;
	
	// enforce a wait time before allowing changelevel
	intermission_exittime = time + 5;

	pos = FindIntermission ();

	// play intermission music
	WriteByte (#MSG_ALL, #SVC_CDTRACK);
	WriteByte (#MSG_ALL, 3);

	WriteByte (#MSG_ALL, #SVC_INTERMISSION);
	WriteCoord (#MSG_ALL, pos.origin_x);
	WriteCoord (#MSG_ALL, pos.origin_y);
	WriteCoord (#MSG_ALL, pos.origin_z);
	WriteAngle (#MSG_ALL, pos.mangle_x);
	WriteAngle (#MSG_ALL, pos.mangle_y);
	WriteAngle (#MSG_ALL, pos.mangle_z);
	
	other = find (world, classname, "player");
	while (other != world)
	{
		other.takedamage = #DAMAGE_NO;
		other.solid = #SOLID_NOT;
		other.movetype = #MOVETYPE_NONE;
		other.modelindex = 0;
		other = find (other, classname, "player");
	}	

};
#endif

void() changelevel_touch =
{
	local entity pos;
	local float ne;
	local string st;

	if (other.classname != "player")
		return;

#ifndef QUAKE_WORLD
    if ((cvar("noexit") == 1) || ((cvar("noexit") == 2) && (mapname != "start")))
	{
		T_Damage (other, self, self, 50000);
		return;
	}
#else
	if (cvar("samelevel") == 2 || (cvar("samelevel") == 3 && mapname != "start"))
		return;
#endif

	bprint (#PRINT_HIGH, other.netname);
	bprint (#PRINT_HIGH, " exited the level\n");

	nextmap = self.map;

	SUB_UseTargets ();

	if ( (self.spawnflags & 1) && (deathmatch == 0) )
	{	// NO_INTERMISSION
		GotoNextMap();
		return;
	}
	
	self.touch = SUB_Null;

	// we can't move people right now, because touch functions are called
	// in the middle of C movement code, so set a think time to do it
	self.think = execute_changelevel;
	self.nextthink = time + 0.1;
};

/*QUAKED trigger_changelevel (0.5 0.5 0.5) ? NO_INTERMISSION
When the player touches this, he gets sent to the map listed in the "map" variable.  Unless the NO_INTERMISSION flag is set, the view will go to the info_intermission spot and display stats.
*/
void() trigger_changelevel =
{
	if (CheckExistence() == #FALSE)
	{
		dremove(self);
		return;
	}

	if (!self.map)
		objerror ("changelevel trigger doesn't have map");
	
	InitTrigger ();
	self.touch = changelevel_touch;
};


/*
=============================================================================

				PLAYER GAME EDGE FUNCTIONS

=============================================================================
*/

void() set_suicide_frame;

// called by ClientKill and DeadThink
void() respawn =
{
/*	if (!(self.done_custom == 0 || (self.done_custom & #CUSTOM_ON_SPAWN))) // do not spawn in prematch
		if (prematch < time)
		{
			sprint(self, #PRINT_HIGH, "Sorry, there are still ");
			sprint(self, #PRINT_HIGH, prematch - time);
			sprint(self, #PRINT_HIGH, " seconds of prematch remaining. Type custom to recreate your class.\n");
			return;
		}
*/		
	if (coop)
	{
		// make a copy of the dead body for appearances sake
		CopyToBodyQue (self);
		// get the spawn parms as they were at level start
		setspawnparms (self);
		// respawn		
		PutClientInServer ();
	}
	else if (deathmatch)
	{
		// make a copy of the dead body for appearances sake
		CopyToBodyQue (self);
		// set default spawn parms
		SetNewParms ();
		// respawn		
		PutClientInServer ();
	}
	else
	{	// restart the entire server
		localcmd ("restart\n");
	}
};

/*
============
ClientKill

Player entered the suicide command
============
*/
void() ClientKill =
{
	local float finished;
	local entity te;
	//WK Stop music
	sound (self, #CHAN_MUSIC, "items/r_item1.wav", 0.1, #ATTN_NORM);

	if (self.suicide_time > time)
		return;

	if (self.deadflag)
		return;

	// players can't suicide again for 10 seconds
	self.suicide_time = time + 5 + (random() * 5);

	//WK If building class, remove flag and start over
	if (self.playerclass == #PC_CUSTOM && (self.done_custom & #CUSTOM_BUILDING))
	{
		sprint(self, #PRINT_HIGH,"You can type 'custom' again to start over!\n");
		return;
		//WK self.done_custom = #CUSTOM_ON_SPAWN | #CUSTOM_FINISHED;
	}
	if (self.playerclass == #PC_UNDEFINED)
	{
		sprint(self, #PRINT_HIGH,"You aren't alive!\n");
		return;
	}

	if (prematch < time)
	{
		bprint (#PRINT_MEDIUM, self.netname);
		bprint (#PRINT_MEDIUM, " suicides\n");
	}

	set_suicide_frame();
	self.modelindex = modelindex_player;

	// If infected, give the medic a frag
	if (self.tfstate & #TFSTATE_INFECTED)
	{
		finished = #FALSE;
		te = find(world, classname, "timer");
		while (te)
		{
			if (te.owner == self && te.think == BioInfection_Decay)
			{
			#ifdef QUAKE_WORLD
				logfrag(te, self);
			#endif
				te.enemy.real_frags = te.enemy.real_frags + 1;
			 	if (!(toggleflags & #TFLAG_TEAMFRAGS))
					te.enemy.frags = te.enemy.real_frags;
				finished = #TRUE; //Thanks lostman
			}

			te = find(te, classname, "timer");
			if (finished) te = world;
		}
	}
#ifdef QUAKE_WORLD
	else 
		logfrag (self, self);
#endif

	self.real_frags = self.real_frags - 1;
	if (teamplay & #TEAMPLAY_VAMPIRE) //WK
		self.real_frags = self.real_frags - 1;

 	if (!(toggleflags & #TFLAG_TEAMFRAGS))
		self.frags = self.real_frags;

	self.weaponmodel= "";
	self.view_ofs = '0 0 -8';
	self.movetype = #MOVETYPE_NONE;

	//WK If building class, remove flag and start over
	if (self.playerclass == #PC_CUSTOM && (self.done_custom & #CUSTOM_BUILDING))
	{
		sprint(self, #PRINT_HIGH,"You can type 'custom' again to start over!\n");
		self.done_custom = #CUSTOM_ON_SPAWN | #CUSTOM_FINISHED;
		return; //ch
	}

	// Remove all timers for this player
	TeamFortress_RemoveTimers();
	TeamFortress_SetupRespawn(#TRUE);

	self.health = -1;
	self.th_die();
	self.deadflag = #DEAD_RESPAWNABLE;
	self.tfstate = self.tfstate | #TFSTATE_RESPAWN_READY;
//	self.respawn_time = time;
};

////////////////////////////////////
// FindTeamSpawnPoint
//////////
entity lastspawn_team1;
entity lastspawn_team2;
entity lastspawn_team3;
entity lastspawn_team4;

entity(float team_num) FindTeamSpawnPoint =
{
	local entity spot;
	local entity at_spot;
	local float spot_found;
	local float attempts;

	if (team_num == 1)
	{
		spot = lastspawn_team1;

		attempts = 0;
		// search through until found or end-of-list
		while (1)
		{
			attempts = attempts + 1;

			spot = find(spot, team_str_home, "ts1");

			if (spot == world)
				spot = find(world, team_str_home, "ts1");

			if (spot == world)
				return world;
		
			at_spot = findradius(spot.origin, 40);
			spot_found = #TRUE;

			while (at_spot != world)
			{
				if (at_spot.classname == "player" && at_spot.deadflag == #DEAD_NO)
				{
					spot_found = #FALSE;					
				}	
				
				at_spot = at_spot.chain;			
			}

			// Check the Criteria of the spawnpoint
			if (!Activated(spot, self))
				spot_found = #FALSE;

			if ((spot_found) || (attempts >= 30))
			{
				lastspawn_team1 = spot;
				return spot;
			}
		}

	}
	else if (team_num == 2)
	{
		spot = lastspawn_team2;

		attempts = 0;
		// search through until found or end-of-list
		while (1)
		{
			attempts = attempts + 1;

			spot = find(spot, team_str_home, "ts2");

			if (spot == world)
				spot = find(world, team_str_home, "ts2");

			if (spot == world)
				return world;
		
			at_spot = findradius(spot.origin, 40);
			spot_found = #TRUE;

			while (at_spot != world)
			{
				if (at_spot.classname == "player" && at_spot.deadflag == #DEAD_NO)
				{
					spot_found = #FALSE;					
				}	
				
				at_spot = at_spot.chain;			
			}

			// Check the Criteria of the spawnpoint
			if (!Activated(spot, self))
				spot_found = #FALSE;

			if ((spot_found) || (attempts >= 30))
			{
				lastspawn_team2 = spot;
				return spot;
			}
		}
	}
	else if (team_num == 3)
	{
		spot = lastspawn_team3;

		attempts = 0;
		// search through until found or end-of-list
		while (1)
		{
			attempts = attempts + 1;

			spot = find(spot, team_str_home, "ts3");

			if (spot == world)
				spot = find(world, team_str_home, "ts3");

			if (spot == world)
				return world;
		
			at_spot = findradius(spot.origin, 40);
			spot_found = #TRUE;

			while (at_spot != world)
			{
				if (at_spot.classname == "player" && at_spot.deadflag == #DEAD_NO)
				{
					spot_found = #FALSE;					
				}	
				
				at_spot = at_spot.chain;			
			}

			// Check the Criteria of the spawnpoint
			if (!Activated(spot, self))
				spot_found = #FALSE;

			if ((spot_found) || (attempts >= 30))
			{
				lastspawn_team3 = spot;
				return spot;
			}
		}
	}
	else if (team_num == 4)
	{
		spot = lastspawn_team4;

		attempts = 0;
		// search through until found or end-of-list
		while (1)
		{
			attempts = attempts + 1;

			spot = find(spot, team_str_home, "ts4");

			if (spot == world)
				spot = find(world, team_str_home, "ts4");

			if (spot == world)
				return world;
		
			at_spot = findradius(spot.origin, 40);
			spot_found = #TRUE;

			while (at_spot != world)
			{
				if (at_spot.classname == "player" && at_spot.deadflag == #DEAD_NO)
				{
					spot_found = #FALSE;					
				}	
				
				at_spot = at_spot.chain;			
			}

			// Check the Criteria of the spawnpoint
			if (!Activated(spot, self))
				spot_found = #FALSE;

			if ((spot_found) || (attempts >= 30))
			{
				lastspawn_team4 = spot;
				return spot;
			}
		}
	}

	// failure
	return world;
};

/*
============
SelectSpawnPoint

Returns the entity to spawn at
============
*/
entity() SelectSpawnPoint =
{
	local	entity spot;
	local 	entity at_spot;
	local 	float  spot_found;
	local   float  attempts;
	
	// testinfo_player_start is only found in regioned levels
	/*
	spot = find (world, classname, "testplayerstart");
	if (spot)
		return spot;
	*/

	// If FortressMap option is on, we want to make the player spawn on a 
	// spawnpoint marked as being one for his/her team.
	// The team that owns a spawnpoint is kept in the spawnpoints's teamno
	if (self.team_no != 0)
	{
		spot = FindTeamSpawnPoint(self.team_no);
		if (spot != world)
			return spot;

		// failure to find a team spawn point for that player
		// just move on
	}

	// choose a info_player_deathmatch point
	if (coop)
	{ 
		lastspawn = find(lastspawn, classname, "info_player_coop");
		if (lastspawn == world)
            lastspawn = find (world, classname, "info_player_coop");
                
        if (lastspawn != world)
        	return lastspawn;
	}
	else if (deathmatch)
	{
		// search through
		spot = find(lastspawn, classname, "info_player_deathmatch");
		if (spot == world)
			spot = find(world, classname, "info_player_deathmatch");

		attempts = 0;
		while (spot != world && attempts < 100)
		{
			attempts = attempts + 1;

			// reject spot if other players are found at point
			at_spot = findradius(spot.origin, 40);
			spot_found = #TRUE;
			while (at_spot)
			{
				if (at_spot.classname == "player" && at_spot.deadflag == #DEAD_NO)
				{
					spot_found = #FALSE;					
				}	
				
				at_spot = at_spot.chain;			
			}

			// Make sure we don't get locked by people standing on all
			// the spawnpoints.
			if ((spot_found) || (attempts >= 10))
			{
				lastspawn = spot;
				return spot;
			}
			
			spot = find(spot, classname, "info_player_deathmatch");	
			
			if (spot == world)
				spot = find(world, classname, "info_player_deathmatch");
		}
	}

	if (serverflags)
	{	// return with a rune to start
		spot = find (world, classname, "info_player_start2");
		if (spot)
			return spot;
	}
	
	spot = find (world, classname, "info_player_start");
	if (!spot)
		error ("PutClientInServer: no info_player_start on level\n");
	
	return spot;
};

/*
===========
PutClientInServer

called each time a player is spawned
============
*/
void() DecodeLevelParms;
void() PlayerDie;
void() TeamFortress_SetHealth;
void() TeamFortress_SetEquipment;
void() player_touch;
void(entity p) TeamFortress_SetSpeed;
void(entity p) TeamFortress_SetSkin;

void() PutClientInServer =
{
	local string st;
	local float iszoom, oldclass;
	local entity spot, te;

	self.touch = player_touch;
	self.classname = "player";
	if (self.playerclass != #PC_CUSTOM)
	{
		self.max_health = 100;
		self.health = 100;
	}
	
    //Check_Admin_Password(self); //CH check pass and sets flags
	
    self.takedamage = #DAMAGE_AIM;
	self.solid = #SOLID_SLIDEBOX;
	self.movetype = #MOVETYPE_WALK;
	self.show_hostile = 0;
	self.is_malfunctioning = 0;
	self.is_abouttodie = 0;

    // OfN
    self.has_holo = 0;
    self.is_killed = #FALSE;
    //////////////////
/*	if (self.is_cameraviewing)
		SwitchFromCamera();*/
	self.FlashTime = 0;
	self.flags = #FL_CLIENT;
  	self.aura = 0; //- OfN
    self.crusader_inspirator=world; // OfN - needed?
	self.gravity = 1; //WK
	self.air_finished = time + 12;
	self.dmg = 2;   		// initial water damage
	self.super_damage_finished = 0;
	self.radsuit_finished = 0;
	self.invisible_finished = 0;
	self.invincible_finished = 0;
	self.effects = 0;
	self.invincible_time = 0;
	self.reload_shotgun = 0;
	self.reload_super_shotgun = 0;
	self.reload_grenade_launcher = 0;
	self.reload_rocket_launcher = 0;
	self.reload_light_assault = 0;
    self.reload_laser_cannon = 0;
	
	//self.is_undercover = 0;
	//self.undercover_team = 0;
	self.last_attacked_time = 0; //WK For chaplan healing purposes

	makeImmune(self,time+5);

	// grapple stuff
	self.on_hook = #FALSE;
	self.hook_out = #FALSE;
	self.fire_held_down = #FALSE;

	DecodeLevelParms ();

#ifdef COOP_MODE
	// Force all players to be on the same team in Coop mode
	if (coop)
	{
		teamplay = 21;
		cvar_set("teamplay", "21?TeamFortress");
		TeamFortress_TeamSet(1);
	}
#endif

	// Set the Civilian Class of anyone in a Civilian Team
	if (self.playerclass == #PC_UNDEFINED)
	{
		if (TeamFortress_TeamIsCivilian(self.team_no))
		{
			self.impulse = 1;
			TeamFortress_ChangeClass();
		}
	}

	// For players who've changed their classes in deathmatch 3, 
	// their class may be PC_RANDOM, in which case we set the toggleflag
	if ((deathmatch == 3) && (self.nextpc != 0))
	{
		self.playerclass = self.nextpc;

		if (self.nextpc == #PC_RANDOM)
			self.tfstate = self.tfstate | #TFSTATE_RANDOMPC;
		else
			self.tfstate = self.tfstate - (self.tfstate & #TFSTATE_RANDOMPC);
	}

	// some states are kept
	iszoom = 0;

	if (self.tfstate & #TFSTATE_ZOOMOFF)
		iszoom = 1;

	// Reset all tfstate flags, except for RANDOMPC
	if (self.tfstate & #TFSTATE_RANDOMPC)
	{
		oldclass = self.playerclass;
		self.playerclass = 1 + floor(random() * (#PC_RANDOM - 1));
		while(!IsLegalClass(self.playerclass) || (self.playerclass == oldclass))
			self.playerclass = 1 + floor(random() * (#PC_RANDOM - 1));
		self.tfstate = #TFSTATE_RANDOMPC;
	}
	else
		self.tfstate = 0;

	if (iszoom == 1)
		self.tfstate = self.tfstate | #TFSTATE_ZOOMOFF;

	// Display the Player's Class
	if (!(self.done_custom == 0 || (self.done_custom & #CUSTOM_ON_SPAWN)))
	{
		if (self.playerclass != #PC_CUSTOM)
			TeamFortress_PrintClassName(self,self.playerclass, (self.tfstate & #TFSTATE_RANDOMPC));
		else 
			TeamFortress_PrintJobName(self,self.job);
	}
	// Set the weapons and ammo for the player based on class
	TeamFortress_SetEquipment();
	// Set the health for the player based on class
	TeamFortress_SetHealth();
	// Set the speed for the player based on class
	TeamFortress_SetSpeed(self);
	// Set the skin for the player based on class
	TeamFortress_SetSkin(self);
	stuffcmd(self, "v_idlescale 0\n");
	stuffcmd(self, "v_cshift 0 0 0 0\n");
	//WK Clear Bastard Rotation
	stuffcmd(self, "-left;-right;cl_yawspeed 140\n");

	//WK Again, since they could lose their sentrygun in SetEquip...
	DetonateAllGuns();


#ifdef QUAKE_WORLD
	SetTeamName(self);
#endif

	W_SetCurrentAmmo ();

	self.attack_finished = time + 0.3;

	self.th_pain = player_pain;
	self.th_die = PlayerDie;

	// make sure that autozoom is reset
	if (self.height != 0)
	{
		self.height = 0;
		TF_zoom(90);
	}
		
	self.deadflag = #DEAD_NO;
	// pausetime is set by teleporters to keep the player from moving a while
	self.pausetime = 0;
	
	spot = SelectSpawnPoint ();

	if (self.playerclass != #PC_UNDEFINED)
		spawn_tdeath (spot.origin, self);

	self.observer_list = spot;
	self.origin = spot.origin + '0 0 1';
	self.angles = spot.angles;
	self.fixangle = #TRUE;		// turn this way immediately

#ifdef MAP_DEBUG
	RPrint(self.netname);
	RPrint(" spawned at a ");
	RPrint(spot.classname);
	if (spot.team_no != 0)
	{
		RPrint(", team_no of ");
		st = ftos(spot.team_no);
		RPrint(st);
	}
	RPrint("\n");
#endif

	// If this is a TeamSpawnpoint, check to see if it
	// gives out a GoalItem, or displays a message
	if (spot.classname == "info_player_teamspawn")
	{
		if (spot.items != 0)
		{
			te = Finditem(spot.items);
			if (te)
				tfgoalitem_GiveToPlayer(te, self, self);

			if (!(spot.goal_activation & #TFSP_MULTIPLEITEMS))
				spot.items = 0;
		}

		// Display teamspawn message
		if (spot.message)
		{
			CenterPrint(self, spot.message);

			if (!(spot.goal_activation & #TFSP_MULTIPLEMSGS))
				spot.message = string_null;
		}

		// Activate a Goal if needed
		if (spot.activate_goal_no != 0)
		{
			te = Findgoal(spot.activate_goal_no);
			if (te)
				AttemptToActivate(te, self, spot);
		}

		// TeamSpawn points can remove themselves after being spawned on
		if (spot.goal_effects == #TFSP_REMOVESELF)
		{
			spot.classname = "deadpoint";
			spot.team_str_home = string_null;
			spot.nextthink = time + 1;
			spot.think = SUB_Remove;
		}
	}

#ifdef QUAKE_WORLD
	setmodel (self, string_null);
	modelindex_null = self.modelindex;
#endif

	setmodel (self, "progs/eyes.mdl");
	modelindex_eyes = self.modelindex;

	setmodel (self, "progs/player.mdl");
	modelindex_player = self.modelindex;

	if (self.playerclass == #PC_UNDEFINED)
	{
#ifdef QUAKE_WORLD
		self.modelindex = modelindex_null;
#else
		setmodel(self, string_null);
#endif
		self.current_menu = 1;
		self.gravity = 0;
	}
	
	//WK DropIntoCustomClassGeneration
	if (self.playerclass == #PC_CUSTOM)
	{
//WK Done_custom is initialized to 0, hackish yes.
//There are two entries, unintialized 0, or a person having issued a 'custom' command
//which sets the #CUSTOM_ON_SPAWN flag
		if (self.done_custom == 0 || (self.done_custom & #CUSTOM_ON_SPAWN))
		{
			DropToCustomClassGen();
		}
		else
		{
			self.maxspeed = self.custom_speed; //Reset our speed
		}
	}
	else {
		self.done_custom = 0; //Unitialize this. Maybe set to ON_SPAWN...
	}

	setsize (self, #VEC_HULL_MIN, #VEC_HULL_MAX);
	
	self.view_ofs = '0 0 22';

	player_stand1 ();

	if (deathmatch || coop)
	{
		makevectors(self.angles);
		if (self.playerclass != #PC_UNDEFINED)
			spawn_tfog (self.origin + v_forward*10);
	}

#ifdef QUAKE_WORLD
	// Set Rocket Jump Modifiers
	if (stof(infokey(world, "rj")) != 0)
		rj = stof(infokey(world, "rj"));
	else
		rj = 1;
#endif

	//This code is in three places. client,custom & tfort.qc
	//WK Give them invincibility if they are a normal class or bought it
	if ((self.playerclass >= #PC_SCOUT && self.playerclass <= #PC_RANDOM) ||
	self.tf_items & #NIT_RESPAWN_GUARD) {
		self.items = self.items + #IT_INVULNERABILITY;
		self.invincible_time = 1;
		self.invincible_finished = time + #RESPAWN_GUARD_TIME;
		if (self.custom_speed > 300)
			self.invincible_finished = self.invincible_finished - 1;			
		if (self.custom_speed > 400)
			self.invincible_finished = self.invincible_finished - 1;			
	}
};


/*
=============================================================================

				QUAKED FUNCTIONS

=============================================================================
*/


/*QUAKED info_player_start (1 0 0) (-16 -16 -24) (16 16 24)
The normal starting point for a level.
*/
void() info_player_start =
{
	if (CheckExistence() == #FALSE)
	{
		dremove(self);
		return;
	}
};


/*QUAKED info_player_start2 (1 0 0) (-16 -16 -24) (16 16 24)
Only used on start map for the return point from an episode.
*/
void() info_player_start2 =
{
	if (CheckExistence() == #FALSE)
	{
		dremove(self);
		return;
	}
};


/*
saved out by quaked in region mode
*/
void() testplayerstart =
{
	if (CheckExistence() == #FALSE)
	{
		dremove(self);
		return;
	}

};

/*QUAKED info_player_deathmatch (1 0 1) (-16 -16 -24) (16 16 24)
potential spawning position for deathmatch games
*/
void() info_player_deathmatch =
{
	if (CheckExistence() == #FALSE)
	{
		dremove(self);
		return;
	}
};

/*QUAKED info_player_coop (1 0 1) (-16 -16 -24) (16 16 24)
potential spawning position for coop games
*/
void() info_player_coop =
{
	if (CheckExistence() == #FALSE)
	{
		dremove(self);
		return;
	}
};

/*
===============================================================================

RULES

===============================================================================
*/

void(entity c) PrintClientScore =
{
	if (c.frags > -10 && c.frags < 0)
		bprint (#PRINT_MEDIUM, " ");
	else if (c.frags >= 0)
	{
		if (c.frags < 100)
			bprint (#PRINT_MEDIUM, " ");
		if (c.frags < 10)
			bprint (#PRINT_MEDIUM, " ");
	}
	bprint (#PRINT_MEDIUM, ftos(c.frags));
	bprint (#PRINT_MEDIUM, " ");
	bprint (#PRINT_MEDIUM, c.netname);
	bprint (#PRINT_MEDIUM, "\n");
};

void() DumpScore =
{
	local entity	e, sort, walk;

	if (world.chain)
		error ("DumpScore: world.chain is set");

// build a sorted lis
	e = find(world, classname, "player");
	sort = world;
	while (e)
	{
		if (!sort)
		{
			sort = e;
			e.chain = world;
		}
		else
		{
			if (e.frags > sort.frags)
			{
				e.chain = sort;
				sort = e;
			}
			else
			{
				walk = sort;
				do
				{
					if (!walk.chain)
					{
						e.chain = world;
						walk.chain = e;
					}
					else if (walk.chain.frags < e.frags)
					{
						e.chain = walk.chain;
						walk.chain = e;
					}
					else
						walk = walk.chain;
				} while (walk.chain != e);
			}
		}
		
		e = find(e, classname, "player");
	}

// print the list
	
	bprint (#PRINT_MEDIUM, "\n");	
	while (sort)
	{
		PrintClientScore (sort);
		sort = sort.chain;
	}
	bprint (#PRINT_MEDIUM, "\n");
};

/*
go to the next level for deathmatch
*/
float already_cycled;

void() NextLevel =
{
	local entity o;
	local string st;
	
	if (already_cycled)
		return;

	already_cycled = #TRUE;

	o = spawn();
	o.map = nextmap;
	o.think = execute_changelevel;
	o.nextthink = time + 0.1;
};

/*
============
CheckRules

Exit deathmatch games upon conditions
============
*/
void() CheckRules =
{
	if (timelimit && time >= timelimit)
		NextLevel ();
	else if (fraglimit && self.frags >= fraglimit)
		NextLevel ();
};

//============================================================================

void() PlayerDeathThink =
{
	local entity	old_self;
	local float		forward;

	if ((self.flags & #FL_ONGROUND))
	{
		forward = vlen (self.velocity);
		forward = forward - 20;
		if (forward <= 0)
			self.velocity = '0 0 0';
		else	
			self.velocity = forward * normalize(self.velocity);
	}

	// wait for all buttons released
	if (self.deadflag == #DEAD_DEAD)
	{
		if (self.button2 || self.button1 || self.button0)
			return;
		self.deadflag = #DEAD_RESPAWNABLE;
		// make sure that respawn flag has not been set
		self.tfstate = self.tfstate - (self.tfstate & #TFSTATE_RESPAWN_READY);
		return;
	}

	// wait for any button down
	if (!self.button2 && !self.button1 && !self.button0)
	{
		// if no buttons, but respawn_ready flag is set, respawn
		if (self.tfstate & #TFSTATE_RESPAWN_READY)
		{
			if (self.respawn_time <= time)
			{
				self.button0 = 0;
				self.button1 = 0;
				self.button2 = 0;
				respawn();
			}
		}
		return;
	}
	else
	{
		// button has been pressed, player is ready to respawn
		self.tfstate = self.tfstate | #TFSTATE_RESPAWN_READY;

		if (self.respawn_time <= time)
		{
			self.button0 = 0;
			self.button1 = 0;
			self.button2 = 0;
			respawn();
		}
		return;
	}
};

void() PlayerJump =
{
	local vector start, end;

	if (self.flags & #FL_WATERJUMP)
		return;

	if (self.waterlevel >= 2)
	{
		if (self.watertype == #CONTENT_WATER)
			self.velocity_z = 100;
		else if (self.watertype == #CONTENT_SLIME)
			self.velocity_z = 80;
		else
			self.velocity_z = 50;
		//WK
		if (self.tf_items & #NIT_SCUBA)
			self.velocity_z = 250;

// play swiming sound
		if (self.cutf_items & #CUTF_STEALTH) // SB no noise if we have stealth
			return;
		
		if (self.swim_flag < time)
		{
			self.swim_flag = time + 1;
			if (random() < 0.5)
				sound (self, #CHAN_BODY, "misc/water1.wav", 1, #ATTN_NORM);
			else
				sound (self, #CHAN_BODY, "misc/water2.wav", 1, #ATTN_NORM);
		}

		return;
	}

	if (!(self.flags & #FL_ONGROUND))
		return;

	if (!(self.flags & #FL_JUMPRELEASED) )
		return;		// don't pogo stick

	self.flags = self.flags - (self.flags & #FL_JUMPRELEASED);
	self.button2 = 0;
// player jumping sound
	if (!(self.cutf_items & #CUTF_STEALTH)) // Only play it if we don't have stealth
		sound (self, #CHAN_BODY, "player/plyrjmp8.wav", 1, #ATTN_NORM);

	//WK Sprinters jump higher
	//SB No, people with high jump do
	if (self.cutf_items & #CUTF_HIGHJUMP)
		self.velocity_z = self.velocity_z + 400;

#ifndef QUAKE_WORLD
	self.velocity_z = self.velocity_z + 270;
#endif
};


/*
===========
WaterMove

============
*/
.float	dmgtime;

void() WaterMove =
{
//  RPrint (ftos(self.waterlevel));
	if (self.movetype == #MOVETYPE_NOCLIP)
		return;
	if (self.health < 0)
		return;

	//WK Poison attacks
	if (self.tfstate & (#TFSTATE_HALLUCINATING | #TFSTATE_TRANQUILISED))
	{
		if (self.air_finished < time)
		{	// drown!
			if (self.pain_finished < time)
			{
				self.dmg = self.dmg + 0.5;
				if (self.dmg == 2.5) //Initial damage is 2
					sprint(self,#PRINT_HIGH,"Your lungs are still paralyzed. Try to minimize your exposure to poison\n");
				if (self.dmg > 6)
					self.dmg = 2.2;
				if (self.dmg < self.health - 1)
					TF_T_Damage (self, world, world, self.dmg, #TF_TD_IGNOREARMOUR, #TF_TD_OTHER);
				self.pain_finished = time + 1;
			}
		}
	}
	else if (self.waterlevel != 3)
	{
		if (self.air_finished < time)
			sound (self, #CHAN_VOICE, "player/gasp2.wav", 1, #ATTN_NORM);
		else if (self.air_finished < time + 9)
			sound (self, #CHAN_VOICE, "player/gasp1.wav", 1, #ATTN_NORM);
		self.air_finished = time + 12;
		self.dmg = 2;
	}
	else if (self.air_finished < time)
	{	// drown!
		if (self.pain_finished < time)
		{
			self.dmg = self.dmg + 2;
			if (self.dmg > 15)
				self.dmg = 10;
			TF_T_Damage (self, world, world, self.dmg, #TF_TD_IGNOREARMOUR, #TF_TD_OTHER);
			self.pain_finished = time + 1;
		}
	}
	
	if (!self.waterlevel)
	{
		if (self.flags & #FL_INWATER)
		{	
			// play leave water sound
			if (!(self.cutf_items & #CUTF_STEALTH)) // SB only if no stealth
				sound (self, #CHAN_BODY, "misc/outwater.wav", 1, #ATTN_NORM);
			self.flags = self.flags - #FL_INWATER;
			//WK Setspeed for Scuba commando
			if (self.tf_items & #NIT_SCUBA)
				TeamFortress_SetSpeed(self);
		}
		return;
	}

	if (self.watertype == #CONTENT_LAVA)
	{	// do damage
		if (self.dmgtime < time)
		{
			if (self.radsuit_finished > time)
				self.dmgtime = time + 1;
			else
				self.dmgtime = time + 0.2;

			// Asbestos armor helps against lava, but I doubt it'll save you :)
			TF_T_Damage (self, world, world, 10*self.waterlevel, 0, #TF_TD_FIRE);
		}
	}
	else if (self.watertype == #CONTENT_SLIME)
	{	// do damage
		if (self.dmgtime < time && self.radsuit_finished < time)
		{
			self.dmgtime = time + 1;
			//T_Damage (self, world, world, 4*self.waterlevel);
			TF_T_Damage (self, world, world, 4*self.waterlevel, 0, #TF_TD_ELECTRICITY);
		}
	}
	
	if ( !(self.flags & #FL_INWATER) )
	{	
		// player enter water sound
		if (!(self.cutf_items & #CUTF_STEALTH))
			if (self.watertype == #CONTENT_LAVA)
				sound (self, #CHAN_BODY, "player/inlava.wav", 1, #ATTN_NORM);
			else if (self.watertype == #CONTENT_WATER)
				sound (self, #CHAN_BODY, "player/inh2o.wav", 1, #ATTN_NORM);
			else if (self.watertype == #CONTENT_SLIME)
				sound (self, #CHAN_BODY, "player/slimbrn2.wav", 1, #ATTN_NORM);

		self.flags = self.flags + #FL_INWATER;
		self.dmgtime = 0;
		//WK Setspeed for scuba commando
		if (self.tf_items & #NIT_SCUBA)
			TeamFortress_SetSpeed(self);
	}

#ifndef QUAKE_WORLD	
	if (! (self.flags & #FL_WATERJUMP) )
		self.velocity = self.velocity - 0.8*self.waterlevel*frametime*self.velocity;
#endif
};

void() CheckWaterJump =
{
	local vector start, end;

	// check for a jump-out-of-water
	makevectors (self.angles);
	start = self.origin;
	start_z = start_z + 8; 
	v_forward_z = 0;
	normalize(v_forward);
	end = start + v_forward*24;
	traceline (start, end, #TRUE, self);
	if (trace_fraction < 1)
	{	// solid at waist
		start_z = start_z + self.maxs_z - 8;
		end = start + v_forward*24;
		self.movedir = trace_plane_normal * -50;
		traceline (start, end, #TRUE, self);
		if (trace_fraction == 1)
		{	// open at eye level
			self.flags = self.flags | #FL_WATERJUMP;
			self.velocity_z = 225;
			self.flags = self.flags - (self.flags & #FL_JUMPRELEASED);
			self.teleport_time = time + 2;	// safety net
			return;
		}
	}
};


/*
================
PlayerPreThink

Called every frame before physics are run
================
*/
void() PlayerPreThink =
{
	local float	mspeed, aspeed, r;
	local vector src;
	//WK -- For LPB calculation
	local string foo;
	local float ping;

	if (self.is_feigning && self.waterlevel == 1)
	{
		self.watertype = #CONTENT_WATER;
		self.waterlevel = 3;
	}

	if (self.cheat_level > 0)
		self.cheat_level = self.cheat_level - 1;
	if (self.speed_level > 0) //Cyto
		self.speed_level = self.speed_level - 1;
	if (intermission_running)
	{
		IntermissionThink ();	// otherwise a button could be missed between
		return;					// the think tics
	}

	makevectors (self.v_angle);		// is this still used?

#ifdef QUAKE_WORLD // culled by KK. was QUAKE_WORLD
	if (infokey(world,"ceasefire")=="on") //Cyto
	{
		#ifndef ceasefire_allows_to_move
        if (self.lip)
			self.origin = self.oldorigin;
		else
		{
			self.velocity_z = -5000;
			self.velocity_x = 0;
			self.velocity_y = 0;
			if (self.flags & #FL_ONGROUND)
			{
				self.oldorigin = self.origin;
				self.lip = #TRUE;
			}
		}
        #endif

		CenterPrint(self,"Ceasefire Applies");
	
    	if (!Good_Impulse(self.impulse)) //See admin.qc
	    	self.impulse = 0;

  		self.button0 = 0;
    	self.button1 = 0;
	    self.button2 = 0;
	}
    else if (self.lip)
	{
		self.lip = #FALSE;
		centerprint(self,"");
	}
#endif
// End Cyt0

	CheckRules ();

	//xxxx
	//WK Supercharged observer mode!
	if (self.playerclass == #PC_UNDEFINED)
	{
		if (self.button0)
		{
			//WK Nifty code to push through walls only if we really want to
			if (vlen(self.velocity) < 200)
			{
				src = self.origin + normalize(v_forward) * 5;
				setorigin(self,src);
			}
			self.velocity = normalize(v_forward) * 400;
		}
		else
		{
			foo = infokey(self,"ping");
			ping = 200;
			if (foo != string_null)
				ping = stof(foo);
			if (ping < 300) {
				self.velocity_x = floor((3 * self.velocity_x) / 4);
				self.velocity_y = floor((3 * self.velocity_y) / 4);
				self.velocity_z = floor((3 * self.velocity_z) / 4);
			}
		}
		if (self.button2)
			self.velocity = '0 0 0';
		return;
	//WK Removed jump == autoteam
	//WK Removed all the demo stuff stuff.
	}

	if (self.view_ofs == '0 0 0')
		return;		// intermission or finale

	if (self.playerclass != #PC_UNDEFINED)
		WaterMove();

#ifndef QUAKE_WORLD
	if (self.waterlevel == 2 && self.playerclass != #PC_UNDEFINED)
		CheckWaterJump ();
#endif

	if (self.deadflag >= #DEAD_DEAD)
	{
		PlayerDeathThink ();
		return;
	}

	if (self.undercover_team || self.undercover_skin || self.is_undercover)
	{
		if (self.effects & (#EF_DIMLIGHT | #EF_BRIGHTLIGHT))
		{
			sprint(self, #PRINT_MEDIUM, "The glowing removes your disguise.\n");
			Spy_RemoveDisguise(self);
		}
	}
	/*if (self.job & #JOB_THIEF && self.job & #JOB_FULL_HIDE) 
	{
		if (self.effects & (#EF_DIMLIGHT | #EF_BRIGHTLIGHT))
		{
			sprint(self, #PRINT_MEDIUM, "The glowing removes your full invisibility.\n");
			self.job = self.job - (self.job & #JOB_FULL_HIDE);
			self.job = self.job | #JOB_ACTIVE;
		}
	} */
	
	if (self.deadflag == #DEAD_DYING)
		return;	// dying, so do nothing

	if (!self.is_feigning)
	{
		if (self.button2)
		{
			PlayerJump (); //WK This just does noises for jumps
		}
		else
			self.flags = self.flags | #FL_JUMPRELEASED;
	}

	//WK Scuba commando treads water :)
	if ((self.tf_items & #NIT_SCUBA) && self.waterlevel > 1) {
		if (self.velocity_z >= -25 && self.velocity_z < 0)
			self.velocity_z = 10; //Tread water if near a stop
	}
	
	//Jello Water :)
	else if (jello && self.waterlevel > 1) {
		if (jello == #TRUE) //Binary on/off
			self.velocity_z = 1000; //900 is a better number for 2forts
		else
			self.velocity_z = jello;
	}

	// teleporters can force a non-moving pause time	
	if (time < self.pausetime)
		self.velocity = '0 0 0';

 	if (time > self.attack_finished && self.currentammo == 0 && self.weapon > #WEAP_AXE)
 	{
 		self.weapon = W_BestWeapon ();
 		W_SetCurrentAmmo ();
 	}

    // Do grapple stuff if I'm on a hook
	if (self.on_hook)
	{
		Service_Grapple ();
		if (self.button2 && self.velocity_z > 10)
			self.velocity_z = 10;	//WK Allow more creative physics with hook
	}
	
	//WK Add Hover Boot Support
	if (self.tf_items & #NIT_HOVER_BOOTS) {
		if (self.button2 && self.velocity_z < 0 && self.hover_time > 0 && self.waterlevel == 0)
		{ 	//Try to hover
			self.velocity_z = 100; //+10 == hover
			self.hover_time = self.hover_time - 0.25; //0.1 == tick time
			if (self.hover_time <= 0) {
				self.hover_time = -5; //3 second penalty for draining it
				sprint(self,#PRINT_HIGH,"Your boots are out of fuel, let them recharge\n");
			}
			//Spit out fire from them!
			if (self.search_time < time) {
			sound (self, #CHAN_AUTO, "weapons/flmfire2.wav", 1, #ATTN_NORM);
			local entity flame;
			flame = spawn();
			flame.owner = self;flame.movetype = #MOVETYPE_FLYMISSILE;
			flame.solid = #SOLID_BBOX;flame.classname = "flamerflame";
			makevectors (self.v_angle);
			flame.velocity = -1 * v_up; flame.velocity = flame.velocity * 600;
			flame.touch = Boot_Flamer_stream_touch;flame.think = s_explode1;
			flame.nextthink = time + 0.1;setmodel (flame, "progs/s_explod.spr");
			setsize (flame, '0 0 0', '0 0 0');
			setorigin (flame, self.origin + v_up * -16);
			self.search_time = time + 0.15;
			}
		}
		else { //Recharger <- That's French for "recharge"
			self.hover_time = self.hover_time + 0.01; //0.05 is a half-tick
			if (self.hover_time > #MAX_HOVER_FUEL && (!(self.tf_items & #NIT_HOVER_BOOTS_UPGRADE)))
				self.hover_time = #MAX_HOVER_FUEL;
			if (self.hover_time > (#MAX_HOVER_FUEL * 2) && self.tf_items & #NIT_HOVER_BOOTS_UPGRADE)
				self.hover_time = (#MAX_HOVER_FUEL * 2);
		}
	}
};
	
/*
================
CheckPowerups

Check for turning off powerups
================
*/
void() CheckPowerups =
{
	local float lighton;
	local entity te;

	if (self.health <= 0)
		return;

    // Invisibility
	//WK Made people invis during building, and during thief's full hide
	//WK And while being inspired by chaplan
	if (self.done_custom & #CUSTOM_BUILDING || //We are building a custom class
          self.playerclass == #PC_UNDEFINED || //Or we're in observer mode
         (self.job & #JOB_THIEF && self.job & #JOB_FULL_HIDE) || //Or we are fully hiding thieves
	   //(self.tfstate & #TFSTATE_INSPIRED && !(self.job & #JOB_CHAPLAN)) || //ofN comented by
       self.aura == #AURA_INVIS) //- OfN
	{
		self.modelindex = modelindex_null;	// don't use eyes
    }
	else if ((self.is_undercover == 1 && invis_only == #TRUE) || (self.job & #JOB_THIEF && self.job & #JOB_ACTIVE))
	{
		self.frame = 0;
		self.modelindex = modelindex_eyes;
	}
	else if (self.invisible_finished)
	{
		// If this is being given by a goalitem, extend the time
		if (self.tfstate & #TFSTATE_INVISIBLE)
		{
			if (self.invisible_finished < time + 10)
				self.invisible_finished = time + 666;
		}

		// sound and screen flash when items starts to run out
		if (self.invisible_sound < time)
		{
			sound (self, #CHAN_AUTO, "items/inv3.wav", 0.5, #ATTN_IDLE);
			self.invisible_sound = time + ((random() * 3) + 1);
		}


		if (self.invisible_finished < time + 3)
		{
			if (self.invisible_time == 1)
			{
				sprint(self, #PRINT_HIGH, "Ring of Shadows magic is fading\n");
				stuffcmd (self, "bf\n");
				sound (self, #CHAN_AUTO, "items/inv2.wav", 1, #ATTN_NORM);
				self.invisible_time = time + 1;
			}
			
			if (self.invisible_time < time)
			{
				self.invisible_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}

		if (self.invisible_finished < time)
		{	// just stopped
			self.items = self.items - #IT_INVISIBILITY;
			self.invisible_finished = 0;
			self.invisible_time = 0;
		}
		
		// use the eyes
		self.frame = 0;
		self.modelindex = modelindex_eyes;
	}
	else
		self.modelindex = modelindex_player;	// don't use eyes

	// invincibility
	if (self.invincible_finished)
	{
		// If this is being given by a goalitem, extend the time
		if (self.tfstate & #TFSTATE_INVINCIBLE)
		{
			if (self.invincible_finished < time + 10)
				self.invincible_finished = time + 666;
		}

		// sound and screen flash when items starts to run out
		if (self.invincible_finished < time + 3)
		{
			if (self.invincible_time == 1)
			{
				sprint (self, #PRINT_HIGH, "Protection is almost burned out\n");

				stuffcmd (self, "bf\n");
				sound (self, #CHAN_AUTO, "items/protect2.wav", 1, #ATTN_NORM);
				self.invincible_time = time + 1;
			}
			
			if (self.invincible_time < time)
			{
				self.invincible_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}
		
		if (self.invincible_finished < time)
		{	// just stopped
			self.items = self.items - #IT_INVULNERABILITY;
			self.invincible_time = 0;
			self.invincible_finished = 0;
		}
		if (self.invincible_finished > time)
			self.effects = self.effects | #EF_DIMLIGHT;
		else
		{
			// Only remove dimlight if it's not being supplied by a GoalItem
			lighton = #FALSE;
			te = find (world, classname, "item_tfgoal");
			while (te)
			{
				if (te.owner == self)
				{
					if (te.goal_activation & #TFGI_GLOW)
						lighton = #TRUE;
				}
				te = find(te, classname, "item_tfgoal");
			}

			if (!lighton)
				self.effects = self.effects - (self.effects & #EF_DIMLIGHT);
		}
	}

	// super damage
	if (self.super_damage_finished)
	{
		// If this is being given by a goalitem, extend the time
		if (self.tfstate & #TFSTATE_QUAD)
		{
			if (self.super_damage_finished == time + 10)
				self.super_damage_finished = time + 666;
		}

		// sound and screen flash when items starts to run out
		if (self.super_damage_finished < time + 3 && !(self.tfstate & #TFSTATE_INSPIRED))
		{
			if (self.super_time == 1)
			{
				sprint (self, #PRINT_HIGH, "Quad Damage is wearing off\n");
				stuffcmd (self, "bf\n");
				sound (self, #CHAN_AUTO, "items/damage2.wav", 1, #ATTN_NORM);
				self.super_time = time + 1;
			}	  
			
			if (self.super_time < time)
			{
				self.super_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}

		if (self.super_damage_finished < time)
		{	// just stopped
			self.items = self.items - #IT_QUAD;
			self.super_damage_finished = 0;
			self.super_time = 0;
			//WK If inspired, remove inspiration
			self.tfstate = self.tfstate - (self.tfstate & #TFSTATE_INSPIRED);
		}
		if (self.super_damage_finished > time)
			self.effects = self.effects | #EF_DIMLIGHT;
		else
		{
			// Only remove dimlight if it's not being supplied by a GoalItem
			lighton = #FALSE;
			te = find (world, classname, "item_tfgoal");
			while (te)
			{
				if (te.owner == self)
				{
					if (te.goal_activation & #TFGI_GLOW)
						lighton = #TRUE;
				}
				te = find(te, classname, "item_tfgoal");
			}

			if (!lighton)
				self.effects = self.effects - (self.effects & #EF_DIMLIGHT);
		}
	}	

	// suit	
	if (self.radsuit_finished)
	{
		self.air_finished = time + 12;		// don't drown

		// If this is being given by a goalitem, extend the time
		if (self.tfstate & #TFSTATE_RADSUIT || self.tf_items & #NIT_SCUBA)
		{
//WK Do we need this?	if (self.radsuit_finished == time + 10)
				self.radsuit_finished = time + 666;
		}

		// sound and screen flash when items starts to run out
		if (self.radsuit_finished < time + 3)
		{
			if (self.rad_time == 1)
			{
				sprint (self, #PRINT_HIGH, "Air supply in Biosuit expiring\n");
				stuffcmd (self, "bf\n");
				sound (self, #CHAN_AUTO, "items/suit2.wav", 1, #ATTN_NORM);
				self.rad_time = time + 1;
			}
			
			if (self.rad_time < time)
			{
				self.rad_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}

		if (self.radsuit_finished < time)
		{	// just stopped
			self.items = self.items - #IT_SUIT;
			self.rad_time = 0;
			self.radsuit_finished = 0;
		}
	}	

    if (self.aura == #AURA_INVIS)
        if (self.aura_time < time)
        {
            if (self.invisible_finished < time)
                self.items = self.items - (self.items & #IT_INVISIBILITY);
            self.aura = 0;
        }

};

void() DeadImpulses;

/*
================


Called every frame after physics are run
================
*/
void() PlayerPostThink =
{
	local	float	mspeed, aspeed;
	local	float	r;

	if (self.view_ofs == '0 0 0')
		return;		// intermission or finale
#ifdef QUAKE_WORLD // culled by KK. was QUAKE_WORLD
	if (infokey(world,"ceasefire")=="on") //Cyto
		if (!Good_Impulse(self.impulse)) //See admin.qc
			self.impulse = 0;
#endif
	if (self.deadflag)
	{
		DeadImpulses();	 // check for dead-only commands
		self.impulse = 0;
		return;
	}

	// check to see if player landed and play landing sound	
	if (self.takedamage && (self.jump_flag < -300) && (self.flags & #FL_ONGROUND) && (self.health > 0))
	{
		if (self.watertype == #CONTENT_WATER)
		{
			if (!(self.cutf_items & #CUTF_STEALTH))
				sound (self, #CHAN_BODY, "player/h2ojump.wav", 1, #ATTN_NORM);
		}
		else if (self.jump_flag < -650)
		{
			if (!(self.cutf_items & #CUTF_STEALTH)) { //WK Judo teaches falling... SB ceaf judo
				self.deathtype = "falling";
				T_Damage (self, world, world, 5); 
				sound (self, #CHAN_VOICE, "player/land2.wav", 1, #ATTN_NORM);
			}
		}
		else
			if (!(self.cutf_items & #CUTF_STEALTH)) //WK Judo teaches falling... SB ceaf judo
				sound (self, #CHAN_VOICE, "player/land.wav", 1, #ATTN_NORM);
	}


	self.jump_flag = self.velocity_z;

	CheckPowerups ();

	W_WeaponFrame ();

	//  Display MOTD
	// Sync this with tforthlp.qc and menu.qc
	if (self.motd < #MOTD_FINISHED)
		TeamFortress_MOTD();
	else if (self.cheat_check == 0)
		self.cheat_check = time + 10;
#ifdef STATUSBAR
	else if (time > self.StatusRefreshTime && self.StatusBarSize != 0)
	{
		if (self.StatusBarScreen == 1)
			RefreshStatusBar1(self); //Sentry screen
		else if (self.StatusBarScreen == 2)
			RefreshStatusBar2(self); //Spy screen
		else if (self.StatusBarScreen == 3)
			RefreshStatusBar3(self); //Misc screen
		else if (self.StatusBarScreen == 4)
			RefreshStatusBar4(self); //Tesla screen
		else if (self.StatusBarScreen == 5)
			RefreshStatusBar5(self); //Scanner screen
		else
			RefreshStatusBar(self); //Normal scores and clip
	}
#endif

	// Check for Team Cheats
	if (self.cheat_check <= time)
	{
		TeamFortress_CheckTeamCheats();

	#ifdef QUAKE_WORLD
		self.cheat_check = time + 5;
	#else
		self.cheat_check = time + 1;
	#endif
	}
};


/*
===========
ClientConnect

called when a player connects to a server
============
*/
void() ClientConnect =
{
	local string st;

	bprint (#PRINT_HIGH, self.netname);
	bprint (#PRINT_HIGH, " has joined the server\n");
    
    //- OfN - shouldnt be needed anyway...
    self.admin_kick = world;

	// Set Default autozoom
	if (#DEFAULT_AUTOZOOM == #OFF)
		self.tfstate = self.tfstate | #TFSTATE_ZOOMOFF;

	// Set the MOTD on
	self.motd = 0;
	// Clear the Alias Flag
	self.got_aliases = 0;
	self.ff_count = 0; //WK Clear the friendly-fire counter


#ifdef QUAKE_WORLD
//RJM
	st = infokey(self, "sbr");
	if (st == string_null)
//RJM
		st = infokey(self, "sbar_res");
	if (st == "768")
		self.StatusBarRes = 8;
	else if (st == "600")
		self.StatusBarRes = 7;
	else if (st == "480")
		self.StatusBarRes = 6;
	else if (st == "400")
		self.StatusBarRes = 5;
	else if (st == "384")
		self.StatusBarRes = 4;
	else if (st == "350")
		self.StatusBarRes = 3;
	else if (st == "300")
		self.StatusBarRes = 2;
	else if (st == "240")
		self.StatusBarRes = 1;
	else 
		self.StatusBarRes = 0;
//RJM
	st = infokey(self, "sbs");
	if (st == string_null)
//RJM
		st = infokey(self, "sbar_size");
	self.StatusBarSize = stof(st);
	if (self.StatusBarSize > 2 || self.StatusBarSize < 0)
		self.StatusBarSize = 0;
#endif

	self.has_disconnected = #FALSE;

	//PlayerObserverMode(); //ofn already commented out
	
    self.gravity = 0;
	self.movetype = #MOVETYPE_FLY;

	// a client connecting during an intermission can cause problems
	if (intermission_running)
		GotoNextMap();


    //- OfN
    if (mapname == "huntedr")
    {
        local float result;
        result = floor(TeamFortress_TeamGetNoPlayers(2) * #HUNTED_YELLOWTEAM_FACTOR);
        team3maxplayers = result;
        if (team3maxplayers < 1) team3maxplayers = 1;
    }
};

/*
===========
ClientDisconnect

called when a player disconnects from a server
============
*/
void() ClientDisconnect =
{
	local float teamsup;
	local entity te;

#ifndef QUAKE_WORLD
	if (gameover)
		return;
#endif

    local string st;

    st = ftos (floor(self.real_frags));
	bprint (#PRINT_HIGH, self.netname);
	bprint (#PRINT_HIGH, " has left the game with ");
    bprint (#PRINT_HIGH, st);
    bprint (#PRINT_HIGH, " frags and ");

    st = ftos (floor(self.ff_count));
    bprint (#PRINT_HIGH, st);
    bprint (#PRINT_HIGH, " teamkills\n");

    //- he got significant score?
    /*local float temp_scr;
    local float avr_team_scr;
    avr_team_scr = (team1score + team2score + team3score + team4score) / number_of_teams;
    temp_scr = fabs (self.real_frags) + self.ff_count;
    
    if ( (temp_scr > time || time > 20) && time < 60*60 && deathmatch == 3) 
    {
        local float final_score;
        final_score = self.real_frags - self.ff_count*3 - avr_team_scr/2 ;
        
        if ( final_score < -50 )
            bprint (#PRINT_HIGH, "bad enough to ban him! hehe\n");
        else if (final_score < 0)
            bprint (#PRINT_HIGH, "damn newbie!\n");
        else if (final_score < 10)
            bprint (#PRINT_HIGH, "he was not doing much\n");
        else if (final_score < 30)
            bprint (#PRINT_HIGH, "a regular player\n");
        else if (final_score < 50)
            bprint (#PRINT_HIGH, "not bad!\n");
        else if (final_score < 75)
            bprint (#PRINT_HIGH, "good score\n");
        else if (final_score < 100)
            bprint (#PRINT_HIGH, "cool score!\n");
        else if (final_score < 125)
            bprint (#PRINT_HIGH, "he is a real master of customTF!\n");
        else bprint (#PRINT_HIGH, "omg! did he cheat? awesome score!\n");
    }*/

    //- OfN
    if (mapname == "huntedr")
    {
        local float result;
        result = floor(TeamFortress_TeamGetNoPlayers(2) * #HUNTED_YELLOWTEAM_FACTOR);
        team3maxplayers = result;
        if (team3maxplayers < 1) team3maxplayers = 1;
    }

	sound (self, #CHAN_BODY, "player/tornoff2.wav", 1, #ATTN_NONE);
	self.has_disconnected = #TRUE;

    if (debug_target == self)
        debug_target = world;

	// Remove Timers
	TeamFortress_RemoveTimers();

	// Remove Buildings
	DetonateAllGunsForced();
    /*Find_And_Dmg("building_dispenser", self, 1);
	Find_And_Dmg("building_sentrygun", self, 1);
	Find_And_Dmg("building_tesla", self, 1);
	Find_And_Dmg("building_camera", self, 1);
	Find_And_Dmg("building_teleporter", self, 1);
	Find_And_Dmg("building_sensor", self, 1); //sb*/

	//WK Added demon cleanup
	kill_my_demon();
	//WK Added ammobox/pipebomb fix
	te = find(world, classname, "ammobox");
	while (te)
	{
		if (te.enemy == self) {
			num_world_ammoboxes = num_world_ammoboxes - 1;
			if (te.enemy.team_no != 0)
				decrement_team_ammoboxes(self.team_no);
			
		}
		te.think = SUB_Remove;
		te.nextthink = time + 0.1;

		te = find(te, classname, "ammobox");
	}
	te = find(world, classname, "pipebomb");
	while (te)
	{
		if (te.owner == self) {
			num_world_pipebombs = num_world_pipebombs - 1;
			decrement_team_pipebombs(self.team_no);		
			te.think = SUB_Remove;
			te.nextthink = time + 0.1;
		}

		te = find(te, classname, "pipebomb");
	}

    // OfN - Remove holograph if player disconnects!
    if (self.has_holo > 0 ) RemoveHolo(self);
    DetonateMines(self);  
    RemoveArmyTimer();

	// Remove Detpacks
	te = find(world, classname, "detpack");
	while (te)
	{
		if (te.owner == self)
		{
			if (te.weaponmode == 1)     	  // Detpack was being disarmed
			{   
				te.enemy.tfstate = te.enemy.tfstate - (te.enemy.tfstate & #TFSTATE_CANT_MOVE);
		#ifdef QUAKE_WORLD
				TeamFortress_SetSpeed(te.enemy);
		#else
				te.enemy.pausetime = time;		
		#endif

				dremove(te.oldenemy);  	 // CountDown
				dremove(te.observer_list); //	Disarm timer
			}

			dremove(te);
			te = world;
		}

		te = find(te, classname, "detpack");
	}

	set_suicide_frame ();
	self.netname = string_null;
	self.team_no = 0;
	self.solid = #SOLID_NOT;
	self.movetype = #MOVETYPE_NONE; //WK Stop crashing MOVETYPE_WALK bug?
	setsize(self, '0 0 0', '0 0 0');
};

/*
===========
ClientObituary
	
called when a player dies
============
*/
void(entity targ, entity attacker) ClientObituary =
{
	local float rnum;
	local string deathstring, deathstring2;
	local float attackerteam, targteam;
	local entity te;
	local entity oself;

    // FIXME:

	//- OfN - Unidentified kill ---------//
    deathstring=" is killed by ";
    deathstring2="\n";
    // I still have no idea when this is used
    //-----------------------------------//
    
    if (prematch >= time)
		return;
	
	rnum = random();
	    
    if (targ.classname == "player")
	{
        //WK No Obituary for the cursed!
		if (targ.penance_time > time - 1)
		{
			Give_Frags_Out(targ, targ, -1, 0, 1, 1, 0);
/*			targ.real_frags = targ.real_frags - 1;
 			if (!(toggleflags & #TFLAG_TEAMFRAGS))
				targ.frags = targ.real_frags;
*/			return;
		}
		
		if (targ.martyr_enemy != targ)
			deathmsg = targ.stored_deathmsg;

        if (deathmsg==#DMSG_CYBERNET)
        {
	    	//local string tst;            
            //tst=GetBuildingName(attacker);
            
            //if (rnum < 0.5)
            //{
                bprint (#PRINT_MEDIUM, targ.netname);
                bprint (#PRINT_MEDIUM, " will abort the hack next time\n");
                //bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
        	    //bprint (#PRINT_MEDIUM, "'s hack-protected");
                //bprint (#PRINT_MEDIUM, tst);
			    //bprint (#PRINT_MEDIUM, "\n");
            //}
            /*else
            {
                bprint (#PRINT_MEDIUM, targ.netname);
                bprint (#PRINT_MEDIUM, " has been lost in the cybernet!\n");*/
                //bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
            	//bprint (#PRINT_MEDIUM, "'s ");
                //bprint (#PRINT_MEDIUM, tst);
    			//bprint (#PRINT_MEDIUM, "\n");
            //}
            /*else
            {
                bprint (#PRINT_MEDIUM, targ.netname);
                bprint (#PRINT_MEDIUM, " dies hacking a \n");
                //bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
            	//bprint (#PRINT_MEDIUM, "'s ");
                bprint (#PRINT_MEDIUM, tst);
    			bprint (#PRINT_MEDIUM, "\n");
            }*/

	    	Give_Frags_Out(targ, targ, -1, 0, 1, 1, 0);

            return;
        }
        
        if (deathmsg==#DMSG_ANTIHACK)
        {
	    	local string tst;            
            tst=GetBuildingName(attacker);
            
            if (rnum < 0.5)
            {
                bprint (#PRINT_MEDIUM, targ.netname);
                bprint (#PRINT_MEDIUM, " is electrocuted trying to hack ");
                bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
        	    bprint (#PRINT_MEDIUM, "'s ");
                bprint (#PRINT_MEDIUM, tst);
			    bprint (#PRINT_MEDIUM, "\n");
            }
            else
            {
                bprint (#PRINT_MEDIUM, targ.netname);
                bprint (#PRINT_MEDIUM, " should never tried to hack ");
                bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
            	bprint (#PRINT_MEDIUM, "'s ");
                bprint (#PRINT_MEDIUM, tst);
    			bprint (#PRINT_MEDIUM, "\n");
            }

	    	Give_Frags_Out(targ, targ, -1, 0, 1, 1, 0);

            return;
        }

        if (deathmsg==#DMSG_ANTIDISM)
        {
	    	local string tst;            
            tst=GetBuildingName(attacker);


            if (rnum < 0.5)
            {
                bprint (#PRINT_MEDIUM, targ.netname);
                bprint (#PRINT_MEDIUM, " tries to dismantle ");
                bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
        	    bprint (#PRINT_MEDIUM, "'s ");
                bprint (#PRINT_MEDIUM, tst);
			    bprint (#PRINT_MEDIUM, " with the wrong tool\n");
            }
            else
            {
                bprint (#PRINT_MEDIUM, targ.netname);
                bprint (#PRINT_MEDIUM, " is electrocuted trying to dismantle ");
                bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
            	bprint (#PRINT_MEDIUM, "'s ");
                bprint (#PRINT_MEDIUM, tst);
    			bprint (#PRINT_MEDIUM, "\n");
            }

	    	Give_Frags_Out(targ, targ, -1, 0, 1, 1, 0);

            return;
        }

        //- OfN - Wizard death stuff
        if (attacker.classname == "monster_wizard")
		{
			custom_demon_name(attacker); //CH
			//If our own demon killed us, kill demon and cost 2 frags
			if (attacker.real_owner == targ) {
				Give_Frags_Out(attacker.real_owner, attacker.real_owner, -2, 0, 1, 1, 0);
                
                bprint (#PRINT_MEDIUM, "The scrag ");
                bprint (#PRINT_MEDIUM, attacker.netname);
				bprint (#PRINT_MEDIUM, " kills his owner, ");
				bprint (#PRINT_MEDIUM, targ.netname);
				bprint (#PRINT_MEDIUM, "\n");

  				//kill_my_demon(); //Demon dies too
				return;

            } 
            else if ((!Teammate(targ.team_no,attacker.real_owner.team_no)) || attacker.real_owner.team_no < 1)
            {
				if ( rnum > 0.6)
                {
                    bprint (#PRINT_MEDIUM, targ.netname);
                	bprint (#PRINT_MEDIUM, " was nullified by the scrag ");
                	bprint (#PRINT_MEDIUM, attacker.netname);
                	bprint (#PRINT_MEDIUM, " (");
                	bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
                	bprint (#PRINT_MEDIUM, ")\n");
                }
                else if (rnum > 0.3)
                {
                    bprint (#PRINT_MEDIUM, targ.netname);
                	bprint (#PRINT_MEDIUM, " didn't survive ");
                	bprint (#PRINT_MEDIUM, attacker.netname);
                	bprint (#PRINT_MEDIUM, "'s (");
                	bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
                	bprint (#PRINT_MEDIUM, ") acid\n");

                }
                else
                {
                	bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
                    bprint (#PRINT_MEDIUM, "'s scrag, ");
                    bprint (#PRINT_MEDIUM, attacker.netname);
                    bprint (#PRINT_MEDIUM, ", removes ");
                    bprint (#PRINT_MEDIUM, targ.netname);
              	  	bprint (#PRINT_MEDIUM, "\n");                	
                }                

      			Give_Frags_Out(attacker.real_owner, attacker.real_owner, 1, 0, 1, 1, 0);

                return;
            }
            else if (Teammate(targ.team_no,attacker.real_owner.team_no))
            {
            	if (rnum < 0.5)
                {
                    bprint (#PRINT_MEDIUM, "The supposed friendly scrag ");
                    bprint (#PRINT_MEDIUM, attacker.netname);
                    bprint (#PRINT_MEDIUM, " (");
                    bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
                    bprint (#PRINT_MEDIUM, ")");
                    bprint (#PRINT_MEDIUM, " killed ");
                    bprint (#PRINT_MEDIUM, targ.netname);
                    bprint (#PRINT_MEDIUM, "\n");
                }
                else
                {
                    //bprint (#PRINT_MEDIUM, "");
                    bprint (#PRINT_MEDIUM, attacker.netname);
                    bprint (#PRINT_MEDIUM, " (");
                    bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
                    bprint (#PRINT_MEDIUM, ") proves that scrags are able to teamkill with ");
                    bprint (#PRINT_MEDIUM, targ.netname);
                    bprint (#PRINT_MEDIUM, "'s help\n");
                }
      			//Give_Frags_Out(attacker.real_owner, attacker.real_owner, -1, 0, 1, 1, 0);

                return;
            }
        }     


        //WK
		if (attacker.classname == "monster_demon1")
		{
			custom_demon_name(attacker); //CH
			//If our own demon killed us, kill demon and cost 2 frags
			if (attacker.real_owner == targ) {
				Give_Frags_Out(attacker.real_owner, attacker.real_owner, -2, 0, 1, 1, 0);

/*				attacker.real_owner.real_frags = attacker.real_owner.real_frags - 2;
				if (!(toggleflags & #TFLAG_TEAMFRAGS))
					attacker.real_owner.frags = attacker.real_owner.real_frags;
*/
				if (deathmsg == #DMSG_DEMON_FIRE)
				{
					bprint (#PRINT_MEDIUM, attacker.netname);
					bprint (#PRINT_MEDIUM, " threw his rage to his owner ");
					bprint (#PRINT_MEDIUM, targ.netname);
					bprint (#PRINT_MEDIUM, "\n");
				}
				else
				{
					if (rnum < 0.5) {
						bprint (#PRINT_MEDIUM, attacker.netname);
						bprint (#PRINT_MEDIUM, " exacts revenge on its summoner, ");
						bprint (#PRINT_MEDIUM, targ.netname);
						bprint (#PRINT_MEDIUM, "\n");
					}
					else {
						bprint (#PRINT_MEDIUM, targ.netname);
						bprint (#PRINT_MEDIUM, " is dragged into the pit by his own demon, ");
						bprint (#PRINT_MEDIUM, attacker.netname);
						bprint (#PRINT_MEDIUM, "\n");
					}
				}

				//kill_my_demon(); //Demon dies too
				return;
			}
			if (deathmsg == #DMSG_DEMON_FIRE)
			{
				if (rnum < 0.2) {
					bprint (#PRINT_MEDIUM, targ.netname);
					bprint (#PRINT_MEDIUM, " was burned alive by ");
					bprint (#PRINT_MEDIUM, attacker.netname);
					bprint (#PRINT_MEDIUM, " (");
					bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
					bprint (#PRINT_MEDIUM, ")\n");
				}
				else if (rnum < 0.5) {
					bprint (#PRINT_MEDIUM, targ.netname);
					bprint (#PRINT_MEDIUM, " thought he was safe from ");
					bprint (#PRINT_MEDIUM, attacker.netname);
					bprint (#PRINT_MEDIUM, " (");
					bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
					bprint (#PRINT_MEDIUM, ")\n");
				}
				else if (rnum < 0.75) {
					bprint (#PRINT_MEDIUM, targ.netname);
					bprint (#PRINT_MEDIUM, " died from ");
					bprint (#PRINT_MEDIUM, attacker.netname);
					bprint (#PRINT_MEDIUM, "'s (");
					bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
					bprint (#PRINT_MEDIUM, ") fire balls\n");
				}
				else {
					bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
					bprint (#PRINT_MEDIUM, "'s demon, ");
					bprint (#PRINT_MEDIUM, attacker.netname);
					bprint (#PRINT_MEDIUM, ", burned ");
					bprint (#PRINT_MEDIUM, targ.netname);
					bprint (#PRINT_MEDIUM, " to a crisp\n");
				}
			}
			else
			{
				if (rnum < 0.1) {
					bprint (#PRINT_MEDIUM, targ.netname);
					bprint (#PRINT_MEDIUM, " was eviscerated by ");
					bprint (#PRINT_MEDIUM, attacker.netname);
					bprint (#PRINT_MEDIUM, " (");
					bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
					bprint (#PRINT_MEDIUM, ")\n");
				}
				else if (rnum < 0.50) {
					bprint (#PRINT_MEDIUM, targ.netname);
					bprint (#PRINT_MEDIUM, " was ripped limb from limb by ");
					bprint (#PRINT_MEDIUM, attacker.netname);
					bprint (#PRINT_MEDIUM, " (");
					bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
					bprint (#PRINT_MEDIUM, ")\n");
				}
				else {
					bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
					bprint (#PRINT_MEDIUM, "'s demon, ");
					bprint (#PRINT_MEDIUM, attacker.netname);
					if (rnum < 0.75)
						bprint (#PRINT_MEDIUM, ", claws apart ");
					else
						bprint (#PRINT_MEDIUM, ", rends apart ");
					bprint (#PRINT_MEDIUM, targ.netname);
					bprint (#PRINT_MEDIUM, "\n");
				}
			}

		 	if (!Teammate(targ.team_no,attacker.real_owner.team_no) || attacker.real_owner.team_no < 1)
				Give_Frags_Out(attacker.real_owner, attacker.real_owner, 1, 0, 1, 1, 0);

/*				attacker.real_owner.real_frags = attacker.real_owner.real_frags + 1;
			if (!(toggleflags & #TFLAG_TEAMFRAGS))
				attacker.real_owner.frags = attacker.real_owner.real_frags;
*/
			return;
		}

		// Grunt demon death stuff

		if (attacker.classname == "monster_army") //SB-1 Tech - Share and Enjoy!
		{
		custom_demon_name(attacker); //CH
		GetRank(attacker); // Sponsored by SB-1 Tech
			//If our own demon killed us, kill demon and cost 2 frags
			if (attacker.real_owner == targ)
			{
				Give_Frags_Out(attacker.real_owner, attacker.real_owner, -2, 0, 1, 1, 0);

/*				attacker.real_owner.real_frags = attacker.real_owner.real_frags - 2;
				if (!(toggleflags & #TFLAG_TEAMFRAGS))
					attacker.real_owner.frags = attacker.real_owner.real_frags;
*/
				/*if (rnum < 0.5)
				{
					bprint (#PRINT_MEDIUM, attacker.undercover_name);
					bprint (#PRINT_MEDIUM, attacker.netname);
					bprint (#PRINT_MEDIUM, " greets his client ");
					bprint (#PRINT_MEDIUM, targ.netname);
					bprint (#PRINT_MEDIUM, " with a bullet in the back of the head\n");
				}
				else
				{*/
					bprint (#PRINT_MEDIUM, targ.netname);
					bprint (#PRINT_MEDIUM, " is killed by his own mercenary ");
					bprint (#PRINT_MEDIUM, attacker.undercover_name);
					bprint (#PRINT_MEDIUM, attacker.netname);
					bprint (#PRINT_MEDIUM, "\n");
				//}
				return;
			}
                   
			if (Teammate(targ.team_no, attacker.real_owner.team_no))
			{
				bprint (#PRINT_MEDIUM, attacker.undercover_name);
 				if (rnum < 0.25)
 				{
					bprint (#PRINT_MEDIUM, attacker.netname);
					bprint (#PRINT_MEDIUM, " mows down a teammate\n");
 				}
 				else if (rnum < 0.50)
 				{
 					bprint (#PRINT_MEDIUM, attacker.netname);
					bprint (#PRINT_MEDIUM, " checks his glasses\n");
				}
 				else if (rnum < 0.75)
 				{
					bprint (#PRINT_MEDIUM, attacker.netname);
					bprint (#PRINT_MEDIUM, " gets a frag for the other team\n");
				}
 				else
				{
					bprint (#PRINT_MEDIUM, attacker.netname);
					bprint (#PRINT_MEDIUM, " loses another friend\n");
				}
				return;
			}
			if (deathmsg == #DMSG_AXE)
			{
				if (attacker.cutf_items & #CUTF_KNIFE)
				{
					bprint (#PRINT_MEDIUM, targ.netname);
					bprint (#PRINT_MEDIUM, " is sliced and diced by ");
					bprint (#PRINT_MEDIUM, attacker.undercover_name);
					bprint (#PRINT_MEDIUM, attacker.netname);
					bprint (#PRINT_MEDIUM, "'s (");
					bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
					bprint (#PRINT_MEDIUM, ") blade\n");
				}
				else
				{
					bprint (#PRINT_MEDIUM, targ.netname);
					bprint (#PRINT_MEDIUM, " is split in two by a powerful axe blow from ");
					bprint (#PRINT_MEDIUM, attacker.undercover_name);
					bprint (#PRINT_MEDIUM, attacker.netname);
					bprint (#PRINT_MEDIUM, " (");
					bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
					bprint (#PRINT_MEDIUM, ")\n");
				}
			}
			else if (deathmsg == #DMSG_BACKSTAB)
			{
				bprint (#PRINT_MEDIUM, targ.netname);
				bprint (#PRINT_MEDIUM, " is filleted by ");
				bprint (#PRINT_MEDIUM, attacker.undercover_name);
				bprint (#PRINT_MEDIUM, attacker.netname);
				bprint (#PRINT_MEDIUM, " (");
				bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
				bprint (#PRINT_MEDIUM, ")\n");
			}
			else if (deathmsg == #DMSG_SHOTGUN)
			{
				bprint (#PRINT_MEDIUM, targ.netname);
				bprint (#PRINT_MEDIUM, " practices being ");
				bprint (#PRINT_MEDIUM, attacker.undercover_name);
				bprint (#PRINT_MEDIUM, attacker.netname);
				bprint (#PRINT_MEDIUM, "'s (");
				bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
				bprint (#PRINT_MEDIUM, ") clay pigeon\n");
			}
			else if (deathmsg == #DMSG_NAILGUN)
			{
				bprint (#PRINT_MEDIUM, targ.netname);
				bprint (#PRINT_MEDIUM, " is turned into ");
				bprint (#PRINT_MEDIUM, attacker.undercover_name);
				bprint (#PRINT_MEDIUM, attacker.netname);
				bprint (#PRINT_MEDIUM, "'s (");
				bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
				bprint (#PRINT_MEDIUM, ") pincushion\n");
			}
			else if (deathmsg == #DMSG_ROCKETL)
			{
				bprint (#PRINT_MEDIUM, attacker.undercover_name);
				bprint (#PRINT_MEDIUM, attacker.netname);
				bprint (#PRINT_MEDIUM, " declares that ");
				bprint (#PRINT_MEDIUM, targ.netname);
				bprint (#PRINT_MEDIUM, " IS the rocket man\n");
			}
			else if (deathmsg == #DMSG_SSHOTGUN)
			{
				bprint (#PRINT_MEDIUM, targ.netname);
				bprint (#PRINT_MEDIUM, " is turned into swiss cheese by ");
				bprint (#PRINT_MEDIUM, attacker.undercover_name);
				bprint (#PRINT_MEDIUM, attacker.netname);
				bprint (#PRINT_MEDIUM, "'s (");
				bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
				bprint (#PRINT_MEDIUM, ") buckshot\n");
			}
			
		 	if (!Teammate(targ.team_no,attacker.real_owner.team_no) || attacker.real_owner.team_no < 1)
			{
				Give_Frags_Out(attacker.real_owner, attacker.real_owner, 1, 0, 1, 1, 0);
				Give_Frags_Out(attacker, attacker, 1, 0, 1, 1, 0);
			}
/*				attacker.real_owner.real_frags = attacker.real_owner.real_frags + 1;
			if (!(toggleflags & #TFLAG_TEAMFRAGS))
				attacker.real_owner.frags = attacker.real_owner.real_frags;
*/
			return;
		}

		if (attacker.classname == "monster_shambler")
		{
		custom_demon_name(attacker); //CH
			//If our own demon killed us, kill demon and cost 2 frags
			if (attacker.real_owner == targ) {
				Give_Frags_Out(attacker.real_owner, attacker.real_owner, -2, 0, 1, 1, 0);

/*				attacker.real_owner.real_frags = attacker.real_owner.real_frags - 2;
				if (!(toggleflags & #TFLAG_TEAMFRAGS))
					attacker.real_owner.frags = attacker.real_owner.real_frags;
*/
				if (deathmsg == #DMSG_LIGHTNING)
				{
					bprint (#PRINT_MEDIUM, attacker.netname);
					bprint (#PRINT_MEDIUM, " annihilates its owner ");
					bprint (#PRINT_MEDIUM, targ.netname);
					bprint (#PRINT_MEDIUM, " with a bolt of lightning\n");
				}
				else if (deathmsg == #DMSG_DEMON_FIRE)
				{
					bprint (#PRINT_MEDIUM, attacker.netname);
					bprint (#PRINT_MEDIUM, " detonates its owner ");
					bprint (#PRINT_MEDIUM, targ.netname);
					bprint (#PRINT_MEDIUM, " with a fireball\n");
				}
				else
				{
					if (rnum < 0.5) {
						bprint (#PRINT_MEDIUM, attacker.netname);
						bprint (#PRINT_MEDIUM, " gets sick of its owner ");
						bprint (#PRINT_MEDIUM, targ.netname);
						bprint (#PRINT_MEDIUM, "\n");
					}
					else {
						bprint (#PRINT_MEDIUM, targ.netname);
						bprint (#PRINT_MEDIUM, " screams as ");
						bprint (#PRINT_MEDIUM, attacker.netname);
						bprint (#PRINT_MEDIUM, " turns on his owner\n");
					}
				}

				//kill_my_demon(); //Demon dies too - OfN nope!
				return;
			}
			if (deathmsg == #DMSG_LIGHTNING)
			{
				if (rnum < 0.2) {
					bprint (#PRINT_MEDIUM, targ.netname);
					bprint (#PRINT_MEDIUM, "'s body crackles with electricity as ");
					bprint (#PRINT_MEDIUM, attacker.netname);
					bprint (#PRINT_MEDIUM, " (");
					bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
					bprint (#PRINT_MEDIUM, ") claims another victim\n");
				}
				else if (rnum < 0.5) {
					bprint (#PRINT_MEDIUM, targ.netname);
					bprint (#PRINT_MEDIUM, " meets a bolt of lightning directed by ");
					bprint (#PRINT_MEDIUM, attacker.netname);
					bprint (#PRINT_MEDIUM, " (");
					bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
					bprint (#PRINT_MEDIUM, ")\n");
				}
				else if (rnum < 0.75) {
					bprint (#PRINT_MEDIUM, targ.netname);
					bprint (#PRINT_MEDIUM, "'s goose is cooked by ");
					bprint (#PRINT_MEDIUM, attacker.netname);
					bprint (#PRINT_MEDIUM, "'s (");
					bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
					bprint (#PRINT_MEDIUM, ") lightning\n");
				}
				else {
					bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
					bprint (#PRINT_MEDIUM, "'s shambler, ");
					bprint (#PRINT_MEDIUM, attacker.netname);
					bprint (#PRINT_MEDIUM, ", teaches ");
					bprint (#PRINT_MEDIUM, targ.netname);
					bprint (#PRINT_MEDIUM, " to cook without gas\n");
				}
			}
			else if (deathmsg == #DMSG_DEMON_FIRE)
			{
				if (rnum < 0.5)
				{
					bprint (#PRINT_MEDIUM, targ.netname);
					bprint (#PRINT_MEDIUM, " is obliterated by ");
					bprint (#PRINT_MEDIUM, attacker.netname);
					bprint (#PRINT_MEDIUM, " (");
					bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
					bprint (#PRINT_MEDIUM, ")'s fireball\n");
				}
				else
				{
					bprint (#PRINT_MEDIUM, targ.netname);
					bprint (#PRINT_MEDIUM, " is turned into little ");
					bprint (#PRINT_MEDIUM, targ.netname);
					bprint (#PRINT_MEDIUM, "s by ");
					bprint (#PRINT_MEDIUM, attacker.netname);
					bprint (#PRINT_MEDIUM, " (");
					bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
					bprint (#PRINT_MEDIUM, ")'s fireball\n");
				}
			}
			else
			{
				if (rnum < 0.02)
				{
					bprint (#PRINT_MEDIUM, targ.netname);
					bprint (#PRINT_MEDIUM, " screams as ");
					bprint (#PRINT_MEDIUM, attacker.netname);
					bprint (#PRINT_MEDIUM, " (");
					bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
					bprint (#PRINT_MEDIUM, ")'s claws slash down\n");
				}
				else if (rnum < 0.1) {
					bprint (#PRINT_MEDIUM, targ.netname);
					bprint (#PRINT_MEDIUM, " was torn asunder by ");
					bprint (#PRINT_MEDIUM, attacker.netname);
					bprint (#PRINT_MEDIUM, " (");
					bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
					bprint (#PRINT_MEDIUM, ")\n");
				}
				else if (rnum < 0.50) {
					bprint (#PRINT_MEDIUM, targ.netname);
					bprint (#PRINT_MEDIUM, " is smashed into next week by ");
					bprint (#PRINT_MEDIUM, attacker.netname);
					bprint (#PRINT_MEDIUM, " (");
					bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
					bprint (#PRINT_MEDIUM, ")\n");
				}
				else {
					bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
					bprint (#PRINT_MEDIUM, "'s shambler, ");
					bprint (#PRINT_MEDIUM, attacker.netname);
					if (rnum < 0.75)
						bprint (#PRINT_MEDIUM, ", tears ");
					else
						bprint (#PRINT_MEDIUM, ", rips ");
					bprint (#PRINT_MEDIUM, targ.netname);
					bprint (#PRINT_MEDIUM, " to shreds\n");
				}
			}

		 	if (!Teammate(targ.team_no,attacker.real_owner.team_no) || attacker.real_owner.team_no < 1)
				Give_Frags_Out(attacker.real_owner, attacker.real_owner, 1, 0, 1, 1, 0);

/*				attacker.real_owner.real_frags = attacker.real_owner.real_frags + 1;
			if (!(toggleflags & #TFLAG_TEAMFRAGS))
				attacker.real_owner.frags = attacker.real_owner.real_frags;
*/
			return;
		}
		
		if (attacker.classname == "teledeath")
		{
			bprint (#PRINT_MEDIUM, targ.netname);
			bprint (#PRINT_MEDIUM, " was telefragged by ");
			bprint (#PRINT_MEDIUM, attacker.owner.netname);
			bprint (#PRINT_MEDIUM, "\n");

		 	if (!Teammate(targ.team_no,attacker.owner.team_no) || attacker.owner.team_no < 1)
				Give_Frags_Out(attacker.owner, attacker.owner, 1, 0, 1, 1, 0);

/*				attacker.owner.real_frags = attacker.owner.real_frags + 1;
			if (!(toggleflags & #TFLAG_TEAMFRAGS))
				attacker.owner.frags = attacker.owner.real_frags;
*/
			return;
		}

		if (attacker.classname == "teledeath2")
		{
			bprint (#PRINT_MEDIUM, "Satan's power deflects ");
			bprint (#PRINT_MEDIUM, targ.netname);
			bprint (#PRINT_MEDIUM, "'s telefrag\n");

			Give_Frags_Out(targ, targ, -1, 1, 1, 1, 0);

/*			targ.real_frags = targ.real_frags - 1;
 			if (!(toggleflags & #TFLAG_TEAMFRAGS))
				targ.frags = targ.real_frags;
			
#ifdef QUAKE_WORLD
			logfrag (targ, targ);
#endif
*/
			return;
		}

		// Killed by a goal
		if (attacker.classname == "info_tfgoal")
		{
			if (attacker.deathtype != "")
			{
				bprint (#PRINT_MEDIUM, targ.netname);
				bprint (#PRINT_MEDIUM, attacker.deathtype);
			}
#ifdef QUAKE_WORLD
			logfrag (targ, targ);
#endif
			return;
		}

		if (attacker.classname == "player")
		{
			if (targ == attacker)
			{
				// killed self
				Give_Frags_Out(attacker, attacker, -1, 0, 1, 1, 1);

/*				attacker.real_frags = attacker.real_frags - 1;
				if (teamplay & #TEAMPLAY_VAMPIRE) //WK
					attacker.real_frags = attacker.real_frags - 1;

	 			if (!(toggleflags & #TFLAG_TEAMFRAGS))
					attacker.frags = attacker.real_frags;
*/
				bprint (#PRINT_MEDIUM, targ.netname);
				
				deathstring = " kills himself!\n";

				if (deathmsg == #DMSG_GREN_HAND)
					deathstring = " grenades himself\n";
				else if (deathmsg == #DMSG_MARTYR) 
                {
					
                   	//if (rnum <= 0.5)
						deathstring = " dies for the cause\n";
					//else
					//	deathstring = " is persecuted to death\n";
					
                    /*
                    //if (!(targ.job & #JOB_MARTYR_ENEMY)) {
					    if (rnum <= 0.5)
						    deathstring = " dies for the heck of it\n";
					    else
						    deathstring = " dies with style\n";
				    
					else {
						//Give last person who attacked him a frag
						if (targ.martyr_enemy.classname == "player" && targ.martyr_enemy.has_disconnected == #FALSE) {
							Give_Frags_Out(targ.martyr_enemy, targ, 1, 1, 1, 1, 0);
						}
						if (rnum <= 0.5)
							deathstring = " dies for the cause\n";
						else
							deathstring = " is persecuted to death\n";
					} */
				}
                /*else if (deathmsg == #DMSG_EXPBODY) - OfN - No need!
                {
                    deathstring = "'s body explodes!\n";
                }*/
				else if (deathmsg == #DMSG_BERSERK)
				{
					if (rnum < 0.5)
						deathstring = " collapses from exhaustion\n";
					else
						deathstring = " goes down fighting\n";
				}
				else if (deathmsg == #DMSG_GREN_NAIL)
					deathstring = " hammers himself\n";
				else if (deathmsg == #DMSG_GREN_FRAG)
					deathstring = " fragments himself\n";
				else if (deathmsg == #DMSG_LAND_MINE)
					deathstring = " forgot where he put his minefield\n";
				else if (deathmsg == #DMSG_GREN_MIRV)
					deathstring = " goes to pieces\n";
				else if (deathmsg == #DMSG_GREN_PIPE)
					deathstring = " ambushes himself with his own pipebombs\n";
				else if (deathmsg == #DMSG_GREN_GAS)
					deathstring = " chokes on his own gas\n";
				else if (deathmsg == #DMSG_GREN_EMP)
					deathstring = " explodes his ammo and body\n";
				else if (deathmsg == #DMSG_GREN_FLASH)
					deathstring = " is charred by his own flash grenade\n";
				else if (deathmsg == #DMSG_GREN_EMP_AMMO)
					deathstring = " detonates an ammo box too close to him\n";
				else if (deathmsg == #DMSG_DETPACK)
					deathstring = " set the detpack and forgot to run\n";
				else if (deathmsg == #DMSG_BIOWEAPON)
					deathstring = " died by his own infection!\n";

                else if (deathmsg == #DMSG_FORCEFIELD)
					deathstring = " is fried in his own force field\n";
                else if (deathmsg == #DMSG_STUCK_FORCEFIELD)
					deathstring = " is caught and shocked to death in his own force field\n";
                else if (deathmsg == #DMSG_SPANNERFIELD)
					deathstring = " learns something about spanners and force fields...\n";

				else if (deathmsg == #DMSG_MAUSER)
					deathstring = " assassinated himself!\n";
				else if (deathmsg == #DMSG_DAEDALUS)
					deathstring = " flew too close to the sun!\n";
				else if (deathmsg == #DMSG_AIRG || deathmsg == #DMSG_AIRG_WATER)
					deathstring = " Airfists his own ass!\n";
                else if (deathmsg == #DMSG_JUDOKA)
					deathstring = " broke his own arms!\n";
				else if (deathmsg == #DMSG_AXE)
					deathstring = " drove an axe through his own head!\n";
				else if (deathmsg == #DMSG_BACKSTAB)
					deathstring = " drove a knife into his own heart!\n";
    
                else if (deathmsg == #DMSG_FGTRAP)
    				deathstring = " explodes with his own (trapped) field generator!\n";

				else if (deathmsg == #DMSG_CALTROP)
					deathstring = " stepped on too many of his own caltrops\n";
   				else if (deathmsg == #DMSG_FLYCALTROP)
					deathstring = " was spiked by his own catlrop\n";
                else if (deathmsg == #DMSG_ROCKETL)
				{
					if (rnum < 0.5)
						deathstring = " becomes bored with life\n";
					else
						deathstring = " checks if his weapon is loaded\n";
				}
                else if (deathmsg == #DMSG_CLUSTER_ROCKET)
                    deathstring = " eats his clusters\n";                
                else if (deathmsg == #DMSG_LASERCANNON)
                    deathstring = " blasts himself\n";                    
				else if (deathmsg == #DMSG_INCENDIARY)
					deathstring = " chars himself with an incendiary rocket\n";
				else if (deathmsg == #DMSG_GRENADEL)
					deathstring = " tries to put the pin back in\n";
				else if (deathmsg == #DMSG_FLAME)
					deathstring = " torches himself\n";
				else if (deathmsg == #DMSG_HOVER) //WK
					deathstring = " dies from uncomfortable boots\n";
				else if (deathmsg == #DMSG_LIGHTNING)
					deathstring = " electrocutes himself\n";
				else if (deathmsg == #DMSG_LIGHTNING && targ.waterlevel > 1)
				{
					bprint (#PRINT_MEDIUM, " discharges into the water.\n");
					return;
				}
				
				bprint(#PRINT_MEDIUM, deathstring);
				return;
			}
			else if (teamplay && Teammate(targ.team_no,attacker.team_no))
			{
				// killed a team member
				if (Teammate(targ.team_no,attacker.team_no) )
					Give_Frags_Out(attacker, attacker, -1, 0, 1, 1, 0);
//					attacker.real_frags = attacker.real_frags - 1; // killed a team member
				else
					Give_Frags_Out(attacker, attacker, 1, 0, 1, 1, 0);
//					attacker.real_frags = attacker.real_frags + 1;

//			 	if (!(toggleflags & #TFLAG_TEAMFRAGS))
//					attacker.frags = attacker.real_frags;
				if (deathmsg == #DMSG_MEDIKIT)
				{
	 				bprint (#PRINT_MEDIUM, targ.netname);
 					bprint (#PRINT_MEDIUM, " didn't survive the operation.\n");
					return;
				}

                if (deathmsg == #DMSG_EXPBODY) //- OfN
				{
	 				bprint (#PRINT_MEDIUM, targ.netname);
 					bprint (#PRINT_MEDIUM, " has been killed as a side effect of ");
   					bprint (#PRINT_MEDIUM, attacker.netname);
                    bprint (#PRINT_MEDIUM, "'s body explosion\n");
                    return;
				}

 				if (rnum < 0.25)
 				{
 					bprint (#PRINT_MEDIUM, attacker.netname);
 					bprint (#PRINT_MEDIUM, " mows down teammate ");
 					bprint (#PRINT_MEDIUM, targ.netname);
 				}
 				else if (rnum < 0.50)
 				{
 					bprint (#PRINT_MEDIUM, attacker.netname);
 					bprint (#PRINT_MEDIUM, " checks his glasses after killing ");
 					bprint (#PRINT_MEDIUM, targ.netname);
 				}
 				else if (rnum < 0.75)
 				{
 					bprint (#PRINT_MEDIUM, attacker.netname);
 					bprint (#PRINT_MEDIUM, " gets a frag for the other team with ");
 					bprint (#PRINT_MEDIUM, targ.netname);
 					bprint (#PRINT_MEDIUM, "'s death");
 				}
 				else
 				{
 					bprint (#PRINT_MEDIUM, targ.netname);
 					bprint (#PRINT_MEDIUM, " doesn't wuv ");
 					bprint (#PRINT_MEDIUM, attacker.netname);
 					bprint (#PRINT_MEDIUM, " any more! Wah!");
 				}

				bprint (#PRINT_MEDIUM, "\n");						
				return;
			}
			else
			{
				Give_Frags_Out(attacker, targ, 1, 1, 1, 1, 1);
//CH
//				attacker.real_frags = attacker.real_frags + 1;
				if (attacker.tfstate & #TFSTATE_INSPIRED) {
					attacker.inspirator.real_frags =
					attacker.inspirator.real_frags + 0.5;
				 	if (!(toggleflags & #TFLAG_TEAMFRAGS))
						attacker.inspirator.frags =
						attacker.inspirator.real_frags;
				}

                if (attacker.aura && attacker.crusader_inspirator != world)
				{
					attacker.crusader_inspirator.real_frags = attacker.crusader_inspirator.real_frags + 0.5;
				 	if (!(toggleflags & #TFLAG_TEAMFRAGS))
						attacker.crusader_inspirator.frags = attacker.crusader_inspirator.real_frags;
				}

				//WK
/*				if (teamplay & #TEAMPLAY_VAMPIRE) //Frag vamp
					targ.real_frags = targ.real_frags - 1;

				#ifdef QUAKE_WORLD
					logfrag (attacker, targ);
				#endif

			 	if (!(toggleflags & #TFLAG_TEAMFRAGS)) {
					attacker.frags = attacker.real_frags;
					targ.frags = targ.real_frags; //In case of vampire
				}
                
*/
                if (deathmsg == #DMSG_CLUSTER_ROCKET)
                {
                    if (rnum < 0.5)
                    {
                        deathstring = " is put away by ";
    	    		    deathstring2 = "'s cluster rockets\n";
                    }
                    else
                    {
                        deathstring = " is destroyed by ";
    	    		    deathstring2 = "'s cluster rockets\n";
                    }
                }
                else if (deathmsg == #DMSG_EXPBODY)
                {
                    deathstring = " is killed by ";
	    		    deathstring2 = "'s body explosion\n";
                }    
				else if (deathmsg == #DMSG_GREN_HAND)
				{
					deathstring = " surfs on a grenade from ";
					deathstring2 = "\n";
				}
				else if (deathmsg == #DMSG_GREN_NAIL)
				{
					deathstring = " gets flayed by ";
					deathstring2 = "'s nail grenade\n";
				}
				else if (deathmsg == #DMSG_GREN_FRAG) //WK
				{
					if (rnum < 0.5) {
						deathstring = " is slashed apart by ";
						deathstring2 = "'s frag grenade\n";
					}
					else if (rnum < 0.75) {
						deathstring = "'s jugular artery is severed by ";
						deathstring2 = "'s frag grenade.\n";
					}
					else {
						deathstring = "'s carotoid artery is severed by ";
						deathstring2 = "'s frag grenade.\n";
					}
				}
				else if (deathmsg == #DMSG_GREN_MIRV)
				{
					deathstring = " gets spammed by ";
					deathstring2 = "'s Mirv grenade\n";
				}
				else if (deathmsg == #DMSG_CALTROP)
				{
					deathstring = " collects one too many of ";
					deathstring2 = "'s caltrops\n";
				}
                else if (deathmsg == #DMSG_FLYCALTROP)
				{
					deathstring = " was spiked by ";
					deathstring2 = "'s caltrops\n";
				}
				else if (deathmsg == #DMSG_GREN_PIPE)
				{
					deathstring = " is caught by ";
					deathstring2 = "'s pipebomb trap\n";
				}
				else if (deathmsg == #DMSG_GREN_GAS)
				{
					deathstring = " gags on ";
					deathstring2 = "'s noxious gasses\n";
				}
				else if (deathmsg == #DMSG_GREN_EMP)
				{
					deathstring = "'s ammo detonates him as ";
					deathstring2 = "'s EMP fries it.\n";
				}
				else if (deathmsg == #DMSG_GREN_FLASH)
				{
					deathstring = " is charred by ";
					deathstring2 = "'s flash grenade.\n";
				}
				else if (deathmsg == #DMSG_GREN_EMP_AMMO)
				{
					deathstring = " stands near some ammo as ";
					deathstring2 = "'s EMP nukes it\n";
				}
				else if (deathmsg == #DMSG_DETPACK)
				{
					deathstring = " reaches orbit via ";
					deathstring2 = "'s detpack\n";
				}
				else if (deathmsg == #DMSG_DETPACK_DIS)
				{
					deathstring = " cut the red wire of ";
					deathstring2 = "'s detpack\n";
				}
				else if (deathmsg == #DMSG_BIOWEAPON)
				{
					deathstring = " dies from ";
					deathstring2 = "'s mysterious tropical disease\n";			
				}
				else if (deathmsg == #DMSG_MAUSER)
				{
				/*	deathstring = " is assassinated by ";
					deathstring2 = "'s Mauser WK-77\n";	*/
					sprint(attacker, #PRINT_HIGH, "You mercilessly slaughter ");
					sprint(attacker, #PRINT_HIGH, targ.netname);
					sprint(attacker, #PRINT_HIGH, "!\n");					
					return;
				}
				else if (deathmsg == #DMSG_DAEDALUS)
				{
					deathstring = " is melted by ";
					deathstring2 = "'s Daedalus impulse rifle\n";			
				}
				else if (deathmsg == #DMSG_BIOWEAPON_ATT)
				{
					deathstring = " escapes infection from ";
					deathstring2 = " by dying first\n";
				}
				else if (deathmsg == #DMSG_GRENADEL)
				{
					deathstring = " eats ";
					deathstring2 = "'s pineapple\n";
					if (targ.health < -40)
					{
						deathstring = " was gibbed by ";
						deathstring2 = "'s grenade\n";
					}
				}
                else if (deathmsg == #DMSG_STUCK_FORCEFIELD)
				{
					deathstring = " is fried in ";
					deathstring2 = "'s force field\n";
				}
                else if (deathmsg == #DMSG_FORCEFIELD)
				{
					deathstring = " had a shocking experience on ";
					deathstring2 = "'s force field\n";
				}
                else if (deathmsg == #DMSG_FGTRAP)
				{
					deathstring = " explodes with ";
					deathstring2 = "'s trapped field generator\n";
				}
				else if (deathmsg == #DMSG_ROCKETL)
				{
					deathstring = " rides ";
					deathstring2 = "'s rocket\n";
					if (targ.health < -40)
					{
						deathstring = " was gibbed by ";
						deathstring2 = "'s rocket\n" ;
					}
				}
				else if (deathmsg == #DMSG_HOVER) //WK
				{
					deathstring = " choked on ";
					deathstring2 = "'s hover exhaust\n";
				}
				else if (deathmsg == #DMSG_LAND_MINE) //WK
				{
					deathstring2 = "'s land mine\n";

                    if (rnum < 0.8)
						deathstring = " walked over ";
					else
						deathstring = " was launched 40 ft into the air by ";

					if (targ.health < -40)
                    {
						if (rnum < 0.8) 
							deathstring = " was turned into a shower of gibs by ";
						else 
							deathstring = " was launched 80 ft into the air by ";
					}
				}
				else if (deathmsg == #DMSG_FLAME)
				{
					if (rnum < 0.2)
					{
						deathstring =  " is burnt up by ";
						deathstring2 = "'s flame\n";
					}
					else if (rnum < 0.4)
					{
						deathstring =  " is fried by ";
						deathstring2 = "'s fire\n";
					}
					else if (rnum < 0.6)
					{
						deathstring =  " feels ";
						deathstring2 = "'s fire of wrath\n";
					}
					else if (rnum < 0.8)
					{
						deathstring =  " is reduced to ashes by ";
						deathstring2 = "\n";
					}
					else
					{
						deathstring = " is grilled by ";
						deathstring2 = "'s flame\n";
					}
				}
				else if (deathmsg == #DMSG_AXE)
				{
                    deathstring2 = "\n";

                    if (attacker.cutf_items & #CUTF_KNIFE)
					{
                        if (attacker.job & #JOB_WARLOCK)
                        {
                            deathstring = " is forced to donate his blood by ";
                            deathstring2 = "\n";
                        }
                        else
                        {
                            deathstring = " was knife-murdered by "; 
                        }
                    }
					else
						deathstring = " was axe-murdered by ";
					
                    //if (attacker.demon_blood < 0) //WK Sanity Check
					//	attacker.demon_blood = 0;
					// if the above ever happens you've got a serious bug that needs fixing
					// don't get around it by cheap hacks - SB
					
                    if (attacker.demon_blood < #MAX_KNIFE_BLOOD) //SB - OfN defined max now
						attacker.demon_blood = attacker.demon_blood + 1;
				}
				else if (deathmsg == #DMSG_SPANNER)
				{
					deathstring = " was spanner-murdered by ";
					deathstring2 = "\n";
				}
				else if (deathmsg == #DMSG_SHOTGUN)
				{
					deathstring = " chewed on ";
					deathstring2 = "'s boomstick\n";
				}
				else if (deathmsg == #DMSG_SSHOTGUN)
				{
					deathstring = " ate 2 loads of ";
					deathstring2 = "'s buckshot\n";
				}
				else if (deathmsg == #DMSG_NAILGUN)
				{
					deathstring = " was nailed by ";
					deathstring2 = "\n";
				}
                else if (deathmsg == #DMSG_SNG)
				{
					deathstring = " was spiked by ";
					deathstring2 = "'s super nailgun\n";
				}
				else if (deathmsg == #DMSG_LIGHT_ASSAULT)
				{
					if (rnum <= 0.1) {
						deathstring = " wishes ";
						deathstring2 = "'s gun was still an SNG\n";
					}
					else if (rnum <= 0.5) {
						deathstring = " gets felled by ";
						deathstring2 = "'s light assault cannon\n";
					}
					else {
						deathstring = " gets sawn almost in half by ";
						deathstring2 = "\n";
					}
				}	 
				else if (deathmsg == #DMSG_LIGHTNING)
				{
					if (rnum <= 0.1) {
						deathstring = " has never seen a lightning gun in TF before. (";
						deathstring2 = " has.)\n";
					}
					else if (rnum <= 0.2) {
						deathstring = " is thunderstruck by ";
						deathstring2 = "'s gun\n";
					}
					else if (rnum <= 0.4) {
						deathstring = " is electrocuted by ";
						deathstring2 = "'s thunderbolt\n";
					}
					else if (rnum <= 0.7) {
						deathstring = " is shocked to death by ";
						deathstring2 = "'s lightning gun\n";
					}
					else {
						deathstring = " accepts ";
						if (attacker.waterlevel > 1)
							deathstring2 = "'s discharge\n";
						else
							deathstring2 = "'s shaft\n";
					}
				}
				else if (deathmsg == #DMSG_HOOK)
				{
					deathstring = " grappled with ";
					deathstring2 = "\n";
				}
				else if (deathmsg == #DMSG_JUDOKA)
				{
					deathstring = " had his arms broken by ";
					deathstring2 = "\n";
				}
                else if (deathmsg == #DMSG_AIRG)
				{
					deathstring = " is ventilated by ";
					deathstring2 = "\n";
				}
                else if (deathmsg == #DMSG_LASERCANNON)
                {
                   	deathstring = " was blasted by ";
					deathstring2 = "'s laser cannon\n";
                }  
                else if (deathmsg == #DMSG_DISPEL)
				{
					deathstring = " is banished to the netherworld by ";
					deathstring2 = "\n";
				}
                else if (deathmsg == #DMSG_AIRG_WATER)
				{
					if (rnum < 0.5)
                    {
                        deathstring = " learns to swim backwards with ";
					    deathstring2 = "'s help\n";
                    }
                    else
                    {
                        deathstring = " is underwater-airfisted by ";
					    deathstring2 = "\n";
                    }
                }
				else if (deathmsg == #DMSG_SNIPERRIFLE)
				{
					if (rnum <= 0.5)
					{
						deathstring = " takes a bullet in the chest from ";
						deathstring2 = "\n";
					}
					else
					{
						deathstring = " succumbs to sniperfire from ";
						deathstring2 = "\n";
					}
                    if (attacker.cutf_items & #CUTF_OTR) //- OfN
                    {
                        /*local float rnum2;
                        rnum2 = random();
       					if (rnum2 <= 0.3)
                        {
    						deathstring = " will never be the same after ";
	    					deathstring2 = "'s shot\n";
                        }
       					else if (rnum2 <= 0.4)
                        {*/
    						//deathstring = " gets a huge OTR implant from "; //organic torsion relay
                            deathstring = " learns from ";
	    					deathstring2 = " what an OTR bullet is\n";
                        //}
                        /*else if (rnum2 <= 0.6)
                        {
                            deathstring = " gets a huge OTR implant from ";
                            deathstring = "\n";
                        }*/
                    }
				}
				else if (deathmsg == #DMSG_SNIPERHEADSHOT)
				{
					if (rnum <= 0.5)
					{
						deathstring = " gets a third eye from ";
						deathstring2 = "\n";
					}
					else
					{
						deathstring = " gets his head blown off by ";
						deathstring2 = "\n";
					}
                    if (attacker.cutf_items & #CUTF_OTR) //- OfN
                    {
       					if (random() <= 0.6)
                        {
    						deathstring = "'s head flies away due to ";
	    					deathstring2 = " and his OTR bullets\n";
                        }
                    }
				}
				else if (deathmsg == #DMSG_SNIPERLEGSHOT)
				{
					if (rnum <= 0.5)
					{
						deathstring = " is made legless by ";
						deathstring2 = "\n";
					}
					else
					{
						deathstring = " gets his legs blown off by ";
						deathstring2 = "\n";
					}
                    if (attacker.cutf_items & #CUTF_OTR) //- OfN
                    {
       					if (random() <= 0.25)
                        {
    						deathstring = " owns a metallic replacement for his legs from ";
	    					deathstring2 = "\n";
                        }
                    }
				}
				else if (deathmsg == #DMSG_AUTORIFLE)
				{
					deathstring = " collects ";
					deathstring2 = "'s bullet spray.\n";
				}
				else if (deathmsg == #DMSG_ASSAULTCANNON)
				{
					deathstring = " gets sawn in half by ";
					deathstring2 = "\n";
				}
				else if (deathmsg == #DMSG_BACKSTAB)
				{
					if (rnum < 0.5)
                    {
                        deathstring = " gets assassinated by ";
					    deathstring2 = "\n";
					}
                    else
                    {
                        deathstring = " is knifed from behind by ";
					    deathstring2 = "\n";
                    }
                    //if (attacker.demon_blood < 0) //WK Sanity Check
					//	attacker.demon_blood = 0;
					// See previous comment - SB
					if (attacker.demon_blood < #MAX_KNIFE_BLOOD) //SB
						attacker.demon_blood = attacker.demon_blood + 1;
				}
				else if (deathmsg == #DMSG_TRANQ)
				{
					deathstring = " is put to sleep by ";
					deathstring2 = "\n";
				}
				else if (deathmsg == #DMSG_LASERBOLT)
				{
					deathstring = " gets a hole in his heart from ";
					deathstring2 = "'s railgun\n";
				}
				else if (deathmsg == #DMSG_INCENDIARY)
				{
					deathstring = " gets well done by ";
					deathstring2 = "'s incendiary rocket\n";
				}

				bprint (#PRINT_MEDIUM, targ.netname);
				bprint (#PRINT_MEDIUM, deathstring);
				bprint (#PRINT_MEDIUM, attacker.netname);
				bprint (#PRINT_MEDIUM, deathstring2);
			}
			return;
		}
		else if (attacker.classname == "building_dispenser")
		{
			if (!(attacker.is_malfunctioning & #SCREWUP_TWO) && !(attacker.is_malfunctioning & #SCREWUP_FOUR))
			{
				if (targ == attacker.real_owner)
				{
					bprint (#PRINT_MEDIUM, targ.netname);
					bprint (#PRINT_MEDIUM, " dispenses with himself\n");
					Give_Frags_Out(attacker, targ, -1, 0, 1, 1, 0);
				}
				else
				{
					bprint (#PRINT_MEDIUM, targ.netname);
					bprint (#PRINT_MEDIUM, " didn't insert the correct change into ");
					bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
					bprint (#PRINT_MEDIUM, "'s dispenser\n");
					if (Teammate(targ.team_no,attacker.team_no))
						Give_Frags_Out(attacker, attacker, -1, 0, 1, 1, 0);
					else
						Give_Frags_Out(attacker, targ, 1, 0, 1, 1, 0);
				}
			}
			else
			{
				if (targ == attacker.real_owner)
				{
					bprint (#PRINT_MEDIUM, targ.netname);
					bprint (#PRINT_MEDIUM, " is blown apart by his trapped dispenser\n");
					Give_Frags_Out(attacker.real_owner, attacker, -1, 0, 1, 1, 0);
				}
				else if (targ == attacker.martyr_enemy)
				{
					bprint (#PRINT_MEDIUM, targ.netname);
					bprint (#PRINT_MEDIUM, " should've stayed away from ");
					bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
					bprint (#PRINT_MEDIUM, "'s dispenser\n");
					Give_Frags_Out(attacker.martyr_enemy, attacker, -1, 0, 1, 1, 0);
				}
				else
				{
					bprint (#PRINT_MEDIUM, attacker.martyr_enemy.netname);
					bprint (#PRINT_MEDIUM, " laughs as ");
					bprint (#PRINT_MEDIUM, targ.netname);
					bprint (#PRINT_MEDIUM, " is blown to pieces by ");
					bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
					bprint (#PRINT_MEDIUM, "'s trapped dispenser\n");
					Give_Frags_Out(attacker.martyr_enemy, targ, 1, 0, 1, 1, 0);
				}
			}
			return;
		}
		else if (attacker.classname == "building_sentrygun" || attacker.classname == "building_tesla")
		{
			if (targ == attacker.real_owner)
			{
				if (deathmsg == #DMSG_SENTRYGUN_ROCKET)
					deathstring = " intercepts his sentry gun's rocket\n";
				else if (deathmsg == #DMSG_SENTRYGUN_BULLET)
					deathstring = " crossed his sentry gun's line of fire\n";
				else if (deathmsg == #DMSG_BUG_ZAPPER)
					deathstring = " was electrocuted by his own sentry\n";
				else
					deathstring = " let his sentry turn against him\n"; //CH
				
				bprint(#PRINT_MEDIUM, targ.netname);
				bprint(#PRINT_MEDIUM, deathstring);
			}
			else
			{
				if (Teammate(targ.team_no, attacker.team_no)) {//remove frags if team member
				//CH its not the sentry/tesla's fault so only take from owner
				//	Give_Frags_Out(attacker, targ, -1, 0, 2, 0, 0); //gun
					Give_Frags_Out(attacker.real_owner, targ, -1, 1, 1, 1, 0);
				} else {
					Give_Frags_Out(attacker, targ, 1, 0, 2, 0, 0); //gun
					Give_Frags_Out(attacker.real_owner, targ, 1, 1, 1, 1, 0);
				} 

				if (deathmsg == #DMSG_SENTRYGUN_ROCKET)
				{
					deathstring = " hates ";
					deathstring2 = "'s sentry gun\n";
				}
				else if (deathmsg == #DMSG_SENTRYGUN_BULLET)
				{
					deathstring = " is mown down by ";
					deathstring2 = "'s sentry gun\n";
				}
				else if (deathmsg == #DMSG_TESLA)
				{
					if (rnum < 0.5) {
						deathstring = " was electrocuted by ";
						deathstring2 = "'s tesla coil\n";
					}
					else if (rnum < 0.75) {
						deathstring = " was shocked to pieces by ";
						deathstring2 = "'s tesla sentry\n";
					}
					else {
						deathstring = " was annihilated by ";
						deathstring2 = "'s tesla gun\n";
					}
				}
				else if (deathmsg == #DMSG_BUG_ZAPPER)
				{
					if (rnum < 0.25) {
						deathstring = " made a frying sound after running into ";
						deathstring2 = "'s Sentry Point Defense System\n";
					}
					else if (rnum < 0.5) {
						deathstring = " is cooked at 400 degrees by ";
						deathstring2 = "'s sentry gun\n";
					}
					else if (rnum < 0.75) {
						deathstring = " is disentegrated by ";
						deathstring2 = "'s Sentry Point Defense System\n";
					}
					else {
						deathstring = " is obliterated by ";
						deathstring2 = "'s sentry gun\n";
					}
				}
				bprint(#PRINT_MEDIUM, targ.netname);
				bprint(#PRINT_MEDIUM, deathstring);
				bprint(#PRINT_MEDIUM, attacker.real_owner.netname);
				bprint(#PRINT_MEDIUM, deathstring2);
			}
		}
		else if (attacker.classname == "building_teleporter")
		{
			sprint(attacker.martyr_enemy, #PRINT_HIGH, targ.netname);
			sprint(attacker.martyr_enemy, #PRINT_HIGH, " disappears into the void.\n");
			return;
		}
		else
		{
			Give_Frags_Out(targ, targ, -1, 1, 1, 1, 0);
/*
			#ifdef QUAKE_WORLD
				logfrag (targ, targ);
			#endif

			targ.real_frags = targ.real_frags - 1;   // killed self
		 	if (!(toggleflags & #TFLAG_TEAMFRAGS))
				targ.frags = targ.real_frags;
*/
			rnum = targ.watertype;

			bprint (#PRINT_HIGH, targ.netname);

			if (rnum == -3)
			{
				if (random() < 0.5)
					deathstring = " sleeps with the fishes\n";
				else
					deathstring = " ate before swimming\n"; //CH
			}
			else if (rnum == -4)
			{
				if (random() < 0.5)
					deathstring = " gulped a load of slime\n";
				else
					deathstring = " can't exist on slime alone\n";
			}
			else if (rnum == -5)
			{
				if (targ.health < -15)
				{
					deathstring = " burst into flames\n";
				}
				else if (random() < 0.5)
					deathstring = " turned into hot slag\n";
				else
					deathstring = " visits the Volcano God\n";
			}
#ifndef QUAKE_WORLD
	//#ifdef COOP_MODE
			else if (attacker.flags & #FL_MONSTER)
			{
				if (attacker.classname == "monster_army")
					deathstring = " was shot by a Grunt\n";
				else if (attacker.classname == "monster_demon1")
					deathstring = " was eviscerated by a Fiend\n";
				else if (attacker.classname == "monster_dog")
					deathstring = " was mauled by a Rottweiler\n";
				else if (attacker.classname == "monster_dragon")
					deathstring = " was fried by a Dragon\n";
				else if (attacker.classname == "monster_enforcer")
					deathstring = " was blasted by an Enforcer\n";
				else if (attacker.classname == "monster_fish")
					deathstring = " was fed to the Rotfish\n";
				else if (attacker.classname == "monster_hell_knight")
					deathstring = " was slain by a Death Knight\n";
				else if (attacker.classname == "monster_knight")
					deathstring = " was slashed by a Knight\n";
				else if (attacker.classname == "monster_ogre")
					deathstring = " was destroyed by an Ogre\n";
				else if (attacker.classname == "monster_oldone")
					deathstring = " became one with Shub-Niggurath\n";
				else if (attacker.classname == "monster_shalrath")
					deathstring = " was exploded by a Vore\n";
				else if (attacker.classname == "monster_shambler")
					deathstring = " was smashed by a Shambler\n";
				else if (attacker.classname == "monster_tarbaby")
					deathstring = " was slimed by a Spawn\n";
				else if (attacker.classname == "monster_vomit")
					deathstring = " was vomited on by a Vomitus\n";
				else if (attacker.classname == "monster_wizard")
					deathstring = " was scragged by a Scrag\n";
				else if (attacker.classname == "monster_zombie")
					deathstring = " joins the Zombies\n";
			}
	//#endif
#endif
			else if (attacker.classname == "explo_box")
			{
				deathstring = " blew up\n";
			}
			else if (attacker.solid == #SOLID_BSP && attacker != world)
			{	
				deathstring = " was squished\n";
			}			
			else if (attacker.classname == "trap_shooter" || attacker.classname == "trap_spikeshooter" || attacker.classname == "trap_tf_spikeshooter" || attacker.classname == "trap_tf_shooter")
			{
				if (attacker.deathtype != string_null)
                    deathstring = attacker.deathtype;
                else if (attacker.spawnflags == #SPAWNFLAG_LASER)
					deathstring = " had surgery from a laser\n";
				else if (attacker.spawnflags == #SPAWNFLAG_TFROCKET)
				{
					//if (rnum < 0.9)
						deathstring = " took a ride on a rocket\n";
					//else
					//	deathstring = " proves for once and for all that he IS the rocket man\n";
				}
				else if (attacker.spawnflags == #SPAWNFLAG_TFGRENADE)
					deathstring = " tried to eat a wild pineapple\n";
				else if (attacker.spawnflags == #SPAWNFLAG_TFFLAME)
					deathstring = " was burned alive\n";
				else if (attacker.spawnflags == #SPAWNFLAG_SUPERSPIKE)
					deathstring = " was nailed to the ground\n";
				else
					deathstring = " was spiked\n";
			}
			else if (attacker.classname == "fireball")
			{
				deathstring = " ate a lavaball\n";
			}
			else if (attacker.classname == "trigger_changelevel")
			{
				deathstring = " tried to leave\n";
			}
            else if (targ.deathtype == "falling" && attacker == world)
			{
				targ.deathtype = "";
				deathstring = " fell to his death\n";
			}
			else //- OfN - unknown death by himself
			{
				rnum = random();
                
                if (rnum < 0.25)
                    deathstring = " died happily\n";
                else if (rnum < 0.5)
                    deathstring = " knows how to die with style\n";
                else if (rnum < 0.75) 
                    deathstring = " simply dies\n";
                else deathstring = " had an original death\n";
			}

			bprint(#PRINT_MEDIUM, deathstring);
            return; //- ofn
		}
	}
    else if (IsMonster(targ) && attacker.classname == "building_sentrygun")
    {
        custom_demon_name(targ); //CH

        if ((teamplay) && (attacker.real_owner.team_no > 0) && (targ.real_owner.team_no > 0))
        {
            if (!Teammate(targ.real_owner.team_no, attacker.real_owner.team_no))
            {
                Give_Frags_Out(attacker, targ, 1, 0, 2, 0, 0); //Tesla
                Give_Frags_Out(attacker.real_owner, targ, 1, 0, 1, 1, 0);

                //bprint (#PRINT_MEDIUM, targ.real_owner.netname);
                //bprint (#PRINT_MEDIUM, "'s demon, ");
                bprint (#PRINT_MEDIUM, targ.netname);
                bprint (#PRINT_MEDIUM, " (");
                bprint (#PRINT_MEDIUM, targ.real_owner.netname);
                bprint (#PRINT_MEDIUM, ") was killed by ");
                bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
                bprint (#PRINT_MEDIUM, "'s sentry gun\n");
                return;

            }
            else
            {
                Give_Frags_Out(attacker, targ, -1, 0, 2, 0, 0); //Tesla
                Give_Frags_Out(attacker.real_owner, targ, -1, 0, 1, 1, 0);

                //bprint (#PRINT_MEDIUM, targ.real_owner.netname);
                //bprint (#PRINT_MEDIUM, " friendly demon, ");
                bprint (#PRINT_MEDIUM, targ.netname);
                bprint (#PRINT_MEDIUM, " (");
                bprint (#PRINT_MEDIUM, targ.real_owner.netname);
                bprint (#PRINT_MEDIUM, ") was killed by ");
                bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
                bprint (#PRINT_MEDIUM, "'s friendly sentry gun\n");
                return;
            }
        }
    }
	else if (targ.classname == "monster_wizard") // OfN
	{
		custom_demon_name(targ);
        if (attacker.classname == "building_tesla")
		{
			if ((teamplay) && (attacker.real_owner.team_no > 0) && (targ.real_owner.team_no > 0))
			{
				if (!Teammate(targ.real_owner.team_no, attacker.real_owner.team_no))
				{
					Give_Frags_Out(attacker, targ, 1, 0, 2, 0, 0); //Tesla
					Give_Frags_Out(attacker.real_owner, targ, 1, 0, 1, 1, 0);

/*					attacker.frags = attacker.frags + 1; //Tesla
					attacker.real_owner.real_frags = attacker.real_owner.real_frags + 1; //Player
				 	if (!(toggleflags & #TFLAG_TEAMFRAGS))
						attacker.real_owner.frags = attacker.real_owner.real_frags;
*/
					bprint (#PRINT_MEDIUM, targ.real_owner.netname);
					bprint (#PRINT_MEDIUM, "'s scrag, ");
					bprint (#PRINT_MEDIUM, targ.netname);
					bprint (#PRINT_MEDIUM, ", was shocked to death by ");
					bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
					bprint (#PRINT_MEDIUM, "'s tesla sentry\n");
					return;
				}
				else
				{
					Give_Frags_Out(attacker, targ, -1, 0, 2, 0, 0); //Tesla
					Give_Frags_Out(attacker.real_owner, targ, -1, 0, 1, 1, 0);
/*
					attacker.frags = attacker.frags - 1; //Tesla
					attacker.real_owner.real_frags = attacker.real_owner.real_frags - 1; //Player
				 	if (!(toggleflags & #TFLAG_TEAMFRAGS))
						attacker.real_owner.frags = attacker.real_owner.real_frags;
*/
					bprint (#PRINT_MEDIUM, targ.real_owner.netname);
					bprint (#PRINT_MEDIUM, "'s friendly scrag, ");
					bprint (#PRINT_MEDIUM, targ.netname);
					bprint (#PRINT_MEDIUM, ", was shocked to death by ");
					bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
					bprint (#PRINT_MEDIUM, "'s tesla sentry\n");
					return;
				}
			}
		}
		else if (attacker.classname == "player")
		{
			if ((teamplay) && (attacker.team_no > 0) && (self.real_owner.team_no > 0))
			{
				if (Teammate(targ.real_owner.team_no,attacker.team_no))
				{
					if (attacker == self.real_owner)
					{
                        Give_Frags_Out(attacker, targ, -2, 0, 1, 1, 0);
//						attacker.real_frags = attacker.real_frags - 2; //Owner -2
                        bprint (#PRINT_MEDIUM, attacker.netname);

                        if (deathmsg == #DMSG_LASERCANNON)
                            bprint (#PRINT_MEDIUM, " cuts his own scrag in half!\n");					    
                        else
					        bprint (#PRINT_MEDIUM, " kills his own scrag!\n");					    
                    }
					else
					{
                        Give_Frags_Out(attacker, targ, -1, 0, 1, 1, 0);
//						attacker.real_frags = attacker.real_frags - 1; // killed a team demon

					    bprint (#PRINT_MEDIUM, attacker.netname);
                        
                        if (deathmsg == #DMSG_LASERCANNON)
                            bprint (#PRINT_MEDIUM, " blasts the friendly scrag ");					    
                        else
					        bprint (#PRINT_MEDIUM, " mows down the friendly scrag ");

					    bprint (#PRINT_MEDIUM, targ.netname);
					    bprint (#PRINT_MEDIUM, " (");
					    bprint (#PRINT_MEDIUM, targ.real_owner.netname);
					    bprint (#PRINT_MEDIUM, ")\n");
                    }
				}
				else
				{
					Give_Frags_Out(attacker, targ, 1, 0, 1, 1, 0);
//					attacker.real_frags = attacker.real_frags + 1;

                    if (deathmsg == #DMSG_LASERCANNON)
                    {
                        bprint (#PRINT_MEDIUM, attacker.netname);
                        bprint (#PRINT_MEDIUM, " cuts ");					    
                        bprint (#PRINT_MEDIUM, targ.real_owner.netname);
                        bprint (#PRINT_MEDIUM, "'s scrag in several parts\n");
                    }
                    else					 
                    {
                        bprint (#PRINT_MEDIUM, targ.real_owner.netname);
                        bprint (#PRINT_MEDIUM, "'s scrag, ");
                        bprint (#PRINT_MEDIUM, targ.netname);
                        bprint (#PRINT_MEDIUM, ", was killed by ");
                        bprint (#PRINT_MEDIUM, attacker.netname);
                        bprint (#PRINT_MEDIUM, "\n");
                    }

                    MonsterKill(attacker); // adds knife kill to warlock if needed
				}
//		 		if (!(toggleflags & #TFLAG_TEAMFRAGS))
//					attacker.frags = attacker.real_frags;
				return;
			}
		}
		else if (attacker.classname == "monster_army")
		{
			custom_demon_name(attacker);
			GetRank(attacker);
			if (Teammate(targ.real_owner.team_no,attacker.real_owner.team_no))
			{
				Give_Frags_Out(attacker, targ, -1, 0, 1, 1, 0);
//				attacker.real_frags = attacker.real_frags - 1; // killed a team demon
					
				bprint (#PRINT_MEDIUM, attacker.undercover_name);
				bprint (#PRINT_MEDIUM, attacker.netname);
				bprint (#PRINT_MEDIUM, " (");
				bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
				bprint (#PRINT_MEDIUM, ") mows down the friendly scrag ");
				bprint (#PRINT_MEDIUM, targ.netname);
				bprint (#PRINT_MEDIUM, " (");
				bprint (#PRINT_MEDIUM, targ.real_owner.netname);
				bprint (#PRINT_MEDIUM, ")\n");
			}
			else
			{
				Give_Frags_Out(attacker, targ, 1, 0, 1, 1, 0);
//				attacker.real_frags = attacker.real_frags + 1;
				bprint (#PRINT_MEDIUM, targ.real_owner.netname);
				bprint (#PRINT_MEDIUM, "'s scrag, ");
				bprint (#PRINT_MEDIUM, targ.netname);
				bprint (#PRINT_MEDIUM, ", is killed by ");
				bprint (#PRINT_MEDIUM, attacker.undercover_name);
				bprint (#PRINT_MEDIUM, attacker.netname);
				bprint (#PRINT_MEDIUM, " (");
				bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
				bprint (#PRINT_MEDIUM, ")\n");
			}
//			if (!(toggleflags & #TFLAG_TEAMFRAGS))
//				attacker.frags = attacker.real_frags;
		return;
		}	
		else if (attacker.classname == "monster_demon1")
		{
			custom_demon_name(attacker);
			if (Teammate(targ.real_owner.team_no,attacker.real_owner.team_no))
			{
				Give_Frags_Out(attacker, targ, -1, 0, 1, 1, 0);
//				attacker.real_frags = attacker.real_frags - 1; // killed a team demon
					
				bprint (#PRINT_MEDIUM, attacker.netname);
				bprint (#PRINT_MEDIUM, " (");
				bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
				bprint (#PRINT_MEDIUM, ") eviscerates the friendly scrag ");
				bprint (#PRINT_MEDIUM, targ.netname);
				bprint (#PRINT_MEDIUM, " (");
				bprint (#PRINT_MEDIUM, targ.real_owner.netname);
				bprint (#PRINT_MEDIUM, ")\n");
			}
			else
			{
				Give_Frags_Out(attacker, targ, 1, 0, 1, 1, 0);
//				attacker.real_frags = attacker.real_frags + 1;
				bprint (#PRINT_MEDIUM, targ.real_owner.netname);
				bprint (#PRINT_MEDIUM, "'s scrag, ");
				bprint (#PRINT_MEDIUM, targ.netname);
				bprint (#PRINT_MEDIUM, ", is returned to hell by ");
				bprint (#PRINT_MEDIUM, attacker.netname);
				bprint (#PRINT_MEDIUM, " (");
				bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
				bprint (#PRINT_MEDIUM, ")\n");
			}
//			if (!(toggleflags & #TFLAG_TEAMFRAGS))
//				attacker.frags = attacker.real_frags;
		return;
		}	
		else if (attacker.classname == "monster_shambler")
		{
			custom_demon_name(attacker);
			if (Teammate(targ.real_owner.team_no,attacker.real_owner.team_no))
			{
				Give_Frags_Out(attacker, targ, -1, 0, 1, 1, 0);
//				attacker.real_frags = attacker.real_frags - 1; // killed a team demon
					
                bprint (#PRINT_MEDIUM, "The shambler ");
                bprint (#PRINT_MEDIUM, attacker.netname);
				bprint (#PRINT_MEDIUM, " (");
				bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
				bprint (#PRINT_MEDIUM, ") annihilates the friendly scrag ");
				bprint (#PRINT_MEDIUM, targ.netname);
				bprint (#PRINT_MEDIUM, " (");
				bprint (#PRINT_MEDIUM, targ.real_owner.netname);
				bprint (#PRINT_MEDIUM, ")\n");
			}
			else
			{
				Give_Frags_Out(attacker, targ, 1, 0, 1, 1, 0);
//				attacker.real_frags = attacker.real_frags + 1;
				bprint (#PRINT_MEDIUM, targ.real_owner.netname);
				bprint (#PRINT_MEDIUM, "'s scrag, ");
				bprint (#PRINT_MEDIUM, targ.netname);
				bprint (#PRINT_MEDIUM, ", learns a lesson from the shambler ");
				bprint (#PRINT_MEDIUM, attacker.netname);
				bprint (#PRINT_MEDIUM, " (");
				bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
				bprint (#PRINT_MEDIUM, ")\n");
			}
//			if (!(toggleflags & #TFLAG_TEAMFRAGS))
//				attacker.frags = attacker.real_frags;
		return;
		}	
        else if (attacker.classname == "monster_wizard")
		{
			custom_demon_name(attacker);
			if (Teammate(targ.real_owner.team_no,attacker.real_owner.team_no))
			{
				Give_Frags_Out(attacker, targ, -1, 0, 1, 1, 0);
//				attacker.real_frags = attacker.real_frags - 1; // killed a team demon
					
				bprint (#PRINT_MEDIUM, attacker.netname);
				bprint (#PRINT_MEDIUM, " (");
				bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
				bprint (#PRINT_MEDIUM, ") annihilates the colleague ");
				bprint (#PRINT_MEDIUM, targ.netname);
				bprint (#PRINT_MEDIUM, " (");
				bprint (#PRINT_MEDIUM, targ.real_owner.netname);
				bprint (#PRINT_MEDIUM, ")\n");
			}
			else
			{
				Give_Frags_Out(attacker, targ, 1, 0, 1, 1, 0);
//				attacker.real_frags = attacker.real_frags + 1;
				bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
				bprint (#PRINT_MEDIUM, "'s scrag, ");
				bprint (#PRINT_MEDIUM, attacker.netname);
				bprint (#PRINT_MEDIUM, ", shows to ");
				bprint (#PRINT_MEDIUM, targ.netname);
				bprint (#PRINT_MEDIUM, " (");
				bprint (#PRINT_MEDIUM, targ.real_owner.netname);
				bprint (#PRINT_MEDIUM, ") who is the best\n");
			}
//			if (!(toggleflags & #TFLAG_TEAMFRAGS))
//				attacker.frags = attacker.real_frags;
		return;
		}	
    }//- End scrag death stuff
    else if (targ.classname == "monster_demon1") //CH
	{
		custom_demon_name(targ); //CH
		if (attacker.classname == "building_tesla")
		{
			if ((teamplay) && (attacker.real_owner.team_no > 0) && (targ.real_owner.team_no > 0))
			{
				if (!Teammate(targ.real_owner.team_no, attacker.real_owner.team_no))
				{
					Give_Frags_Out(attacker, targ, 1, 0, 2, 0, 0); //Tesla
					Give_Frags_Out(attacker.real_owner, targ, 1, 0, 1, 1, 0);

/*					attacker.frags = attacker.frags + 1; //Tesla
					attacker.real_owner.real_frags = attacker.real_owner.real_frags + 1; //Player
				 	if (!(toggleflags & #TFLAG_TEAMFRAGS))
						attacker.real_owner.frags = attacker.real_owner.real_frags;
*/
                    bprint (#PRINT_MEDIUM, targ.real_owner.netname);
                    bprint (#PRINT_MEDIUM, "'s demon, ");
                    bprint (#PRINT_MEDIUM, targ.netname);
                    bprint (#PRINT_MEDIUM, ", was shocked to death by ");
                    bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
                    bprint (#PRINT_MEDIUM, "'s tesla sentry\n");
                    return;

				}
				else
				{
					Give_Frags_Out(attacker, targ, -1, 0, 2, 0, 0); //Tesla
					Give_Frags_Out(attacker.real_owner, targ, -1, 0, 1, 1, 0);
/*
					attacker.frags = attacker.frags - 1; //Tesla
					attacker.real_owner.real_frags = attacker.real_owner.real_frags - 1; //Player
				 	if (!(toggleflags & #TFLAG_TEAMFRAGS))
						attacker.real_owner.frags = attacker.real_owner.real_frags;
*/
					bprint (#PRINT_MEDIUM, targ.real_owner.netname);
					bprint (#PRINT_MEDIUM, "'s friendly demon, ");
					bprint (#PRINT_MEDIUM, targ.netname);
					bprint (#PRINT_MEDIUM, ", was shocked to death by ");
					bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
					bprint (#PRINT_MEDIUM, "'s tesla sentry\n");
					return;
				}
			}
		}
        else if (attacker.classname == "player")
		{
			if ((teamplay) && (attacker.team_no > 0) && (self.real_owner.team_no > 0))
			{
				if (Teammate(targ.real_owner.team_no,attacker.team_no))
				{
					if (attacker == self.real_owner)
					{
                        Give_Frags_Out(attacker, targ, -2, 0, 1, 1, 0);
//						attacker.real_frags = attacker.real_frags - 2; //Owner -2
                        bprint (#PRINT_MEDIUM, attacker.netname);
					    bprint (#PRINT_MEDIUM, " kills his own fiend!\n");
                    }
					else
					{
                        Give_Frags_Out(attacker, targ, -1, 0, 1, 1, 0);
//						attacker.real_frags = attacker.real_frags - 1; // killed a team demon

					    bprint (#PRINT_MEDIUM, attacker.netname);
					    bprint (#PRINT_MEDIUM, " mows down the friendly demon ");
					    bprint (#PRINT_MEDIUM, targ.netname);
					    bprint (#PRINT_MEDIUM, " (");
					    bprint (#PRINT_MEDIUM, targ.real_owner.netname);
					    bprint (#PRINT_MEDIUM, ")\n");
                    }
				}
				else
				{
					Give_Frags_Out(attacker, targ, 1, 0, 1, 1, 0);
//					attacker.real_frags = attacker.real_frags + 1;
					bprint (#PRINT_MEDIUM, targ.real_owner.netname);
					bprint (#PRINT_MEDIUM, "'s demon, ");
					bprint (#PRINT_MEDIUM, targ.netname);
					bprint (#PRINT_MEDIUM, ", was killed by ");
					bprint (#PRINT_MEDIUM, attacker.netname);
					bprint (#PRINT_MEDIUM, "\n");

                    MonsterKill(attacker); // adds knife kills to warlock
				}
//		 		if (!(toggleflags & #TFLAG_TEAMFRAGS))
//					attacker.frags = attacker.real_frags;
				return;
			}
		}
		else if (attacker.classname == "monster_army")
		{
			custom_demon_name(attacker);
			GetRank(attacker);
			if (Teammate(targ.real_owner.team_no,attacker.real_owner.team_no))
			{
				Give_Frags_Out(attacker, targ, -1, 0, 1, 1, 0);
//				attacker.real_frags = attacker.real_frags - 1; // killed a team demon
					
				bprint (#PRINT_MEDIUM, attacker.undercover_name);
				bprint (#PRINT_MEDIUM, attacker.netname);
				bprint (#PRINT_MEDIUM, " (");
				bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
				bprint (#PRINT_MEDIUM, ") mows down the friendly demon ");
				bprint (#PRINT_MEDIUM, targ.netname);
				bprint (#PRINT_MEDIUM, " (");
				bprint (#PRINT_MEDIUM, targ.real_owner.netname);
				bprint (#PRINT_MEDIUM, ")\n");
			}
			else
			{
				Give_Frags_Out(attacker, targ, 1, 0, 1, 1, 0);
//				attacker.real_frags = attacker.real_frags + 1;
				bprint (#PRINT_MEDIUM, targ.real_owner.netname);
				bprint (#PRINT_MEDIUM, "'s demon, ");
				bprint (#PRINT_MEDIUM, targ.netname);
				bprint (#PRINT_MEDIUM, ", didn't have a prayer against ");
				bprint (#PRINT_MEDIUM, attacker.undercover_name);
				bprint (#PRINT_MEDIUM, attacker.netname);
				bprint (#PRINT_MEDIUM, " (");
				bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
				bprint (#PRINT_MEDIUM, ")\n");
			}
//			if (!(toggleflags & #TFLAG_TEAMFRAGS))
//				attacker.frags = attacker.real_frags;
		return;
		}	
		else if (attacker.classname == "monster_demon1")
		{
			custom_demon_name(attacker);
			if (Teammate(targ.real_owner.team_no,attacker.real_owner.team_no))
			{
				Give_Frags_Out(attacker, targ, -1, 0, 1, 1, 0);
//				attacker.real_frags = attacker.real_frags - 1; // killed a team demon
					
				bprint (#PRINT_MEDIUM, attacker.netname);
				bprint (#PRINT_MEDIUM, " (");
				bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
				bprint (#PRINT_MEDIUM, ") eviscerates the friendly demon ");
				bprint (#PRINT_MEDIUM, targ.netname);
				bprint (#PRINT_MEDIUM, " (");
				bprint (#PRINT_MEDIUM, targ.real_owner.netname);
				bprint (#PRINT_MEDIUM, ")\n");
			}
			else
			{
				Give_Frags_Out(attacker, targ, 1, 0, 1, 1, 0);
//				attacker.real_frags = attacker.real_frags + 1;
				bprint (#PRINT_MEDIUM, targ.real_owner.netname);
				bprint (#PRINT_MEDIUM, "'s demon, ");
				bprint (#PRINT_MEDIUM, targ.netname);
				bprint (#PRINT_MEDIUM, ", realises too late that ");
				bprint (#PRINT_MEDIUM, attacker.netname);
				bprint (#PRINT_MEDIUM, " (");
				bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
				bprint (#PRINT_MEDIUM, ") wasn't just trying to be friendly\n");
			}
//			if (!(toggleflags & #TFLAG_TEAMFRAGS))
//				attacker.frags = attacker.real_frags;
		return;
		}	
		else if (attacker.classname == "monster_shambler")
		{
			custom_demon_name(attacker);
			if (Teammate(targ.real_owner.team_no,attacker.real_owner.team_no))
			{
				Give_Frags_Out(attacker, targ, -1, 0, 1, 1, 0);
//				attacker.real_frags = attacker.real_frags - 1; // killed a team demon
					
				bprint (#PRINT_MEDIUM, attacker.netname);
				bprint (#PRINT_MEDIUM, " (");
				bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
				bprint (#PRINT_MEDIUM, ") annihilates the friendly demon ");
				bprint (#PRINT_MEDIUM, targ.netname);
				bprint (#PRINT_MEDIUM, " (");
				bprint (#PRINT_MEDIUM, targ.real_owner.netname);
				bprint (#PRINT_MEDIUM, ")\n");
			}
			else
			{
				Give_Frags_Out(attacker, targ, 1, 0, 1, 1, 0);
//				attacker.real_frags = attacker.real_frags + 1;
				bprint (#PRINT_MEDIUM, targ.real_owner.netname);
				bprint (#PRINT_MEDIUM, "'s demon, ");
				bprint (#PRINT_MEDIUM, targ.netname);
				bprint (#PRINT_MEDIUM, ", is given a firm farewell to the netherworld by ");
				bprint (#PRINT_MEDIUM, attacker.netname);
				bprint (#PRINT_MEDIUM, " (");
				bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
				bprint (#PRINT_MEDIUM, ")\n");
			}
//			if (!(toggleflags & #TFLAG_TEAMFRAGS))
//				attacker.frags = attacker.real_frags;
		return;
		}	
        else if (attacker.classname == "monster_wizard")
		{
			custom_demon_name(attacker);
			if (Teammate(targ.real_owner.team_no,attacker.real_owner.team_no))
			{
				Give_Frags_Out(attacker, targ, -1, 0, 1, 1, 0);
//				attacker.real_frags = attacker.real_frags - 1; // killed a team demon
					
				bprint (#PRINT_MEDIUM, attacker.netname);
				bprint (#PRINT_MEDIUM, " (");
				bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
				bprint (#PRINT_MEDIUM, ") kills the friendly demon ");
				bprint (#PRINT_MEDIUM, targ.netname);
				bprint (#PRINT_MEDIUM, " (");
				bprint (#PRINT_MEDIUM, targ.real_owner.netname);
				bprint (#PRINT_MEDIUM, ")\n");
			}
			else
			{
				Give_Frags_Out(attacker, targ, 1, 0, 1, 1, 0);
//				attacker.real_frags = attacker.real_frags + 1;
				bprint (#PRINT_MEDIUM, targ.real_owner.netname);
				bprint (#PRINT_MEDIUM, "'s demon, ");
				bprint (#PRINT_MEDIUM, targ.netname);
				bprint (#PRINT_MEDIUM, ", is killed by the scrag ");
				bprint (#PRINT_MEDIUM, attacker.netname);
				bprint (#PRINT_MEDIUM, " (");
				bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
				bprint (#PRINT_MEDIUM, ")\n");
			}
//			if (!(toggleflags & #TFLAG_TEAMFRAGS))
//				attacker.frags = attacker.real_frags;
		return;
		}	
	}
	else if (targ.classname == "monster_army") //CH
	{
		custom_demon_name(targ); //CH
		GetRank(targ);
		if (attacker.classname == "building_tesla")
		{
			if ((teamplay) && (attacker.real_owner.team_no > 0) && (targ.real_owner.team_no > 0))
			{
				if (!Teammate(targ.real_owner.team_no, attacker.real_owner.team_no))
				{
					Give_Frags_Out(attacker, targ, 1, 0, 2, 0, 0); //Tesla
					Give_Frags_Out(attacker.real_owner, targ, 1, 0, 1, 1, 0);

/*					attacker.frags = attacker.frags + 1; //Tesla
					attacker.real_owner.real_frags = attacker.real_owner.real_frags + 1; //Player
				 	if (!(toggleflags & #TFLAG_TEAMFRAGS))
						attacker.real_owner.frags = attacker.real_owner.real_frags;
*/
					bprint (#PRINT_MEDIUM, targ.real_owner.netname);
					bprint (#PRINT_MEDIUM, "'s mercenary soldier, ");
					bprint (#PRINT_MEDIUM, targ.undercover_name);
					bprint (#PRINT_MEDIUM, targ.netname);
					bprint (#PRINT_MEDIUM, ", was shocked to death by ");
					bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
					bprint (#PRINT_MEDIUM, "'s tesla sentry\n");
					return;
				}
				else
				{
					Give_Frags_Out(attacker, targ, -1, 0, 2, 0, 0); //Tesla
					Give_Frags_Out(attacker.real_owner, targ, -1, 0, 1, 1, 0);
/*
					attacker.frags = attacker.frags - 1; //Tesla
					attacker.real_owner.real_frags = attacker.real_owner.real_frags - 1; //Player
				 	if (!(toggleflags & #TFLAG_TEAMFRAGS))
						attacker.real_owner.frags = attacker.real_owner.real_frags;
*/
					bprint (#PRINT_MEDIUM, targ.real_owner.netname);
					bprint (#PRINT_MEDIUM, "'s friendly soldier, ");
					bprint (#PRINT_MEDIUM, targ.undercover_name);
					bprint (#PRINT_MEDIUM, targ.netname);
					bprint (#PRINT_MEDIUM, ", was shocked to death by ");
					bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
					bprint (#PRINT_MEDIUM, "'s tesla sentry\n");
					return;
				}
			}
		}
		if (attacker.classname == "player")
		{
			if ((teamplay) && (attacker.team_no > 0) && (self.real_owner.team_no > 0))
			{
				if (Teammate(targ.real_owner.team_no,attacker.team_no))
				{
					if (attacker == self.real_owner)
					{
                        Give_Frags_Out(attacker, targ, -2, 0, 1, 1, 0);
//						attacker.real_frags = attacker.real_frags - 2; //Owner -2
                        bprint (#PRINT_MEDIUM, attacker.netname);
					    bprint (#PRINT_MEDIUM, " kills his own soldier!\n");
                    }
					else
					{
                        Give_Frags_Out(attacker, targ, -1, 0, 1, 1, 0);
//						attacker.real_frags = attacker.real_frags - 1; // killed a team demon

					    bprint (#PRINT_MEDIUM, attacker.netname);
					    bprint (#PRINT_MEDIUM, " mows down the friendly soldier ");
					    bprint (#PRINT_MEDIUM, targ.undercover_name);
					    bprint (#PRINT_MEDIUM, targ.netname);
					    bprint (#PRINT_MEDIUM, " (");
					    bprint (#PRINT_MEDIUM, targ.real_owner.netname);
					    bprint (#PRINT_MEDIUM, ")\n");
                    }
				}
				else
				{
					Give_Frags_Out(attacker, targ, 1, 0, 1, 1, 0);
//					attacker.real_frags = attacker.real_frags + 1;
					bprint (#PRINT_MEDIUM, targ.real_owner.netname);
					bprint (#PRINT_MEDIUM, "'s mercenary soldier, ");
					bprint (#PRINT_MEDIUM, targ.undercover_name);
					bprint (#PRINT_MEDIUM, targ.netname);
					bprint (#PRINT_MEDIUM, ", was killed by ");
					bprint (#PRINT_MEDIUM, attacker.netname);
					bprint (#PRINT_MEDIUM, "\n");
				}
//		 		if (!(toggleflags & #TFLAG_TEAMFRAGS))
//					attacker.frags = attacker.real_frags;
				return;
			}
		}
		else if (attacker.classname == "monster_shambler")
		{
			custom_demon_name(attacker);
			if (Teammate(targ.real_owner.team_no,attacker.real_owner.team_no))
			{
				Give_Frags_Out(attacker, targ, -1, 0, 1, 1, 0);
//				attacker.real_frags = attacker.real_frags - 1; // killed a team demon
					
				bprint (#PRINT_MEDIUM, attacker.netname);
				bprint (#PRINT_MEDIUM, " (");
				bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
				bprint (#PRINT_MEDIUM, ") slaps the friendly soldier ");
				bprint (#PRINT_MEDIUM, targ.undercover_name);
				bprint (#PRINT_MEDIUM, targ.netname);
				bprint (#PRINT_MEDIUM, " (");
				bprint (#PRINT_MEDIUM, targ.real_owner.netname);
				bprint (#PRINT_MEDIUM, ") into oblivion\n");
			}
			else
			{
				Give_Frags_Out(attacker, targ, 1, 0, 1, 1, 0);
//				attacker.real_frags = attacker.real_frags + 1;
				bprint (#PRINT_MEDIUM, targ.real_owner.netname);
				bprint (#PRINT_MEDIUM, "'s soldier, ");
				bprint (#PRINT_MEDIUM, targ.undercover_name);
				bprint (#PRINT_MEDIUM, targ.netname);
				bprint (#PRINT_MEDIUM, ", is smacked down by ");
				bprint (#PRINT_MEDIUM, attacker.netname);
				bprint (#PRINT_MEDIUM, " (");
				bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
				bprint (#PRINT_MEDIUM, ")\n");
			}
//			if (!(toggleflags & #TFLAG_TEAMFRAGS))
//				attacker.frags = attacker.real_frags;
		return;
		}	
		else if (attacker.classname == "monster_demon1")
		{
			custom_demon_name(attacker);
			if (Teammate(targ.real_owner.team_no,attacker.real_owner.team_no))
			{
				Give_Frags_Out(attacker, targ, -1, 0, 1, 1, 0);
//				attacker.real_frags = attacker.real_frags - 1; // killed a team demon
					
				bprint (#PRINT_MEDIUM, attacker.netname);
				bprint (#PRINT_MEDIUM, " (");
				bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
				bprint (#PRINT_MEDIUM, ") disembowels the friendly soldier ");
				bprint (#PRINT_MEDIUM, targ.undercover_name);
				bprint (#PRINT_MEDIUM, targ.netname);
				bprint (#PRINT_MEDIUM, " (");
				bprint (#PRINT_MEDIUM, targ.real_owner.netname);
				bprint (#PRINT_MEDIUM, ")\n");
			}
			else
			{
				Give_Frags_Out(attacker, targ, 1, 0, 1, 1, 0);
//				attacker.real_frags = attacker.real_frags + 1;
				bprint (#PRINT_MEDIUM, targ.real_owner.netname);
				bprint (#PRINT_MEDIUM, "'s soldier, ");
				bprint (#PRINT_MEDIUM, targ.undercover_name);
				bprint (#PRINT_MEDIUM, targ.netname);
				bprint (#PRINT_MEDIUM, ", is now listed as KIA thanks to ");
				bprint (#PRINT_MEDIUM, attacker.netname);
				bprint (#PRINT_MEDIUM, " (");
				bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
				bprint (#PRINT_MEDIUM, ")\n");
			}
//			if (!(toggleflags & #TFLAG_TEAMFRAGS))
//				attacker.frags = attacker.real_frags;
		return;
		}	
		else if (attacker.classname == "monster_army")
		{
			custom_demon_name(attacker);
			GetRank(attacker);
			
            if (targ==attacker) //- OfN - It *may* happen
            {
                bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
                bprint (#PRINT_MEDIUM, "'s soldier, ");
				bprint (#PRINT_MEDIUM, attacker.undercover_name);
                bprint (#PRINT_MEDIUM, attacker.netname);
                bprint (#PRINT_MEDIUM, ", explodes with his own rockets!\n");
                return;
            }   
            
            if (Teammate(targ.real_owner.team_no,attacker.real_owner.team_no))
			{
				Give_Frags_Out(attacker, targ, -1, 0, 1, 1, 0);
//				attacker.real_frags = attacker.real_frags - 1; // killed a team demon
					
				bprint (#PRINT_MEDIUM, attacker.undercover_name);
				bprint (#PRINT_MEDIUM, attacker.netname);
				bprint (#PRINT_MEDIUM, " (");
				bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
				bprint (#PRINT_MEDIUM, ") mows down comrade-in-arms ");
				bprint (#PRINT_MEDIUM, targ.undercover_name);
				bprint (#PRINT_MEDIUM, targ.netname);
				bprint (#PRINT_MEDIUM, " (");
				bprint (#PRINT_MEDIUM, targ.real_owner.netname);
				bprint (#PRINT_MEDIUM, ")\n");
			}
			else
			{
				Give_Frags_Out(attacker, targ, 1, 0, 1, 1, 0);
//				attacker.real_frags = attacker.real_frags + 1;
				bprint (#PRINT_MEDIUM, targ.real_owner.netname);
				bprint (#PRINT_MEDIUM, "'s soldier, ");
				bprint (#PRINT_MEDIUM, targ.undercover_name);
				bprint (#PRINT_MEDIUM, targ.netname);
				bprint (#PRINT_MEDIUM, ", takes a bullet in the chest from ");
				bprint (#PRINT_MEDIUM, attacker.undercover_name);
				bprint (#PRINT_MEDIUM, attacker.netname);
				bprint (#PRINT_MEDIUM, " (");
				bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
				bprint (#PRINT_MEDIUM, ")\n");
			}
//			if (!(toggleflags & #TFLAG_TEAMFRAGS))
//				attacker.frags = attacker.real_frags;
		return;
		}	
        else if (attacker.classname == "monster_wizard")
		{
			custom_demon_name(attacker);
			//GetRank(attacker);
			if (Teammate(targ.real_owner.team_no,attacker.real_owner.team_no))
			{
				Give_Frags_Out(attacker, targ, -1, 0, 1, 1, 0);
//				attacker.real_frags = attacker.real_frags - 1; // killed a team demon
					
				//bprint (#PRINT_MEDIUM, attacker.undercover_name);
				bprint (#PRINT_MEDIUM, "The scrag ");
                bprint (#PRINT_MEDIUM, attacker.netname);
				bprint (#PRINT_MEDIUM, " (");
				bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
				bprint (#PRINT_MEDIUM, ") kills the friendly soldier ");
				bprint (#PRINT_MEDIUM, targ.undercover_name);
				bprint (#PRINT_MEDIUM, targ.netname);
				bprint (#PRINT_MEDIUM, " (");
				bprint (#PRINT_MEDIUM, targ.real_owner.netname);
				bprint (#PRINT_MEDIUM, ")\n");
			}
			else
			{
				Give_Frags_Out(attacker, targ, 1, 0, 1, 1, 0);
//				attacker.real_frags = attacker.real_frags + 1;
				bprint (#PRINT_MEDIUM, targ.real_owner.netname);
				bprint (#PRINT_MEDIUM, "'s soldier, ");
				bprint (#PRINT_MEDIUM, targ.undercover_name);
				bprint (#PRINT_MEDIUM, targ.netname);
				bprint (#PRINT_MEDIUM, ", is killed by the scrag ");
				//bprint (#PRINT_MEDIUM, attacker.undercover_name);
				bprint (#PRINT_MEDIUM, attacker.netname);
				bprint (#PRINT_MEDIUM, " (");
				bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
				bprint (#PRINT_MEDIUM, ")\n");
			}
//			if (!(toggleflags & #TFLAG_TEAMFRAGS))
//				attacker.frags = attacker.real_frags;
		return;
		}	
	}
	else if (targ.classname == "monster_shambler") //CH
	{
		custom_demon_name(targ); //CH
		if (attacker.classname == "building_tesla")
		{
			if ((teamplay) && (attacker.real_owner.team_no > 0) && (targ.real_owner.team_no > 0))
			{
				if (!Teammate(targ.real_owner.team_no,attacker.real_owner.team_no))
				{
					Give_Frags_Out(attacker, targ, 1, 0, 2, 0, 0); //Tesla
					Give_Frags_Out(attacker.real_owner, targ, 1, 0, 1, 1, 0);

/*					attacker.frags = attacker.frags + 1; //Tesla
					attacker.real_owner.real_frags = attacker.real_owner.real_frags + 1; //Player
				 	if (!(toggleflags & #TFLAG_TEAMFRAGS))
						attacker.real_owner.frags = attacker.real_owner.real_frags;
*/
					bprint (#PRINT_MEDIUM, targ.real_owner.netname);
					bprint (#PRINT_MEDIUM, "'s shambler, ");
					bprint (#PRINT_MEDIUM, targ.netname);
					bprint (#PRINT_MEDIUM, ", was given a shocking surprise by ");
					bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
					bprint (#PRINT_MEDIUM, "'s tesla sentry\n");
					return;
				}
				else
				{
					Give_Frags_Out(attacker, targ, -1, 0, 2, 0, 0); //Tesla
					Give_Frags_Out(attacker.real_owner, targ, -1, 0, 1, 1, 0);
/*
					attacker.frags = attacker.frags - 1; //Tesla
					attacker.real_owner.real_frags = attacker.real_owner.real_frags - 1; //Player
				 	if (!(toggleflags & #TFLAG_TEAMFRAGS))
						attacker.real_owner.frags = attacker.real_owner.real_frags;
*/
					bprint (#PRINT_MEDIUM, targ.real_owner.netname);
					bprint (#PRINT_MEDIUM, "'s friendly shambler, ");
					bprint (#PRINT_MEDIUM, targ.netname);
					bprint (#PRINT_MEDIUM, ", shouldn't play so close to ");
					bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
					bprint (#PRINT_MEDIUM, "'s tesla sentry\n");
					return;
				}
			}
		}
		if (attacker.classname == "player")
		{
			if ((teamplay) && (attacker.team_no > 0) && (self.real_owner.team_no > 0))
			{
				if (Teammate(targ.real_owner.team_no,attacker.team_no))
				{
					if (attacker == self.real_owner)
					{
                        Give_Frags_Out(attacker, targ, -2, 0, 1, 1, 0);
                        bprint (#PRINT_MEDIUM, attacker.netname);
					    bprint (#PRINT_MEDIUM, " kills his own shambler!\n");
//						attacker.real_frags = attacker.real_frags - 2; //Owner -2
                    }
					else
					{
                        Give_Frags_Out(attacker, targ, -1, 0, 1, 1, 0);
//						attacker.real_frags = attacker.real_frags - 1; // killed a team demon

					    bprint (#PRINT_MEDIUM, attacker.netname);
					    bprint (#PRINT_MEDIUM, " mows down the friendly shambler ");
					    bprint (#PRINT_MEDIUM, targ.netname);
					    bprint (#PRINT_MEDIUM, " (");
					    bprint (#PRINT_MEDIUM, targ.real_owner.netname);
					    bprint (#PRINT_MEDIUM, ")\n");
                    }
				}
				else
				{
					Give_Frags_Out(attacker, targ, 1, 0, 1, 1, 0);
//					attacker.real_frags = attacker.real_frags + 1;
					bprint (#PRINT_MEDIUM, targ.real_owner.netname);
					bprint (#PRINT_MEDIUM, "'s shambler, ");
					bprint (#PRINT_MEDIUM, targ.netname);
					bprint (#PRINT_MEDIUM, ", was felled by ");
					bprint (#PRINT_MEDIUM, attacker.netname);
					bprint (#PRINT_MEDIUM, "\n");

                    MonsterKill(attacker); // adds knife kills to warlock
				}
//		 		if (!(toggleflags & #TFLAG_TEAMFRAGS))
//					attacker.frags = attacker.real_frags;
				return;
			}
		}
		else if (attacker.classname == "monster_demon1")
		{
			custom_demon_name(attacker);
			if (Teammate(targ.real_owner.team_no,attacker.real_owner.team_no))
			{
				Give_Frags_Out(attacker, targ, -1, 0, 1, 1, 0);
//				attacker.real_frags = attacker.real_frags - 1; // killed a team demon
					
				bprint (#PRINT_MEDIUM, attacker.netname);
				bprint (#PRINT_MEDIUM, " (");
				bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
				bprint (#PRINT_MEDIUM, ") checks its aura after killing ");
				bprint (#PRINT_MEDIUM, targ.netname);
				bprint (#PRINT_MEDIUM, " (");
				bprint (#PRINT_MEDIUM, targ.real_owner.netname);
				bprint (#PRINT_MEDIUM, ")\n");
			}
			else
			{
				Give_Frags_Out(attacker, targ, 1, 0, 1, 1, 0);
//				attacker.real_frags = attacker.real_frags + 1;
				bprint (#PRINT_MEDIUM, targ.real_owner.netname);
				bprint (#PRINT_MEDIUM, "'s shambler, ");
				bprint (#PRINT_MEDIUM, targ.netname);
				bprint (#PRINT_MEDIUM, ", is torn apart by ");
				bprint (#PRINT_MEDIUM, attacker.netname);
				bprint (#PRINT_MEDIUM, " (");
				bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
				bprint (#PRINT_MEDIUM, ")\n");
			}
//			if (!(toggleflags & #TFLAG_TEAMFRAGS))
//				attacker.frags = attacker.real_frags;
		return;
		}	
		else if (attacker.classname == "monster_shambler")
		{
			custom_demon_name(attacker);
			if (Teammate(targ.real_owner.team_no,attacker.real_owner.team_no))
			{
				Give_Frags_Out(attacker, targ, -1, 0, 1, 1, 0);
//				attacker.real_frags = attacker.real_frags - 1; // killed a team demon
					
				bprint (#PRINT_MEDIUM, attacker.netname);
				bprint (#PRINT_MEDIUM, " (");
				bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
				bprint (#PRINT_MEDIUM, ") electrifies the friendly shambler ");
				bprint (#PRINT_MEDIUM, targ.netname);
				bprint (#PRINT_MEDIUM, " (");
				bprint (#PRINT_MEDIUM, targ.real_owner.netname);
				bprint (#PRINT_MEDIUM, ")\n");
			}
			else
			{
				Give_Frags_Out(attacker, targ, 1, 0, 1, 1, 0);
//				attacker.real_frags = attacker.real_frags + 1;
				bprint (#PRINT_MEDIUM, targ.real_owner.netname);
				bprint (#PRINT_MEDIUM, "'s shambler, ");
				bprint (#PRINT_MEDIUM, targ.netname);
				bprint (#PRINT_MEDIUM, ", finds losing against shambler ");
				bprint (#PRINT_MEDIUM, attacker.netname);
				bprint (#PRINT_MEDIUM, " (");
				bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
				bprint (#PRINT_MEDIUM, ") to be a fatal experience\n");
			}
//			if (!(toggleflags & #TFLAG_TEAMFRAGS))
//				attacker.frags = attacker.real_frags;
		return;
		}	
		else if (attacker.classname == "monster_army")
		{
			custom_demon_name(attacker);
			GetRank(attacker);
			if ( Teammate(targ.real_owner.team_no,attacker.real_owner.team_no))
			{
				Give_Frags_Out(attacker, targ, -1, 0, 1, 1, 0);
//				attacker.real_frags = attacker.real_frags - 1; // killed a team demon
					
				bprint (#PRINT_MEDIUM, targ.netname);
				bprint (#PRINT_MEDIUM, " (");
				bprint (#PRINT_MEDIUM, targ.real_owner.netname);
				bprint (#PRINT_MEDIUM, ") is caught in the crossfire from ");
				bprint (#PRINT_MEDIUM, attacker.undercover_name);
				bprint (#PRINT_MEDIUM, attacker.netname);
				bprint (#PRINT_MEDIUM, " (");
				bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
				bprint (#PRINT_MEDIUM, ")\n");
			}
			else
			{
				Give_Frags_Out(attacker, targ, 1, 0, 1, 1, 0);
//				attacker.real_frags = attacker.real_frags + 1;
				bprint (#PRINT_MEDIUM, attacker.undercover_name);
				bprint (#PRINT_MEDIUM, attacker.netname);
				bprint (#PRINT_MEDIUM, " (");
				bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
				bprint (#PRINT_MEDIUM, ") proves to ");
				bprint (#PRINT_MEDIUM, targ.netname);
				bprint (#PRINT_MEDIUM, " (");
				bprint (#PRINT_MEDIUM, targ.real_owner.netname);
				bprint (#PRINT_MEDIUM, ") that size doesn't matter\n");
			}
//			if (!(toggleflags & #TFLAG_TEAMFRAGS))
//				attacker.frags = attacker.real_frags;
		return;
		}	
   		else if (attacker.classname == "monster_wizard")
		{
			custom_demon_name(attacker);
			//GetRank(attacker);

            // condition reversed forconvenience
			if (!Teammate(targ.real_owner.team_no,attacker.real_owner.team_no))
			{
				Give_Frags_Out(attacker, targ, 1, 0, 1, 1, 0);
//				attacker.real_frags = attacker.real_frags - 1; // killed a team demon
					
				bprint (#PRINT_MEDIUM, targ.netname);
				bprint (#PRINT_MEDIUM, " (");
				bprint (#PRINT_MEDIUM, targ.real_owner.netname);
				bprint (#PRINT_MEDIUM, ") had his army career truncated by the scrag ");
				//bprint (#PRINT_MEDIUM, attacker.undercover_name);
				bprint (#PRINT_MEDIUM, attacker.netname);
				bprint (#PRINT_MEDIUM, " (");
				bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
				bprint (#PRINT_MEDIUM, ")\n");
			}
			else
			{
				Give_Frags_Out(attacker, targ, -1, 0, 1, 1, 0);
//				attacker.real_frags = attacker.real_frags + 1;
				//bprint (#PRINT_MEDIUM, attacker.undercover_name);
                bprint (#PRINT_MEDIUM, "The scrag ");
                bprint (#PRINT_MEDIUM, attacker.netname);
				bprint (#PRINT_MEDIUM, " (");
				bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
				bprint (#PRINT_MEDIUM, ") kills the friendly soldier ");
				bprint (#PRINT_MEDIUM, targ.netname);
				bprint (#PRINT_MEDIUM, " (");
				bprint (#PRINT_MEDIUM, targ.real_owner.netname);
				bprint (#PRINT_MEDIUM, ")\n");
			}
//			if (!(toggleflags & #TFLAG_TEAMFRAGS))
//				attacker.frags = attacker.real_frags;
		return;
		}	

	}
	else if (IsBuilding(targ) && targ.classname != "building_sentrygun_base" && attacker.classname == "building_tesla") //Evil Tesla!
	{
		if (!Teammate(targ.real_owner.team_no,attacker.real_owner.team_no))
		{
			if (targ.classname == "building_sentrygun" ||
				targ.classname == "building_tesla") 
			{
				Give_Frags_Out(attacker, targ, 1, 0, 2, 0, 0); //Tesla
				Give_Frags_Out(attacker.real_owner, targ, 1, 0, 1, 1, 0);
/*
				attacker.frags = attacker.frags + 1; //Tesla
				attacker.real_owner.real_frags = attacker.real_owner.real_frags + 1; //Player
			 	if (!(toggleflags & #TFLAG_TEAMFRAGS))
					attacker.real_owner.frags = attacker.real_owner.real_frags;
*/
			}
		}
		bprint (#PRINT_MEDIUM, targ.real_owner.netname);
		bprint (#PRINT_MEDIUM, "'s ");
			if (targ.classname == "building_dispenser")
				bprint (#PRINT_MEDIUM, "dispenser was zapped by");
			else if (targ.classname == "building_sentrygun")
				bprint (#PRINT_MEDIUM, "sentrygun was no match for");
			else if (targ.classname == "building_camera")
				bprint (#PRINT_MEDIUM, "security camera was vaporized by");
			else if (targ.classname == "building_sensor")
				bprint (#PRINT_MEDIUM, "motion sensor was obliterated by");
			else if (targ.classname == "building_teleporter")
				bprint (#PRINT_MEDIUM, "teleporter pad was short circuted by");
			else if (targ.classname == "building_tesla" && attacker == targ)
			{
				bprint (#PRINT_MEDIUM, "tesla coil destroys itself.\n");
				return;
			}
			else if (targ.classname == "building_tesla")
				bprint (#PRINT_MEDIUM, "tesla sentry lost the battle against");
            else if (targ.classname == "building_sensor")
				bprint (#PRINT_MEDIUM, "motion sensor was fucked up by");
   			else if (targ.classname == "building_fieldgen")
				bprint (#PRINT_MEDIUM, "field generator was destroyed by");
			else
				bprint (#PRINT_MEDIUM, "??Building??");
		bprint (#PRINT_MEDIUM, " ");
		bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
		bprint (#PRINT_MEDIUM, "'s tesla sentry\n");
		return;
	}
	else if (IsBuilding(targ) && targ.classname != "building_sentrygun_base")
	{

        //- OfN - Weird but may happen.. like when a sentry is blown up by its own rocket
        if (attacker == targ)
		{
			bprint (#PRINT_MEDIUM, targ.real_owner.netname);
			bprint (#PRINT_MEDIUM, "'s ");
			
            	if (targ.classname == "building_dispenser")
					bprint (#PRINT_MEDIUM, "dispenser");
				else if (targ.classname == "building_sentrygun")
					bprint (#PRINT_MEDIUM, "sentrygun");
				else if (targ.classname == "building_camera")
					bprint (#PRINT_MEDIUM, "security camera");
				else if (targ.classname == "building_teleporter")
					bprint (#PRINT_MEDIUM, "teleporter pad");
				else if (targ.classname == "building_tesla")
					bprint (#PRINT_MEDIUM, "tesla sentry");
                else if (targ.classname == "building_sensor")
    				bprint (#PRINT_MEDIUM, "motion sensor");
                else if (targ.classname == "building_fieldgen")
                    bprint (#PRINT_MEDIUM, "field generator");
                else
					bprint (#PRINT_MEDIUM, "??Building??");
            
			bprint (#PRINT_MEDIUM, " destroys itself.\n");
			return;
		}
        
        if (attacker.classname == "teledeath")
		{
			bprint (#PRINT_MEDIUM, targ.real_owner.netname);
			bprint (#PRINT_MEDIUM, "'s ");
			
            //bprint (#PRINT_MEDIUM,GetBuildingName(targ));
            	if (targ.classname == "building_dispenser")
					bprint (#PRINT_MEDIUM, "dispenser");
				else if (targ.classname == "building_sentrygun")
					bprint (#PRINT_MEDIUM, "sentrygun");
				else if (targ.classname == "building_camera")
					bprint (#PRINT_MEDIUM, "security camera");
				else if (targ.classname == "building_teleporter")
					bprint (#PRINT_MEDIUM, "teleporter pad");
				else if (targ.classname == "building_tesla")
					bprint (#PRINT_MEDIUM, "tesla sentry");
                else if (targ.classname == "building_sensor")
    				bprint (#PRINT_MEDIUM, "motion sensor");
                else if (targ.classname == "building_fieldgen")
                    bprint (#PRINT_MEDIUM, "field generator");
                else
					bprint (#PRINT_MEDIUM, "??Building??");
            
			bprint (#PRINT_MEDIUM, " was telefragged by ");
			bprint (#PRINT_MEDIUM, attacker.owner.netname);
			bprint (#PRINT_MEDIUM, "\n");
			return;
		}

		if (attacker.classname == "player")
		{
			if (attacker == targ.real_owner)
			{
				bprint (#PRINT_MEDIUM, targ.real_owner.netname);
				bprint (#PRINT_MEDIUM, " destroys his ");
				
                //bprint (#PRINT_MEDIUM,GetBuildingName(targ));
                if (targ.classname == "building_dispenser")
					bprint (#PRINT_MEDIUM, "dispenser");
				else if (targ.classname == "building_sentrygun")
					bprint (#PRINT_MEDIUM, "sentrygun");
				else if (targ.classname == "building_camera")
					bprint (#PRINT_MEDIUM, "security camera");
				else if (targ.classname == "building_teleporter")
					bprint (#PRINT_MEDIUM, "teleporter pad");
				else if (targ.classname == "building_tesla")
					bprint (#PRINT_MEDIUM, "tesla sentry");
				else if (targ.classname == "building_sensor")
    				bprint (#PRINT_MEDIUM, "motion sensor");
                else if (targ.classname == "building_fieldgen")
                    bprint (#PRINT_MEDIUM, "field generator");
                else
					bprint (#PRINT_MEDIUM, "??Building??");
				bprint (#PRINT_MEDIUM, "\n");
				return;
			}

			bprint (#PRINT_MEDIUM, targ.real_owner.netname);
			bprint (#PRINT_MEDIUM, "'s ");

            //bprint (#PRINT_MEDIUM,GetBuildingName(targ)); //- OfN - FIXED?

			if (targ.classname == "building_dispenser")
				bprint (#PRINT_MEDIUM, "dispenser");
			else if (targ.classname == "building_sentrygun")
				bprint (#PRINT_MEDIUM, "sentrygun");
			else if (targ.classname == "building_camera")
				bprint (#PRINT_MEDIUM, "security camera");
			else if (targ.classname == "building_teleporter")
				bprint (#PRINT_MEDIUM, "teleporter pad");
			else if (targ.classname == "building_tesla")
				bprint (#PRINT_MEDIUM, "tesla sentry");
			else if (targ.classname == "building_sensor")
				bprint (#PRINT_MEDIUM, "motion sensor");
   			else if (targ.classname == "building_fieldgen")
				bprint (#PRINT_MEDIUM, "field generator");
			else
				bprint (#PRINT_MEDIUM, "??Building??");

			bprint (#PRINT_MEDIUM, " was destroyed by ");
			bprint (#PRINT_MEDIUM, attacker.netname);
			bprint (#PRINT_MEDIUM, "\n");

			if (!Teammate(targ.real_owner.team_no,attacker.team_no))
			{
				if (targ.classname == "building_sentrygun" ||
					targ.classname == "building_tesla")
				{
					Give_Frags_Out(attacker, targ, 1, 0, 1, 1, 0);
/*
					attacker.real_frags = attacker.real_frags + 1;
				 	if (!(toggleflags & #TFLAG_TEAMFRAGS))
						attacker.frags = attacker.real_frags;
*/
				}
			}

			return;
		}
		else if (attacker.classname == "monster_army") // SB grunty kills building
		{
			custom_demon_name(attacker);
			GetRank(attacker);

			bprint (#PRINT_MEDIUM, targ.real_owner.netname);
			bprint (#PRINT_MEDIUM, "'s ");
			
            //bprint(#PRINT_MEDIUM,GetBuildingName(targ));
            if (targ.classname == "building_dispenser")
				bprint (#PRINT_MEDIUM, "dispenser");
			else if (targ.classname == "building_sentrygun")
				bprint (#PRINT_MEDIUM, "sentrygun");
			else if (targ.classname == "building_camera")
				bprint (#PRINT_MEDIUM, "security camera");
			else if (targ.classname == "building_teleporter")
				bprint (#PRINT_MEDIUM, "teleporter pad");
			else if (targ.classname == "building_tesla")
				bprint (#PRINT_MEDIUM, "tesla sentry");
			else if (targ.classname == "building_sensor")
				bprint (#PRINT_MEDIUM, "motion sensor");
   			else if (targ.classname == "building_fieldgen")
				bprint (#PRINT_MEDIUM, "field generator");
            else
				bprint (#PRINT_MEDIUM, "??Building??");

			bprint (#PRINT_MEDIUM, " was destroyed by ");
			bprint (#PRINT_MEDIUM, attacker.undercover_name);
			bprint (#PRINT_MEDIUM, attacker.netname);
			bprint (#PRINT_MEDIUM, " (");
			bprint (#PRINT_MEDIUM, attacker.real_owner.netname);
			bprint (#PRINT_MEDIUM, ")\n");
		
			if (!Teammate(targ.real_owner.team_no,attacker.real_owner.team_no))
			{
				if (targ.classname == "building_sentrygun" ||
					targ.classname == "building_tesla")
				{
					Give_Frags_Out(attacker, targ, 1, 0, 1, 1, 0);
/*
					attacker.real_frags = attacker.real_frags + 1;
				 	if (!(toggleflags & #TFLAG_TEAMFRAGS))
						attacker.frags = attacker.real_frags;
*/
				}
			}
			return;
		}
	}

    //- Miscellaneous monster/army deaths
    if (IsMonster(targ))
    {
        if (attacker.classname == "explo_box")
        {
            deathstring = " blew up\n";
        }
        else if (attacker.solid == #SOLID_BSP && attacker != world)
        {	
            deathstring = " was squished\n";
        }
        else if (attacker.classname == "trap_shooter" || attacker.classname == "trap_spikeshooter" || attacker.classname == "trap_tf_spikeshooter" || attacker.classname == "trap_tf_shooter")
        {
            if (attacker.deathtype != string_null)
                deathstring = attacker.deathtype;
            else if (attacker.spawnflags == #SPAWNFLAG_LASER)
                deathstring = " had surgery from a laser\n";
            else if (attacker.spawnflags == #SPAWNFLAG_TFROCKET)
                deathstring = " took a ride on a rocket\n";
            else if (attacker.spawnflags == #SPAWNFLAG_TFGRENADE)
                deathstring = " tried to eat a wild pineapple\n";
            else if (attacker.spawnflags == #SPAWNFLAG_TFFLAME)
                deathstring = " was burned alive\n";
            else if (attacker.spawnflags == #SPAWNFLAG_SUPERSPIKE)
                deathstring = " was nailed to the ground\n";
            else
                deathstring = " was spiked\n";
        }
        else if (attacker.classname == "fireball")
        {
            deathstring = " ate a lavaball\n";
        }
        else if (attacker.classname == "teledeath")
        {
            deathstring = " was telefragged by ";
        }
        else 
        {
            deathstring = " dies\n";
        }

        deathstring2=GetMonsterName(targ);

        bprint(#PRINT_HIGH,"The ");
        bprint(#PRINT_HIGH, deathstring2);
        bprint(#PRINT_HIGH," ");
        bprint(#PRINT_HIGH, targ.netname);
        bprint(#PRINT_HIGH," (");
        bprint(#PRINT_HIGH, targ.real_owner.netname);
        bprint(#PRINT_HIGH,")");
        bprint(#PRINT_HIGH, deathstring);
        if (attacker.classname == "teledeath")
        {
            bprint(#PRINT_HIGH, attacker.owner.netname);
            bprint(#PRINT_HIGH,"\n");
        }

        return;
    }

};
