#include "defs.qh"
/*======================================================
	SENTRY.QC			Custom TeamFortress v2.1	

	(c) TeamFortress Software Pty Ltd 	29/2/97
	(c) William Kerney			21/10/99
	(c) Craig Hauser				19/3/00
========================================================
Weapons and functions for the Sentry Guns
======================================================*/
// This is a temporary hack... they'll be replaced with real bots when
// the bot code is in (should that be if? :)
// WK If is right. :)
// SentryGun AI Functions
void() Sentry_Rotate;
float() Sentry_FindTarget;
void() Sentry_FoundTarget;
void() Sentry_HuntTarget;
void() Sentry_Pain;
void() Sentry_Die;
float() Sentry_Fire;
//WK - Will kill enemies on touch, and adds support for flying.
void() Sentry_Touch;
/* WK==============================================
#ifndef COOP_MODE
void() ai_face =
{
	local vector temp_vect,temp_ang;
	self.ideal_yaw = vectoyaw(self.enemy.origin - self.origin);
	self.ideal_yaw = anglemod(self.ideal_yaw);
	//WK Turrets swivel instanter
	if (self.tf_items & NIT_TURRET) { //Auto-swivel
		self.angles_y = self.ideal_yaw;
	}
	else
		ChangeYaw ();
};
#endif
*/
//==============================================
$cd /quake/fortress/progs/turrgun
$origin 0 -6 24
$base base		
$skin skin

$frame lvl1_stand1
$frame lvl1_shoot1 lvl1_shoot2 
$frame lvl2_stand1
$frame lvl2_shoot1 lvl2_shoot2 
$frame lvl3_stand1
$frame lvl3_shoot1 lvl3_shoot2 

/*    WK -- This is how you unhack the turret's position :Þ
	if (self.tf_items & NIT_TURRET) self.origin_z = self.origin_z + 40;
*/

void() RemoveGlow = {
	self.effects = self.effects - (self.effects & EF_DIMLIGHT);
};

//===========================
// Level 1 Sentry Gun Frames
void()	lvl1_sentry_atk3;
void()  lvl1_sentry_stand =[ $lvl1_stand1, 	lvl1_sentry_stand ] {RemoveGlow(); Sentry_Rotate();};
void()	lvl1_sentry_atk1 =[	$lvl1_shoot1,	lvl1_sentry_atk3 ] 
{
	ai_face();
	if (self.enemy == world || self.enemy.health <= 0 || /* !visible(self.enemy) || */ self.enemy.has_disconnected == TRUE) //CH
		lvl1_sentry_stand();
	else if (self.ammo_shells <= 0)
		lvl1_sentry_stand();
	else if (Sentry_Fire() == FALSE)
		//WK lvl1_sentry_atk3();
		lvl1_sentry_stand();
};
void()	lvl1_sentry_atk2 =[	$lvl1_shoot2,	lvl1_sentry_atk3 ]
{
	ai_face();
	Sentry_Fire();
};
void()	lvl1_sentry_atk3 =[	$lvl1_stand1,	lvl1_sentry_atk1 ]  {ai_face();};

//===========================
// Level 2 Sentry Gun Frames
void()	lvl2_sentry_atk3;
void()  lvl2_sentry_stand=	[  $lvl2_stand1, 	lvl2_sentry_stand ] {RemoveGlow(); Sentry_Rotate();};
void()	lvl2_sentry_atk1 =  [	$lvl2_shoot1,	lvl2_sentry_atk2	] 
{
	ai_face();
	if (self.enemy == world || self.enemy.health <= 0 || /* !visible(self.enemy) || */ self.enemy.has_disconnected == TRUE) //CH
		lvl2_sentry_stand();
	else if (self.ammo_shells <= 0)
		lvl2_sentry_stand();
	else if (Sentry_Fire() == FALSE)
		//WK lvl2_sentry_atk3();
		lvl2_sentry_stand();
};
void()	lvl2_sentry_atk2	=[	$lvl2_shoot2,	lvl2_sentry_atk3	] 
{
	ai_face();
	Sentry_Fire();
};
void()	lvl2_sentry_atk3 =[	$lvl2_stand1,	lvl2_sentry_atk1 ]
{
	ai_face(); 
	Sentry_Fire();
};

//===========================
// Level 3 Sentry Gun Frames
void()	lvl3_sentry_atk3;
void()	lvl3_sentry_atk4;
void()  lvl3_sentry_stand=	[   $lvl3_stand1, 	lvl3_sentry_stand ] {RemoveGlow(); Sentry_Rotate();};
void()	lvl3_sentry_atk1 =  [	$lvl3_shoot1,	lvl3_sentry_atk2  ] 
{
	ai_face();
	if (self.enemy == world || self.enemy.health <= 0 || /* !visible(self.enemy) || */ self.enemy.has_disconnected == TRUE) //CH
		lvl3_sentry_stand();
	else if (self.ammo_shells <= 0 && self.ammo_rockets <= 0)
		lvl3_sentry_stand();
	else if (self.ammo_shells <= 0 && self.ammo_rockets > 0) //CH rocket check
	{
		RemoveGlow();
		lvl3_sentry_atk4();
	}
	else if (Sentry_Fire() == FALSE)
		//WK lvl3_sentry_atk3();
		lvl3_sentry_stand();
};
void()	lvl3_sentry_atk2 =[	$lvl3_shoot2,	lvl3_sentry_atk3  	] 
{
	ai_face();
  	Sentry_Fire();
};
void()	lvl3_sentry_atk3 =[	$lvl3_stand1,	lvl3_sentry_atk1	] 
{
	ai_face(); 
	Sentry_Fire();
};
void()	lvl3_sentry_atk4 =  [	$lvl3_stand1,	lvl3_sentry_atk5  ] 
{
	ai_face();
	if (self.enemy == world || self.enemy.health <= 0 || /* !visible(self.enemy) || */ self.enemy.has_disconnected == TRUE) //CH
		lvl3_sentry_stand();
	else if (self.ammo_shells <= 0 && self.ammo_rockets <= 0)
		lvl3_sentry_stand();
	else if (Sentry_Fire() == FALSE)
		//WK lvl3_sentry_atk3();
		lvl3_sentry_stand();
};
void()	lvl3_sentry_atk5 =[	$lvl3_stand1,	lvl3_sentry_atk4	] 
{
	ai_face(); 
	Sentry_Fire();
};

//=============
void() Sentry_Rotate =
{
/*
	// don't let them exist in walls/doors
	// FIXME: pointcontents is wrong for doors
	local vector testpoint = self.origin;
	if (self.tf_items & NIT_TURRET)
		testpoint_z -= 40;
	if (pointcontents (testpoint) == CONTENTS_SOLID) {
		TF_T_Damage (self, world, world, self.health + 100,
					 TF_TD_IGNOREARMOUR, TF_TD_OTHER);
		return;
	}
*/

	if (self.is_malfunctioning & SCREWUP_ONE)
	{
		self.ideal_yaw = self.ideal_yaw + 10;
		ChangeYaw();
		return;
	}

	if (Sentry_FindTarget())
		return;

    //- OfN this does the sentry to not return to rotate status after enemy becomes not visible or died
    // it doesn't alter the real behaviour only the look
    if (self.attack_finished > time)
    {
        self.has_holo=1;
        return;
    }

    if (self.has_holo==1)
    {
        self.has_holo=0;
		sound (self, CHAN_ITEM, "weapons/trr2lost.wav", 0.25, ATTN_NORM);        
    }
	
	if (self.heat == 0)
	{
		self.ideal_yaw = anglemod(self.waitmin);
		ChangeYaw();
                                                          // 15                                              // 16 or 14
		//was if ((anglemod(self.angles_y) <= (self.waitmin + 1)) && (anglemod(self.angles_y) >= (self.waitmin - 2)))  //CH after the && fixed spaz sent!!
        if ((anglemod(self.angles_y) <= (self.waitmin + 1)) && (anglemod(self.angles_y) >= (self.waitmin - 2)))  //CH after the && fixed spaz sent!!
		{
			self.heat = 1;
			if (random() < 0.1)
				sound (self, CHAN_ITEM, "weapons/turridle.wav", 1, ATTN_NORM);
		}
	}
	else
	{
		self.ideal_yaw = anglemod(self.waitmax);
		ChangeYaw();

		//was if ((anglemod(self.angles_y) >= (self.waitmax - 1 )) && (anglemod(self.angles_y) <= (self.waitmax + 2)))  //CH after the && fixed spaz sent!!
        if ((anglemod(self.angles_y) >= (self.waitmax - 1 )) && (anglemod(self.angles_y) <= (self.waitmax + 2)))  //CH after the && fixed spaz sent!!
			self.heat = 0;
	}
};

//================================================0
// new RANGE_VERYFAR hacked sentries can shot at it

float(entity targ) rangesentry =
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
    if (r < 2000)
        return RANGE_FAR;
    return RANGE_VERYFAR;
};


float() Sentry_FindTarget =
{
	self.enemy = world; //CH for sbar

	if (infokey(world,"ceasefire")=="on")
		return FALSE;
    
    local entity client;
	local float	r, gotone, loopc;

	//WK Hack to get floating sentry working
	if (self.tf_items & NIT_TURRET) {
		self.origin_z = self.origin_z - 40;
	}

	// Try a few checks to make it react faster
	r = 0;
	loopc = 0;
	gotone = FALSE;
	//WK Theortetically this will check every client on the server now
	while (loopc < 32 && gotone == FALSE) //WK 3
	{
		client = checkclient();

		gotone = TRUE;

		if (!client)
			gotone = FALSE;

		if (!Pharse_Client(client, self, 1, 0, 0, 1))
			gotone = FALSE;

		r = rangesentry (client);

        //- ofn
		//if (r == RANGE_FAR)
		//	gotone = FALSE;			
	
		//WK Hack, turret should be able to see in all directions...
		if (!(self.tf_items & NIT_TURRET)) {

			if (r == RANGE_NEAR)
			{
				if (client.show_hostile < time && !infront (client))
					gotone = FALSE;
			}
			else if (r == RANGE_MID)
			{
				if (!infront (client))
					gotone = FALSE;
			}
            else if (r == RANGE_FAR) //- OfN - Sentries with enhanced circuits can shot at far range
			{
				if (!(self.num_mines & IMPROVED_FOUR) || !infront (client))
					gotone = FALSE;
			}
		}
        else //- OfN - a turretized sentry gun... 
        {
            if (r == RANGE_FAR && !(self.num_mines & IMPROVED_FOUR))
                gotone = FALSE;
        }

        //- OfN ----------------//
        if (r == RANGE_VERYFAR)
            gotone = FALSE;
        //----------------------//

		loopc = loopc + 1;
		//WK Solve a bug in sentry targetting?
		if (gotone) loopc = 1000;
	}

    if (!gotone) //if no player target found lets scan for monsters and army..
    {
        local entity te;

        te = find(world, message,"XX");

        while (te != world && gotone == FALSE)
        {
            gotone = TRUE;

            if (Teammate(self.real_owner.team_no,te.real_owner.team_no))
                gotone = FALSE;
            else if (!IsMonster(te))
                gotone = FALSE;
            else if (te.health <= 0)
                gotone = FALSE;
            else if ( (!(self.tf_items & NIT_TURRET) && !visible2x(self,te)) || ((self.tf_items & NIT_TURRET) && !visible2(self,te)))
                gotone = FALSE;           
            else            
            {
                r = rangesentry(te);

                //WK Hack, turret should be able to see in all directions...
                if (!(self.tf_items & NIT_TURRET)) {

                    if (r == RANGE_NEAR)
                    {
                        if (!infront (te))
                            gotone = FALSE;
                    }
                    else if (r == RANGE_MID)
                    {
                        if (!infront (te))
                            gotone = FALSE;
                    }
                    else if (r == RANGE_FAR) //- OfN - Sentries with enhanced circuits can shot at far range
                    {
                        if (!(self.num_mines & IMPROVED_FOUR) || !infront (te))
                            gotone = FALSE;
                    }
                }
                else //- OfN - a turretized sentry gun... 
                {
                    if (r == RANGE_FAR && !(self.num_mines & IMPROVED_FOUR))
                        gotone = FALSE;
                }

                //- OfN ----------------//
                if (r == RANGE_VERYFAR)
                    gotone = FALSE;
                //----------------------//

            } // this is the ELSE of !isMonster()

            if (gotone)
                client=te;
           
            te = find(te, message, "XX");

        } // while

    } //monster scanning

	//WK Unhack our hack
	if (self.tf_items & NIT_TURRET) {
		self.origin_z = self.origin_z + 40;
	}

	if (!gotone)
		return FALSE;

	// Found a Target
	self.enemy = client;
	
    //- OfN - what was this for??
    /*if (self.enemy.classname != "player")
	{
		self.enemy = self.enemy.enemy;
		if (self.enemy.classname != "player")
		{
			self.enemy = world;
			return FALSE;
		}
	}*/
	
	Sentry_FoundTarget ();

	return TRUE;
};

void() Sentry_FoundTarget =
{
	// Cannon Powerup Sound?
	if (self.ammo_shells > 0 || (self.ammo_rockets > 0 && self.weapon == 3))
    {
        if (self.attack_finished < time) //- OfN -
            sound (self, CHAN_VOICE, "weapons/turrspot.wav", 1, ATTN_NORM);
    }

	Sentry_HuntTarget ();
	if (self.super_damage_finished < time)
	{
        self.super_damage_finished = time + 1.0; //WK Was at .5, which was too fast
        
        if (self.num_mines & IMPROVED_FOUR)
            self.super_damage_finished = time + 0.65; //- OfN - improved circuits! heh
    }
};

void() Sentry_HuntTarget =
{
	self.goalentity = self.enemy;
	if (self.weapon == 1)
		self.think = lvl1_sentry_atk1;
	else if (self.weapon == 2)
		self.think = lvl2_sentry_atk1;
	else // if (self.weapon == 3)
	{
		if (self.ammo_shells <= 0 && self.ammo_rockets > 0) //CH has rockets but no shells
			self.think = lvl3_sentry_atk4;
		else
			self.think = lvl3_sentry_atk1;
	}
	self.ideal_yaw = vectoyaw(self.enemy.origin - self.origin);
	self.nextthink = time + 0.1;
	
    //SUB_AttackFinished (0.5);	// WK Does this do anything?
                                // - OfN - Nope lol it didnt
    local float tfactor;
    tfactor=1;

    //- OfN - Does this sentry has enhanced circuits? if so.. cut down lock time
    if (self.num_mines & IMPROVED_FOUR) tfactor=0.5;

    //WK --- Invisible people take longer for sentries to lock onto
	// because they have to use their heat sensors
	if (self.enemy.modelindex == modelindex_null)
		self.nextthink = time + (2*tfactor);	// Must acquire a heat signal
	else if (self.enemy.modelindex == modelindex_eyes)
		self.nextthink = time + (1.5*tfactor);	// Some visual, so its a little easier
	else
		self.nextthink = time + (0.5*tfactor);	// Some visual, so its a little easier
};

void() Sentry_Pain =
{
	// Update the owner's status bar
	self.real_owner.StatusRefreshTime = time + 0.2;
//CH special sbar  for eng.
	self.real_owner.StatusBarScreen = 1;
};

void() Sentry_Die =
{
	sprint(self.real_owner, PRINT_HIGH, "Your sentry gun was destroyed.\n");
	self.real_owner.has_sentry = self.real_owner.has_sentry - 1;
	if (self.real_owner.has_sentry < 0)
		self.real_owner.has_sentry = 0;

	ThrowGib("progs/t2gib1.mdl", -70);
	ThrowGib("progs/t2gib2.mdl", -70);
	ThrowGib("progs/t2gib3.mdl", -70);
    ThrowGib("progs/t2gib4.mdl", self.skin);

	if (self.classname == "building_sentrygun_base")
	{
		if (self.oldenemy)
			dremove(self.oldenemy);
	}
	else
	{
		if (self.trigger_field)
			dremove(self.trigger_field);
	}

	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_EXPLOSION);
	WriteCoord (MSG_MULTICAST, self.origin_x);
	WriteCoord (MSG_MULTICAST, self.origin_y);
	WriteCoord (MSG_MULTICAST, self.origin_z);
	multicast (self.origin, MULTICAST_PHS);
    dremove(self);
};

float() Sentry_Fire =
{
	local vector dir;
	local vector miss_factor;

    //- OfN -
    local vector soffset;
    soffset = '0 0 0';
    
    if (!(self.tf_items & NIT_TURRET))
        soffset = '0 0 20';

    // this on the end..
    //self.attack_finished = time + SENTRY_UNLOCKTIME; // don't rotate immediately after target invisible or dead

	if (infokey(world,"ceasefire")=="on") //Cyto
			return FALSE;

	//WK Stop gun from shooting at dead spies
	if (self.enemy.is_feigning)
		return FALSE;

	//WK Hack to get floating sentry working - reset before all the returns
	if (self.tf_items & NIT_TURRET) self.origin_z = self.origin_z - 40;
	
	// Only fire if they're within sight
	dir = self.enemy.origin - self.origin;
	if (vlen(dir) > 2048) //WK Don't fire if they're too far away
	{
		if (self.tf_items & NIT_TURRET) self.origin_z = self.origin_z + 40;
		return FALSE;
	}
	dir = normalize(dir);

	//WK Turret can shoot in any direction
	if (!(self.tf_items & NIT_TURRET)) {
		if ((self.ideal_yaw - anglemod(self.angles_y)) < -10 || (self.ideal_yaw - anglemod(self.angles_y)) > 10) {
			return FALSE;
		}
	}
	if (self.ammo_shells >= 1)
		self.ammo_shells = self.ammo_shells - 1;
	if (self.ammo_shells < 1) //WK Disallow half-shells
		self.ammo_shells = 0;
	if ((self.ammo_shells <= 0 && self.weapon != 3) || (self.ammo_shells <= 0 && self.ammo_rockets <= 0 && self.weapon == 3)) //CH stay on target if have rockets
	{
		if (self.tf_items & NIT_TURRET) self.origin_z = self.origin_z + 40;
		return FALSE;
	}
	//CH this further checks while firing
	traceline (self.origin + soffset, self.enemy.origin, TRUE, self);
	if (trace_fraction != 1 || trace_endpos != self.enemy.origin)
	{
		if (self.tf_items & NIT_TURRET) self.origin_z = self.origin_z + 40;
		return FALSE;
	}

	if (self.ammo_shells > 0)
	{
		//WK muzzleflash();
		self.effects = self.effects | EF_DIMLIGHT;
	/*	if (self.tf_items & NIT_TURRET) 
			sound (self ,CHAN_WEAPON, "weapons/asscan2.wav", 1, ATTN_NORM);
		else */
		//sound (self ,CHAN_WEAPON, "weapons/sniper.wav", 1, ATTN_NORM);
        sound (self ,CHAN_WEAPON, "weapons/sntr666.wav", 1, ATTN_NORM);
		deathmsg = DMSG_SENTRYGUN_BULLET;
	}



////////////
//WK Our hacked attempt to make sentries shoot right
	//Make base not shootable //CH if its not floating it needs this
    if (!(self.tf_items & NIT_TURRET))
	{
		if (self.trigger_field)	self.trigger_field.solid = SOLID_NOT;
        //soffset = '0 0 20'; // non-turretized sentries correction
	}

	if (self.is_malfunctioning & SCREWUP_TWO)
	{
		miss_factor_z = random() * 200 - 100;
		miss_factor_y = random() * 200 - 100;
		miss_factor_x = random() * 200 - 100;
		traceline (self.origin + soffset, self.enemy.origin + miss_factor, FALSE, self);
	}
	else
		traceline (self.origin + soffset, self.enemy.origin, FALSE, self);
	if (trace_fraction != 1.0 && trace_ent.takedamage && self.ammo_shells > 0) //Hit something and has shells
	{
		SpawnBlood (trace_endpos, 50);
		
        local float thedmg;
        local float therange;

        therange = rangesentry(trace_ent);
        thedmg = 6;

        // OfN - damage now depends on distance to target
        if (therange == RANGE_MELEE)
            thedmg = 12;
        else if (therange == RANGE_NEAR)
            thedmg = 6;
        else if (therange == RANGE_MID)
            thedmg = 4;
        else if (therange == RANGE_FAR) // only circuit hacked sentries shot at this range
            thedmg = 3;
        else thedmg = 2; // this shouldnt happen ever (RANGE_VERYFAR)

        // OfN - hacked sentries do more damage (improved circuits)
        if (self.num_mines & IMPROVED_FOUR)
            thedmg = thedmg * 1.25; // 1.25 too high?

		TF_T_Damage (trace_ent, self, self, thedmg, TF_TD_NOTTEAM, TF_TD_SHOT);
	}
    else if (trace_fraction != 1.0 && trace_ent.classname == "force_field")
    {
       FieldExplosion(trace_ent,trace_endpos,trace_ent);
       PutFieldWork(trace_ent);
    }
    

	//FireBullets (1, dir, '0.1 0.1 0');
	//CH if its not floating it needs this
	if (!(self.tf_items & NIT_TURRET))
	{
		if (self.trigger_field)	self.trigger_field.solid = SOLID_BBOX;
	}
/////////////

	// Level 3 Turrets fire rockets every 3 seconds
	if (self.weapon == 3 && self.ammo_rockets > 0 && self.super_damage_finished < time)
	{
		//sound (self, CHAN_WEAPON, "weapons/rocket1i.wav", 1, ATTN_NORM); UGLY AND STOPS COOL SOUND
        // wtf happens here, why is this the supernailgun sound?
		if (self.is_malfunctioning & SCREWUP_THREE)
		{
			local float damg;
			damg = random() * 50 + 120;
			T_RadiusDamage(self, self, damg, world);
			WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
			WriteByte (MSG_MULTICAST, TE_EXPLOSION);
			WriteCoord (MSG_MULTICAST, self.origin_x);
			WriteCoord (MSG_MULTICAST, self.origin_y);
			WriteCoord (MSG_MULTICAST, self.origin_z);
			if (self.tf_items & NIT_TURRET)
				self.origin_z = self.origin_z + 40;
			return FALSE;
		}

		newmis = spawn ();
		newmis.owner = self;
		newmis.movetype = MOVETYPE_FLYMISSILE;
		newmis.solid = SOLID_BBOX;
			
		// set newmis speed
		if (self.is_malfunctioning & SCREWUP_TWO) // SB - oh no we've been hax0red
		{
			miss_factor_z = random() * 200 - 100;
			miss_factor_y = random() * 200 - 100;
			miss_factor_x = random() * 200 - 100;
		}
		else
		{	
			miss_factor_z = 0;
			miss_factor_y = 0;
			miss_factor_x = 0;
		}

		if (self.tf_items & NIT_TURRET) 
			newmis.velocity = normalize(self.enemy.origin + miss_factor - (self.origin - '0 0 16')) * 800;
		else
			newmis.velocity = normalize(self.enemy.origin + miss_factor - (self.origin + '0 0 16')) * 800;
		newmis.angles = vectoangles(newmis.velocity);
		newmis.weapon = DMSG_SENTRYGUN_ROCKET;
		newmis.touch = T_MissileTouch;

		// set newmis duration
		newmis.nextthink = time + 5;
		newmis.think = SUB_Remove;

		setmodel (newmis, "progs/missile.mdl");
		setsize (newmis, '0 0 0', '0 0 0');
		if (self.tf_items & NIT_TURRET) //Determines if rocket should spawn above or below sent		
			setorigin (newmis, self.origin + v_forward*8 - '0 0 16'); //CH make rocket 16 below
		else
			setorigin (newmis, self.origin + v_forward*8 + '0 0 16'); //CH make rocket 16 above

		self.super_damage_finished = time + 3;

        // - OfN - if this sentry has enhanced circuits then delay between rockets firing is cut half
        if (self.num_mines & IMPROVED_FOUR) self.super_damage_finished = time + 1.5;

		self.ammo_rockets = self.ammo_rockets - 1;

		if (self.ammo_rockets == 5) //CH 10 was too high
			sprint(self.real_owner, PRINT_HIGH, "Sentry Gun is low on rockets.\n");
	}
	// Warn owner that it's low on ammo
	//WK if (self.ammo_shells == 0 && (random() < 0.1))
	if ((self.ammo_shells == 0 && self.weapon != 3) || (self.ammo_shells == 0 && self.weapon == 3 && self.ammo_rockets > 0 && (random() < 0.05))) //CH .05 seems to be good.
		sprint(self.real_owner, PRINT_HIGH, "Sentry Gun is out of shells.\n");
	else if (self.ammo_shells == 20)
		sprint(self.real_owner, PRINT_HIGH, "Sentry Gun is low on shells.\n");

	//WK < 0.1
	if (self.ammo_rockets == 0 && self.weapon == 3 && (random() <= 0.1))
		sprint(self.real_owner, PRINT_HIGH, "Sentry Gun is out of rockets.\n");
	
	if (self.tf_items & NIT_TURRET) self.origin_z = self.origin_z + 40;

    self.attack_finished = time + SENTRY_UNLOCKTIME + 2 * random() - 1; // don't rotate immediately after target invisible or dead
    
    return TRUE;
};

//WK Returns TRUE if the vector is not a spot a turret can attach to
float(vector vec) BadSpot =
{
	/*
	if (pointcontents(vec) == CONTENTS_SOLID)
		sprint(self.real_owner,PRINT_HIGH,"SOLID Point\n");
	else if (pointcontents(vec) == CONTENTS_EMPTY)
		sprint(self.real_owner,PRINT_HIGH,"EMPTY Point\n");
	else if (pointcontents(vec) == CONTENTS_SKY)
		sprint(self.real_owner,PRINT_HIGH,"SKY Point\n");
	else if (pointcontents(vec) == CONTENTS_WATER)
		sprint(self.real_owner,PRINT_HIGH,"WATER Point\n");
	else
		sprint(self.real_owner,PRINT_HIGH,"BUG: Other Point\n");
	*/
	if (pointcontents(vec) == CONTENTS_SKY)
		return TRUE;
	return FALSE;
};

//WK Sentry Touch function
//Will kill bad guy 
void() Sentry_Touch =
{
	//WK Check for blockage
	if (pointcontents(self.origin) == CONTENTS_SKY)
	{
		sprint(self.real_owner, PRINT_HIGH, "Your sentry gun flew away.\n");
		Sentry_Die();
		return;
	}

	if (other.takedamage && !(self.tf_items & NIT_TURRET)) // OfN - fixme: doesn't check for enemy disguised spies
	{
		deathmsg = DMSG_BUG_ZAPPER;

        if (IsMonster(other))
        {
            if (!Teammate(other.real_owner.team_no, self.real_owner.team_no))
            {
                TF_T_Damage (other, self, self, 400, TF_TD_NOTTEAM, TF_TD_ELECTRICITY);
        		return;
            }
            
            return;
        }

		if (!Teammate(other.team_no,self.real_owner.team_no) && (other.is_undercover != 1)) // <== FIXME
			//TF_T_Damage (other, self, self.real_owner, 400, TF_TD_NOTTEAM, TF_TD_ELECTRICITY);
			TF_T_Damage (other, self, self, 400, TF_TD_NOTTEAM, TF_TD_ELECTRICITY);
		return;
	}
	//I'm in midflight and hit something
	if (self.tf_items & NIT_TURRET && self.movetype == MOVETYPE_FLY) 
	{
		//WK Check to see if we are blocked
		//WK These numbers seem to be about right
		if ( BadSpot(self.origin + '0 0 20') || BadSpot(self.origin + '0 0 22'))
		{
			sprint(self.real_owner, PRINT_HIGH, "Your sentry gun flew away.\n");
			Sentry_Die();
			return;
		}
		if (other == world) { //The eagle has landed!
		//	sprint(self.real_owner, PRINT_HIGH, "The eagle has landed!\n");
			self.flags = self.flags | FL_ONGROUND;
			self.movetype = MOVETYPE_STEP;
			self.origin_z = self.origin_z + 32;//32; // was 40, old custom bug? fixed
			return;
		}
		else if (other.classname == "player")
		{
			deathmsg = DMSG_BUG_ZAPPER;
			//TF_T_Damage (other, self, self.real_owner, 400, TF_TD_NOTTEAM, TF_TD_ELECTRICITY);
			TF_T_Damage (other, self, self, 400, TF_TD_NOTTEAM, TF_TD_ELECTRICITY);

            self.velocity_z = 200; //- OfN reset velocity, not stop
		}
		else
		{
			deathmsg = DMSG_BUG_ZAPPER;
			//TF_T_Damage (other, self, self.real_owner, 400, TF_TD_NOTTEAM, TF_TD_ELECTRICITY);
			if (!Teammate(other.real_owner.team_no,self.real_owner.team_no))
				TF_T_Damage (other, self, self, 400, TF_TD_NOTTEAM, TF_TD_ELECTRICITY);
			Sentry_Die();
		}
		//sprint(self.real_owner, PRINT_HIGH, "The eagle has died.\n");
	}
};
