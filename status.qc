
/*======================================================
	STATUS.QC			TeamFortress v2.5	

	(c) TeamFortress Software Pty Ltd 	13/5/97
	(c) Craig Hauser			26/3/00
========================================================
TF status bar functions
=======================================================*/

#include "defs.qh"

float(float tno) TeamFortress_TeamGetScore;

////////////////////////////////////////////////////
//  NumberToStringxxx functions
//  take an integer, return a constant string.
#ifdef STATUSBAR
void(entity pl, string s1) CenterPrint;
void(entity pl, string s1, string s2) CenterPrint2;
void(entity pl, string s1, string s2, string s3) CenterPrint3;
void(entity pl, string s1, string s2, string s3, string s4) CenterPrint4;
void(entity pl, string s1, string s2, string s3, string s4, string s5) CenterPrint5;
void(entity pl, string s1, string s2, string s3, string s4, string s5, string s6) CenterPrint6;
void(entity pl, string s1, string s2, string s3, string s4, string s5, string s6, string s7) CenterPrint7;

void(entity pl, float fTime, string s1) StatusPrint;

string(entity pl) GetStatusSize;

string(entity pl) ClipSizeToString100;
string(float num) NumberToString10;
string(entity te) SentryDetailsToString;
string(entity te) TeslaDetailsToString;

//used for print
string(float tno) GetTrueTeamName;
string(float pc) TeamFortress_GetClassName;
string(float pc) TeamFortress_GetJobName;

void(entity demon) custom_demon_name;

//- OfN -
float(entity thing) IsMonster;
float(entity player) HasMonster;

/////////////////////////////////////////////////////////////////
// CenterPrint replacement.  Takes into account the status bar //
/////////////////////////////////////////////////////////////////
void(entity pl, string s1) CenterPrint =
{
	centerprint(pl, s1);
	pl.StatusRefreshTime = time + 1;
};

void(entity pl, string s1, string s2) CenterPrint2 =
{
	centerprint(pl, s1, s2);
	pl.StatusRefreshTime = time + 1;
};

void(entity pl, string s1, string s2, string s3) CenterPrint3 =
{
	centerprint(pl, s1, s2, s3);
	pl.StatusRefreshTime = time + 1;
};

void(entity pl, string s1, string s2, string s3, string s4) CenterPrint4 =
{
	centerprint(pl, s1, s2, s3, s4);
	pl.StatusRefreshTime = time + 1;
};

void(entity pl, string s1, string s2, string s3, string s4, string s5) CenterPrint5 =
{
	centerprint(pl, s1, s2, s3, s4, s5);
	pl.StatusRefreshTime = time + 1;
};

void(entity pl, string s1, string s2, string s3, string s4, string s5, string s6) CenterPrint6 =
{
	centerprint(pl, s1, s2, s3, s4, s5, s6);
	pl.StatusRefreshTime = time + 1;
};

void(entity pl, string s1, string s2, string s3, string s4, string s5, string s6, string s7) CenterPrint7 =
{
	centerprint(pl, s1, s2, s3, s4, s5, s6, s7);
	pl.StatusRefreshTime = time + 1;
};

//////////////////////////////////////////////////////////////////
// StatusPrint - like centerprint, but works with the status bar
void(entity pl, float fTime, string s1) StatusPrint =
{
	centerprint(pl, s1);
	pl.StatusRefreshTime = time + fTime;
};

void(entity pl) RefreshStatusBar =
{
	local string s1, s2, s3, s4;
	local string s5, s6, s7;
	local float num;

	if (pl.StatusBarSize == 0)
	{
		pl.StatusRefreshTime = time + 60;
		return;
	}

	pl.StatusRefreshTime = time + 1.0;
	if (pl.playerclass == PC_UNDEFINED)
		return;

	s1 = GetStatusSize(pl);
	num = ceil(team1score);
	if (num >= 1000)
	{
		s2 = s3 = s4 = "9";
	}
	else
	{
//CH The below functions take a number and print out each character
		if (num >= 100)
			s2 = NumberToString10(floor(num/100));
		else
			s2 = " ";
		if (num >= 10)
			s3 = NumberToString10(floor((num - (floor(num/100)*100))/10));
		else
			s3 = " ";
		if (num > 0)
			s4 = NumberToString10(floor((num - (floor(num/10)*10))));
		else
			s4 = "0";
	}

    //s2 = "Âלץו: ";
    //s3 = (ftos(ceil(team1score)));
    //s4 = " Òוה: "
    //s5 = (ftos(ceil(team2score)));

	s5 = " :Âלץו   Òוה: ";
	s6 = (ftos(ceil(team2score)));
	
	s7 = ClipSizeToString100(pl);
	centerprint(pl, s1, s2, s3, s4, s5, s6,s7);

//CH determines which screen to show next (its at the end of all RefreshStatusBars)
	if (self.has_sentry)
		self.StatusBarScreen = 1;
	else if (self.has_tesla)
		self.StatusBarScreen = 4;
	else if (self.scaned != self)
		self.StatusBarScreen = 5;
	else if (self.is_undercover != 0)
		self.StatusBarScreen = 2;  // (self.job & JOB_WARLOCK && self.job & JOB_DEMON_OUT)
	else if (self.is_detpacking || HasMonster(self) || (self.is_haxxxoring && self.job & JOB_HACKER))
		self.StatusBarScreen = 3;
	else
		self.StatusBarScreen = 0;

};
//sentry bar :)
void(entity pl) RefreshStatusBar1 =
{
	local string s1, s2, s3, s4;
	local string s5, s6, s7;
	local entity sent;
	sent = world;

	if (pl.StatusBarSize == 0)
	{
		pl.StatusRefreshTime = time + 60;
		return;
	}

	pl.StatusRefreshTime = time + 1.0;
	if (pl.playerclass == PC_UNDEFINED)
		return;

	s1 = GetStatusSize(pl);

	do
		sent = find(sent, classname, "building_sentrygun");
	while (sent != world && sent.real_owner != self);

	if (sent)
	{
		s2 = SentryDetailsToString(sent);
		s3 = ftos(floor((sent.health / sent.max_health) * 100));
		s4 = "% health  ";

		if (sent.enemy != world)
		{
			s5 = "Attacking: ";
			s6 = sent.enemy.netname;
		}
		else
		{
			s5 = "Idle";
			s6 = " ";
		}

		if (self.is_building)
		{
			s7 = "\n  building...     \n";
		}
		else
		{
			s7 = ClipSizeToString100(pl);
		}

		centerprint(pl, s1, s2, s3, s4, s5, s6,s7);
	}

//CH determines which screen to show next (its at the end of all RefreshStatusBars)
	if (self.has_tesla)
		self.StatusBarScreen = 4;
	else if (self.scaned != self)
		self.StatusBarScreen = 5;
	else if (self.is_undercover != 0)
		self.StatusBarScreen = 2; //(self.job & JOB_WARLOCK && self.job & JOB_DEMON_OUT)
	else if (self.is_detpacking || HasMonster(self) || (self.is_haxxxoring && self.job & JOB_HACKER))
		self.StatusBarScreen = 3;
	else
		self.StatusBarScreen = 0;

};
//Tesla bar :)
void(entity pl) RefreshStatusBar4 =
{
	local string s1, s2, s3, s4;
	local string s5, s6, s7;
	local entity sent;
	sent = world;

	if (pl.StatusBarSize == 0)
	{
		pl.StatusRefreshTime = time + 60;
		return;
	}

	pl.StatusRefreshTime = time + 1.0;
	if (pl.playerclass == PC_UNDEFINED)
		return;

	s1 = GetStatusSize(pl);

	do
		sent = find(sent, classname, "building_tesla");
	while (sent != world && sent.real_owner != self);

	if (sent)
	{
		//- OfN - if (sent.enemy.classname == "monster_demon1" || sent.enemy.classname == "monster_army" || sent.enemy.classname == "monster_shambler" )
        if (IsMonster(sent.enemy))
			custom_demon_name(sent.enemy); //CH
		s2 = TeslaDetailsToString(sent);
		s3 = ftos(floor((sent.health / sent.max_health) * 100));
		s4 = "% health  ";
		if (sent.oldenemy != world)
		{
			s5 = "Attacking: ";
			s6 = sent.enemy.netname;
		}
		else
		{
			s5 = "Idle";
			s6 = " ";
		}

		if (self.is_building)
		{
			s7 = "\n  building...     \n";
		}
		else
		{
			s7 = ClipSizeToString100(pl);
		}

		centerprint(pl, s1, s2, s3, s4, s5, s6,s7);
	}

//CH determines which screen to show next (its at the end of all RefreshStatusBars)
	if (self.scaned != self)
		self.StatusBarScreen = 5;
	else if (self.is_undercover != 0)
		self.StatusBarScreen = 2; //(self.job & JOB_WARLOCK && self.job & JOB_DEMON_OUT)
	else if (self.is_detpacking || HasMonster(self) || (self.is_haxxxoring && self.job & JOB_HACKER))
		self.StatusBarScreen = 3;
	else
		self.StatusBarScreen = 0;

};
//Scanner Screen
void(entity pl) RefreshStatusBar5 =
{
	local string s1, s2, s3, s4;
	local string s5, s6, s7;

	if (pl.StatusBarSize == 0)
	{
		pl.StatusRefreshTime = time + 60;
		return;
	}

	pl.StatusRefreshTime = time + 1.0;
	if (pl.playerclass == PC_UNDEFINED)
		return;

	s1 = GetStatusSize(pl);
	s6 = ftos(ceil(vlen(self.scaned.origin - self.origin)));
	s7 = ClipSizeToString100(pl);
	if (self.scaned.classname == "player" && self.scaned.playerclass != PC_UNDEFINED)
	{
		s2 = GetTrueTeamName(self.scaned.team_no);
		s3 = ": ";
		if (self.enemy.playerclass != PC_CUSTOM)
			s4 = TeamFortress_GetClassName(self.scaned.playerclass);
		else 
			s4 = TeamFortress_GetJobName(self.scaned.job);
		s5 = "\nRange: ";
		centerprint(pl, s1, s2, s3, s4, s5, s6,s7);
	}
	else if ((self.scaned.classname == "building_sentrygun" || self.scaned.classname == "building_tesla" || self.scaned.classname == "building_teleporter" || self.scaned.classname == "monster_demon1") && self.scaned.health > 0)
	{
		//- OfN - if (self.scaned.classname == "monster_demon1" || self.scaned.classname == "monster_army" || self.scaned.classname == "monster_shambler")
        if (IsMonster(self.scaned))
		{
			custom_demon_name(self.scaned); //CH
			s2 = GetTrueTeamName(self.scaned.real_owner.team_no); //demons are special
		}
		else
			s2 = GetTrueTeamName(self.scaned.team_no);
		if (self.scaned.classname == "building_sentrygun")
			s3 = ": Sentry Gun (";
		else if (self.scaned.classname == "building_tesla")
			s3 = ": Tesla Sentry (";
		else if (self.scaned.classname == "building_teleporter")
			s3 = ": Teleporter Pad (";
		else if (self.scaned.classname == "monster_demon1")
			s3 = ": Demon (";
		else if (self.scaned.classname == "monster_army")
			s3 = ": Soldier (";
		else if (self.scaned.classname == "monster_shambler")
			s3 = ": Shambler (";
		else if (self.scaned.classname == "monster_wizard")
			s3 = ": Scrag (";
		
        else 
			s3 = "!!!ERROR!!!";
		s4 = self.scaned.real_owner.netname;
		s5 = ")\nRange: ";
		centerprint(pl, s1, s2, s3, s4, s5, s6, s7);
	}
	else if (self.scaned.classname == "item_tfgoal")
	{
		s2 = GetTrueTeamName(self.scaned.owned_by);
		s3 = ": Item(";
		s4 = self.scaned.netname;
		s5 = ")\nRange: ";
		centerprint(pl, s1, s2, s3, s4, s5, s6, s7);
	}
	else
		pl.StatusRefreshTime = time + 0.1;

	self.scaned = self; //Reset it.

//CH determines which screen to show next (its at the end of all RefreshStatusBars)
	if (self.is_undercover != 0)
		self.StatusBarScreen = 2; //(self.job & JOB_WARLOCK && self.job & JOB_DEMON_OUT)
	else if (self.is_detpacking || HasMonster(self) || (self.is_haxxxoring && self.job & JOB_HACKER))
		self.StatusBarScreen = 3;
	else
		self.StatusBarScreen = 0;
};

//Spy Screen
void(entity pl) RefreshStatusBar2 =
{
	local string s1, s2, s3, s4;
	local string s5;

	if (pl.StatusBarSize == 0)
	{
		pl.StatusRefreshTime = time + 60;
		return;
	}

	pl.StatusRefreshTime = time + 1.0;
	if (pl.playerclass == PC_UNDEFINED)
		return;

	s1 = GetStatusSize(pl);
	
	if (self.is_undercover == 2)
		s2 = "Disguising: ";
	else if (self.is_undercover == 1)
		s2 = "Óכימ: ";
	else
		s2 = "Uncovered ";
	if (invis_only)
	{
		s3 = "     Inviso     ";
		s4 = "\n";
	}
	else
	{
		if (self.undercover_team >= 1 && self.undercover_team <= 4)
			s3 = GetTrueTeamName(self.undercover_team);
		else
			s3 = "      ";
		if (self.undercover_skin == 1)
			s4 = " Scout   ";
		else if (self.undercover_skin == 2)
			s4 = " Sniper  ";
		else if (self.undercover_skin == 3)
			s4 = " Soldier ";
		else if (self.undercover_skin == 4)
			s4 = " Demoman ";
		else if (self.undercover_skin == 5)
			s4 = " Medic   ";
		else if (self.undercover_skin == 6)
			s4 = " Hvy Wpns";
		else if (self.undercover_skin == 7)
			s4 = " Pyro    ";
		else if (self.undercover_skin == 8)
			s4 = " Spy     ";
		else if (self.undercover_skin == 9)
			s4 = " Engineer";
		else
			s4 = "         ";
	}
	s5 = ClipSizeToString100(pl);
	centerprint(pl, s1, s2, s3, s4, s5);

//CH determines which screen to show next (its at the end of all RefreshStatusBars)
                            //(self.job & JOB_WARLOCK && self.job & JOB_DEMON_OUT)||(self.job & JOB_ARMY && self.job & JOB_DEMON_OUT)
	if (self.is_detpacking || HasMonster(self) || (self.is_haxxxoring && self.job & JOB_HACKER))
		self.StatusBarScreen = 3;
	else
		self.StatusBarScreen = 0;

};
//Misc Screen
void(entity pl) RefreshStatusBar3 =
{
	local string s1, s2, s3, s4;
	local string s5, s6;
	local float num;

	if (pl.StatusBarSize == 0)
	{
		pl.StatusRefreshTime = time + 60;
		return;
	}

	pl.StatusRefreshTime = time + 1.0;
	if (pl.playerclass == PC_UNDEFINED)
		return;

    s4 = "";
    s5 = "";

    s1 = GetStatusSize(pl);

       //(self.job & JOB_WARLOCK && self.job & JOB_DEMON_OUT)||(self.job & JOB_ARMY && self.job & JOB_DEMON_OUT)
	if (self.is_haxxxoring && self.job & JOB_HACKER)
    {
    	if (self.demon_two.has_camera == -2) // we r aborting hack...
        {
            s2 = "\nÈבדכ: Aborting...";
            s3 = "";
            s4 = "";
        }
        else
        {
            s2 = "\nÈבדכ: ";
            s3 = ftos(100 - floor((self.demon_two.heat/self.demon_two.ltime) * 100));
            s4 = "% completed";
        }
    }    
    else if (HasMonster(pl))
	{
        num = self.demon_one.health; //- OfN -
        
		if (self.demon_one.classname == "monster_army")
			s2 = "\nÓןלהיוע: ";
		else if (self.demon_one.classname == "monster_shambler")
			s2 = "\nÓטבםגלוע: ";
        else if (self.demon_one.classname == "monster_wizard")
        	s2 = "\nÓדעבח: ";
        else if (self.demon_one.classname == "monster_demon1")
        	s2 = "\nÆיומה: ";
        else if (self.demon_one.classname == "monster_knight")
        	s2 = "\nËמיחטפ: ";
        else if (self.demon_one.classname == "monster_hknight")
        	s2 = "\nHell Knight: ";

        s3 = ftos(floor((self.demon_one.health / self.demon_one.max_health) * 100));
        s4 = "% health";
	}
	else
	{
		s2 = "";
		s3 = "";
	}
	
    if (self.is_detpacking)
	{
        //s4 = "\n\n "; //- OfN \n\n
        s5 = "\n Setting Detpack... ";
    }
	
    //else
		
	s6 = ClipSizeToString100(pl);
	centerprint(pl, s1, s2, s3, s4, s5, s6);

//CH determines which screen to show next (its at the end of all RefreshStatusBars)
		self.StatusBarScreen = 0;
};

//////////////////////////////////////////////////////////////////
// Status Bar Resolution Settings 
// Thanks goes to Dave 'Zoid' Kirsch (zoid@threewave.com) from CTF
// for the res settings.
string(entity pl) GetStatusSize =
{
	if (pl.StatusBarSize == 1)
	{
		if (pl.StatusBarRes > 7) // 768 
			return "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
		else if (pl.StatusBarRes == 7) // 600 
			return "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
		else if (pl.StatusBarRes == 6) // 480 
			return "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
		else if (pl.StatusBarRes == 5) // 400
			return "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
		else if (pl.StatusBarRes == 4) // 384 
			return "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
		else if (pl.StatusBarRes == 3) // 350 
			return "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
		else if (pl.StatusBarRes == 2) // 300 
			return "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
		else if (pl.StatusBarRes == 1) // 240 
			return "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
		// 200 
		return "\n\n\n\n\n\n\n\n\n\n";
	}
	else // if (pl.StatusBarSize == 2)
	{
		if (pl.StatusBarRes > 7) // 768 
			return "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
		else if (pl.StatusBarRes == 7) // 600 
			return "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
		else if (pl.StatusBarRes == 6) // 480 
			return "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
		else if (pl.StatusBarRes == 5) // 400
			return "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
		else if (pl.StatusBarRes == 4) // 384 
			return "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
		else if (pl.StatusBarRes == 3) // 350 
			return "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
		else if (pl.StatusBarRes == 2) // 300 
			return "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
		else if (pl.StatusBarRes == 1) // 240 
			return "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
		// 200 
		return "\n\n\n\n\n\n\n\n\n\n\n\n\n";
	}
};

void(float res) StatusRes =
{
	self.StatusBarRes = res;

	if (res > 7) // 768 
		sprint(self, PRINT_HIGH, "Status Bar Res set to 1024x768.\n");
	else if (res == 7) // 600 
		sprint(self, PRINT_HIGH, "Status Bar Res set to 800x600.\n");
	else if (res == 6) // 480 
		sprint(self, PRINT_HIGH, "Status Bar Res set to 640x480.\n");
	else if (res == 5) // 400
		sprint(self, PRINT_HIGH, "Status Bar Res set to 640x400.\n");
	else if (res == 4) // 384 
		sprint(self, PRINT_HIGH, "Status Bar Res set to 512x384.\n");
	else if (res == 3) // 350 
		sprint(self, PRINT_HIGH, "Status Bar Res set to 320x350.\n");
	else if (res == 2) // 300 
		sprint(self, PRINT_HIGH, "Status Bar Res set to 400x300.\n");
	else if (res == 1) // 240 
		sprint(self, PRINT_HIGH, "Status Bar Res set to 320x240.\n");
	else
		sprint(self, PRINT_HIGH, "Status Bar Res set to 320x200.\n");
};

string(entity pl) ClipSizeToString100 =
//CH edited b/c nothing has over 20
{
	local float num;

	if (pl.current_weapon == WEAP_SHOTGUN)
	{
		if (RE_SHOTGUN - pl.reload_shotgun > pl.ammo_shells)
			pl.reload_shotgun = RE_SHOTGUN - pl.ammo_shells;
		num = RE_SHOTGUN - pl.reload_shotgun;
	}
	else if (pl.current_weapon == WEAP_SUPER_SHOTGUN)
	{
		if (RE_SUPER_SHOTGUN - pl.reload_super_shotgun > pl.ammo_shells)
			pl.reload_super_shotgun = RE_SUPER_SHOTGUN - pl.ammo_shells;
		num = RE_SUPER_SHOTGUN - pl.reload_super_shotgun;
	}
	else if (pl.current_weapon == WEAP_GRENADE_LAUNCHER)
	{
		if (RE_GRENADE_LAUNCHER - pl.reload_grenade_launcher > pl.ammo_rockets)
			pl.reload_grenade_launcher = RE_GRENADE_LAUNCHER - pl.ammo_rockets;
		num = RE_GRENADE_LAUNCHER - pl.reload_grenade_launcher;
	}
	else if (pl.current_weapon == WEAP_ROCKET_LAUNCHER)
	{
		if (RE_ROCKET_LAUNCHER - pl.reload_rocket_launcher > pl.ammo_rockets)
			pl.reload_rocket_launcher = RE_ROCKET_LAUNCHER - pl.ammo_rockets;
		num = RE_ROCKET_LAUNCHER - pl.reload_rocket_launcher;
	}
	else if (pl.current_weapon == WEAP_LIGHT_ASSAULT)
	{
		if (RE_LIGHT_ASSAULT - pl.reload_light_assault > pl.ammo_nails)
			pl.reload_light_assault = RE_LIGHT_ASSAULT - pl.ammo_nails;
		num = RE_LIGHT_ASSAULT - pl.reload_light_assault;
	}
    else if (pl.current_weapon == WEAP_LASERCANNON)
	{
		if (RE_LASER_CANNON - pl.reload_laser_cannon > pl.ammo_cells)
			pl.reload_laser_cannon = RE_LASER_CANNON - pl.ammo_cells;
		num = RE_LASER_CANNON - pl.reload_laser_cannon;
	}
	else
	{
		return "\n       ";
	}             

	if (num < 10)
	{
		if (num < 5)
		{
			if (num == 0)
				return "\nדלינ: 0";
			else if (num == 1)
				return "\nדלינ: 1";
			else if (num == 2)
				return "\nדלינ: 2";
			else if (num == 3)
				return "\nדלינ: 3";
			else
				return "\nדלינ: 4";
		}
		else
		{
			if (num == 5)
				return "\nדלינ: 5";
			else if (num == 6)
				return "\nדלינ: 6";
			else if (num == 7)
				return "\nדלינ: 7";
			else if (num == 8)
				return "\nדלינ: 8";
			else if (num == 9)
				return "\nדלינ: 9";
		}
	}
	else if (num < 20)
	{
		if (num < 15)
		{
			if (num == 10)
				return "\nדלינ:10";
			else if (num == 11)
				return "\nדלינ:11";
			else if (num == 12)
				return "\nדלינ:12";
			else if (num == 13)
				return "\nדלינ:13";
			else
				return "\nדלינ:14";
		}
		else
		{
			if (num == 15)
				return "\nדלינ:15";
			else if (num == 16)
				return "\nדלינ:16";
			else if (num == 17)
				return "\nדלינ:17";
			else if (num == 18)
				return "\nדלינ:18";
			else if (num == 19)
				return "\nדלינ:19";
		}
	}
	else if (num < 30)
	{
		if (num < 25)
		{
			if (num == 20)
				return "\nדלינ:20";
			else if (num == 21)
				return "\nדלינ:21";
			else if (num == 22)
				return "\nדלינ:22";
			else if (num == 23)
				return "\nדלינ:23";
			else if (num == 24)
				return "\nדלינ:24";
		}
		else
		{
			if (num == 25)
				return "\nדלינ:25";
			if (num == 26)
				return "\nדלינ:26";
			if (num == 27)
				return "\nדלינ:27";
			if (num == 28)
				return "\nדלינ:28";
			if (num == 29)
				return "\nדלינ:29";
		}
	}
	else if (num < 40)
	{
		if (num < 35)
		{
			if (num == 30)
				return "\nדלינ:30";
			else if (num == 31)
				return "\nדלינ:31";
			else if (num == 32)
				return "\nדלינ:32";
			else if (num == 33)
				return "\nדלינ:33";
			else if (num == 34)
				return "\nדלינ:34";
		}
		else
		{
			if (num == 35)
				return "\nדלינ:35";
			if (num == 36)
				return "\nדלינ:36";
			if (num == 37)
				return "\nדלינ:37";
			if (num == 38)
				return "\nדלינ:38";
			if (num == 39)
				return "\nדלינ:39";
		}
	}
	else if (num >= 40)
		return "\nדלינ:40";
	return ftos (num);
};
//==========
string(entity te) SentryDetailsToString =
{
	if (te.ammo_shells == 0)
	{
		if (te.ammo_rockets == 0 && te.weapon == 3)
			return "Óומפעש: no ammo   \nÓומפעש: ";
		else	   
			return "Óומפעש: no shells \nÓומפעש: ";
	}
	else if (te.ammo_rockets == 0 && te.weapon == 3)
	{
		return "Óומפעש: no rockets\nÓומפעש: ";
	}		   
	else
	{		   
		return "                  \nÓומפעש: ";
	}

	return "                           \n"; // should never happen
};
//==========
string(entity te) TeslaDetailsToString =
{
	if (te.ammo_cells == 0)
	{
		return "Ôוףלב:     No cells\nÔוףלב: ";
	}
	else if (te.ammo_cells <= 30)
	{
		return "Ôוףלב: Low on cells\nÔוףלב: ";
	}
	else
	{		   
		return "                   \nÔוףלב: ";
	}
	return "                           \n"; // should never happen
};
string(float num) NumberToString10 =
{
	if (num == 0)
		return "0";
	else if (num == 1)
		return "1";
	else if (num == 2)
		return "2";
	else if (num == 3)
		return "3";
	else if (num == 4)
		return "4";
	else if (num == 5)
		return "5";
	else if (num == 6)
		return "6";
	else if (num == 7)
		return "7";
	else if (num == 8)
		return "8";
	else if (num == 9)
		return "9";
	else
		return "A"; //CH just in case
};

#endif
