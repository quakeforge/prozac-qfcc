#include "defs.qh"
/*======================================================
	ACTIONS.QC			Custom TeamFortress v3.2	

	(c) TeamFortress Software Pty Ltd 	13/5/97
	(c) William Kerney			2/9/00
	(c) Craig Hauser				19/3/00
========================================================
Non Class-Specific Impulse Commands
=======================================================*/
// Prototypes
void() TeamFortress_Discard;
void() TeamFortress_SaveMe;
void(float inAuto) TeamFortress_ID;
void() TeamFortress_ReloadCurrentWeapon;

//CH dropitems
void() TeamFortress_DropItems;
void(entity Item, entity AP, float method) tfgoalitem_RemoveFromPlayer;

//=========================================================================
// Discard Command. Drops all ammo useless to the player's class.
void() TeamFortress_Discard =
{ 
	// Create a backpack
	newmis = spawn();
//CH to save space. Dont do class specific checks
//
//CH new setup, checks if you have weapon that uses that ammo
//and if you dont, throws it away
	 if (self.playerclass != PC_UNDEFINED)
	{
		if (!(self.weapons_carried & WEAP_SNIPER_RIFLE || self.weapons_carried & WEAP_AUTO_RIFLE || self.weapons_carried & WEAP_SHOTGUN || self.weapons_carried & WEAP_SUPER_SHOTGUN || self.weapons_carried & WEAP_ASSAULT_CANNON || (self.cutf_items & CUTF_SENTRYGUN && self.weapons_carried & WEAP_SPANNER)))
			newmis.ammo_shells = self.ammo_shells;
		if (!(self.weapons_carried & WEAP_NAILGUN || self.weapons_carried & WEAP_SNG || self.weapons_carried & WEAP_LIGHT_ASSAULT || self.weapons_carried & WEAP_LASER || self.weapons_carried & WEAP_TRANQ || self.weapons_carried & WEAP_MAUSER)) //CH is it just me or are there not many nail weapons? //WK It's just you
			newmis.ammo_nails = self.ammo_nails;
		if (!(self.weapons_carried & WEAP_ROCKET_LAUNCHER || self.weapons_carried & WEAP_INCENDIARY || self.weapons_carried & WEAP_GRENADE_LAUNCHER || (self.cutf_items & CUTF_SENTRYGUN && self.weapons_carried & WEAP_SPANNER) || self.job & JOB_GUERILLA))
			newmis.ammo_rockets = self.ammo_rockets;
		if (!(self.cutf_items & CUTF_CYBERAUG || self.cutf_items & CUTF_HOLO || self.weapons_carried & WEAP_LASERCANNON || self.weapons_carried & WEAP_INCENDIARY || self.weapons_carried & WEAP_LIGHTNING || self.weapons_carried & WEAP_SUPER_SHOTGUN || self.weapons_carried & WEAP_ASSAULT_CANNON || self.weapons_carried & WEAP_DAEDALUS || (self.cutf_items & CUTF_SENTRYGUN && self.weapons_carried & WEAP_SPANNER) || (self.weapons_carried & WEAP_SPANNER && self.tf_items & NIT_TESLA) || (self.weapons_carried & WEAP_SPANNER && self.tf_items & NIT_SECURITY_CAMERA) || (self.weapons_carried & WEAP_SPANNER && self.tf_items & NIT_TELEPORTER)))
			newmis.ammo_cells = self.ammo_cells;
	}

	// If there's nothing in the backpack, remove it and return
	if (!(newmis.ammo_shells + newmis.ammo_nails + newmis.ammo_rockets + newmis.ammo_cells))
	{
		dremove(newmis);
		return;
	}

	// Remove the ammo from the player
	if (newmis.ammo_shells)
		self.ammo_shells = 0;
	if (newmis.ammo_nails)
		self.ammo_nails = 0;
	if (newmis.ammo_rockets)
		self.ammo_rockets = 0;
	if (newmis.ammo_cells)
		self.ammo_cells = 0;
	W_SetCurrentAmmo();

	sound(self, CHAN_ITEM, "weapons/lock4.wav", 1, ATTN_NORM);

	// The backpack is treated as an ammobox, so people can't crash svrs
	// by making too many of them.
	if (self.team_no != 0)
	{
		increment_team_ammoboxes(self.team_no);
		if (num_team_ammoboxes(self.team_no) > (MAX_WORLD_AMMOBOXES / number_of_teams))
			RemoveOldAmmobox(self.team_no);
	}
	else 
	{
		num_world_ammoboxes = num_world_ammoboxes + 1;
		if (num_world_ammoboxes > MAX_WORLD_AMMOBOXES)
			RemoveOldAmmobox(0);
	}

	// Throw the backpack
	newmis.enemy = self;
	newmis.health = time;
	newmis.weapon = 0;
	newmis.movetype = MOVETYPE_TOSS;
	newmis.solid = SOLID_TRIGGER;
	newmis.classname = "ammobox";
	newmis.team_no = self.team_no;
	makevectors (self.v_angle);
	if (self.v_angle_x)
	{
		newmis.velocity = v_forward*400 + v_up * 200;
	}
	else
	{
		newmis.velocity = aim(self, 10000);
		newmis.velocity = newmis.velocity * 400;
		newmis.velocity_z = 200;
	}
	newmis.avelocity = '0 300 0';
	setsize (newmis, '0 0 0', '0 0 0');		
	setorigin (newmis, self.origin);
	newmis.nextthink = time + 30;	// remove after 30 seconds
	newmis.think = SUB_Remove;
	newmis.touch = TeamFortress_AmmoboxTouch;
	setmodel (newmis, "progs/backpack.mdl");
};

//=========================================================================
// Shows any medics/engineers on your team that you need help.
// Spies see all requests.
void() TeamFortress_SaveMe =
{
	local entity te, tl;

	if (self.last_saveme_sound < time)
	{
		if (random() < 0.8)
			sound(self, CHAN_WEAPON, "speech/saveme1.wav", 1, ATTN_NORM);	// MEDIC!
		else
			sound(self, CHAN_WEAPON, "speech/saveme2.wav", 1, ATTN_NORM);	// Excuse me...
		self.last_saveme_sound = time + 4;
	}

	te = find(NIL, classname, "player");
	while (te)
	{	
		if (self.weapons_carried & WEAP_MEDIKIT)

		if (self == te || te.weapons_carried & WEAP_MEDIKIT || te.weapons_carried & WEAP_SPANNER || te.cutf_items & CUTF_SPY_KIT) //WK Custom class friendly
		{
			if (Teammate(self.team_no, te.team_no) || (te.cutf_items & CUTF_SPY_KIT))
			{
				// If the other teammate is visible, show them I need help
				if (visible(te))
				{
					msg_entity = te;
					tl = spawn();
					tl.origin = self.origin;
					tl.origin_z = tl.origin_z + 32;
					WriteByte (MSG_ONE, SVC_TEMPENTITY);
					WriteByte (MSG_ONE, TE_LIGHTNING3);
					WriteEntity (MSG_ONE, tl);
					WriteCoord (MSG_ONE, tl.origin_x);
					WriteCoord (MSG_ONE, tl.origin_y);
					WriteCoord (MSG_ONE, tl.origin_z + 24);
					WriteCoord (MSG_ONE, self.origin_x);
					WriteCoord (MSG_ONE, self.origin_y);
					WriteCoord (MSG_ONE, self.origin_z);
					dremove(tl);
				}
			}
		}

		te = find(te, classname, "player");
	}
};

//=========================================================================
// ID's the player in your sights, and if you're a medic or engineer,
// reports their health and armor.
void(float inAuto) TeamFortress_ID =
{
	// OfN Returns if any menu is being displayed
    //if (self.current_menu != MENU_DEFAULT) 
    //    return; DON'T WORK
    
    //WK All the inAuto and spacer stuff I added
	local vector src;
	local string st, cls;
	local string spacer;
	src = self.origin + v_forward*10;
	src_z = self.absmin_z + self.size_z * 0.7;
	if (!inAuto) //WK I.e. just someone is doing it normally
		traceline (src, src + v_forward*2048, FALSE, self);
	else		//WK I.e. it is an autoscan
		traceline (src, src + v_forward*1024, FALSE, self);

	if (inAuto)
	{
        if (trace_ent.classname == "player" && trace_ent.job & (JOB_THIEF + JOB_ACTIVE))
			return;

        //- ofn - auto id doesnt pertubate menus
        //if (self.current_menu != MENU_DEFAULT)
         //   return; DOESNT WORK?
    }

	//if (!inAuto)
		//spacer = "\n\n\n\n\n";
		spacer = "\n";
	//else
	//	spacer = "\n\n\n\n\n\n\n";

	if (trace_ent && trace_ent.origin != world.origin )
	{
		if (trace_ent.classname == "player" && trace_ent.health > 0)
		{
			self.StatusRefreshTime = time + 1.5;

			if (Teammate(trace_ent.team_no,self.team_no))
			{
				if (trace_ent.playerclass == PC_CUSTOM)
					cls = TeamFortress_GetJobName(trace_ent.job);
				else
					cls = TeamFortress_GetClassName(trace_ent.playerclass);

				if (self.weapons_carried & WEAP_MEDIKIT) //WK
				{
					st = ftos(trace_ent.health);
					centerprint(self, spacer, trace_ent.netname, "\n\nFriendly ", cls, "\n\n", st, " health\n");
//centerprint(self, "\n\n\n\n", trace_ent.netname, "\nFriendly ", cls, "\n", st, //" health\n");
					return;
				}
				else if (self.weapons_carried & WEAP_SPANNER) //WK
				{
					st = ftos(trace_ent.armorvalue);
					centerprint(self, spacer, trace_ent.netname, "\n\nFriendly ", cls, "\n\n", st, " armor\n");
					return;
				}
				else
					centerprint(self, spacer, trace_ent.netname, "\n\nFriendly ", cls,"\n");
				return;
			}

			if (trace_ent.is_feigning) //WK Can't id enemy spies feigning
				return;

			if (trace_ent.cutf_items & CUTF_SPY_KIT)
			{
				cls = TeamFortress_GetClassName(trace_ent.undercover_skin);
				// Report a false name
				if (self.team_no != 0 && (self.team_no == trace_ent.undercover_team))
				{
					if (self.weapons_carried & WEAP_MEDIKIT)
					{
						st = ftos(trace_ent.health);
						if (trace_ent.undercover_skin != 0)
							centerprint(self, spacer, trace_ent.undercover_name, "\n\nFriendly ", cls, "\n\n", st, " health\n");
						else
							centerprint(self, spacer, trace_ent.undercover_name, "\n\nFriendly Spy\n\n", st, " health\n");
						return;
					}
					else if (self.weapons_carried & WEAP_SPANNER)
					{
						st = ftos(trace_ent.armorvalue);
						if (trace_ent.undercover_skin != 0)
							centerprint(self, spacer, trace_ent.undercover_name, "\n\nFriendly ", cls, "\n\n", st, " armor\n");
						else
							centerprint(self, spacer, trace_ent.undercover_name, "\n\nFriendly Spy\n\n", st, " armor\n");
						return;
					}
					else
					{
						st = ftos(trace_ent.armorvalue);
						if (trace_ent.undercover_skin != 0)
							centerprint(self, spacer, trace_ent.undercover_name, "\n\nFriendly ", cls, "\n");
						else
							centerprint(self, spacer, trace_ent.undercover_name, "\n\nFriendly Spy\n");
						return;
					}
				}

				if (trace_ent.undercover_name)
				{
					if (trace_ent.undercover_skin != 0)
						centerprint(self, spacer, trace_ent.undercover_name, "\n\nΕξενω ", cls, "\n");
					else
						centerprint(self, spacer, trace_ent.undercover_name, "\n\nΕξενω Spy");
				}
				else
				{
					if (trace_ent.undercover_skin != 0)
						centerprint(self, spacer, trace_ent.netname, "\n\nΕξενω ", cls, "\n");
					else
						centerprint(self, spacer, trace_ent.netname, "\n\nΕξενω Spy");
				}
			}
			else 
			{
				if (trace_ent.playerclass == PC_CUSTOM) {
					cls = TeamFortress_GetJobName(trace_ent.job);
					centerprint(self, spacer, trace_ent.netname, "\n\nΕξενω ", cls, "\n");
				}
				else {
					cls = TeamFortress_GetClassName(trace_ent.playerclass);
					centerprint(self, spacer, trace_ent.netname, "\n\nΕξενω ", cls, "\n");
				}
			}
		}
		else if (trace_ent.classname == "building_dispenser")
		{
			self.StatusRefreshTime = time + 1.5;
			
			if (self == trace_ent.real_owner)
				centerprint(self, spacer,"Your Dispenser\n");
			else if (!teamplay)
				centerprint(self, spacer,"Dispenser made by\n\n", trace_ent.real_owner.netname);
			else if (Teammate(trace_ent.team_no,self.team_no))
				centerprint(self, spacer,"Friendly Dispenser made by\n\n", trace_ent.real_owner.netname, "\n");
			else 
				centerprint(self, spacer,"Εξενω Dispenser made by\n\n", trace_ent.real_owner.netname, "\n");
	
		}
   		else if (trace_ent.classname == "building_fieldgen")
		{
			self.StatusRefreshTime = time + 1.5;
			
			if (self == trace_ent.real_owner)
				centerprint(self, spacer,"Your Field Generator.\n");
			else if (!teamplay)
				centerprint(self, spacer,"Field Generator made by\n\n", trace_ent.real_owner.netname);
			else if (Teammate(trace_ent.team_no,self.team_no))
				centerprint(self, spacer,"Friendly Field Generator made by\n\n", trace_ent.real_owner.netname, "\n");
			else 
				centerprint(self, spacer,"Εξενω Field Generator made by\n\n", trace_ent.real_owner.netname, "\n");
	

		}

		else if (trace_ent.classname == "building_sentrygun" || trace_ent.classname == "building_sentrygun_base")
		{
			self.StatusRefreshTime = time + 1.5;
			if (self == trace_ent.real_owner)
				centerprint(self, spacer,"Your SentryGun\n");
			else if (!teamplay)
				centerprint(self, spacer,"Sentrygun made by\n\n", trace_ent.real_owner.netname,"\n");
			else if (Teammate(trace_ent.team_no, self.team_no))
				centerprint(self, spacer,"Friendly Sentrygun made by\n\n", trace_ent.real_owner.netname,"\n");
			else 
				centerprint(self, spacer,"Εξενω Sentrygun made by\n\n", trace_ent.real_owner.netname,"\n");
		}	
		else if (trace_ent.classname == "building_tesla")
		{
			self.StatusRefreshTime = time + 1.5;
			if (self == trace_ent.real_owner)
				centerprint(self, spacer,"Your favorite Tesla Sentry\n");
			else if (!teamplay)
				centerprint(self, spacer,"Tesla Sentry made by\n\n", trace_ent.real_owner.netname,"\n");
			else if (Teammate(trace_ent.team_no, self.team_no))
				centerprint(self, spacer,"Friendly Tesla made by\n\n", trace_ent.real_owner.netname,"\n");
			else 
				centerprint(self, spacer,"Εξενω Tesla made by\n\n", trace_ent.real_owner.netname,"\n");
		}
		else if (trace_ent.classname == "building_camera")
		{
			self.StatusRefreshTime = time + 1.5;
			if (self == trace_ent.real_owner)
				centerprint(self, spacer,"Your favorite Security Camera\n");
			else if (!teamplay)
				centerprint(self, spacer,"Security Camera made by\n\n", trace_ent.real_owner.netname,"\n");
			else if (Teammate(trace_ent.team_no, self.team_no))
				centerprint(self, spacer,"Friendly Security Camera made by\n\n", trace_ent.real_owner.netname,"\n");
			else 
				centerprint(self, spacer,"Εξενω Security Camera made by\n\n", trace_ent.real_owner.netname,"\n");
		}
		else if (trace_ent.classname == "building_sensor")
		{
			self.StatusRefreshTime = time + 1.5;
			if (self == trace_ent.real_owner)
				centerprint(self, spacer,"Your favorite Motion Sensor\n");
			else if (!teamplay)
				centerprint(self, spacer,"Motion Sensor made by\n\n", trace_ent.real_owner.netname,"\n");
			else if (Teammate(trace_ent.team_no, self.team_no))
				centerprint(self, spacer,"Friendly Motion Sensor made by\n\n", trace_ent.real_owner.netname,"\n");
			else 
				centerprint(self, spacer,"Εξενω Motion Sensor made by\n\n", trace_ent.real_owner.netname,"\n");
		}
		else if (trace_ent.classname == "building_teleporter")
		{
			self.StatusRefreshTime = time + 1.5;
			if (self == trace_ent.real_owner)
				centerprint(self, spacer,"One of your favorite Teleporter Pads\n"); //CH b/c you have 2
			else if (!teamplay)
				centerprint(self, spacer,"Teleporter Pad made by\n\n", trace_ent.real_owner.netname,"\n");
			else if (Teammate(trace_ent.team_no, self.team_no))
				centerprint(self, spacer,"Friendly Teleporter Pad made by\n\n", trace_ent.real_owner.netname,"\n");
			else 
				centerprint(self, spacer,"Εξενω Teleporter Pad made by\n\n", trace_ent.real_owner.netname,"\n");
		}
		else if (trace_ent.classname == "monster_demon1")
		{
			custom_demon_name(trace_ent); //CH
			self.StatusRefreshTime = time + 1.5;
			st = ftos(trace_ent.health);
			if (self == trace_ent.real_owner)
				centerprint(self, spacer,"Your Pet Demon ",trace_ent.netname, "\n\n", st, " health");
			else if (!teamplay)
				centerprint(self, spacer,"Demon summoned by\n\n", trace_ent.real_owner.netname);
			else if (Teammate(trace_ent.real_owner.team_no, self.team_no))
			{
				if (self.cutf_items & CUTF_DEMONLORE)
					centerprint(self, spacer,trace_ent.netname,"\n\nfriendly demon summoned by\n\n", trace_ent.real_owner.netname, "\n\n", st, " health");
				else
					centerprint(self, spacer,trace_ent.netname,"\n\nfriendly demon summoned by\n\n", trace_ent.real_owner.netname);
			}
			else
			{
				if (self.cutf_items & CUTF_DEMONLORE)
					centerprint(self, spacer,trace_ent.netname,"\n\nεξενω demon summoned by\n\n", trace_ent.real_owner.netname, "\n\n", st, " health");
				else
					centerprint(self, spacer,trace_ent.netname,"\n\nεξενω demon summoned by\n\n", trace_ent.real_owner.netname, "\n\n", st, " health");
			}
		}
		else if (trace_ent.classname == "monster_army")
		{
			custom_demon_name(trace_ent); //CH
			self.StatusRefreshTime = time + 1.5;
			st = ftos(trace_ent.health);
			if (self == trace_ent.real_owner)
				centerprint(self, spacer,"Your mercenary soldier ",trace_ent.netname, "\n\n", st, " health");
			else if (!teamplay)
				centerprint(self, spacer,"Soldier in the pay of\n\n", trace_ent.real_owner.netname);
			else if (Teammate(trace_ent.real_owner.team_no, self.team_no))
			{
				if (self.cutf_items & CUTF_DEMONLORE)
					centerprint(self, spacer,trace_ent.netname,"\n\nfriendly soldier owned by\n\n", trace_ent.real_owner.netname, "\n\n", st, " health");
				else
					centerprint(self, spacer,trace_ent.netname,"\n\nfriendly soldier owned by\n\n", trace_ent.real_owner.netname);
			}
			else
			{
				if (self.cutf_items & CUTF_DEMONLORE)
					centerprint(self, spacer,trace_ent.netname,"\n\nεξενω soldier owned by\n\n", trace_ent.real_owner.netname, "\n\n", st, " health");
				else
					centerprint(self, spacer,trace_ent.netname,"\n\nεξενω soldier owned by\n\n", trace_ent.real_owner.netname);
			}
		}
		else if (trace_ent.classname == "monster_shambler")
		{
			custom_demon_name(trace_ent); //CH
			self.StatusRefreshTime = time + 1.5;
			st = ftos(trace_ent.health);
			if (self == trace_ent.real_owner)
				centerprint(self, spacer,"Your Pet Shambler ",trace_ent.netname, "\n\n", st, " health");
			else if (!teamplay)
				centerprint(self, spacer,"Shambler under control of\n\n", trace_ent.real_owner.netname);
			else if (Teammate(trace_ent.real_owner.team_no, self.team_no))
			{
				if (self.cutf_items & CUTF_DEMONLORE)
					centerprint(self, spacer,trace_ent.netname,"\n\nfriendly shambler summoned by\n\n", trace_ent.real_owner.netname, "\n\n", st, " health");
				else
					centerprint(self, spacer,trace_ent.netname,"\n\nfriendly shambler summoned by\n\n", trace_ent.real_owner.netname);
			}
			else
			{
				if (self.cutf_items & CUTF_DEMONLORE)
					centerprint(self, spacer,trace_ent.netname,"\n\nεξενω shambler summoned by\n\n", trace_ent.real_owner.netname, "\n\n", st, " health");
				else
					centerprint(self, spacer,trace_ent.netname,"\n\nεξενω shambler summoned by\n\n ", trace_ent.real_owner.netname);
			}
		}
        else if (trace_ent.classname == "monster_wizard") //- OfN
		{
			custom_demon_name(trace_ent); 
			self.StatusRefreshTime = time + 1.5;
			st = ftos(trace_ent.health);
			if (self == trace_ent.real_owner)
				centerprint(self, spacer,"Your flying Scrag ",trace_ent.netname, "\n\n", st, " health");
			else if (!teamplay)
				centerprint(self, spacer,"Scrag under control of\n\n", trace_ent.real_owner.netname);
			else if (Teammate(trace_ent.real_owner.team_no, self.team_no))
			{
				if (self.cutf_items & CUTF_DEMONLORE)
					centerprint(self, spacer,trace_ent.netname,"\n\nfriendly Scrag summoned by\n\n", trace_ent.real_owner.netname, "\n\n", st, " health");
				else
					centerprint(self, spacer,trace_ent.netname,"\n\nfriendly Scrag summoned by\n\n", trace_ent.real_owner.netname);
			}
			else
			{
				if (self.cutf_items & CUTF_DEMONLORE)
					centerprint(self, spacer,trace_ent.netname,"\n\nεξενω Scrag summoned by\n\n ", trace_ent.real_owner.netname, "\n\n", st, " health");
				else
					centerprint(self, spacer,trace_ent.netname,"\n\nεξενω Scrag summoned by\n\n", trace_ent.real_owner.netname);
			}
		}
	}
};

//=========================================================================
// Reloads the current weapon
void() TeamFortress_ReloadCurrentWeapon =
{
	local float rt;
	local entity tWeapon;

	if (self.current_weapon == WEAP_SHOTGUN)
	{
		if (self.reload_shotgun == 0)
		{
			sprint(self, PRINT_HIGH, "Clip full.\n");
			return;
		}

        if ( self.reload_shotgun < self.ammo_shells)
        {
			Attack_Finished(0.4);

			// Calculate the reload time needed
			rt = (RE_SHOTGUN - self.reload_shotgun) / RE_SHOTGUN;
			rt = RE_SHOTGUN_TIME - (RE_SHOTGUN_TIME * rt);

			self.reload_shotgun = 0;
			if (self.ammo_shells < RE_SHOTGUN)
				self.reload_shotgun = RE_SHOTGUN - self.ammo_shells;
		   
			sprint(self, PRINT_HIGH, "reloading...\n");
			self.tfstate = (self.tfstate | TFSTATE_RELOADING);
			tWeapon = spawn();
			tWeapon.netname = "reloadtimer"; //WK For Judoka code
			tWeapon.owner = self;
			tWeapon.classname = "timer";
			tWeapon.nextthink = time + rt;
			tWeapon.think = W_Reload_shotgun;

			self.weaponmodel = "";
			self.weaponframe = 0;
        }
		else
		{
			sprint(self, PRINT_HIGH, "not enough ammo to reload\n");
		}
	}
	else if (self.current_weapon == WEAP_SUPER_SHOTGUN)
	{
		if (self.reload_super_shotgun == 0)
		{
			sprint (self, PRINT_HIGH, "Clip full.\n");
			return;
		}

        if ( self.reload_super_shotgun < self.ammo_shells)
        {
        	Attack_Finished(0.7);

			// Calculate the reload time needed
			rt = (RE_SUPER_SHOTGUN - self.reload_super_shotgun) / RE_SUPER_SHOTGUN;
			rt = RE_SUPER_SHOTGUN_TIME - (RE_SUPER_SHOTGUN_TIME * rt);

			self.reload_super_shotgun = 0;
			if (self.ammo_shells < RE_SUPER_SHOTGUN)
				self.reload_super_shotgun = RE_SUPER_SHOTGUN - self.ammo_shells;

	      	sprint (self, PRINT_HIGH, "reloading...\n");
			self.tfstate = (self.tfstate | TFSTATE_RELOADING);
			tWeapon = spawn();
			tWeapon.netname = "reloadtimer"; //WK For Judoka code
			tWeapon.owner = self;
			tWeapon.classname = "timer";
			tWeapon.nextthink = time + rt;
         		tWeapon.think = W_Reload_super_shotgun;

	         	self.weaponmodel = "";
    		     	self.weaponframe = 0;
	  	}
		else
		{
			sprint (self, PRINT_HIGH, "not enough ammo to reload\n");
		}
	}
	else if (self.current_weapon == WEAP_LASERCANNON)
	{
		if (self.reload_laser_cannon == 0)
		{
			sprint (self, PRINT_HIGH, "Cannon already in full charge.\n");
			return;
		}

        if ( self.reload_laser_cannon < self.ammo_cells)
        {
	        	Attack_Finished(2);

			// Calculate the reload time needed
			rt = (RE_LASER_CANNON - self.reload_laser_cannon) / RE_LASER_CANNON;
			rt = RE_LASER_CANNON_TIME - (RE_LASER_CANNON_TIME * rt);

			self.reload_laser_cannon = 0;
			if (self.ammo_cells < RE_LASER_CANNON)
				self.reload_laser_cannon = RE_LASER_CANNON - self.ammo_cells;

	      	sprint (self, PRINT_HIGH, "Charging cannon...\n");
			self.tfstate = (self.tfstate | TFSTATE_RELOADING);
			tWeapon = spawn();
			tWeapon.netname = "reloadtimer"; //WK For Judoka code
			tWeapon.owner = self;
			tWeapon.classname = "timer";
			tWeapon.nextthink = time + rt;
         		tWeapon.think = W_Reload_laser_cannon;

	         	self.weaponmodel = "";
    		     	self.weaponframe = 0;
	  	}
		else
		{
			sprint (self, PRINT_HIGH, "not enough ammo to reload\n");
		}
	}
    else if (self.current_weapon == WEAP_LIGHT_ASSAULT)
	{
		if (self.reload_light_assault == 0)
		{
			sprint (self, PRINT_HIGH, "Clip full.\n");
			return;
		}

        if ( self.reload_light_assault < self.ammo_nails)
        {
	        	Attack_Finished(2);

			// Calculate the reload time needed
			rt = (RE_LIGHT_ASSAULT - self.reload_light_assault) / RE_LIGHT_ASSAULT;
			rt = RE_LIGHT_ASSAULT_TIME - (RE_LIGHT_ASSAULT_TIME * rt);

			self.reload_light_assault = 0;
			if (self.ammo_nails < RE_LIGHT_ASSAULT)
				self.reload_light_assault = RE_LIGHT_ASSAULT - self.ammo_nails;

	      	sprint (self, PRINT_HIGH, "reloading...\n");
			self.tfstate = (self.tfstate | TFSTATE_RELOADING);
			tWeapon = spawn();
			tWeapon.netname = "reloadtimer"; //WK For Judoka code
			tWeapon.owner = self;
			tWeapon.classname = "timer";
			tWeapon.nextthink = time + rt;
         		tWeapon.think = W_Reload_light_assault;

	         	self.weaponmodel = "";
    		     	self.weaponframe = 0;
	  	}
		else
		{
			sprint (self, PRINT_HIGH, "not enough ammo to reload\n");
		}
	}
	else if (self.current_weapon == WEAP_GRENADE_LAUNCHER)
	{
		if (self.reload_grenade_launcher == 0)
		{
			sprint (self, PRINT_HIGH, "Clip full.\n");
			return;
		}
		
        if (self.reload_grenade_launcher < self.ammo_rockets)
        {
		Attack_Finished(0.6);

		// Calculate the reload time needed
		rt = (RE_GRENADE_LAUNCHER - self.reload_grenade_launcher) / RE_GRENADE_LAUNCHER;
		rt = RE_GRENADE_LAUNCHER_TIME - (RE_GRENADE_LAUNCHER_TIME * rt);

	  	self.reload_grenade_launcher = 0;
		if (self.ammo_rockets < RE_GRENADE_LAUNCHER)
			self.reload_grenade_launcher = RE_GRENADE_LAUNCHER - self.ammo_rockets;

	  	sprint (self, PRINT_HIGH, "reloading...\n");
		self.tfstate = (self.tfstate | TFSTATE_RELOADING);
	     	tWeapon = spawn();
		tWeapon.netname = "reloadtimer"; //WK For Judoka code
	     	tWeapon.owner = self;
		tWeapon.classname = "timer";
		tWeapon.nextthink = time + rt;
	      tWeapon.think = W_Reload_grenade_launcher;

	      self.weaponmodel = "";
	      self.weaponframe = 0;
	}
	else {
		sprint (self, PRINT_HIGH, "not enough ammo to reload\n");
	}
	}
	else if (self.current_weapon == WEAP_ROCKET_LAUNCHER)
	{
		if (self.reload_rocket_launcher == 0)
		{
			sprint (self, PRINT_HIGH, "Clip full.\n");
			return;
		}

	    if (self.reload_rocket_launcher < self.ammo_rockets)
      	{
        	Attack_Finished(0.8);

		// Calculate the reload time needed
		rt = (RE_ROCKET_LAUNCHER - self.reload_rocket_launcher) / RE_ROCKET_LAUNCHER;
		rt = RE_ROCKET_LAUNCHER_TIME - (RE_ROCKET_LAUNCHER_TIME * rt);

        	self.reload_rocket_launcher = 0;
		if (self.ammo_rockets < RE_ROCKET_LAUNCHER)
			self.reload_rocket_launcher = RE_ROCKET_LAUNCHER - self.ammo_rockets;

     		sprint (self, PRINT_HIGH, "reloading...\n");
		self.tfstate = (self.tfstate | TFSTATE_RELOADING);
         	tWeapon = spawn();
		tWeapon.netname = "reloadtimer"; //WK For Judoka code
         	tWeapon.owner = self;
		tWeapon.classname = "timer";
         	tWeapon.nextthink = time + rt;
         	tWeapon.think = W_Reload_rocket_launcher;

         	self.weaponmodel = "";
         	self.weaponframe = 0;
      	}
	}
};

//CH drops an item TF goal if the bits are set to allow it.
void() TeamFortress_DropItems =
{
	local entity tg;

	tg = find (NIL, classname, "item_tfgoal");
	while (tg)
	{
		if (tg.owner == self && tg && tg.classname == "item_tfgoal")
		{
			if (tg.goal_result & TFGR_DROPITEMS)
			{
				sprint (self, PRINT_HIGH, "Dropping item: ");
				sprint (self, PRINT_HIGH, tg.netname);
				sprint (self, PRINT_HIGH, "\n");
				tfgoalitem_RemoveFromPlayer(tg, self, 0);
//CH it treats it as though you died.  And if bits are set, you throw it, or it gets removed etc.
			}
		}

		tg = find(tg, classname, "item_tfgoal");
	}
};
