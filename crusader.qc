/*=======================================================//
// crusader.QC - CustomTF 3.2.OfN          - 30/1/2001 - //
// by Sergio Fumaña Grunwaldt - OfteN aka superCOCK2000  //
=========================================================//
 This is all the crusader stuff created by SB-1 tech
=========================================================*/

void() JobCrusader =
{
	self.current_menu = #MENU_CRUSADER;
	self.menu_count = #MENU_REFRESH_RATE;
	self.StatusRefreshTime = time + 1;
};

float(vector veca, vector vecb) crossproduct;

entity (entity crusader) Crusader_FindIdiot =
{
	local entity guy;
	local entity matched;
	local vector store;
	local float matchlevel, oldmatch;
	
	matchlevel = 0;
	matched = crusader;
	oldmatch = 0;
	
	guy = findradius(crusader.origin, 250);
	while (guy)
	{
		if (guy.classname == "player")
		{
			store = normalize(guy.origin - crusader.origin);
			matchlevel = crusader.v_angle * store;
			if (matchlevel > oldmatch)
			{
				matched = guy;
				oldmatch = matchlevel;
			}
		}
		guy = guy.chain;
	}
	
	if (oldmatch > 0.2)
		return matched;
	else
		return crusader;
};

void(float aur) AddAura =
{
	local float amount;
	local entity targ;
	
	amount = time - self.job_finished;
	if (amount > 60)
		amount = 60;
	
	if (amount < 15)
	{
		sprint(self, #PRINT_HIGH, "You don't have enough mana to bestow an aura\n");
		return;
	}
/*	makevectors(self.v_angle);
	traceline(self.origin, self.origin + (v_forward * 200), #FALSE, self);
	*/
	
	targ = Crusader_FindIdiot(self);
	
	if (self == targ)
	{
		sprint(self, #PRINT_HIGH, "There is nobody there to bestow an aura upon\n");
		return;
	}
	
	if (targ.aura == aur)
	{
		sprint(self, #PRINT_HIGH, targ.netname, " already has that aura.\n");
		return;
	}
	
	if (!(targ.job & #JOB_CRUSADER))
	{
//		sound (targ, #CHAN_ITEM, "auras/aura3.wav", 1, #ATTN_NORM);
        
        local string strung;
		local float oldaur;
		local string oldstrung;
		
		oldaur = targ.aura;
		targ.aura = aur;
		targ.crusader_inspirator = self;
		amount = amount - 15;
		self.job_finished = time - amount;
		
		if (targ.aura == #AURA_POWER)
			strung = "Aura of Power.\n";
		else if (targ.aura == #AURA_RESISTANCE)
			strung = "Aura of Resistance.\n";
		else if (targ.aura == #AURA_HASTE)
			strung = "Aura of Haste.\n";
		if (oldaur == #AURA_POWER)
			oldstrung = "Aura of Power";
		else if (oldaur == #AURA_RESISTANCE)
			oldstrung = "Aura of Resistance";
		else if (oldaur == #AURA_HASTE)
			oldstrung = "Aura of Haste";
		
		if (oldaur == 0)
			sprint(self, #PRINT_HIGH, "You provide ", targ.netname, " with an ", strung);
		else
			sprint(self, #PRINT_HIGH, "You replace ", targ.netname, "'s ", oldstrung, " with an ", strung);
		sprint(targ, #PRINT_HIGH, self.netname, " bestows upon you an ", strung);
	}
	else //if (targ.job & #JOB_CRUSADER)
		sprint(self, #PRINT_HIGH, targ.netname, " is a Crusader and their Aura of Righteousness may not be replaced.\n");
	//else
	//	sprint(self, #PRINT_HIGH, "You may only bestow an aura upon a player\n");
};

void() CrusaderAddInvisibility =
{
	local float amount;
	local entity targ;
	
	amount = time - self.job_finished;
	if (amount > 60)
		amount = 60;
	
	if (amount < 45)
	{
		sprint(self, #PRINT_HIGH, "You don't have enough mana to grant invisibility\n");
		return;
	}
	
	targ = Crusader_FindIdiot(self);
	
	if (self == targ)
	{
		sprint(self, #PRINT_HIGH, "There is nobody there to bestow an aura upon\n");
		return;
	}
	
	if (!(targ.job & #JOB_CRUSADER))
	{
//    	sound (targ, #CHAN_ITEM, "auras/aura3.wav", 1, #ATTN_NORM);
        
        sprint(self, #PRINT_HIGH, "You provide ", targ.netname, " with powers of invisibility! They will be invisible for the next 10 seconds!\n");
		sprint(targ, #PRINT_HIGH, self.netname, " grants you an Aura of Invisibility! You will be fully invisibile for the next 10 seconds!\n");
		targ.aura = #AURA_INVIS;
		targ.aura_time = time + 10;
		amount = amount - 45;
		self.job_finished = time - amount;
		targ.items = targ.items | #IT_INVISIBILITY;
	}
	else
		sprint(self, #PRINT_HIGH, "You cannot bestow invisibility upon another Crusader\n");
};

void() CrusaderMassHeal =
{
	local entity te;
	local float amount;
	
	if (!(self.weapons_carried & #WEAP_MEDIKIT))
	{
		sprint(self, #PRINT_HIGH, "You cannot perform mass heal without a medikit\n");
		return;
	}

	amount = time - self.job_finished;
	if (amount > 60)
		amount = 60;
	
	if (amount < 20)
	{
		sprint(self, #PRINT_HIGH, "You don't have enough mana to perform a mass heal\n");
		return;
	}
	
	te = findradius(self.origin, 600);
	while (te)
	{
		if (te.classname == "player")
			if (Teammate(te.team_no, self.team_no))
				if (te.health < te.max_health)
				{
//        	    	sound (te, #CHAN_ITEM, "auras/aura3.wav", 1, #ATTN_NORM);

                    te.health = te.max_health;
					if (self != te)
						sprint(te, #PRINT_HIGH, self.netname, " restores you to full health\n");
					else
						sprint(te, #PRINT_HIGH, "Your deity restores you to full health\n");
				}
		
		te = te.chain;
	}
	amount = amount - 20;
	self.job_finished = time - amount;
	sound(self, #CHAN_MUSIC, "items/r_item2.wav", 1, #ATTN_NORM);
};

float(entity doc, entity patient, vector org) CureAdverseEffects;

void() CrusaderMassCure =
{
	local entity te;
	local float amount;
	
	if (!(self.weapons_carried & #WEAP_MEDIKIT))
	{
		sprint(self, #PRINT_HIGH, "You cannot perform mass cure without a medikit\n");
		return;
	}
	
	amount = time - self.job_finished;
	if (amount > 60)
		amount = 60;
	
	if (amount < 20)
	{
		sprint(self, #PRINT_HIGH, "You don't have enough mana to perform a mass cure\n");
		return;
	}
	
	te = findradius(self.origin, 600);
	while (te)
	{
		if (te.classname == "player")
			if (Teammate(te.team_no, self.team_no))
				CureAdverseEffects(self, te, te.origin);
		
		te = te.chain;
	}
	amount = amount - 20;
	self.job_finished = time - amount;
	sound(self, #CHAN_MUSIC, "items/health1.wav", 1, #ATTN_NORM);
	
};

void() CrusaderDispel =
{
	local entity te;
	local float amount;
	
	amount = time - self.job_finished;
	if (amount > 60)
		amount = 60;
	
	if (amount < 30)
	{
		sprint(self, #PRINT_HIGH, "You don't have enough mana to dispel evil\n");
		return;
	}
	
	te = findradius(self.origin, 1000);
	while (te)
	{
		if (!Teammate(self.team_no, te.team_no))
			/*if (te.classname == "monster_demon1")
				TF_T_Damage(te, self, self, 500, 0, #TF_TD_OTHER);
			else if (te.classname == "monster_shambler")
				TF_T_Damage(te, self, self, 830, 0, #TF_TD_OTHER);
			else if (coop)
			{
				if (te.classname == "monster_zombie")
					TF_T_Damage(te, self, self, 200, 0, #TF_TD_OTHER);
				else if (te.classname == "monster_wizard")
					TF_T_Damage(te, self, self, 200, 0, #TF_TD_OTHER);
				else if (te.classname == "monster_shalrath")
					TF_T_Damage(te, self, self, 250, 0, #TF_TD_OTHER);
			}*/
            if (IsMonsterNonArmy(te))
            	TF_T_Damage(te, self, self, 500, 0, #TF_TD_OTHER);
			else if (te.classname == "player")
				if (te.job & #JOB_WARLOCK)
				{
					local entity oself;
					
					te.attack_finished = time + 5;
					te.job_finished = time + 25;
					sprint(te, #PRINT_HIGH, self.netname, " dispels you!\n");
					oself = self;
					if (te.current_menu == #MENU_DEMON)
						ResetMenu();
					self = te;
					self = oself;
            
//                    sound (te, #CHAN_ITEM, "auras/aura3.wav", 1, #ATTN_NORM);

                    deathmsg = #DMSG_DISPEL;
					TF_T_Damage(te, self, self, 25, 0, #TF_TD_OTHER);
				}
		
		te = te.chain;
	}
	
	amount = amount - 30;
	self.job_finished = time - amount;
	sound(self, #CHAN_MUSIC, "misc/power.wav", 1, #ATTN_NORM);
};
