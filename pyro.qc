#include "defs.qh"
/*
	PYRO.QC

	TeamFortress v2.5	 31/10/96
*/

/*==============================================
 Weapons and functions for the PYRO class and 
 associated weaponry                          
==============================================*/
void() NapalmGrenadeTouch;

//WK Extern
float (entity foobar) IsBuilding;

void (vector org, entity shooter) NapalmGrenadeLaunch ;
void() Napalm_touch;
float (string id_flame) RemoveFlameFromQueue;

#define DAMAGE_TIME 3

//** different types of flames (decreasing priority)

// 1 : burning flames making light and damage (1 per players or monsters)
// 2 : exploding flames (grenade)
// 3 : burning flames (players, monsters)
// 4 : NIL flames (on ground)


// create a flame of a given type, maintaining the count for each type
entity (string type, entity p_owner) FlameSpawn =
{
	if (type != "1")
		return NIL;


	num_world_flames = num_world_flames + 1;

/*
	db1 = ftos(num_world_flames);
	RPrint("num_world_flames : ");
	RPrint(db1);
	RPrint("\n");
*/

	while (num_world_flames > FLAME_MAXWORLDNUM)
	{
		if (!(RemoveFlameFromQueue(type)))
		{
			// RPrint("Create flame failed: too many\n");
			return NIL;
		}
	}

	newmis = spawn();

	// to keep track of the number of each type of flames
	if (type == "1") 
	{
		newmis.movetype = MOVETYPE_FLYMISSILE;
		newmis.solid = SOLID_BBOX;
		newmis.effects = EF_DIMLIGHT; 
		newmis.flame_id = "1";
		setmodel (newmis, "progs/flame2.mdl");
		setsize (newmis, '0 0 0', '0 0 0');
	}
	else if (type == "2") 
	{
		newmis.movetype = MOVETYPE_BOUNCE;
		newmis.solid = SOLID_BBOX;
		newmis.flame_id = "2";
		setmodel (newmis, "progs/flame2.mdl");
		newmis.frame=1;
		setsize (newmis, '0 0 0', '0 0 0');
	}
	else if (type == "3")
	{
		newmis.movetype = MOVETYPE_FLYMISSILE;
		newmis.solid = SOLID_BBOX;
		newmis.flame_id = "3";
		setmodel (newmis, "progs/flame2.mdl");
		setsize (newmis, '0 0 0', '0 0 0');
	}
	else if (type == "4")
	{
		newmis.movetype = MOVETYPE_FLYMISSILE;
		newmis.solid = SOLID_BBOX;
		newmis.flame_id = "4";
		setmodel (newmis, "progs/flame2.mdl");
		newmis.frame=1;
		setsize (newmis, '0 0 0', '0 0 0');
	}

	newmis.owner = p_owner;
	return newmis;
};


// destroy a given flame, maintaining counters and links in the queue
void (entity this) FlameDestroy =
{
//	local string db1;

	num_world_flames = num_world_flames - 1;

/*
	db1 = ftos(num_world_flames);
	RPrint("num_world_flames : ");
	RPrint(db1);
	RPrint("\n");
*/
	remove(this);
};

float (string id_flame) RemoveFlameFromQueue =
{
	local entity tmp;
//	local string db1;


	if (num_world_flames < FLAME_MAXWORLDNUM)
	{
		RPrint("ERROR in RemoveFlameFromQueue\n");
		return FALSE;
	}
/*
	db1 = ftos(num_world_flames);
	RPrint("num_world_flames : ");
	RPrint(db1);
	RPrint("\n");
*/

	num_world_flames = num_world_flames - 1;

	tmp = find(NIL, flame_id, "4");
	if (!tmp)
	{
		if (id_flame == "4") // if priority not high enough, don't continue
			return FALSE;

		tmp = find(NIL, flame_id, "3");
		if (!tmp)
		{
			if (id_flame == "3")
				return FALSE;

			tmp = find(NIL, flame_id, "2");
			if (!tmp)
			{
				if (id_flame == "2")
					return FALSE;

				tmp = find(NIL, flame_id, "1");
			 	if (!tmp)
				{
					// oh shit, no flames found!
					// the queue must be wrong
					RPrint("\n\nRemoveFlameFromQueue():BOOM!\n");
					RPrint("!! please report this bug !!\n");
					return FALSE;
				}
			}
		}
	}

/*
	RPrint("flame removed: flame_id: ");
	RPrint(id_flame);
	RPrint("\n");
*/

/*
	if (tmp.effects == EF_DIMLIGHT)
	{
		RPrint("** error: this flame should not be removed **\n");
	}
*/

	remove(tmp);
	return TRUE;
};


void() Remove=
{
	FlameDestroy(self);
};

// function used by the flames spawned when the grenade explode : killed in water or when stopped
void() NapalmGrenadeFollow =
{
	traceline(self.origin,self.origin,TRUE,self);

	//WK Bugfix
    if (self.enemy.waterlevel > 1)
	{
        sound (self, CHAN_VOICE, "misc/vapeur2.wav", 1, ATTN_NORM);

		FlameDestroy(self);
	}

	if (self.velocity == '0 0 0')
		FlameDestroy(self);

	self.nextthink = time + 0.1;
//	self.think = NapalmGrenadeFollow;
};

void() NapalmGrenadeTouch =
{
	sound (self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM);  // bounce sound
	if (self.velocity == '0 0 0')
		self.avelocity = '0 0 0';
};


void() NapalmGrenadeExplode =
{
	sound (self, CHAN_AUTO, "weapons/flmgrexp.wav", 1, ATTN_NORM);  // bounce sound

	// Launch flames
	traceline(self.origin,self.origin,TRUE,self);

    if (trace_inwater == TRUE)
	{
		dremove(self);
    	return;
	}

#ifdef DEMO_STUFF
	// Remove any camera's locks on this missile
	if (self.enemy)
		CamProjectileLockOff();
#endif

	local entity head;

	// do an incendiary-cannon explosion instead
	self.effects |= EF_BRIGHTLIGHT;

	// don't do radius damage to the other, because all the damage
	// was done in the impact
	head = findradius(self.origin, 140);
	
	while (head)
	{
			if (head.takedamage)
			{
				deathmsg = DMSG_FLAME;
				TF_T_Damage (head, self, self.owner, 120, TF_TD_NOTTEAM, TF_TD_FIRE);
				// set 'em on fire
				other = head;  // i can't believe this works!
				Napalm_touch();
				if (other.classname == "player")
					stuffcmd(other, "bf\nbf\n");
				
			}
		head = head.chain;
	}

	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_EXPLOSION);
	WriteCoord (MSG_MULTICAST, self.origin_x);
	WriteCoord (MSG_MULTICAST, self.origin_y);
	WriteCoord (MSG_MULTICAST, self.origin_z);
	multicast (self.origin, MULTICAST_PHS);
	dremove(self);


};

//=========================================================================
// Launch a flame foe the grenade explosion
void (vector org, entity shooter) NapalmGrenadeLaunch =
{
	local float xdir,ydir,zdir, spin;

	xdir = 150 * random() - 75;
	ydir = 150 * random() - 75;
	zdir = 40 * random();

	newmis = FlameSpawn ("2", shooter);
	if (!newmis)
		return;

	self.touch = NIL;

	newmis.classname = "fire";
	newmis.touch = Napalm_touch;
	newmis.think = NapalmGrenadeFollow;
	newmis.nextthink = time + 0.1;

	newmis.enemy = shooter.owner;

	newmis.velocity_x = xdir * 2;
	newmis.velocity_y = ydir * 2;
	newmis.velocity_z = zdir * 15;

	spin = (random() * 10) / 2;
	if (spin <= 0)
		newmis.avelocity='250 300 400';
	if (spin == 1)
		newmis.avelocity='400 250 300';
	if (spin == 2)
		newmis.avelocity='300 400 250';
	if (spin == 3)
		newmis.avelocity='300 300 300';
	if (spin >= 4)
		newmis.avelocity='400 250 400';

	setorigin (newmis, org);
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);
};

void() OnPlayerFlame_touch;

void() FlameFollow =
{
	local vector dir,vtemp,boundsize;
	local float damage;

	vtemp = self.enemy.absmin;
	boundsize = self.enemy.size;

	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_NONE;

	// if no flames, remove itself
	if (self.enemy.numflames == 0)
	{
		FlameDestroy(self);
		return;
	}

	if (self.enemy.health < 1)
	{
		deathmsg = DMSG_FLAME;
		T_RadiusDamage(self,self,10,self);
		self.enemy.numflames = 0;
		FlameDestroy(self);
		return;
	}

	if (self.enemy.armorclass & AT_SAVEFIRE)
	{
//		if ((random()*100) < self.enemy.armorvalue)
		if (self.enemy.armorvalue > 0)
		{
			self.health = 0;
		}
	}

	if (self.health < 1)
	{
		// only remove the flame if it is not the master flame, or if it is the last flame
		if (self.effects != EF_DIMLIGHT || self.enemy.numflames <= 1)
		{
			self.enemy.numflames = self.enemy.numflames - 1;
			self.enemy.numflames = 0;
			FlameDestroy(self);
			return;
		}
	}


	self.health = self.health - 1;

	// if player is moving too fast, hide flames
	if (vlen(self.enemy.velocity) < 50)
	{
		dir_x = (random() * boundsize_x/2)+boundsize_x/4;
		dir_y = (random() * boundsize_y/2)+boundsize_y/4;
		dir_z = (random() * boundsize_z/3)+boundsize_z/2;
		vtemp = vtemp + dir;
		setorigin(self, vtemp);
	
		if (self.model != "progs/flame2.mdl")
		{
			self.model = "progs/flame2.mdl";
			setmodel(self, self.model);
		}
	}
	else if (self.model == "progs/flame2.mdl")
	{
		self.model = "";
		setmodel(self, self.model);		
	}

	//traceline(self.origin,self.origin,TRUE,self);

	//WK Bugfix
    if (self.enemy.waterlevel > 1)
	{
        sound (self, CHAN_VOICE, "misc/vapeur2.wav", 1, ATTN_NORM);
		self.enemy.numflames = self.enemy.numflames - 1;
		FlameDestroy(self);
		return;
	}

	self.nextthink = time + 0.1;

	if (self.effects == EF_DIMLIGHT && self.heat >= DAMAGE_TIME)
	{
		damage = self.enemy.numflames * 0.3 * DAMAGE_TIME;
		if (damage < 1) 
			damage = 1;

		self.heat = 1;
		deathmsg = DMSG_FLAME;
		TF_T_Damage(self.enemy, self, self.owner, damage, TF_TD_NOTTEAM, TF_TD_FIRE);
	}
	else if (self.effects == EF_DIMLIGHT)
	{
		self.heat = self.heat + 1;
	}
};

// OnPlayerflame : no damage if enemy not dead, spawn flames if touched
void() OnPlayerFlame_touch =
{
	local entity flame;
	local vector vtemp;

	if (other && other.health > 0 && other != self.enemy)
	{

		if (other.numflames >= FLAME_MAXPLYRFLAMES)
			return;

        if (other.classname == "player")
        {
			if ((teamplay & TEAMPLAY_NOEXPLOSIVE) && Teammate(other.team_no, self.owner.team_no))
				return;

             CenterPrint(other,"You are on fire!\n");
             stuffcmd (other,"bf\n");
        }

		if (other.numflames < FLAME_NUMLIGHTS)
		{						    
			flame = FlameSpawn ("1", other);
			sound (flame, CHAN_VOICE, "ambience/fire1.wav", 1, ATTN_NORM);
		}
		else
		{
			flame = FlameSpawn ("3", other);
			if (!flame)
				return;
		}

		flame.classname = "fire";
		flame.health = FLAME_PLYRMAXTIME;
		other.numflames = other.numflames + 1;

		flame.velocity = other.velocity;
		flame.enemy = other;
		flame.touch = OnPlayerFlame_touch;
		flame.owner = self.owner;

		vtemp = self.origin;

		setorigin(flame, vtemp);

		flame.nextthink = time + 0.1;
		flame.think = FlameFollow;
	}
};


// worldflame : lot of damage, spawn flames if touched
void() WorldFlame_touch =
{
	local entity flame;
	local vector vtemp;

	deathmsg = DMSG_FLAME;
	TF_T_Damage(other, self, self.enemy, 2, TF_TD_NOTTEAM, TF_TD_FIRE);

	if (other && other.solid != SOLID_TRIGGER && other.health > 0)
	{

		if (other.numflames >= FLAME_MAXPLYRFLAMES)
			return;

        if (other.classname == "player")
        {
			if ((teamplay & TEAMPLAY_NOEXPLOSIVE) && Teammate(other.team_no, self.owner.team_no))
					return;
        	CenterPrint(other,"You are on fire!\n");
            stuffcmd (other,"bf\n");
        }

		if (other.numflames < FLAME_NUMLIGHTS)
		{
			flame = FlameSpawn ("1", other);
			sound (flame,CHAN_VOICE, "ambience/fire1.wav", 1, ATTN_NORM);
		}
		else
		{
			flame = FlameSpawn ("3", other);
			if (!flame)
				return;
		}

		flame.classname = "fire";
		flame.health = 0;
		other.numflames=other.numflames + 1;

		flame.velocity = other.velocity;
		flame.enemy = other;
		flame.touch = OnPlayerFlame_touch;
		flame.owner = self.owner;

		vtemp = self.origin + '0 0 10';

		setorigin(flame, vtemp);

		flame.nextthink = time + 0.15;
		flame.think = FlameFollow;
	}
};


//Like the flamethrower touch, but it doesn't light them on fire
void() Boot_Flamer_stream_touch =
{
	deathmsg = DMSG_HOVER;


	//WK Sweep for mines at point of contact	
	GuerillaMineSweep(self.origin);

	//WK if (other.takedamage && other.classname == "player")
	if (other.takedamage)
		TF_T_Damage(other,self,self.owner, 40, TF_TD_NOTTEAM, TF_TD_FIRE);
	remove(self);
};
// first touch : direct touch with the flamer stream or flame from grenade
void() Flamer_stream_touch =
{

	local entity flame;
	local vector vtemp;

	if (other.classname == "fire")
		return;

	//WK Sweep for mines at point of contact	
	GuerillaMineSweep(self.origin);

	if (other)
	{
		if (other.takedamage == DAMAGE_AIM && other.health > 0)
		{

			deathmsg = DMSG_FLAME;
			TF_T_Damage(other,self,self.owner, 15, TF_TD_NOTTEAM, TF_TD_FIRE);
	
			if (other.numflames >= FLAME_MAXPLYRFLAMES)
				return;

			if (other.armorclass & AT_SAVEFIRE)
			{
//				if ((random()*100) < other.armorvalue)
				if (other.armorvalue > 0)
				{
					return;
				}
			}

	
            if (other.classname == "player")
            {
				if ((teamplay & TEAMPLAY_NOEXPLOSIVE) && Teammate(other.team_no, self.owner.team_no))
						return;

            	CenterPrint(other,"You are on fire!\n");
	            stuffcmd (other,"bf\n");
        	}

			if (other.numflames < FLAME_NUMLIGHTS)
			{
				flame = FlameSpawn("1", other);
				sound (flame,CHAN_VOICE, "ambience/fire1.wav", 1, ATTN_NORM);
			}
			else
			{
				flame = FlameSpawn("3", other);
				if (!flame)
					return;
			}
			flame.classname = "fire";
			flame.health = FLAME_PLYRMAXTIME;
			other.numflames=other.numflames + 1;

			flame.velocity = other.velocity;
			flame.enemy = other;
			flame.touch = OnPlayerFlame_touch;
			flame.owner = self.owner;

			vtemp=self.origin;

			setorigin(flame , vtemp);

			flame.nextthink = time + 0.1;
			flame.think = FlameFollow;
		}
	}
	else
	{
		if (random() < FLAME_BURNRATIO)
		{
			remove(self);
			return;
		}
		flame = FlameSpawn("4", other);
		if (flame)
		{
			flame.touch = WorldFlame_touch;
			flame.classname = "fire";

			vtemp=self.origin + '0 0 10';
			setorigin(flame , vtemp);
			flame.nextthink = time + FLAME_MAXBURNTIME;
			flame.think = Remove;
			flame.enemy = self.owner;
		}

		remove(self);
	}
};


void() Napalm_touch =
{

	local entity flame;
	local vector vtemp;

	if (other.classname == "fire")
		return;

	if (other)
	{
		if (other.takedamage == DAMAGE_AIM && other.health > 0)
		{
			deathmsg = DMSG_FLAME;
			TF_T_Damage(other, self, self.owner, 6, TF_TD_NOTTEAM, TF_TD_FIRE);
	
			if (other.numflames >= FLAME_MAXPLYRFLAMES)
				return;

			if (other.armorclass & AT_SAVEFIRE && other.armorvalue > 0)
				return;
	
	        if (other.classname == "player")
	        {
				if ((teamplay & TEAMPLAY_NOEXPLOSIVE) && Teammate(other.team_no, self.owner.team_no))
						return;

	        	CenterPrint(other,"You are on fire!\n");
	            stuffcmd (other,"bf\n");
        	}

			if (other.numflames < FLAME_NUMLIGHTS) // = 0
			{
				flame = FlameSpawn("1", other);
				sound (flame,CHAN_VOICE, "ambience/fire1.wav", 1, ATTN_NORM);
			}
			else
			{
				flame = FlameSpawn("3", other);
				if (!flame)
					return;
			}
			flame.classname = "fire";
			flame.health = FLAME_PLYRMAXTIME;
			other.numflames = other.numflames + 1;

			flame.velocity = other.velocity;
			flame.enemy = other;
			flame.touch = OnPlayerFlame_touch;
			flame.owner = self.owner;

			flame.AIRG_Flags = self.AIRG_Flags;
			flame.AIRG_FlyTracker = self.AIRG_FlyTracker;

			vtemp=self.origin;

			setorigin(flame , vtemp);

			flame.nextthink = time + 0.1;
			flame.think = FlameFollow;
		}
	}
	else
	{
		flame = FlameSpawn("4", other);
		if (flame)
		{
			flame.touch = WorldFlame_touch;
			flame.classname = "fire";

			vtemp=self.origin + '0 0 10';
			setorigin(flame , vtemp);
			flame.nextthink = time + NAPALM_MAXBURNTIME;
			flame.think = Remove;
			flame.enemy = self.owner;
		}

		FlameDestroy(self);
	}
};


// Player.qc declaration
	void () DeathBubblesSpawn;


// Slightly varied version of DEATHBUBBLES
void(float num_bubbles, vector bub_origin) NewBubbles =
{
local entity	bubble_spawner;

	bubble_spawner = spawn();
    setorigin (bubble_spawner, bub_origin);
	bubble_spawner.movetype = MOVETYPE_NONE;
	bubble_spawner.solid = SOLID_NOT;
	bubble_spawner.nextthink = time + 0.1;

    if (self.classname == "player")
		bubble_spawner.owner = self;
    else
        bubble_spawner.owner = self.enemy;

    bubble_spawner.think = DeathBubblesSpawn;
	bubble_spawner.bubble_count = num_bubbles;
	return;
};


void() W_FireFlame =
{
    local   entity flame;
    local   float rn;

    if (self.waterlevel > 2)
    {
            makevectors (self.v_angle);
            NewBubbles(2, self.origin+v_forward*64);

            rn = random();
            if (rn < 0.5)
                    sound (self, CHAN_WEAPON, "misc/water1.wav", 1, ATTN_NORM);
            else
                    sound (self, CHAN_WEAPON, "misc/water2.wav", 1, ATTN_NORM);

            return;
    }

    // Take away a cell
    self.currentammo = self.ammo_cells = self.ammo_cells - 1;

    sound (self, CHAN_AUTO, "weapons/flmfire2.wav", 1, ATTN_NORM);

    flame = spawn ();

    flame.owner = self;
    flame.movetype = MOVETYPE_FLYMISSILE;
    flame.solid = SOLID_BBOX;
    flame.classname = "flamerflame";

	// set flame speed

	makevectors (self.v_angle);

    flame.velocity = aim(self, 10000);
    flame.velocity = flame.velocity * 600;

    flame.touch = Flamer_stream_touch;

    flame.think = s_explode1;
    flame.nextthink = time + 0.15;

    setmodel (flame, "progs/s_explod.spr");
    setsize (flame, '0 0 0', '0 0 0');
    setorigin (flame, self.origin + v_forward * 16 + '0 0 16');
};


/*======================
Touch function for incendiary cannon rockets
======================*/
void() T_IncendiaryTouch =
{
	local 	float	damg;
	local	entity	head; 

	if (other == self.owner)
		return;		// don't explode on owner

	if (pointcontents(self.origin) == CONTENTS_SKY)
	{
		remove(self);
		return;
	}
	self.effects |= EF_BRIGHTLIGHT;

	damg = 20 + random()*20;
	
	if (other.health)
	{
		deathmsg = DMSG_FLAME;
		TF_T_Damage (other, self, self.owner, damg, TF_TD_NOTTEAM, TF_TD_FIRE);
	}

	// don't do radius damage to the other, because all the damage
	// was done in the impact
	head = findradius(self.origin, 180);
	
	while (head)
	{
			if (head.takedamage)
			{
				deathmsg = DMSG_FLAME;
				TF_T_Damage (head, self, self.owner, 15, TF_TD_NOTTEAM, TF_TD_FIRE);

				// set 'em on fire
				other = head;  // i can't believe this works!
				Napalm_touch();
				if (other.classname == "player")
					stuffcmd(other, "bf\nbf\n");
				//if (IsBuilding(other))  //this made no sense
				//TF_T_Damage (head, self, self.owner, 35, TF_TD_NOTTEAM, TF_TD_FIRE);

			}
		head = head.chain;
	}

//	sound (self, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NORM);
	self.origin = self.origin - 8*normalize(self.velocity);

#ifdef DEMO_STUFF
	// Remove any camera's locks on this missile
	if (self.enemy)
		CamProjectileLockOff();
#endif

	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_EXPLOSION);
	WriteCoord (MSG_MULTICAST, self.origin_x);
	WriteCoord (MSG_MULTICAST, self.origin_y);
	WriteCoord (MSG_MULTICAST, self.origin_z);
	multicast (self.origin, MULTICAST_PHS);

    if (other.classname == "force_field") //- OfN - Makes field explosion b4 removing it
        FieldExplosion(other,self.origin,self);

	dremove(self);
};


/*
================
W_FireIncendiaryCannon
================
*/
void() W_FireIncendiaryCannon =
{
	
	if (self.ammo_rockets < 3)
		return;

	self.currentammo = self.ammo_rockets = self.ammo_rockets - 3;
	
	sound (self, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);

	KickPlayer(-3, self);

	newmis = spawn ();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;
		
	// set newmis speed	
	makevectors (self.v_angle);
	newmis.velocity = aim(self, 1000);
	newmis.velocity = newmis.velocity * 600;
	newmis.angles = vectoangles(newmis.velocity);
	
	newmis.touch = T_IncendiaryTouch;

    //- OfN - For airfist
    newmis.classname = "rocket";

	// set newmis duration
	newmis.nextthink = time + 5;
	newmis.think = SUB_Remove;

	newmis.weapon = DMSG_INCENDIARY;
	
	setmodel (newmis, "progs/missile.mdl");
	setsize (newmis, '0 0 0', '0 0 0');		
	setorigin (newmis, self.origin + v_forward*8 + '0 0 16');

#ifdef DEMO_STUFF
	// Have we got a live camera in projectile mode?
	if (live_camera)
		CamProjectileLockOn();
#endif
};

//=========================================================================
// Incendiary cannon selection function
void() TeamFortress_IncendiaryCannon =
{
	if (!(self.weapons_carried & WEAP_INCENDIARY))
		return;

	if (self.ammo_rockets < 3)
	{
		sprint (self, PRINT_HIGH, "not enough ammo.\n");
		return;
	}

	self.current_weapon = WEAP_INCENDIARY;

	W_SetCurrentAmmo();
};
// Flamethrower selection function
void() TeamFortress_FlameThrower =
{
	if (!(self.weapons_carried & WEAP_FLAMETHROWER))
		return;

	if (self.ammo_cells < 1)
	{
		sprint (self, PRINT_HIGH, "not enough ammo.\n");
		return;
	}

	self.current_weapon = WEAP_FLAMETHROWER;

	W_SetCurrentAmmo();
};

