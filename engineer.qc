/*======================================================
	ENGINEER.QC			Custom TeamFortress v3.1	

	(c) TeamFortress Software Pty Ltd 	2/3/97
	(c) William Kerney			4/14/00
	(c) Craig Hauser				4/14/00
========================================================
Weapons and functions for the ENGINEER class and associated weaponry
=======================================================*/

#include "defs.qh"
#include "menu.qh"

float modelindex_tesla; //CH
// Weapon Functions
void() LaserBolt_Touch;
void() LaserBolt_Think;
void() W_FireLaser;

// EMP Grenade Functions
void() EMPExplode;
void() EMPGrenadeTouch;
void() EMPGrenadeExplode;

// Building Functions
void() TeamFortress_EngineerBuild;
void(float objtobuild) TeamFortress_Build;
void() TeamFortress_FinishedBuilding;
void() T_Dispenser;
void(entity atk, float dmg) Dispenser_Pain;
void() Dispenser_Die;
void(entity disp) Engineer_UseDispenser;
void(entity gun) Engineer_UseSentryGun;
void(entity cam) Engineer_UseCamera;
void() CheckDistance;
//WK
void() Sentry_Touch;
float(float myteam) HasFlag;

//- OfN
void(entity field) Field_Built;

//=========================================================================
// Laserbolt think function
// Previously on crack
// No longer used
#if 0
void() LaserBolt_Think =
{
	if (time > self.heat) {
		if (self.demon_one)
			dremove(self.demon_one);
		dremove(self);	
		return;
	}	

	self.velocity = self.mangle;
	setorigin (self, self.oldorigin + normalize (self.mangle));

	self.nextthink = self.heat;
	self.think = SUB_Remove;
};
#endif

// New railgun think function, needed to work right :/
void() LaserBolt_Think =
{
	if (time > self.heat) {
		dremove (self);
		return;
	}

	setorigin (self, self.oldorigin);
	setmodel (self, self.mdl);
	self.velocity = self.mangle;
};

//=========================================================================
// Laserbolt touch function. Just moves through the player and comes out
// the other side.
void() LaserBolt_Touch =
{
	local vector org;
	
	if (time > self.heat) {
		dremove (self);	
		return;
	}

	if (pointcontents(self.origin) == CONTENTS_SKY) {
		dremove (self);
		return;
	}

	self.owner = other; // I understand this now

	if (other == self.real_owner)
		return;

	if (other.classname == "force_field") { // ff can block rails, but not easily, loses cells
		other.demon_one.ammo_cells -= 5;
		other.demon_two.ammo_cells -= 5;
		
		if (other.demon_one.ammo_cells < 0)
			other.demon_one.ammo_cells = 0;
		if (other.demon_two.ammo_cells < 0)
			other.demon_two.ammo_cells = 0;

		FieldExplosion (other, self.origin, self);
		PutFieldWork (other);
		dremove (self);
		return;
	}

	//WK Sweep mines at point of impact
	GuerillaMineSweep(self.origin);

	org = self.origin - 8*normalize(self.velocity);

	if (other && other.takedamage)
	{
		local float armorsave = other.armortype;
		SpawnBlood (org, 15);
		deathmsg = DMSG_LASERBOLT;
		other.armortype *= 0.33;
		TF_T_Damage (other, self, self.real_owner, 50, 0, TF_TD_NAIL); // was electricity... WTF?
		if (other.armortype)
			other.armortype = armorsave;
		self.mdl = "progs/e_spike2.mdl";
	}

	self.think = LaserBolt_Think;
	self.nextthink = time + 0.1;
	self.oldorigin = self.origin + normalize (self.velocity);

	setmodel (self, "");
};

//=========================================================================
// Fire a laserbolt
void() W_FireLaser =
{
	local	vector	vec, org;

	self.currentammo = self.ammo_nails = self.ammo_nails - 1;

	makevectors(self.v_angle);
	org = self.origin + (v_forward * 8);
	vec = aim(self, 10000);
	vec = normalize(vec);
		
	newmis = spawn();
	newmis.owner = self;
	newmis.real_owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_TRIGGER;
	newmis.mdl = "progs/e_spike1.mdl";

	setmodel (newmis, newmis.mdl);
	setsize (newmis, '0 0 0', '0 0 0');		

	setorigin (newmis, org + '0 0 16');

	newmis.mangle = vec*300;
	newmis.velocity = newmis.mangle;
	newmis.angles = vectoangles(newmis.velocity);

	newmis.heat = time + 5;
	newmis.nextthink = time + 5;
	newmis.think = SUB_Remove;

	newmis.touch = LaserBolt_Touch;
};

//=========================================================================
// Ammo/Weapon exploded by the EMP grenade
void() EMPExplode =
{
	local float expsize;

	expsize = 10;
	// Weapon?

	if (self.touch == weapon_touch)
		expsize = 60;
	else if (self.classname == "item_shells")
		expsize = 50 + self.aflag;
	else if (self.classname == "item_spikes")
		expsize = 40;
	else if (self.classname == "item_rockets")
		expsize = 100 + (self.aflag * 4);
	else if (self.classname == "item_cells")
		expsize = 100 + (self.aflag * 3);
	else if (self.classname == "item_weapon")
		expsize = 60;
	else
	{
		RPrint("EMPExplode: Attempting to explode a ");
		RPrint(self.classname);
		RPrint("\n");
		return;
	}

	deathmsg = DMSG_GREN_EMP_AMMO;
	T_RadiusDamage (self, self.enemy, expsize, NIL);

	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_EXPLOSION);
	WriteCoord (MSG_MULTICAST, self.origin_x);
	WriteCoord (MSG_MULTICAST, self.origin_y);
	WriteCoord (MSG_MULTICAST, self.origin_z);
	multicast (self.origin, MULTICAST_PHS);

	// Respawn
	Respawn_Item(self, self.enemy);
};

//=========================================================================
// Touch Function for EMP Grenade
void() EMPGrenadeTouch =
{
	// If the EMP Grenade hits a player, it just bounces off
	sound (self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM);
	if (self.velocity == '0 0 0')
		self.avelocity = '0 0 0';
};

//=========================================================================
// EMP Scrambling effect (on players and buildings
void() EMPScramble =
{
#if 0
	te = findradius(self.origin, 500);
	
	while (te)
	{
		local float dist = vlen(te.origin - self.origin);	
		local float mult = 0.25 + (0.65 * dist / 500) + 0.15 * random();

		te = te.chain;
	}
#endif
	dremove(self);
};

//=========================================================================
// EMP Grenade explode function, for when the PRIMETIME runs out
void() EMPGrenadeExplode =
{
	local float expsize;
	local entity te, oldself;
	local float total_exp;
	local float dist, mult;
//CH Slice gave idea of an emp gren getting rated based on blast so i added..
	total_exp = 0;
	local float range = 300;
	local float dmg = 0.8;

	local float numcells = 0;
	local float numrockets = 0;
	local float numshells = 0;
	local float numgren1 = 0;
	local float numgren2 = 0;

	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_TAREXPLOSION);
	WriteCoord (MSG_MULTICAST, self.origin_x);
	WriteCoord (MSG_MULTICAST, self.origin_y);
	WriteCoord (MSG_MULTICAST, self.origin_z);
	multicast (self.origin, MULTICAST_PHS);

	// Find all ammo in the area
	te = findradius(self.origin, range); // was 240

	local entity head = te;

	while (te)
	{
		te.chain2 = te.chain;
		te = te.chain2;
	}

	te.chain2 = NIL;
	te = head;

	while (te)
	{	
		dist = vlen(self.origin - te.origin);
		mult = 0.90 - (0.75 * dist / range) + (0.10 * random());
		mult *= dmg;
		numshells = numcells = numrockets = numgren1 = numgren2 = expsize = 0;

		if (IsBuilding(te))
		{
			if (te.num_mines & IMPROVED_THREE)
				mult *= 0.5;
			else
				mult *= 0.8;
		}

		if (mult > 1) mult = 1;
		else if (mult < 0) mult = 0;


        	if (te.touch == ammo_touch || te.touch == weapon_touch) // Ammo/Weapon?
		{
			// Make sure it isn't picked up in the next second
			te.solid = SOLID_NOT;
			te.enemy = self.owner;
			te.nextthink = time + 1 + (random() * 2);
			te.think = EMPExplode;
		}
		// Detpack?
		else if (te.think == TeamFortress_DetpackExplode)
		{
			//te.solid = SOLID_NOT;
			te.nextthink = time + 1 + 120 * mult*mult; //chance of either exploding or lengthening timer
			
			dremove(te.oldenemy); // Countdown ent
		}
		// Pipebomb?
		else if (te.classname == "pipebomb")
		{
			te.nextthink = time + 0.1 + random();
		}
		// Mine/grenade?
		else if (te.classname == "grenade")
		{
			if (te.netname == "land_mine")
				te.think = GuerillaExplode;
			te.nextthink = time + 0.1 + random();
		}
		// Ammobox?
		else if (te.classname == "ammobox")
		{
			expsize = 0;
			expsize = expsize + (te.ammo_rockets * 3);
			expsize = expsize + (te.ammo_cells * 1.5);
			expsize += expsize * te.ammo_shells / 500;

			if (expsize > 0)
			{
				te.solid = SOLID_NOT;
				
				// Damage player and explode
				deathmsg = DMSG_GREN_EMP;
				total_exp = total_exp + expsize;
				if (expsize > 500)
					expsize = 500;

				T_RadiusDamage(te, self.owner, expsize, te);

				te.think = SUB_Remove;
				te.nextthink = time + 0.1;

				WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
				WriteByte (MSG_MULTICAST, TE_EXPLOSION);
				WriteCoord (MSG_MULTICAST, te.origin_x);
				WriteCoord (MSG_MULTICAST, te.origin_y);
				WriteCoord (MSG_MULTICAST, te.origin_z);
				multicast (te.origin, MULTICAST_PHS);
			}
		}
		// Backpack/Player/Building?
		else if ((te.classname == "player") || (te.classname=="monster_army") || (te.touch == BackpackTouch)
			|| IsBuilding(te))
		{

			if (te.touch == BackpackTouch)
			{
				numcells = te.ammo_cells;
				numrockets = te.ammo_rockets;
			}
			else
			{
				numcells = te.maxammo_cells * mult;
				numrockets = te.maxammo_rockets * mult;				

				if (numcells > te.ammo_cells)
					numcells = te.ammo_cells;
				if (numrockets > te.ammo_rockets)
					numrockets = te.ammo_rockets;
	
				if (te.weapons_carried & WEAP_SPANNER && te.classname == "player")
					numcells = 0;
			}

			numcells = floor(numcells);
			numrockets = floor(numrockets);

			expsize = 0;
			// calculate explosion size
			expsize = numcells * 1.5 + numrockets * 3; // ouch, this hurts

			if (te.classname == "player")
			{
				numgren1 = numgren2 = floor(3 * mult);

				if (numgren1 > te.no_grenades_1)
					numgren1 = te.no_grenades_1;
				if (numgren2 > te.no_grenades_2)
					numgren2 = te.no_grenades_2;

				if (te.tp_grenades_1 == GR_TYPE_MIRV)
					expsize += numgren1 * 50; // arggh, lots of damage
				if (te.tp_grenades_2 == GR_TYPE_MIRV)
					expsize += numgren2 * 50; // gotta get hwguys somehow
			}

			if (te.classname == "player" && (te.is_detpacking || te.is_toffingadet))
				expsize += 500;

			if (expsize < 500 && te.touch != BackpackTouch)
				numshells = te.ammo_shells * expsize / 500;
			else
				numshells = te.ammo_shells;

			numshells = floor(numshells);

			expsize += numshells * 1.5;
	
			if (expsize > 0)
			{
				// Damage player and explode
				deathmsg = DMSG_GREN_EMP_RADIUS;
				total_exp = total_exp + expsize;
				//WK Make players not explode radially! GR why not?
				if (te.touch != BackpackTouch)
				{
					T_RadiusDamage(te, self.owner, expsize / 2, te);
					
					deathmsg = DMSG_GREN_EMP;
					TF_T_Damage (te, te, self.owner, expsize, 0, TF_TD_EXPLOSION);

					// Remove ammo
					te.ammo_cells -= numcells;
					te.ammo_rockets -= numrockets;
					te.ammo_shells -= numshells;

					if (te.classname == "player")
					{
						if (te.tp_grenades_1 == GR_TYPE_MIRV)
							te.no_grenades_1 -= numgren1;
						if (te.tp_grenades_2 == GR_TYPE_MIRV)
							te.no_grenades_2 -= numgren2;
					
					// Update console
						oldself = self;
						self = te;
						W_SetCurrentAmmo();
						self = oldself;
  					}                      
				
        				WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
					WriteByte (MSG_MULTICAST, TE_EXPLOSION);
					WriteCoord (MSG_MULTICAST, te.origin_x);
					WriteCoord (MSG_MULTICAST, te.origin_y);
					WriteCoord (MSG_MULTICAST, te.origin_z);
					multicast (te.origin, MULTICAST_PHS);
				}
				else
				{
					T_RadiusDamage(te, self.owner, expsize, te);

					if (te.classname != "player")
					{
						te.think = SUB_Remove;
						te.nextthink = time + 0.1;
					}
				}

				WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
				WriteByte (MSG_MULTICAST, TE_EXPLOSION);
				WriteCoord (MSG_MULTICAST, te.origin_x);
				WriteCoord (MSG_MULTICAST, te.origin_y);
				WriteCoord (MSG_MULTICAST, te.origin_z);
				multicast (te.origin, MULTICAST_PHS);
			}
		}

		te = te.chain2;
	}

	sound (self, CHAN_WEAPON, "weapons/gren_emp.wav", 1, ATTN_NORM); //- OfN - cool sound! :)

if (total_exp > 0) {//CH Thanks Slice for the idea :)

    sprint(self.owner,PRINT_HIGH, "Your EMP grenade inflicted ");
	local string st;
	st = ftos(total_exp);
	sprint(self.owner,PRINT_HIGH, st);
	sprint(self.owner,PRINT_HIGH, " damage\n");
}

#ifdef DEMO_STUFF
	// Remove any camera's locks on this missile
	if (self.enemy)
		CamProjectileLockOff();
#endif

	self.nextthink = time + 0.5;
	self.think = EMPScramble;

	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	setmodel(self, "");
	setorigin(self, self.origin);
};


//=========================================================================
// Tests whether a team is allowed to build or not

float(float myteam) HasFlag =
{
	
	if ( mapname != "steal4d" )
		return TRUE;
	
	if (myteam == team_with_flag){	
		return TRUE;
		}
	return FALSE;	
};

//=========================================================================
// Function handling the Engineer's build impulse
void() TeamFortress_EngineerBuild =
{
	local entity te;
	
	// Can't build in the air
	// WK Yes you can, why not? You can do it by pulling up this menu anyway
	/*
	if (!(self.flags & FL_ONGROUND))
	{
		CenterPrint(self, "You can't build in the air!\n\n");
		return;
	}
	*/
	


	if (self.is_detpacking == 1) {
		CenterPrint(self, "You can't build while detpacking\n");
		return;		
	}

	if (self.is_feigning == 1) {
		CenterPrint(self, "You can't build while feigning\n");
		return;		
	}

	// Pop up the menu
	if (self.is_building == 0)
	{
		// Check to see if they've got enuf metal to build anything
		if (self.ammo_cells < BUILD_COST_CAMERA && self.has_dispenser == FALSE && self.has_sentry == FALSE && self.has_tesla == FALSE && self.has_camera == FALSE && self.has_teleporter == FALSE && self.has_sensor == FALSE && self.has_fieldgen == FALSE)
		{
			CenterPrint(self, "You don't have enough metal to \nbuild anything.\n\n");
			return;
		}

		self.current_menu = MENU_ENGINEER;
		self.menu_count = MENU_REFRESH_RATE;
	}
	else if (self.is_building == 1)	
	{
		sprint(self, PRINT_HIGH, "You stop building.\n");

		self.is_building = 0;
		self.tfstate &= ~TFSTATE_CANT_MOVE;

		TeamFortress_SetSpeed(self);

		// Remove the timer
		te = find(NIL, netname, "build_timer");
		while (te)
		{
			if (te.owner == self)
			{
				dremove(te);
				te = NIL;
			}
			else
			{
				te = find(te, netname, "build_timer");
			}
		}

		self.current_weapon = self.weapon;
		W_SetCurrentAmmo();
	}
};

float(entity obj, entity builder) CheckArea =
{
	local integer pos;

	// Check the hull
	pos = entpointcontents(obj);
	if (pos == CONTENTS_SOLID || pos == CONTENTS_SKY)
		return FALSE;

	// Trace a line from the player to the object too
	traceline(builder.origin, obj.origin, TRUE, builder);

	if (trace_fraction != 1)
		return FALSE;

	// may add in more checks later

	return TRUE;
};

//////////////////////////////////////////////////////////////////////////
// rehashed version of TF_Build 
void(float objtobuild) TeamFortress_Build =
{
	local float btime = time - 0.1;
	local entity obj;

	obj = spawn();

	// get an origin
	makevectors(self.v_angle);
	v_forward_z = 0;
	v_forward = normalize(v_forward);

	obj.origin = self.origin + v_forward * 35;

	//WK Cheat Fix
	if (self.is_feigning) {
			sprint(self, PRINT_HIGH, "Try standing up first.\n");
			return;
	}

    //OfN - Cheat Fix, heh
	if (self.is_haxxxoring) {
			sprint(self, PRINT_HIGH, "You can't build while hacking.\n");
			return;
	}

	if (objtobuild == BUILD_DISPENSER)
	{
		if (self.has_dispenser)
		{
			sprint(self, PRINT_HIGH, "You can only have one dispenser.\nTry dismantling your old one.\n");
			return;
		}
		if (!(self.cutf_items & CUTF_DISPENSER))
		{
			sprint(self, PRINT_HIGH, "You must buy the dispenser before you can build it.\n");
			return;
		}
		if (self.ammo_cells < BUILD_COST_DISPENSER) {
			sprint (self, PRINT_HIGH, "Not enough cells.\n");
			return;
		}

		obj.mins = '-8 -8 0';
		obj.maxs = '8 8 40';

        #ifdef no_new_dispenser
        obj.mdl = "progs/disp.mdl";        
        #else
        obj.mdl = "progs/disp2.mdl";
        #endif
		
        obj.netname = "dispenser";

		btime = time + BUILD_TIME_DISPENSER;
	}
	else if (objtobuild == BUILD_SENTRYGUN)
	{
		if (self.has_sentry)
		{
			sprint(self, PRINT_HIGH, "You can only have one sentry gun.\nTry dismantling your old one.\n");
			return;
		}
		if (!(self.cutf_items & CUTF_SENTRYGUN))
		{
			sprint(self, PRINT_HIGH, "You must buy a sentrygun before you can build one.\n");
			return;
		}
		if (self.ammo_cells < BUILD_COST_SENTRYGUN) {
			sprint (self, PRINT_HIGH, "Not enough cells.\n");
			return;
		}

		obj.mins = '-16 -16 0';
		obj.maxs = '16 16 48';
		//obj.mdl = "progs/turrbase.mdl"; 
        obj.mdl = "progs/trrbs2.mdl";
		obj.netname = "sentrygun";
	
		btime = time + BUILD_TIME_SENTRYGUN;
	}
	else if (objtobuild == BUILD_TESLA)
	{
		if (self.has_tesla)
		{
			sprint(self, PRINT_HIGH, "You can only have one tesla gun.\nTry dismantling your old one.\n");
			return;
		}
		if (!(self.tf_items & NIT_TESLA))
		{
			sprint(self, PRINT_HIGH, "You must buy a tesla sentry before you can build one.\n");
			return;
		}
		if (self.ammo_cells < BUILD_COST_TESLA) {
			sprint (self, PRINT_HIGH, "Not enough cells.\n");
			return;
		}


//		obj.mins = '-16 -16 0'; //- OfN commented by
        obj.mins = '-16 -16 -25';
//		obj.maxs = '16 16 48'; //WK 62 is better, but crashes?
        obj.maxs = '16 16 48';
		//obj.mdl = "progs/newtesla.mdl";
        obj.mdl = "progs/coil.mdl";
		obj.netname = "tesla";
//        obj.origin = obj.origin + '0 0 25';
        
	
		btime = time + BUILD_TIME_TESLA;
	}
	else if (objtobuild == BUILD_SECURITY_CAMERA)
	{
		if (self.has_camera)
		{
			sprint(self, PRINT_HIGH, "You can only have one security camera.\nTry dismantling your old one.\n");
			return;
		}
		if (!(self.tf_items & NIT_SECURITY_CAMERA))
		{
			sprint(self, PRINT_HIGH, "You must buy a security camera before you can build one.\n");
			return;
		}
		Security_Camera_Spawn();
	}
	else if (objtobuild == BUILD_TELEPORTER)
	{
		if (self.has_teleporter >= 2)
		{
			sprint(self, PRINT_HIGH, "You can only have 2 teleporters.\nTry dismantling an old one.\n");
			return;
		}
		if (!(self.tf_items & NIT_TELEPORTER))
		{
			sprint(self, PRINT_HIGH, "You must buy a teleporter before you can build one.\n");
			return;
		}
		if (self.ammo_cells < BUILD_COST_TELEPORTER) {
			sprint (self, PRINT_HIGH, "Not enough cells.\n");
			return;
		}


		obj.mins = '-16 -16 0';
		obj.maxs = '16 16 4';
		obj.mdl = "progs/telepad.mdl";
		obj.netname = "teleporter";
	
		btime = time + BUILD_TIME_TELEPORTER;
	}
    else if (objtobuild == BUILD_FIELDGEN)
	{
		if (self.has_fieldgen >= 2)
		{
			sprint(self, PRINT_HIGH, "You already have 2 field generators.\nTry dismantling an old one.\n");
			return;
		}
		if (!(self.cutf_items & CUTF_FIELDGEN))
		{
			sprint(self, PRINT_HIGH, "You must buy a field generator before you can build one.\n");
			return;
		}
		if (self.ammo_cells < BUILD_COST_FIELDGEN) {
			sprint (self, PRINT_HIGH, "Not enough cells.\n");
			return;
		}


		obj.mins = '-6 -6 0';
		obj.maxs = '6 6 54';
		obj.mdl = "progs/ffgen2.mdl";
		obj.netname = "field generator";
	
		btime = time + BUILD_TIME_FIELDGEN;
	}
	
	if (objtobuild == BUILD_SECURITY_CAMERA)
		return;

	local vector startpos, endpos;

	startpos = obj.origin;
	startpos_z = self.absmin_z - obj.mins_z + 60;

	// build right up against the wall if there's a wall there
	checkmove(startpos, obj.mins, obj.maxs, startpos + v_forward*30, MOVE_NORMAL, obj);

	RPrint ("Builder origin: " + vtos(self.origin) + "\n");
	RPrint ("First checkmove: ");
	printtrace( 1 );
	RPrint ("Distance from builder: ");
	RPrint (ftos(vlen(trace_endpos - self.origin)));
	RPrint ("\n");

	startpos = trace_endpos;

	endpos = obj.origin;
	endpos_z = self.absmin_z - obj.mins_z - 40;

	checkmove(startpos, obj.mins, obj.maxs, endpos, MOVE_NORMAL, obj);

	RPrint("Second checkmove: ");
	printtrace( 1 );
	RPrint("Distance from builder: ");
	RPrint(ftos(vlen(trace_endpos - self.origin)));
	RPrint("\n");

	if (trace_fraction == 1 && !trace_allsolid) {
		sprint (self, PRINT_HIGH, "No buildable surfaces\n");
		dremove (obj);
		return;
	}

	if (trace_allsolid || trace_fraction == 0) {
		sprint (self, PRINT_HIGH, "Not enough room to build\n");
		dremove (obj);
		return;
	}

	if (trace_ent.classname == "force_field") // make it collide with ff
		trace_endpos_z--;

	obj.origin = trace_endpos;
	obj.flags |= FL_ONGROUND;
	obj.movetype = MOVETYPE_TOSS;

#ifdef		DISALLOW_BLOCKED_TELE
	if (objtobuild == BUILD_TELEPORTER) {
		checkmove (obj.origin + '0 0 32', '-16 -16 -24', '16 16 32',
				   obj.origin + '0 0 30', MOVE_NOMONSTERS, self);
		if (trace_startsolid || trace_fraction != 1) {
			sprint (self, PRINT_HIGH, "Not enough room for teleportation\n");
			dremove (obj);
			return;
		}
	}
#endif

        obj.owner = self;
        obj.classname = "timer";
        obj.netname = "build_timer";
        obj.nextthink = btime;
        obj.think = TeamFortress_FinishedBuilding;
        obj.colormap = self.colormap;
        obj.weapon = objtobuild;
        obj.angles_y = anglemod(self.angles_y + 180);

        obj.solid = SOLID_BBOX;
        setmodel (obj, obj.mdl);
        setsize (obj, obj.mins, obj.maxs);
        setorigin (obj, obj.origin);

#ifdef DISALLOW_BLOCKED_TELE
	if (objtobuild == BUILD_TELEPORTER)
		if (Teleporter_CheckBlocked (obj)) {
			sprint (self, PRINT_HIGH, "Not enough room for teleportation.\n");
			dremove (obj);
			return;
		}
#endif

        if (objtobuild==BUILD_TESLA)
        {
            obj.skin = self.team_no;
            if (self.team_no==3) obj.skin=0;
            else if (self.team_no==4) obj.skin=3;
        }

        self.is_building = 1;
        makeImmune(self,time + 2);
        //self.immune_to_check = time + 2;
        self.tfstate |= TFSTATE_CANT_MOVE;

        // Save the current weapon and remove it
        self.weapon = self.current_weapon;
        self.current_weapon = 0;
        self.weaponmodel = "";
        self.weaponframe = 0;

        TeamFortress_SetSpeed(self);

	if (objtobuild == BUILD_FIELDGEN)
		WhereGen(obj.origin);
};

void() DispenserThink =
{
    local float iI; // is Improved?

    iI=1;
    
    if (self.num_mines & IMPROVED_ONE)
        iI=2;


    // dispenser refilling itself 5%
	if (!(self.is_malfunctioning & SCREWUP_THREE)) // SB
	{
		self.ammo_shells = self.ammo_shells + rint((BUILD_DISPENSER_MAX_SHELLS*iI) / 10);
		self.ammo_cells = self.ammo_cells + rint((BUILD_DISPENSER_MAX_CELLS*iI) / 10);
		self.ammo_nails = self.ammo_nails + rint((BUILD_DISPENSER_MAX_NAILS*iI) / 10);
		self.ammo_rockets = self.ammo_rockets + rint((BUILD_DISPENSER_MAX_ROCKETS*iI) / 10);
		self.armorvalue = self.armorvalue + rint((BUILD_DISPENSER_MAX_ARMOR*iI) / 10);	

		if (self.ammo_shells > BUILD_DISPENSER_MAX_SHELLS*iI)
			self.ammo_shells = BUILD_DISPENSER_MAX_SHELLS*iI;	
		if (self.ammo_nails > BUILD_DISPENSER_MAX_NAILS*iI)
			self.ammo_nails = BUILD_DISPENSER_MAX_NAILS*iI;	
		if (self.ammo_rockets > BUILD_DISPENSER_MAX_ROCKETS*iI)
			self.ammo_rockets = BUILD_DISPENSER_MAX_ROCKETS*iI;	
		if (self.ammo_cells > BUILD_DISPENSER_MAX_CELLS*iI)
			self.ammo_cells = BUILD_DISPENSER_MAX_CELLS*iI;	
		if (self.armorvalue > BUILD_DISPENSER_MAX_ARMOR*iI)
			self.armorvalue = BUILD_DISPENSER_MAX_ARMOR*iI;	
	}
	self.nextthink = time + 10;
};

void() TeamFortress_FinishedBuilding =
{
	local entity oldself;

	if (self.owner.is_building != 1)
		return;

	oldself = self;
	self = self.owner;
	oldself.owner = NIL;
	oldself.real_owner = self;

	self.is_building = 0;
	self.tfstate &= ~TFSTATE_CANT_MOVE;
	self.current_weapon = self.weapon;
	self.StatusRefreshTime = time + 0.1;

	TeamFortress_SetSpeed(self);

	if (oldself.weapon == BUILD_DISPENSER)
	{
		self.has_dispenser = TRUE;
		sprint (self, PRINT_HIGH, "You finish building the dispenser.\n");

        teamprefixsprint(self.team_no,self); //- OfN

        teamsprint(self.team_no, self, self.netname);
		teamsprint(self.team_no, self, " has built a Dispenser.\n");

		self.ammo_cells = self.ammo_cells - BUILD_COST_DISPENSER;
		
		// Create the dispenser
		oldself.classname = "building_dispenser";
		oldself.netname = "dispenser";
		oldself.blocked = T_Dispenser;		// Actual touch function
		oldself.touch = T_Dispenser;
		oldself.max_health = BUILD_HEALTH_DISPENSER;
		oldself.health = BUILD_HEALTH_DISPENSER;
		oldself.think = DispenserThink;
		oldself.nextthink = time + 5;
		oldself.th_die = Dispenser_Die;		// Death function
		oldself.th_pain = Dispenser_Pain;		

        #ifdef no_new_dispenser
        oldself.mdl = "progs/disp.mdl";		// Actual mdl
        #else
        oldself.mdl = "progs/disp2.mdl";		// Actual mdl
        #endif
        
		oldself.team_no = self.team_no;

        oldself.num_mines=0; // OfN - reset HACKER improvements

		oldself.real_owner = self;			// The Engineer owns this item
		oldself.colormap = self.colormap;	// Set the Color
		oldself.takedamage = DAMAGE_AIM;
		oldself.owner = NIL;

		// Put some ammo in the Dispenser
		oldself.ammo_shells = ceil(self.ammo_shells * 0.25);
		oldself.ammo_nails = ceil(self.ammo_nails * 0.25);
		oldself.ammo_rockets = ceil(self.ammo_rockets * 0.25);
		oldself.ammo_cells = ceil(self.ammo_cells * 0.25);
		oldself.armorvalue = ceil(self.armorvalue * 0.25);

		// Remove ours
		self.ammo_shells = ceil(self.ammo_shells * 0.75);
		self.ammo_nails = ceil(self.ammo_nails * 0.75);
		self.ammo_rockets = ceil(self.ammo_rockets * 0.75);
		self.ammo_cells = ceil(self.ammo_cells * 0.75);
		self.armorvalue = ceil(self.armorvalue * 0.75);

		oldself.solid = SOLID_BBOX;
		setmodel(oldself, oldself.mdl);
	}
	else if (oldself.weapon == BUILD_SENTRYGUN)
	{
		//CH special sbar for eng.
		self.StatusBarScreen = 1;
		self.has_sentry = TRUE;
		sprint (self, PRINT_HIGH, "You finish building the sentry gun.\n");

        teamprefixsprint(self.team_no,self); //- OfN

        teamsprint(self.team_no, self, self.netname);
		teamsprint(self.team_no, self, " has built a Sentry Gun.\n");
			
		oldself.classname = "building_sentrygun_base";
		oldself.netname = "sentry gun";
		oldself.takedamage = 0;
		oldself.th_die = Sentry_Die; 		// Death function
		self.ammo_cells = self.ammo_cells - BUILD_COST_SENTRYGUN;

		setsize (oldself, '-16 -16 0', '16 16 4'); // '-16 -16 0' '16 16 4'
		newmis = spawn();
		newmis.classname = "building_sentrygun";
		newmis.health = BUILD_HEALTH_SENTRYGUN;
		newmis.max_health = newmis.health;
		newmis.tf_items = NIT_KEVLAR; //Start with kevlar armor
		newmis.armorclass = AT_SAVESHOT; //kevlar armor
		newmis.weapon = 1;					// Level 1 Turret
		newmis.th_die = Sentry_Die;			// Death function
		newmis.th_pain = Sentry_Pain;
		//newmis.mdl = "progs/turrgun.mdl";
        newmis.mdl = "progs/trrgn2.mdl";
		sound (oldself, CHAN_ITEM, "weapons/turrset.wav", 1, ATTN_NORM);
		newmis.solid = SOLID_BBOX;
		setmodel(newmis, newmis.mdl);
		setsize (newmis, '-16 -16 4', '16 16 48'); //don't make it encompass the base
		setorigin(newmis, oldself.origin + '0 0 8'); 
		newmis.real_owner = oldself.real_owner;	// The Engineer owns this item
		newmis.trigger_field = oldself;
		oldself.oldenemy = newmis;
		newmis.movetype = MOVETYPE_STEP;
		oldself.colormap = self.colormap;	// Set the Base Color
		newmis.colormap = self.colormap;	// Set the Color

        newmis.skin = self.team_no - 1;

		newmis.takedamage = DAMAGE_AIM;
		newmis.velocity = '0 0 -8';

		newmis.frags = 0; //CH how many people has your sent killed?

		newmis.team_no = self.team_no;
		newmis.think = lvl1_sentry_stand;
		newmis.nextthink = time + 0.5;
		newmis.touch = Sentry_Touch;
		// Rotate Details
		newmis.yaw_speed = 10;  //Turn rate
		newmis.heat = 0;	// Turn Right
		newmis.angles_x = 0;
		newmis.angles_y = ceil(oldself.angles_y); //CH remove decimal
		newmis.angles_z = 0;

		newmis.angles_y = ((ceil(newmis.angles_y / 10)) * 10); //CH set last int to 0
		newmis.waitmin = anglemod(newmis.angles_y - 50);
		newmis.waitmax = anglemod(newmis.angles_y + 50);

		// Give the Gun some ammo
		newmis.ammo_shells = 75; //WK
		newmis.maxammo_shells = 100;
		newmis.maxammo_rockets = 20;

        newmis.num_mines=0; // OfN - reset HACKER improvements
        newmis.attack_finished=time; //- controls time after loosing track of enemy to not be rotating
        newmis.has_holo=0;

	}
	else if (oldself.weapon == BUILD_TESLA)
	{
		//CH special sbar for eng.
		self.StatusBarScreen = 4;
		self.has_tesla = TRUE;
		sprint (self, PRINT_HIGH, "You finish building the tesla.\n");

        teamprefixsprint(self.team_no,self); //- OfN
        
        teamsprint(self.team_no, self, self.netname);
		teamsprint(self.team_no, self, " has built a tesla.\n");
		sound (oldself, CHAN_ITEM, "weapons/guerilla_set.wav", 1, ATTN_NORM);
			
		oldself.classname = "building_tesla";
		oldself.netname = "tesla";
		oldself.takedamage = DAMAGE_AIM;
		oldself.solid = SOLID_BBOX;
		oldself.th_die = Tesla_Die; 		// Death function
		oldself.th_pain = Tesla_Pain;
		self.ammo_cells = self.ammo_cells - BUILD_COST_TESLA;

		oldself.health = BUILD_HEALTH_TESLA;
		oldself.movetype = MOVETYPE_TOSS;
		oldself.colormap = self.colormap;	// Set the Base Color
		oldself.team_no = self.team_no;
		
        //- OfN -
        //oldself.think = Tesla_Idle;
        oldself.think = tsla_on1;
		//oldself.nextthink = time + 2;
        oldself.nextthink = time + 0.1;
        oldself.has_holo = time + 2; // next Tesla_Idle run
        oldself.job = 0; // this flag will determine which frame animation is currently on
        //oldself.job_finished = time; // change for frame animation purposes, instead of increasing its nextthing during charging
        oldself.no_grenades_1 = FALSE; // first think reset
        oldself.no_grenades_2 = 0; // cloak touch delay reset

		oldself.touch = Tesla_Touch;
		oldself.enemy = NIL;
		oldself.oldenemy = NIL; //CH for sbar

		//Set all initial tesla values here
		oldself.maxammo_shells = 0; //Voltage == 0
		oldself.maxammo_nails = 0; //Amps == 0
		oldself.maxammo_rockets = 0; //Battery == 0
		oldself.max_health = 150;
		oldself.ammo_cells = MAXCELLS0; //Initial ammo allocation
		oldself.maxammo_cells = MAXCELLS0; //Initial maxammo
		oldself.tf_items = NIT_CERAMIC; //Start with shock armor
		oldself.armorclass = AT_SAVEELECTRICITY; //Shock armor
		if (self.tf_items & NIT_TESLA_UPGRADE) {
			oldself.has_sentry = 6; //Normal Upgrades
			oldself.has_tesla = 2; //Misc Upgrade
		}
		else
		{
			oldself.has_sentry = 4; //Normal Upgrades
			oldself.has_tesla = 1; //Misc Upgrade
		}
		oldself.has_teleporter = 0; //CH for frag related upgrades
		if (!(self.weapons_carried & WEAP_SPANNER)) { //No spanner
			oldself.ammo_shells = 1;
			oldself.ammo_nails = 2;
			oldself.ammo_rockets = 1;
			oldself.has_sentry = oldself.has_sentry - 4; //Take away 3
			oldself.max_health = 225;
			oldself.ammo_cells = MAXCELLS1; //Initial ammo allocation
			oldself.maxammo_cells = MAXCELLS1;
		}
		oldself.health = oldself.max_health;
		oldself.waitmin = (oldself.ammo_shells + 2) * (oldself.ammo_nails + 2);
		oldself.waitmax = FALSE; //No target yet

		oldself.frags = 0; //CH how many people has your sent killed?
		oldself.lip   = 0; //WK How many tinkers have been done
		modelindex_tesla = oldself.modelindex; //CH

        oldself.num_mines=0; // OfN - reset HACKER improvements
        oldself.is_haxxxoring=0; // isnt flying
	}
	else if (oldself.weapon == BUILD_TELEPORTER)
	{
		self.has_teleporter = (self.has_teleporter + 1);
		sprint (self, PRINT_HIGH, "You finish building the Teleporter Pad.\n");

        teamprefixsprint(self.team_no,self); //- OfN

        teamsprint(self.team_no, self, self.netname);
		teamsprint(self.team_no, self, " has built a Teleporter Pad.\n");
		sound (oldself, CHAN_ITEM, "weapons/guerilla_set.wav", 1, ATTN_NORM);

		self.ammo_cells = self.ammo_cells - BUILD_COST_TELEPORTER;

		// Create the teleporter
		oldself.classname = "building_teleporter";
		oldself.netname = "teleporter";
//		oldself.blocked = Teleporter_touch;		// Actual touch function
		oldself.touch = Teleporter_touch;
		oldself.max_health = BUILD_HEALTH_TELEPORTER;
		oldself.health = BUILD_HEALTH_TELEPORTER;
		oldself.th_die = Teleporter_Die;		// Death function
		oldself.mdl = "progs/telepad.mdl";		// Actual mdl
		oldself.team_no = self.team_no;
		oldself.maxammo_cells = 200;	//CH Max of 20 teleports
		oldself.ammo_cells = 100;	//CH start not at full

		oldself.real_owner = self;			// The Engineer owns this item
		oldself.colormap = self.colormap;	// Set the Color
		oldself.takedamage = DAMAGE_AIM;
		oldself.owner = NIL;
		oldself.movetype = MOVETYPE_TOSS;

		oldself.solid = SOLID_BBOX;
		setmodel(oldself, oldself.mdl);
		setsize (oldself, '-16 -16 0', '16 16 4');
		setorigin(oldself, oldself.origin); //CH does jump

		oldself.heat = 4; //dont come on for 4 seconds
		oldself.think = Teleporter_heat_think;
		oldself.nextthink = time + 1;
		oldself.spawnflags = 4; //CH cause extensive checks for height

        oldself.num_mines=0; // OfN - reset HACKER improvements
	}
    else if (oldself.weapon == BUILD_FIELDGEN)
	{
		self.has_fieldgen = (self.has_fieldgen + 1);
		sprint (self, PRINT_HIGH, "You finish building the Field Generator.\n");

        teamprefixsprint(self.team_no,self); //- OfN

        teamsprint(self.team_no, self, self.netname);
		teamsprint(self.team_no, self, " has built a Field Generator.\n");
		sound (oldself, CHAN_ITEM, "weapons/guerilla_set.wav", 1, ATTN_NORM);

		self.ammo_cells = self.ammo_cells - BUILD_COST_FIELDGEN;

		// Create the teleporter
		oldself.classname = "building_fieldgen";
		oldself.netname = "field generator";
//		oldself.blocked = Teleporter_touch;		// Actual touch function
		//oldself.touch = Teleporter_touch;
		oldself.max_health = BUILD_HEALTH_FIELDGEN;
		oldself.health = BUILD_HEALTH_FIELDGEN;
		oldself.th_die = FieldGen_Die;		// Death function
		oldself.mdl = "progs/ffgen2.mdl";		// Actual mdl
		oldself.team_no = self.team_no;
		
        oldself.maxammo_cells = 100;	//CH Max of 20 field recharges
		oldself.ammo_cells = 75;	//CH start not at full*/

		oldself.real_owner = self;			// The Engineer owns this item
		oldself.colormap = self.colormap;	// Set the Color
		oldself.takedamage = DAMAGE_AIM;
		oldself.owner = NIL;
		oldself.movetype = MOVETYPE_TOSS;

		oldself.solid = SOLID_BBOX;

        setmodel(oldself, oldself.mdl);

		oldself.spawnflags = 4; //CH cause extensive checks for height

        oldself.is_malfunctioning = 0;
        oldself.num_mines=0; // OfN - reset HACKER improvements

        Field_Built(oldself);
	}

	W_SetCurrentAmmo();
};

//=========================================================================
// Dispenser Touch function. Allows players to get stuff from the Dispenser.

void() T_Dispenser =
{
	local entity dist_checker;

	if (other.classname != "player")
		return;
		
	if (self.is_malfunctioning & SCREWUP_ONE)
		return;
		
	if (self.is_malfunctioning & SCREWUP_TWO)
		TF_T_Damage(self, self, self, 200, 0, TF_TD_OTHER);

	// Ignore any engineer working on this dispenser
	if (!other.building && other.building_wait < time)
	{
		// Pop up the menu
		other.current_menu = MENU_DISPENSER;
		other.menu_count = MENU_REFRESH_RATE;

		other.building = self;

		// Start a Distance checker, which removes the menu if the player
		// gets too far away from the Dispenser.
		dist_checker = spawn();
		dist_checker.classname = "timer";
		dist_checker.owner = other;
		dist_checker.enemy = self;
		dist_checker.think = CheckDistance;
		dist_checker.nextthink = time + 0.3;
	}
};

//============================================================
// this is needed to avoid stack overflow

void() Dispenser_Explode =
{    
    T_RadiusDamage(self.demon_one, self.demon_one, self.has_holo, NIL);

    WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_EXPLOSION);
	WriteCoord (MSG_MULTICAST, self.demon_one.origin_x);
	WriteCoord (MSG_MULTICAST, self.demon_one.origin_y);
	WriteCoord (MSG_MULTICAST, self.demon_one.origin_z);
	multicast (self.demon_one.origin, MULTICAST_PHS);
    dremove(self.demon_one);

    dremove(self); // remove explosion timer for this dispenser
};

void(entity atk, float dmg) Dispenser_Pain =
{
	if (self.health < 0)
	{
		// give credit to the guy blowing up the disp
		self.martyr_enemy = atk;
		self.is_malfunctioning = 0;
	}
};

void() Dispenser_Die =
{
	local float damg;
	self.real_owner.has_dispenser = FALSE;
	
	damg = self.ammo_cells * 0.25;
	damg = damg + self.ammo_nails * 0.1;
	damg = damg + self.ammo_shells * 0.2;
	damg = damg + self.ammo_rockets / 2;
	
    //- OfN causes overflow so we need a timer for dispenser explosion
    newmis = spawn();
    newmis.has_holo = damg;
    newmis.demon_one = self;
    newmis.nextthink = time + 0.1;
    newmis.think = Dispenser_Explode;
    /*T_RadiusDamage(self, self, damg, NIL); // OfN - Fixme, stack overflow??*/


	sprint(self.real_owner, PRINT_HIGH, "Your dispenser was destroyed.\n");

	#ifdef no_new_dispenser
    ThrowGib("progs/dgib1.mdl", -30);
	ThrowGib("progs/dgib2.mdl", -50);
	ThrowGib("progs/dgib3.mdl", -50);
    #else
    ThrowGib("progs/d2gib1.mdl", -30);
	ThrowGib("progs/d2gib2.mdl", -50);
	ThrowGib("progs/d2gib3.mdl", -50);
    #endif
};

//=========================================================================
// Engineer has used a Spanner on the Dispenser
void(entity disp) Engineer_UseDispenser =
{
	local entity dist_checker;
	local string st;

	// Print the dispenser's details
	sprint (self, PRINT_HIGH, "Dispenser has ");
	st = ftos(disp.health);
	sprint(self, PRINT_HIGH, st);
    sprint(self, PRINT_HIGH, "¯");
	st = ftos(disp.max_health);
    sprint(self, PRINT_HIGH, st);
	sprint (self, PRINT_HIGH, " èåáìôè\n");
	st = ftos(disp.ammo_shells);
	sprint (self, PRINT_HIGH, st);
	sprint (self, PRINT_HIGH, " óèåììó, ");
	st = ftos(disp.ammo_nails);
	sprint (self, PRINT_HIGH, st);
	sprint (self, PRINT_HIGH, " îáéìó, ");
	st = ftos(disp.ammo_rockets);
	sprint (self, PRINT_HIGH, st);
	sprint (self, PRINT_HIGH, " òïãëåôó\n");
	st = ftos(disp.ammo_cells);
	sprint (self, PRINT_HIGH, st);
	sprint (self, PRINT_HIGH, " ãåììó, and ");
	st = ftos(disp.armorvalue);
	sprint (self, PRINT_HIGH, st);
	sprint (self, PRINT_HIGH, " áòíïò\n");

	// Pop up the menu
	self.current_menu = MENU_ENGINEER_FIX_DISPENSER;
	self.menu_count = MENU_REFRESH_RATE;

	self.building = disp;

	// Start a Distance checker, which removes the menu if the player
	// gets too far away from the Dispenser.
	dist_checker = spawn();
	dist_checker.classname = "timer";
	dist_checker.owner = self;
	dist_checker.enemy = disp;
	dist_checker.think = CheckDistance;
	dist_checker.nextthink = time + 0.3;
};

//=========================================================================
// Engineer has used a Spanner on the SentryGun
void(entity gun) Engineer_UseSentryGun =
{
	local entity dist_checker;
	local string st;

	// Print the gun's details
	sprint(self, PRINT_HIGH, "Ìåöåì ");
	st = Return_Colored_Num(gun.weapon);
	sprint(self, PRINT_HIGH, st);
	sprint(self, PRINT_HIGH, " Sentry Gun has ");
	st = ftos(gun.health);
	sprint(self, PRINT_HIGH, st);
    sprint(self, PRINT_HIGH, "¯");
	st = ftos(gun.max_health);
    sprint(self, PRINT_HIGH, st);
	sprint(self, PRINT_HIGH, " èåáìôè, ");
	st = ftos(gun.ammo_shells);
	sprint(self, PRINT_HIGH, st);
	sprint(self, PRINT_HIGH, " óèåììó");
	if (gun.weapon == 3)
	{
		st = ftos(gun.ammo_rockets);
		sprint(self, PRINT_HIGH, ", ");
		sprint(self, PRINT_HIGH, st);
		sprint(self, PRINT_HIGH, " òïãëåôó");
	}
	sprint(self, PRINT_HIGH, "\n");

	sprint(self, PRINT_HIGH, "Sentry Gun ÆÒÁÇÓ: "); //CH Displays kills of sent
		st = ftos(gun.frags);
	sprint(self, PRINT_HIGH, st);
	sprint(self, PRINT_HIGH, "\n");

	// Pop up the menu
	self.current_menu = MENU_ENGINEER_FIX_SENTRYGUN;
	self.menu_count = MENU_REFRESH_RATE;

	self.building = gun;

	//dodgy

	// Start a Distance checker, which removes the menu if the player
	// gets too far away from the sentry.
	dist_checker = spawn();
	dist_checker.classname = "timer";
	dist_checker.owner = self;
	dist_checker.enemy = gun;
	dist_checker.think = CheckDistance;
	dist_checker.nextthink = time + 0.3;
};

////////////////////////////////////////////////
// Engineer has used a Spanner on the Tesla
void(entity gun) Engineer_UseTesla =
{
	local entity dist_checker;
	local string st;

	// Print the gun's details
	sprint(self, PRINT_HIGH, "Èåáìôè:");
	st = ftos(gun.health);
	sprint(self, PRINT_HIGH, st);
	sprint(self, PRINT_HIGH, "¯");
	st = ftos(gun.max_health);
	sprint(self, PRINT_HIGH, st);
	sprint(self, PRINT_HIGH, " Ãåììó:");
	st = ftos(gun.ammo_cells);
	sprint(self, PRINT_HIGH, st);
	sprint(self, PRINT_HIGH, "¯");
	st = ftos(gun.maxammo_cells);
	sprint(self, PRINT_HIGH, st);
	st = ftos(gun.has_sentry);
	sprint(self, PRINT_HIGH, " Îïòíáì Ups Left:");
	sprint(self, PRINT_HIGH, st);
	st = ftos(gun.has_tesla);
	sprint(self, PRINT_HIGH, " Íéóã Ups Left:");
	sprint(self, PRINT_HIGH, st);
	sprint(self, PRINT_HIGH, "\n");

	sprint(self, PRINT_HIGH, "Öïìôáçå:");
	st = ftos(gun.ammo_shells);
	sprint(self, PRINT_HIGH, st);
	sprint(self, PRINT_HIGH, " Áíðåòáçå:");
	st = ftos(gun.ammo_nails);
	sprint(self, PRINT_HIGH, st);
	sprint(self, PRINT_HIGH, " Ðï÷åò Óõððìù:");
	st = ftos(gun.ammo_rockets);
	sprint(self, PRINT_HIGH, st);
	sprint(self, PRINT_HIGH, "\n");
	if (gun.tf_items) {
		local float num;
		num = 0;
		if (gun.tf_items & NIT_TURRET) {
			sprint(self, PRINT_HIGH, "TeslaTurret(tm). ");
			num = num + 1;
		}
		if (gun.tf_items & NIT_SCANNER) {
			sprint(self, PRINT_HIGH, "Improved Targeter. ");
			num = num + 1;
		}
		if (gun.tf_items & NIT_AUTOID) {
			sprint(self, PRINT_HIGH, "Spy Detector. ");
			num = num + 1;
		}
		if (gun.tf_items & NIT_KEVLAR) {
			sprint(self, PRINT_HIGH, "Kevlar Armor. ");
			num = num + 1;
		}
		if (gun.tf_items & NIT_BLAST) {
			sprint(self, PRINT_HIGH, "Blast Armor. ");
			num = num + 1;
		}
		if (gun.tf_items & NIT_ASBESTOS) {
			sprint(self, PRINT_HIGH, "Asbestos Armor. ");
			num = num + 1;
		}
		if (gun.tf_items & NIT_TELEPORTER) {
			sprint(self, PRINT_HIGH, "Upgrades from frags. ");
			num = num + 1;
		}
		if (gun.tf_items & NIT_TESLA_CLOAKING) {
			sprint(self, PRINT_HIGH, "Cloaking Device. ");
			num = num + 1;
		}
		if (num != 0)
			sprint(self, PRINT_HIGH, "\n");
	}

	sprint(self, PRINT_HIGH, "Tesla Sentry ÆÒÁÇÓ: "); //CH Displays kills of tesla
		st = ftos(gun.frags);
	sprint(self, PRINT_HIGH, st);
	sprint(self, PRINT_HIGH, "\n");

	// Pop up the menu
	self.current_menu = MENU_ENGINEER_FIX_TESLA;
	self.menu_count = MENU_REFRESH_RATE;

	self.building = gun;

	// Start a Distance checker, which removes the menu if the player
	// gets too far away from the tesla.
	dist_checker = spawn();
	dist_checker.classname = "timer";
	dist_checker.owner = self;
	dist_checker.enemy = gun;
	dist_checker.think = CheckDistance;
	dist_checker.nextthink = time + 0.3;
};
//=================
void(entity cam) Engineer_UseSensor =
{
	local entity dist_checker;
	local string st;

	sprint(self, PRINT_HIGH, "Motion Sensor has ");
	st = ftos(cam.health);
	sprint(self, PRINT_HIGH, st);
	sprint(self, PRINT_HIGH, "¯");
	st = ftos(ceil(cam.max_health));
	sprint(self, PRINT_HIGH, st);
	sprint(self, PRINT_HIGH, " èåáìôè\n");

	// Pop up the menu
	self.current_menu = MENU_ENGINEER_FIX_SENSOR;
	self.menu_count = MENU_REFRESH_RATE;

	self.building = cam;

	// Start a Distance checker, which removes the menu if the player
	// gets too far away from the camera.
	dist_checker = spawn();
	dist_checker.classname = "timer";
	dist_checker.owner = self;
	dist_checker.enemy = cam;
	dist_checker.think = CheckDistance;
	dist_checker.nextthink = time + 0.3;

};
//=================
void(entity cam) Engineer_UseCamera =
{
	local entity dist_checker;
	local string st;

	sprint(self, PRINT_HIGH, "Security Camera has ");
	st = ftos(cam.health);
	sprint(self, PRINT_HIGH, st);
	sprint(self, PRINT_HIGH, "¯");
	st = ftos(ceil(cam.max_health));
	sprint(self, PRINT_HIGH, st);
	sprint(self, PRINT_HIGH, " èåáìôè\n");

	// Pop up the menu
	self.current_menu = MENU_ENGINEER_FIX_CAMERA;
	self.menu_count = MENU_REFRESH_RATE;

	self.building = cam;

	// Start a Distance checker, which removes the menu if the player
	// gets too far away from the camera.
	dist_checker = spawn();
	dist_checker.classname = "timer";
	dist_checker.owner = self;
	dist_checker.enemy = cam;
	dist_checker.think = CheckDistance;
	dist_checker.nextthink = time + 0.3;

};
//=================
void(entity tele) Engineer_UseTeleporter =
{
	local entity dist_checker;
	local string st;

	sprint(self, PRINT_HIGH, "Teleporter Pad has ");
	st = ftos(tele.health);
	sprint(self, PRINT_HIGH, st);
	sprint(self, PRINT_HIGH, "¯");
	st = ftos(ceil(tele.max_health));
	sprint(self, PRINT_HIGH, st);
	sprint(self, PRINT_HIGH, " èåáìôè  ");
	st = ftos(tele.ammo_cells);
	sprint(self, PRINT_HIGH, st);
	sprint(self, PRINT_HIGH, "¯");
	st = ftos(ceil(tele.maxammo_cells));
	sprint(self, PRINT_HIGH, st);
	sprint(self, PRINT_HIGH, " ãåììó\n");


	// Pop up the menu
	self.current_menu = MENU_ENGINEER_FIX_TELEPORTER;
	self.menu_count = MENU_REFRESH_RATE;

	self.building = tele;

	if (teamplay != 0 && !Teammate(self.building.real_owner.team_no,self.team_no)) {
		Menu_EngineerFix_Teleporter_Input(4);
		return;
	}

	// Start a Distance checker, which removes the menu if the player
	// gets too far away from the teleporter.
	dist_checker = spawn();
	dist_checker.classname = "timer";
	dist_checker.owner = self;
	dist_checker.enemy = tele;
	dist_checker.think = CheckDistance;
	dist_checker.nextthink = time + 0.3;

};
//=========================================================================
// Think function for the timer which checks the distance between the 
// Engineer and the building he's using
void() CheckDistance =
{
	local vector dist;
	
	// Check to see if the Engineer's spanner'ed a different building 
	// without leaving the area of this one.
	if (self.owner.building != self.enemy)
	{
		dremove(self);
		return;
	}

	dist = self.enemy.origin - self.owner.origin;
//WK	if (vlen(dist) > 64)
	if (vlen(dist) > 98)
	{
		CenterPrint(self.owner, "\n");
		self.owner.menu_count = MENU_REFRESH_RATE;
		self.owner.current_menu = MENU_DEFAULT;
		self.owner.building = NIL;
		dremove(self);
		return;
	}

	self.nextthink = time + 0.3;
};

void() Engineer_AutoUse =
{
	local float repair_amt = 0;
	local entity targ = self.building;

	if (self.building.real_owner != self && !Teammate(self.team_no,self.building.real_owner.team_no))
	{
		// Auto Dismantle
		if (CheckEnemyDismantle() == FALSE)
			return;
		else if (self.building.classname == "building_dispenser")
			Menu_EngineerFix_Dispenser_Input(4);
		else if (self.building.classname == "building_sentrygun")
			Menu_EngineerFix_SentryGun_Input(5);
		else if (self.building.classname == "building_tesla")
			Menu_EngineerDismantle_Tesla();
		else if (self.building.classname == "building_camera")
			Menu_EngineerFix_Camera_Input(3);
		else if (self.building.classname == "building_sensor")
			Menu_EngineerFix_Sensor_Input(3);
		else if (self.building.classname == "building_fieldgen")
			Menu_EngineerFix_FieldGen_Input(4);
		else if (self.building.classname == "building_teleporter")
			Menu_EngineerFix_Teleporter_Input(4);
	} else if (self.building.health < self.building.max_health) {

		// Auto Repair
		if (self.building.classname == "building_dispenser")
			repair_amt = BUILD_DISPENSER_REPAIR;
		else if (self.building.classname == "building_sentrygun")
			repair_amt = BUILD_SENTRYGUN_REPAIR;
		else if (self.building.classname == "building_tesla")
			repair_amt = BUILD_TESLA_REPAIR;
		else if (self.building.classname == "building_teleporter")
			repair_amt = BUILD_TELEPORT_REPAIR;
		else if (self.building.classname == "building_camera")
			repair_amt = BUILD_CAMERA_REPAIR;
		else if (self.building.classname == "building_sensor")
			repair_amt = BUILD_SENSOR_REPAIR;
		else if (self.building.classname == "building_fieldgen")
			repair_amt = BUILD_FIELDGEN_REPAIR;
		else
		{
			RPrint ("BUG BUG BUG! Engineer_AutoUse called on unknown building!");
			repair_amt = 0;
		}

		if (repair_amt*5 > (self.building.max_health - self.building.health))
			repair_amt = ceil((self.building.max_health - self.building.health) / 5);
		if (repair_amt > self.ammo_cells)
			repair_amt = self.ammo_cells;

		self.building.health += repair_amt * 5;
		if (self.building.health > self.building.max_health)
			self.building.health = self.building.max_health;
		self.ammo_cells -= repair_amt;
		sprint(self, PRINT_HIGH, ftos(self.building.health) + "/" + ftos(self.building.max_health) + " health\n");	
	
		W_SetCurrentAmmo();

	} else {
		
		// Auto Recharge / refill
		if (self.building.classname == "building_tesla")
			repair_amt = BUILD_TESLA_RECHARGE;
		else if (self.building.classname == "building_teleporter")
			repair_amt = BUILD_TELEPORT_RECHARGE;
		else if (self.building.classname == "building_fieldgen")
			repair_amt = BUILD_FIELDGEN_RECHARGE;

		if (repair_amt) {
			if (repair_amt > self.building.maxammo_cells - self.building.ammo_cells)
				repair_amt = self.building.maxammo_cells - self.building.ammo_cells;
			if (repair_amt > self.ammo_cells)
				repair_amt = self.ammo_cells;

			self.building.ammo_cells += repair_amt;
			self.ammo_cells -= repair_amt;

			sprint(self, PRINT_HIGH, ftos(self.building.ammo_cells) + "/" 
						+ftos(self.building.maxammo_cells) + " cells\n");

			W_SetCurrentAmmo();

		} else if (self.building.classname == "building_dispenser") {
			sprint(self, PRINT_HIGH, "Filling armor...");
			local float oldarmor = self.armorvalue;
			Menu_EngineerFix_Dispenser_Input(2);

			self.building = targ;

			if (self.armorvalue == oldarmor)
			{
				sprint(self, PRINT_HIGH, "full. Filling ammo...\n");
				Menu_EngineerFix_Dispenser_Input(1);
				self.building = targ;
			}
			else
				sprint(self, PRINT_HIGH, "\n");

			self.current_menu = MENU_ENGINEER_FIX_DISPENSER;
			self.menu_count = MENU_REFRESH_RATE;
		} else if (self.building.classname == "building_sentrygun") {
			Menu_EngineerFix_SentryGun_Input(1);

			self.current_menu = MENU_ENGINEER_FIX_SENTRYGUN;
			self.menu_count = MENU_REFRESH_RATE;
			self.building = targ;

			sprint(self, PRINT_HIGH, ftos(self.building.ammo_shells) + "/"
						+ftos(self.building.maxammo_shells) + " shells ");
			if (self.building.weapon >= 3)
				sprint(self, PRINT_HIGH, ftos(self.building.ammo_rockets) + "/"
							+ftos(self.building.maxammo_rockets) + " rockets");

			sprint(self, PRINT_HIGH, "\n");
		}
	}
};

