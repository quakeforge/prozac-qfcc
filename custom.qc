/*======================================================
	CUSTOM.QC			Custom TeamFortress v3.2	

	(c) William Kerney			5/21/00
========================================================
All the functions pertaining to custom class generation and 
the miscellanious new features of Custom TF
======================================================*/

float(float t1, float t2) Teammate; //KK: are team_no's current teammates
void() DropToCustomClassGen; //Called when starting class generation
void() DropFromCustomClassGen; //Called when finished class generation
void() PrintMoney;
void(float in) PrintRefund;
void(float in) PrintNotEnoughMoney;
void(float cost, float type) BuyWeapon;
void(float cost, float type) BuyCuTF;
void(float cost, float type) BuyItem;
void(float cost, float type) BuyJob;
/*void(float cost, float type) BuyGren1;
void(float cost, float type) BuyGren2;*/
void(entity tif, float pain) RevealThief;
void() FragGrenadeTouch;
void() FragGrenadeExplode;
void() KracGrenadeTouch;
void() KracGrenadeExplode; 
void(entity bastard,float threshold) createBastard;
void(entity immuner,float timer) makeImmune;
void() UseJobSkill; //Function for handling professions
void() DetonateAllGuns;
void (string temp) DebugSprint;
void (float temp)  DebugSprintFloat;
float(entity tester) IsBuilding;
void() autoteam_think;
//Extern
void (vector org, entity death_owner) spawn_tdeath;
void (string gib, float health) ThrowGib;
void() TeamFortress_SetHealth;
void() TeamFortress_SetEquipment;
float() W_BestWeapon;
void() W_SetCurrentAmmo;
void(entity p) TeamFortress_SetSpeed;
void(entity p) TeamFortress_SetSkin;
void(entity Viewer, float pc) TeamFortress_PrintJobName;
void () BecomeExplosion;
void(entity bomb, entity attacker, float rad, entity ignore) T_RadiusDamage;
void() SUB_regen;
float modelindex_eyes, modelindex_player, modelindex_null;
void(float inAuto) W_FireMedikit;
void(float inAuto) TeamFortress_ID;
void(float range,float inAuto) TeamFortress_Scan;
void() kill_my_demon;
void() player_assaultcannondown1;
void (entity rhook) Reset_Grapple;
void() GuerillaExplode;
void(float krac) TeamFortress_DetpackStop;
void (float all) TeamFortress_TeamShowScores;
void () execute_changelevel;
void(entity Item, entity AP, float method) tfgoalitem_RemoveFromPlayer;

//- OfN
void(entity mine_owner) DetonateMines; //external, job.qc
string (float tno) TeamGetNiceColor;
void() SetArmyTimer; 
void() RemoveArmyTimer;
entity() SelectSpawnPoint;
void(entity tfield, vector where, entity thing) FieldExplosion;

//KK: are team_no's current teammates
float(float targteam, float attackteam) Teammate =
{
	local float teammask;

	if ( !targteam ) return #FALSE;
	if ( targteam == attackteam ) return #TRUE;
	if ( number_of_teams < 3 ) return #FALSE;

	if      ( targteam == 1 ) teammask = 1;
	else if ( targteam == 2 ) teammask = 2;
	else if ( targteam == 3 ) teammask = 4;
	else if ( targteam == 4 ) teammask = 8;

	if      ( attackteam == 1 && (friends1_mask & teammask)) return #TRUE;
	else if ( attackteam == 2 && (friends2_mask & teammask)) return #TRUE;
	else if ( attackteam == 3 && (friends3_mask & teammask)) return #TRUE;
	else if ( attackteam == 4 && (friends4_mask & teammask)) return #TRUE;

	return #FALSE;
};

void (string temp) DebugSprint =
{
	sprint(self,#PRINT_HIGH,temp);
	sprint(self,#PRINT_HIGH,"\n");
};

void (float foo)  DebugSprintFloat =
{
	local string temp;
	temp = ftos(foo);
	sprint(self,#PRINT_HIGH,temp);
	sprint(self,#PRINT_HIGH,"\n");
};


void() DropToCustomClassGen =
{
	local entity te;
	local float sell_no;
	local string st;
	sell_no = 0;

	self.gravity = 1;
	
    //st = infokey(world, "no_grapple");

    kill_my_demon();//FIXED?
	DetonateMines(self);
    RemoveArmyTimer();

    self.aura = 0;

    //Remove everything he's carrying	
	self.job = 0;
	self.is_malfunctioning = 0;
	//self.is_cameraviewing = 0;
	self.tf_items = 0;
	self.cutf_items = 0;
	self.tf_items_flags = 0;
	self.items = 0;
	self.ammo_rockets = 0;
	self.ammo_nails = 0;
	self.ammo_shells = 0;
	self.ammo_cells = 0;
	self.maxammo_rockets = 10; //Give em a minimal carrying capacity
	self.maxammo_nails = 10;
	self.maxammo_shells = 10;
	self.maxammo_cells = 10;
	self.maxammo_medikit = 0;
	self.maxammo_detpack = 0;
	self.ammo_c4det = 0;
	self.demon_one = world; //SB - this tells us who our demon is for easy reference
	self.demon_two = world; //- OfN-  Used for hacker job, target building and for timer (% on sbar)
	self.demon_blood = 0;
	//self.demon_points = 5;

    self.num_mines = 0; // OfN Number of mines set by the player

	self.no_grenades_1 = 0;
	self.no_grenades_2 = 0;
	self.tp_grenades_1 = 0;
	self.tp_grenades_2 = 0;

	self.armor_allowed = 0.3; //Red yellow or green
	self.armorclass = 0; //Red yellow or green
	self.armorvalue = 0; //200 etc
	self.maxarmor = 0;  //200 etc
	self.weapon = 0; // #WEAP_HOOK & #WEAP_SHOTGUN etc
	self.current_weapon = 0; // No current weapon
	
	if ((allow_hook) && (no_grapple != 1)) //If map allows it...
      	self.weapons_carried = #WEAP_HOOK; // Start with grapple
	else
	      self.weapons_carried = 0; // Or remove everything
	self.weaponmodel = ""; //Remove the model of a weapon in front

	self.solid = #SOLID_NOT;
	self.movetype = #MOVETYPE_NONE;
	self.takedamage = #DAMAGE_NO;

//Ready to buy
	self.maxspeed = 0; //Can't move while buying
	self.max_health = 50;
	self.health = 50;

#define PRICE_PER_FRAG 100
#define MAX_FRAGS_TO_SELL 50
//Calculate starting money
//This means the most someone can get is 50*100 = $5000
	if (self.done_custom & #CUSTOM_SELLING)
	{
		if (self.real_frags >= #MAX_FRAGS_TO_SELL)
			sell_no = #MAX_FRAGS_TO_SELL;
		else if (self.real_frags > 0)
			sell_no = self.real_frags;
		else {
			sell_no = 0;
			self.done_custom = self.done_custom - (self.done_custom & #CUSTOM_SELLING);
		}

		self.real_frags = self.real_frags - sell_no;
		self.frags = self.real_frags; //TODO: Make this work with TEAMFRAGS on
		self.money = custom_money + sell_no * #PRICE_PER_FRAG;
	}
	else
		self.money = custom_money;

	self.custom_speed = 250; //HWGUY Speed

	//Overrides the menu handler to always display my menu
	//Hack alert! This preserves the selling flag. :p
	if (self.done_custom & #CUSTOM_SELLING)
		self.done_custom = #CUSTOM_BUILDING | #CUSTOM_SELLING; 
	else
		self.done_custom = #CUSTOM_BUILDING; 
	
	//Destroy Buildings... again. :p
	DetonateAllGuns();

	//And then kill all demons I own
	
    //kill_my_demon();
    //DetonateMines(self);
    //RemoveArmyTimer();

      self.current_menu = #MENU_PRIMARY_WEAPON;
      Menu_PrimaryWeapon();
	return;
};

void(vector org) spawn_tfog;

void() DropFromCustomClassGen =
{
	local string scratch;

    //
	self.is_killed = #FALSE;
    //

    self.summon_one = world;
    self.summon_two = world;

    self.done_custom = #CUSTOM_FINISHED;
	self.maxspeed = self.custom_speed;
	self.gravity = 1;

	if (self.cutf_items & #CUTF_TOSSABLEDET)
		self.maxammo_detpack = 1;

	//Make sure they have at least one axe-like weapon
	if (!(self.weapons_carried & (#WEAP_MEDIKIT | #WEAP_SPANNER)) || (self.cutf_items & #CUTF_KNIFE))
		self.weapons_carried = self.weapons_carried | #WEAP_AXE;

	//CH if you bought Guerilla, you get 20 rockets :)
	if (self.job & #JOB_GUERILLA)
		self.maxammo_rockets = self.maxammo_rockets + 20;

    //OfN if we got the holo we get extra cells ammo space
    if (self.cutf_items & #CUTF_HOLO)
		self.maxammo_cells = self.maxammo_cells + 40;

	//If they bought weapons, remove their basic ammo allotment
	if (self.maxammo_rockets > 10)
		self.maxammo_rockets = self.maxammo_rockets - 10;
      if (self.maxammo_nails > 10)
		self.maxammo_nails = self.maxammo_nails - 10;
      if (self.maxammo_shells > 10)
		self.maxammo_shells = self.maxammo_shells - 10;
      if (self.maxammo_cells > 10)
		self.maxammo_cells = self.maxammo_cells - 10;

	//Increase their supply if they bought a backpack or bandolier
	if (self.tf_items & #NIT_AMMO_BACKPACK) {
		self.maxammo_rockets = self.maxammo_rockets + 30;
		self.maxammo_nails   = self.maxammo_nails   + 100;
		self.maxammo_shells  = self.maxammo_shells  + 100;
		if (self.weapons_carried & #WEAP_SPANNER)
			self.maxammo_cells   = self.maxammo_cells   + 170;
		else
			self.maxammo_cells   = self.maxammo_cells   + 50;
		if (self.maxammo_medikit > 0) //Only increase their medical supplies when...
			self.maxammo_medikit = self.maxammo_medikit + 70;
		if (self.maxammo_detpack > 0)
			self.maxammo_detpack = self.maxammo_detpack + 0.5;
	}
	if (self.tf_items & #NIT_AMMO_BANDOLIER) {
		self.maxammo_rockets = self.maxammo_rockets + 10;
		self.maxammo_nails   = self.maxammo_nails   + 50;
		self.maxammo_shells  = self.maxammo_shells  + 50;
		self.maxammo_cells   = self.maxammo_cells   + 30;
		if (self.maxammo_medikit > 0)
			self.maxammo_medikit = self.maxammo_medikit + 50;
		if (self.maxammo_detpack > 1) //Only give extra det if they bought both
			self.maxammo_detpack = 2;
	}

	//Clean up detpack fraction
	if (self.maxammo_detpack > 1 && self.maxammo_detpack < 2) 
		self.maxammo_detpack = 1;

	if (self.cutf_items & #CUTF_SENSOR) // SB
		self.maxammo_cells = self.maxammo_cells + 70;
	if (self.cutf_items & #CUTF_DISPENSER) // SB
		self.maxammo_cells = self.maxammo_cells + 100;
	if (self.cutf_items & #CUTF_FIELDGEN) // SB
		self.maxammo_cells = self.maxammo_cells + 140;

    //- OfN
    if (self.weapons_carried & #WEAP_LASERCANNON) self.maxammo_cells = self.maxammo_cells + 70;
    if (self.weapons_carried & #WEAP_SNG) self.maxammo_nails = self.maxammo_nails + 70;

	//Now cap the max ammo
	if (self.maxammo_rockets > 100)
		self.maxammo_rockets = 100;
      if (self.maxammo_nails > 350)
		self.maxammo_nails = 350;
      if (self.maxammo_shells > 300)
		self.maxammo_shells = 300;
      
      //- ofn
      if (self.tf_items & #NIT_AMMO_BANDOLIER && self.tf_items & #NIT_AMMO_BACKPACK)
      {
        if (self.maxammo_cells > 400) 
		    self.maxammo_cells = 400;
      }
      else if (self.tf_items & #NIT_AMMO_BACKPACK)
      {
        if (self.maxammo_cells > 360) // was 400
		    self.maxammo_cells = 360;
      }      
      else
      {
        if (self.maxammo_cells > 320) // was 400
		    self.maxammo_cells = 320;
      }
      

	//- OFN HERE FRONTLIN HELI BUG FIX ---//
    local entity spot;
    spot = SelectSpawnPoint ();

//	if (self.playerclass != #PC_UNDEFINED)
	//spawn_tdeath (spot.origin, self);

	self.observer_list = spot;
	self.origin = spot.origin + '0 0 1';
	self.angles = spot.angles;
	self.fixangle = #TRUE;		// turn this way immediately

	makevectors(self.angles);
	spawn_tfog (self.origin + v_forward*20);

    //------------------------------------//
    
    //Telefrag anyone sitting on top of us
	spawn_tdeath(self.origin,self);
	
	//Remove observer-like mode
	self.takedamage = #DAMAGE_AIM;
	//Prevent bad movetype errors, or something
	if (self.classname != "player") {
		RPrint("BUG BUG BUG BUG BUG BUG BUG BUG BUG\n");
		RPrint("Non-player was in custom class generation!\n");
		return;
	}
	self.movetype = #MOVETYPE_WALK;
	self.flags = #FL_CLIENT | #FL_ONGROUND;
	self.waterlevel = 0;
	self.air_finished = time + 12;
	self.solid = #SOLID_SLIDEBOX;
	self.pausetime = 0;

	//Remove invisibility
	//setmodel (self, "progs/eyes.mdl");
	//setmodel (self, "progs/player.mdl");
	self.modelindex = modelindex_player;

	// Stock him up
	// Display the Player's Class
	TeamFortress_PrintJobName(self,self.job);
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
	stuffcmd(self, "bf\n");

	ResetMenu();		
	self.impulse = 0;

	//Make them invincible if they bought respawn protection
	if (self.tf_items & #NIT_RESPAWN_GUARD) {
		self.items = self.items + #IT_INVULNERABILITY;
		self.invincible_time = 1;
		self.invincible_finished = time + #RESPAWN_GUARD_TIME;
		if (self.custom_speed > 300)
			self.invincible_finished = self.invincible_finished - 1;			
		if (self.custom_speed > 400)
			self.invincible_finished = self.invincible_finished - 1;			
	}

    //Come again!
	sprint(self,#PRINT_HIGH,"Type 'custom' at the console to build a new class.\n");

    //- OfN - Set army timer //
    if (self.job & #JOB_ARMY)
    {
        SetArmyTimer();
    }	
	
	return;
};

void() PrintMoney =
{
    if (pay_msgs != 1)
    	return;

	local string as;
	sprint(self,#PRINT_HIGH,"You have ");
	as = ftos(self.money);
	sprint(self,#PRINT_HIGH,as);
	sprint(self,#PRINT_HIGH," dollars left.\n");
	return;
};


void(float in) PrintRefund=
{
   	local string as;

    if (pay_msgs == 1)
    {
		sprint(self,#PRINT_HIGH,"You sell it back for ");
		as = ftos(in);
		sprint(self,#PRINT_HIGH,as);
		sprint(self,#PRINT_HIGH," dollars.\n");
    }

	self.money = self.money + in; //Give em a refund

    if (pay_msgs == 1)
    {
		sprint(self,#PRINT_HIGH,"You now have ");
		as = ftos(self.money);
		sprint(self,#PRINT_HIGH,as);
		sprint(self,#PRINT_HIGH," dollars available.\n");
    }

	return;
};

void(float in) PrintNotEnoughMoney =
{
    if (pay_msgs != 1)
    {
		sprint(self,#PRINT_HIGH,"Not enough money!\n");
		return;
    }

	local string as;
    
    sprint(self,#PRINT_HIGH,"Sorry, that costs ");
	as = ftos(in);
	sprint(self,#PRINT_HIGH,as);
	sprint(self,#PRINT_HIGH," dollars.\n");

	sprint(self,#PRINT_HIGH,"You only have ");
	as = ftos(self.money);
	sprint(self,#PRINT_HIGH,as);
	sprint(self,#PRINT_HIGH," dollars left.\n");
	return;
};

//Functions for determining ammo carrying capacity
float (float item) countshells =
{
/*	if (chris)
	{
		if (item == #WEAP_SHOTGUN) return 16;
		if (item == #WEAP_SPANNER) return 20;
		if (item == #WEAP_SUPER_SHOTGUN) return 32;
		if (item == #WEAP_ASSAULT_CANNON) return 75;
	}
	else
	{*/
		if (item == #WEAP_SHOTGUN) return 25;
		if (item == #WEAP_SPANNER) return 40;
		if (item == #WEAP_SUPER_SHOTGUN) return 50;
		if (item == #WEAP_ASSAULT_CANNON) return 100;
	//}
	return 0;
};
float (float item) countnails =
{
	/*if (chris)
	{
		if (item == #WEAP_MAUSER) return 10;
		if (item == #WEAP_TRANQ) return 20;
		if (item == #WEAP_LASER) return 10;
		if (item == #WEAP_NAILGUN) return 75;
		if (item == #WEAP_LIGHT_ASSAULT) return 100;
	}
	else
	{*/
		if (item == #WEAP_MAUSER) return 30;
		if (item == #WEAP_TRANQ) return 30;
		if (item == #WEAP_LASER) return 50;
		if (item == #WEAP_NAILGUN) return 100;
		if (item == #WEAP_LIGHT_ASSAULT) return 150;
	//}
	return 0;
};
float (float item) countrockets =
{
	/*if (chris)
	{
		if (item == #WEAP_SPANNER) return 2;
		if (item == #WEAP_ROCKET_LAUNCHER) return 3;
		if (item == #WEAP_GRENADE_LAUNCHER) return 7;
	}
	else
	{*/
		if (item == #WEAP_SPANNER) return 30;
		if (item == #WEAP_ROCKET_LAUNCHER) return 30;
		if (item == #WEAP_GRENADE_LAUNCHER) return 50;
	//}
	return 0;
};
float (float item) countcells =
{
	/*if (chris)
	{
		if (item == #WEAP_ASSAULT_CANNON) return 16;
		if (item == #WEAP_DAEDALUS) return 50;
		if (item == #WEAP_LIGHTNING) return 75;
		if (item == #WEAP_SPANNER) return 150;
	}
	else
	{*/
		if (item == #WEAP_ASSAULT_CANNON) return 50;
		if (item == #WEAP_DAEDALUS) return 100;
		if (item == #WEAP_LIGHTNING) return 100;
		if (item == #WEAP_SPANNER) return 150;
	//}
	return 0;
};

void(float cost, float item) BuyWeapon =
{
	if (item == 0) //Make sure we don't buy a null weapon
		return;
	
	if (self.weapons_carried & item) //We are selling
	{
		if (item == #WEAP_ROCKET_LAUNCHER && self.tf_items & #NIT_RL_LASER_SIGHT)
		{
			self.money = self.money + 1000;
			self.tf_items = self.tf_items - #NIT_RL_LASER_SIGHT;
		}
		if (item == #WEAP_ROCKET_LAUNCHER && self.tf_items & #NIT_CLUSTER_ROCKETS)
		{
			self.money = self.money + 3250;
			self.tf_items = self.tf_items - #NIT_CLUSTER_ROCKETS;
		}
		self.maxammo_shells = self.maxammo_shells - countshells(item);
		self.maxammo_nails = self.maxammo_nails - countnails(item);
		self.maxammo_rockets = self.maxammo_rockets - countrockets(item);
		self.maxammo_cells = self.maxammo_cells - countcells(item);
		PrintRefund(cost);
		self.weapons_carried = self.weapons_carried - item;
		return;
	}
	if (cost > self.money)
	{
		PrintNotEnoughMoney(cost);
		return;
	}
	//Add to max ammo
	self.maxammo_shells = self.maxammo_shells + countshells(item);
	self.maxammo_nails = self.maxammo_nails + countnails(item);
	self.maxammo_rockets = self.maxammo_rockets + countrockets(item);
	self.maxammo_cells = self.maxammo_cells + countcells(item);

	self.weapons_carried = self.weapons_carried | item;
	self.money = self.money - cost;
	PrintMoney();
};


void(float cost, float item) BuyCuTF =
{
	if (item == 0) //Make sure we don't buy a null weapon
		return;
	
	if (item == #CUTF_OTR && !(self.weapons_carried & #WEAP_SNIPER_RIFLE)) {
		sprint(self,#PRINT_HIGH,"These are special bullets for the sniper rifle, buy one first\n");
		return;
	}

	if (self.cutf_items & item) //We are selling
	{
		if (item == #CUTF_SENTRYGUN) {
			self.maxammo_shells = self.maxammo_shells - 130;
			self.maxammo_cells  = self.maxammo_cells  - 130;
		}
		PrintRefund(cost);
		self.cutf_items = self.cutf_items - item;
		return;
	}
	if (cost > self.money)
	{
		PrintNotEnoughMoney(cost);
		return;
	}
	//Add to max ammo if sentrygun purchase
	if (item == #CUTF_SENTRYGUN) {
		self.maxammo_shells = self.maxammo_shells + 130;
		self.maxammo_cells  = self.maxammo_cells  + 130;
	}

	self.cutf_items = self.cutf_items | item;
	self.money = self.money - cost;
	PrintMoney();
};

//CH gives ammo for items
void(float item) Apply_Item_Ammo =
{
	local float cellsfoo,rocketsfoo;
	cellsfoo = rocketsfoo = 0;

	if (item == #NIT_TESLA)
		cellsfoo = 150;
	if (item == #NIT_SECURITY_CAMERA)
		cellsfoo = 60;
	if (item == #NIT_TELEPORTER)
		cellsfoo = 100;

	if (item == #NIT_RL_LASER_SIGHT)
		rocketsfoo = 10;
	if (item == #NIT_CLUSTER_ROCKETS)
		rocketsfoo = 20;

	if (self.tf_items & item) { //we selling
		self.maxammo_cells = self.maxammo_cells - cellsfoo;
		self.maxammo_rockets = self.maxammo_rockets - rocketsfoo;
	}
	else {
		self.maxammo_cells = self.maxammo_cells + cellsfoo;
		self.maxammo_rockets = self.maxammo_rockets + rocketsfoo;
	}
};
void(float cost, float item) BuyItem =
{
	if (item == 0) //Make sure we don't buy a null item
		return;

	Apply_Item_Ammo(item); //CH

	if (self.tf_items & item) //We are selling
	{
		if (item == #NIT_HOVER_BOOTS && self.tf_items & #NIT_HOVER_BOOTS_UPGRADE) {
			self.money = self.money + 350; //sync with buying of upgrade
			item = item + #NIT_HOVER_BOOTS_UPGRADE;
		}

		PrintRefund(cost);
		self.tf_items = self.tf_items - item;
		return;
	}
	//Special rules
	if (item == #NIT_AUTOSCANNER && !(self.tf_items & #NIT_SCANNER)) {
		sprint(self,#PRINT_HIGH,"Sorry, you have to have the scanner first\n");
		return;
	}
	if ((item == #NIT_RL_LASER_SIGHT || item == #NIT_CLUSTER_ROCKETS) && !(self.weapons_carried & #WEAP_ROCKET_LAUNCHER)) {
		sprint(self,#PRINT_HIGH,"Sorry, you have to have the rocket launcher first\n");
		return;
	}
	if (item == #NIT_HOVER_BOOTS)
		sprint(self,#PRINT_HIGH,"Hold down jump to use the boots\n");
	if (item == #NIT_HOVER_BOOTS_UPGRADE && !(self.tf_items & #NIT_HOVER_BOOTS)) {
		sprint(self,#PRINT_HIGH,"Sorry, you have to have the hover boots first\n");
		return;
	}
	if (cost > self.money)
	{
		PrintNotEnoughMoney(cost);
		return;
	}

	self.tf_items = self.tf_items | item;
	self.money = self.money - cost;
	PrintMoney();
};

void(float cost, float type) BuyJob =
{
	if (type == 0) //Make sure we don't buy a null grenade
		return;
	
	if (type == self.job) //We are selling
	{
		if (self.job & #JOB_WARLOCK)
		{
			if (!(self.cutf_items & #CUTF_DEMONLORE))
				cost = cost - 300; // sync with demonlore cost
			else
				self.cutf_items = self.cutf_items - (self.cutf_items & #CUTF_DEMONLORE);
		}
		if (self.job & #JOB_RUNNER)
		{
			if (!(self.cutf_items & #CUTF_HIGHJUMP))
				cost = cost - 200; // sync with highjump cost
			else
				self.cutf_items = self.cutf_items - (self.cutf_items & #CUTF_HIGHJUMP);
		}
		if (self.job & #JOB_JUDOKA)
		{
			if (!(self.cutf_items & #CUTF_STEALTH))
				cost = cost - 400; // sync with stealth cost
			else
				self.cutf_items = self.cutf_items - (self.cutf_items & #CUTF_STEALTH);
		}
		PrintRefund(cost);
		self.job = 0;
		return;
	}
	if (cost > self.money)
	{
		PrintNotEnoughMoney(cost);
		return;
	}
	if (self.job) { //Make sure we haven't bought another kind already
		sprint(self,#PRINT_HIGH,"You already have a job. Leave your other one first.\n");
		return;
	}
	//Special rules for buying jobs
	if (type == #JOB_WARLOCK && !(self.cutf_items & #CUTF_KNIFE)) {
		sprint(self,#PRINT_HIGH,"Every Warlock needs a good bloody knife. Buy one.\n");
		return;
	}
	if (type == #JOB_WARLOCK)
		if (self.cutf_items & #CUTF_DEMONLORE)
			self.money = self.money + 300; // sync this with demonlore cost
		else
			self.cutf_items = self.cutf_items | #CUTF_DEMONLORE; // warlocks see demon health
	
	if (type == #JOB_RUNNER)
		if (self.cutf_items & #CUTF_HIGHJUMP)
			self.money = self.money + 200; // sync with highjump cost
		else
			self.cutf_items = self.cutf_items | #CUTF_HIGHJUMP; // runner jumps high
	
	if (type == #JOB_JUDOKA)
		if (self.cutf_items & #CUTF_STEALTH)
			self.money = self.money + 400; // sync with stealth price
		else
			self.cutf_items = self.cutf_items | #CUTF_STEALTH; // Judo is a master of stealth by default
	
	//Ok we buy it
	self.job = type;
	self.money = self.money - cost;
	PrintMoney();
};


void (float cost, float type) BuyGren =
{
	local string talk;
	///local float level; // This is the level of legs we have.
	
	if (type == 0) // if type is 0 we are buying the NULL GRENADE(tm)
	{
		sprint(self, #PRINT_HIGH, "Congratulations. You have just attempted to buy a null grenade.\n");
		dprint("WARNING: Attempted purchase of NULL GRENADE. BUG BUG BUG BUG BUG BUG BUG\n");
		return;
	}
	// Check whether we're allowing gren purchase.
	/*level = ReturnLegLevel(self.custom_speed);
	if (level == 1) // grens are a no-no
	{
		sprint(self, #PRINT_HIGH, "Sorry, you are not allowed any grenades at that speed. It is very dangerous.\n");
		return;
	}
	else if (level == 2)
	{
		local float acc; // Acceptable.
		
		acc = #FALSE;
		
		if (type == #GR_TYPE_CALTROP)
			acc = #TRUE;
		else if (type == #GR_TYPE_CONCUSSION)
			acc = #TRUE;
		else if (type == GR_TYPE_STASIS)
			acc = #TRUE;
		else if (type == #GR_TYPE_ANTIGRAV)
			acc = #TRUE;
		else if (type == #GR_TYPE_FLARE)
			acc = #TRUE;
		if (!acc)
		{
			sprint(self, #PRINT_HIGH, "Sorry, using those grenades at your speed could be dangerous.\n");
			return;
		}
	}
	else if (level == 3)
	{
		if (type == #GR_TYPE_MIRV)
		{
			sprint(self, #PRINT_HIGH, "Sorry, you aren't allowed MIRVs at that speed.\n");
			return;
		}
	}*/
	// Grenade and speed is fine.
	
	if (!self.tp_grenades_1 && cost <= self.money) // if we don't have gren1s, make it a gren1
	{
/*		if (self.money_misc + cost > self.money_spent - self.money_misc)
		{
			PrintTooHighProportion();
			return;
		} */
		self.tp_grenades_1 = type;
		//sprint(self, #PRINT_HIGH, "You buy the grenades and add them to your first grenade slot for ");
	}
	else if (!self.tp_grenades_2 && cost <= self.money) // We already have gren1s, can we buy gren2s?
	{
		/*if (self.money_misc + cost > self.money_spent - self.money_misc)
		{
			PrintTooHighProportion();
			return;
		}*/
		self.tp_grenades_2 = type;
		//sprint(self, #PRINT_HIGH, "You buy the grenades and add them to your second grenade slot for ");
	}
	else	// We have both gren1s and gren2s so now we need to try to sell some
	{		// If our type matches gren1 AND gren2s we want to sell both
		if (self.tp_grenades_1 == type && self.tp_grenades_2 == type)
		{
			PrintRefund(cost * 2);
			//self.money_misc = self.money_misc - cost * 2;
            //self.money = self.money + cost * 2; //*2
			self.tp_grenades_1 = 0;
			self.tp_grenades_2 = 0;
		}
		else if (self.tp_grenades_1 == type) // otherwise if our gren1s are the type
		{
			PrintRefund(cost);
			//self.money_misc = self.money_misc - cost;
            //self.money = self.money + cost;
			self.tp_grenades_1 = 0;
		}
		else if (self.tp_grenades_2 == type) // otherwise if we have gren2s as the type..
		{
			PrintRefund(cost);
			//self.money_misc = self.money_misc - cost;
            //self.money = self.money + cost;
			self.tp_grenades_2 = 0;
		}
		else if (cost <= self.money)
			sprint(self,#PRINT_HIGH,"You already have a full set of grenades. Sell some back first.\n");
		else
			PrintNotEnoughMoney(cost);
		
		return;
	}
	self.money = self.money - cost;
	//self.money_misc = self.money_misc + cost;
	//self.money_spent = self.money_spent + cost;
	/*talk = ftos(cost);
	sprint(self, #PRINT_HIGH, talk);
	sprint(self, #PRINT_HIGH, " dollars. You have ");
	talk = ftos(self.money);
	sprint(self, #PRINT_HIGH, talk);
	sprint(self, #PRINT_HIGH, " dollars left.\n");*/
};
/*

void(float cost, float type) BuyGren1 =
{
	if (type == 0) //Make sure we don't buy a null grenade
		return;
	
	if (type == self.tp_grenades_1) //We are selling
	{
		PrintRefund(cost);
		self.tp_grenades_1 = 0;
		return;
	}
	if (cost > self.money)
	{
		PrintNotEnoughMoney(cost);
		return;
	}
	if (self.tp_grenades_1) { //Make sure we haven't bought another kind already
		sprint(self,#PRINT_HIGH,"You already have grenades. Sell back the ones you bought first.\n");
		return;
	}
	//Ok we buy it
	self.tp_grenades_1 = type;
	self.money = self.money - cost;
	PrintMoney();
};

void(float cost, float type) BuyGren2 =
{
	if (type == 0) //Make sure we don't buy a null grenade
		return;
	
	if (type == self.tp_grenades_2) //We are selling
	{
		PrintRefund(cost);
		self.tp_grenades_2 = 0;
		return;
	}
	if (cost > self.money)
	{
		PrintNotEnoughMoney(cost);
		return;
	}
	if (self.tp_grenades_2) { //Make sure we haven't bought another kind already
		sprint(self,#PRINT_HIGH,"You already have grenades. Sell back the ones you bought first.\n");
		return;
	}

	//Ok we buy it
	self.tp_grenades_2 = type;
	self.money = self.money - cost;
	PrintMoney();
};
*/

//Functions for our new grenades
void() fragspike_touch =
{
	//if (pointcontents(self.origin) == #CONTENT_SKY)
	if (pointcontents(self.origin) != #CONTENT_EMPTY)
	{
		dremove(self);
		return;
	}
	
// hit something that bleeds
	if (other.takedamage)
	{
		deathmsg = #DMSG_GREN_FRAG;

		TF_T_Damage (other, self, self.real_owner, 150, #TF_TD_NOTTEAM, #TF_TD_NAIL);
		dremove(self);
	}
	else
	{
		//We bounce off world since we are fragments
		if (self.heat > 0) {
//			self.heat = self.heat - 1;
//			if (self.velocity = '0 0 0') { //Skip around
			if (1) { //Skip around
				self.velocity_x = (random() - 0.5) * 200;
				self.velocity_y = (random() - 0.5) * 200;
				self.velocity_z = random() * 200;
			}
		}
		else {
            if (other.classname == "force_field") //- OfN - Makes field explosion b4 removing it
               FieldExplosion(other,self.origin,self);
            else
            {
                WriteByte (#MSG_BROADCAST, #SVC_TEMPENTITY);
                WriteByte (#MSG_BROADCAST, #TE_SUPERSPIKE);
                WriteCoord (#MSG_BROADCAST, self.origin_x);
                WriteCoord (#MSG_BROADCAST, self.origin_y);
                WriteCoord (#MSG_BROADCAST, self.origin_z);
            #ifdef QUAKE_WORLD
                multicast (self.origin, #MULTICAST_PHS);
            #endif
            }

			dremove(self);
		}
	}
};
void() FragSpikeThink =
{
	if (self.heat > 0) {
		self.heat = self.heat - 1;

		self.angles_y = random() * 360;
		self.angles_x = 0;
		self.angles_z = 0;
		makevectors(self.angles);
		if (self.velocity = '0 0 0')
			self.origin_z = self.origin_z + 50;

		self.velocity = v_forward * 1000;
		self.velocity_z = (random() + 0.25) * 1000;

		self.nextthink = time + 0.5 + random();
	}
	else {
		WriteByte (#MSG_BROADCAST, #SVC_TEMPENTITY);
		WriteByte (#MSG_BROADCAST, #TE_SUPERSPIKE);
		WriteCoord (#MSG_BROADCAST, self.origin_x);
		WriteCoord (#MSG_BROADCAST, self.origin_y);
		WriteCoord (#MSG_BROADCAST, self.origin_z);
	#ifdef QUAKE_WORLD
		multicast (self.origin, #MULTICAST_PHS);
	#endif						
		dremove(self);
	}
};

void() FragGrenadeTouch =
{
	if (other == self.owner)
		return;		// don't explode on owner

	// Thrown grenades don't detonate when hitting an enemy

	sound (self, #CHAN_WEAPON, "weapons/bounce.wav", 1, #ATTN_NORM);	// bounce sound
	if (self.velocity == '0 0 0')
		self.avelocity = '0 0 0';
};
void() FragGrenadeExplode =
{
	local float shraps;
	local string happy;
	local entity newmis;

//Small explosive radius
	deathmsg = #DMSG_GREN_HAND;
	T_RadiusDamage (self, self.owner, 80, world);

	WriteByte (#MSG_BROADCAST, #SVC_TEMPENTITY);
	WriteByte (#MSG_BROADCAST, #TE_EXPLOSION);
	WriteCoord (#MSG_BROADCAST, self.origin_x);
	WriteCoord (#MSG_BROADCAST, self.origin_y);
	WriteCoord (#MSG_BROADCAST, self.origin_z);
#ifdef QUAKE_WORLD
	multicast (self.origin, #MULTICAST_PHS);
#endif

	shraps = rint(6 * random()) + 6; //Pieces of shrapmetal;
	while (shraps > 0) {
		self.angles_y = random() * 360;
		self.angles_x = 0;
		self.angles_z = 0;
		makevectors(self.angles);

		deathmsg = #DMSG_GREN_NAIL;
		newmis = spawn ();
		//WK Make shraps hit owner newmis.owner = self.owner;
		newmis.real_owner = self.owner;
		newmis.movetype = #MOVETYPE_BOUNCE;
		newmis.solid = #SOLID_BBOX;

		newmis.angles = '0 0 0';
		newmis.classname = "spike";
		newmis.think = FragSpikeThink;
//		newmis.think = SUB_Remove;
		newmis.nextthink = time + 1;
		setmodel (newmis, "progs/spike.mdl");
		setsize (newmis, #VEC_ORIGIN, #VEC_ORIGIN);		
		setorigin (newmis, self.origin);

		//Start it over the ground
		newmis.origin_z = newmis.origin_z + 10;

		newmis.velocity = v_forward * 1000;
		if (random() < 0.5) 
			newmis.velocity_z = 20;
		else
			newmis.velocity_z = random() * 1000;
		newmis.avelocity = '100 100 100';
		newmis.touch = fragspike_touch;
		newmis.weapon = #DMSG_GREN_NAIL;

		//Make it bounce six times.
		newmis.heat = 5;
		shraps = shraps - 1;
	}
#ifdef QUAKE_WORLD
	WriteByte (#MSG_BROADCAST, #SVC_TEMPENTITY);
	WriteByte (#MSG_BROADCAST, #TE_EXPLOSION);
	WriteCoord (#MSG_BROADCAST, self.origin_x);
	WriteCoord (#MSG_BROADCAST, self.origin_y);
	WriteCoord (#MSG_BROADCAST, self.origin_z);
	multicast (self.origin, #MULTICAST_PHS);
	dremove(self);
#else
	BecomeExplosion();
#endif

};

void() KracGrenadeTouch =
{
	//WK Have it detonate on impact
	if (other == self.owner)
		return;		// don't explode on owner

	sound (self, #CHAN_WEAPON, "weapons/bounce.wav", 1, #ATTN_NORM);	// bounce sound
	
	KracGrenadeExplode();
};

void() KracGrenadeExplode =
{
	local entity te,newmis;
	local entity oldself;
	te = findradius(self.origin, 150);
	while (te)
	{	
		// Player?
		if (te.classname == "player")
		{
			//WW: Kracs disable detpack
			oldself = self;
			self = te;
			TeamFortress_DetpackStop(#TRUE);
			self = oldself;
			//Gel armor makes kracs do less damage
			if (te.armorclass & #AT_SAVEMELEE) {
				if (te.armorvalue > 75)
					te.armorvalue = 75;
			} else {
				if (te.armorvalue > 10)
					te.armorvalue = 10;
			}
			te.ammo_cells = 0; //Kill their metal supply too
		}
		else if (te.classname == "pipebomb")
			te.nextthink = time + 0.1 + random();
		else if (te.classname == "grenade" && te.netname == "land_mine")
		{
			te.think = GuerillaExplode;
			te.nextthink = time + 0.1;
		}
		else if (te.classname == "building_sentrygun")
			TF_T_Damage(te, self, self.owner, 200, 0, 0);
		else if (te.classname == "building_tesla")
			TF_T_Damage(te, self, self.owner, 200, 0, 0);
		else if (te.classname == "building_dispenser")
			TF_T_Damage(te, self, self.owner, 500, 0, 0);
		else if (te.classname == "building_camera")
			TF_T_Damage(te, self, self.owner, 400, 0, 0);
		else if (te.classname == "building_teleporter")
			TF_T_Damage(te, self, self.owner, 200, 0, 0);
        else if (te.classname == "building_sensor") //- Often - needed?
			TF_T_Damage(te, self, self.owner, 200, 0, 0);
		else if (te.classname == "item_armor1" || te.classname == "item_armor2" || te.classname == "item_armorInv") {
			te.solid = #SOLID_NOT;
			te.model = string_null;
			te.nextthink = time + 45; //WK 20
			te.think = SUB_regen;
			//SUB_UseTargets();	
		}
		else if (te.classname == "detpack") {
			if (te.owner.netname != self.owner.netname) {
				bprint (#PRINT_MEDIUM, te.owner.netname);
				bprint (#PRINT_MEDIUM, "'s detpack was Kraced by ");
				bprint (#PRINT_MEDIUM, self.owner.netname);
				bprint (#PRINT_MEDIUM, "\n");
			} else {
				sprint (te.owner, #PRINT_MEDIUM, "You Kraced your own detpack!\n");
			}
			// This code handles disarming a detpack
			if (te.weaponmode == 1)	// Detpack was being disarmed
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
			else { //Not being disarmed
				dremove(te.oldenemy);  	 // CountDown
			}
			te.think = BecomeExplosion;
			te.nextthink = time + 0.1;
		}
		te = te.chain;
	}

#ifdef QUAKE_WORLD
	WriteByte (#MSG_BROADCAST, #SVC_TEMPENTITY);
	WriteByte (#MSG_BROADCAST, #TE_EXPLOSION);
	WriteCoord (#MSG_BROADCAST, self.origin_x);
	WriteCoord (#MSG_BROADCAST, self.origin_y);
	WriteCoord (#MSG_BROADCAST, self.origin_z);
	multicast (self.origin, #MULTICAST_PHS);
	dremove(self);
#else
	BecomeExplosion();
#endif
};

//Stops us from lowering the time immunity
void(entity immuner,float timeimmune) makeImmune =
{
	if (immuner == world) return;
	if (immuner.immune_to_chec > timeimmune) return;
	immuner.immune_to_chec = timeimmune;
};

void() BastardTimer =
{
	local entity te;
	local string st;
	te = self.owner;

	//makeImmune(te,time+5);

	if (te.penance_time < time)
	{
		stuffcmd(te, "cl_yawspeed 140;-right;-left\n");
		//stuffcmd(te, "name \"");
		//stuffcmd(te, te.old_netname);
		//stuffcmd(te, "\"\n");

		//Reset their color
		stuffcmd(te, "color ");
		st = ftos(TeamFortress_TeamGetColor(te.team_no) - 1);
        
        //- OfN - Nice colors
        if (nicecolors==1) st =TeamGetNiceColor(te.team_no);

		stuffcmd(te, st);
		stuffcmd(te, "\n");

		bprint (#PRINT_MEDIUM, te.netname);
		bprint (#PRINT_MEDIUM, " has his teamkill curse removed\n");

		//Don't let up on them. Two more teamkills and its back into the tarpit for them
		te.ff_count = self.frags - 1.9;
		if (te.ff_count < 0) te.ff_count = 0;
		
		TF_T_Damage(te, world, world, te.health + 300, #TF_TD_IGNOREARMOUR, #TF_TD_OTHER);
		
		remove(self);
		return;
	}

	if (random() > 0.5) 
		stuffcmd(te, "cl_yawspeed 500;-left;+right;color 8 8\n");
	else
		stuffcmd(te, "cl_yawspeed 500;-right;+left;color 9 9\n");
	//te.immune_to_check = time + 5;
	te.ammo_rockets = 0;
	te.ammo_cells = 0;
	te.ammo_nails = 0;
	te.ammo_shells = 0;
	te.ammo_detpack = 0;
	te.ammo_c4det = 0;
      te.no_grenades_1 = 0;
      te.no_grenades_2 = 0;
	if (te.health > 50) te.health = 50;
	if (te.armorvalue > 10) te.armorvalue = 10;

	self.nextthink = time + 2;
};

void(entity bastard,float threshold) createBastard =
{
	local entity te;

	if (bastard == world) return;

	if (bastard.penance_time > time) {
		bastard.ff_count = bastard.ff_count - 1; //Dont count it
		bastard.penance_time = time + 60; //Just reset the clock
		makeImmune(bastard,time+65);
		return;
	}

    //---------------------------------------------------------------------------//
	// Why do I not like MegaTF? ------------------------------------------------//
	// Look at http://www.planetfortress.com/history/people/shaka.html ----------//
	if (bastard.ff_count == threshold + 0.1 || bastard.ff_count == threshold + 0.6) {
		//- OfN - lol
        //bprint(#PRINT_HIGH,"‘…Õ≈ ‘œ À…√À »…M\n");
        bprint(#PRINT_HIGH,"ok, lets send ");
        bprint(#PRINT_HIGH,bastard.netname);
        bprint(#PRINT_HIGH," to a nice megaTF server...\n");
        stuffcmd(bastard, "name \"CustomTF reject-wanna play Mega\"\n");        
        //stuffcmd(bastard, "name \"im gay, wanna make new friends\"\n");  
        
		local string st;
#ifdef QUAKE_WORLD
		st = infokey(world,"curseserver");
#endif
		//if (st == string_null) st = "207.171.0.74";
		if (st == string_null) st = "209.39.192.74:27500";
        stuffcmd(bastard, "connect ");
		stuffcmd(bastard, st);
		stuffcmd(bastard, "\n");

        return; //- OfN - (missing) OLD BUG?
	} //---------------------------------------------------------------------------//


	newmis = spawn();

	newmis.classname = "timer";
	newmis.netname = "bastardtimer";
	newmis.owner = bastard;
	newmis.think = BastardTimer;
	newmis.nextthink = time + 1;
	newmis.frags = threshold; //Let the timer know what the thresh is
	makeImmune(bastard,time+65);
	//bastard.immune_to_check = time + 65; //Make him immune while purple
	//bastard.old_netname = bastard.netname;

	bprint (#PRINT_MEDIUM, bastard.netname);
	bprint (#PRINT_MEDIUM, " has been struck down by the wrath of the admin.\n");
	bprint (#PRINT_MEDIUM, "Feel free to frag him at will.\n");

	bastard.penance_time = time + 60;
	stuffcmd(bastard, "name \"‘Â·ÌÀÈÏÏÂÚ (");
//	stuffcmd(bartard, "name \"\<TeamKiller\> (");
	stuffcmd(bastard, bastard.netname);
	stuffcmd(bastard, ")\"\n");

	// Drop any GoalItems
	te = find (world, classname, "item_tfgoal");
	while (te)
	{
		if (te.owner == bastard)
		{
			// Remove it from the player, if it is supposed to be
			if (!(te.goal_activation & #TFGI_KEEP))
			{
				tfgoalitem_RemoveFromPlayer(te, bastard, 0);
			}

			// CTF support
			if (CTF_Map == #TRUE && te.goal_no == #CTF_FLAG1)
			{
				bprint(#PRINT_HIGH, bastard.netname);
      			bprint(#PRINT_HIGH, " Ãœ”‘ the ¬Ã’≈ flag!\n");
			}
			else if (CTF_Map == #TRUE && te.goal_no == #CTF_FLAG2)
			{
				bprint(#PRINT_HIGH, bastard.netname);
                bprint(#PRINT_HIGH, " Ãœ”‘ the “≈ƒ flag!\n");
			}

		}
		te = find(te, classname, "item_tfgoal");
	}

	return;
};

void() Autoitem_think =
{
	local entity oself;
	local float happy;
	if (self.heat == #TRUE)
		self.heat = #FALSE;
	else
		self.heat = #TRUE;
	happy = self.heat;

	oself = self;
	self = self.owner;
	if (self.tf_items & #NIT_AUTOID) {
		//Do an id
		TeamFortress_ID(#TRUE); //TRUE means we are in autoitemthink
	}
	if (self.weapons_carried & #WEAP_MEDIKIT) {
		//Do a heal, passing it #TRUE tells it not to "tink"
		//Don't automedic whack while fully invisible
		if (!(self.job & #JOB_THIEF && (self.job & #JOB_ACTIVE || self.job & #JOB_FULL_HIDE)))
			W_FireMedikit(#TRUE);
	}
	if (happy) { //Only do this every two seconds
	if (self.tf_items & #NIT_AUTOSCANNER) {
		//Do a scan15
		TeamFortress_Scan(15,#TRUE);
	}
	}

	self = oself;
	self.nextthink = time + 0.5;
};

void() custom_lay =
{
	local string st;
	if (self.last_saveme_sound < time) {
		bprint(#PRINT_HIGH,self.netname);
		bprint(#PRINT_HIGH,"'s legs were broken when he tried to 'lay'\n");
		sound(self,#CHAN_VOICE,"player/pain1.wav",1,#ATTN_NONE);
		self.last_saveme_sound = time + 60;
	}
	self.suicide_time = time + 60;
	self.leg_damage = 9;
	TeamFortress_SetSpeed(self);
	if (self.health > 50) self.health = 50;
	if (self.armorvalue > 10) self.armorvalue = 10;
};

//Blow up all sentries, dispensers and teslas if we can no longer build them
void() DetonateAllGuns =
{
	if (!(self.cutf_items & #CUTF_DISPENSER))
		Find_And_Dmg("building_dispenser", self, 1);
	if (!(self.cutf_items & #CUTF_SENTRYGUN)) 
		Find_And_Dmg("building_sentrygun", self, 1);
	if (!(self.tf_items & #NIT_TESLA)) //WK
		Find_And_Dmg("building_tesla", self, 1);
	if (!(self.tf_items & #NIT_SECURITY_CAMERA)) //CH
		Find_And_Dmg("building_camera", self, 1);
	if (!(self.tf_items & #NIT_TELEPORTER)) //CH
		Find_And_Dmg("building_teleporter", self, 1);
	if (!(self.cutf_items & #CUTF_SENSOR)) //SB
		Find_And_Dmg("building_sensor", self, 1);
    if (!(self.cutf_items & #CUTF_FIELDGEN)) //OfN
		Find_And_Dmg("building_fieldgen", self, 1);
};

//Blow up all sentries, dispensers and teslas if we can no longer build them
void() DetonateAllGunsForced =
{
    Find_And_Dmg("building_dispenser", self, 1);
	Find_And_Dmg("building_sentrygun", self, 1);
	Find_And_Dmg("building_tesla", self, 1);
	Find_And_Dmg("building_camera", self, 1);
	Find_And_Dmg("building_teleporter", self, 1);
	Find_And_Dmg("building_sensor", self, 1);
    Find_And_Dmg("building_fieldgen", self, 1);
};

//Returns true if the entity is a building -- UPDATE THIS WHEN A NEW ONE IS ADDED
float(entity tester) IsBuilding =
{
	if (
		tester.classname == "building_sentrygun" ||
		tester.classname == "building_sentrygun_base" ||
		tester.classname == "building_tesla" ||
		tester.classname == "building_dispenser" ||
		tester.classname == "building_camera" ||
		tester.classname == "building_arawana" ||
		tester.classname == "building_teleporter"||
   		tester.classname == "building_fieldgen"||
		tester.classname == "building_sensor"
	   )
		return #TRUE;
	return #FALSE;
};
