/*======================================================
	MENU.QC			Custom TeamFortress v2.3	

	(c) TeamFortress Software Pty Ltd 	29/2/97
	(c) William Kerney			         4/4/00
	(c) Craig Hauser				    19/3/00
========================================================
This file handles all menu functions and displays.
======================================================*/

#include "defs.qh"
#include "messages.qh"
#include "menu.qh"

void(vector where) spawnFOG;
void(entity pl, string s1, string s2, string s3, string s4) CenterPrint4;
void(entity pl, string s1, string s2, string s3, string s4, string s5, string s6, string s7) CenterPrint7;


void(entity targ, entity inflictor, entity attacker, float damage, float T_flags, float T_AttackType) TF_T_Damage;
void() W_SetCurrentAmmo;
void(entity p) bound_other_ammo;
float(float tno) TeamFortress_TeamSet;
void(entity p) TeamFortress_SetSkin;
float(float tno) TeamGetColor;
void() TeamFortress_ChangeClass;
void(float type) TeamFortress_DropAmmo;
float() TeamFortress_TeamPutPlayerInTeam;
float(float tno) TeamFortress_TeamIsCivilian;
void(float class) TeamFortress_SpyChangeSkin;
void(float teamno) TeamFortress_SpyChangeColor;
void(float building) TeamFortress_Build;
void(float type) TeamFortress_SpyFeignDeath;
void(entity spy) Spy_RemoveDisguise;
void() lvl1_sentry_stand;
void() lvl2_sentry_stand;
void() lvl3_sentry_stand;
float (float tno) TeamFortress_TeamGetNoPlayers;
float(float myteam) HasFlag; 
void() PrintMOTD;

/* WK void(float menu_no) DisplayMenu; */
// Assorted menus
void() Menu_Team;
void() Menu_Class;
void() Menu_Drop;
void() Menu_Intro;
void() PlayerObserverMode;
// Classhelp
void() Menu_ClassHelp;
void() Menu_ClassHelp2;
void() Menu_StuffClassHelp;
void(float inp) Menu_ClassHelp_Input;
// Bindings
void() Menu_DoBindings;
void() Menu_ShowBindings1;
void() Menu_ShowBindings2;
void() Menu_RepeatHelp;
// Spy
void() Menu_Spy;
void() Menu_Spy_Skin;
void() Menu_Spy_Color;
void(float inp) Menu_Spy_Input;
void(float inp) Menu_Spy_Skin_Input;
void(float inp) Menu_Spy_Color_Input;
// Engineer
void() Menu_Engineer;
void() Menu_EngineerFix_Dispenser;
void() Menu_EngineerFix_SentryGun;
void() Menu_EngineerFix_Tesla;
void() Menu_EngineerFix_Tesla2;
void() Menu_EngineerFix_Camera;
void() Menu_EngineerFix_Sensor;
void() Menu_EngineerFix_Teleporter;
void() Menu_EngineerFix_FieldGen;
void(float inp) Menu_Engineer_Input;
void(float inp) Menu_EngineerFix_Dispenser_Input;
void(float inp) Menu_EngineerFix_SentryGun_Input;
void(float inp) Menu_EngineerFix_Tesla_Input;
void(float inp) Menu_EngineerFix_Tesla_Input2;
void(float inp) Menu_EngineerFix_Camera_Input;
void(float inp) Menu_EngineerFix_Sensor_Input;
void(float inp) Menu_EngineerFix_Teleporter_Input;
void(float inp) Menu_EngineerFix_FieldGen_Input;

// Demons
void() Menu_Demon;
void(float inp) Menu_Demon_Input;
void() kill_my_demon;

// Buildings
void() Menu_Dispenser;
void(float inp) Menu_Dispenser_Input;
void(entity pl, string s1) CenterPrint;
void(entity pl, string s1, string s2) CenterPrint2;
float(entity obj, entity builder) CheckArea;

// WK - Custom Class
void() DropFromCustomClassGen; //Extern
void() PrintMoney;
void(float cost,float type) BuyWeapon;
void(float cost,float type) BuyCuTF;
void(float cost,float type) BuyItem;
void(float cost, float type) BuyJob;
/*void(float cost,float type) BuyGren1;
void(float cost,float type) BuyGren2;*/
void(float in) PrintRefund;
void(float in) PrintNotEnoughMoney;
void() Menu_PrimaryWeapon;
void(float inp) Menu_PrimaryWeapon_Input;
void() Menu_SecondaryWeapon;
void(float inp) Menu_SecondaryWeapon_Input;
//- Ofn -
void() Menu_MiscWeapon;
void(float inp) Menu_MiscWeapon_Input;
void() Menu_Crusader;
void(float inp) Menu_Crusader_Input;


void() Menu_Legs;
void(float inp) Menu_Legs_Input;
void() Menu_Health;
void(float inp) Menu_Health_Input;
void() Menu_Armor;
void(float inp) Menu_Armor_Input;
void() Menu_Special;
void(float inp) Menu_Special_Input;
void() Menu_Special2;
void(float inp) Menu_Special2_Input;
void() Menu_Gren1;
void(float inp) Menu_Gren1_Input;
void() Menu_Gren2;
void(float inp) Menu_Gren2_Input;
void() Menu_Engineering;
void(float inp) Menu_Engineering_Input;
void() Menu_Profession;
void(float inp) Menu_Profession_Input;
void() Menu_Profession2;
void(float inp) Menu_Profession2_Input;
void() Menu_Proficiency;
void(float inp) Menu_Proficiency_Input;
void() Menu_Option;
void(float inp) Menu_Option_Input;

//WK Needed for rotate
float(float v) anglemod;
//WK Needed to det sentries et al.
void(entity inflictor, entity attacker, float damage, entity ignore) T_RadiusDamage;
//WK Needed to make a bastard
void(entity bastard,float threshold) createBastard;
//CY Tinker
void() DoTinker;

// WK --------------

//- OfN - Warlock menu (now in warlock.qc) --//
void(float inp) Menu_Demon_Input;            //
void() Menu_Demon;                           //
//-------------------------------------------//
//- OfN - Army menu (now in army.qc) --------//
void(float inp) Menu_Army_Input;             //
void() Menu_Army;                            //
//-------------------------------------------//
//- OfN - Hack menu (now in haxxx.qc) -------//
void(float inp) Menu_EnemyHax_Inp;           //
void() Menu_Enemy_Hax;                       //
void(float inp) Menu_FriendHax_Inp;          //
void() Menu_Friend_Hax;                      //
//-------------------------------------------//
float() CheckEnemyDismantle;
void() SBBuildSensor;
void() Tesla_Lose_Glow;
entity(entity OldTesla) TeslaClone;
float(entity theplayer, float grenslot) GetMaxGrens;
void (float cost, float type) BuyGren;

#ifdef FIELD_FORCEMODE
void(float value) SetFieldForcedStatus; // player function (self = player) cuts disabled time also
float() GetFieldForcedStatus; // player
#endif

//------------------------------------------//



void() ResetMenu =
{
	if (self.StatusBarSize == 0)
		CenterPrint(self, "\n");
	else
		self.StatusRefreshTime = time + 0.1;
	self.menu_count = MENU_REFRESH_RATE;
	self.current_menu = MENU_DEFAULT;
};

void() Player_Menu =
{
	// loop function
	if (self.menu_count > MENU_REFRESH_RATE)
	{
		self.menu_count = 0;
	}
	else
	{
		self.menu_count = self.menu_count + 1;
		return;
	}

	// determine which menu to display
	// WK - Check to see if the custom class menu is overriding us
	if ((self.done_custom & CUSTOM_BUILDING) && !(self.done_custom & CUSTOM_OVERRIDE) && self.playerclass == PC_CUSTOM) {
		self.current_menu = MENU_PRIMARY_WEAPON;
		self.done_custom |= CUSTOM_OVERRIDE;
	}

	//Don't flash status bars
	if (self.current_menu >= MENU_PRIMARY_WEAPON && self.current_menu <= MENU_OPTION)
		self.StatusRefreshTime = time + 1.5;

    //- OfN - Checks for destroyed buildings - NEEDED?
    /*if (self.current_menu >= MENU_ENGINEER_FIX_DISPENSER && self.current_menu <= MENU_ENGINEER_FIX_FIELDGEN && !self.building)
    {
        ResetMenu();
        return;
    }*/
    
    if (self.current_menu == MENU_INTRO)
	{
		Menu_Intro();
		self.current_menu = MENU_DEFAULT;
	}
	else if (self.current_menu == MENU_CLASSHELP)
	{
		Menu_ClassHelp();
		if (self.menu_displaytime > 8)
		{
			Menu_StuffClassHelp();
			self.current_menu = MENU_DEFAULT;
		}
		else
			self.menu_displaytime = self.menu_displaytime + 1;
	}
	else if (self.current_menu == MENU_CLASSHELP2)
	{
		Menu_ClassHelp2();
		if (self.menu_displaytime > 5)
		{
			Menu_StuffClassHelp();
			self.current_menu = MENU_DEFAULT;
		}
		else
			self.menu_displaytime = self.menu_displaytime + 1;
	}
	else if (self.current_menu == MENU_SHOWBINDS1)
	{
		Menu_ShowBindings1();
		if (self.menu_displaytime > 8)
		{
			self.current_menu = MENU_DEFAULT;
		}
		else
			self.menu_displaytime = self.menu_displaytime + 1;
	}
	else if (self.current_menu == MENU_SHOWBINDS2)
	{
		Menu_ShowBindings2();
		if (self.menu_displaytime > 8)
		{
			self.current_menu = MENU_DEFAULT;
		}
		else
			self.menu_displaytime = self.menu_displaytime + 1;
	}
	else if (self.current_menu == MENU_DROP)
	{	
		Menu_Drop();
	}
	else if (self.current_menu == MENU_SPY)
	{
		Menu_Spy();
	}
	else if (self.current_menu == MENU_SPY_SKIN)
	{
		Menu_Spy_Skin();
	}
	else if (self.current_menu == MENU_SPY_COLOR)
	{
		Menu_Spy_Color();
	}
	else if (self.current_menu == MENU_ENGINEER)
	{
		Menu_Engineer();
	}
	else if (self.current_menu == MENU_ENGINEER_FIX_DISPENSER)
	{
		Menu_EngineerFix_Dispenser();
	}
	else if (self.current_menu == MENU_ENGINEER_FIX_SENTRYGUN)
	{
		Menu_EngineerFix_SentryGun();
	}
	else if (self.current_menu == MENU_ENGINEER_FIX_TESLA)
	{
		Menu_EngineerFix_Tesla();
	}
	else if (self.current_menu == MENU_ENGINEER_FIX_TESLA2)
	{
		Menu_EngineerFix_Tesla2();
	}
	else if (self.current_menu == MENU_ENGINEER_FIX_CAMERA)
	{
		Menu_EngineerFix_Camera();
	}
	else if (self.current_menu == MENU_ENGINEER_FIX_SENSOR)
	{
		Menu_EngineerFix_Sensor();
	}
	else if (self.current_menu == MENU_ENGINEER_FIX_TELEPORTER)
	{
		Menu_EngineerFix_Teleporter();
	}
    else if (self.current_menu == MENU_ENGINEER_FIX_FIELDGEN)
	{
		Menu_EngineerFix_FieldGen();
	}
	else if (self.current_menu == MENU_DISPENSER)
	{
		Menu_Dispenser();
	}
	else if (self.current_menu == MENU_REPEATHELP)
	{	
		Menu_RepeatHelp();
		self.current_menu = MENU_DEFAULT;
	}
	else if (self.current_menu == MENU_PICKBINDS)
	{	
		Menu_DoBindings();
	}
	else if (self.current_menu == MENU_DEMON)
	{
		Menu_Demon();
	}
	else if (self.current_menu == MENU_ARMY) //- OfN
	{
		Menu_Army();
	}
    else if (self.current_menu == MENU_E_HACK) //- OfN
    {
        Menu_Enemy_Hax();
    }
    else if (self.current_menu == MENU_F_HACK) //- OfN
    {
        Menu_Friend_Hax();
    }
    else if (self.current_menu == MENU_CRUSADER)
    {
        Menu_Crusader();
    }
    //WK ------------------
	else if (self.current_menu == MENU_PRIMARY_WEAPON)
	{
		Menu_PrimaryWeapon();
	}
	else if (self.current_menu == MENU_SECONDARY_WEAPON)
	{
		Menu_SecondaryWeapon();
	}
    else if (self.current_menu == MENU_MISC_WEAPON)
	{
		Menu_MiscWeapon();
	}
	else if (self.current_menu == MENU_LEGS)
	{
		Menu_Legs();
	}
	else if (self.current_menu == MENU_HEALTH)
	{
		Menu_Health();
	}
	else if (self.current_menu == MENU_ARMOR)
	{
			Menu_Armor();
	}
	else if (self.current_menu == MENU_SPECIAL)
	{
		Menu_Special();
	}
	else if (self.current_menu == MENU_SPECIAL2)
	{
		Menu_Special2();
	}
	else if (self.current_menu == MENU_GREN1)
	{
		Menu_Gren1();
	}
	else if (self.current_menu == MENU_GREN2)
	{
		Menu_Gren2();
	}
	else if (self.current_menu == MENU_ENGINEERING)
	{
		Menu_Engineering();
	}
	else if (self.current_menu == MENU_PROFESSION)
	{
		Menu_Profession();
	}
	else if (self.current_menu == MENU_PROFESSION2)
	{
		Menu_Profession2();
	}
	else if (self.current_menu == MENU_PROFICIENCY)
	{
		Menu_Proficiency();
	}
	else if (self.current_menu == MENU_OPTION)
	{
		Menu_Option();
	}    
    
    //WK ----------------
	else if (self.team_no == 0 && teamplay && (self.lives != 0))
	{
		if (self.motd >= MOTD_FINISHED) {
			self.current_menu = MENU_TEAM;
			Menu_Team();
		}
	}
//WK Default to custom class gen - OfN - nope!
	else if (self.playerclass == PC_UNDEFINED && (self.lives != 0))
	{
		//- OfN - stock_mode applies
        if (stock_mode < 2) {
            self.current_menu = MENU_CLASS;//-was commented
		    Menu_Class();//-was commented
		}
        else
        {
            self.impulse = PC_CUSTOM + TF_CHANGEPC; //-wasnt commented
		    TeamFortress_ChangeClass();//-wasnt commented
        }
	}
	else
		self.current_menu = 0;
};


//WK What the hell is this for?
/*
void(float menu_no) DisplayMenu =
{
	self.current_menu = menu_no;

	if (menu_no == MENU_TEAM)
	{
		Menu_Team();
	}
	else if (menu_no == MENU_CLASS)
	{
		Menu_Class();
	}
};
*/

void(float inp) Menu_Team_Input;

void() Menu_Team =
{
	if ((toggleflags & TFLAG_AUTOTEAM) && teamplay)
	{
		// assign player a team
		if (TeamFortress_TeamPutPlayerInTeam())
			return;
	}

	// The Detection entity may have specified a Team Menu String
	if (team_menu_string)
	{
		CenterPrint(self, team_menu_string);
		return;
	}

	if (CTF_Map == TRUE)							   							 
		CenterPrint(self, "ùûü √ËÔÔÛÂ ŸÔıÚ ‘Â·Ì ùûü\n\nì.. Blue Team           \nî.. Red Team            \n\n\n\nô.. Bind my keys for me!\n\nFor full details on this patch:\nhttp://www.telefragged.com/teamfortress/\n");
	else if (number_of_teams == 1)
		CenterPrint(self, "ùûü √ËÔÔÛÂ ŸÔıÚ ‘Â·Ì ùûü\n\nì.. Team One  \n");
	else if (number_of_teams == 2)
		CenterPrint(self, "ùûü √ËÔÔÛÂ ŸÔıÚ ‘Â·Ì ùûü\n\nì.. Team One  \nî.. Team Two  \n              \n              \n\nó.. ¡ıÙÔ ‘Â·Ì \n");
	else if (number_of_teams == 3)
		CenterPrint(self, "ùûü √ËÔÔÛÂ ŸÔıÚ ‘Â·Ì ùûü\n\nì.. Team One  \nî.. Team Two  \nï.. Team Three\n              \n\nó.. ¡ıÙÔ ‘Â·Ì \n");
	else // if (number_of_teams == 4)
		CenterPrint(self, "ùûü √ËÔÔÛÂ ŸÔıÚ ‘Â·Ì ùûü\n\nì.. Team One  \nî.. Team Two  \nï.. Team Three\nñ.. Team Four \n\nó.. ¡ıÙÔ ‘Â·Ì \n");
};

void(float inp) Menu_Team_Input =
{
	//WK Remove starting observer gravity. It might come right back.
	self.gravity = 1;

	if (inp == 5) // auto team
		TeamFortress_TeamPutPlayerInTeam();
	else if (inp <= number_of_teams && inp > 0)
		TeamFortress_TeamSet(inp);		
	else if (number_of_teams == 0 && inp <= TM_MAX_NO)
		TeamFortress_TeamSet(inp);
	else //- OfN
    {
    	//ResetMenu();		
    	self.impulse = 0;
        return;
    }

    /*else if (inp == 7)
		self.current_menu = MENU_PICKBINDS;
	else if (inp == 8)
		PlayerObserverMode();*/

    if (custom_mode!=2) sprint(self, PRINT_MEDIUM, "Press í for a custom player class\n");

	ResetMenu();		
	self.impulse = 0;
};

void() Menu_Class =
{
	local entity AD;

	AD = find(NIL, classname, "info_tfdetect");

	if (AD)
	{
		if (self.team_no == 1)
		{
			if (AD.noise1)
			{
				CenterPrint(self, AD.noise1);
				return;
			}
		}
		else if (self.team_no == 2)
		{
			if (AD.noise2)
			{
				CenterPrint(self, AD.noise2);
				return;
			}
		}
		else if (self.team_no == 3)
		{
			if (AD.noise3)
			{
				CenterPrint(self, AD.noise3);
				return;
			}
		}
		else if (self.team_no == 4)
		{
			if (AD.noise4)
			{
				CenterPrint(self, AD.noise4);
				return;
			}
		}
	}

    if (custom_mode!=2)
    {
	    if (TeamFortress_TeamIsCivilian(self.team_no))
		    CenterPrint(self, "Your team can only be Civilians.\n");
	    else if (spy_off == TRUE)
		    CenterPrint(self, "ùûü √ËÔÔÛÂ ˘ÔıÚ „Ï·ÛÛ ùûü\n\nì.. Scout   \nî.. Sniper  \nï.. Soldier \nñ.. Demoman \nó.. Medic   \nò.. Hvwep   \nô.. Pyro    \nõ.. Engineer\n\ní.. √ıÛÙÔÌ! \n");
	    else  
		    CenterPrint(self, "ùûü √ËÔÔÛÂ ˘ÔıÚ „Ï·ÛÛ ùûü\n\nì.. Scout   \nî.. Sniper  \nï.. Soldier \nñ.. Demoman \nó.. Medic   \nò.. Hvwep   \nô.. Pyro    \nö.. Spy     \nõ.. Engineer\n\ní.. √ıÛÙÔÌ! \n");
    }
    else
    {
	    if (TeamFortress_TeamIsCivilian(self.team_no))
		    CenterPrint(self, "Your team can only be Civilians.\n");
	    else if (spy_off == TRUE)
		    CenterPrint(self, "ùûü √ËÔÔÛÂ ˘ÔıÚ „Ï·ÛÛ ùûü\n\nì.. Scout   \nî.. Sniper  \nï.. Soldier \nñ.. Demoman \nó.. Medic   \nò.. Hvwep   \nô.. Pyro    \nõ.. Engineer\n");
	    else  
		    CenterPrint(self, "ùûü √ËÔÔÛÂ ˘ÔıÚ „Ï·ÛÛ ùûü\n\nì.. Scout   \nî.. Sniper  \nï.. Soldier \nñ.. Demoman \nó.. Medic   \nò.. Hvwep   \nô.. Pyro    \nö.. Spy     \nõ.. Engineer\n");
    }
};

void(float inp) Menu_Class_Input =
{
	if (inp > 10 || inp < 1)
		return;

    if (inp==10 && custom_mode==2)
    {
      self.impulse = 0;
      return;
    }

	self.impulse = inp + TF_CHANGEPC;
	if (inp == 10) //We picked custom, chnage it from random
		self.impulse = PC_CUSTOM + TF_CHANGEPC;
		
//WK Default to Custom class. TODO: Make this a serverside option - OfN - done!
//	self.impulse = PC_CUSTOM + TF_CHANGEPC;

	TeamFortress_ChangeClass();			
	ResetMenu();		

	if ( DISPLAY_CLASS_HELP ) 
		self.current_menu = MENU_CLASSHELP;
	else
		self.current_menu = MENU_DEFAULT;

	self.menu_displaytime = 0;

	self.impulse = 0;
};

void () Menu_Drop =
{
	if (self.weapons_carried & WEAP_SPANNER)
		CenterPrint(self, "ƒÚÔ ÔÚ Õ·ÎÂ:                   \n\nì.. Shells                      \nî.. Nails                       \nï.. Rockets                     \nñ.. Cells                       \n\nó.. ŒÔÙËÈÓÁ                     \n\n");
	else
		CenterPrint(self, "ƒÚÔ:                           \n\nì.. Shells                      \nî.. Nails                       \nï.. Rockets                     \nñ.. Cells                       \n\nó.. ŒÔÙËÈÓÁ                     \n\n");
};

void () Menu_RepeatHelp =
{
	CenterPrint(self, "Press õ to see this help again\n");
};

void(float inp) Menu_Drop_Input =
{
	if ((inp > 0) && (inp < 5))
	{
		TeamFortress_DropAmmo(inp);
	}
	
	if ((inp > 0) && (inp < 6))
		ResetMenu();		

	self.impulse = 0;
};

void(float inp) Menu_DoBindings_Input =
{/*- unusefull
	local string st;

	if (inp < 4)
	{
		self.impulse = 0;
		if (inp == 1)
		{
			// Flag info
			stuffcmd(self, "bind q \"impulse 23\"\n");
			// Hook
			stuffcmd(self, "bind e \"impulse 22\"\n");
			// Grenade 1
			stuffcmd(self, "bind r \"+gren1\"\n");
			// Grenade 2
			stuffcmd(self, "bind f \"+gren2\"\n");
			// Detonate Pipebombs
			stuffcmd(self, "bind v \"detpipe\"\n");
			// Drop ammo
			stuffcmd(self, "bind c \"dropammo\"\n");
			// Scan
			stuffcmd(self, "bind x \"scan50\"\n");
			// Showclasses
			stuffcmd(self, "bind g \"showclasses\"\n");
			// Inventory
			stuffcmd(self, "bind z \"inv\"\n");
		
			self.menu_count = MENU_REFRESH_RATE;
			self.current_menu = MENU_SHOWBINDS1;
			self.menu_displaytime = 0;
			return;
		}
		else if (inp == 2)
		{
			// Flag info
			stuffcmd(self, "bind s \"impulse 23\"\n");
			// Hook
			stuffcmd(self, "bind x \"impulse 22\"\n");
			// Grenade 1
			stuffcmd(self, "bind d \"+gren1\"\n");
			// Grenade 2
			stuffcmd(self, "bind c \"+gren2\"\n");
			// Detonate Pipebombs
			stuffcmd(self, "bind f \"detpipe\"\n");
			// Drop ammo
			stuffcmd(self, "bind v \"dropammo\"\n");
			// Scan
			stuffcmd(self, "bind b \"scan50\"\n");
			// Showclasses
			stuffcmd(self, "bind g \"showclasses\"\n");
			// Inventory
			stuffcmd(self, "bind n \"inv\"\n");
		
			self.menu_count = MENU_REFRESH_RATE;
			self.current_menu = MENU_SHOWBINDS2;
			self.menu_displaytime = 0;
			return;
		}
		ResetMenu();		
	}*///- save space
};

void(float inp) Menu_Input =
{
	if (self.current_menu == MENU_TEAM)
		Menu_Team_Input(inp);
	else if (self.current_menu == MENU_CLASS)
		Menu_Class_Input(inp);
	else if (self.current_menu == MENU_DROP)
	    Menu_Drop_Input(inp);
	else if (self.current_menu == MENU_SPY)
	    Menu_Spy_Input(inp);
	else if (self.current_menu == MENU_SPY_SKIN)
	    Menu_Spy_Skin_Input(inp);
	else if (self.current_menu == MENU_SPY_COLOR)
	    Menu_Spy_Color_Input(inp);
	else if (self.current_menu == MENU_ENGINEER)
	    Menu_Engineer_Input(inp);
	else if (self.current_menu == MENU_ENGINEER_FIX_DISPENSER)
	    Menu_EngineerFix_Dispenser_Input(inp);
	else if (self.current_menu == MENU_ENGINEER_FIX_TESLA)
	    Menu_EngineerFix_Tesla_Input(inp);
	else if (self.current_menu == MENU_ENGINEER_FIX_TESLA2)
	    Menu_EngineerFix_Tesla_Input2(inp);
	else if (self.current_menu == MENU_ENGINEER_FIX_SENTRYGUN)
	    Menu_EngineerFix_SentryGun_Input(inp);
	else if (self.current_menu == MENU_ENGINEER_FIX_CAMERA)
	    Menu_EngineerFix_Camera_Input(inp);
	else if (self.current_menu == MENU_ENGINEER_FIX_SENSOR)
	    Menu_EngineerFix_Sensor_Input(inp);
	else if (self.current_menu == MENU_ENGINEER_FIX_TELEPORTER)
	    Menu_EngineerFix_Teleporter_Input(inp);
   	else if (self.current_menu == MENU_ENGINEER_FIX_FIELDGEN)
	    Menu_EngineerFix_FieldGen_Input(inp);
	else if (self.current_menu == MENU_DISPENSER)
		Menu_Dispenser_Input(inp);
	else if (self.current_menu == MENU_CLASSHELP)
		Menu_ClassHelp_Input(inp);
	else if (self.current_menu == MENU_PICKBINDS)
		Menu_DoBindings_Input(inp);
	else if (self.current_menu == MENU_DEMON)
		Menu_Demon_Input(inp);
    else if (self.current_menu == MENU_ARMY)
		Menu_Army_Input(inp);
    else if (self.current_menu == MENU_E_HACK)
		Menu_EnemyHax_Inp(inp);
    else if (self.current_menu == MENU_F_HACK)
		Menu_FriendHax_Inp(inp);
    else if (self.current_menu == MENU_CRUSADER)
        Menu_Crusader_Input(inp);
	else if (self.current_menu == MENU_PRIMARY_WEAPON) //WK --
		Menu_PrimaryWeapon_Input(inp);
	else if (self.current_menu == MENU_SECONDARY_WEAPON)
		Menu_SecondaryWeapon_Input(inp);
    else if (self.current_menu == MENU_MISC_WEAPON)
		Menu_MiscWeapon_Input(inp);
	else if (self.current_menu == MENU_LEGS)
		Menu_Legs_Input(inp);
	else if (self.current_menu == MENU_HEALTH)
		Menu_Health_Input(inp);
	else if (self.current_menu == MENU_ARMOR)
		Menu_Armor_Input(inp);
	else if (self.current_menu == MENU_SPECIAL)
		Menu_Special_Input(inp);
	else if (self.current_menu == MENU_SPECIAL2)
		Menu_Special2_Input(inp);
	else if (self.current_menu == MENU_GREN1)
		Menu_Gren1_Input(inp);
	else if (self.current_menu == MENU_GREN2)
		Menu_Gren2_Input(inp);
	else if (self.current_menu == MENU_ENGINEERING)
		Menu_Engineering_Input(inp);
	else if (self.current_menu == MENU_PROFESSION)
		Menu_Profession_Input(inp);
      else if (self.current_menu == MENU_PROFESSION2)
		Menu_Profession2_Input(inp);
	else if (self.current_menu == MENU_PROFICIENCY)
		Menu_Proficiency_Input(inp);
	else if (self.current_menu == MENU_OPTION)
		Menu_Option_Input(inp); //WK --
};

void() Menu_Intro =
{
	PrintMOTD ();
};

void() Menu_ClassHelp =
{
	if (self.menu_displaytime < 5)
	{
		if (self.playerclass == PC_SCOUT)
			CenterPrint(self, "”√œ’‘ Details:               \n\n◊≈¡–œŒ”:                     \n2.. Shotgun                  \n4.. Nailgun                  \n\nPress õ for alias help\n");
		else if (self.playerclass == PC_SNIPER)
			CenterPrint(self, "”Œ…–≈“ Details:              \n\n◊≈¡–œŒ”:                     \n2.. Sniper Rifle/Auto Rifle  \n4.. Nailgun                  \n\nPress õ for alias help\n");
		else if (self.playerclass == PC_SOLDIER)
			CenterPrint(self, "”œÃƒ…≈“ Details:             \n\n◊≈¡–œŒ”:                     \n2.. Shotgun                  \n3.. Super Shotgun            \n7.. Rocket Launcher          \n\nPress õ for alias help\n");
		else if (self.playerclass == PC_DEMOMAN)
			CenterPrint(self, "ƒ≈ÕœÃ…‘…œŒ” Õ¡Œ Details:     \n\n◊≈¡–œŒ”:                     \n2.. Shotgun                  \n6.. Grenade/Pipebomb Launcher\n                             \n\nPress õ for alias help\n");
		else if (self.playerclass == PC_MEDIC)
			CenterPrint(self, "Õ≈ƒ…√ Details:               \n\n◊≈¡–œŒ”:                     \n1.. Medikit/BioWeapon        \n2.. Shotgun                  \n3.. Super Shotgun            \n5.. Super Nailgun            \n\nPress õ for alias help\n");
		else if (self.playerclass == PC_HVYWEAP)
			CenterPrint(self, "»≈¡÷Ÿ ◊≈¡–œŒ” «’Ÿ Details:   \n\n◊≈¡–œŒ”:                     \n2.. Shotgun                  \n3.. Super Shotgun            \n7.. Assault Cannon           \n\nPress õ for alias help\n");
		else if (self.playerclass == PC_PYRO)
			CenterPrint(self, "–Ÿ“œ Details:                \n\n◊≈¡–œŒ”:                     \n2.. Shotgun                  \n6.. Flamethrower             \n7.. Incendiary Cannon        \n\nPress õ for alias help\n");
		else if (self.playerclass == PC_SPY)
			CenterPrint(self, "”–Ÿ Details:                 \n\n◊≈¡–œŒ”:                     \n2.. Tranquiliser Gun         \n3.. Super Shotgun            \n4.. Nailgun                  \n\nPress õ for alias help\n");
		else if (self.playerclass == PC_ENGINEER)
			CenterPrint(self, "≈Œ«…Œ≈≈“ Details:            \n\n◊≈¡–œŒ”:                     \n1.. Spanner                  \n2.. RailGun                  \n3.. Super Shotgun            \n\nPress õ for alias help\n");
	}
	else
	{
		if (self.playerclass == PC_SCOUT)
			CenterPrint(self, "«“≈Œ¡ƒ≈”:            \nFlash Grenade       \nConcussion Grenade  \n\n”–≈√…¡Ã √œÕÕ¡Œƒ”:   \nScanner: scan10,scan50,scan250\nHolograph:  holo        \n\n\nPress õ for alias help\n");
		else if (self.playerclass == PC_SNIPER)
			CenterPrint(self, "«“≈Œ¡ƒ≈”:            \nHand Grenade        \nFlare               \n\n”–≈√…¡Ã √œÕÕ¡Œƒ”:   \nautozoom : Toggle Rifle Autozooming\n\n\nPress õ for alias help\n");
		else if (self.playerclass == PC_SOLDIER)																							
			CenterPrint(self, "«“≈Œ¡ƒ≈”:            \nHand Grenade        \nNail Grenade        \n\n”–≈√…¡Ã √œÕÕ¡Œƒ”:   \nNone\n\n\nPress õ for alias help\n");
		else if (self.playerclass == PC_DEMOMAN)																																							                                                                                                
			CenterPrint(self, "«“≈Œ¡ƒ≈”:            \nHand Grenade        \nMirv Grenade        \n\n”–≈√…¡Ã √œÕÕ¡Œƒ”:   \nThe Detpack : det5,det20,det50\nDetonate Pipebombs : detpipe  \n\n\nPress õ for alias help\n");
		else if (self.playerclass == PC_MEDIC)
			CenterPrint(self, "«“≈Œ¡ƒ≈”:            \nHand Grenade        \nConcussion Grenade  \n\n”–≈√…¡Ã √œÕÕ¡Œƒ”:   \nNone\n\n\nPress õ for alias help\n");
		else if (self.playerclass == PC_HVYWEAP)
			CenterPrint(self, "«“≈Œ¡ƒ≈”:            \nHand Grenade        \nMirv Grenade        \n\n”–≈√…¡Ã √œÕÕ¡Œƒ”:   \nNone\n\n\nPress õ for alias help\n");
		else if (self.playerclass == PC_PYRO)
			CenterPrint(self, "«“≈Œ¡ƒ≈”:            \nHand Grenade        \nNapalm Grenade      \n\n”–≈√…¡Ã √œÕÕ¡Œƒ”:   \nNone\n\n\nPress õ for alias help\n");
		else if (self.playerclass == PC_SPY)
			CenterPrint(self, "«“≈Œ¡ƒ≈”:            \nHand Grenade        \nHallucinogen Grenade\n\n”–≈√…¡Ã √œÕÕ¡Œƒ”:   \nGo Undercover : disguise\nStart feigning: feign\n\n\nPress õ for alias help\n");
		else if (self.playerclass == PC_ENGINEER)
			CenterPrint(self, "«“≈Œ¡ƒ≈”:            \nHand Grenade        \nEMP Grenade         \n\n”–≈√…¡Ã √œÕÕ¡Œƒ”:   \nStart Building : build  \n\n\nPress õ for alias help\n");
		/* WK Stop GRENADES - Build your own class from appearing
			else if (self.playerclass == PC_CUSTOM)
				CenterPrint(self, "«“≈Œ¡ƒ≈”:            \nBuild your own class!\n\n");
		*/
	}
};

void() Menu_StuffClassHelp =
{
	/*
    if (self.playerclass == PC_SCOUT)
	{
		sprint(self, PRINT_HIGH, "”√œ’‘ Details:\n◊≈¡–œŒ”:\n   2.. Shotgun\n   4.. Nailgun\n");
		sprint(self, PRINT_HIGH, "«“≈Œ¡ƒ≈”:\n   Concussion Grenade\n   Flare\n”–≈√…¡Ã √œÕÕ¡Œƒ”:\n");
		sprint(self, PRINT_HIGH, "Scanner: scan10,scan30,scan100\nHolograph: holo\n\n\n");
	}
	else if (self.playerclass == PC_SNIPER)
	{
		sprint (self, PRINT_HIGH, "”Œ…–≈“ Details:\n\n◊≈¡–œŒ”:\n   2.. Sniper Rifle/Auto Rifle\n");
		sprint (self, PRINT_HIGH, "4.. Nailgun\n«“≈Œ¡ƒ≈”:\n   Hand Grenade\n\n\n”–≈√…¡Ã √œÕÕ¡Œƒ”:\n");
		sprint (self, PRINT_HIGH, "  autozoom : Toggle Rifle Autozooming\n\n\n");
	}
	else if (self.playerclass == PC_SOLDIER)
	{
		sprint (self, PRINT_HIGH, "”œÃƒ…≈“ Details:\n\n◊≈¡–œŒ”:\n   2.. Shotgun\n   3.. Super Shotgun\n");
		sprint (self, PRINT_HIGH, "   7.. Rocket Launcher\n«“≈Œ¡ƒ≈”:\n   Hand Grenade\n   Nail Grenade\n");
		sprint (self, PRINT_HIGH, "”–≈√…¡Ã √œÕÕ¡Œƒ”:\n   None\n\n\n");
	}
	else if (self.playerclass == PC_DEMOMAN)
	{
		sprint (self, PRINT_HIGH, "ƒ≈ÕœÃ…‘…œŒ” Õ¡Œ Details:\n\n◊≈¡–œŒ”:\n   2.. Shotgun\n   6.. Grenade/Pipebomb Launcher\n");
		sprint (self, PRINT_HIGH, "«“≈Œ¡ƒ≈”:\n   Hand Grenade\n   Mirv Grenade\n");
		sprint (self, PRINT_HIGH, "”–≈√…¡Ã √œÕÕ¡Œƒ”:\n   The Detpack : det5,det20,det50\n   Detonate Pipebombs : detpipe\n\n\n");
	}
	else if (self.playerclass == PC_MEDIC)
	{
		sprint (self, PRINT_HIGH, "Õ≈ƒ…√ Details:\n\n◊≈¡–œŒ”:\n   1.. Medikit/BioWeapon\n   2.. Shotgun\n   3.. Super Shotgun\n");
		sprint (self, PRINT_HIGH, "   5.. Super Nailgun\n«“≈Œ¡ƒ≈”:\n   Hand Grenade\n   Concussion Grenade\n");
		sprint (self, PRINT_HIGH, "”–≈√…¡Ã √œÕÕ¡Œƒ”:\n   None\n\n\n");
	}
	else if (self.playerclass == PC_HVYWEAP)
	{
		sprint (self, PRINT_HIGH, "»≈¡÷Ÿ ◊≈¡–œŒ” «’Ÿ Details:\n\n◊≈¡–œŒ”:\n   2.. Shotgun\n   3.. Super Shotgun\n");
		sprint (self, PRINT_HIGH, "   7.. Assault Cannon\n«“≈Œ¡ƒ≈”:\n   Hand Grenade\n");
		sprint (self, PRINT_HIGH, "   Mirv Grenade\n”–≈√…¡Ã √œÕÕ¡Œƒ”:\n   None\n\n\n");
	}
	else if (self.playerclass == PC_PYRO)
	{
		sprint (self, PRINT_HIGH, "–Ÿ“œ Details:\n\n◊≈¡–œŒ”:\n   2.. Shotgun\n   6.. Flamethrower\n   7.. Incendiary Cannon\n");
		sprint (self, PRINT_HIGH, "«“≈Œ¡ƒ≈”:\n   Hand Grenade\n   Napalm Grenade\n");
		sprint (self, PRINT_HIGH, "”–≈√…¡Ã √œÕÕ¡Œƒ”:\n   None\n\n\n");
	}
	else if (self.playerclass == PC_SPY)
	{
		sprint (self, PRINT_HIGH, "”–Ÿ Details:\n\n◊≈¡–œŒ”:\n   2.. Tranquiliser Gun\n   3.. Super Shotgun\n   4.. Nailgun\n");
		sprint (self, PRINT_HIGH, "«“≈Œ¡ƒ≈”:\n   Hand Grenade\n   Hallucinogenic Grenade\n");
		sprint (self, PRINT_HIGH, "”–≈√…¡Ã √œÕÕ¡Œƒ”:\n   Go Undercover : disguise\n   Start feigning: feign\n\n\n");
	}
	else if (self.playerclass == PC_ENGINEER)
	{
		sprint (self, PRINT_HIGH, "≈Œ«…Œ≈≈“ Details:\n\n◊≈¡–œŒ”:\n   1.. Spanner\n   2.. RailGun\n   3.. Super Shotgun\n");
		sprint (self, PRINT_HIGH, "«“≈Œ¡ƒ≈”:\n   Hand Grenade\n   EMP Grenade\n");
		sprint (self, PRINT_HIGH, "”–≈√…¡Ã √œÕÕ¡Œƒ”:\n   Start Building : build\n\n\n");
	}
    */
};

void() Menu_ClassHelp2 =
{								  
	CenterPrint(self, "√ÔÌÌ·Ó‰Û:     \n\ninv       : Show inventory \n+gren1    : Throw grenade 1\n+gren2    : Throw Grenade 2\nreload    : Force a reload \ndropammo  : drop some ammo \nskill     : use job ability\ntaunt1 : taunts(also 2,3,4)\n");
};                                                                                                                                                                                                      //    \nskill     : use job ability

void(float inp) Menu_ClassHelp_Input =
{
    if (self.playerclass == PC_UNDEFINED) return;

//CH changed inp from 8 to 9,  lgun uses 8
	if (inp == 9)
	{
		Menu_ClassHelp2();
		self.menu_count = MENU_REFRESH_RATE;
		self.current_menu = MENU_CLASSHELP2;
		self.menu_displaytime = 0;
		self.impulse = 0;
	}

	// Otherwise, the impulse is passed on
};

void() Menu_DoBindings =
{																		   				 
	//CenterPrint(self, "ì.. Use keys: E R F V C Q X G Z\nî.. Use keys: S X D C F V B G N\nï.. Don't make bindings        \n");
};

void() Menu_ShowBindings1 =
{
	//CenterPrint(self, "—.. Flaginfo      \n≈.. Hook          \n“.. Throw Gren 1  \n∆.. Throw Gren 2  \n÷.. Det. Pipebombs\n√.. Drop ammo     \nÿ.. Use Scanner   \n«.. Showclasses   \n⁄.. inventory     \n");
};

void() Menu_ShowBindings2 =
{
	//CenterPrint(self, "”.. Flaginfo      \nÿ.. Hook          \nƒ.. Throw Gren 1  \n√.. Throw Gren 2  \n∆.. Det. Pipebombs\n÷.. Drop ammo     \n¬.. Use Scanner   \n«.. Showclasses   \nŒ.. inventory     \n");
};

//============================================================================
// SPY menus for the Skin and Color changing ability
void() Menu_Spy =
{
		if (self.is_feigning)
	{
		if (self.undercover_team != 0 && self.undercover_skin != 0)
			CenterPrint(self, "¡„ÙÈÔÓ:                           \n\nì.. Change Skin                 \nî.. Change Color                \nï.. Stop Feigning               \nñ.. Reset Skin and Color        \n\nó.. ŒÔÙËÈÓÁ                     \n\n");
		else if (self.undercover_team != 0)
			CenterPrint(self, "¡„ÙÈÔÓ:                           \n\nì.. Change Skin                 \nî.. Change Color                \nï.. Stop Feigning               \nñ.. Reset Color                 \n\nó.. ŒÔÙËÈÓÁ                     \n\n");
		else if (self.undercover_skin != 0)
			CenterPrint(self, "¡„ÙÈÔÓ:                           \n\nì.. Change Skin                 \nî.. Change Color                \nï.. Stop Feigning               \nñ.. Reset Skin                  \n\nó.. ŒÔÙËÈÓÁ                     \n\n");
		else
			CenterPrint(self, "¡„ÙÈÔÓ:                           \n\nì.. Change Skin                 \nî.. Change Color                \nï.. Stop Feigning               \n\nñ.. ŒÔÙËÈÓÁ                     \n\n");
	}
	else
	{
		if (self.undercover_team != 0 && self.undercover_skin != 0)
			CenterPrint(self, "¡„ÙÈÔÓ:                           \n\nì.. Change Skin                 \nî.. Change Color                \nï.. Start Feigning              \nñ.. Reset Skin and Color        \n\nó.. ŒÔÙËÈÓÁ                     \n\n");
		else if (self.undercover_team != 0)
			CenterPrint(self, "¡„ÙÈÔÓ:                           \n\nì.. Change Skin                 \nî.. Change Color                \nï.. Start Feigning              \nñ.. Reset Color                 \n\nó.. ŒÔÙËÈÓÁ                     \n\n");
		else if (self.undercover_skin != 0)
			CenterPrint(self, "¡„ÙÈÔÓ:                           \n\nì.. Change Skin                 \nî.. Change Color                \nï.. Start Feigning              \nñ.. Reset Skin                  \n\nó.. ŒÔÙËÈÓÁ                     \n\n");
		else
			CenterPrint(self, "¡„ÙÈÔÓ:                           \n\nì.. Change Skin                 \nî.. Change Color                \nï.. Start Feigning              \n\nñ.. ŒÔÙËÈÓÁ                     \n\n");
	}
};

void(float inp) Menu_Spy_Input =
{
	if (inp == 1 || inp == 2)
	{
		if (self.effects & EF_ANYGLOW)
		{
			sprint(self, PRINT_HIGH, "You can't go undercover while glowing.\n");
			ResetMenu();		
			self.impulse = 0;
			return;
		}
		if (self.is_unabletospy == 1)
		{
			sprint(self, PRINT_HIGH, "You can't go undercover right now.\n");
			ResetMenu();		
			self.impulse = 0;
			return;
		}
	}

	if (inp == 1)
	{
		Menu_Spy_Skin();
		self.menu_count = MENU_REFRESH_RATE;
		self.current_menu = MENU_SPY_SKIN;
		self.menu_displaytime = 0;
		self.impulse = 0;
	}
	else if (inp == 2)
	{
		Menu_Spy_Color();
		self.menu_count = MENU_REFRESH_RATE;
		self.current_menu = MENU_SPY_COLOR;
		self.menu_displaytime = 0;
		self.impulse = 0;
	}
	else if (inp == 3)
	{
		TeamFortress_SpyFeignDeath(1); //CH Normal feign
		ResetMenu();		
		self.impulse = 0;
	}
	else if (inp == 4)
	{
		Spy_RemoveDisguise(self);

		ResetMenu();		
		self.impulse = 0;
	}
	else if (inp == 5 && (self.undercover_team != 0 || self.undercover_skin != 0))
	{
		ResetMenu();		
		self.impulse = 0;
	}

	// Otherwise, the impulse is passed on
};

void() Menu_Spy_Skin =
{
	CenterPrint(self, "√Ë·ÓÁÂ ”ÎÈÓ ÙÔ:\n\nì.. Scout   \nî.. Sniper  \nï.. Soldier \nñ.. Demoman \nó.. Medic   \nò.. Hvwep   \nô.. Pyro    \nö.. Spy     \nõ.. Engineer\n\n");
};

void(float inp) Menu_Spy_Skin_Input =
{
	if (inp < 10 && inp > 0)
	{
		TeamFortress_SpyChangeSkin(inp);
		ResetMenu();		
		self.impulse = 0;
	}

	// Otherwise, the impulse is passed on
};

void() Menu_Spy_Color =
{
	if (number_of_teams == 0)
	{
		sprint(self, PRINT_HIGH, "No Color changing allowed in deathmatch.\n");
		ResetMenu();		
		self.impulse = 0;
		return;
	}

	if (number_of_teams == 1)											 
		CenterPrint(self, "√Ë·ÓÁÂ √ÔÏÔÚ ÙÔ:\n\nì.. Team One  \n\n");
	else if (number_of_teams == 2)
		CenterPrint(self, "√Ë·ÓÁÂ √ÔÏÔÚ ÙÔ:\n\nì.. Team One  \nî.. Team Two  \n\n");
	else if (number_of_teams == 3)
		CenterPrint(self, "√Ë·ÓÁÂ √ÔÏÔÚ ÙÔ:\n\nì.. Team One  \nî.. Team Two  \nï.. Team Three\n\n");
	else // if (number_of_teams == 4)
		CenterPrint(self, "√Ë·ÓÁÂ √ÔÏÔÚ ÙÔ:\n\nì.. Team One  \nî.. Team Two  \nï.. Team Three\nñ.. Team Four \n\n");
};

void(float inp) Menu_Spy_Color_Input =
{
	if (inp >= 1 && inp <= number_of_teams)
	{
		TeamFortress_SpyChangeColor(inp);
		ResetMenu();		
		self.impulse = 0;
	}

	// Otherwise, the impulse is passed on
};

//============================================================================
// ENGINEER menus for the building ability
//WK Rewritten for better extensibility and less lines of code

void() Menu_Engineer =
{
	local string st = "";

	st += "\<Action\>:                           \n\n";
	if (self.has_dispenser)
		st += "\x93\<..\> Destroy Dispenser             \n";
	else if (self.ammo_cells >= BUILD_COST_DISPENSER && (self.cutf_items & CUTF_DISPENSER))
		st += "\x93.. Build Dispenser               \n";
	else
		st += "\n";

	if (self.has_sentry)
		st += "\x94\<..\> Destroy Sentry Gun            \n";
	else if (self.ammo_cells >= BUILD_COST_SENTRYGUN && self.cutf_items & CUTF_SENTRYGUN)
		st += "\x94.. Build Sentry Gun              \n";
	else
		st += "\n";

	if (self.has_tesla)
		st += "\x95\<..\> Destroy Tesla Sentry          \n";
	else if (self.ammo_cells >= BUILD_COST_TESLA && self.tf_items & NIT_TESLA)
		st += "\x95.. Build Tesla Sentry            \n";
	else
		st += "\n";
	
    if (self.has_camera)
		st += "\x96\<..\> Destroy Security Camera       \n";
	else if (self.ammo_cells >= BUILD_COST_CAMERA && self.tf_items & NIT_SECURITY_CAMERA)
		st += "\x96.. Launch Security Camera        \n";
	else
		st += "\n";

	if (self.has_teleporter < 2 && self.ammo_cells >= BUILD_COST_TELEPORTER && self.tf_items & NIT_TELEPORTER)
		st += "\x97.. Build a Teleporter Pad        \n";
	else
		st += "\n";

	if (self.has_teleporter == 2)
		st += "\x98\<..\> Destroy Both Teleporter Pads  \n";
	else if (self.has_teleporter == 1)
		st += "\x98\<..\> Destroy a Teleporter Pad      \n";
	else
		st += "\n";

    if (self.has_sensor)
		st += "\x99\<..\> Destroy Motion Sensor         \n";
	else if (self.ammo_cells >= BUILD_COST_SENSOR && self.cutf_items & CUTF_SENSOR)
        st += "\x99.. Deploy Motion Sensor          \n";		
    else
        st += "\n";

	if (self.has_fieldgen < 2 && self.ammo_cells >= BUILD_COST_FIELDGEN && self.cutf_items & CUTF_FIELDGEN)
		st += "\x9a.. Build a Field Generator       \n";
#ifdef FIELD_FORCEMODE
	else if (self.has_fieldgen == 2 && self.cutf_items & CUTF_FIELDGEN)
		st += "\x9a.. Force field: " + (GetFieldForcedStatus() ? "\<Closed Mode\>      \n" : "\<Intelligent Mode\> \n");
#endif
	else
		st += "\n";

	if (self.has_fieldgen == 2)
		st += "\x9b\<..\> Destroy Both Field Generators \n";
	else if (self.has_fieldgen == 1)
		st += "\x9b\<..\> Destroy a Field Generator     \n";
	else
		st += "\n";

	st += "\n\x92.. \<Nothing\>                       \n";

	//Finally, we output the menu...
	CenterPrint (self, st);
 
};

void(float inp) Menu_Engineer_Input =
{
	local entity te;

	if (inp == 1 && self.ammo_cells >= BUILD_COST_DISPENSER && self.has_dispenser == FALSE)
	{
		if (!self.has_dispenser) TeamFortress_Build(BUILD_DISPENSER);
		ResetMenu();		
		self.impulse = 0;
	}
	else if (inp == 2 && self.ammo_cells >= BUILD_COST_SENTRYGUN && self.has_sentry == FALSE)
	{
        if (HasFlag(self.team_no) == FALSE) {
            CenterPrint(self, "No building until your team has the flag!\n");
            return;		
        }
    
        TeamFortress_Build(BUILD_SENTRYGUN);
		ResetMenu();		
		self.impulse = 0;
	}
	else if (inp == 3 && self.ammo_cells >= BUILD_COST_TESLA && self.has_tesla == FALSE)
	{
        if (HasFlag(self.team_no) == FALSE) {
            CenterPrint(self, "No building until your team has the flag!\n");
            return;		
        }
		
		TeamFortress_Build(BUILD_TESLA);
		ResetMenu();		
		self.impulse = 0;
	}
	else if (inp == 4)
	{
		if (!self.has_camera)
			TeamFortress_Build(BUILD_SECURITY_CAMERA);
		else
		{
			if (self.option < time)
                Find_And_Dmg("building_camera", self, 1);
            else
            {
                self.impulse = 0;
                return;
            }
		}
		ResetMenu();		
		self.impulse = 0;
	}
//CH uses 5 and 6 
	else if (inp == 5
			 && (self.has_teleporter == 0 || self.has_teleporter == 1)
			 && self.ammo_cells >= BUILD_COST_TELEPORTER) //ch if have one out, can build
	{

		TeamFortress_Build(BUILD_TELEPORTER);	
		ResetMenu();		
		self.impulse = 0;
	
	}
	else if (inp == 6 && (self.has_teleporter == 1 || self.has_teleporter == 2)) //ch if have one out. can destroy
	{
		Find_And_Dmg("building_teleporter", self, 1);
		ResetMenu();		
		self.impulse = 0;
	}
    else if (inp == 7 && (self.ammo_cells >= BUILD_COST_SENSOR || self.has_sensor) && self.cutf_items & CUTF_SENSOR)
    {
        SBBuildSensor();
        ResetMenu();		
		self.impulse = 0;
    }
    //CH uses 5 and 6 
	else if (inp == 8) //ch if have one out, can build
	{
        if ((self.has_fieldgen == 0 || self.has_fieldgen == 1) && self.ammo_cells >= BUILD_COST_FIELDGEN)
        {
            if (HasFlag(self.team_no) == FALSE) {
                CenterPrint(self, "No building until your team has the flag!\n");
                return;		
            }
            
            // find if there are other generators too close, if this is our first generator only - nope
		TeamFortress_Build(BUILD_FIELDGEN);	
		ResetMenu();		
		self.impulse = 0;
        }

#ifdef FIELD_FORCEMODE

        else if (self.has_fieldgen > 1)
        {
            if (GetFieldForcedStatus())
            {
                SetFieldForcedStatus(FALSE);
                sprint(self,PRINT_HIGH,"You set the force field to Intelligent Mode\n");
            }
            else
            {
                SetFieldForcedStatus(TRUE);
                sprint(self,PRINT_HIGH,"You set the force field to Closed Mode\n");
            }

            ResetMenu();
            self.impulse = 0;
        }

#endif

    }
	else if (inp == 9 && (self.has_fieldgen >= 1)) //ch if have one out. can destroy
	{
		Find_And_Dmg("building_fieldgen", self, 1);
        self.has_fieldgen = 0; // FIXME: shouldnt be needed
		ResetMenu();		
		self.impulse = 0;
	}
//-----------------------------------------------------------------//
	else if (inp == 1 && self.has_dispenser == TRUE)
	{
		Find_And_Dmg("building_dispenser", self, 1);
		ResetMenu();		
		self.impulse = 0;
	}
	else if (inp == 2 && self.has_sentry == TRUE)
	{
		Find_And_Dmg("building_sentrygun", self, 1);
		ResetMenu();		
		self.impulse = 0;
	}
	else if (inp == 3 && self.has_tesla == TRUE)
	{
		te = find(NIL, classname, "building_tesla");
		while (te)
		{
			if (te.real_owner == self)
			{
				if (te.tf_items & NIT_SECURITY_CAMERA) {
					sprint(self, PRINT_HIGH, "Can't detonate a rogue tesla. Sorry, it's not that easy.\n");
					ResetMenu();		
					self.impulse = 0;
					return;
				}
			}
			te = find(te, classname, "building_tesla");
		}
		Find_And_Dmg("building_tesla", self, 1);
		ResetMenu();		
		self.impulse = 0;
	}
	else if (inp == 10) //CH was 4
	{
		ResetMenu();		
		self.impulse = 0;
	}

	// Otherwise, the impulse is passed on
};

//CH to reduce code.
void(entity person, string build) Add_Building_Teamkill =
{
	local string st;
	local float threshold;
	threshold = 0;
	bprint (PRINT_HIGH, person.netname);
	bprint (PRINT_HIGH, " has dismantled a friendly ");
	bprint (PRINT_HIGH, build);
	bprint (PRINT_HIGH, "!\n");

	st = infokey(NIL, "curse");
	if (st)
		threshold = stof(st);
	person.ff_count = person.ff_count + 2; //Increase their bastard rating
	//Increase the engineers bastard rating so they
	//can't block everyone.
	person.building.real_owner.ff_count = person.building.real_owner.ff_count + 0.5;
	if (threshold >= 1)
	{
		if (person.ff_count >= threshold)
			createBastard(person,threshold);
		if (person.building.real_owner.ff_count >= threshold)
			createBastard(person.building.real_owner,threshold);
		if ((person.ff_count == threshold - 2) || (person.ff_count == threshold - 1.5) || (person.ff_count == threshold - 1) || (person.ff_count == threshold - 0.5))
		{
			sprint (person, PRINT_MEDIUM, "One more dismantling and you will be cursed.\n");
		}
	}
};

//============================================================================
// ENGINEER menus for fixing buildings

void() Menu_EngineerFix_Dispenser =
{
	CenterPrint(self, "¡„ÙÈÔÓ:                            \n\nì.. Put Ammo into Dispenser     \nî.. Put Armor into Dispenser    \nï.. Repair Dispenser            \nñ.. Dismantle Dispenser         \n\nó.. ŒÔÙËÈÓÁ                     \n\n");
};

void(float inp) Menu_EngineerFix_Dispenser_Input =
{
	local float metalcost;
	local float am;

	if (self.classname != "player" || !self.building)
		return;

    local float iI; // is Improved?
    iI=1;
    if (self.building.num_mines & IMPROVED_ONE)
        iI=2;

	if (inp == 1)
	{
		// shells
		am = (DROP_SHELLS * 2);
		if (am > self.ammo_shells)
			am = self.ammo_shells; 
		if (am > (BUILD_DISPENSER_MAX_SHELLS*iI - self.building.ammo_shells))
			am = BUILD_DISPENSER_MAX_SHELLS*iI - self.building.ammo_shells;
		self.ammo_shells = self.ammo_shells - am;
		self.building.ammo_shells = self.building.ammo_shells + am;

		// nails
		am = (DROP_NAILS * 2);
		if (am > self.ammo_nails)
			am = self.ammo_nails; 
		if (am > (BUILD_DISPENSER_MAX_NAILS*iI - self.building.ammo_nails))
			am = BUILD_DISPENSER_MAX_NAILS*iI - self.building.ammo_nails;
		self.ammo_nails = self.ammo_nails - am;
		self.building.ammo_nails = self.building.ammo_nails + am;

		// rockets
		am = (DROP_ROCKETS * 2);
		if (am > self.ammo_rockets)
			am = self.ammo_rockets; 
		if (am > (BUILD_DISPENSER_MAX_ROCKETS*iI - self.building.ammo_rockets))
			am = BUILD_DISPENSER_MAX_ROCKETS*iI - self.building.ammo_rockets;
		self.ammo_rockets = self.ammo_rockets - am;
		self.building.ammo_rockets = self.building.ammo_rockets + am;

		// cells
		am = (DROP_CELLS * 2);
		if (am > self.ammo_cells)
			am = self.ammo_cells; 
		if (am > (BUILD_DISPENSER_MAX_CELLS*iI - self.building.ammo_cells))
			am = BUILD_DISPENSER_MAX_CELLS*iI - self.building.ammo_cells;
		self.ammo_cells = self.ammo_cells - am;
		self.building.ammo_cells = self.building.ammo_cells + am;
	}
	else if (inp == 2)
	{
		// armor
		am = (DROP_ARMOR * 2);
		if (am > self.armorvalue)
			am = self.armorvalue; 
		if (am > (BUILD_DISPENSER_MAX_ARMOR*iI - self.building.armorvalue))
			am = BUILD_DISPENSER_MAX_ARMOR*iI - self.building.armorvalue;
		self.armorvalue = self.armorvalue - am;
		self.building.armorvalue = self.building.armorvalue + am;
	}
	else if (inp == 3)
	{
		metalcost = (self.building.max_health - self.building.health) / 5;

		if (metalcost > self.ammo_cells)
			metalcost = self.ammo_cells;
		if (!instant_repair && metalcost > BUILD_DISPENSER_REPAIR) // don't allow instant repairs
			metalcost = BUILD_DISPENSER_REPAIR;

		self.ammo_cells = self.ammo_cells - metalcost;
		self.building.health = self.building.health + (metalcost * 5);
	}
	else if (inp == 4)
	{
        if (CheckEnemyDismantle()==FALSE) {ResetMenu(); self.impulse=0; return;}

        sprint (self, PRINT_HIGH, "You dismantle the Dispenser.\n");
  		self.ammo_cells = self.ammo_cells + (BUILD_COST_DISPENSER / 2.0);
///////////////////////////
		if (Teammate(self.building.real_owner.team_no,self.team_no) && teamplay != 0 && self.building.real_owner != self) { //Boot em if they dismantle too many
			Add_Building_Teamkill (self, "dispenser");
		}

        self.building.health=0; // - OfN aborts hacks on it
        self.building.real_owner.has_dispenser = FALSE;
        dremove(self.building);

    }

	if (inp >= 1 && inp <= 5)
	{
		ResetMenu();		
		self.impulse = 0;
		self.building = NIL;

		bound_other_ammo(self);

		if (self.armorvalue == 0)
		{
			self.armortype = 0;	// lost all armor
			self.armorclass = 0; // lost special armor
			self.items &= ~(IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3);
		}

		W_SetCurrentAmmo();
	}

	// Otherwise, the impulse is passed on
};

void() Menu_EngineerFix_SentryGun =
{
	if (self.building.weapon < 3 && self.ammo_cells >= BUILD_COST_SENTRYGUN)
	{
        if (!(self.tf_items & NIT_TURRET)) // TODO: Action --> OfteN's sentry gun
            CenterPrint(self, "¡„ÙÈÔÓ:                            \n\n.. Put Ammo into Sentry Gun    \n.. Upgrade Sentry Gun          \nï.. Repair Sentry Gun           \n\nñ.. ŒÔÙËÈÓÁ                     \n\nó.. Dismantle Sentry Gun        \nò.. Rotate Clockwise            \nô.. Rotate Counter-Clockwise    \n");
        else
            CenterPrint(self, "¡„ÙÈÔÓ:                            \n\n.. Put Ammo into Sentry Gun    \n.. Upgrade Sentry Gun          \nï.. Repair Sentry Gun           \n\nñ.. ŒÔÙËÈÓÁ                     \n\nó.. Dismantle Sentry Gun        \nò.. Rotate Clockwise            \nô.. Rotate Counter-Clockwise    \nö.. Create Turret               \n");
    }
	else
    {
        if (!(self.tf_items & NIT_TURRET))
            CenterPrint(self, "¡„ÙÈÔÓ:                            \n\n.. Put Ammo into Sentry Gun    \nï.. Repair Sentry Gun           \n\nñ.. ŒÔÙËÈÓÁ                     \n\nó.. Dismantle Sentry Gun        \nò.. Rotate Clockwise            \nô.. Rotate Counter-Clockwise    \n");
        else
            CenterPrint(self, "¡„ÙÈÔÓ:                            \n\n.. Put Ammo into Sentry Gun    \nï.. Repair Sentry Gun           \n\nñ.. ŒÔÙËÈÓÁ                     \n\nó.. Dismantle Sentry Gun        \nò.. Rotate Clockwise            \nô.. Rotate Counter-Clockwise    \nö.. Create Turret               \n");
    }
};

void(float inp) Menu_EngineerFix_SentryGun_Input =
{
	local float am, metalcost;
	local string st;

	if (self.classname != "player" || !self.building)
		return;

	if (inp == 1)
	{
		// shells
		am = (DROP_SHELLS * 2);
		if (am > self.ammo_shells)
			am = self.ammo_shells;
		if (am > (self.building.maxammo_shells - self.building.ammo_shells))
			am = (self.building.maxammo_shells - self.building.ammo_shells);
		self.ammo_shells = self.ammo_shells - am;
		self.building.ammo_shells = self.building.ammo_shells + am;

		// If it's level 3, put some rockets in too
		// GR But not at the same time as the shells 
		if (self.building.weapon == 3 && am == 0)
		{
			am = (DROP_ROCKETS * 2);
			if (am > self.ammo_rockets)
				am = self.ammo_rockets;
			if (am > (self.building.maxammo_rockets - self.building.ammo_rockets))
				am = (self.building.maxammo_rockets - self.building.ammo_rockets);
			self.ammo_rockets = self.ammo_rockets - am;
			self.building.ammo_rockets = self.building.ammo_rockets + am;
		}
	}
	else if (self.building.weapon < 3 && inp == 2 && self.ammo_cells >= BUILD_COST_SENTRYGUN)
	{
		self.ammo_cells = self.ammo_cells - BUILD_COST_SENTRYGUN;
		self.building.weapon = self.building.weapon + 1;

		local float HPfactor,AMMOfactor;
        if (self.building.num_mines & IMPROVED_THREE)
            HPfactor=2;
        else
            HPfactor=1;

        if (self.building.num_mines & IMPROVED_ONE)
            AMMOfactor=2;
        else
            AMMOfactor=1;
        
        // more health
		//self.building.max_health = self.building.max_health * 1.2;
		//self.building.health = self.building.max_health;

		// more ammo capability
		//self.building.maxammo_shells = self.building.maxammo_shells * 1.2;
		// Change the skin and frames
		if (self.building.weapon == 2)
		{
			sound (self.building, CHAN_ITEM, "weapons/turrset.wav", 1, ATTN_NORM);
			self.building.think = lvl2_sentry_stand;
			//self.building.skin = 1;
            self.building.max_health = 180 * HPfactor;
            self.building.maxammo_shells = 120 * AMMOfactor;
		}
		else // if (self.building.weapon == 3)
		{
			sound (self.building, CHAN_ITEM, "weapons/turrset.wav", 1, ATTN_NORM);
			self.building.think = lvl3_sentry_stand;
			//self.building.skin = 2;
            self.building.max_health = 220 * HPfactor;
            self.building.maxammo_shells = 144 * AMMOfactor;
		}
        
        self.building.health = self.building.max_health;

		sprint(self, PRINT_HIGH, "You upgrade the Sentry Gun to level ");
		st = ftos(self.building.weapon); 
		sprint(self, PRINT_HIGH, st);
		sprint(self, PRINT_HIGH, "\n");
	}
	else if (inp == 3)
	{
		metalcost = (self.building.max_health - self.building.health) / 5;

		if (metalcost > self.ammo_cells)
			metalcost = self.ammo_cells;
		if (!instant_repair && metalcost > BUILD_SENTRYGUN_REPAIR) // disallow instant repairs
			metalcost = BUILD_SENTRYGUN_REPAIR;

		self.ammo_cells = self.ammo_cells - metalcost;
		self.building.health = self.building.health + (metalcost * 5);
	}
	else if (inp == 5)
	{
		if (CheckEnemyDismantle()==FALSE) return;
        
        sprint(self, PRINT_HIGH, "You dismantle the Sentry Gun.\n");
//CH give .5 of build cost====give 25*level
		self.ammo_cells = self.ammo_cells + (BUILD_COST_SENTRYGUN / 2.0) + (self.building.weapon * 25);

		if (Teammate(self.building.real_owner.team_no,self.team_no) && teamplay != 0 && self.building.real_owner != self) { //Boot em if they dismantle too many
			Add_Building_Teamkill (self, "sentry gun");
		}
		self.building.real_owner.has_sentry = FALSE;
		dremove(self.building.trigger_field);
        self.building.health=0; // - OfN aborts hacks on it
		dremove(self.building);
	}
	else if (inp == 6) //WK
	{
		sprint(self, PRINT_HIGH, "You rotate it clockwise 45 degrees\n");
		self.building.angles_y = anglemod(self.building.angles_y - 45);
			self.building.angles_y = ((ceil(self.building.angles_y / 10)) * 10); //CH set last int to 0
		self.building.waitmin = anglemod(self.building.angles_y - 50);
		self.building.waitmax = anglemod(self.building.angles_y + 50);
		self.building.heat = 0;
	}
	else if (inp == 7) //WK
	{
		sprint(self, PRINT_HIGH, "You rotate it counter-clockwise 45 degrees\n");
		self.building.angles_y = anglemod(self.building.angles_y + 45);
			self.building.angles_y = ((ceil(self.building.angles_y / 10)) * 10); //CH set last int to 0
		self.building.waitmin = anglemod(self.building.angles_y - 50);
		self.building.waitmax = anglemod(self.building.angles_y + 50);
		self.building.heat = 1;
	}
	//Detachable sentry!
	else if (inp == 8)
	{
		if (self.building.tf_items & NIT_TURRET) {
			sprint(self, PRINT_HIGH, "Gun is already deployed\n");
		}
		else if (!(self.tf_items & NIT_TURRET)) {
			sprint(self, PRINT_HIGH, "You need to purchase the turret upgrade\n");
		}
		else if (self.ammo_cells < BUILD_COST_TURRET)
		{
			sprint (self, PRINT_HIGH, "Creating a turret costs "
					+ ftos (BUILD_COST_TURRET) + " metal\n");
		}
		else {
			self.building.origin_z = self.building.origin_z + 15; //Elevate for the check
			//Make sure the launch area is clear
			if (CheckArea(self.building,self) == FALSE) {
				sprint(self, PRINT_HIGH, "You need a clear area to launch\n");		
				self.building.origin_z = self.building.origin_z - 15; //Set back down
			}
			else {
				self.building.origin_z = self.building.origin_z + 25; //Finish liftoff
				sprint(self, PRINT_HIGH, "You launch the sentrygun\n");
				self.ammo_cells = self.ammo_cells - BUILD_COST_TURRET;
				self.building.angles_z = 180;
			 	setmodel(self.building.trigger_field, "");
				self.building.trigger_field.solid = SOLID_NOT;
				self.building.flags &= ~FL_ONGROUND;
				self.building.movetype = MOVETYPE_FLY;
				self.building.velocity_z = 200;
				setsize (self.building, '-16 -16 -40', '16 16 -10'); //WK -40, -10
				self.building.tf_items |= NIT_TURRET;
			}
		}
	}
	if (inp >= 1 && inp <= 8)
	{
		ResetMenu();		
		self.impulse = 0;

		bound_other_ammo(self);

		if (self.armorvalue == 0)
		{
			self.armortype = 0;	// lost all armor
			self.armorclass = 0; // lost special armor
			self.items &= ~(IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3);
		}

		W_SetCurrentAmmo();
	}
};

void() Menu_EngineerFix_Sensor =
{
	CenterPrint(self, "¡„ÙÈÔÓ:              \n\n.. Repair Sensor      \n\n.. ŒÔÙËÈÓÁ            \n\n.. Dismantle          \n");
}; 
void(float inp) Menu_EngineerFix_Sensor_Input =
{
//*ch
	local float metalcost;

	if (self.classname != "player" || !self.building)
		return;

	if (inp == 1)
	{
		metalcost = (self.building.max_health - self.building.health) / 10;

		if (metalcost > self.ammo_cells)
			metalcost = self.ammo_cells;
		if (!instant_repair && metalcost > BUILD_SENSOR_REPAIR)
			metalcost = BUILD_SENSOR_REPAIR;

		self.ammo_cells = self.ammo_cells - metalcost;
		self.building.health = self.building.health + (metalcost * 10);
	}
	else if (inp == 3)
	{
        if (CheckEnemyDismantle() == FALSE) return; //- OfN - ICE avoids enemy dismantle (see often.qc)
        
        sprint(self, PRINT_HIGH, "You dismantle the Motion Sensor.\n");
//CH will give you half of cost + max of 20
		self.ammo_cells = self.ammo_cells + (BUILD_COST_SENSOR * 0.5) + floor(self.building.health / 40);
		self.building.real_owner.has_sensor = FALSE;

		if (Teammate(self.building.real_owner.team_no,self.team_no) && teamplay != 0 && self.building.real_owner != self) { //Boot em if they dismantle too many
			Add_Building_Teamkill (self, "motion sensor");
		}

        self.building.health=0; // - OfN aborts hacks on it
		dremove(self.building);
	}
	if (inp >= 1 && inp <= 3)
	{
		ResetMenu();		
		self.impulse = 0;

		bound_other_ammo(self);

		if (self.armorvalue == 0)
		{
			self.armortype = 0;	// lost all armor
			self.armorclass = 0; // lost special armor
			self.items &= ~(IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3);
		}

		W_SetCurrentAmmo();
	}
};

void() Menu_EngineerFix_Camera =
{
	CenterPrint(self, "¡„ÙÈÔÓ:                \n\n.. Repair Camera      \n\n.. ŒÔÙËÈÓÁ            \n\n.. Dismantle          \n");
};
void(float inp) Menu_EngineerFix_Camera_Input =
{
//*ch
	local float metalcost;

	if (self.classname != "player" || !self.building)
		return;

	if (inp == 1)
	{
		metalcost = (self.building.max_health - self.building.health) / 10;

		if (metalcost > self.ammo_cells)
			metalcost = self.ammo_cells;

		if (!instant_repair && metalcost > BUILD_CAMERA_REPAIR)
			metalcost = BUILD_CAMERA_REPAIR;

		self.ammo_cells = self.ammo_cells - metalcost;
		self.building.health = self.building.health + (metalcost * 10);
	}
	else if (inp == 3)
	{
        if (CheckEnemyDismantle() == FALSE) return; //- OfN - ICE avoids enemy dismantle (see often.qc)

        sprint(self, PRINT_HIGH, "You dismantle the Security Camera.\n");
//CH will give you half of cost + max of 20
		self.ammo_cells = self.ammo_cells + (BUILD_COST_CAMERA * 0.5) + floor(self.building.health / 40);
		self.building.real_owner.has_camera = FALSE;

		if (Teammate(self.building.real_owner.team_no,self.team_no) && teamplay != 0 && self.building.real_owner != self) { //Boot em if they dismantle too many
			Add_Building_Teamkill (self, "security camera");
		}

        self.building.health=0; // - OfN aborts hacks on it
        dremove(self.building);
	}
	if (inp >= 1 && inp <= 3)
	{
		ResetMenu();		
		self.impulse = 0;

		bound_other_ammo(self);

		if (self.armorvalue == 0)
		{
			self.armortype = 0;	// lost all armor
			self.armorclass = 0; // lost special armor
			self.items &= ~(IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3);
		}

		W_SetCurrentAmmo();
	}
};

void() Menu_EngineerFix_Teleporter =
{
	CenterPrint(self, "¡„ÙÈÔÓ:                \n\n.. Repair Teleporter  \n.. Recharge Teleporter\n\n.. ŒÔÙËÈÓÁ            \n\n.. Dismantle          \n");
};
void(float inp) Menu_EngineerFix_Teleporter_Input =
{
//*ch
	local float metalcost;

	if (self.classname != "player" || !self.building)
		return;

	if (inp == 1)
	{
		metalcost = (self.building.max_health - self.building.health) / 5;

		if (metalcost > self.ammo_cells)
			metalcost = ceil(self.ammo_cells);
		if (!instant_repair && metalcost > BUILD_TELEPORT_REPAIR)
			metalcost = BUILD_TELEPORT_REPAIR;			

		self.ammo_cells = self.ammo_cells - metalcost;
		self.building.health = self.building.health + (metalcost * 5);
	}
	else if (inp == 2)
	{
		metalcost = (self.building.maxammo_cells - self.building.ammo_cells);

		if (metalcost > self.ammo_cells)
			metalcost = ceil(self.ammo_cells);
		if (!instant_repair && metalcost > BUILD_TELEPORT_RECHARGE)
			metalcost = BUILD_TELEPORT_RECHARGE;

		self.ammo_cells = self.ammo_cells - metalcost;
		self.building.ammo_cells = self.building.ammo_cells + metalcost;
		if (self.building.ammo_cells > self.building.maxammo_cells)
			self.building.ammo_cells = self.building.maxammo_cells;
	}
	else if (inp == 4)
	{
        if (CheckEnemyDismantle() == FALSE) return; //- OfN - ICE avoids enemy dismantle (see often.qc)

        sprint(self, PRINT_HIGH, "You dismantle the Teleporter Pad.\n");
//CH will give you half of cost + max of 20
		self.ammo_cells = self.ammo_cells + (BUILD_COST_TELEPORTER * 0.5) + floor(self.building.health / 15);
		self.building.real_owner.has_teleporter = (self.building.real_owner.has_teleporter - 1);

		if (Teammate(self.building.real_owner.team_no,self.team_no) && teamplay != 0 && self.building.real_owner != self) { //Boot em if they dismantle too many
			Add_Building_Teamkill (self, "teleporter");
		}

        self.building.health=0; // - OfN aborts hacks on it
        dremove(self.building);
	}
	if (inp >= 1 && inp <= 4)
	{
		ResetMenu();		
		self.impulse = 0;

		bound_other_ammo(self);

		if (self.armorvalue == 0)
		{
			self.armortype = 0;	// lost all armor
			self.armorclass = 0; // lost special armor
			self.items &= ~(IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3);
		}

		W_SetCurrentAmmo();
	}
};

//=========================================================================
// field generator

void() Menu_EngineerFix_FieldGen =
{
	CenterPrint(self, "¡„ÙÈÔÓ:                \n\n.. Repair Field Generator  \n.. Recharge Field Generator\n\n.. ŒÔÙËÈÓÁ                 \n\n.. Dismantle               \n");
};
void(float inp) Menu_EngineerFix_FieldGen_Input =
{
	local float metalcost;

	if (self.classname != "player" || !self.building)
		return;

	if (inp == 1)
	{
		metalcost = (self.building.max_health - self.building.health) / 5;

		if (metalcost > self.ammo_cells)
			metalcost = ceil(self.ammo_cells);
		if (!instant_repair && metalcost > BUILD_FIELDGEN_REPAIR)
			metalcost = BUILD_FIELDGEN_REPAIR;

		self.ammo_cells = self.ammo_cells - metalcost;
		self.building.health = self.building.health + (metalcost * 5);
	}
	else if (inp == 2)
	{
		metalcost = (self.building.maxammo_cells - self.building.ammo_cells);

		if (metalcost > self.ammo_cells)
			metalcost = ceil(self.ammo_cells);
		if (!instant_repair && metalcost > BUILD_FIELDGEN_RECHARGE)
			metalcost = BUILD_FIELDGEN_RECHARGE;

		self.ammo_cells = self.ammo_cells - metalcost;
		self.building.ammo_cells = self.building.ammo_cells + metalcost;
		if (self.building.ammo_cells > self.building.maxammo_cells)
			self.building.ammo_cells = self.building.maxammo_cells;
	}
	else if (inp == 4)
	{
        if (CheckEnemyDismantle() == FALSE) return; //- OfN - ICE avoids enemy dismantle (see often.qc)

        sprint(self, PRINT_HIGH, "You dismantle the Field Generator.\n");
//CH will give you half of cost + max of 20
		self.ammo_cells = self.ammo_cells + (BUILD_COST_FIELDGEN * 0.5) + floor(self.building.health / 15);
		self.building.real_owner.has_fieldgen = (self.building.real_owner.has_fieldgen - 1);

		if (Teammate(self.building.real_owner.team_no,self.team_no) && teamplay != 0 && self.building.real_owner != self) { //Boot em if they dismantle too many
			Add_Building_Teamkill (self, "field generator");
		}

        self.building.health=0; // - OfN aborts hacks on it
        dremove(self.building);
	}
	if (inp >= 1 && inp <= 4)
	{
		ResetMenu();		
		self.impulse = 0;

		bound_other_ammo(self);

		if (self.armorvalue == 0)
		{
			self.armortype = 0;	// lost all armor
			self.armorclass = 0; // lost special armor
			self.items &= ~(IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3);
		}

		W_SetCurrentAmmo();
	}
};


//CH
string(float num) Return_Colored_Num =
{
	if (num == 0)
		return "í";
	else if (num == 1)
		return "ì";
	else if (num == 2)
		return "î";
	else if (num == 3)
		return "ï";
	else if (num == 4)
		return "ñ";
	else if (num == 5)
		return "ó";
	else if (num == 6)
		return "ò";
	else if (num == 7)
		return "ô";
	else if (num == 8)
		return "ö";
	else if (num == 9)
		return "õ";
	else
		return "£"; //Should never happen // OfN - It does when a tesla is in upgrade for frags
};
//Upgrades tesla, type 1=volt 2=amps 3=health 4=spy 5=kevlar 6=blast 7=turret 8=improve 9=cloak
//menu 0=normal 1=misc
float(float ups, entity person, entity sent, float type, float menu) Check_Tesla_Ups =
{
	local float upgrades;

	if (menu == 1)
		upgrades = sent.has_tesla; //misc
	else
		upgrades = sent.has_sentry; //normal
	if (ups > upgrades) {//not enough upgrades
		sprint(person,PRINT_HIGH,"You do not have enough upgrades to improve the tesla\n");
		return FALSE;
	}
	if (type == 4 || type == 5) { //Spy detector and frag to upgrade
		if (person.ammo_cells < (ups / 2) * UPGRADE) {//not enough cells
			sprint(person,PRINT_HIGH,"You need more cells to upgrade the tesla\n");
			return FALSE;
		}
	}
	else
	{
		if (person.ammo_cells < ups * UPGRADE) {//not enough cells
			sprint(person,PRINT_HIGH,"You need more cells to upgrade the tesla\n");
			return FALSE;
		}
	}
	if (type ==1)
	{
		if (sent.ammo_shells >= 3) {
			sprint(self,PRINT_HIGH,"You can only upgrade voltage 3 times\n");
			return FALSE;
		}
		else {
			self.ammo_cells = self.ammo_cells - (ups * UPGRADE);
			sent.has_sentry = sent.has_sentry - ups;
			return TRUE;
		}
	}
	if (type ==2)
	{
		if (sent.ammo_nails >= 3) {
			sprint(person,PRINT_HIGH,"You can only upgrade amperage 3 times\n");
			return FALSE;
		}
		else {
			self.ammo_cells = self.ammo_cells - (ups * UPGRADE);
			sent.has_sentry = sent.has_sentry - ups;
			return TRUE;
		}
	}
	if (type ==3)
	{
		if (sent.ammo_rockets >= 3) {
			sprint(person,PRINT_HIGH,"You can only upgrade the capacitor 3 times\n");
			return FALSE;
		}
		else {
			self.ammo_cells = self.ammo_cells - (ups * UPGRADE);
			sent.has_sentry = sent.has_sentry - ups;
			return TRUE;
		}
	}
	if (type ==4)
	{
		if (sent.tf_items & NIT_AUTOID) {
			sprint(person,PRINT_HIGH,"You already built a spy detector\n");
			return FALSE;
		}
		else {
			self.ammo_cells = self.ammo_cells - (ups * UPGRADE);
			sent.has_sentry = sent.has_sentry - ups;
			return TRUE;
		}
	}
	if (type ==5)
	{
		if (sent.tf_items & NIT_TELEPORTER) {
			sprint(person,PRINT_HIGH,"You already have the upgrade\n");
			return FALSE;
		}
		else {
			self.ammo_cells = self.ammo_cells - (ups * UPGRADE);
			sent.has_sentry = sent.has_sentry - ups;
			return TRUE;
		}
	}
	if (type ==6)
	{
		if (sent.tf_items & NIT_KEVLAR) {
			sprint(person,PRINT_HIGH,"The Tesla already has Kevlar Armor\n");
			return FALSE;
		}
		else {
			self.ammo_cells = self.ammo_cells - (ups * UPGRADE);
			sent.has_tesla = sent.has_tesla - ups;
			return TRUE;
		}
	}
	if (type ==7)
	{
		if (sent.tf_items & NIT_BLAST) {
			sprint(person,PRINT_HIGH,"The Tesla already has Blast Armor\n");
			return FALSE;
		}
		else {
			self.ammo_cells = self.ammo_cells - (ups * UPGRADE);
			sent.has_tesla = sent.has_tesla - ups;
			return TRUE;
		}
	}
	if (type ==8)
	{
		if (sent.tf_items & NIT_ASBESTOS) {
			sprint(person,PRINT_HIGH,"The Tesla already has Asbestos Armor\n");
			return FALSE;
		}
		else {
			self.ammo_cells = self.ammo_cells - (ups * UPGRADE);
			sent.has_tesla = sent.has_tesla - ups;
			return TRUE;
		}
	}
	if (type ==9)
	{
		if (sent.tf_items & NIT_TURRET) {
			sprint(person,PRINT_HIGH,"The Tesla is already a turret!\n");
			return FALSE;
		}
		else {
			self.ammo_cells = self.ammo_cells - (ups * UPGRADE);
			sent.has_tesla = sent.has_tesla - ups;
			return TRUE;
		}
	}
	if (type ==10)
	{
		if (sent.tf_items & NIT_SCANNER) {
			sprint(person,PRINT_HIGH,"The Tesla already has an improved targeter\n");
			return FALSE;
		}
		else {
			self.ammo_cells = self.ammo_cells - (ups * UPGRADE);
			sent.has_tesla = sent.has_tesla - ups;
			return TRUE;
		}
	}
	if (type ==11)
	{
		
		//sprint(person,PRINT_HIGH,"Not implemented yet!\n");
		//	return FALSE;
		if (sent.tf_items & NIT_TESLA_CLOAKING) {
			sprint(person,PRINT_HIGH,"The Tesla already has a cloaking device\n");
			return FALSE;
		}
		else {
			self.ammo_cells = self.ammo_cells - (ups * UPGRADE);
			sent.has_tesla = sent.has_tesla - ups;
			return TRUE;
		}
	}
	return FALSE; //Should not happen
	
};
//Cause its used 2x
void() Menu_EngineerRepair_Tesla =
{
	local float cost;
	local float maxcells;
	if (self.building.health < self.building.max_health) //CH allow repair with limited cells
	{
		cost = (self.building.max_health - self.building.health) / 2;
		if (cost > self.ammo_cells)
			cost = self.ammo_cells;
		if (!instant_repair && cost > BUILD_TESLA_REPAIR)
			cost = BUILD_TESLA_REPAIR;

		self.ammo_cells = self.ammo_cells - cost;
		self.building.health = self.building.health + (cost * 2);
		if (self.building.health >= self.building.max_health)
			self.building.health = self.building.max_health;
	} else {  // don't allow repair and recharge at the same time
		maxcells = self.building.maxammo_cells;	

		cost = maxcells - self.building.ammo_cells;
		if (cost > self.ammo_cells) cost = self.ammo_cells;
		if (!instant_repair && cost > BUILD_TESLA_RECHARGE) cost = BUILD_TESLA_RECHARGE;
		self.ammo_cells = self.ammo_cells - cost;
		self.building.ammo_cells = self.building.ammo_cells + cost;
		if (self.building.ammo_cells >= maxcells)
			self.building.ammo_cells = maxcells;
	}
};
void() Menu_EngineerDismantle_Tesla =
{
	if (!self.building)
		return;

	if (self.building.tf_items & NIT_SECURITY_CAMERA) {
		sprint(self, PRINT_HIGH, "You can't dismantle it. It's not that easy!\n");
		return;
	}

    if (CheckEnemyDismantle() == FALSE) return;

	sprint(self, PRINT_HIGH, "You dismantle the Tesla Gun.\n");
//CH give .5 of ammount of build====give 25*health level (0-3)====give .5 of cells
	self.ammo_cells = self.ammo_cells + (BUILD_COST_TESLA / 2.0) + (self.building.ammo_rockets * 25) + (self.building.ammo_cells / 2);
	self.building.real_owner.has_tesla = FALSE;

		if (Teammate(self.building.real_owner.team_no,self.team_no) && teamplay != 0 && self.building.real_owner != self) { //Boot em if they dismantle too many
			Add_Building_Teamkill (self, "tesla");
		}
	dremove(self.building);
};
//CH does random and picks what upgrade to give
void(entity sent, entity who) Tesla_Add_Rand_Upgrade =
{
	local float num;
	num = random();
	if (num <= 0.8) //give them a normal upgrade
	{
		sprint(who,PRINT_HIGH,"The tesla got a normal upgrade!\n");
		sent.has_sentry = sent.has_sentry + 1;
	}
	else
	{
		sprint(who,PRINT_HIGH,"The tesla got a misc upgrade!\n");
		sent.has_tesla = sent.has_tesla + 1;
	}
};
void() Menu_EngineerFix_Tesla =
{
	local string l1,l2;

	l1 = Return_Colored_Num(self.building.has_sentry);
	l2 = "ì.. Upgrade Voltage           ≠ 1u\nî.. Upgrade Amperage          ≠ 1u\nï.. Upgrade Power Supply      ≠ 1u\nñ.. Add Spy Detector          ≠ 4u\nó.. Upgrades from frags       ≠ 3u\nò.. Tinker                        \nô.. Repair and Recharge           \nö.. Dismantle                     \nõ.. ŒÔÙËÈÓÁ                       \n\ní.. Misc Upgrades  \n";
	
      CenterPrint4(self, "Tesla ÕÔ‰ÈÊÈ„·ÙÈÔÓ Ã·‚: ",l1, " Upgrades Left\n\nùûûûûûûü Normal Tesla Upgrades ùûûûûûûü\n\n" ,l2);

};
void(float inp) Menu_EngineerFix_Tesla_Input =
{
	local float cost = 0;

	if (self.classname != "player" || !self.building)
		return;

	if (inp <= 10 && inp >= 1)
	{
	if (self.building.real_owner != self && (inp < 7 || inp == 10) ) {
		sprint(self,PRINT_HIGH,"Sorry, only the owner can do that\n");
		return;
	}
		
	if (inp == 1) { //Upgrade volt
		if (Check_Tesla_Ups(1, self, self.building, 1, 0))
		{
			self.building.ammo_shells = self.building.ammo_shells + 1;
			self.building.waitmin = (self.building.ammo_shells + 2) * (self.building.ammo_nails + 2); //Ammo consumption
		}
	}
	if (inp == 2) { //Upgrade amperage
		if (Check_Tesla_Ups(1, self, self.building, 2, 0))
		{
			self.building.ammo_nails = self.building.ammo_nails + 1;
			self.building.waitmin = (self.building.ammo_shells + 2) * (self.building.ammo_nails + 2); //Ammo consumption
		}
	}
	if (inp == 3) { //Upgrade power supply
		if (Check_Tesla_Ups(1, self, self.building, 3, 0))
		{
			local float HPfactor,num,AMMOfactor;
            if (self.building.num_mines & IMPROVED_THREE)
                HPfactor=2;
            else
                HPfactor=1;
            
            if (self.building.num_mines & IMPROVED_ONE)
                AMMOfactor=2;
            else
                AMMOfactor=1;            

            num=self.building.health/self.building.max_health;

            self.building.ammo_rockets = self.building.ammo_rockets + 1;
			//Upgrade them //- OfN - teslas start with 150 hp
			if (self.building.ammo_rockets == 1) {
				//self.building.max_health = self.building.max_health + 75; // 225
                self.building.max_health = 225*HPfactor;
				//self.building.health = self.building.health + 75;
				self.building.maxammo_cells = (MAXCELLS0 + ADDCELLS1) * AMMOfactor;
				self.building.ammo_cells = self.building.maxammo_cells;
			}
			else if (self.building.ammo_rockets == 2) {
				//self.building.max_health = self.building.max_health + 100;// 325
                self.building.max_health = 325*HPfactor;// 325
				//self.building.health = self.building.health + 100;
				//self.building.maxammo_cells = self.building.maxammo_cells + ADDCELLS2; //Add
                self.building.maxammo_cells = (MAXCELLS0 + ADDCELLS1 + ADDCELLS2)*AMMOfactor;
				self.building.ammo_cells = self.building.maxammo_cells;
			}
			else if (self.building.ammo_rockets == 3) {
				//self.building.max_health = self.building.max_health + 75; // 400
   				self.building.max_health = 400*HPfactor; // 400
				//self.building.health = self.building.health + 75;
				self.building.maxammo_cells = (MAXCELLS0 + ADDCELLS1 + ADDCELLS2 + ADDCELLS3)*AMMOfactor; //Add
				self.building.ammo_cells = self.building.maxammo_cells;
			}

            self.building.health=self.building.max_health*num;
		}
	}
	if (inp == 4) { //Spy Detector
		if (Check_Tesla_Ups(4, self, self.building, 4, 0))
		{
			self.building.tf_items |= NIT_AUTOID;
		}
	}
	if (inp == 5) { //CH Get frags for upgrades
		if (Check_Tesla_Ups(3, self, self.building, 5, 0))
		{
			self.building.tf_items |= NIT_TELEPORTER;
		}
	}
	if (inp == 6){ // Tinker by Cyt0  Remade by CH to fit with new code
		if (self.building.tf_items & NIT_TELEPORTER) //- ofn - workaround to solve the HP/cells increase by tinker combined with the hack
        {
       		sprint(self,PRINT_HIGH,"You can't tinker a tesla in upgrade from frags mode!\n");            
        }
        else
        {
            DoTinker();
        }
	}
	if (inp == 7) { //Repair and Rearm
		Menu_EngineerRepair_Tesla();
	}
	if (inp == 8) {
		Menu_EngineerDismantle_Tesla();
	}
//	if (inp == 9) {
//	}
	if (inp == 10) {
		self.impulse = 0;
		Menu_EngineerFix_Tesla2();
		self.current_menu = MENU_ENGINEER_FIX_TESLA2;
	}

	if (inp >= 1 && inp <= 9)
	{
		ResetMenu();		
		self.impulse = 0;

		if (self.ammo_cells < 0) self.ammo_cells = 0;

		bound_other_ammo(self);

		if (self.armorvalue == 0)
		{
			self.armortype = 0;	// lost all armor
			self.armorclass = 0; // lost special armor
			self.items &= ~(IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3);
		}

		W_SetCurrentAmmo();
	}
	}
};
void() Menu_EngineerFix_Tesla2 =
{
	local string l1,l2;

	l1 = Return_Colored_Num(self.building.has_tesla);
	//l2 = "ò.. Cloaking Tesla            ≠ 2u";
	l2 = "ì.. Kevlar Armor              ≠ 1u\nî.. Blast Armor               ≠ 1u\nï.. Asbestos Armor            ≠ 1u\nñ.. Make TeslaTurret(tm)      ≠ 1u\nó.. Improved Targeting System ≠ 1u\nò.. Cloaking Device           ≠ 1u\nô.. Repair and Recharge           \nö.. Dismantle                     \nõ.. ŒÔÙËÈÓÁ                       \n\ní.. Normal Upgrades\n";
    //l2 = "ì.. Kevlar Armor              ≠ 1u\nî.. Blast Armor               ≠ 1u\nï.. Asbestos Armor            ≠ 1u\nñ.. Make TeslaTurret(tm)      ≠ 1u\nó.. Improved Targeting System ≠ 1u\n\nô.. Repair and Recharge           \nö.. Dismantle                     \nõ.. ŒÔÙËÈÓÁ                       \n\ní.. Normal Upgrades\n";
	CenterPrint4(self, "Tesla ÕÔ‰ÈÊÈ„·ÙÈÔÓ Ã·‚: ",l1, " Upgrades Left\n\nÄÅÅÅÅÅÅÅÇ Misc Tesla Upgrades ÄÅÅÅÅÅÅÅÇ\n\n" ,l2);
};
void(float inp) Menu_EngineerFix_Tesla_Input2 =
{
	local float cost = 0;

	if (self.classname != "player" || !self.building)
		return;

	if (inp <= 10 && inp >= 1)
	{
	if (inp == 1) { //Kevlar
		if (Check_Tesla_Ups(1, self, self.building, 6, 1))
		{
			self.building.tf_items |= NIT_KEVLAR;
			self.building.armorclass |= AT_SAVESHOT;
		}
	}
	if (inp == 2) { //Blast
		if (Check_Tesla_Ups(1, self, self.building, 7, 1))
		{
			self.building.tf_items |= NIT_BLAST;
			self.building.armorclass |= AT_SAVEEXPLOSION;
		}
	}
	if (inp == 3) { //Blast
		if (Check_Tesla_Ups(1, self, self.building, 8, 1))
		{
			self.building.tf_items |= NIT_ASBESTOS;
			self.building.armorclass |= AT_SAVEFIRE;
		}
	}
	if (inp == 4) { //Tesla Turret(tm)
		if (Check_Tesla_Ups(1, self, self.building, 9, 1))
		{
			if (self.building.tf_items & NIT_TURRET) {
				sprint(self, PRINT_HIGH, "Gun is already deployed\n");
			}
			else {
				//Make sure the launch area is clear
				if (FALSE) {
				//if (CheckArea(self.building,self) == FALSE) {
					sprint(self, PRINT_HIGH, "You need a clear area to launch\n");		
					self.building.origin_z = self.building.origin_z - 15; //-15//Set back down
				}
				else {
					//self.building.origin_z = self.building.origin_z + 25; //+ 25 //Finish liftoff
                    self.building.origin_z = self.building.origin_z - 34; //often fixes tesla not touchin ceiling//+
					sprint(self, PRINT_HIGH, "You turretize the tesla\n");

                    if (self.building.job == 1 && self.building.tf_items & NIT_TESLA_CLOAKING)
                    {    
                        local entity TSelf, OSelfB;
                        OSelfB=self.building;
                        TSelf=TeslaClone(OSelfB);
                        dremove(OSelfB);
                        self.building=TSelf; // NEEDED? teslaclone should have updated this pointer anyway..                        
 
                        spawnFOG(self.building.origin);
                        sound (self.building, CHAN_MISC, "misc/r_tele4.wav", 1, ATTN_NORM);
                    }    
                    
                    self.building.angles_z = 180;
					self.building.flags &= ~FL_ONGROUND;
					self.building.movetype = MOVETYPE_FLY;
					self.building.velocity_z = 200;
					setsize (self.building, '-16 -16 10', '16 16 62');
					self.building.tf_items |= NIT_TURRET;
                    self.building.is_haxxxoring=1; //flag determines if flying and it's used for cloaking teslas, set to 0 when landed
                    
				}
			}
		}
	}
	if (inp == 5) { //Improved Targeter
		if (Check_Tesla_Ups(1, self, self.building, 10, 1))
		{
			self.building.tf_items |= NIT_SCANNER;
		}
	}
//CH its commented out here and in the centerprint - OfN nomore!
	if (inp == 6) { //Cloaking tesla
		if (Check_Tesla_Ups(1, self, self.building, 11, 1))
		{
			self.building.tf_items |= NIT_TESLA_CLOAKING;
            if (self.building.job == 1)
            {
                local entity oself;
                oself=self;
                self=self.building;
                self.job=3; //- OfN - this flag indicates it must skip condition on lose_glow
                Tesla_Lose_Glow();
                self=oself;
            }
		}
	}

	if (inp == 7) { //Repair and Rearm
		Menu_EngineerRepair_Tesla();
	}
	if (inp == 8) {
		Menu_EngineerDismantle_Tesla();
	}
//	if (inp == 9) {
//	}
	if (inp == 10) {
		self.impulse = 0;
		Menu_EngineerFix_Tesla();
		self.current_menu = MENU_ENGINEER_FIX_TESLA;
	}

	if (inp >= 1 && inp <= 9)
	{
		ResetMenu();		
		self.impulse = 0;

		if (self.ammo_cells < 0) self.ammo_cells = 0;

		bound_other_ammo(self);

		if (self.armorvalue == 0)
		{
			self.armortype = 0;	// lost all armor
			self.armorclass = 0; // lost special armor
			self.items &= ~(IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3);
		}

		W_SetCurrentAmmo();
	}
	}
};

//============================================================================
// Menu for using buildings
void() Menu_Dispenser =
{
	CenterPrint(self, "’ÛÂ ƒÈÛÂÓÛÂÚ:                     \n\nì.. Withdraw some ammo          \nî.. Withdraw some Armor         \n\nï.. ŒÔÙËÈÓÁ                     \n\n");
};

void(float inp) Menu_Dispenser_Input =
{
	if (self.classname != "player" || !self.building)
		return;
    
    local float am, empty;

	empty = FALSE;
	if (inp == 1)
	{
		if (self.building.ammo_shells == 0 && self.building.ammo_nails == 0 && 
			self.building.ammo_rockets == 0 && self.building.ammo_cells == 0)
		{
			empty = TRUE;
		}
		else
		{
			// shells
			am = self.maxammo_shells - self.ammo_shells;
			if (am > self.building.ammo_shells)
				am = self.building.ammo_shells; 
			self.building.ammo_shells = self.building.ammo_shells - am;
			self.ammo_shells = self.ammo_shells + am;

			// nails
			am = self.maxammo_nails - self.ammo_nails;
			if (am > self.building.ammo_nails)
				am = self.building.ammo_nails; 
			self.building.ammo_nails = self.building.ammo_nails - am;
			self.ammo_nails = self.ammo_nails + am;

			// rockets
			am = self.maxammo_rockets - self.ammo_rockets;
			if (am > self.building.ammo_rockets)
				am = self.building.ammo_rockets; 
			self.building.ammo_rockets = self.building.ammo_rockets - am;
			self.ammo_rockets = self.ammo_rockets + am;

			// cells
			am = self.maxammo_cells - self.ammo_cells;
			if (am > self.building.ammo_cells)
				am = self.building.ammo_cells; 
			self.building.ammo_cells = self.building.ammo_cells - am;
			self.ammo_cells = self.ammo_cells + am;
			
			// SB gren1s
			local float grenammo;
			/*if (self.tf_items & NIT_AMMO_BANDOLIER)
				grenammo = 5;
			else
				grenammo = 4;*/

            grenammo = GetMaxGrens(self,1);

			am =  grenammo - self.no_grenades_1;
			if (am*15 > self.building.ammo_rockets)
				am = floor(self.building.ammo_rockets / 15);
			self.building.ammo_rockets = self.building.ammo_rockets - am * 15;
			self.no_grenades_1 = self.no_grenades_1 + am;

			// SB gren2s

            grenammo = GetMaxGrens(self,2);

			am =  grenammo - self.no_grenades_2;
			if (am*15 > self.ammo_rockets)
				am = floor(self.ammo_rockets / 15);
			self.building.ammo_rockets = self.building.ammo_rockets - am * 15;
			self.no_grenades_2 = self.no_grenades_2 + am;
		}
	}
	else if (inp == 2)
	{
		if (self.building.is_malfunctioning & SCREWUP_FOUR)
		{	
            sprint(self,PRINT_HIGH,"Trapped dispenser, have a nice day!\n");
            TF_T_Damage(self.building, self.building, self.building.martyr_enemy, 500, 0, TF_TD_OTHER);
            return;
        }
			
		if (self.building.armorvalue == 0)
		{
			empty = TRUE;
		}
		else
		{
			// armor
			am = self.maxarmor - self.armorvalue;
			if (am > self.building.armorvalue)
				am = self.building.armorvalue; 

			if (self.armortype == 0)
			{
				self.armortype = self.armor_allowed;
				//self.items |= IT_ARMOR1;
				W_SetCurrentAmmo();
			}

			self.building.armorvalue = self.building.armorvalue - am;
			self.armorvalue = self.armorvalue + am;
		}
	}

	if (inp >= 1 && inp <= 3)
	{
		if (empty)
			sprint(self, PRINT_HIGH, "The dispenser is empty.\n");
		ResetMenu();		
		self.impulse = 0;
		self.building = NIL;
		self.building_wait = time + 0.5;

		bound_other_ammo(self);

		if (self.armorvalue == 0)
		{
			self.armortype = 0;	// lost all armor
			self.armorclass = 0; // lost special armor
			self.items &= ~(IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3);
		}

		W_SetCurrentAmmo();
	}

	// Otherwise, the impulse is passed on
};
//----------------------------------------------------------------------
// Rod May  kk@rod.net
// mstr and mstr2 and eqstr only exist to cut down on a crap load of code.
//
string(float v,float m1,float m2,string s1,string s2,string s3,string s4) mstr =
{
	// return string for matching masks (m1 and m2) on value v.
	// neither match: s1, first only: s2, second only: s3, both: s4

	if ((v & m1) && (v & m2)) return s4;
	if (v & m1) return s2;
	if (v & m2) return s3;
	return s1;
};
string(float v1,float v2,float m1,float m2,string s1,string s2,string s3,string s4) mstr2 =
{
	// same func as above but with a value for each mask.
	// return string for matching mask m1 on value v1, and m2 on v2.

	if ((v1 & m1) && (v2 & m2)) return s4;
	if (v1 & m1) return s2;
	if (v2 & m2) return s3;
	return s1;
};
string(float v,float v1,float v2,string s1,string s2,string s3) eqstr =
{
	// return string based on v equals values v1 OR v2
	// neither equal: s1, first only: s2, second only: s3

	if (v == v1) return s2;
	if (v == v2) return s3;
	return s1;
};
//----------------------------------------------------------------------
//----------------------------------------------------------------------
//----------------------------------------------------------------------
//----------------------------------------------------------------------
//----------------------------------------------------------------------
//----------------------------------------------------------------------

//WK =====================================================================
//	Prints Menu of Primary Weapons Available
//   =====================================================================
void() Menu_PrimaryWeapon =
{
	local string temp;
	temp = ftos(self.money);
	
	local string msg_custom;
	local string l1,l2,l3,l4;

		l1 = mstr(self.weapons_carried, WEAP_SNIPER_RIFLE, WEAP_ASSAULT_CANNON,
			"  .. Sniper Rifle    ≠ 4000\n  .. Assault Cannon  ≠ 3000\n",
			"* .. Sniper Rifle    ≠ 4000\n  .. Assault Cannon  ≠ 3000\n",
			"  .. Sniper Rifle    ≠ 4000\n* .. Assault Cannon  ≠ 3000\n",
			"* .. Sniper Rifle    ≠ 4000\n* .. Assault Cannon  ≠ 3000\n");
		
		l2 = mstr(self.weapons_carried, WEAP_ROCKET_LAUNCHER, WEAP_INCENDIARY,
			"  ï.. Rocket Launcher ≠ 3000\n  ñ.. Pyro Toys       ≠ 3000\n",
			"* ï.. Rocket Launcher ≠ 3000\n  ñ.. Pyro Toys       ≠ 3000\n",
			"  ï.. Rocket Launcher ≠ 3000\n* ñ.. Pyro Toys       ≠ 3000\n",
			"* ï.. Rocket Launcher ≠ 3000\n* ñ.. Pyro Toys       ≠ 3000\n");

		l3 = mstr(self.weapons_carried, WEAP_GRENADE_LAUNCHER, WEAP_LIGHTNING,
			"  ó.. Grenade Set     ≠ 2200\n  ò.. Lightning Gun   ≠ 2200\n",
			"* ó.. Grenade Set     ≠ 2200\n  ò.. Lightning Gun   ≠ 2200\n",
			"  ó.. Grenade Set     ≠ 2200\n* ò.. Lightning Gun   ≠ 2200\n",
			"* ó.. Grenade Set     ≠ 2200\n* ò.. Lightning Gun   ≠ 2200\n");

		l4 = 	"  ô.. Light Assault   ≠ 1800\nö..         \nõ.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n";

		if (self.weapons_carried & WEAP_LIGHT_ASSAULT)
			l4 = 	"* ô.. Light Assault   ≠ 1800\nö..         \nõ.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n";

    if (self.done_custom & CUSTOM_SELLING)
		msg_custom  = " dollars left\n\n*CURRENTLY SELLING FRAGS*\nTyping √’”‘œÕ again will waste your cash\n";
	else
		msg_custom =  " dollars left\n\nUse the √’”‘œÕ command to start over\nUse the ’–«“¡ƒ≈ command to sell frags\n";

	centerprint(self, "úãê CısÙoÌi˙e ŸÔıÚÛÂÏÊ ãú\nãú Primary Weapons    úã\n\n",l1,l2,l3,l4,temp,msg_custom);
};                                                     //–ÚÈÌ·Ú˘ ◊Â·ÔÓÛ

void(float inp) Menu_PrimaryWeapon_Input =
{
	local string st;
	st = infokey(NIL, "no_spam");
	if (inp <= 10 && inp >= 1)
	{
//Snipe
#undef PRICE
#define PRICE 4000
		if (inp == 1)
				if (self.weapons_carried & WEAP_SNIPER_RIFLE) //Already have it
				{
					PrintRefund(PRICE);
					self.weapons_carried = self.weapons_carried - WEAP_SNIPER_RIFLE;
#ifndef NO_AUTORIFLE
					self.weapons_carried = self.weapons_carried - WEAP_AUTO_RIFLE;
#endif
					self.maxammo_shells = self.maxammo_shells - 75;
				}
				else if (self.money >= PRICE) {
					self.money = self.money - PRICE;
					self.weapons_carried |= WEAP_SNIPER_RIFLE | WEAP_AUTO_RIFLE;
					self.maxammo_shells = self.maxammo_shells + 75;
					PrintMoney();
				}
				else
					PrintNotEnoughMoney(PRICE);
			
		if (inp == 2)
		{
			if (st == "on") //If admin disable it
			{
				sprint(self,PRINT_HIGH,"The admin has disabled spam devices on this map.\n");
                        return;
			}
				BuyWeapon(3000,WEAP_ASSAULT_CANNON);
		}
		if (inp == 3)
		{
				BuyWeapon(3000,WEAP_ROCKET_LAUNCHER);			
		}
//IC
#undef PRICE
#define PRICE 3000
		if (inp == 4)
		{
				if (self.weapons_carried & WEAP_INCENDIARY) //Already have it
				{
					//Clean up asbestos armor
					if (!(self.tf_items & NIT_ASBESTOS))
						self.money = self.money - 750; //Sync this with asbestos
					self.tf_items &= ~NIT_ASBESTOS;
	
					PrintRefund(PRICE);
					self.weapons_carried = self.weapons_carried - WEAP_INCENDIARY;
					self.weapons_carried = self.weapons_carried - WEAP_FLAMETHROWER;
					self.maxammo_cells = self.maxammo_cells - 200;
					self.maxammo_rockets = self.maxammo_rockets - 60;
				}
				else if (self.money >= PRICE)
				{
					self.money = self.money - PRICE;
					self.weapons_carried |= WEAP_INCENDIARY | WEAP_FLAMETHROWER;
					//Give em asbestos armor, and a refund if they have it
					if (self.tf_items & NIT_ASBESTOS)
						self.money = self.money + 750; //Sync this with asbestos price
					self.tf_items |= NIT_ASBESTOS;
	
					
					self.maxammo_cells = self.maxammo_cells + 200;
					self.maxammo_rockets = self.maxammo_rockets + 60;
					PrintMoney();
				}
				else
					PrintNotEnoughMoney(PRICE);
			//}
		}
		if (inp == 5)
		{
				BuyWeapon(2200,WEAP_GRENADE_LAUNCHER);
		}
		if (inp == 6)
		{
				BuyWeapon(2200,WEAP_LIGHTNING);
		}
		if (inp == 7)
		{
				BuyWeapon(1800,WEAP_LIGHT_ASSAULT);
		}
//		if (inp == 8) {
//			centerprint(self, "No previous menu\n");
//		}
		if (inp == 9)
		{
			Menu_SecondaryWeapon();
			self.current_menu = MENU_SECONDARY_WEAPON;
		}
		if (inp == 10)
		{
			DropFromCustomClassGen();
		}

		self.impulse = 0;
	}
	// Otherwise, the impulse is passed on
	// SB to where, nobody knows
};


// ====================================================================
//  Prints Menu of Secondary Weapons Available
// ====================================================================
void() Menu_SecondaryWeapon =
{
	local string temp;
	temp = ftos(self.money);
	local string l1,l2,l3,l4;
    
/*l1 = mstr2(self.weapons_carried,self.cutf_items, WEAP_DAEDALUS, CUTF_KNIFE,
	"  .. Impulse Rifle   ≠ 1400\n  .. Knife           ≠  650\n",
	"* .. Impulse Rifle   ≠ 1400\n  .. Knife           ≠  650\n",
	"  .. Impulse Rifle   ≠ 1400\n* .. Knife           ≠  650\n",
	"* .. Impulse Rifle   ≠ 1400\n* .. Knife           ≠  650\n");*/

l1 = mstr2(self.weapons_carried,self.cutf_items, WEAP_SNG, CUTF_KNIFE,
	"  .. Super Nailgun   ≠  800\n  .. Knife           ≠  650\n",
	"* .. Super Nailgun   ≠  800\n  .. Knife           ≠  650\n",
	"  .. Super Nailgun   ≠  800\n* .. Knife           ≠  650\n",
	"* .. Super Nailgun   ≠  800\n* .. Knife           ≠  650\n");


l2 = mstr(self.weapons_carried, WEAP_SUPER_SHOTGUN, WEAP_LASER,
	"  ï.. Double Barrel   ≠  575\n  ñ.. Rail Gun        ≠  500\n",
	"* ï.. Double Barrel   ≠  575\n  ñ.. Rail Gun        ≠  500\n",
	"  ï.. Double Barrel   ≠  575\n* ñ.. Rail Gun        ≠  500\n",
	"* ï.. Double Barrel   ≠  575\n* ñ.. Rail Gun        ≠  500\n");

l3 = mstr(self.weapons_carried, WEAP_NAILGUN, WEAP_TRANQ,
	"  ó.. Nail Gun        ≠  400\n  ò.. Tranquilizer    ≠  300\n",
	"* ó.. Nail Gun        ≠  400\n  ò.. Tranquilizer    ≠  300\n",
	"  ó.. Nail Gun        ≠  400\n* ò.. Tranquilizer    ≠  300\n",
	"* ó.. Nail Gun        ≠  400\n* ò.. Tranquilizer    ≠  300\n");

l4 =	"  ô.. Single Barrel   ≠   50\nö.. –ÚÂˆ    \nõ.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n";

if (self.weapons_carried & WEAP_SHOTGUN)
l4 =	"* ô.. Single Barrel   ≠   50\nö.. –ÚÂˆ    \nõ.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n";

	centerprint(self, "úãê CısÙoÌi˙e ŸÔıÚÛÂÏÊ ãú\nãúê Secondary Weapons  úã\n\n",l1,l2,l3,l4,temp," dollars left\n");
};                                                     //”Â„ÔÓ‰·Ú˘ ◊Â·ÔÓÛ

void(float inp) Menu_SecondaryWeapon_Input =
{ 
  if (inp <= 10 && inp >= 1)
  {
    if (inp == 1) {
        //BuyWeapon(1400, WEAP_DAEDALUS);
        BuyWeapon(800,WEAP_SNG);
        //self.maxammo_        
    }

//Knife
#undef PRICE
#define PRICE 650
    if (inp == 2) {
        if (self.cutf_items & CUTF_KNIFE) //Already have it
        {
            //Clean up knife-less warlocks (sync this with Custom.qc)
            if (self.job & JOB_WARLOCK) { // OfN Fix getting extra money with demon lore
               sprint(self, PRINT_HIGH, "You will need this knife being a warlock!\n");
               self.impulse=0;
               return;
            }

            PrintRefund(PRICE);
            self.cutf_items = self.cutf_items - CUTF_KNIFE;
        }
        else if (self.money >= PRICE) {
            self.money = self.money - PRICE;
            self.cutf_items |= CUTF_KNIFE;
            PrintMoney();
        }
        else
            PrintNotEnoughMoney(PRICE);
    }
    if (inp == 3) {
        BuyWeapon(575,WEAP_SUPER_SHOTGUN);
    }
    if (inp == 4) {
        BuyWeapon(500,WEAP_LASER);
    }
    if (inp == 5) {
        BuyWeapon(400,WEAP_NAILGUN);
    }
    if (inp == 6) {
        BuyWeapon(300,WEAP_TRANQ);
    }
    if (inp == 7) {
        BuyWeapon(50,WEAP_SHOTGUN);
    }
    if (inp == 8) {
        Menu_PrimaryWeapon();
        self.current_menu = MENU_PRIMARY_WEAPON;
    }
    if (inp == 9)
    {
            Menu_MiscWeapon();
            self.current_menu = MENU_MISC_WEAPON;
    }
    if (inp == 10)
    {
        DropFromCustomClassGen();
    }

     self.impulse = 0;
  }
};


// ====================================================================
//  Prints Menu of Secondary Weapons Available
// ====================================================================
void() Menu_MiscWeapon =
{
	local string temp;
	temp = ftos(self.money);
	local string l1,l2,l3,l4;
    


l1 = mstr(self.weapons_carried, WEAP_MAUSER, WEAP_AIRF,
	"  .. Mauser          ≠ 2400\n  .. Air-Fist        ≠ 1600\n",
	"* .. Mauser          ≠ 2400\n  .. Air-Fist        ≠ 1600\n",
	"  .. Mauser          ≠ 2400\n* .. Air-Fist        ≠ 1600\n",
	"* .. Mauser          ≠ 2400\n* .. Air-Fist        ≠ 1600\n");

l2 = mstr2(self.weapons_carried, self.weapons_carried, WEAP_DAEDALUS, WEAP_LASERCANNON, 
	"  ï.. Impulse Rifle   ≠ 1500\n  ñ.. Laser Cannon    ≠ 1200\n",
	"* ï.. Impulse Rifle   ≠ 1500\n  ñ.. Laser Cannon    ≠ 1200\n",
	"  ï.. Impulse Rifle   ≠ 1500\n* ñ.. Laser Cannon    ≠ 1200\n",
	"* ï.. Impulse Rifle   ≠ 1500\n* ñ.. Laser Cannon    ≠ 1200\n");

l3="\n\n"; l4="\nö.. –ÚÂˆ    \nõ.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n";

/*l3 = mstr(self.weapons_carried, WEAP_LASER, WEAP_NAILGUN,
	"  ó.. Railgun         ≠  500\n  ò.. Nailgun         ≠  800\n",
	"* ó.. Railgun         ≠  500\n  ò.. Nailgun         ≠  800\n",
	"  ó.. Railgun         ≠  500\n* ò.. Nailgun         ≠  800\n",
	"* ó.. Railgun         ≠  500\n* ò.. Nailgun         ≠  800\n");

    

l2 =	"  ï.. Impulse Rifle   ≠ 1500\n\n\n\n\nö.. –ÚÂˆ    \nõ.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n";

if (self.weapons_carried & WEAP_DAEDALUS)
l2 =	"* ï.. Impulse Rifle   ≠ 1500\n\n\n\n\nö.. –ÚÂˆ    \nõ.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n";*/


	centerprint(self, "úãê CısÙoÌi˙e ŸÔıÚÛÂÏÊ ãú\nãúê MiscØExtra Weapons úã\n\n",l1,l2,l3,l4,temp," dollars left\n");
};                                                     //”Â„ÔÓ‰·Ú˘ ◊Â·ÔÓÛ

void(float inp) Menu_MiscWeapon_Input =
{ 
  if (inp <= 10 && inp >= 1)
  {

        if (inp == 1) {
			BuyWeapon(2400, WEAP_MAUSER);
			//sprint(self, PRINT_HIGH, "Unfortunately all stocks of this item have been requisitioned to increase the glory of the Queen. God save the Queen!\n");
		}
		if (inp == 2) {

			BuyWeapon(1600,WEAP_AIRF);            
			//sprint(self, PRINT_HIGH, "Unfortunately all stocks of this item have been requisitioned to increase the glory of the Queen. God save the Queen!\n");
		}

		if (inp == 3) {

			BuyWeapon(1500,WEAP_DAEDALUS);
        }
		if (inp == 4) {
			if (no_laser)
            {
                sprint(self,PRINT_HIGH,"Laser cannon is disabled, sorry.\n");
                self.impulse = 0;
                return;
            }
            BuyWeapon(1200,WEAP_LASERCANNON);
            
		}/*
		if (inp == 5) {
			BuyWeapon(500,WEAP_LASER);
		}
		if (inp == 6) {
			BuyWeapon(800,WEAP_NAILGUN);
		}
		if (inp == 7) {
			BuyWeapon(300,WEAP_TRANQ);
		}*/
		if (inp == 8) {
			Menu_SecondaryWeapon();
			self.current_menu = MENU_SECONDARY_WEAPON;
		}
		if (inp == 9)
		{
				Menu_Legs();
				self.current_menu = MENU_LEGS;
		}
		if (inp == 10)
		{
			DropFromCustomClassGen();
		}
		
     self.impulse = 0;
  }
};

// =============================
//  Prints Menu of Legs for Sale
// =============================
void() Menu_Legs =
{
	local string temp;
	temp = ftos(self.money);
	local string l1,l2,l3,l4;

	l1 = "  .. Cheetah         ≠ 9000\n  .. Cougar          ≠ 6000\n";
	l2 = "  ï.. White Rhino     ≠ 3250\n  ñ.. Scrub Jay       ≠ 2500\n";
	l3 = "  ó.. KGB Officer     ≠ 1250\n  ò.. Black Mamba     ≠  500\n";
	l4 = "  ô.. ImperialPenguin ≠    0\nö.. –ÚÂˆ    \nõ.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n";

/*
650  9000
420  6000
330  3250
310  2500
290  1250
270  500
250  0
*/

if (self.custom_speed == 650 )
	l1 = "* .. Cheetah         ≠ 9000\n  .. Cougar          ≠ 6000\n";
else if (self.custom_speed == 420 )
	l1 = "  .. Cheetah         ≠ 9000\n* .. Cougar          ≠ 6000\n";
else if (self.custom_speed == 330 )
	l2 = "* ï.. White Rhino     ≠ 3250\n  ñ.. Scrub Jay       ≠ 2500\n";
else if (self.custom_speed == 310 )
	l2 = "  ï.. White Rhino     ≠ 3250\n* ñ.. Scrub Jay       ≠ 2500\n";
else if (self.custom_speed == 290)
	l3 = "* ó.. KGB Officer     ≠ 1250\n  ò.. Black Mamba     ≠  500\n";
else if (self.custom_speed == 270)
	l3 = "  ó.. KGB Officer     ≠ 1250\n* ò.. Black Mamba     ≠  500\n";
else
	l4 = "* ô.. ImperialPenguin ≠    0\nö.. –ÚÂˆ    \nõ.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n";

	centerprint(self, "úãê CısÙoÌi˙e ŸÔıÚÛÂÏÊ ãú\nãúê Leg Enhancements   úã\n\n", l1,l2,l3,l4, temp," dollars left\n");
};                                                     //ÃÂÁ ≈ÓË·Ó„ÂÌÂÓÙÛ

void(float inp) Menu_Legs_Input =
{

    //Second, sell off our current legs
    if (inp < 8) {
    if (self.custom_speed == 650) {
        PrintRefund(9000);
        self.custom_speed = 250;
        if (self.impulse == 1) {self.impulse = 0; return;}
    }
    else if (self.custom_speed == 420) {
        PrintRefund(6000);
        self.custom_speed = 250;
        if (self.impulse == 2) {self.impulse = 0;	return;}
    }
    else if (self.custom_speed == 330) {
        PrintRefund(3250);
        self.custom_speed = 250;
        if (self.impulse == 3) {self.impulse = 0;	return;}
    }
    else if (self.custom_speed == 310) {
        PrintRefund(2500);
        self.custom_speed = 250;
        if (self.impulse == 4) {self.impulse = 0;	return;}
    }
    else if (self.custom_speed == 290) {
        PrintRefund(1250);
        self.custom_speed = 250;
        if (self.impulse == 5) {self.impulse = 0;	return;}
    }
    else if (self.custom_speed == 270) {
        PrintRefund(500);
        self.custom_speed = 250;
        if (self.impulse == 6) {self.impulse = 0;	return;}
    }
    }
    
#undef PRICE
#define PRICE 9000	
    if (inp == 1) {
        if (self.money >= PRICE) {
            self.money = self.money - PRICE;
            self.custom_speed = 650;
            PrintMoney();
        }
        else
            PrintNotEnoughMoney(PRICE);
    }
#undef PRICE
#define PRICE 6000	
    if (inp == 2) {
        if (self.money >= PRICE) {
            self.money = self.money - PRICE;
            self.custom_speed = 420;
            PrintMoney();
        }
        else
            PrintNotEnoughMoney(PRICE);
    }
#undef PRICE
#define PRICE 3250	
    if (inp == 3) {
        if (self.money >= PRICE) {
            self.money = self.money - PRICE;
            self.custom_speed = 330;
            PrintMoney();
        }
        else
            PrintNotEnoughMoney(PRICE);
    }
#undef PRICE
#define PRICE 2500	
    if (inp == 4) {
        if (self.money >= PRICE) {
            self.money = self.money - PRICE;
            self.custom_speed = 310;
            PrintMoney();
        }
        else
            PrintNotEnoughMoney(PRICE);
    }
#undef PRICE
#define PRICE 1250	
    if (inp == 5) {
        if (self.money >= PRICE) {
            self.money = self.money - PRICE;
            self.custom_speed = 290;
            PrintMoney();
        }
        else
            PrintNotEnoughMoney(PRICE);
    }
#undef PRICE
#define PRICE 500	
    if (inp == 6) {
        if (self.money >= PRICE) {
            self.money = self.money - PRICE;
            self.custom_speed = 270;
            PrintMoney();
        }
        else
            PrintNotEnoughMoney(PRICE);
    }
#undef PRICE
#define PRICE 0	
    if (inp == 7) {
        if (self.money >= PRICE) {
            self.money = self.money - PRICE;
            self.custom_speed = 250;
            PrintMoney();
        }
        else
            PrintNotEnoughMoney(PRICE);
    }
    if (inp == 8) {
        Menu_MiscWeapon();
        self.current_menu = MENU_MISC_WEAPON;
    }
    if (inp == 9)
    {
            Menu_Health();
            self.current_menu = MENU_HEALTH;
    }
    if (inp == 10) {
        DropFromCustomClassGen();
    }

    self.impulse = 0;
};

// ==========================================
//  Prints Menu of Armor and Health Available
// ==========================================
void() Menu_Health =
{
	local string temp;
	temp = ftos(self.money);
	local string l1,l2,l3,l4;

l1 = eqstr(self.maxarmor, 75, 100,
	"  .. 75 Green armor  ≠  200\n  .. 100 Yellow      ≠  700\n",
	"* .. 75 Green armor  ≠  200\n  .. 100 Yellow      ≠  700\n",
	"  .. 75 Green armor  ≠  200\n* .. 100 Yellow      ≠  700\n");

l2 = eqstr(self.maxarmor, 150, 200,
	"  ï.. 150 Red         ≠ 1400\n  ñ.. 200 Red         ≠ 2200\n",
	"* ï.. 150 Red         ≠ 1400\n  ñ.. 200 Red         ≠ 2200\n",
	"  ï.. 150 Red         ≠ 1400\n* ñ.. 200 Red         ≠ 2200\n");

l3 =	"  ó.. 300 Red         ≠ 3600\n";

if (self.maxarmor == 300 )
l3 =	"* ó.. 300 Red         ≠ 3600\n";

l4 = 	"  ò.. +50 Health      ≠ 1000\n  ô.. +5 Health       ≠  100\nö.. –ÚÂˆ    \nõ.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n";

	centerprint(self, "úãê CısÙoÌi˙e ŸÔıÚÛÂÏÊ ãú\nãú Armor and Health   úã\n\n", l1,l2,l3,l4, temp," dollars left\n");
};

void(float inp) Menu_Health_Input =
{
    //Fix multiple armor buy bug
    //WW: Modded to allow to sell armor back
    if (inp >= 1 && inp <= 5 && self.maxarmor > 0) {
        if (self.maxarmor == 75)
        {
            if (inp == 1) {
                inp = 0;
                PrintRefund(200);
            }
            else
                self.money = self.money + 200;
        }
        else if (self.maxarmor == 100)
        {
            if (inp == 2) {
                inp = 0;
                PrintRefund(700);
            }
            else
                self.money = self.money + 700;
        }
        else if (self.maxarmor == 150)
        {
            if (inp == 3) {
                inp = 0;
                PrintRefund(1400);
            }
            else
                self.money = self.money + 1400;
        }
        else if (self.maxarmor == 200)
        {
            if (inp == 4) {
                inp = 0;
                PrintRefund(2200);
            }
            else
                self.money = self.money + 2200;
        }
        else if (self.maxarmor == 300)
        {
            if (inp == 5) {
                inp = 0;
                PrintRefund(3600);
            }
            else
                self.money = self.money + 3600;
        }
        self.armor_allowed = self.armorvalue = self.maxarmor = 0;
    }
#undef PRICE
#define PRICE 200	
    if (inp == 1) {
        if (self.money >= PRICE) {
            self.money = self.money - PRICE;
            self.maxarmor = 75;
            self.armorvalue = self.maxarmor;
            self.armortype = 0.3;	// Green
            self.armor_allowed = 0.3; //Green max
            PrintMoney();
        }
        else
            PrintNotEnoughMoney(PRICE);
    }
#undef PRICE
#define PRICE 700
    if (inp == 2) {
        if (self.money >= PRICE) {
            self.money = self.money - PRICE;
            self.maxarmor = 100;
            self.armorvalue = self.maxarmor;
            self.armortype = 0.6;	// Yellow
            self.armor_allowed = 0.6; //Yellow max
            PrintMoney();
        }
        else
            PrintNotEnoughMoney(PRICE);
    }
#undef PRICE
#define PRICE 1400
    if (inp == 3) {
        if (self.money >= PRICE) {
            self.money = self.money - PRICE;
            self.maxarmor = 150;
            self.armorvalue = self.maxarmor;
            self.armortype = 0.8; //Red armor
            self.armor_allowed = 0.8; //Max
            PrintMoney();
        }
        else
            PrintNotEnoughMoney(PRICE);
    }
#undef PRICE
#define PRICE 2200
    if (inp == 4) {
        if (self.money >= PRICE) {
            self.money = self.money - PRICE;
            self.maxarmor = 200;
            self.armorvalue = self.maxarmor;
            self.armortype = 0.8; //Red armor
            self.armor_allowed = 0.8; //Red max
            PrintMoney();
        }
        else
            PrintNotEnoughMoney(PRICE);
    }
#undef PRICE
#define PRICE 3600
    if (inp == 5) {
        if (self.money >= PRICE) {
            self.money = self.money - PRICE;
            self.maxarmor = 300;
            self.armorvalue = self.maxarmor;
            self.armortype = 0.8; //Red armor (used to be 0.9)
            self.armor_allowed = 0.8; //Red max
            PrintMoney();
            W_SetCurrentAmmo ();
        }
        else
            PrintNotEnoughMoney(PRICE);
    }
#undef PRICE
#define PRICE 1000
    if (inp == 6) {
        if (self.money >= PRICE) {
            self.money = self.money - PRICE;
            self.max_health = self.max_health + 50;
            self.health = self.max_health;
            PrintMoney();
        }
        else
        {
            // WW: Modded to allow to sell health back
            //     Buying #6 with <#7 money resets hp
            if (self.money < 100)
            {
                self.money = self.money + ((self.max_health - 50) / 5) * 100;
                self.max_health = 50;
                self.health = self.max_health;
                PrintMoney();
            }
            else
                PrintNotEnoughMoney(PRICE);
        }
    }
#undef PRICE
#define PRICE 100
    if (inp == 7) {
        if (self.money >= PRICE) {
            self.money = self.money - PRICE;
            self.max_health = self.max_health + 5;
            self.health = self.max_health;
            PrintMoney();
        }
        else
            PrintNotEnoughMoney(PRICE);
    }
    if (inp == 8)
    {
        Menu_Legs();
        self.current_menu = MENU_LEGS;
    }
    if (inp == 9) {
        Menu_Armor();
        self.current_menu = MENU_ARMOR;
    }
    if (inp == 10) {
        DropFromCustomClassGen();
    }

    self.impulse = 0;
};


// ==========================================
//  Prints Menu of Special Armor and Ammo
// ==========================================
void() Menu_Armor  =
{
	local string temp;
	temp = ftos(self.money);
	local string l1,l2,l3,l4;

l1 = mstr(self.tf_items, NIT_CERAMIC, NIT_GEL,
	"  .. Ceramic Armor   ≠  575\n  .. Impact Armor    ≠  625\n",
	"* .. Ceramic Armor   ≠  575\n  .. Impact Armor    ≠  625\n",
	"  .. Ceramic Armor   ≠  575\n* .. Impact Armor    ≠  625\n",
	"* .. Ceramic Armor   ≠  575\n* .. Impact Armor    ≠  625\n");

l2 = mstr(self.tf_items, NIT_ASBESTOS, NIT_KEVLAR,
	"  ï.. Asbestos Armor  ≠  750\n  ñ.. Kevlar Armor    ≠ 1200\n",
	"* ï.. Asbestos Armor  ≠  750\n  ñ.. Kevlar Armor    ≠ 1200\n",
	"  ï.. Asbestos Armor  ≠  750\n* ñ.. Kevlar Armor    ≠ 1200\n",
	"* ï.. Asbestos Armor  ≠  750\n* ñ.. Kevlar Armor    ≠ 1200\n");

l3 = mstr(self.tf_items, NIT_BLAST, NIT_AMMO_BACKPACK,
	"  ó.. Blast Armor     ≠ 1500\n  ò.. Ammo Backpack   ≠  300\n",
	"* ó.. Blast Armor     ≠ 1500\n  ò.. Ammo Backpack   ≠  300\n",
	"  ó.. Blast Armor     ≠ 1500\n* ò.. Ammo Backpack   ≠  300\n",
	"* ó.. Blast Armor     ≠ 1500\n* ò.. Ammo Backpack   ≠  300\n");

l4 =	"  ô.. Ammo Bandolier  ≠  200\nö.. –ÚÂˆ    \nõ.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n";

if (self.tf_items & NIT_AMMO_BANDOLIER)
l4 =	"* ô.. Ammo Bandolier  ≠  200\nö.. –ÚÂˆ    \nõ.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n";
	centerprint(self, "úãê CısÙoÌi˙e ŸÔıÚÛÂÏÊ ãú\nãú Special ArmorØAmmo úã\n\n", l1,l2,l3,l4, temp," dollars left\n");
};

void(float inp) Menu_Armor_Input =
{
    if (inp == 1) {
        BuyItem(575,NIT_CERAMIC);
    }
    if (inp == 2) {
        BuyItem(625, NIT_GEL);
    }
    if (inp == 3) {
        BuyItem(750,NIT_ASBESTOS);
    }
    if (inp == 4) {
        BuyItem(1200,NIT_KEVLAR);
    }
    if (inp == 5) {
        BuyItem(1500,NIT_BLAST);
    }
    if (inp == 6) {
        BuyItem(300,NIT_AMMO_BACKPACK);
    }
    if (inp == 7) {
        BuyItem(200,NIT_AMMO_BANDOLIER);
    }
    if (inp == 8)
    {
            Menu_Health();
            self.current_menu = MENU_HEALTH;
    }
    if (inp == 9) {
        Menu_Special();
        self.current_menu = MENU_SPECIAL;
    }
    if (inp == 10) {
        DropFromCustomClassGen();
    }

    self.impulse = 0;
};



// ==================================
//  Prints Menu of Specials Available
// ==================================
void() Menu_Special =
{
	local string temp;
	temp = ftos(self.money);
	local string l1,l2,l3,l4;

l1 = mstr(self.tf_items, NIT_SCANNER, NIT_AUTOSCANNER,
	"  .. Scanner         ≠  650\n  ..   Auto-Scanner  ≠  250\n",
	"* .. Scanner         ≠  650\n  ..   Auto-Scanner  ≠  250\n",
	"  .. Scanner         ≠  650\n* ..   Auto-Scanner  ≠  250\n",
	"* .. Scanner         ≠  650\n* ..   Auto-Scanner  ≠  250\n");

l2 = mstr2(self.cutf_items, self.weapons_carried, CUTF_DETPACK, WEAP_MEDIKIT,
	"  ï.. Detpack         ≠  800\n  ñ.. Medikit         ≠ 1550\n",
	"* ï.. Detpack         ≠  800\n  ñ.. Medikit         ≠ 1550\n",
	"  ï.. Detpack         ≠  800\n* ñ.. Medikit         ≠ 1550\n",
	"* ï.. Detpack         ≠  800\n* ñ.. Medikit         ≠ 1550\n");

l3 = mstr2(self.cutf_items, self.tf_items, CUTF_SPY_KIT, NIT_SCUBA,
	"  ó.. Spy Kit         ≠ 2000\n  ò.. Scuba Gear      ≠ 1000\n",
	"* ó.. Spy Kit         ≠ 2000\n  ò.. Scuba Gear      ≠ 1000\n",
	"  ó.. Spy Kit         ≠ 2000\n* ò.. Scuba Gear      ≠ 1000\n",
	"* ó.. Spy Kit         ≠ 2000\n* ò.. Scuba Gear      ≠ 1000\n");

l4 =	"  ô.. Grapple         ≠ 3000\nö.. –ÚÂˆ    \nõ.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n";

if (self.weapons_carried & WEAP_HOOK)
l4 =	"* ô.. Grapple         ≠ 3000\nö.. –ÚÂˆ    \nõ.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n";
	centerprint(self, "úãê CısÙoÌi˙e ŸÔıÚÛÂÏÊ ãú\nãú Special Items      úã\n\n",l1,l2,l3,l4, temp," dollars left\n");
};

void(float inp) Menu_Special_Input =
{
	local string st2;

//Scanner
#undef PRICE
#define PRICE 650
		
    //st = infokey(NIL, "no_grapple");
    st2 = infokey(NIL, "no_spam");
    if (inp == 1) {
        if (self.tf_items & NIT_SCANNER)
        {
            //Clean up auto-medic (sync this with Custom.qc)
            if (self.tf_items & NIT_AUTOSCANNER)
                self.money = self.money + 250; //Sync this with price below
            self.tf_items &= ~NIT_AUTOSCANNER;

            PrintRefund(PRICE);
            self.tf_items &= ~NIT_SCANNER;
            self.tf_items_flags &= ~NIT_SCANNER_ENEMY;
        }
        else if (self.money >= PRICE) {
            self.money = self.money - PRICE;
            self.tf_items |= NIT_SCANNER;
            self.tf_items_flags |= NIT_SCANNER_ENEMY;
            PrintMoney();
        }
        else
            PrintNotEnoughMoney(PRICE);
    }
    if (inp == 2) { //Sync this with scanner above
        BuyItem(250,NIT_AUTOSCANNER); 
    }
//Detpack
#undef PRICE
#define PRICE 800
    if (inp == 3) {
        if (st2 == "on") {//If admin disable it
            sprint(self,PRINT_HIGH,"The admin has disabled spam devices on this map.\n");
//                self.impulse=0;
            return;
        }
        if (self.cutf_items & CUTF_DETPACK) //Already have it
        {
            PrintRefund(PRICE);
            self.cutf_items = self.cutf_items - CUTF_DETPACK;
            self.maxammo_detpack = self.maxammo_detpack - 1;
        }
        else if (self.money >= PRICE) {
            self.money = self.money - PRICE;
            self.cutf_items |= CUTF_DETPACK;
            self.maxammo_detpack = self.maxammo_detpack + 1;
            PrintMoney();
        }
        else
            PrintNotEnoughMoney(PRICE);
    }
#undef PRICE
#define PRICE 1550
    if (inp == 4) {
        if (self.weapons_carried & WEAP_MEDIKIT)
        {
            PrintRefund(PRICE);
            self.weapons_carried = self.weapons_carried - WEAP_MEDIKIT;
            self.maxammo_medikit = self.maxammo_medikit - 80;
        }
        else if (self.money >= PRICE) {
            self.money = self.money - PRICE;
            self.weapons_carried |= WEAP_MEDIKIT;
            self.maxammo_medikit = self.maxammo_medikit + 80;
            PrintMoney();
        }
        else
            PrintNotEnoughMoney(PRICE);
    }
    if (inp == 5) {
        BuyCuTF(2000,CUTF_SPY_KIT);
    }
    //Self-Contained Underwater Breathing Apparatus
    if (inp == 6) {
        BuyItem(1000,NIT_SCUBA);
    }
    if (inp == 7) {
        if (no_grapple == 1) //If admin disable it
        {
            sprint(self,PRINT_HIGH,"The admin has disabled the grapple on this map.\n");
            self.impulse = 0;
            return;
        }
        else if (allow_hook) //If map allows it...
           sprint(self,PRINT_HIGH,"You can't sell your grapple on this map!\n");
        else
           BuyWeapon(3000,WEAP_HOOK);
    }
    if (inp == 8) {
        Menu_Armor();
        self.current_menu = MENU_ARMOR;
    }
    if (inp == 9) {
        Menu_Special2();
        self.current_menu = MENU_SPECIAL2;
    }
    if (inp == 10) {
        DropFromCustomClassGen();
    }

    self.impulse = 0;
};

// ============================================//
// Prints Menu of Specials Available           //
// ============================================//
void() Menu_Special2 =
{
	local string temp;
	temp = ftos(self.money);
	local string l1,l2,l3,l4;

l1 = mstr(self.cutf_items, CUTF_JAMMER, CUTF_CYBERAUG,
	"  .. Scanner Jammer  ≠ 1000\n  .. CyberAug Unit   ≠  800\n",
	"* .. Scanner Jammer  ≠ 1000\n  .. CyberAug Unit   ≠  800\n",
	"  .. Scanner Jammer  ≠ 1000\n* .. CyberAug Unit   ≠  800\n",
	"* .. Scanner Jammer  ≠ 1000\n* .. CyberAug Unit   ≠  800\n");

/*
l2 = mstr(self.cutf_items, CUTF_SENSOR, CUTF_HOLO,
	"  ï.. Motion sensor   ≠  450\n  ñ.. Holo device     ≠  600\n",
	"* ï.. Motion sensor   ≠  450\n  ñ.. Holo device     ≠  600\n",
	"  ï.. Motion sensor   ≠  450\n* ñ.. Holo device     ≠  600\n",
	"* ï.. Motion sensor   ≠  450\n* ñ.. Holo device     ≠  600\n");
    */

l2 = mstr(self.cutf_items, CUTF_SENSOR, CUTF_FIELDGEN,
	"  ï.. Motion Sensor   ≠  450\n  ñ.. Field Generator ≠ 1600\n",
	"* ï.. Motion Sensor   ≠  450\n  ñ.. Field Generator ≠ 1600\n",
	"  ï.. Motion Sensor   ≠  450\n* ñ.. Field Generator ≠ 1600\n",
	"* ï.. Motion Sensor   ≠  450\n* ñ.. Field Generator ≠ 1600\n");

l3 = mstr(self.cutf_items, CUTF_FULLARMOUR, CUTF_TOSSABLEDET,
	"  ó.. Full Armour     ≠  250\n  ò.. C4 Tossable Det ≠ 1200\n",
	"* ó.. Full Armour     ≠  250\n  ò.. C4 Tossable Det ≠ 1200\n",
	"  ó.. Full Armour     ≠  250\n* ò.. C4 Tossable Det ≠ 1200\n",
	"* ó.. Full Armour     ≠  250\n* ò.. C4 Tossable Det ≠ 1200\n");

l4 =	"  ô.. Dispenser       ≠  600\nö.. –ÚÂˆ    \nõ.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n";

if (self.cutf_items & CUTF_DISPENSER)
l4 =	"* ô.. Dispenser       ≠  600\nö.. –ÚÂˆ    \nõ.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n";
	centerprint(self, "úãê CısÙoÌi˙e ŸÔıÚÛÂÏÊ ãú\nãú More Special Items úã\n\n",l1,l2,l3,l4, temp," dollars left\n");
};

void(float inp) Menu_Special2_Input =
{
	local string st;
	st = infokey(NIL, "no_spam");	

    if (inp == 1)//SB Jammer
		BuyCuTF(1000, CUTF_JAMMER);
	else if (inp == 2)//SB cybernetic augmentation
	{
		if (self.cutf_items & CUTF_CYBERAUG)
		{
			self.maxammo_medikit = self.maxammo_medikit - 80;
			self.maxammo_cells = self.maxammo_cells - 80;
		}
		else
		{
			self.maxammo_medikit = self.maxammo_medikit + 80;
			self.maxammo_cells = self.maxammo_cells + 80;
		}
		BuyCuTF(800,CUTF_CYBERAUG); 
	}
	else if (inp == 3)//SB motion sensor
	{
		BuyCuTF(450,CUTF_SENSOR);
	}
	else if (inp == 4)//SB hax0r tool
	{
        BuyCuTF(1600,CUTF_FIELDGEN);
		//BuyCuTF(600,CUTF_HOLO);
		//sprint(self, PRINT_HIGH, "Activate the holograph with the 'holo' command.\n");
	}
	else if (inp == 5)//SB full armour
	{
		BuyCuTF(250,CUTF_FULLARMOUR);
	}
	else if (inp == 6)//SB C4 tossable detpack
	{
        if (no_c4==1)
        {
            sprint(self,PRINT_HIGH,"The C4 is disabled, sorry\n");
            self.impulse=0;
            return;
        }
        else
        {
            BuyCuTF(1200,CUTF_TOSSABLEDET);
		    sprint(self, PRINT_HIGH, "Type 'throwdet' to throw the detpack.\n");
        }
	}
	else if (inp == 7)
		BuyCuTF(600,CUTF_DISPENSER);
	else if (inp == 8) {
		Menu_Special();
		self.current_menu = MENU_SPECIAL;
	}
	else if (inp == 9) {
		Menu_Gren1();
		self.current_menu = MENU_GREN1;
	}
	else if (inp == 10) {
		DropFromCustomClassGen();
	}

	self.impulse = 0;	
};

////////////////////////////////////////////////////////////////////////
string(float v1, float v2, string s1, string s2, string s3, string s4, string s5, string s6) grenstr =
{
	// Return string based on how values compare to gren1 and gren2
	
	if ((self.tp_grenades_1 != v1 && self.tp_grenades_2 != v1) && (self.tp_grenades_1 != v2 && self.tp_grenades_2 != v2)) return s1;
	// If we have one gren1 and no gren2s, return s2
	if ((self.tp_grenades_1 == v1 || self.tp_grenades_2 == v1) && (self.tp_grenades_1 != v2 && self.tp_grenades_2 != v2) && self.tp_grenades_1 != self.tp_grenades_2) return s2;
	// If no gren1 and one gren2, return s3
	if ((self.tp_grenades_1 != v1 && self.tp_grenades_2 != v1) && (self.tp_grenades_1 == v2 || self.tp_grenades_2 == v2) && self.tp_grenades_1 != self.tp_grenades_2) return s3;
	// If one of both, return s4...
	if ((self.tp_grenades_1 == v1 || self.tp_grenades_2 == v1) && (self.tp_grenades_1 == v2 || self.tp_grenades_2 == v2)) return s4;
	// If two gren1s, return s5
	if (self.tp_grenades_1 == v1 && self.tp_grenades_2 == v1) return s5;
	// If two gren2s, return s6
	if (self.tp_grenades_1 == v2 && self.tp_grenades_2 == v2) return s6;

	return "BUG on grenstr()\n";
};

/*
0 0
1 0
0 1
1 1
2 0
0 2
*/
// ====================================
//  Prints Menu of Grenade-1s Available
// ====================================

void() Menu_Gren1 =
{
	local string temp;
	temp = ftos(self.money);
	local string l1,l2,l3,l4;

l1 = grenstr(GR_TYPE_NORMAL, GR_TYPE_FLAME,
	"  .. Normal          ≠  500\n  .. Flame           ≠  750\n",
	"1 .. Normal          ≠  500\n  .. Flame           ≠  750\n",
	"  .. Normal          ≠  500\n1 .. Flame           ≠  750\n",
	"1 .. Normal          ≠  500\n1 .. Flame           ≠  750\n",
	"2 .. Normal          ≠  500\n  .. Flame           ≠  750\n",
	"  .. Normal          ≠  500\n2 .. Flame           ≠  750\n");

l2 = grenstr(GR_TYPE_GAS, GR_TYPE_EMP,
	"  ï.. Gas             ≠ 1200\n  ñ.. EMP             ≠ 1300\n",
	"1 ï.. Gas             ≠ 1200\n  ñ.. EMP             ≠ 1300\n",
	"  ï.. Gas             ≠ 1200\n1 ñ.. EMP             ≠ 1300\n",
	"1 ï.. Gas             ≠ 1200\n1 ñ.. EMP             ≠ 1300\n",
	"2 ï.. Gas             ≠ 1200\n  ñ.. EMP             ≠ 1300\n",
	"  ï.. Gas             ≠ 1200\n2 ñ.. EMP             ≠131200\n");

l3 = grenstr(GR_TYPE_FRAG, GR_TYPE_NAIL,
	"  ó.. Frag            ≠ 1300\n  ò.. Nail            ≠ 1400\n",
	"1 ó.. Frag            ≠ 1300\n  ò.. Nail            ≠ 1400\n",
	"  ó.. Frag            ≠ 1300\n1 ò.. Nail            ≠ 1400\n",
	"1 ó.. Frag            ≠ 1300\n1 ò.. Nail            ≠ 1400\n",
	"2 ó.. Frag            ≠ 1300\n  ò.. Nail            ≠ 1400\n",
	"  ó.. Frag            ≠ 1300\n2 ò.. Nail            ≠ 1400\n");

l4 =	"  ô.. MIRV            ≠ 1500\nö.. –ÚÂˆ    \nõ.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n";
if (self.tp_grenades_1 == GR_TYPE_MIRV && self.tp_grenades_2 == GR_TYPE_MIRV)
l4 =	"2 ô.. MIRV            ≠ 1500\nö.. –ÚÂˆ    \nõ.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n";
else if (self.tp_grenades_2 == GR_TYPE_MIRV || self.tp_grenades_1 == GR_TYPE_MIRV)
l4 =	"1 ô.. MIRV            ≠ 1500\nö.. –ÚÂˆ    \nõ.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n";

//l4 =	"\nö.. –ÚÂˆ    \nõ.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n";

	centerprint(self, "úãê CısÙoÌi˙e ŸÔıÚÛÂÏÊ ãú\nãú Grenades ≠ Combat  úã\n\n",l1,l2,l3,l4, temp," dollars left\n");


};
void(float inp) Menu_Gren1_Input =
{	
	local string st, st2;
	st = infokey(NIL, "no_gasgren");
	st2 = infokey (NIL, "no_spam");

    if (inp == 1)
        BuyGren(500,GR_TYPE_NORMAL);
    else if (inp == 2)
        BuyGren(750,GR_TYPE_FLAME);
    else if (inp == 3)
    {
        if (st == "on")
        {
            sprint(self, PRINT_HIGH, "The admin has disabled gas grens on this map.\n");
            return;
        }
        if (st2 == "on") //If admin disable it
        {
            sprint(self,PRINT_HIGH,"The admin has disabled spam devices on this map.\n");
            return;
        }
        BuyGren(1200,GR_TYPE_GAS);
    }
    else if (inp == 4)
    {
        if (st2 == "on") //If admin disable it
        {
            sprint(self,PRINT_HIGH,"The admin has disabled spam devices on this map.\n");
            return;
        }
        BuyGren(1300,GR_TYPE_EMP);
    }
    else if (inp == 5)
    {
        if (st2 == "on") //If admin disable it
        {
            sprint(self,PRINT_HIGH,"The admin has disabled spam devices on this map.\n");
            return;
        }
        BuyGren(1300,GR_TYPE_FRAG);
    }
    else if (inp == 6)
    {
        BuyGren(1400,GR_TYPE_NAIL);
    }
    if (inp == 7)
    {
        if (st2 == "on") //If admin disable it
        {
            sprint(self,PRINT_HIGH,"The admin has disabled spam devices on this map.\n");
                return;
        }
        BuyGren(1500,GR_TYPE_MIRV);
    }
    
    if (inp == 8)
    {
        Menu_Special2();
        self.current_menu = MENU_SPECIAL2;
    }
    if (inp == 9)
    {
        Menu_Gren2();
        self.current_menu = MENU_GREN2;
    }
    else if (inp == 10)
        DropFromCustomClassGen();

    self.impulse = 0;
};


// ====================================
//  Prints Menu of Grenade-2s Available
// ====================================
void() Menu_Gren2 =
{
	local string temp;
	temp = ftos(self.money);
	local string l1,l2,l3,l4;

l1 = grenstr(GR_TYPE_FLARE, GR_TYPE_CALTROP,
	"  .. Flare           ≠  300\n  .. Caltrop         ≠  500\n",
	"1 .. Flare           ≠  300\n  .. Caltrop         ≠  500\n",
	"  .. Flare           ≠  300\n1 .. Caltrop         ≠  500\n",
	"1 .. Flare           ≠  300\n1 .. Caltrop         ≠  500\n",
	"2 .. Flare           ≠  300\n  .. Caltrop         ≠  500\n",
	"  .. Flare           ≠  300\n2 .. Caltrop         ≠  500\n");

l2 = grenstr(GR_TYPE_CONCUSSION, GR_TYPE_FLASH,
	"  ï.. Concussion      ≠ 1000\n  ñ.. Flash           ≠ 1000\n",
	"1 ï.. Concussion      ≠ 1000\n  ñ.. Flash           ≠ 1000\n",
	"  ï.. Concussion      ≠ 1000\n1 ñ.. Flash           ≠ 1000\n",
	"1 ï.. Concussion      ≠ 1000\n1 ñ.. Flash           ≠ 1000\n",
	"2 ï.. Concussion      ≠ 1000\n  ñ.. Flash           ≠ 1000\n",
	"  ï.. Concussion      ≠ 1000\n2 ñ.. Flash           ≠ 1000\n");

l3 = grenstr(GR_TYPE_ANTIGRAV, GR_TYPE_BIO,
	"  ó.. AntiGrav        ≠ 1000\n  ò.. Bio-Infection   ≠ 1450\n",
	"1 ó.. AntiGrav        ≠ 1000\n  ò.. Bio-Infection   ≠ 1450\n",
	"  ó.. AntiGrav        ≠ 1000\n1 ò.. Bio-Infection   ≠ 1450\n",
	"1 ó.. AntiGrav        ≠ 1000\n1 ò.. Bio-Infection   ≠ 1450\n",
	"2 ó.. AntiGrav        ≠ 1000\n  ò.. Bio-Infection   ≠ 1450\n",
	"  ó.. AntiGrav        ≠ 1000\n2 ò.. Bio-Infection   ≠ 1450\n");

//.. Flash           ≠ 1000
//.. Krac            ≠ 1500

l4 = 	"  ô.. Krac            ≠ 1500\nö.. –ÚÂˆ    \nõ.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n";

if (self.tp_grenades_1 == GR_TYPE_KRAC && self.tp_grenades_2 == GR_TYPE_KRAC)
l4 =	"2 ô.. Krac            ≠ 1500\nö.. –ÚÂˆ    \nõ.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n";
else if (self.tp_grenades_1 == GR_TYPE_KRAC || self.tp_grenades_2 == GR_TYPE_KRAC)
l4 =	"1 ô.. Krac            ≠ 1500\nö.. –ÚÂˆ    \nõ.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n";

//l4 =	"\nö.. –ÚÂˆ    \nõ.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n";
	centerprint(self, "úãê CısÙoÌi˙e ŸÔıÚÛÂÏÊ ãú\nãú Grenades ≠ Utility úã\n\n",l1,l2,l3,l4, temp," dollars left\n");
    
};
void(float inp) Menu_Gren2_Input =
{
	local string st, st2;
	st = infokey(NIL, "no_antigrav");
	st2 = infokey(NIL, "no_spam");

    //WK I should have done all the buy menus like this
    //SB I reckon - this one actually looks nice and makes sense
    if (inp == 1)
    {
        BuyGren(300, GR_TYPE_FLARE);
    }
    if (inp == 2)
    {
        if (st2 == "on")
            sprint(self, PRINT_HIGH, "The admin has disabled spam devices on this map.\n");
        else
            BuyGren(500, GR_TYPE_CALTROP);
    }
    if (inp == 3)
    {
        BuyGren(1000, GR_TYPE_CONCUSSION);
    }
    if (inp == 4)
    {
        BuyGren(1000,GR_TYPE_FLASH);
    }
    if (inp == 5)
    {	
        if (st == "on")
            sprint(self, PRINT_HIGH, "The admin has disabled anti-grav grens on this map.\n");
        else	
            BuyGren(1000, GR_TYPE_ANTIGRAV);
    }
    if (inp == 6)
    {
        BuyGren(1450, GR_TYPE_BIO);
    }
    if (inp == 7)
    {
        BuyGren(1500, GR_TYPE_KRAC);
    }
    else if (inp == 8)
    {
        Menu_Gren1();
        self.current_menu = MENU_GREN1;
    }
    else if (inp == 9)
    {
        Menu_Engineering();
        self.current_menu = MENU_ENGINEERING;
    }
    if (inp == 10)
    {
        DropFromCustomClassGen();
    }

    self.impulse = 0;
};

//////////////////////////////////////////////////////////////////////////////

// ====================================
//  Prints Menu of Grenade-1s Available
// ====================================
/*void() Menu_Gren1 =
{
	local string temp;
	temp = ftos(self.money);
	local string l1,l2,l3,l4;

l1 = eqstr(self.tp_grenades_1, GR_TYPE_NORMAL, GR_TYPE_FLASH,
	"  .. Normal          ≠  500\n  .. Flash           ≠ 1000\n",
	"* .. Normal          ≠  500\n  .. Flash           ≠ 1000\n",
	"  .. Normal          ≠  500\n* .. Flash           ≠ 1000\n");

l2 = eqstr(self.tp_grenades_1, GR_TYPE_ANTIGRAV, GR_TYPE_EMP,
	"  ï.. AntiGrav        ≠ 1200\n  ñ.. EMP             ≠ 1200\n",
	"* ï.. AntiGrav        ≠ 1200\n  ñ.. EMP             ≠ 1200\n",
	"  ï.. AntiGrav        ≠ 1200\n* ñ.. EMP             ≠ 1200\n");

    if (allow_antigrav==0) {
l2 = eqstr(self.tp_grenades_1, GR_TYPE_CONCUSSION, GR_TYPE_EMP,
	"  ï.. Concussion      ≠ 1000\n  ñ.. EMP             ≠ 1200\n",
	"* ï.. Concussion      ≠ 1000\n  ñ.. EMP             ≠ 1200\n",
	"  ï.. Concussion      ≠ 1000\n* ñ.. EMP             ≠ 1200\n");
    }

l3 = eqstr(self.tp_grenades_1, GR_TYPE_FRAG, GR_TYPE_FLAME,
	"  ó.. Frag            ≠ 1425\n  ò.. Flame           ≠ 1425\n",
	"* ó.. Frag            ≠ 1425\n  ò.. Flame           ≠ 1425\n",
	"  ó.. Frag            ≠ 1425\n* ò.. Flame           ≠ 1425\n");

l4 = 	"  ô.. Krac            ≠ 1500\nö.. –ÚÂˆ    \nõ.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n";

if (self.tp_grenades_1 == GR_TYPE_KRAC)
l4 =	"* ô.. Krac            ≠ 1500\nö.. –ÚÂˆ    \nõ.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n";
	centerprint(self, "úãê CısÙoÌi˙e ŸÔıÚÛÂÏÊ ãú\nãú Grenades - 1st Slotúã\n\n",l1,l2,l3,l4, temp," dollars left\n");
};
void(float inp) Menu_Gren1_Input =
{
	local string st2, st3;
	
	st2 = infokey(NIL, "no_spam");
    
	if (inp <= 10 && inp >= 1)
	{
		//WK I should have done all the buy menus like this
		//SB I reckon - this one actually looks nice and makes sense
		if (inp == 1) {
			BuyGren1(500,GR_TYPE_NORMAL);
		}
		if (inp == 2) {
			BuyGren1(1000,GR_TYPE_FLASH);
		}
		if (inp == 3) {
			if (allow_antigrav == 0)
				//sprint(self,PRINT_HIGH,"The admin has disabled anti-grav grens on this map.\n");
                BuyGren1(1000,GR_TYPE_CONCUSSION);
			else	
				BuyGren1(1200,GR_TYPE_ANTIGRAV);
		}
		if (inp == 4) {
			BuyGren1(1200,GR_TYPE_EMP);
		}
		if (inp == 5) {	
			if (st2 == "on") {//If admin disable it
				sprint(self,PRINT_HIGH,"The admin has disabled spam devices on this map.\n");
                        return;
			}
			BuyGren1(1425,GR_TYPE_FRAG);
		}
		if (inp == 6) {
			BuyGren1(1425,GR_TYPE_FLAME);
		}
		if (inp == 7) {
			BuyGren1(1500,GR_TYPE_KRAC);
		}
		if (inp == 8) {
			Menu_Special2();
			self.current_menu = MENU_SPECIAL2;
		}
		if (inp == 9) {
			Menu_Gren2();
			self.current_menu = MENU_GREN2;
		}
		if (inp == 10) {
			DropFromCustomClassGen();
		}

		self.impulse = 0;
	}
};


// ====================================
//  Prints Menu of Grenade-2s Available
// ====================================
void() Menu_Gren2 =
{
	local string temp,st;
	temp = ftos(self.money);
	st = infokey(NIL, "no_flare");
    local string l1,l2,l3,l4;

l1 = eqstr(self.tp_grenades_2, GR_TYPE_FLARE, GR_TYPE_CONCUSSION,
	"  .. Flare           ≠  400\n  .. Concussion      ≠ 1000\n",
	"* .. Flare           ≠  400\n  .. Concussion      ≠ 1000\n",
	"  .. Flare           ≠  400\n* .. Concussion      ≠ 1000\n");

    if (st == "on" || st == "1") {

l1 = eqstr(self.tp_grenades_2, GR_TYPE_NORMAL, GR_TYPE_CONCUSSION,
	"  .. Normal          ≠  500\n  .. Concussion      ≠ 1000\n",
	"* .. Normal          ≠  500\n  .. Concussion      ≠ 1000\n",
	"  .. Normal          ≠  500\n* .. Concussion      ≠ 1000\n");
    }

l2 = eqstr(self.tp_grenades_2, GR_TYPE_GAS, GR_TYPE_EMP,
	"  ï.. Gas             ≠ 1200\n  ñ.. EMP             ≠ 1200\n",
	"* ï.. Gas             ≠ 1200\n  ñ.. EMP             ≠ 1200\n",
	"  ï.. Gas             ≠ 1200\n* ñ.. EMP             ≠ 1200\n");

l3 = eqstr(self.tp_grenades_2, GR_TYPE_MIRV, GR_TYPE_FLAME,
	"  ó.. MIRV            ≠ 1200\n  ò.. Flame           ≠ 1425\n",
	"* ó.. MIRV            ≠ 1200\n  ò.. Flame           ≠ 1425\n",
	"  ó.. MIRV            ≠ 1200\n* ò.. Flame           ≠ 1425\n");

l4 =	"  ô.. Nail            ≠ 2000\nö.. –ÚÂˆ    \nõ.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n";

if (self.tp_grenades_2 == GR_TYPE_NAIL)
l4 =	"* ô.. Nail            ≠ 2000\nö.. –ÚÂˆ    \nõ.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n";

	centerprint(self, "úãê CısÙoÌi˙e ŸÔıÚÛÂÏÊ ãú\nãú Grenades - 2nd Slotúã\n\n", l1,l2,l3,l4, temp," dollars left\n");
};
void(float inp) Menu_Gren2_Input =
{	
	local string st, st2,st3;
	st = infokey(NIL, "no_gasgren");
	st2 = infokey (NIL, "no_spam");
    st3 = infokey(NIL, "no_flare");
	if (inp <= 10 && inp >= 1)
	{
		if (inp == 1) {
			if (st3 == "on" || st3 == "1") 
              BuyGren2(500,GR_TYPE_NORMAL);
            else
              BuyGren2(400,GR_TYPE_FLARE);
		}
		if (inp == 2) {
			BuyGren2(1000,GR_TYPE_CONCUSSION);
		}
		if (inp == 3) {
			if (st == "on"){
				sprint(self,PRINT_HIGH,"The admin has disabled gas grens on this map.\n");
				return;
			}
			if (st2 == "on") {//If admin disable it
				sprint(self,PRINT_HIGH,"The admin has disabled spam devices on this map.\n");
                        return;
				}
			BuyGren2(1200,GR_TYPE_GAS);
		}
		if (inp == 4) {
			BuyGren2(1200,GR_TYPE_EMP);
		}
		if (inp == 5) {
			if (st2 == "on") {//If admin disable it
				sprint(self,PRINT_HIGH,"The admin has disabled spam devices on this map.\n");
                        return;
				}
			BuyGren2(1200,GR_TYPE_MIRV);
		}
		if (inp == 6) {
			BuyGren2(1425,GR_TYPE_FLAME);
		}
		if (inp == 7) {
			if (st2 == "on") {//If admin disable it
				sprint(self,PRINT_HIGH,"The admin has disabled spam devices on this map.\n");
                        return;
				}
			BuyGren2(2000,GR_TYPE_NAIL);
		}
		if (inp == 8) {
			Menu_Gren1();
			self.current_menu = MENU_GREN1;
		}
		if (inp == 9) {
			Menu_Engineering();
			self.current_menu = MENU_ENGINEERING;
		}
		if (inp == 10) {
			DropFromCustomClassGen();
		}

		self.impulse = 0;
	}
};*/


// ====================================
//  Prints Menu of Optional Items Here
// ====================================
void() Menu_Engineering =
{
	local string temp;
	temp = ftos(self.money);
	local string l1,l2,l3,l4;

l1 = mstr2(self.weapons_carried,self.cutf_items,WEAP_SPANNER,CUTF_SENTRYGUN,
	"  .. Spanner         ≠ 1200\n  .. Build Sentrygun ≠ 1500\n",
	"* .. Spanner         ≠ 1200\n  .. Build Sentrygun ≠ 1500\n",
	"  .. Spanner         ≠ 1200\n* .. Build Sentrygun ≠ 1500\n",
	"* .. Spanner         ≠ 1200\n* .. Build Sentrygun ≠ 1500\n");

l2 = mstr(self.tf_items,NIT_TURRET,NIT_TESLA,
	"  ï..  Turret Upgrade ≠  700\n  ñ.. Build Tesla     ≠ 1350\n",
	"* ï..  Turret Upgrade ≠  700\n  ñ.. Build Tesla     ≠ 1350\n",
	"  ï..  Turret Upgrade ≠  700\n* ñ.. Build Tesla     ≠ 1350\n",
	"* ï..  Turret Upgrade ≠  700\n* ñ.. Build Tesla     ≠ 1350\n");

l3 = mstr(self.tf_items, NIT_TESLA_UPGRADE, NIT_SECURITY_CAMERA,
	"  ó..   Tesla Upgrade ≠ 1650\n  ò.. Build Camera    ≠  350\n",
	"* ó..   Tesla Upgrade ≠ 1650\n  ò.. Build Camera    ≠  350\n",
	"  ó..   Tesla Upgrade ≠ 1650\n* ò.. Build Camera    ≠  350\n",
	"* ó..   Tesla Upgrade ≠ 1650\n* ò.. Build Camera    ≠  350\n");

l4 =	"  ô.. BuildTeleporter ≠ 1100\nö.. –ÚÂˆ    \nõ.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n";

if (self.tf_items & NIT_TELEPORTER)
l4 =	"* ô.. BuildTeleporter ≠ 1100\nö.. –ÚÂˆ    \nõ.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n";
	centerprint(self, "úãê CısÙoÌi˙e ŸÔıÚÛÂÏÊ ãú\nãú Engineering Items  úã\n\n", l1,l2,l3,l4, temp," dollars left\n");
};
void(float inp) Menu_Engineering_Input =
{
    if (inp == 1) {
        BuyWeapon(1200,WEAP_SPANNER);
    }
    if (inp == 2) {
        BuyCuTF(1500,CUTF_SENTRYGUN);
    }
    if (inp == 3) {
        BuyItem(700,NIT_TURRET); 
    }
    if (inp == 4) {
        BuyItem(1350,NIT_TESLA);
    }
    if (inp == 5) {
        BuyItem(1650,NIT_TESLA_UPGRADE);
    }
    if (inp == 6) {
        BuyItem(350,NIT_SECURITY_CAMERA);
    }
    if (inp == 7) {
        BuyItem(1100,NIT_TELEPORTER);
    }
    if (inp == 8) {
        Menu_Gren2();
        self.current_menu = MENU_GREN2;
    }
    if (inp == 9) {
        if (custom_mode!=1)
        {
            Menu_Profession();
            self.current_menu = MENU_PROFESSION;
        }
        else
        {
            Menu_Proficiency();
            self.current_menu = MENU_PROFICIENCY;
        }
    }
    if (inp == 10) {
        DropFromCustomClassGen();
    }

    self.impulse = 0;
};

// =====================================
//  Prints Menu of Professions Available
// =====================================
void() Menu_Profession =
{
	local string temp;
	temp = ftos(self.money);
	local string l1,l2,l3,l4;

l1 = eqstr(self.job, JOB_THIEF, JOB_RUNNER,
	"  .. Thief     ®Hide©≠  950\n  .. Runner  ®Sprint©≠  400\n",
	"* .. Thief     ®Hide©≠  950\n  .. Runner  ®Sprint©≠  400\n",
	"  .. Thief     ®Hide©≠  950\n* .. Runner  ®Sprint©≠  400\n");

l2 = eqstr(self.job, JOB_WARLOCK, JOB_CHAPLAN,
	"  ï.. Warlock ®Summon©≠ 1350\n  ñ.. Chaplan®Inspire©≠ 1200\n",
	"* ï.. Warlock ®Summon©≠ 1350\n  ñ.. Chaplan®Inspire©≠ 1200\n",
	"  ï.. Warlock ®Summon©≠ 1350\n* ñ.. Chaplan®Inspire©≠ 1200\n");

l3 = eqstr(self.job, JOB_BERSERKER, JOB_GUERILLA,
	"  ó.. Berserker ®Fury©≠ 1200\n  ò.. Guerilla ®Mines©≠ 1500\n",
	"* ó.. Berserker ®Fury©≠ 1200\n  ò.. Guerilla ®Mines©≠ 1500\n",
	"  ó.. Berserker ®Fury©≠ 1200\n* ò.. Guerilla ®Mines©≠ 1500\n");

l4 =	"  ô.. Judoka  ®Disarm©≠  700\nö.. –ÚÂˆ    \nõ.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n";

if (self.job == JOB_JUDOKA)
l4 =	"* ô.. Judoka  ®Disarm©≠  700\nö.. –ÚÂˆ    \nõ.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n";

	centerprint(self, "úãê CısÙoÌi˙e ŸÔıÚÛÂÏÊ ãú\nãú Skilled Profession úã\n\n", l1,l2,l3,l4, temp," dollars left\n\nUse ”À…ÃÃ to trigger ability\n");

};
void(float inp) Menu_Profession_Input =
{
    if (inp == 1) {
        BuyJob( 950,JOB_THIEF);
    }
    if (inp == 2) {
        BuyJob( 400,JOB_RUNNER);
    }
    if (inp == 3) { //Sync this with price in knife
        BuyJob( 1350,JOB_WARLOCK);
    }
    if (inp == 4) {
        if (no_chaplan)
        {
            sprint(self,PRINT_HIGH,"Chaplan is disabled, sorry.\n");
            self.impulse=0;
            return;
        }

        BuyJob(1200,JOB_CHAPLAN);
    }
    if (inp == 5) {
        BuyJob(1200,JOB_BERSERKER);
    }
    if (inp == 6) {
        BuyJob(1500,JOB_GUERILLA);
    }
    if (inp == 7) {
        BuyJob( 700,JOB_JUDOKA);
    }
    if (inp == 8) {
        Menu_Engineering();
        self.current_menu = MENU_ENGINEERING;
    }
    if (inp == 9) {
        Menu_Profession2();
        self.current_menu = MENU_PROFESSION2;
    }
    if (inp == 10) {
        DropFromCustomClassGen();
    }

    self.impulse = 0;
};



// ==================================
//  Prints Second page of Professions
// ==================================
void() Menu_Profession2 =
{
	local string temp;
	temp = ftos(self.money);
	local string l1,l2,l3,l4;

l1 = eqstr(self.job, JOB_ARMY, JOB_HACKER,
      "  .. Army   ®Soldier©≠ 1250\n  .. CyberNet  ®Hack©≠ 1200\n",
      "* .. Army   ®Soldier©≠ 1250\n  .. CyberNet  ®Hack©≠ 1200\n",
      "  .. Army   ®Soldier©≠ 1250\n* .. CyberNet  ®Hack©≠ 1200\n");

l2 = eqstr(self.job, JOB_MARTYR, JOB_CRUSADER,
	"  ï.. Martyr ®Suicide©≠ 1000\n  ñ.. Crusader ®Auras©≠ 1600\n",
	"* ï.. Martyr ®Suicide©≠ 1000\n  ñ.. Crusader ®Auras©≠ 1600\n",
	"  ï.. Martyr ®Suicide©≠ 1000\n* ñ.. Crusader ®Auras©≠ 1600\n");


/*l2 = eqstr(self.job, JOB_MARTYR, JOB_MYSTIC,
	"  ï.. Martyr ®Suicide©≠ 1000\n  ñ.. Mystic   ®Regen©≠ 1000\n",
	"* ï.. Martyr ®Suicide©≠ 1000\n  ñ.. Mystic   ®Regen©≠ 1000\n",
	"  ï.. Martyr ®Suicide©≠ 1000\n* ñ.. Mystic   ®Regen©≠ 1000\n");*/

/*l3 = eqstr(self.job, JOB_BERSERKER, JOB_GUERILLA,
	"  -.. Berserker ®Fury©- 1200\n  ò.. Guerilla ®Mines©- 1500\n",
	"* -.. Berserker ®Fury©- 1200\n  ò.. Guerilla ®Mines©- 1500\n",
	"  -.. Berserker ®Fury©- 1200\n* ò.. Guerilla ®Mines©- 1500\n");*/

l4 = "\nö.. –ÚÂˆ    \nõ.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n";
//l3 = "\n\n";
l3 = "\n\n";

/*l2 =	"  ï.. Martyr ®Suicide©≠ 1000";

if (self.job == JOB_MARTYR)
l2 =	"* ï.. Martyr ®Suicide©≠ 1000";*/

	centerprint(self, "úãê CısÙoÌi˙e ŸÔıÚÛÂÏÊ ãú\nãú More Professions   úã\n\n", l1,l2,l3,l4, temp," dollars left\n\nUse ”À…ÃÃ to trigger ability\n");
		
};
void(float inp) Menu_Profession2_Input =
{
    if (inp == 1) {
        if (no_army==1)
        {
            sprint(self,PRINT_HIGH,"Army job is disabled\n");
            self.impulse=0;
            return;
        }
        else
           BuyJob( 1250,JOB_ARMY);
    }
    if (inp == 2) {
        BuyJob( 1200,JOB_HACKER);
    }
    if (inp == 3) { 
        BuyJob( 1000,JOB_MARTYR);
    }
    if (inp == 4) {
        BuyJob(1600,JOB_CRUSADER);
    }
    /*
    if (inp == 5) {
        BuyJob(1200,JOB_BERSERKER);
    }
    if (inp == 6) {
        BuyJob(1500,JOB_GUERILLA);
    }
    if (inp == 7) {
        BuyJob( 700,JOB_JUDOKA);
    }*/
    if (inp == 8) {
        Menu_Profession();
        self.current_menu = MENU_PROFESSION;
    }
    if (inp == 9) {
        Menu_Proficiency();
        self.current_menu = MENU_PROFICIENCY;
    }
    if (inp == 10) {
        DropFromCustomClassGen();
    }

    self.impulse = 0;
};


// =====================================
//  Prints Menu of Proficiencies Available
// =====================================
void() Menu_Proficiency =
{
	local string temp;
	temp = ftos(self.money);
	local string l1,l2,l3,l4;

l1 = mstr(self.cutf_items, CUTF_STEALTH, CUTF_HIGHJUMP,
	"  .. Stealth         ≠  400\n  .. Highjump        ≠  200\n",
	"* .. Stealth         ≠  400\n  .. Highjump        ≠  200\n",
	"  .. Stealth         ≠  400\n* .. Highjump        ≠  200\n",
	"* .. Stealth         ≠  400\n* .. Highjump        ≠  200\n");

l2 = mstr(self.cutf_items, CUTF_HWGUY, CUTF_EXPBODY,
	"  ï.. Aspect of HWGuy ≠  450\n  ñ.. Exp. Body       ≠ 1200\n",
	"* ï.. Aspect of HWGuy ≠  450\n  ñ.. Exp. Body       ≠ 1200\n",
	"  ï.. Aspect of HWGuy ≠  450\n* ñ.. Exp. Body       ≠ 1200\n",
	"* ï.. Aspect of HWGuy ≠  450\n* ñ.. Exp. Body       ≠ 1200\n");

l3 = mstr(self.cutf_items, CUTF_GYMNAST, CUTF_DEMONLORE,
	"  ó.. Gymnast         ≠  450\n  ò.. Demon Lore      ≠  300\n",
	"* ó.. Gymnast         ≠  450\n  ò.. Demon Lore      ≠  300\n",
	"  ó.. Gymnast         ≠  450\n* ò.. Demon Lore      ≠  300\n",
	"* ó.. Gymnast         ≠  450\n* ò.. Demon Lore      ≠  300\n");

l4 =	"  ô.. Close Combat    ≠  600\nö.. –ÚÂˆ    \nõ.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n";

if (self.cutf_items & CUTF_CLOSECOMBAT)
l4 =	"* ô.. Close Combat    ≠  600\nö.. –ÚÂˆ    \nõ.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n";
	centerprint(self, "úãê CısÙoÌi˙e ŸÔıÚÛÂÏÊ ãú\nãú Proficiency        úã\n\n", l1,l2,l3,l4, temp," dollars left\n");
}; 
void(float inp) Menu_Proficiency_Input =
{
    if (inp == 1) {
        BuyCuTF( 400,CUTF_STEALTH);
    }
    if (inp == 2) {
        BuyCuTF( 200,CUTF_HIGHJUMP);
    }
    if (inp == 3) {
        if (self.cutf_items & CUTF_GYMNAST)
            sprint(self, PRINT_HIGH, "Having Gymnast and Aspect of HWGuy proficiencies is illogical.\n");
        else
            BuyCuTF( 450,CUTF_HWGUY);
    }
    if (inp == 4) {
        BuyCuTF(1200,CUTF_EXPBODY);
    }
    if (inp == 5) {
        if (self.cutf_items & CUTF_HWGUY)
            sprint(self, PRINT_HIGH, "Trust me, you don't want Aspect of HWGuy AND Gymnast.\n");
        else
            BuyCuTF( 450,CUTF_GYMNAST);
    }
    if (inp == 6) {
        BuyCuTF( 300,CUTF_DEMONLORE);
    }
    if (inp == 7) {
        BuyCuTF( 600,CUTF_CLOSECOMBAT);
    }
    if (inp == 8) {
        if (custom_mode!=1)
        {
            Menu_Profession2();
            self.current_menu = MENU_PROFESSION2;
        }
        else
        {
            Menu_Engineering();
            self.current_menu = MENU_ENGINEERING;
        }             
    }
    if (inp == 9) {
        Menu_Option();
        self.current_menu = MENU_OPTION;
    }
    if (inp == 10) {
        DropFromCustomClassGen();
    }

    self.impulse = 0;
};

// ====================================
//  Prints Menu of Optional Items Here
// ====================================
void() Menu_Option =
{
	local string temp;
	temp = ftos(self.money);
	local string l1,l2,l3,l4;

l1 = mstr(self.tf_items, NIT_AUTOID, NIT_RESPAWN_GUARD,
	"  .. Auto-ID         ≠   25\n  .. Respawn Guard   ≠   25\n",
	"* .. Auto-ID         ≠   25\n  .. Respawn Guard   ≠   25\n",
	"  .. Auto-ID         ≠   25\n* .. Respawn Guard   ≠   25\n",
	"* .. Auto-ID         ≠   25\n* .. Respawn Guard   ≠   25\n");

//l2 = mstr2(self.cutf_items,self.tf_items,CUTF_OTR,NIT_HOVER_BOOTS,
l2 = mstr(self.tf_items,NIT_HOVER_BOOTS, NIT_HOVER_BOOTS_UPGRADE,
	"  ï.. Hover Boots     ≠  850\n  ñ..   Boot Upgrade  ≠  350\n",
	"* ï.. Hover Boots     ≠  850\n  ñ..   Boot Upgrade  ≠  350\n",
	"  ï.. Hover Boots     ≠  850\n* ñ..   Boot Upgrade  ≠  350\n",
	"* ï.. Hover Boots     ≠  850\n* ñ..   Boot Upgrade  ≠  350\n");

l3 = mstr2(self.tf_items, self.cutf_items, NIT_RL_LASER_SIGHT, CUTF_OTR,
	"  ó.. Laser Guided RL ≠ 1000\n  ò.. OTR Bullets     ≠ 1850\n",
	"* ó.. Laser Guided RL ≠ 1000\n  ò.. OTR Bullets     ≠ 1850\n",  //..   Boot Upgrade  ≠  350
	"  ó.. Laser Guided RL ≠ 1000\n* ò.. OTR Bullets     ≠ 1850\n",
	"* ó.. Laser Guided RL ≠ 1000\n* ò.. OTR Bullets     ≠ 1850\n");

l4 =	"  ô.. Cluster Rockets ≠ 3250\nö.. –ÚÂˆ    \nõ..         \n.. ƒÔÓÂ!   \n";

if (self.tf_items & NIT_CLUSTER_ROCKETS )
l4 =	"* ô.. Cluster Rockets ≠ 3250\nö.. –ÚÂˆ    \nõ..         \n.. ƒÔÓÂ!   \n";
	centerprint(self, "úãê CısÙoÌi˙e ŸÔıÚÛÂÏÊ ãú\nãú Optional Equipment úã\n\n", l1,l2,l3,l4, temp," dollars left\n");
};
void(float inp) Menu_Option_Input =
{
    if (inp == 1) {
        BuyItem(25,NIT_AUTOID);
    }
    if (inp == 2) { 
        BuyItem(25,NIT_RESPAWN_GUARD);
    }
    if (inp == 6) { 
        if (no_otr==1)
        {
            sprint(self,PRINT_HIGH,"OTR bullets are disabled\n");
            self.impulse=0;
            return;
        }
        else
          BuyCuTF(1850,CUTF_OTR);
    }
    if (inp == 3) {
        BuyItem(850,NIT_HOVER_BOOTS);
    }
    if (inp == 4) {
        BuyItem(350, NIT_HOVER_BOOTS_UPGRADE); //sync price with buyitem
    }
    if (inp == 5) {
        BuyItem(1000, NIT_RL_LASER_SIGHT); //sync with RL
    }
    if (inp == 7) {
        if (no_clusters==1)
        {
            sprint(self,PRINT_HIGH,"Cluster rockets are disabled\n");
            self.impulse=0;
            return;
        }
        else
          BuyItem(3250, NIT_CLUSTER_ROCKETS); //sync with RL
    }
    if (inp == 8) {
        Menu_Proficiency();
        self.current_menu = MENU_PROFICIENCY;
    }
//		if (inp == 9) {
//			centerprint(self, "No next menu\n");
//		}
    if (inp == 10) {
        DropFromCustomClassGen();
    }

    self.impulse = 0;
};

// SB - crusader ability menu
void(entity pl, string s1, string s2, string s3) CenterPrint3;

/*
#define AURA_POWER		1
#define AURA_RESISTANCE	2
#define AURA_HASTE		3
#define AURA_INVIS		4
*/

void(float aur) AddAura;
void() CrusaderAddInvisibility;
void() CrusaderMassHeal;
void() CrusaderMassCure;
void() CrusaderDispel;

void() Menu_Crusader =
{
	local string	str1;
	local float		amount;
	
	amount = time - self.job_finished;
	if (amount > 60)
		amount = 60;
	
	str1 = ftos(floor(amount));

	if (self.weapons_carried & WEAP_MEDIKIT)
		CenterPrint3(self, " ¡„ÙÈÔÓ:                  \n\n.. Aura of Power         €15 mana›\n.. Aura of Resistance    €15 mana›\nï.. Aura of Haste         €15 mana›\nñ.. Aura of Invisibility  €45 mana›\nó.. Dispel Evil           €30 mana›\nò.. Mass healing          €20 mana›\nô.. Mass cure             €20 mana›\nö.. Sing                  € 0 mana›\n\nÕ·Ó· ÏÂÊÙ: ", str1,"\n\ní.. ŒÔÙËÈÓÁ                        ");
	else
		CenterPrint3(self, " ¡„ÙÈÔÓ:                  \n\n.. Aura of Power         €15 mana›\n.. Aura of Resistance    €15 mana›\nï.. Aura of Haste         €15 mana›\nñ.. Aura of Invisibility  €45 mana›\nó.. Dispel Evil           €30 mana›\nö.. Sing                  € 0 mana›\n\nÕ·Ó· ÏÂÊÙ: ", str1,"\n\ní.. ŒÔÙËÈÓÁ                        ");
	self.StatusRefreshTime = time + 1;
};

void(float inp) Menu_Crusader_Input =
{
	// If you read this, this is how you should be doing menus. HEAR ME?? No? Well I assume you
	// are reading it so that'll have to do.
	
	if (inp == 1)
		AddAura(AURA_POWER);
	else if (inp == 2)
		AddAura(AURA_RESISTANCE);
	else if (inp == 3)
		AddAura(AURA_HASTE);
	else if (inp == 4)
		CrusaderAddInvisibility();
	else if (inp == 5)
		CrusaderDispel();
	else if (inp == 6)
		CrusaderMassHeal();
	else if (inp == 7)
		CrusaderMassCure();
	else if (inp == 8)
		sound (self, CHAN_MUSIC, "ambience/orff.wav", 1, ATTN_NORM);
    else if (inp == 10)
		inp = 0;
	else
		return;

	self.impulse = 0;
	ResetMenu();
};
