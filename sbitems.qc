/* SB Items. New items for use with Custom TF 3.2 (or something) */

#include "defs.qh"

// Internal prototypes
int(entity e) entpointcontents;
void() AntiGravGrenadeExplode; // antigrav goes boom
void() AntiGravGrenadeTimer; // controls antigrav decay or whatever you call it
void(entity inflictor, entity attacker, float bounce, entity ignore) T_RadiusAntiGrav; // bang

void() MotionSensorIdle; // motion sensor sitting
float() MotionSensorFindTarget; // sensor scans for target
void() MotionSensorDie; // I wonder what this does
void() MotionSensorSpawn; // let's make a sensor
void() SensorBeAlarmed; // very alarming
void() TeamFortress_C4DetpackTouch;
void() ThrowC4Det;
//void() SBInitiateInterface;
float(entity hacked, float r) ReturnHackDelay;
void() SBHackDotTimerThink;
/*void() SwitchToCamera;
void() SwitchFromCamera;
void() CameraSwitchView;*/
// External functions

void() ConcussionGrenadeTouch;
void(entity attacker, float damage) Security_Camera_Pain;
void(float tno, entity ignore, string st) teamsprint;
void() TeamFortress_DetpackTouch;
void() TeamFortress_DetpackCountDown;
void() TeamFortress_DetpackExplode;
void() TeamFortress_DetpackDisarm;
void() SBFireInterface;

// -- OfN --
void(float tno, entity ignore) teamprefixsprint;


//--------------------------------------------------------------
/*
void() CameraSwitchView =
{
	if (!self.has_camera)
		return;

	if (self.is_cameraviewing)
		SwitchFromCamera();
	else
		SwitchToCamera();
};

void() SwitchToCamera =
{
	local entity camera;
	local float done;
	
	if (!self.has_camera)
		return;
	if (self.is_cameraviewing)
		return;
	
	camera = find(nil, classname, "building_camera");
	if (camera.real_owner == self)
		done = TRUE;
	while (!done)
	{
		camera = find(camera, classname, "building_camera");
		if (camera.real_owner == self)
			done = TRUE;
		if (!camera)
			done = TRUE;
	}
	
	if (!camera)
		return;
		
	msg_entity = self;
	WriteByte(MSG_ONE, SVC_SETVIEWPORT);
	WriteEntity(MSG_ONE, camera);
	WriteByte(MSG_ONE, SVC_SETANGLES);
	WriteAngle(MSG_ONE, camera.angles.x);
	WriteAngle(MSG_ONE, camera.angles.y);
	WriteAngle(MSG_ONE, camera.angles.z);
	self.fixangle = TRUE;
	self.is_cameraviewing = TRUE;
	self.t_s_h = self.weaponmodel;
	self.weaponmodel= "";
	self.view_ofs = '0 0 0';
	sprint(self, PRINT_HIGH, "Camera view activated.\n");
};

void() SwitchFromCamera =
{
	if (!self.has_camera)
		return;
	if (!self.is_cameraviewing)
		return;
	msg_entity = self;
	WriteByte(MSG_ONE, SVC_SETVIEWPORT);
	WriteEntity(MSG_ONE, self);
	WriteByte(MSG_ONE, SVC_SETANGLES);
	WriteAngle(MSG_ONE, self.angles.x);
	WriteAngle(MSG_ONE, self.angles.y);
	WriteAngle(MSG_ONE, self.angles.z);
	self.fixangle = FALSE;
	self.weaponmodel = self.t_s_h;
	self.view_ofs = '0 0 22';
	
	self.is_cameraviewing = FALSE;
};
*/


// SB Tossable Detpack!
// A 10 second detpack that can be thrown around corners

void() PrimeC4Det =
{
	local entity te;

	if (infokey (nil, "no_spam") == "on")
	{
		sprint(self,PRINT_HIGH,"The admin has disabled spam devices on this map.\n");
		return;
	}	
	if (!(self.cutf_items & CUTF_TOSSABLEDET))
	{
		sprint (self, PRINT_HIGH, "You do not have the C4 tossable detpack.\n");
		return;
	}
	if (self.ammo_c4det < 1)
	{
		sprint (self, PRINT_HIGH, "Looks like you're out of C4.\n");
		return;
	}
	if (self.is_detpacking || self.is_toffingadet)
	{
		sprint (self, PRINT_HIGH, "You can only set one detpack at once, throwable or otherwise!\n");
		return;
	}
	if (self.is_haxxxoring)
	{
		sprint (self, PRINT_HIGH, "You can't set a detpack while hacking.\n");
		return;
	}
	
	te = spawn();
	te.owner = self;
	te.nextthink = time + WEAP_DETPACK_SETTIME;
	te.think = ThrowC4Det;
	te.classname = "timer";
	te.netname = "C4detpack_timer";
	self.is_toffingadet = 1;
	self.tfstate |= TFSTATE_C4THROW;
	TeamFortress_SetSpeed(self);
	sprint(self, PRINT_HIGH, "Arming detpack...\n");
};

void() TeamFortress_C4DetpackTouch = 
{
	local entity disarm;

	if (other.classname != "player")
		return;

	//WK if (other.playerclass != PC_SCOUT)
	if (!(other.tf_items & NIT_SCANNER))
		return;
    
	if (self.weaponmode == 1)
	    return;

	if (Teammate(self.owner.team_no,other.team_no))
	    return;

	makeImmune(other,time + 2);
	//other.immune_to_check = time + 2;
	other.tfstate |= TFSTATE_CANT_MOVE;

	sprint(other, PRINT_HIGH, "Disarming detpack...\n");
	TeamFortress_SetSpeed(other);

	// Spawn disarming entity
	disarm = spawn();
	disarm.movetype = MOVETYPE_NONE; //WK M3 Bug Hunt
	disarm.owner = other;		// the scout
	disarm.enemy = self;		// the detpack
	disarm.classname = "timer";
	disarm.nextthink = time + WEAP_DETPACK_DISARMTIME;
	disarm.think = TeamFortress_DetpackDisarm;
	
	self.weaponmode = 1;  // indicates disarming
	self.enemy = other;   // points to scout
	self.observer_list = disarm;
};

void(entity ignore, string st, string st2, string st3, string st4, string st5, string st6) teamsprint6;

void() ThrowC4Det =
{
	local entity user;
	
	self.owner.is_toffingadet = 0;

	self.owner.ammo_c4det = self.owner.ammo_c4det - 1;

	user = self.owner;

	sound (user, CHAN_WEAPON, "weapons/grenade.wav", 1, ATTN_NORM);
	KickPlayer(-1, user);
	
	newmis = spawn ();
	newmis.owner = user;
	newmis.movetype = MOVETYPE_BOUNCE;
	newmis.solid = SOLID_BBOX;
	newmis.classname = "detpack";

    // for identify it on airfist pushable? routine
    //newmis.netname = "C4";
	
	// set grenade speed
	makevectors (user.v_angle);

	if (user.deadflag)
	{
		// if user is dead, throw grenade directly up
		newmis.velocity = '0 0 200';
	}
	else
	{
		if (user.v_angle.x)
		{
			newmis.velocity = v_forward*600 + v_up * 200 + random()*v_right*10 + random()*v_up*10;
		}
		else
		{
			newmis.velocity = aim(user, 10000);
			newmis.velocity = newmis.velocity * 600;
			newmis.velocity.z = 200;
		}
	}

	newmis.angles = vectoangles(newmis.velocity);

	newmis.touch = TeamFortress_C4DetpackTouch;
	newmis.think = TeamFortress_DetpackExplode;
	newmis.nextthink = time + 10;
	
	newmis.avelocity = '300 300 300';
	setmodel (newmis, "progs/detpack.mdl");

	setsize (newmis, '-16 -16 -8', '16 16 8');
	setorigin (newmis, user.origin);

	dremove (self);
	self = user;

#ifdef DEMO_STUFF
	if (live_camera)
		CamProjectileLockOn();
#endif
	local entity countd;

	newmis.weaponmode = 0;  // Detpack weaponmode = 1 when disarming

	sound (newmis, CHAN_WEAPON, "doors/medtry.wav", 1, ATTN_NORM);  //CH play set detpack sound
	

	// Create the CountDown entity
	countd = spawn();
	newmis.linked_list = countd;    // attach count to its detpack
	countd.think = TeamFortress_DetpackCountDown;
	countd.health = 9;
	countd.nextthink = time + 1;
	countd.owner = newmis.owner;
	countd.movetype = MOVETYPE_BOUNCE; 
	countd.classname = "countdown_timer"; // Don't call it timer, because we
							  // don't want it removed if player dies
	countd.enemy = newmis;
	newmis.oldenemy = countd;

	sprint(self, PRINT_HIGH, "Detpack armed!\n");

    teamprefixsprint(self.team_no,self);
    teamsprint6(self,self.netname," throws a C4!\n","","","","");
	
	self.tfstate &= ~TFSTATE_C4THROW;
	TeamFortress_SetSpeed(self); // let's roll

};


// SB Motion Sensor
// Sits in shadows and lights up and makes noise when player goes near

void() SBBuildSensor =
{
	if (self.ammo_cells >= BUILD_COST_SENSOR && self.has_sensor == 0)
	{
		self.ammo_cells = self.ammo_cells - BUILD_COST_SENSOR;
		MotionSensorSpawn();
		self.has_sensor = 1;
		sprint(self, PRINT_HIGH, "You place the motion sensor.\n");
        self.option = time + 2;
	}
	else if (self.ammo_cells < BUILD_COST_SENSOR && self.has_sensor == 0)
		sprint(self, PRINT_HIGH, "You do not have enough metal to build a motion sensor.\n");
	else
	{
		if (self.option < time) // avoids ppl overflowing by destroying/building it repeatedly
        {
            Find_And_Dmg("building_sensor", self, 1);
		    sprint(self, PRINT_HIGH, "You detonate your motion sensor.\n");
		    self.has_sensor = 0;
        }
	}
};

void() MotionSensorTossTouch = 
{
	if (other || other == self.real_owner)
		return;
	local int pc = entpointcontents(self);
	if (pc == CONTENTS_SOLID || pc == CONTENTS_SKY)
	{
		MotionSensorDie();
		return;
	}

    teamprefixsprint(self.real_owner.team_no,self.real_owner); //- OfN
    teamsprint(self.real_owner.team_no, self.real_owner, self.real_owner.netname);
	teamsprint(self.real_owner.team_no, self.real_owner, " has built a Motion Sensor.\n");

	self.movetype = MOVETYPE_NONE;
	self.owner = nil;
	setsize (self, self.mins, self.maxs);
	self.solid = SOLID_BBOX;
	self.takedamage = DAMAGE_AIM;
	sound (self, CHAN_WEAPON, "weapons/guerilla_set.wav", 1, ATTN_NORM);
	self.think = MotionSensorIdle;
	self.nextthink = time + 1;
};

void() MotionSensorIdle =
{
	if (MotionSensorFindTarget())
		self.nextthink = time + 2.4; //if found wait 2.5 sec before do another check
	else
		self.nextthink = time + 0.2; // lots per sec GR No, too hard to get past
	self.think = MotionSensorIdle;
};

float() MotionSensorFindTarget =
{
	local entity client = nil;
	local float	r, gotone, loopc;

	// Try a few checks to make it react faster
	r = 0;
	loopc = 0;
	gotone = FALSE;
	
	if (self.is_malfunctioning & SCREWUP_THREE)
		return FALSE;
	
    local float trange; //- OfN - Hack
    trange=300; // was 250

    if (self.num_mines & IMPROVED_ONE)
        trange=500; // was 400

	//CH Theortetically this will check every client on the server now
	while (loopc < 32 && gotone == FALSE)
	{
		client = checkclient();
		gotone = TRUE;

		if (!client)
			gotone = FALSE;
		else if (!Pharse_Client(client, self, 1, trange, 2, 1))
			gotone = FALSE;

		loopc = loopc + 1;
		if (gotone) loopc = 1000;
	}

	if (!gotone)
	{
		self.effects = 0;
        self.skin=1;
		return FALSE;
	}
	
	// Found a Target
	self.enemy = client;

	if (self.enemy.cutf_items & CUTF_JAMMER) // jammer makes it hard
	{
	}
	
    /*if (self.enemy.classname != "player") // OfN - wtf does this?
	{
		self.enemy = self.enemy.enemy;
		if (self.enemy.classname != "player")
		{
			self.enemy = nil;
			return FALSE;
		}
	}*/ // OfN - wtf does this?

    // SPIES, only returned by pharseclient if sensor is able to uncover them -changed
    if (Teammate(self.enemy.undercover_team,self.team_no) && self.num_mines & IMPROVED_FOUR)
    {
        /*if (!(self.enemy.cutf_items & CUTF_JAMMER)) // if they dont have a scanner jammer remove their disguise
        {*/
            Spy_RemoveDisguise(self.enemy);
            sprint(self.real_owner, PRINT_HIGH, "Your motion sensor detects a spy!\n");
		    sprint(self.enemy, PRINT_HIGH, "That motion sensor knows you are a spy!\n");
        //}
        //else 
        //    return FALSE; // removed cause sensors alarm is activated anyway, even if they will not uncover them
    }

    // THIEVES, ALWAYS DETECTED BUT SENSOR ONLY UNCOVERS THEM IF HACKED TO DO- changed
    if (self.enemy.classname=="player")
    {
        if (self.enemy.job & JOB_THIEF && (self.enemy.job & JOB_ACTIVE || self.enemy.job & JOB_FULL_HIDE))
        {
            if (self.num_mines & IMPROVED_SEVEN)
            {
                sprint(self.real_owner, PRINT_HIGH, "Your motion sensor detects a thief!\n");
                sprint(self.enemy, PRINT_HIGH, "That motion sensor can see you!\n");
                RevealThief(self.enemy,TRUE);
            }
        }
    }
	
	if (!(self.is_malfunctioning & SCREWUP_ONE))
		sound(self, CHAN_WEAPON, "misc/enemy.wav", 1, ATTN_NORM);
	
	if (!(self.is_malfunctioning & SCREWUP_TWO))
	{	self.effects = EF_BRIGHTLIGHT; self.skin=0;}


    sprint(self.real_owner,PRINT_HIGH,"Your motion sensor reports enemy presence!\n");

	self.think = SensorBeAlarmed;
	return TRUE;
};

void() SensorBeAlarmed =
{
	if (MotionSensorFindTarget())
	{
		if (!(self.is_malfunctioning & SCREWUP_ONE))
			sound(self, CHAN_WEAPON, "misc/enemy.wav", 1, ATTN_NORM);

		self.nextthink = time + 2.4;
	}
	else
	{
		self.think = MotionSensorIdle;
		self.effects = 0;
		self.nextthink = time + 0.5;
        ///
        self.skin=1;
	}
};

void() MotionSensorSpawn =
{
	self.has_sensor = TRUE;
	newmis = spawn();
	newmis.movetype = MOVETYPE_BOUNCE;
	setsize (newmis, '-16 -16 -6', '16 16 10');
//	setsize (newmis, '-8 -8 -8', '8 8 8');
	newmis.solid = SOLID_BBOX;
	newmis.takedamage = DAMAGE_AIM;
	newmis.classname = "building_sensor";
	newmis.netname = "motion_sensor";
	newmis.origin = self.origin;
	newmis.owner = self;
	newmis.real_owner = self;
	makevectors (self.v_angle);
	newmis.avelocity = '0 0 0';
	newmis.velocity = v_forward*800 + v_up * 200 + v_right*10 + v_up*10;
	setorigin(newmis, newmis.origin);
	newmis.angles = '0 0 0';
	newmis.angles.y = anglemod(self.angles.y + 180);
//	newmis.skin = 1;
	newmis.th_die = MotionSensorDie; 		// Death function
	newmis.th_pain = Security_Camera_Pain; // may as well use this eh
	//newmis.mdl = "progs/s_light.spr"; //CH temp model
    
    newmis.mdl = "progs/sencer.mdl";
    newmis.skin=1;

	setmodel (newmis, newmis.mdl);
	newmis.team_no = self.team_no;
	newmis.colormap = self.colormap;
	newmis.heat = 0; //Beeps

	newmis.health = newmis.max_health = BUILD_HEALTH_SENSOR;
	newmis.touch = MotionSensorTossTouch;

    newmis.num_mines=0; // OfN - reset HACKER improvements

	W_SetCurrentAmmo();
};

void() MotionSensorDie =
{
	sprint(self.real_owner, PRINT_HIGH, "Your motion sensor was destroyed.\n");
	self.real_owner.has_sensor = FALSE;

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


// SB AntiGrav Grenade(tm)
// Screws over a player's gravity for a short time
//
// Uses the conc gren's touch function - why repeat it with an identical one?

void() AntiGravGrenadeExplode =
{	
	T_RadiusAntiGrav (self, self.owner, 100, nil);

#ifdef DEMO_STUFF
	// Remove any camera's locks on this missile
	if (self.enemy)
		CamProjectileLockOff();
#endif

	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_EXPLOSION);
	WriteCoord (MSG_MULTICAST, self.origin.x);
	WriteCoord (MSG_MULTICAST, self.origin.y);
	WriteCoord (MSG_MULTICAST, self.origin.z);
	multicast (self.origin, MULTICAST_PHS);
	dremove(self);
};

// Bounces the enemy a bit and screws over their gravity :)

void(entity inflictor, entity attacker, float bounce, entity ignore) T_RadiusAntiGrav =
{
	local	float 	points;
	local	entity	head, te;
	local	vector	org;
	
	head = findradius(inflictor.origin, bounce+40);
	
	while (head)
	{
		if (head != ignore)
		{
			if (head.takedamage)
			{
				org = head.origin + (head.mins + head.maxs)*0.5;
				points = 0.5*vlen (org - inflictor.origin);
				if (points < 0)
					points = 0;
				points = bounce - points;
				if (self.cutf_items & CUTF_GYMNAST)
					points = points * 2;

				if (!IsBuilding(head) && points > 0)
				{
					// Bounce!!
					head.velocity = org - inflictor.origin;
					head.velocity = head.velocity * (points / 20);

					if (head.classname != "player")
					{
						head.flags &= ~FL_ONGROUND;
					}
					else
					{
						//WK Add cheat immunity since they fly
						makeImmune(head,time+3);

						// Turn on antigrav
						// If it's already on, restore it to full time
						// Try to find a concusstimer entity for this player
						te = find(nil, classname, "timer");
						while (((te.owner != head) || (te.think != AntiGravGrenadeTimer)) && (te))
							te = find(te, classname, "timer");
						if (te)
						{
							head.gravity = 0.3 * random();
							te.health += GR_ANTIGRAV_AMOUNT;
							te.nextthink = time + GR_ANTIGRAV_TIME;
						}
						else
						{
							head.gravity = 0.3 * random();
							stuffcmd(head,"bf\n");
							// Create a timer entity
							te = spawn();
							te.nextthink = time + GR_CONCUSS_TIME;
							te.think = AntiGravGrenadeTimer;
							te.team_no = attacker.team_no;
							te.classname = "timer";
							te.owner = head;
							te.health = GR_ANTIGRAV_AMOUNT;
						}
					}
				}
			}
		}
		head = head.chain;
	}
};

// Timer used to control antigrav effects

void() AntiGravGrenadeTimer =
{
	if (self.owner.invincible_finished > time)
	{
		self.owner.gravity = 1;
		dremove(self);
		return;
	}

	self.health = self.health - GR_ANTIGRAV_DEC * 2;
	
	// hwguy recovers twice as fast - heh heh
	if (self.owner.cutf_items & CUTF_HWGUY)
		self.health = self.health - GR_ANTIGRAV_DEC * 2;

	if (self.health < 0)
		self.health = 0;
	self.nextthink = time + GR_ANTIGRAV_TIME;

	if (self.health == 0)
	{
		self.owner.gravity = 1;
		sprint(self.owner, PRINT_HIGH, "Your weight feels normal again.\n");
		dremove(self);
	}
};
