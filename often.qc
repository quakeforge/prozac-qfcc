#include "defs.qh"
/*=======================================================//
// OfteN.QC - CustomTF 3.2.OfN             - 30/1/2001 - //
// by Sergio FumaÒa Grunwaldt  - OfteN aka superCOCK2000 //
=========================================================//
 Additional stuff
=========================================================*/

//= HOLOGRAPH SETTINGS ==========//
#define HOLO_POWER_COST     10   //
#define HOLO_CYCLE_COST      2   //
#define HOLO_CYCLE_TIME      1.5 //
//===============================//

//= FLARE GREN SETTINGS =========//
#define FLARE_DURATION      60   //
//===============================//

void() HoloThink;
void(entity player) RemoveHolo;

//====================================================================//
// Initialize stuff, localinfos etc...                                //
// This is called on worldspawn and with the IMPULSE_UPDATEINFO (194) //
//====================================================================//

void () UpdateInfos = 
{
    local string st;
    
    st = infokey(world, "allow_debug"); //
	if (st == "1" || st =="on")
		allow_debug = 1;
	else
	{
        debug_target=world;
        allow_debug = 0;
    }

    /*st = infokey(world, "cool_gibs"); //
	if (st == "1" || st =="on")
		cool_gibs = 1;
	else
		cool_gibs = 0;*/

    st = infokey(world, "pay_msgs"); //
	if (st == "1" || st =="on")
		pay_msgs = 1;
	else
		pay_msgs = 0;

    st = infokey(world, "team_prefix"); //
	if (st == "1" || st =="on")
		team_prefix = 1;
	else
		team_prefix = 0;

    /*st = infokey(world, "allow_mauser"); //
	if (st == "1" || st =="on")
		allow_mauser = 1;
	else
		allow_mauser = 0;*/

    st = infokey(world, "headless"); //
	if (st == "1" || st =="on" )
		headless = 1;
	else
		headless = 0;

    st = infokey(world, "no_grapple"); //
	if (st == "1" || st =="on" )
		no_grapple = 1;
	else
		no_grapple = 0;

    st = infokey(world, "no_army"); //
	if (st == "1" || st =="on" )
		no_army = 1;
	else
		no_army = 0;

    st = infokey(world, "nicecolors"); //
	if (st == "1" || st =="on" )
		nicecolors = 1;
	else
		nicecolors = 0;

    st = infokey(world, "relax_cheatcheck"); //
	if (st == "1" || st =="on" )
		relax_cheatcheck = 1;
	else
		relax_cheatcheck = 0;

    /*st = infokey(world, "allow_antigrav"); //
	if (st == "1" || st =="on" )
		allow_antigrav = 1;
	else
		allow_antigrav = 0;*/

    st = infokey(world, "no_clusters"); //
    if (st == "1" || st =="on" )
		no_clusters = 1;
	else
		no_clusters = 0;
 
    st = infokey(world, "no_c4"); //
    if (st == "1" || st =="on" )
		no_c4 = 1;
	else
		no_c4 = 0;

    st = infokey(world, "no_otr"); //
    if (st == "1" || st =="on" )
		no_otr = 1;
	else
		no_otr = 0;

    st = infokey(world, "no_laser"); //
    if (st == "1" || st =="on" )
		no_laser = 1;
	else
		no_laser = 0;

    st = infokey(world, "no_detpush"); //
    if (st == "0" || st =="off" )
		no_detpush = 0;
	else
		no_detpush = 1;

    st = infokey(world, "no_monstercolors"); //
    if (st == "1" || st =="on" )
		no_monstercolors = 1;
	else
		no_monstercolors = 0;

    st = infokey(world, "no_chaplan"); //
    if (st == "1" || st =="on" )
		no_chaplan = 1;
	else
		no_chaplan = 0;

    st = infokey(world, "max_mines"); //
    if (!st) st="4"; //sets default, 4 max mines
    max_mines = stof(st);
    if (max_mines < 2 ) max_mines = 2; // the allowed minimum are 2 mines
    else if (max_mines > 8) max_mines = 8; //the allowed maximum is 8 mines	

    st = infokey(world, "custom_mode"); //
    if (!st) st="0"; //sets default
    custom_mode = stof(st);
    if (custom_mode < 0 ) custom_mode = 0; // the allowed minimum 
    else if (custom_mode > 2) custom_mode = 2; //the allowed maximum

    st = infokey(world, "stock_mode"); //
    if (!st) st="0"; //sets default
    stock_mode = stof(st);
    if (stock_mode < 0 ) stock_mode = 0; // the allowed minimum 
    else if (stock_mode > 2) stock_mode = 2; //the allowed maximum

    if (stock_mode == 2 && custom_mode == 2) custom_mode = 0;

    st = infokey(world, "army_delay"); //
    if (!st) st="5"; //sets default
    army_delay = stof(st);
    if (army_delay < 2 ) army_delay = 2; // the allowed minimum 
    else if (army_delay > 60) army_delay = 60; //the allowed maximum

    st = infokey(world, "allow_watermonsters"); //
    if (st == "1" || st =="on" )
		allow_watermonsters = 1;
	else
		allow_watermonsters = 0;

};

//====================================================================//
// Sprints to all the members on one team except one the Team> Prefix //
// It should be used prior any teamsprint (look at tforttm.qc)        //
//====================================================================//

void(float tno, entity ignore) teamprefixsprint =
{
    if ( team_prefix != 1 )
      return;
    
    local entity te;

	// Don't do teamprints in DM
	if (tno == 0)
		return;

	te = find(world, classname, "player");
	while (te)
	{
		if (Teammate(te.team_no,tno) && te != ignore)
		{
            sprint(te, PRINT_HIGH, "Teamç ");
		}

		te = find(te, classname, "player");
	}
};

//==========================================================
// same shit but ignores 2 players

void(float tno, entity ignore, entity ignore2) teamprefixsprintbi =
{
    if ( team_prefix != 1 )
      return;
    
    local entity te;

	// Don't do teamprints in DM
	if (tno == 0)
		return;

	te = find(world, classname, "player");
	while (te)
	{
		if (Teammate(te.team_no,tno) && te != ignore && te != ignore2)
		{
            sprint(te, PRINT_HIGH, "Teamç ");
		}

		te = find(te, classname, "player");
	}
};

//- For better performance i added this: --//
void(entity ignore, string st, string st2, string st3, string st4, string st5, string st6) teamsprint6 =
{
    local entity te;

	te = find(world, classname, "player");
	while (te)
	{
		if (Teammate(te.team_no,ignore.team_no) && te != ignore)
		{
            sprint(te, PRINT_HIGH, st);
            sprint(te, PRINT_HIGH, st2);
            sprint(te, PRINT_HIGH, st3);
            sprint(te, PRINT_HIGH, st4);
            sprint(te, PRINT_HIGH, st5);
            sprint(te, PRINT_HIGH, st6);
		}

		te = find(te, classname, "player");
	}
};

//==========================================================
// same shit but ignores 2 players

void(entity ignore, entity ignore2, string st, string st2, string st3, string st4, string st5, string st6) teamsprintbi =
{
    local entity te;

	te = find(world, classname, "player");
	while (te)
	{
		if (Teammate(te.team_no,ignore.team_no) && te != ignore && te != ignore2)
		{
            sprint(te, PRINT_HIGH, st);
            sprint(te, PRINT_HIGH, st2);
            sprint(te, PRINT_HIGH, st3);
            sprint(te, PRINT_HIGH, st4);
            sprint(te, PRINT_HIGH, st5);
            sprint(te, PRINT_HIGH, st6);
		}

		te = find(te, classname, "player");
	}
};

//================================================//
// Kicks any player with no TF skin on tforttm.qc //
//================================================//

float (string skin_str) Is_TF_Skin =
{
   // if relax_cheatcheck is "on" return its a valid skin
   if (relax_cheatcheck==1) return TRUE;
   
   if ( skin_str != "tf_scout"
    && skin_str != "tf_snipe"
    && skin_str != "tf_sold"
    && skin_str != "tf_demo"
    && skin_str != "tf_medic"
    && skin_str != "tf_hwguy"
    && skin_str != "tf_pyro"
    && skin_str != "tf_spy"
    && skin_str != "tf_eng")
        return FALSE;
   else
        return TRUE;
};

//============================================================================//
// Return the new "NICE" color for the team corresponding to the no passed in //
//============================================================================//

/*string (float tno) TeamGetNiceColor =
{
	if (tno == 1)
		return "2 13";
	if (tno == 2)
		return "9 4";
	if (tno == 3)
		return "5 12";
	if (tno == 4)
		return "3 11";

	return "";
};
*/
float (float tno) TeamGetNiceColor =
{
	if (nicecolors == 1)
	{
		if (tno == 1)
			return 2;
		if (tno == 2)
			return 9;
		if (tno == 3)
			return 5;
		if (tno == 4)
			return 3;
	}
	else
	{
		if (tno == 1)
			return 13;
		if (tno == 2)
			return 4;
		if (tno == 3)
			return 12;
		if (tno == 4)
			return 11;
	}
	return 0;
};

float (float tno, float theColor ) IsValidTopColor =
{
    theColor = floor(theColor);
    
    // if relax_cheatcheck is "on" return its a valid color value
    if (relax_cheatcheck==1)
    {
        if (theColor > 13 || theColor < 0)
            return FALSE;
        
        if (tno == 1)
        {
            if (theColor == 4)
                return FALSE;
            
            if (number_of_teams > 2 && theColor == 12)
                return FALSE;
            if (number_of_teams > 3 && theColor == 11)
                return FALSE;
        }
        
        if (tno == 2)
        {
            if (theColor == 13)
                return FALSE;
        
            if (number_of_teams > 2 && theColor == 12)
                return FALSE;
            if (number_of_teams > 3 && theColor == 11)
                return FALSE;
        }
        
        if (tno == 3)
        {
            if (theColor==4||theColor==13)
                return FALSE;

            if (number_of_teams > 3 && theColor == 11)
                return FALSE;
        }

        if (tno == 4 && (theColor==4||theColor==13||theColor==12))
            return FALSE;

        return TRUE;
    }

    if (tno == 1 && (theColor==2||theColor==13))
		return TRUE;
	if (tno == 2 && (theColor==9||theColor==4))
		return TRUE;
	if (tno == 3 && (theColor==12||theColor==5))
		return TRUE;
	if (tno == 4 && (theColor==11||theColor==3))
		return TRUE;

	return FALSE;
};


//==========================//
// The new holograph device //
//==========================//
void(entity player) UpdateCells =
{
    if (player.current_weapon == WEAP_SPANNER 
    || player.current_weapon == WEAP_LIGHTNING
    || player.current_weapon == WEAP_FLAMETHROWER
    || player.current_weapon == WEAP_DAEDALUS
    || player.current_weapon == WEAP_LASERCANNON)
    {
        player.currentammo = player.ammo_cells;
        player.items = player.items | IT_CELLS;
    }
};

void(entity player) ActivateHolo =
{
    if (!(player.cutf_items & CUTF_HOLO))
    {
		//sprint(player, PRINT_MEDIUM, "You do not have the holograph!\n");
		return;
	}

    if (player.has_holo == 2) return; // avoids overflow, turns to 1 after first think

    if (player.ammo_cells < 10 && player.has_holo == 0)
    {
		local string st;
        sprint(player, PRINT_HIGH, "Your holograph needs "); 
        st=ftos(HOLO_POWER_COST);
        sprint(player, PRINT_HIGH, st);
        sprint(player, PRINT_HIGH," cells at least!\n");
		return;
	}

    if (player.has_holo == 1)
    {
		sprint(player, PRINT_HIGH, "You turn off the holograph device\n");
		RemoveHolo(player);
        return;
	}

	newmis = spawn();
	newmis.solid = SOLID_NOT;
	newmis.movetype = MOVETYPE_NOCLIP;
	newmis.origin = player.origin;
	newmis.angles = player.angles;
	newmis.colormap = player.colormap;
    newmis.skin = player.skin;
	setmodel (newmis, "progs/player.mdl");
	newmis.classname = "holo";
	newmis.owner=player;
	newmis.frame=player.frame;
	newmis.nextthink = time + HOLO_CYCLE_TIME;	
	newmis.think = HoloThink;
    newmis.effects = EF_DIMLIGHT;
	player.ammo_cells = player.ammo_cells - HOLO_POWER_COST;

    UpdateCells(player);

	stuffcmd (player, "bf\nbf\n");
	sprint(player,PRINT_HIGH,"you turn on your holograph...\n");
    sound (newmis, CHAN_MISC, "effects/bodyhit2.wav", 0.5, ATTN_NORM);
    player.has_holo = 2; // 2 makes it wait until first think for turning off the holo 
};

void() HoloThink =
{
    //local entity oldself;

    if (self.owner.ammo_cells < 1)
    {
		sprint(self.owner, PRINT_MEDIUM, "your hologram runs out of energy\n");
        sound (self, CHAN_MISC, "effects/bodyhit1.wav", 0.6, ATTN_NORM);
        spawnFOG(self.origin);
        self.owner.has_holo = 0;
        dremove(self);
        return;
	}

	self.owner.ammo_cells = self.owner.ammo_cells - HOLO_CYCLE_COST;

    /*oldself = self;
	self = self.owner;
	W_SetCurrentAmmo();
	self = oldself;*/

    UpdateCells(self.owner);
    
    self.nextthink = time + HOLO_CYCLE_TIME;	
    self.owner.has_holo = 1; // ready to be turned off
};

void (entity player) RemoveHolo =
{
	local entity te;
    te = find(world, classname, "holo");
    while (te)
	{
		if (te.owner == player) {
          te.owner.has_holo = 0;
          sound (te, CHAN_MISC, "effects/bodyhit1.wav", 0.6, ATTN_NORM);
          spawnFOG(te.origin);
          dremove(te);
          return;
        }

		te = find(te, classname, "holo");
	}
};

//===========================//
// THE FLARES ARE BACK! hehe //
//===========================//

void() FlareBounce;

//---------------------------//
// Flare touch function.     //

void() FlareGrenadeTouch =
{
	if (other == self.owner)
		return;		// don't bounce on owner

    if (pointcontents(self.origin) == CONTENTS_SKY || pointcontents(self.origin) == CONTENTS_SOLID) // if in wall or sky
	{
       dremove(self);
       return;
    }

    if (self.has_holo==0)
    {
        self.skin=1;
        //setmodel (self, "progs/flare.mdl");
    }

    if (other == world && self.movetype != MOVETYPE_BOUNCE)
    {
        self.velocity = '0 0 0';
        
        if (random()<0.6)
        {
           sound (self, CHAN_MISC, "effects/bodyhit2.wav", 0.7, ATTN_NORM);	// bounce sound
        }
        else
        {
           sound (self, CHAN_MISC, "effects/bodyhit1.wav", 0.6, ATTN_NORM);	// bounce sound
        }
    }
    else
    {
        self.movetype = MOVETYPE_BOUNCE;
        self.avelocity = '1000 200 850';
        self.touch = FlareBounce;

    }

    if (self.velocity == '0 0 0')
		self.avelocity = '0 0 0';
	
};

void() FlareBounce =
{
	if (other == self.owner)
		return;		// don't bounce on owner

   
	if (self.velocity == '0 0 0')
		self.avelocity = '0 0 0';
};

//---------------------------//
// Flare grenade explosion.  //

void() FlareGrenadeExplode =
{
    sound (self, CHAN_MISC, "items/flare1.wav", 1, ATTN_NORM);

    //setmodel (self, "progs/flare.mdl");
    self.skin=0;
    self.has_holo=1;

    local vector org;
    org=self.origin;

        WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
		WriteByte (MSG_MULTICAST, TE_GUNSHOT);
		WriteByte (MSG_MULTICAST, 3);
		WriteCoord (MSG_MULTICAST, org_x);
		WriteCoord (MSG_MULTICAST, org_y);
		WriteCoord (MSG_MULTICAST, org_z);
		multicast (org, MULTICAST_PVS);

    self.effects = self.effects | EF_DIMLIGHT;

    self.think = SUB_Remove;
    self.nextthink = time + FLARE_DURATION;
};

//========================================================//
// My stupid contributions to optimize something!         //
//========================================================//

float(entity thing) IsMonster =
{
    if (thing.classname=="monster_shambler")
        return TRUE;
    if (thing.classname=="monster_demon1")
        return TRUE;
    if (thing.classname=="monster_wizard")
        return TRUE;
    if (thing.classname=="monster_army")
        return TRUE;

    if (thing.classname=="monster_knight")
        return TRUE;
    if (thing.classname=="monster_hknight")
        return TRUE;
    
    return FALSE;
};

float(entity thing) IsMonsterNonArmy =
{
    if (thing.classname=="monster_shambler")
        return TRUE;
    if (thing.classname=="monster_demon1")
        return TRUE;
    if (thing.classname=="monster_wizard")
        return TRUE;

    if (thing.classname=="monster_knight")
        return TRUE;
    if (thing.classname=="monster_hknight")
        return TRUE;

    
    return FALSE;
};

float(entity player) HasMonster =
{
   if ((player.job & JOB_WARLOCK && player.job & JOB_DEMON_OUT)
     ||(player.job & JOB_ARMY && player.job & JOB_DEMON_OUT))
     return TRUE;
   
   return FALSE;
};

string(entity themonster) GetMonsterName =
{
    if (themonster.classname == "monster_wizard")
        return "scrag";
    if (themonster.classname == "monster_shambler")
        return "shambler";
    if (themonster.classname == "monster_demon1")
        return "fiend";
    if (themonster.classname == "monster_army")
        return "army soldier";
    if (themonster.classname == "monster_knight")
        return "knight";
    if (themonster.classname == "monster_hknight")
        return "hell knight";
    
    return "unknown monster";
};

void(entity themonster) KillTheMonster =
{
    local entity oself;
    oself=self;

    self=themonster;

    if (themonster.classname == "monster_wizard")
        wiz_die();
    else if (themonster.classname == "monster_shambler")
        custom_shambler_die();
    else if (themonster.classname == "monster_demon1")
        custom_demon_die();
    else if (themonster.classname == "monster_army")
        custom_grunt_die();
    else if (themonster.classname == "monster_knight")
        knight_die();
    else if (themonster.classname == "monster_hknight")
        hknight_die();


    self=oself;
};

string(entity thebuilding) GetBuildingName =
{
	if (thebuilding.classname == "building_dispenser")
		return "dispenser";
	else if (thebuilding.classname == "building_sentrygun")
		return "sentry gun";
	else if (thebuilding.classname == "building_tesla")
		return "tesla sentry";
	else if (thebuilding.classname == "building_sensor")
		return "motion sensor";
	else if (thebuilding.classname == "building_camera")
		return "security camera";
	else if (thebuilding.classname == "building_teleporter")
		return "teleporter pad";
	else if (thebuilding.classname == "building_fieldgen")
		return "field generator";
	else
	    return "unknown building (BUG)";
};

// soldiers don't target unoffensive buildings, or cloaked teslas!
float(entity thebuilding) IsOffenseBuilding =
{
    if (!IsBuilding(thebuilding))
        return FALSE;

    if (thebuilding.classname == "building_sentrygun") 
        return TRUE;

    if (thebuilding.classname == "building_tesla")
    {
        if (thebuilding.tf_items & NIT_TESLA_CLOAKING)  
        {
            if (thebuilding.job == 2)
                return TRUE; // tesla is uncloaked, so soldier can see it
        }
        else
        {
            return TRUE;
        }
    }

    return FALSE;
};

string(entity thething) GetEnemyName =
{
    if (thething.classname == "player")
        return thething.netname;

    if (IsMonster(thething))
        return GetMonsterName(thething);
    
    if (IsBuilding(thething))
        return GetBuildingName(thething);

    if (thething.classname == "grenade" && thething.netname == "land_mine")
        return "land mine";
    
    if (thething.classname != "")
        return thething.classname;
       
    return "unknown stuff";
};

//======================================================//
void() ExpBodyThink;

void(entity body) ExpBody =
{    
    newmis=spawn();
    newmis.owner=body;
    newmis.think=ExpBodyThink;
    newmis.nextthink=time;    
    newmis.origin=body.origin;
};

void() ExpBodyThink =
{
    //deathmsg = DMSG_EXPBODY;
    TF_T_Damage(self.owner, self.owner, self.owner.martyr_enemy, self.owner.health + 60, TF_TD_IGNOREARMOUR, TF_TD_OTHER);// TF_TD_OTHER);

    WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
    WriteByte (MSG_MULTICAST, TE_EXPLOSION);
    WriteCoord (MSG_MULTICAST, self.origin_x);
    WriteCoord (MSG_MULTICAST, self.origin_y);
    WriteCoord (MSG_MULTICAST, self.origin_z);
   	multicast (self.origin, MULTICAST_PHS);

    deathmsg = DMSG_EXPBODY;
    T_RadiusDamage (self.owner, self.owner, EXPBODY_DMG, self.owner);

//    self.owner.is_abouttodie = TRUE;

    dremove(self);
};

//===========================================//

void(vector where) spawnFOG =
{
    WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_TELEPORT);
	WriteCoord (MSG_MULTICAST, where_x);
	WriteCoord (MSG_MULTICAST, where_y);
	WriteCoord (MSG_MULTICAST, where_z);
	multicast (where, MULTICAST_PHS);
};

//=========================================================//
// called on any try to dismantle something from menu.qc
// returns true if the thing should be dismantled
float() CheckEnemyDismantle =
{
    if (Teammate(self.building.real_owner.team_no,self.team_no)) return TRUE;

    local string st;
    st=GetBuildingName(self.building); 
    
    if (GetICELevel(self.building) == 1 && random() > 0.5)
    {
        sprint(self, PRINT_HIGH, "This ");
        sprint(self, PRINT_HIGH, st);
        sprint(self, PRINT_HIGH, " isn't easy to dismantle, it has a level 1 ICE!\n");

        sprint(self.building.real_owner, PRINT_HIGH, "Somebody is trying to dismantle your ");
        sprint(self.building.real_owner, PRINT_HIGH,st);
        sprint(self.building.real_owner, PRINT_HIGH, "!\n");

        return FALSE;
    } 
    else if (GetICELevel(self.building) == 2)
    {
        sprint(self, PRINT_HIGH, "You can't dismantle this ");
        sprint(self, PRINT_HIGH, st);
        sprint(self, PRINT_HIGH, ", it's protected with a level 2 ICE!\n");

        sprint(self.building.real_owner, PRINT_HIGH, "Somebody tried to dismantle your ");
        sprint(self.building.real_owner, PRINT_HIGH,st);
        sprint(self.building.real_owner, PRINT_HIGH, "!\n");

        return FALSE;
    } 
    else if (GetICELevel(self.building) == 3)
    {
        sprint(self, PRINT_HIGH, "This ");
        sprint(self, PRINT_HIGH, st);
        sprint(self, PRINT_HIGH, " is protected with a level 3 ICE!\n");
        deathmsg=DMSG_ANTIDISM;
        TF_T_Damage(self, self, self.building, self.health + 50, TF_TD_IGNOREARMOUR, TF_TD_OTHER);
        sound (self, CHAN_MISC, "effects/crunch.wav", 1, ATTN_NONE);

        return FALSE;
    }
    
    bprint(PRINT_MEDIUM, self.building.real_owner.netname);
    bprint(PRINT_MEDIUM, "'s ");
    bprint(PRINT_MEDIUM, st);
    bprint(PRINT_MEDIUM, " has been dismantled by ");
    bprint(PRINT_MEDIUM, self.netname);
    bprint(PRINT_MEDIUM, "\n");

    sprint(self.building.real_owner, PRINT_HIGH, "The enemy has dismantled your ");
    sprint(self.building.real_owner, PRINT_HIGH, st);
    sprint(self.building.real_owner, PRINT_HIGH, "!\n");

    logfrag(self, self.building.real_owner);
	
    self.real_frags = self.real_frags + 1; 
	if (!(toggleflags & TFLAG_TEAMFRAGS))
    	self.frags = self.real_frags;

    return TRUE;
};

//- OfN - Checks spots are visible between them
float (vector spot1, vector spot2) vis2orig =
{
	traceline (spot1, spot2, TRUE, world);	// see through other monsters
	
	if (trace_inopen && trace_inwater)
		return FALSE;			// sight line crossed contents

	if (trace_fraction == 1 && trace_endpos == spot2) //CH just extra check
		return TRUE;
	return FALSE;
};

//=========================================================================
// Return the number of players in game
float() GetNoPlayers =
{
	local float num_players = 0;
	local entity search;

	search = find (world, classname, "player");
	while (search != world)
	{
    	num_players = num_players + 1;
		search = find (search, classname, "player");
	}

	return num_players;
};

//==================================================================
// prints the overall resutls, best player etc.. on intermission

entity() GetBestPlayer =
{
    local float bestscore;
    local entity theplayer, search;

    theplayer = world;
    search = world;
    bestscore = 0;

    search = find (world, classname, "player");
	while (search != world)
	{
        if (search.frags > bestscore)
        {
            bestscore = search.frags;
            theplayer = search;
        }

    	search = find (search, classname, "player");
	}

    return theplayer;
};

entity() GetBestKiller =
{
    local float bestscore;
    local entity theplayer, search;

    theplayer = world;
    search = world;
    bestscore = 0;

    search = find (world, classname, "player");
	while (search != world)
	{
        if (search.frags - TeamFortress_TeamGetScore(search.team_no) > bestscore && search.team_no > 0)
        {
            bestscore = search.frags - TeamFortress_TeamGetScore(search.team_no);
            theplayer = search;
        }

    	search = find (search, classname, "player");
	}

    return theplayer;
};

void() bprintline =
{
    bprint(PRINT_HIGH,"\nùûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûü\n\n");
};

void() PrintResults =
{
    local string winteam;
    local entity theplayer;    
    
    bprintline();

    if (time >= timelimit)
    {
        bprint(PRINT_HIGH,"Time limit reached!\n");
    }

    bprint(PRINT_HIGH,"Map ");
    bprint(PRINT_HIGH,mapname);
    bprint(PRINT_HIGH," was played for ");
    bprint(PRINT_HIGH,ftos(floor(time/60)));
    bprint(PRINT_HIGH," minutes.\n");

    bprint(PRINT_HIGH,"\nùûûûûûûûûûûü “ÂÛıÏÙÛ: ùûûûûûûûûûûûûü\n\n");
    
    winteam = GetTrueTeamName(TeamFortress_TeamGetWinner());

    if (winteam != "ERROR")
    {

        bprint(PRINT_HIGH,winteam);
        bprint(PRINT_HIGH," team ◊…Œ” the game!!\n\n");
    }

    bprint(PRINT_HIGH,"¬ÂÛÙ –Ï·˘ÂÚ: ");
    theplayer = GetBestPlayer();
    
    if (theplayer != world)
    {
        bprint(PRINT_HIGH,theplayer.netname);
        bprint(PRINT_HIGH," (");
        bprint(PRINT_HIGH,GetTrueTeamName(theplayer.team_no));
        bprint(PRINT_HIGH,") with ");
        bprint(PRINT_HIGH,ftos(floor(theplayer.frags)));
        bprint(PRINT_HIGH," frags.");
    }
    else
        bprint(PRINT_HIGH,"None.");
    
    bprint(PRINT_HIGH,"\nÀÈÏÏÈÓÁ Õ·„ËÈÓÂ: ");
    theplayer = GetBestKiller();
    
    if (theplayer != world)
    {
        bprint(PRINT_HIGH,theplayer.netname);
        bprint(PRINT_HIGH," (");
        bprint(PRINT_HIGH,GetTrueTeamName(theplayer.team_no));
        bprint(PRINT_HIGH,") with ");
        bprint(PRINT_HIGH,ftos(floor(theplayer.frags - TeamFortress_TeamGetScore(theplayer.team_no))));
        bprint(PRINT_HIGH," kills.");
    }
    else
        bprint(PRINT_HIGH,"None.");

    bprint(PRINT_HIGH,"\n");
    bprintline();
};

//======================================================================================
// called on clientobituary to check if warlock knife kills should be increased

void(entity attacker) MonsterKill =
{
    if (attacker.job & JOB_WARLOCK)
    if (deathmsg == DMSG_AXE || deathmsg == DMSG_BACKSTAB)
    if (attacker.demon_blood < MAX_KNIFE_BLOOD)
    	attacker.demon_blood = attacker.demon_blood + 1;    
};

//===============================================================================
// this function returns the max amount of grens a player can carry

float(entity theplayer, float grenslot) GetMaxGrens =
{
    if (theplayer.tf_items & NIT_AMMO_BANDOLIER) // player can carry more grens cause he got bandolier
	{
        if (grenslot == 2) //2nd slot
        {
            if (theplayer.tp_grenades_2 == 0)
                return 0;
            
            if (theplayer.tp_grenades_2 == GR_TYPE_NAIL)
                return 3;// was 1
            if (theplayer.tp_grenades_2 == GR_TYPE_FRAG)
                return 4;// was 1
            if (theplayer.tp_grenades_2 == GR_TYPE_CALTROP)
                return 4;// was 1
            if (theplayer.tp_grenades_2 == GR_TYPE_MIRV)
                return 3;// was 1
            if (theplayer.tp_grenades_2 == GR_TYPE_FLARE)
                return 8;            

            return 5;
        }
        else // first slot, or bug :)
        {
            if (theplayer.tp_grenades_1 == 0)
                return 0;

            if (theplayer.tp_grenades_1 == GR_TYPE_NAIL)
                return 3;// was 1
            if (theplayer.tp_grenades_1 == GR_TYPE_FRAG)
                return 4;// was 1
            if (theplayer.tp_grenades_1 == GR_TYPE_CALTROP)
                return 4;// was 1
            if (theplayer.tp_grenades_1 == GR_TYPE_MIRV)
                return 3;// was 1
            if (theplayer.tp_grenades_1 == GR_TYPE_FLARE)
                return 8;
            
            return 5;
        }        
    }
    
    if (grenslot == 2) //2nd slot
    {
        if (theplayer.tp_grenades_2 == 0)
            return 0;

        if (theplayer.tp_grenades_2 == GR_TYPE_NAIL)
            return 2;// was 1
        if (theplayer.tp_grenades_2 == GR_TYPE_FRAG)
            return 3;// was 1
        if (theplayer.tp_grenades_2 == GR_TYPE_CALTROP)
            return 3;// was 1
        if (theplayer.tp_grenades_2 == GR_TYPE_MIRV)
            return 2;// was 1
        if (theplayer.tp_grenades_2 == GR_TYPE_FLARE)
            return 6;

        return 4;
    }
    else // first slot, or bug :)
    {
        if (theplayer.tp_grenades_1 == 0)
            return 0;

        if (theplayer.tp_grenades_1 == GR_TYPE_NAIL)
            return 2;// was 1
        if (theplayer.tp_grenades_1 == GR_TYPE_FRAG)
            return 3;// was 1
        if (theplayer.tp_grenades_2 == GR_TYPE_CALTROP)
            return 3;// was 1
        if (theplayer.tp_grenades_1 == GR_TYPE_MIRV)
            return 2;// was 1
        if (theplayer.tp_grenades_1 == GR_TYPE_FLARE)
            return 6;
        
        return 4;
    }

    return 0; // shouldnt happen ever.
};

//=====================================================//

/*void(entity attacker) Check_PainInflictor =
{
    if (self.health <= 0)
        return;

    local entity real_attacker;
    real_attacker = attacker;

    if (!IsMonster(attacker) && attacker.classname!="player")
    {
        if (!IsMonster(atta
    }
      
    
    if (self.enemy!=self && self.enemy!=world && self.enemy!=attacker && self.enemy!=attacker.owner)
    {
        if (!visible(self.enemy))
        {
            

        }
    }
};*/
/*

void(entity player) SwitchToCamera =
{
    if (player.classname!="player")
    {
        RPrint("OFTEN BUG REPORT: Object '");
        RPrint(player.classname);
        RPrint("' in SwitchToCamera()\n");
        return;
    }

    local entity camera;
	local float done;
	
	if (!player.has_camera)
		return;
	if (player.is_cameraviewing)
		return;

     // FIXME: no inair, no water, no moving, no haxxxoring, no building, no detpacking, no throwing a det, 
     // no feinginG? (special)
	
	camera = find(world, classname, "building_camera");
	if (camera.real_owner == player)
		done = TRUE;
	while (!done)
	{
		camera = find(camera, classname, "building_camera");
		if (camera.real_owner == player)
			done = TRUE;
		if (camera == world)
			done = TRUE;
	}
	
	if (camera == world)
		return;
		
	/*
    
    msg_entity = player;
	WriteByte(MSG_ONE, SVC_SETVIEWPORT);
	WriteEntity(MSG_ONE, camera);
	WriteByte(MSG_ONE, SVC_SETANGLES);
	WriteAngle(MSG_ONE, camera.angles_x);
	WriteAngle(MSG_ONE, camera.angles_y);
	WriteAngle(MSG_ONE, camera.angles_z);
    
    */

    /*

    //- OfN create the "fake" player image
    newmis=spawn();
    newmis.solid = SOLID_BBOX; //SOLID_BSP
	newmis.movetype = MOVETYPE_NONE;
    newmis.takedamage = DAMAGE_AIM;
	newmis.origin = player.origin;
	newmis.angles = player.angles;
	newmis.colormap = player.colormap;
    newmis.skin = player.skin;
	setmodel (newmis, "progs/player.mdl");
    //setsize (newmis,????); // NEEDED?
    //setorigin (newmis, newmis.origin); // NEEDED?
	newmis.classname = "fake_player";
	newmis.owner=player;
	newmis.frame=player.frame;
	
    newmis.th_pain = FakePain;
    newmis.th_die = FakeDie;
    
    newmis.max_health = 9999;
    newmis.health = 9999;

    //newmis.nextthink = time + HOLO_CYCLE_TIME;	
	//newmis.think = HoloThink;
    //newmis.effects = EF_DIMLIGHT;
	//player.ammo_cells = player.ammo_cells - HOLO_POWER_COST;

	player.fixangle = TRUE;
	player.is_cameraviewing = TRUE;
	player.t_s_h = player.weaponmodel; // FIXME: reloadingø?
	player.weaponmodel= ""; // FIXME: reloadingø?
	player.view_ofs = '0 0 0';

    setorigin (player, camera.origin);

	sprint(player, PRINT_HIGH, "Camera view activated.\n");
};

void(entity player) SwitchFromCamera =
{
	if (player.classname!="player")
    {
        RPrint("OFTEN BUG REPORT: Object '");
        RPrint(player.classname);
        RPrint("' in SwitchFromCamera()\n");
        return;
    }
    
    if (!player.has_camera)
		return;
	if (!player.is_cameraviewing)
		return;
	
    /*
    
    msg_entity = player;
	WriteByte(MSG_ONE, SVC_SETVIEWPORT);
	WriteEntity(MSG_ONE, player);
	WriteByte(MSG_ONE, SVC_SETANGLES);
	WriteAngle(MSG_ONE, player.angles_x);
	WriteAngle(MSG_ONE, player.angles_y);
	WriteAngle(MSG_ONE, player.angles_z);
    
    */

    /*

	player.fixangle = FALSE;

	player.weaponmodel = player.t_s_h; // FIXME: reloadingø?
	player.view_ofs = '0 0 22';
	
	player.is_cameraviewing = FALSE;
};

*/

// hola
