#include "defs.qh"
/*======================================================
	SNIPER.QC

	TeamFortress v2.5	 29/2/97
========================================================
Functions for the SNIPER class and associated weaponry                          
========================================================*/
// Functions outside this file

// Functions inside this file
void() TeamFortress_SniperWeapon;
// Autozoom functions
void(float zoom_level) TF_zoom;
void() SniperSight_Update;
void() SniperSight_Update2;
void(float type) SniperSight_Create;



//=========================================================================
// Sniper/Auto Rifle selection function
void() TeamFortress_SniperWeapon =
{
	self.impulse = 0;

    if (self.tfstate & TFSTATE_RELOADING)
   		return;

	if (!((self.weapons_carried & WEAP_SNIPER_RIFLE) && (self.weapons_carried & WEAP_AUTO_RIFLE)))
		return;

	if (self.ammo_shells < 5)
	{	// don't have the ammo
		sprint (self, PRINT_HIGH, "not enough ammo.\n");
		return;
	}

#ifndef NO_AUTORIFLE
	if (self.current_weapon == WEAP_SNIPER_RIFLE)
	{
		self.current_weapon = WEAP_AUTO_RIFLE;
	}
	else
#endif
	{
		self.current_weapon = WEAP_SNIPER_RIFLE;
	}

	W_SetCurrentAmmo ();
};

//=========================================================================
// Do the autozoom of the sniper rifle
void(float zoom_level) TF_zoom =
{
	local string zl;
	
	if (self.tfstate & TFSTATE_ZOOMOFF)
		return;

	zl = ftos(zoom_level);

	stuffcmd(self, "fov ");
	stuffcmd(self, zl);
	stuffcmd(self, "\n");
};


//=========================================================================
// Move the sight to the point the rifle's aiming at
void() SniperSight_Update =
{
	local vector org;

	if (!(self.owner.tfstate & TFSTATE_AIMING) || (self.owner.current_weapon != WEAP_SNIPER_RIFLE))
	{
		self.owner.tfstate &= ~TFSTATE_AIMING;
		TeamFortress_SetSpeed(self.owner);
		self.owner.heat = 0;
		dremove(self);
		return;
	}

    makevectors(self.owner.v_angle);

	org = self.owner.origin + v_forward*10;
	org.z = self.owner.absmin.z + self.owner.size.z * 0.7;

    traceline (org, org + v_forward*9192, FALSE, self);

    if (trace_fraction == 1.0)
	{
       	setorigin(self, self.owner.origin );
		return;
	}

	self.angles = vectoangles(v_forward);
    setorigin(self, trace_endpos);

	self.v_angle.z = self.owner.v_angle.z;

	self.owner.heat *= 0.9;
	self.owner.heat--;

	local float diff = vlen(self.owner.v_angle - self.v_angle);
	if (diff > 10) diff = 10;

	local float heat = diff * 0.5 + vlen(self.owner.velocity) * 0.1;
	if (self.owner.heat < heat)
	   self.owner.heat = heat;

	self.v_angle = self.owner.v_angle;

	self.nextthink = time + 0.1;
};
//CH used for the rl
void() SniperSight_Update2 =
{
	//bprint(PRINT_HIGH, "Sight Think..\n");
	local vector org;

	if (!(self.owner.tfstate & TFSTATE_RL_LASER) || (self.owner.current_weapon != WEAP_ROCKET_LAUNCHER))
	{
		self.owner.tfstate &= ~TFSTATE_RL_LASER;
		TeamFortress_SetSpeed(self.owner);
		self.owner.heat = 0;
		dremove(self);
		return;
	}

    makevectors(self.owner.v_angle);

	org = self.owner.origin + v_forward*10;
	org.z = self.owner.absmin.z + self.owner.size.z * 0.7;

    traceline (org, org + v_forward*9192, FALSE, self);

    if (trace_fraction == 1.0)
	{
       	setorigin(self, self.owner.origin );
		return;
	}

	self.angles = vectoangles(v_forward);
    setorigin(self, trace_endpos);

	self.nextthink = time + 0.1;
};

//=========================================================================
// Create the sight
//CH type 1 = rl
void(float type) SniperSight_Create =
{
	local entity sight;
	if (type == 1)
		self.tfstate |= TFSTATE_RL_LASER;
	else
		self.tfstate |= TFSTATE_AIMING;

	sight = spawn ();
	sight.owner = self;
	sight.movetype = MOVETYPE_NOCLIP;
	sight.solid = SOLID_NOT;
	sight.v_angle = self.v_angle;

	setmodel (sight, "progs/sight.spr");

	sight.classname = "timer";

	setorigin(sight, self.origin);
	if (type == 1)
		sight.think = SniperSight_Update2;
	else
		sight.think = SniperSight_Update;
	sight.nextthink = time + 0.05;
};

// this toggles the snipers autozoom on/off
void() TeamFortress_AutoZoomToggle =
{
	if (self.tfstate & TFSTATE_ZOOMOFF)
	{
		self.tfstate &= ~TFSTATE_ZOOMOFF;
		sprint(self, PRINT_HIGH, "autozoom ON\n");
	}
	else
	{
		self.tfstate |= TFSTATE_ZOOMOFF;
		sprint(self, PRINT_HIGH, "autozoom OFF\n");
	}

};



//=========================================================================
