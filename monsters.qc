/* ALL MONSTERS SHOULD BE 1 0 0 IN COLOR */
#include "defs.qh"
#include "monsters.qh"

// name =[framenum,	nexttime, nextthink] {code}
// expands to:
// name ()
// {
//		self.frame=framenum;
//		self.nextthink = time + nexttime;
//		self.think = nextthink
//		<code>
// };

//- OfN -
entity (vector location, float life, float type) CreateWaypoint;
void (entity player) kill_his_demon;
string(entity themonster) GetMonsterName;

/*
=============
visible

returns 1 if the entity is visible to self, even if not infront ()
=============
*/

float (entity targ) visible =
{
	local vector	spot1, spot2;
	
	spot1 = self.origin + self.view_ofs;
	spot2 = targ.origin + targ.view_ofs;
	traceline (spot1, spot2, TRUE, self);	// see through other monsters
	
	if (trace_inopen && trace_inwater)
		return FALSE;			// sight line crossed contents

	if (trace_fraction == 1)
		return TRUE;
	return FALSE;
};
//CH so you can check other then self
float (entity targ, entity check) visible2 =
{
	local vector	spot1, spot2;
	
	spot1 = check.origin + check.view_ofs;
	spot2 = targ.origin + targ.view_ofs;
	traceline (spot1, spot2, TRUE, check);	// see through other monsters
	
	if (trace_inopen && trace_inwater)
		return FALSE;			// sight line crossed contents

	if (trace_fraction == 1 && trace_endpos == spot2) //CH just extra check
		return TRUE;
	return FALSE;
};

//- OfN - Used for haxxx and sentrygun targetting
float (entity targ, entity check) visible2x =
{
	local vector	spot1, spot2;
	
	spot1 = check.origin + check.view_ofs;
	spot2 = targ.origin + targ.view_ofs;
	
    if (check.classname == "building_sentrygun" && (check.tf_items & NIT_TURRET))
        spot1 = check.origin + check.view_ofs - '0 0 20';
    
    if (check.classname == "building_sentrygun" && !(check.tf_items & NIT_TURRET))
        spot1 = check.origin + check.view_ofs + '0 0 20';

    traceline (spot1, spot2, TRUE, check);	// see through other monsters
	
	if (trace_inopen && trace_inwater)
		return FALSE;			// sight line crossed contents

	if (trace_fraction == 1)
		return TRUE;
	return FALSE;
};


//#ifndef COOP_MODE
#ifdef NEVER_DEFINED
/*
void() monster_ogre =
{
	dremove(self);
};

void() monster_knight =
{
	dremove(self);
};
 
void() monster_shambler =
{
	dremove(self);
};

void() monster_demon1 =
{
	dremove(self);
};

void() monster_wizard =
{
	dremove(self);
};

void() monster_zombie =
{
	dremove(self);
};

void() monster_dog =
{
	dremove(self);
};

void() monster_hell_knight =
{
	dremove(self);
};

void() monster_tarbaby =
{
	dremove(self);
};

void() monster_vomit =
{
	dremove(self);
};

void() monster_enforcer =
{
	dremove(self);
};

void() monster_shalrath =
{
	dremove(self);
};

void() monster_dragon =
{
	dremove(self);
};

void() monster_army =
{
	dremove(self);
};

*/

/*
==============================================================================

MOVETARGET CODE

The angle of the movetarget effects standing and bowing direction, but has no effect on movement, which allways heads to the next target.

targetname
must be present.  The name of this movetarget.

target
the next spot to move to.  If not present, stop here for good.

pausetime
The number of seconds to spend standing or bowing for path_stand or path_bow

==============================================================================
*/

/*
void() t_movetarget;

void() movetarget_f =
{
	if (!self.targetname)
		objerror ("monster_movetarget: no targetname");

	self.solid = SOLID_TRIGGER;
	self.touch = t_movetarget;
	setsize (self, '-8 -8 -8', '8 8 8');
};

*/

/*QUAKED path_corner (0.5 0.3 0) (-8 -8 -8) (8 8 8)
Monsters will continue walking towards the next target corner.
*/

/*
void() path_corner =
{
	if (CheckExistence() == FALSE)
	{
		dremove(self);
		return;
	}

	movetarget_f ();
};
*/

/*
=============
t_movetarget

Something has bumped into a movetarget.  If it is a monster
moving towards it, change the next destination and continue.
==============
*/

/*
void() t_movetarget =
{
	local entity	temp;

	if (other.movetarget != self)
		return;
	
	if (other.enemy)
		return;		// fighting, not following a path

	temp = self;
	self = other;
	other = temp;
*/
/*
	if (self.classname == "monster_ogre")
		sound (self, CHAN_VOICE, "ogre/ogdrag.wav", 1, ATTN_IDLE);// play chainsaw drag sound
*/
/*
//RPrint ("t_movetarget\n");
	self.goalentity = self.movetarget = find (nil, targetname, other.target);
	self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
	if (!self.movetarget)
	{
		self.pausetime = time + 999999;
		self.th_stand ();
		return;
	}
};

float(float v) anglemod =
{
	while (v >= 360)
		v = v - 360;
	while (v < 0)
		v = v + 360;
	return v;
};

float(entity targ) range =
{
	local vector	spot1, spot2;
	local float		r;	

	spot1 = self.origin + self.view_ofs;
	spot2 = targ.origin + targ.view_ofs;
	
	r = vlen (spot1 - spot2);
	if (r < 120)
		return RANGE_MELEE;
	if (r < 500)
		return RANGE_NEAR;
	if (r < 1000)
		return RANGE_MID;
	return RANGE_FAR;
};

*/
/*
=============
infront

returns 1 if the entity is in front (in sight) of self
=============
*/
/*
float(entity targ) infront =
{
	local vector	vec;
	local float		dot;
	
	makevectors (self.angles);
	vec = normalize (targ.origin - self.origin);
	dot = vec * v_forward;
	
	if ( dot > 0.3)
	{
		return TRUE;
	}
	return FALSE;
};



//============================================================================

void() HuntTarget =
{
	self.goalentity = self.enemy;
	self.think = self.th_run;
	self.ideal_yaw = vectoyaw(self.enemy.origin - self.origin);
	self.nextthink = time + 0.1;
	SUB_AttackFinished (1);	// wait a while before first attack
};


/*
===========
FindTarget

Self is currently not attacking anything, so try to find a target

Returns TRUE if an enemy was sighted

When a player fires a missile, the point of impact becomes a fakeplayer so
that monsters that see the impact will respond as if they had seen the
player.

To avoid spending too much time, only a single client (or fakeclient) is
checked each frame.  This means multi player games will have slightly
slower noticing monsters.
============
*/

/*
float() FindTarget =
{
//WK THIS CODE IS DEF-ed out!!
/* WK Replace this with the code from sentry
	local entity	client;
	
	client = checkclient ();

	if (!client)
		return FALSE;	// current check entity isn't in PVS

	if (client.flags & FL_NOTARGET)
		return FALSE;
	if (client.items & IT_INVISIBILITY)
		return FALSE;
	
	if (!visible (client))
		return FALSE;

	if (client.classname != "player")
		return FALSE;	

	self.enemy = client;

	HuntTarget ();

	return TRUE;
*/
/*
	local entity client;
	local float	r, gotone, loopc;

	//WK Hack to get floating sentry working
	if (self.tf_items & NIT_FLOATING_SENTRY) {
		self.origin.z = self.origin.z - 40;
	}

	// Try a few checks to make it react faster
	r = 0;
	loopc = 0;
	gotone = FALSE;
	while (loopc < 5 && gotone == FALSE) //WK 3
	{
		client = checkclient();

		gotone = TRUE;

		if (!client)
			gotone = FALSE;
/*
		if (teamplay)
		{
			// Only attack enemies
			if (client.team_no == self.team_no && self.team_no != 0)
				gotone = FALSE;

			// Cant see Undercover spies
			if (client.undercover_team == self.team_no && self.team_no != 0)
				gotone = FALSE;
		}

//		if (client == self.real_owner)
//			gotone = FALSE;
*/
/*
		if (client.is_feigning)
			gotone = FALSE;

		if (client.flags & FL_NOTARGET)
			gotone = FALSE;
		if (client.items & IT_INVISIBILITY)
			gotone = FALSE;

		if (!visible (client))
			gotone = FALSE;

		r = range (client);
		if (r == RANGE_FAR)
			gotone = FALSE;			
	
		if (r == RANGE_NEAR)
		{
			if (client.show_hostile < time && !infront (client))
				gotone = FALSE;
		}
		else if (r == RANGE_MID)
		{
			if ( /* client.show_hostile < time || */ !infront (client))
/*				gotone = FALSE;
		}
		loopc = loopc + 1;
		if (gotone) loopc = 1000;
	}

	if (!gotone)
		return FALSE;

	// Found a Target
	self.enemy = client;
	if (self.enemy.classname != "player")
	{
		self.enemy = self.enemy.enemy;
		if (self.enemy.classname != "player")
		{
			self.enemy = nil;
			return FALSE;
		}
	}
	
	HuntTarget ();

	return TRUE;
};*/
#endif

void() FoundTarget;


/*
================
monster_use

Using a monster makes it angry at the current activator
================
*/
void() monster_use =
{
	if (self.enemy)
		return;
	if (self.health <= 0)
		return;
	if (activator.items & IT_INVISIBILITY)
		return;
	if (activator.flags & FL_NOTARGET)
		return;
	if (activator.classname != "player")
		return;
	
// delay reaction so if the monster is teleported, its sound is still
// heard
	self.enemy = activator;
	self.nextthink = time + 0.1;
	self.think = FoundTarget;
};

/*===========================
set_monster_health

Increases the monsters health 
for skill levels above 3
doesnt work
===========================*/

void() set_monster_health =
{
	skill = cvar("skill");

	if (skill > 2)
	{
		self.lives = ((skill - 2) * 10) - 1;
		skill = 3;
	}
};


/*
================
monster_death_use

When a mosnter dies, it fires all of its targets with the current
enemy as activator.
================
*/
#ifdef COOP_MODE
//WK This is doubly declared in combat.qc
void() monster_death_use =
{
	local entity 	ent, otemp;

// fall to ground
	if (self.flags & FL_FLY)
		self.flags = self.flags - FL_FLY;
	if (self.flags & FL_SWIM)
		self.flags = self.flags - FL_SWIM;

	if (!self.target)
		return;

	activator = self.enemy;
	SUB_UseTargets ();
};
#endif

//============================================================================

void() walkmonster_start_go =
{
//	local float		failure;
//	local vector	test;

	self.movetype = MOVETYPE_STEP;
	self.solid = SOLID_SLIDEBOX;

	self.origin.z = self.origin.z + 1;	// raise off floor a bit
	droptofloor();
	
	if (entpointcontents(self) == CONTENTS_SOLID)
	{
		//- OfN - if (self.classname == "monster_demon1" || self.classname == "monster_army" || self.classname == "monster_shambler")
        if (IsMonster(self))
			if (self.real_owner.classname == "player")
			{
				//self.real_owner.job &= ~JOB_DEMON_OUT);
				local string MName;
                MName=GetMonsterName(self);
                sprint(self.real_owner,PRINT_HIGH,"Your ");
                sprint(self.real_owner,PRINT_HIGH,MName);
                sprint(self.real_owner,PRINT_HIGH," was beamed into a wall and died.\n");

				if (self.classname == "monster_shambler") //- ofn
				{
					self.real_owner.demon_blood = self.real_owner.demon_blood + 4;
					if (self.real_owner.demon_blood > MAX_KNIFE_BLOOD)
						self.real_owner.demon_blood = MAX_KNIFE_BLOOD;
				}
                else if (self.classname == "monster_demon1") //- ofn
				{
					self.real_owner.demon_blood = self.real_owner.demon_blood + 2;
					if (self.real_owner.demon_blood > MAX_KNIFE_BLOOD)
						self.real_owner.demon_blood = MAX_KNIFE_BLOOD;
				}
                
                /*else if (self.classname == "monster_wizard") //- ofn
				{
					self.real_owner.demon_blood = self.real_owner.demon_blood + ? ;
					if (self.real_owner.demon_blood > MAX_KNIFE_BLOOD)
						self.real_owner.demon_blood = MAX_KNIFE_BLOOD;
				}*/

                kill_his_demon(self.real_owner);
                return;
			}
		dremove(self);
		return;
	}
	
	self.takedamage = DAMAGE_AIM;

	self.ideal_yaw = self.angles * '0 1 0';
	if (!self.yaw_speed)
		self.yaw_speed = 20;
	self.view_ofs = '0 0 25';
	self.use = monster_use;
	
	self.flags |= FL_MONSTER;
	
	if (self.target)
	{
		self.goalentity = self.movetarget = find(nil, targetname, self.target);
		self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
		if (!self.movetarget)
		{
			RPrint ("Monster can't find target at ");
			RPrint (vtos(self.origin));
			RPrint ("\n");
		}
// this used to be an objerror
		if (self.movetarget.classname == "path_corner")
			self.th_walk ();
		else
			self.pausetime = 99999999;
			self.th_stand ();
	}
	else
	{
		self.pausetime = 99999999;
		self.th_stand ();
	}
	
	if (self.classname == "monster_army")
	{
        self.martyr_enemy = CreateWaypoint(self.origin,WAYPOINT_LIFE,WAYPOINT_TYPE_PRIMARY);
		self.martyr_enemy.goalentity = nil;

        // OFTEN
        self.demon_two=nil;
        self.demon_one=nil;
        // OFTEN

		self.goalentity = nil;
	}

// spread think times so they don't all happen at same time
	self.nextthink = self.nextthink + random()*0.5;
};


void() walkmonster_start =
{
// delay drop to floor to make sure all doors have been spawned
// spread think times so they don't all happen at same time
	self.nextthink = self.nextthink + 1; //WK Give time to run from demons
	//WK self.nextthink = self.nextthink + random()*0.5;
	self.think = walkmonster_start_go;
	total_monsters = total_monsters + 1;
	set_monster_health();
};



void() flymonster_start_go =
{
	self.takedamage = DAMAGE_AIM;

	self.ideal_yaw = self.angles * '0 1 0';
	if (!self.yaw_speed)
		self.yaw_speed = 10;
	self.view_ofs = '0 0 25';
	self.use = monster_use;

	self.flags |= FL_FLY;
	self.flags |= FL_MONSTER;

	if (!walkmove(0,0))
	{
		RPrint ("flymonster in wall at: ");
		RPrint (vtos(self.origin));
		RPrint ("\n");
	}

	if (self.target)
	{
		self.goalentity = self.movetarget = find(nil, targetname, self.target);
		if (!self.movetarget)
		{
			RPrint ("Monster can't find target at ");
			RPrint (vtos(self.origin));
			RPrint ("\n");
		}
// this used to be an objerror
		if (self.movetarget.classname == "path_corner")
			self.th_walk ();
		else
			self.pausetime = 99999999;
			self.th_stand ();
	}
	else
	{
		self.pausetime = 99999999;
		self.th_stand ();
	}
};

void() flymonster_start =
{
// spread think times so they don't all happen at same time
	self.nextthink = self.nextthink + random()*0.5;
        
	self.think = flymonster_start_go;
	total_monsters = total_monsters + 1;
	set_monster_health();
};


void() swimmonster_start_go =
{
	if (deathmatch)
	{
		dremove(self);
		return;
	}

	self.takedamage = DAMAGE_AIM;
	total_monsters = total_monsters + 1;

	self.ideal_yaw = self.angles * '0 1 0';
	if (!self.yaw_speed)
		self.yaw_speed = 10;
	self.view_ofs = '0 0 10';
	self.use = monster_use;
	
	self.flags |= FL_SWIM;
	self.flags |= FL_MONSTER;

	if (self.target)
	{
		self.goalentity = self.movetarget = find(nil, targetname, self.target);
		if (!self.movetarget)
		{
			RPrint ("Monster can't find target at ");
			RPrint (vtos(self.origin));
			RPrint ("\n");
		}
// this used to be an objerror
		self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
		self.th_walk ();
	}
	else
	{
		self.pausetime = 99999999;
		self.th_stand ();
	}

// spread think times so they don't all happen at same time
	self.nextthink = self.nextthink + random()*0.5;
};

void() swimmonster_start =
{
// spread think times so they don't all happen at same time
	self.nextthink = self.nextthink + random()*0.5;
	self.think = swimmonster_start_go;
	total_monsters = total_monsters + 1;
	set_monster_health();
};
// WK #endif

/* WK We are already including these
ai.qc
fight.qc
demon.qc
*/
#ifdef COOP_MODE
// include all the monsters
// WK In normal QW we only need demons
// SB and soldiers, and shamblers
#include "dog.qc"
#include "enforcer.qc"
#include "fish.qc"
#include "hknight.qc"
#include "knight.qc"
#include "ogre.qc"
#include "oldone.qc"
#include "shalrath.qc"
#include "tarbaby.qc"
#include "wizard.qc"
#include "zombie.qc"
#endif
