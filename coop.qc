#include "defs.qh"
/*============================
	coop.qc

This file handles all the
cooperative mode functions
============================*/


void() DroppedKeyThink =
{
	// let the throwing player pick it up again
	self.think = dont_think;
	self.touch = key_touch;
	self.owner = nil;
};


void() DropKey =
{
	if ((self.items & IT_KEY1) || (self.items & IT_KEY2))
	{
		newmis = spawn();
	
		if (self.items & IT_KEY1)
		{	
			self.items &= ~IT_KEY1;
			newmis.items = IT_KEY1;
			if (world.worldtype == 0)
			{
				setmodel (newmis, "progs/w_s_key.mdl");
				newmis.netname = "silver key";
				newmis.noise = "misc/medkey.wav";
			}
			else if (world.worldtype == 1)
			{
				setmodel (newmis, "progs/m_s_key.mdl");
				newmis.netname = "silver runekey";
				newmis.noise = "misc/runekey.wav";
			}
			else if (world.worldtype == 2)
			{
				setmodel (newmis, "progs/b_s_key.mdl");
				newmis.netname = "silver keycard";
				newmis.noise = "misc/basekey.wav";
			}
		}
		else if (self.items & IT_KEY2)
		{	
			self.items &= ~IT_KEY2;
			newmis.items = IT_KEY2;
			if (world.worldtype == 0)
			{
				setmodel (newmis, "progs/w_g_key.mdl");
				newmis.netname = "gold key";
				newmis.noise = "misc/medkey.wav";
			}
			else if (world.worldtype == 1)
			{
				setmodel (newmis, "progs/m_g_key.mdl");
				newmis.netname = "gold runekey";
				newmis.noise = "misc/runekey.wav";
			}
			else if (world.worldtype == 2)
			{
				setmodel (newmis, "progs/b_g_key.mdl");
				newmis.netname = "gold keycard";
				newmis.noise = "misc/basekey.wav";
			}
		}

		newmis.owner = self;
		newmis.touch = nil;
		setorigin(newmis, self.origin + '0 0 16');
		makevectors(self.v_angle);
		newmis.velocity = normalize(v_forward) * 300 + '0 0 200';
		newmis.movetype = MOVETYPE_TOSS;
		newmis.solid = SOLID_TRIGGER;

		newmis.deadflag = TRUE;
		setsize (newmis, '-16 -16 -24', '16 16 32');
		newmis.think = DroppedKeyThink;
		newmis.nextthink = time + 1.5;
	}
	else
	{
		sprint (self, PRINT_HIGH, "You don't have a key\n");
	}
};

/*==================================
	DoorShouldOpen
	
This function is only for key doors in
coop mode 2.

It returns true	if all players have keyed
the door.
==================================*/

float() DoorShouldOpen =
{
	local entity ptr;
	local float plyrcount;
	local entity plyr1 = nil;
	local entity plyr2 = nil;

	if (coop != 2)
		return TRUE;

	plyrcount = 0;
	ptr = find(nil, classname, "player");
	while (ptr)
	{
		if (!(ptr.tf_items & self.items) && ptr.playerclass != PC_UNDEFINED
										 && ptr.solid != SOLID_NOT
										 && ptr.model)
		{
			plyrcount = plyrcount + 1;
			if (plyrcount == 1)
				plyr1 = ptr;
			else if(plyrcount == 2)
				plyr2 = ptr;
		}

		ptr = find(ptr, classname, "player");
	}

	if (plyrcount != 0)
	{
		if (plyrcount == 1)
		{
			bprint(PRINT_HIGH, plyr1.netname);
			bprint(PRINT_HIGH, " needs");
		}
		else if (plyrcount == 2)
		{
			bprint(PRINT_HIGH, plyr1.netname);
			bprint(PRINT_HIGH, " and ");
			bprint(PRINT_HIGH, plyr2.netname);
			bprint(PRINT_HIGH, " need");
		}
		else
		{
			bprint(PRINT_HIGH, "More players need");
		}

		bprint(PRINT_HIGH, " to unlock the ");
		if (self.items & IT_KEY1)
			bprint(PRINT_HIGH, "silver");
		else
			bprint(PRINT_HIGH, "gold");
		bprint(PRINT_HIGH, " door\n");

		return FALSE;
	}

	bprint(PRINT_HIGH, "The ");
	if (self.items & IT_KEY1)
		bprint(PRINT_HIGH, "silver");
	else
		bprint(PRINT_HIGH, "gold");
	bprint(PRINT_HIGH, " door has been unlocked\n");

	return TRUE;
};
