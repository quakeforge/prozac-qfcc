#include "defs.qh"
/*======================================================
	DEMOMAN.QC

	TeamFortress v2.5	 29/2/97
========================================================
Functions for the DEMOMAN class and associated weaponry                          
========================================================*/
// Functions outside this file
void() NormalGrenadeTouch;
void() NormalGrenadeExplode;

// Functions in this file
// Pipebomb Functions
void() TeamFortress_DetonatePipebombs;
void() PipebombTouch;
// Mirv Grenade Functions
void() MirvGrenadeTouch;
void() MirvGrenadeExplode;
void (vector org, entity shooter) MirvGrenadeLaunch;
// Detpack Functions
void(float timer) TeamFortress_SetDetpack;
void() TeamFortress_DetpackSet;
void(float krac) TeamFortress_DetpackStop;
void() TeamFortress_DetpackExplode;
void() TeamFortress_DetpackTouch;
void() TeamFortress_DetpackDisarm;
void() TeamFortress_DetpackCountDown;

//=========================================================================
// Detonate all thrown pipebombs
void() TeamFortress_DetonatePipebombs =
{
	local entity e;

	// Find all this players pipebombs
	e = find(nil, classname, "pipebomb");
	while (e)
	{
    	if(e.owner == self)
			e.nextthink = time;
		
		e = find(e, classname, "pipebomb");
	}
};

//=========================================================================
// Pipebomb touch function
void() PipebombTouch =
{
	sound (self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM);	// bounce sound
	if (self.velocity == '0 0 0')
		self.avelocity = '0 0 0';
};

//=========================================================================
// Touch Function for Mirv Grenade
// Mirv Grenade heavily influenced by the Firewall Grenade by Steve Bond (wedge@nuc.net)
void() MirvGrenadeTouch =
{
	// If the Mirv Grenade hits a player, it just bounces off
	sound (self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM);
	if (self.velocity == '0 0 0')
		self.avelocity = '0 0 0';
};

//=========================================================================
// Mirv Grenade explode function, for when the PRIMETIME runs out
void() MirvGrenadeExplode =
{
	local float i;

	deathmsg = DMSG_GREN_MIRV;
	T_RadiusDamage (self, self.owner, 100, nil);

	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_EXPLOSION);
	WriteCoord (MSG_MULTICAST, self.origin.x);
	WriteCoord (MSG_MULTICAST, self.origin.y);
	WriteCoord (MSG_MULTICAST, self.origin.z);
	multicast (self.origin, MULTICAST_PHS);

	self.solid = SOLID_NOT;

	// Launch mirvs
	i = 0;
	while (i < GR_TYPE_MIRV_NO)
	{
		MirvGrenadeLaunch (self.origin + '0 0 -1',self.owner);
		i = i + 1;
	}

#ifdef DEMO_STUFF
	// Remove any camera's locks on this missile
	if (self.enemy)
		CamProjectileLockOff();
#endif

	BecomeExplosion();
};

//=========================================================================
// Launch a Mirv
void (vector org, entity shooter) MirvGrenadeLaunch =
{
	local float xdir,ydir,zdir;

	xdir = 150 * random() - 75;
	ydir = 2 * (100 - fabs(xdir)) * random() - (75 - fabs(xdir));
	zdir = 170 - (fabs(xdir) + fabs(ydir));

	newmis = spawn ();
	newmis.owner = shooter;
	newmis.movetype = MOVETYPE_BOUNCE;
	newmis.solid = SOLID_BBOX;

	newmis.classname = "grenade";
	newmis.weapon = DMSG_GREN_MIRV;

#ifdef NET_SERVER
	newmis.touch = GrenadeTouch;
	newmis.think = GrenadeExplode;
#else
	newmis.touch = GrenadeTouch;
	newmis.think = GrenadeExplode;
#endif

	//WK 2 + random
	newmis.nextthink = time + 0.75 + random();
	
	newmis.velocity.x = xdir * 3;
	newmis.velocity.y = ydir * 3;
	newmis.velocity.z = zdir * 5;

	newmis.avelocity='100 100 500';
	newmis.AIRG_Flags = self.AIRG_Flags; //for tk stuff
	newmis.AIRG_FlyTracker = self.AIRG_FlyTracker; 

	setmodel (newmis, "progs/grenade2.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);
	setorigin (newmis, org);
};

//=========================================================================
// Handles the Setting of Detpacks
void(float timer) TeamFortress_SetDetpack =
{
	local string stimer;

	// prevent detpack impulse from triggering anything else
	self.impulse = 0;
	self.last_impulse = 0;

	if (!(self.cutf_items & CUTF_DETPACK))
		return;

	if (self.ammo_detpack <= 0)
		return;

	if (infokey (nil, "no_spam") == "on")
	{
		sprint(self,PRINT_HIGH,"The admin has disabled spam devices on this map.\n");
		return;
	}
	// Cant set detpack if you're in the air
	if (!(self.flags & FL_ONGROUND))
	{
		sprint (self, PRINT_HIGH, "You can't set detpacks in the air!\n");
		return;
	}
	//WK Prevents spy sliding bug
	if (self.is_feigning)
	{
		sprint (self, PRINT_HIGH, "You can't set detpacks while playing dead!\n");
		return;
	}
	if (self.is_haxxxoring)
	{
		sprint (self, PRINT_HIGH, "You can't set a detpack while you're hacking something.\n");
		return;
	}
	if (timer < 5)
	{
		sprint (self, PRINT_HIGH, "You can't set detpacks for less that 5 seconds.\n");
		return;
	}

	if (self.is_detpacking || self.is_toffingadet)
		return;

	self.is_detpacking = 1;
	self.ammo_detpack = self.ammo_detpack - 1;

	makeImmune(self,time + 2);
	//self.immune_to_check = time + 2;
	self.tfstate |= TFSTATE_CANT_MOVE;
	// Save the current weapon and remove it
	self.weapon = self.current_weapon;
	self.current_weapon = 0;
	self.weaponmodel = "";
	self.weaponframe = 0;

	TeamFortress_SetSpeed(self);

	self.pausetime = time + WEAP_DETPACK_SETTIME;

	stimer = ftos(timer);

	sprint(self, PRINT_HIGH, "Setting detpack for ");
	sprint(self, PRINT_HIGH, stimer);
	sprint(self, PRINT_HIGH, " seconds...\n");

	newmis = spawn();
	newmis.owner = self;
	newmis.classname = "timer";
	newmis.netname = "detpack_timer";
	newmis.movetype = MOVETYPE_NONE; //WK M3 Bug Hunt
	newmis.nextthink = time + WEAP_DETPACK_SETTIME;
	newmis.think = TeamFortress_DetpackSet;
	newmis.health = timer;

//CH because its on the sbar :)
	self.StatusRefreshTime = time + 0.2;
	self.StatusBarScreen = 3;
};

//=========================================================================
// Stops the setting of the detpack
void(float krac) TeamFortress_DetpackStop =
{
	local entity detpack_timer;

	detpack_timer = find(nil, netname, "detpack_timer");
	while ((detpack_timer.owner != self) && (detpack_timer))
		detpack_timer = find(detpack_timer, netname, "detpack_timer");

	if (!detpack_timer)  
		return;

	if (krac == TRUE) {
		sprint(self, PRINT_HIGH, "Your detpack got Kraced!\n");
	} else {
		sprint(self, PRINT_HIGH, "Detpack retrieved.\n");
		self.ammo_detpack = self.ammo_detpack + 1;
	}

	dremove(detpack_timer);

	self.tfstate &= ~TFSTATE_CANT_MOVE;

	self.is_detpacking = 0;
	self.current_weapon = self.weapon;
	W_SetCurrentAmmo();

	TeamFortress_SetSpeed(self);

	self.pausetime = time;
};

//=========================================================================
// The detpack is set, let the player go and start timer
void() TeamFortress_DetpackSet =
{
	local entity countd, oldself;

	self.is_detpacking = 0;
	self.owner.tfstate &= ~TFSTATE_CANT_MOVE;
    self.owner.is_detpacking = 0;

	TeamFortress_SetSpeed(self.owner);

#ifdef SPEECH
	stuffcmd(self.owner, "play speech/demo_dp.wav\n");
#endif

	oldself = self;
	self = self.owner;
	//self.is_detpacking = 0;
	self.current_weapon = self.weapon;
	W_SetCurrentAmmo();
	self = oldself;

	newmis = spawn ();
	newmis.owner = self.owner;
    newmis.origin = self.owner.origin - '0 0 23';
	newmis.movetype = MOVETYPE_BOUNCE;
	newmis.solid = SOLID_BBOX;
	newmis.classname = "detpack";
    newmis.flags = FL_ITEM;
		
	newmis.angles = '90 0 0';
	newmis.angles.y = self.owner.angles.y;
	newmis.velocity = '0 0 0';
	newmis.avelocity = '0 0 0';

	newmis.weaponmode = 0;  // Detpack weaponmode = 1 when disarming
   	newmis.touch = TeamFortress_DetpackTouch;

	setmodel (newmis, "progs/detpack.mdl");
	setsize (newmis, '-16 -16 0', '16 16 8');
	setorigin (newmis, self.owner.origin);

	sound (newmis, CHAN_WEAPON, "doors/medtry.wav", 1, ATTN_NORM);  //CH play set detpack sound
	

	// Create the CountDown entity
	countd = spawn();
	newmis.linked_list = countd;    // attach count to its detpack
	countd.think = TeamFortress_DetpackCountDown;
	countd.health = self.health - 1;
	countd.owner = self.owner;
	countd.movetype = MOVETYPE_NONE; //WK M3 Bug Hunt
	countd.classname = "countdown_timer"; // Don't call it timer, because we
							  // don't want it removed if player dies
	countd.enemy = newmis;
	newmis.oldenemy = countd;
	if (self.health <= 10)
		countd.nextthink = time + 1;
	else
	{
		countd.nextthink = time + self.health - 10;
		countd.health = 9;
	}
	newmis.nextthink = time + self.health;
	newmis.think = TeamFortress_DetpackExplode;

	sprint(self.owner, PRINT_HIGH, "Detpack set!\n");

    teamprefixsprint(self.team_no,self);
    teamsprint6(self,self.netname," sets a detpack!\n","","","","");

	dremove(self);
};

//- OfN - Used for extra det explosions
float (vector targ, vector check) vis2orig;


//=========================================================================
// The detpack goes BOOM!
void() TeamFortress_DetpackExplode = 
{
	local int pos;

	bprint(PRINT_MEDIUM, "FIRE IN THE HOLE!\n");

	// Check the pointcontents to prevent detpack outside the world
	pos = entpointcontents(self); 
	if (pos != CONTENTS_SOLID && pos != CONTENTS_SKY) 
	{
		deathmsg = DMSG_DETPACK;
		T_RadiusDamage (self, self.owner, WEAP_DETPACK_SIZE, nil);

        sound(self, CHAN_MISC, "weapons/detpack.wav", 1, ATTN_NONE);

		WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
		WriteByte (MSG_MULTICAST, TE_EXPLOSION);
		WriteCoord (MSG_MULTICAST, self.origin.x);
		WriteCoord (MSG_MULTICAST, self.origin.y);
		WriteCoord (MSG_MULTICAST, self.origin.z);
		multicast (self.origin, MULTICAST_PHS);

        WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
		WriteByte (MSG_MULTICAST, TE_LAVASPLASH);
		WriteCoord (MSG_MULTICAST, self.origin.x);
		WriteCoord (MSG_MULTICAST, self.origin.y);
		WriteCoord (MSG_MULTICAST, self.origin.z);
		multicast (self.origin, MULTICAST_PHS);

    //- OfN - Should a detpack make the same explosion a gren does? dont think so...
    #ifdef extra_detpack_explosions
        
        local float loopc;
        local vector rexp;

        loopc = 0;

        while (loopc < EXTRA_DETEXPOSIONS)
        {
            rexp.x = self.origin.x + random()*400 - 200;
            rexp.y = self.origin.y + random()*400 - 200;
            rexp.z = self.origin.z + random()*100;

            if (vis2orig(self.origin,rexp))
            {
                WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
                WriteByte (MSG_MULTICAST, TE_EXPLOSION);
                WriteCoord (MSG_MULTICAST, rexp.x);
                WriteCoord (MSG_MULTICAST, rexp.y);
                WriteCoord (MSG_MULTICAST, rexp.z);
                multicast (rexp, MULTICAST_PHS);
            }
            loopc = loopc + 1;
        }
    #endif

    //- OfN - Moves a bit the players that are near the exploding detpack
    #ifdef detpack_earthquake
        
        local entity head;

        local vector v;
	    
        head = findradius(self.origin, DETPACK_EARTHQUAKE_RANGE);

        while (head)
        {
            if (head.classname == "player")
            if (head.health > 0)
            if (!head.has_disconnected)
            if (head.playerclass != PC_UNDEFINED)
            if (head.flags & FL_ONGROUND || head.waterlevel)
            {
                v.x = 100 * crandom();
            	v.y = 100 * crandom();
        	    v.z = 150 + 200 * random();
                head.velocity = head.velocity + v;
            }
            
            head = head.chain;
        }

    #endif


	}
	else
	{
//		bprint(PRINT_HIGH, "Your detpack fizzled out.\n");
		sprint(self.owner, PRINT_HIGH, "Your detpack fizzled out.\n");
	}

	// This code handles a disarming scout with protection
	if (self.weaponmode == 1)     	  // Detpack was being disarmed
	{   
		TeamFortress_SetSpeed(self.enemy);

		dremove(self.oldenemy);  	 // CountDown
		dremove(self.observer_list); //	Disarm timer
	}

	BecomeExplosion ();
};

//=========================================================================
// The detpack touch function. Scouts can disarm it.
void() TeamFortress_DetpackTouch = 
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

//=========================================================================
// The detpack disarm function. Scout has finished disarming it
// .enemy is the detpack
// .owner is the scout
void() TeamFortress_DetpackDisarm = 
{
	if (self.owner.health <= 0) {
		dremove(self);
		return;
	}

	bprint (PRINT_MEDIUM, self.enemy.owner.netname);
	bprint (PRINT_MEDIUM, "'s detpack was defused by ");
	bprint (PRINT_MEDIUM, self.owner.netname);
	bprint (PRINT_MEDIUM, "\n");
	
    //if (!(self.owner.is_feigning))
	//- OfN already checked on TeamFortress_SetSpeed()
    //{
        self.owner.tfstate &= ~TFSTATE_CANT_MOVE;

	// Reset speeds of scout
	TeamFortress_SetSpeed(self.owner);
	//}

	dremove(self.enemy.oldenemy);	// remove count down
	dremove(self.enemy);        	// remove detpack
	dremove(self);					// remove this timer
};

//=========================================================================
// The Detpack CountDown function. Displays the seconds left before the
// detpack detonates to the owner of the detpack, if <10
void() TeamFortress_DetpackCountDown = 
{
	local string cd;

	cd = ftos(self.health);

	sprint(self.owner, PRINT_HIGH, cd);
	sprint(self.owner, PRINT_HIGH, "...\n");

	self.nextthink = time + 1;
	self.health = self.health - 1;

	// Flash the red light
	if (self.health <= 4)
		self.enemy.skin = 1;

	if (self.health <= 3 && self.health > 2) { //WK Detpack alerts
		sound (self.owner, CHAN_VOICE, "weapons/fith.wav", 1, ATTN_NORM);
		sound (self.enemy, CHAN_WEAPON, "doors/baseuse.wav", 1, ATTN_NORM);  //CH play set detpack sound
	}

	if (self.health == 0)
		dremove(self);
};

