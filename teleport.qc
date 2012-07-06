#include "defs.qh"
/*======================================================
	TELEPORT.QC			Custom TeamFortress v2.2

	(c) Craig Hauser			23/3/00
========================================================
Functions for the teleporters
======================================================*/

void() Teleporter_touch;
void() Teleporter_Die;
void() Teleporter_heat_think;
int (entity ent) Teleporter_CheckBlocked;
float(entity targ) Teleporter_check_person;

#define TELEPORTER_CELLS	8 //How many cells to use on teleport
#define TELEPORTER_WAIT		2  //How long to wait after teleport (whole number)

//====================
void() Teleporter_touch =
{
	local entity te;

	if (self.heat == 0)
	{
		if (Teleporter_check_person(other))
		{
			te = find(nil, classname, "building_teleporter");
			while (!(te.real_owner == self.real_owner && te != self) && te)
			{
				te = find(te, classname, "building_teleporter");
			}
			if (te)
			{
				if (te.heat == 0 && te.ammo_cells >= TELEPORTER_CELLS)
				{
					self.heat = TELEPORTER_WAIT;
					te.heat = TELEPORTER_WAIT;
					if (self.is_malfunctioning & SCREWUP_FOUR || te.is_malfunctioning & SCREWUP_FOUR)
					{
						CenterPrint(other, "The other teleporter is out of power.\n");
						return;
					}
					self.ammo_cells = self.ammo_cells - TELEPORTER_CELLS;
					te.ammo_cells = te.ammo_cells - TELEPORTER_CELLS;
					local entity ote;
					ote = te;
					if (self.is_malfunctioning & SCREWUP_THREE || te.is_malfunctioning & SCREWUP_THREE) //sb
					{
						te = self.real_owner;
						spawn_tdeath(te.origin + '0 0 32', te);
					}
					spawn_tfog (other.origin);
					spawn_tdeath(te.origin + '0 0 32', other);
					makeImmune(other,time + 2);
					setorigin(other, te.origin + '0 0 32');
					if (self.is_malfunctioning & SCREWUP_ONE || te.is_malfunctioning & SCREWUP_ONE) // SB
					{
						other.ammo_cells = 0;
						other.ammo_shells = 0;
						other.ammo_nails = 0;
						other.ammo_rockets = 0;
						other.armorvalue = 0;
						other.ammo_detpack = 0;
						other.ammo_c4det = 0;
						other.ammo_medikit = 0;
					}
					if (self.is_malfunctioning & SCREWUP_TWO || te.is_malfunctioning & SCREWUP_TWO) // SB
					{
						if (self.is_malfunctioning & SCREWUP_TWO)
							te.martyr_enemy = self.martyr_enemy;
						else if (te.is_malfunctioning & SCREWUP_TWO)
							self.martyr_enemy = te.martyr_enemy;
						TF_T_Damage(other, self, self, 500, 0, TF_TD_OTHER);
					}
					spawn_tfog (te.origin + '0 0 32');
					if (self.is_malfunctioning & SCREWUP_THREE || ote.is_malfunctioning & SCREWUP_THREE)
						te = ote;
					if ((te.ammo_cells >= TELEPORTER_CELLS && te.ammo_cells <= TELEPORTER_CELLS * 2) || (self.ammo_cells >= TELEPORTER_CELLS && self.ammo_cells <= TELEPORTER_CELLS * 2))
						sprint (self.real_owner, PRINT_HIGH, "A teleporter is getting low on power.\n");
				}
				else if (te.ammo_cells < TELEPORTER_CELLS)
					CenterPrint(other, "The other teleporter is out of power.\n");
			}
		}
	}
	
};
//===============
float(entity targ) Teleporter_check_person =
{
	if (infokey(nil,"ceasefire")=="on") //To not cause loops
		return FALSE;
	if (!targ)//that would be bad.
		return FALSE;
	if (targ.done_custom & CUSTOM_BUILDING)
		return FALSE;
	if (targ.classname != "player")
		return FALSE;
	if (targ.velocity != '0 0 0')
		return FALSE;
	if (targ.health <= 0)
		return FALSE;
	if (targ.has_disconnected)
		return FALSE;
	if (targ.playerclass == PC_UNDEFINED)
		return FALSE;
	if (targ.is_feigning)
		return FALSE;
	if (targ.is_building)
		return FALSE;
	if (targ.is_detpacking)
		return FALSE;
	if (self.ammo_cells < TELEPORTER_CELLS) {
		if (Teammate(targ.team_no, self.team_no)) //only to team member
			CenterPrint(other, "This teleporter is out of power.\n");
		return FALSE;
	}
	if (self.real_owner.has_teleporter == 1) {
		if (Teammate(targ.team_no, self.team_no)) //only to team member
			CenterPrint(other, "There is no other teleporter!\n");
		return FALSE;
	}
	if (targ.playerclass == PC_CIVILIAN) {
		CenterPrint(targ, "Civilian + Teleporter = No, NFC!\n");
		return FALSE;
	}
	if (targ.effects & EF_ANYGLOW) {//no flag for you!
		CenterPrint(targ, "Can't use teleporter while glowing!\n");
		return FALSE;
	}

//ALL NEW CHECKS _MUST_ BE ABOVE THIS LINE
	if (teamplay)
	{
		if (Teammate(targ.team_no, self.team_no))
			return TRUE;
		if (Teammate(targ.undercover_team, self.team_no))
			return TRUE;
	}
	else
		return TRUE;
	return FALSE;
};
//===============
void() Teleporter_heat_think =
{
//CH used to reduce the heat and check pos
	if (self.heat <= 0)
		self.heat = 0;
	else
		self.heat = self.heat - 1;

	self.think = Teleporter_heat_think; //keep in loop
	self.nextthink = time + 1;
	if (Teleporter_CheckBlocked(self)) {
		sprint (self.real_owner, PRINT_HIGH, "Not enough space for teleportation.\n");
		TF_T_Damage (self, nil, nil, self.health + 1, 0, 0);
	}
};

int (entity ent) Teleporter_CheckBlocked =
{
	checkmove (ent.origin + '0 0 32', '-16 -16 -24', '16 16 32',
			   ent.origin + '0 0 32', MOVE_NOMONSTERS, ent);

	if (trace_startsolid || trace_fraction != 1)
		return TRUE;
	else
		return FALSE;

/*
	local float pos, num;
	local vector loc;

//CH if spawnflags is >0 do extensive height checks b/c the pad just spawned.
	if (ent.spawnflags > 0) {
		ent.spawnflags = ent.spawnflags - 1;
		num = 0; //16 checks
	}
	else
		num = 15; //1 check
	while (num < 16)
	{
		//sprint (ent.real_owner, PRINT_HIGH, "Checking space!\n");
		loc = ent.origin;
		loc.x = loc.x + ((rint(random() * 3 + 1) * 16) - 32);
		loc.y = loc.y + ((rint(random() * 3 + 1) * 16) - 32);
		loc.z = loc.z + (rint(random() * 8 + 1) * 8); //1-8 * 8  x+8 -> x+64

		pos = pointcontents(loc);
		if (pos == CONTENTS_SOLID || pos == CONTENTS_SKY)
			return TRUE;
		num = num + 1;
	}
	return FALSE;
*/
};


//================
void() Teleporter_Die =
{
	sprint(self.real_owner, PRINT_HIGH, "Your Teleporter Pad was destroyed.\n");
	self.real_owner.has_teleporter = (self.real_owner.has_teleporter - 1);

//	ThrowGib("progs/tgib1.mdl", -70);
//	ThrowGib("progs/tgib2.mdl", -70);
//	ThrowGib("progs/tgib3.mdl", -70);

	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_EXPLOSION);
	WriteCoord (MSG_MULTICAST, self.origin.x);
	WriteCoord (MSG_MULTICAST, self.origin.y);
	WriteCoord (MSG_MULTICAST, self.origin.z);
	multicast (self.origin, MULTICAST_PHS);
    dremove(self);
};
