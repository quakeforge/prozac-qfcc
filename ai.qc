#include "defs.qh"
#include "ai.qh"
void() movetarget_f;
void() t_movetarget;
//WK Selective AIs
#ifdef COOP_MODE
void() knight_walk1;
void() knight_bow6;
void() knight_bow1;
void() demon1_fire1;
#endif

void(entity targ, entity inflictor, entity attacker, float damage) T_Damage;

//- OfN -
float()	WizardCheckAttack;
float(entity thing) IsMonsterNonArmy;
void(entity themonster) KillTheMonster;
string(entity themonster) GetMonsterName;
void (entity themonster) PutMonsterStand;
float(entity thebuilding) IsOffenseBuilding;
void (entity themonster) PutMonsterWalk;
float() CheckAttack;


void() custom_demon_die;
void() custom_shambler_die;
void() custom_grunt_die;
void() wiz_die;
/*

.enemy
Will be nil if not currently angry at anyone.

.movetarget
The next path spot to walk toward.  If .enemy, ignore .movetarget.
When an enemy is killed, the monster will try to return to it's path.

.hunt_time
Set to time + something when the player is in sight, but movement straight for
him is blocked.  This causes the monster to use wall following code for
movement direction instead of sighting on the player.

.ideal_yaw
A yaw angle of the intended direction, which will be turned towards at up
to 45 deg / state.  If the enemy is in view and hunt_time is not active,
this will be the exact line towards the enemy.

.pausetime
A monster will leave it's stand state and head towards it's .movetarget when
time > .pausetime.

walkmove(angle, speed) primitive is all or nothing
*/


//
// globals
//
float	current_yaw;
float	enemy_yaw, enemy_vis;
float   enemy_infront, enemy_range;


//
// when a monster becomes angry at a player, that monster will be used
// as the sight target the next frame so that monsters near that one
// will wake up even if they wouldn't have noticed the player
//
entity	sight_entity;
float	sight_entity_time;

float(float v) anglemod =
{
	while (v >= 360)
		v = v - 360;
	while (v < 0)
		v = v + 360;
	return v;
};
void(entity test) AI_Check_Contents =
{
	if (test.solid != SOLID_SLIDEBOX)
	{
	    bprint(PRINT_HIGH, "CRAZY! AI_Check_Contents, test.solid=");
	    bprint(PRINT_HIGH, ftos(test.solid));
	    bprint(PRINT_HIGH, "\n");
	}
	if (test.movetype != MOVETYPE_TOSS && test.movetype != MOVETYPE_STEP)
	{
	    bprint(PRINT_HIGH, "CRAZY! AI_Check_Contents, test.movetype=");
	    bprint(PRINT_HIGH, ftos(test.movetype));
	    bprint(PRINT_HIGH, "\n");
	}
	

//CH demons (and other ai) can be hurt by liquids //- OfN completely changed!
	if (entpointcontents(test) ==  CONTENTS_EMPTY && IsMonsterNonArmy(self) && self.health < self.max_health)
	{	// Heal it
		if (self.dmgtime < time)
		{
			local float heal, rate;
            heal = 3;
            rate = 1.5;
            
            if (self.classname=="monster_shambler")
            {
                heal = SHAMBLER_REGEN;
                rate = SHAMBLER_REGRATE;
            }
            else if (self.classname=="monster_wizzard")
            {
                heal = SCRAG_REGEN;
                rate = SCRAG_REGRATE;
            }
            else if (self.classname=="mosnter_demon1")
            {
                heal = FIEND_REGEN;
                rate = FIEND_REGRATE;
            }

	    if (self.is_malfunctioning)
	    {
		heal = 0;
	    }

            self.dmgtime = time + rate;
			self.health = self.health + heal;//self.has_tesla - 2;
			
            if (self.health > self.max_health)
				self.health = self.max_health;
			//T_Damage (self, nil, nil, 4*self.waterlevel);
			//TF_T_Damage (self, nil, nil, 5, 0, TF_TD_ELECTRICITY);
		}
	}
	if (entpointcontents(test) == CONTENTS_LAVA)
	{	// do damage
		if (self.dmgtime < time)
		{
			self.dmgtime = time + 1;

			// Asbestos armor helps against lava, but I doubt it'll save you :)
			//TF_T_Damage (self, nil, nil, 25, 0, TF_TD_FIRE);
            if (IsMonster(self))            
            {
                local string MName;
                MName = GetMonsterName(self);
                if (self.ltime > time - 4) //- OfN - if it felt just after summon
                {
                    local float r;
                    r=random();
                    if (r<0.4)
                    {
                        bprint(PRINT_MEDIUM,self.real_owner.netname);
                        bprint(PRINT_MEDIUM," throws his ");
                        bprint(PRINT_MEDIUM,MName);
                        bprint(PRINT_MEDIUM," to the lava\n");
                    }
                    else
                    {
                        bprint(PRINT_MEDIUM,self.real_owner.netname);
                        bprint(PRINT_MEDIUM," realizes now why lava isn't the best place to put his ");
                        bprint(PRINT_MEDIUM,MName);
                        bprint(PRINT_MEDIUM,"\n");
                    }
                }
                else
                {
                    bprint(PRINT_MEDIUM,self.real_owner.netname);
                    bprint(PRINT_MEDIUM,"'s ");
                    bprint(PRINT_MEDIUM,MName);
                    bprint(PRINT_MEDIUM," burned into the lava\n");
                }
                
                self.health = -1;
                KillTheMonster(self);
            }
		}
	}
	else if (entpointcontents(test) ==  CONTENTS_SLIME)
	{	// do damage
		if (self.dmgtime < time)
		{
			self.dmgtime = time + 1;
			//T_Damage (self, nil, nil, 4*self.waterlevel);
			//TF_T_Damage (self, nil, nil, 5, 0, TF_TD_ELECTRICITY);

            if (IsMonster(self))            
            {
                local string MName;
                MName = GetMonsterName(self);
                if (self.ltime > time - 4) //- OfN - if it felt just after summon
                {
                    bprint(PRINT_MEDIUM,self.real_owner.netname);
                    bprint(PRINT_MEDIUM," throws his ");
                    bprint(PRINT_MEDIUM,MName);
                    bprint(PRINT_MEDIUM," to the slime\n");
                }
                else
                {
                    bprint(PRINT_MEDIUM,self.real_owner.netname);
                    bprint(PRINT_MEDIUM,"'s ");
                    bprint(PRINT_MEDIUM,MName);
                    bprint(PRINT_MEDIUM," died into the slime\n");
                }

                self.health = -1;
                KillTheMonster(self);
            }
		}
	}
	/* WK Removed because water is ok for monsters, sheesh
	Whatever you think, ceaf it is. */
    //- OfN - what the fuck means "ceaf"? heh
	else if (entpointcontents(test) == CONTENTS_WATER && allow_watermonsters == FALSE)
	{
		if (self.classname == "monster_demon1")
		{	// do damage
			if (self.dmgtime < time)
			{
//				self.dmgtime = time + 1;
				//T_Damage (self, nil, nil, 4*self.waterlevel);
				//TF_T_Damage (self, nil, nil, (self.health - 1), 0, TF_TD_IGNOREARMOUR);
                
                //self.think = custom_demon_die;
                //self.nextthink=time+0.1;
                

                if (self.ltime > time - 4) //- OfN - if it felt after summon
                {
                    bprint(PRINT_MEDIUM,self.real_owner.netname);
                    bprint(PRINT_MEDIUM," enjoys throwing his demon to the water\n");
                }
                else
                {
                    bprint(PRINT_MEDIUM,self.real_owner.netname);
                    bprint(PRINT_MEDIUM,"'s demon touches the water and dies\n");
                }

                self.health = -1;
                custom_demon_die();
			}
		}
		else if (self.classname == "monster_army")
		{	// do damage
			if (self.dmgtime < time)
			{
//				self.dmgtime = time + 1;
				//T_Damage (self, nil, nil, 4*self.waterlevel);
				//TF_T_Damage (self, nil, nil, (self.health - 1), 0, TF_TD_IGNOREARMOUR);
                
                
                if (self.ltime > time - 4) //- OfN - if it felt just after summon
                {
                    bprint(PRINT_MEDIUM,self.real_owner.netname);
                    bprint(PRINT_MEDIUM," teleports his soldier to the water\n");
                    self.waterlevel = 3;
                }
                else
                {
                    bprint(PRINT_MEDIUM,"Unfortunately, ");
                    bprint(PRINT_MEDIUM,self.real_owner.netname);
                    bprint(PRINT_MEDIUM,"'s soldier didn't learn to swim when he was a kid\n");
                    self.waterlevel = 3;
                }
                
                self.health = -1; //nomore soldiers in water
                custom_grunt_die();
            
            }
		}
		else if (self.classname == "monster_shambler")
		{	// do damage
			if (self.dmgtime < time)
			{
//				self.dmgtime = time + 1;
				//T_Damage (self, nil, nil, 4*self.waterlevel);
				//TF_T_Damage (self, nil, nil, (self.health - 1), 0, TF_TD_IGNOREARMOUR);

                self.think = custom_shambler_die;
                self.nextthink=time+0.1;

                bprint(PRINT_MEDIUM,self.real_owner.netname);
                bprint(PRINT_MEDIUM,"'s shambler is too fat to swim\n");
                
                self.health = -1;
                custom_shambler_die();
			}
		}
        /*else if (self.classname == "monster_wizard") //- OfN - they can stay in water now
		{	// do damage
			if (self.dmgtime < time)
			{
//				self.dmgtime = time + 1;
				//T_Damage (self, nil, nil, 4*self.waterlevel);
				//TF_T_Damage (self, nil, nil, (self.health - 1), 0, TF_TD_IGNOREARMOUR);

                self.think = wiz_die;
                self.nextthink=time+0.1;
                
                if (self.ltime > time - 5) //- OfN - if it felt after summon
                {
                    bprint(PRINT_MEDIUM,self.real_owner.netname);
                    bprint(PRINT_MEDIUM," learns that water is a bad place to summon\n");
                    //self.has_holo=666;
                }
                else
                {
                    bprint(PRINT_MEDIUM,self.real_owner.netname);
                    bprint(PRINT_MEDIUM,"'s scrag touches water and dies\n");
                }
			}
		}*/
	}
	
};

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


void() movetarget_f =
{
	if (!self.targetname)
		objerror ("monster_movetarget: no targetname");
		
	self.solid = SOLID_TRIGGER;
	self.touch = t_movetarget;
	setsize (self, '-8 -8 -8', '8 8 8');
	
};

/*QUAKED path_corner (0.5 0.3 0) (-8 -8 -8) (8 8 8)
Monsters will continue walking towards the next target corner.
*/
void() path_corner =
{
	if (CheckExistence() == FALSE)
	{
		dremove(self);
		return;
	}

	movetarget_f ();
};


/*
=============
t_movetarget

Something has bumped into a movetarget.  If it is a monster
moving towards it, change the next destination and continue.
==============
*/
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

	if (self.classname == "monster_ogre")
		sound (self, CHAN_VOICE, "ogre/ogdrag.wav", 1, ATTN_IDLE);// play chainsaw drag sound

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



//============================================================================

/*
=============
range

returns the range catagorization of an entity reletive to self
0	melee range, will become hostile even if back is turned
1	visibility and infront, or visibility and show hostile
2	infront and show hostile
3	only triggered by damage
=============
*/
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


float (entity targ) visible;

/*
=============
infront

returns 1 if the entity is in front (in sight) of self
=============
*/
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

/*
===========
ChangeYaw

Turns towards self.ideal_yaw at self.yaw_speed
Sets the global variable current_yaw
Called every 0.1 sec by monsters
============
*/
/*

void() ChangeYaw =
{
	local float		ideal, move;

//current_yaw = self.ideal_yaw;
// mod down the current angle
	current_yaw = anglemod( self.angles.y );
	ideal = self.ideal_yaw;
	
	if (current_yaw == ideal)
		return;
	
	move = ideal - current_yaw;
	if (ideal > current_yaw)
	{
		if (move > 180)
			move = move - 360;
	}
	else
	{
		if (move < -180)
			move = move + 360;
	}
		
	if (move > 0)
	{
		if (move > self.yaw_speed)
			move = self.yaw_speed;
	}
	else
	{
		if (move < 0-self.yaw_speed )
			move = 0-self.yaw_speed;
	}

	current_yaw = anglemod (current_yaw + move);

	self.angles.y = current_yaw;
};
*/



//============================================================================

void() HuntTarget =
{
	self.goalentity = self.enemy;
	self.think = self.th_run;
	self.ideal_yaw = vectoyaw(self.enemy.origin - self.origin);
	self.nextthink = time + 0.1;
	SUB_AttackFinished (1);	// wait a while before first attack
};

void() SightSound =
{
local float	rsnd;

	if (self.classname == "monster_ogre")	
		sound (self, CHAN_VOICE, "ogre/ogwake.wav", 1, ATTN_NORM);
	else if (self.classname == "monster_knight")
		sound (self, CHAN_VOICE, "knight/ksight.wav", 1, ATTN_NORM);
	else if (self.classname == "monster_shambler")
		sound (self, CHAN_VOICE, "shambler/ssight.wav", 1, ATTN_NORM);
	else if (self.classname == "monster_demon1")
		sound (self, CHAN_VOICE, "demon/sight2.wav", 1, ATTN_NORM);
	else if (self.classname == "monster_wizard")
		sound (self, CHAN_VOICE, "wizard/wsight.wav", 1, ATTN_NORM);
	else if (self.classname == "monster_zombie")
		sound (self, CHAN_VOICE, "zombie/z_idle.wav", 1, ATTN_NORM);
	else if (self.classname == "monster_dog")
		sound (self, CHAN_VOICE, "dog/dsight.wav", 1, ATTN_NORM);
	else if (self.classname == "monster_hell_knight")
		sound (self, CHAN_VOICE, "hknight/sight1.wav", 1, ATTN_NORM);
	else if (self.classname == "monster_tarbaby")
		sound (self, CHAN_VOICE, "blob/sight1.wav", 1, ATTN_NORM);
	else if (self.classname == "monster_vomit")
		sound (self, CHAN_VOICE, "vomitus/v_sight1.wav", 1, ATTN_NORM);
	else if (self.classname == "monster_enforcer")
	{
		rsnd = rint(random() * 3);			
		if (rsnd == 1)
			sound (self, CHAN_VOICE, "enforcer/sight1.wav", 1, ATTN_NORM);
		else if (rsnd == 2)
			sound (self, CHAN_VOICE, "enforcer/sight2.wav", 1, ATTN_NORM);
		else if (rsnd == 0)
			sound (self, CHAN_VOICE, "enforcer/sight3.wav", 1, ATTN_NORM);
		else
			sound (self, CHAN_VOICE, "enforcer/sight4.wav", 1, ATTN_NORM);
	}
	else if (self.classname == "monster_army")
		sound (self, CHAN_VOICE, "soldier/sight1.wav", 1, ATTN_NORM);
	else if (self.classname == "monster_shalrath")
		sound (self, CHAN_VOICE, "shalrath/sight.wav", 1, ATTN_NORM);
};

void() FoundTarget =
{
	/* if (self.enemy.classname == "player")
	{	// let other monsters see this monster for a while
		sight_entity = self;
		sight_entity_time = time;
	} */
	
	//self.show_hostile = time + 1;		// wake up other monsters
	

	SightSound ();
	HuntTarget ();
};

//- OfN LookAround for monsters - grunty uses another one in grunty.qc
entity (entity scanner) LookAround =
{

    if (infokey(nil,"ceasefire")=="on") //OfN
	    return scanner;

	local entity		client;
	local float			gotatarget;

	client = findradius(scanner.origin, 2500);

	while (client)
	{
		gotatarget = 0;
		
        if (client != scanner && visible2(client, scanner))
		{
            
            #ifdef MAD_MONSTERS
            
            if (client.classname == "player" && IsMonsterNonArmy(scanner)) gotatarget = 1;
            
            #else
            
            if (client.classname == "player" && !Teammate(client.team_no, scanner.real_owner.team_no))
			{
                gotatarget = Pharse_Client(client, scanner, 1, 0, 0, 0);

                /*if (scanner.classname=="monster_army") // extra grunty checks
                {
                    if (client.is_undercover)
                        if (client.cutf_items & CUTF_JAMMER || !scanner.tf_items & NIT_SCANNER)
                            gotatarget=0;
                    if (client.modelindex == modelindex_null)
                        if (client.cutf_items & CUTF_JAMMER || !scanner.tf_items & NIT_SCANNER)
                            gotatarget=0;
                    if (client.modelindex == modelindex_eyes)
                        if (client.cutf_items & CUTF_JAMMER || !scanner.tf_items & NIT_SCANNER)
                            if (random() < 2 - scanner.has_tesla * random())
                                gotatarget=0;		
                }*/
            }
            
            #endif

            /*else if (client.classname == "monster_shambler")
			{
				if (!Teammate(client.real_owner.team_no,scanner.real_owner.team_no))
					gotatarget = 1;
			}
            else if (client.classname == "monster_wizard") //- OfN -
			{
				if (!Teammate(client.real_owner.team_no,scanner.real_owner.team_no))
					gotatarget = 1;
			}
			else if (client.classname == "monster_demon1")
			{
				if (!Teammate(client.real_owner.team_no,scanner.real_owner.team_no))
					gotatarget = 1;
			}
			else if (client.classname == "monster_army")
			{
				if (!Teammate(client.real_owner.team_no,scanner.real_owner.team_no))
					gotatarget = 1;
			}*/

            else if (IsMonster(client))
			{
				if (!Teammate(client.real_owner.team_no,scanner.real_owner.team_no))
					gotatarget = 1;
			}
			////////////////////////////////////////////////////////////////////////
            //else if (scanner.classname != "monster_army") 
				//gotatarget = 0;
            //--- GRUNTY STUFF ---
			/*else if (client.classname == "grenade" && client.netname == "land_mine")
			{
				if (!Teammate(client.owner.team_no,scanner.real_owner.team_no))
					gotatarget = 1;
			}
			else if (!Teammate(client.team_no, scanner.real_owner.team_no))
			{ //  && client.classname != "building_sentrygun_base"
				if (IsOffenseBuilding(client)) // for teslas isoffensiveb only returns true if not cloaked
					gotatarget = 1;                
			}*/	
            
		}
		if (gotatarget)
			return client;
		
		client = client.chain;
	}
	return scanner;
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
float() FindTarget =
{
	local entity	client;

// if the first spawnflag bit is set, the monster will only wake up on
// really seeing the player, not another monster getting angry

// spawnflags & 3 is a big hack, because zombie crucified used the first
// spawn flag prior to the ambush flag, and I forgot about it, so the second
// spawn flag works as well
	AI_Check_Contents(self); //CH check if in lava
	/* if (sight_entity_time >= time - 0.1 && !(self.spawnflags & 3) )
	{
		client = sight_entity;
		if (client.enemy == self.enemy)
			return TRUE;
	}
	else
	{
		client = checkclient ();
		if (!client)
			return FALSE;	// current check entity isn't in PVS
	} */
	if (random() >= 0.6) // don't always look around to save processor power
		return FALSE;
	client = LookAround(self); // search for targets
	
	if (client == self)
		return FALSE;

	if (client == self.enemy)
		return FALSE;

    if (!client) //- OfN - added, needed?
        return FALSE; 

	/*if (client.health < 0) // - OfN DONE IN PHARSE?
		return FALSE;

	if (client.flags & FL_NOTARGET)
		return FALSE;
	if (client.items & IT_INVISIBILITY)
		return FALSE;

	r = range (client);
	if (r == RANGE_FAR && self.classname == "monster_demon1")
		return FALSE;
		
	if (!visible (client))
		return FALSE;

	//WK Thief Invis 
	if (client.modelindex == modelindex_null)
		if (self.classname != "monster_demon1")
			return FALSE;
		else if (r > RANGE_MELEE)
			return FALSE;*/ // - OfN DONE IN PHARSE?

	//WK Thief Moving // - OfN DONE IN PHARSE?
	/*if (client.modelindex == modelindex_eyes)
	{
		if ( self.classname == "monster_army" || (self.classname == "monster_shambler" && self.has_tesla < 5))
			return FALSE;
		if (r > RANGE_MID) //Demons have to smell out thieves. :)
			return FALSE;
	}*/


	//WK Don't target observers - OfN done in pharse?
	//if (client.playerclass == PC_UNDEFINED && client.classname == "player")
	//	return FALSE;

	//WK Don't target disconnected players - OfN done in pharse?
	//if (client.has_disconnected)
	//	return FALSE;

	/*
	//WK Demons are team-aware, but they still get owners
	if (self.real_owner.team_no == client.team_no && client != self.real_owner)
		return FALSE;
	*/
	//WK Demon remake, they won't target owners now
	//if (self.real_owner.team_no == client.team_no )
	//	return FALSE;

	/*if (!Teammate(client.team_no,self.real_owner.team_no) && (client.is_undercover == 1)) // - OfN DONE IN PHARSE?
	{ //Spy
		if ( self.classname == "monster_army" || self.classname == "monster_wizard" || (self.classname == "monster_shambler" && self.has_tesla < 5))
			return FALSE;
		if ((r > RANGE_NEAR && self.classname == "monster_demon1") || (r > RANGE_MELEE && self.classname == "monster_shambler"))
			return FALSE;
		if (self.last_saveme_sound < time)
		{
			if (random() < 0.2)
				sound(client, CHAN_MISC, "player/gasp1.wav", 1, ATTN_NORM);	// Shocked
			else
				sound(client, CHAN_MISC, "speech/saveme1.wav", 1, ATTN_NORM);	// Call for a medic. :)
			sprint(self.real_owner,PRINT_HIGH,"Your demon has discovered a spy!\n");
			self.last_saveme_sound = time + 15;
		}
	}*/ // - OfN DONE IN PHARSE?

	/* WK Removed in the great demon AI revision of '00
	//TODO: Don't attack owner unless he's the only one in the room
	if (client == self.real_owner)
		if (random() < 0.8)
			return FALSE;
	*/

/* WK 360 field of view -- makes AIs a little more powerful
	if (r == RANGE_NEAR)
	{
		if (client.show_hostile < time && !infront (client))
			return FALSE;
	}
	else if (r == RANGE_MID)
	{
		if ( !infront (client))
			return FALSE;
	}
*/

//
// got one
//
	self.enemy = client;
	/* if (self.enemy.classname != "player")
	{
		self.enemy = self.enemy.enemy;
		if (self.enemy.classname != "player")
		{
			self.enemy = nil;
			return FALSE;
		}
	} */
	
	FoundTarget ();

	return TRUE;
};



//=============================================================================

void(float dist) ai_forward =
{
AI_Check_Contents(self); //CH check if in lava
	if (self.tfstate & TFSTATE_TRANQUILISED)
		walkmove (self.angles.y, (dist * (AI_TRANQ_FACTOR_UP / AI_TRANQ_FACTOR_DN))); //Tranq
	else
		walkmove (self.angles.y, dist);

};

void(float dist) ai_back =
{
AI_Check_Contents(self); //CH check if in lava
	if (self.tfstate & TFSTATE_TRANQUILISED)
		walkmove ( (self.angles.y+180), (dist * (AI_TRANQ_FACTOR_UP / AI_TRANQ_FACTOR_DN))); //Tranq
	else
		walkmove ( (self.angles.y+180), dist);

};


/*
=============
ai_pain

stagger back a bit
=============
*/
void(float dist) ai_pain =
{
AI_Check_Contents(self); //CH check if in lava
	if (self.tfstate & TFSTATE_TRANQUILISED)
		ai_back(dist * (AI_TRANQ_FACTOR_UP / AI_TRANQ_FACTOR_DN)); //Tranq
	else
		ai_back (dist);
/*
	local float	away;
	
	away = anglemod (vectoyaw (self.origin - self.enemy.origin) 
	+ 180*(random()- 0.5) );
	
	walkmove (away, dist);
*/
};

/*
=============
ai_painforward

stagger back a bit
=============
*/
void(float dist) ai_painforward =
{
AI_Check_Contents(self); //CH check if in lava
	if (self.tfstate & TFSTATE_TRANQUILISED)
		walkmove (self.ideal_yaw, (dist * (AI_TRANQ_FACTOR_UP / AI_TRANQ_FACTOR_DN))); //Tranq
	else
		walkmove (self.ideal_yaw, dist);
	
};

/*
=============
ai_walk

The monster is walking it's beat
=============
*/
void(float dist) ai_walk =
{
    AI_Check_Contents(self); //CH check if in lava
	
	if (self.tfstate & TFSTATE_TRANQUILISED)
		movedist = dist * (AI_TRANQ_FACTOR_UP / AI_TRANQ_FACTOR_DN); //Tranq
	else
		movedist = dist;

	/*if (self.classname == "monster_dragon")
	{
		movetogoal (dist);
		return;
	}*/
	
    // check for noticing a player
	if (FindTarget ())
		return;
	
	if (self.tfstate & TFSTATE_TRANQUILISED)
		movetogoal (dist * (AI_TRANQ_FACTOR_UP / AI_TRANQ_FACTOR_DN)); //Tranq
	else
		movetogoal (dist);	
};


/*
=============
ai_stand

The monster is staying in one place for a while, with slight angle turns
=============
*/
void() ai_stand =
{
	AI_Check_Contents(self); //CH check if in lava
	if (FindTarget ())
		return;
	
	if (time > self.pausetime)
	{
		self.th_walk ();
		return;
	}
	
// change angle slightly

};

/*
=============
ai_turn

don't move, but turn towards ideal_yaw
=============
*/
void() ai_turn =
{
	if (FindTarget ())
		return;
	
	ChangeYaw ();
};

//=============================================================================

/*
=============
ChooseTurn
=============
*/
void(vector dest3) ChooseTurn =
{
	local vector	dir, newdir;
	
	dir = self.origin - dest3;

	newdir.x = trace_plane_normal.y;
	newdir.y = 0 - trace_plane_normal.x;
	newdir.z = 0;
	
	if (dir * newdir > 0)
	{
		dir.x = 0 - trace_plane_normal.y;
		dir.y = trace_plane_normal.x;
	}
	else
	{
		dir.x = trace_plane_normal.y;
		dir.y = 0 - trace_plane_normal.x;
	}

	dir.z = 0;
	self.ideal_yaw = vectoyaw(dir);	
};

/*
============
FacingIdeal

============
*/
float() FacingIdeal =
{
	local	float	delta;
	
	delta = anglemod(self.angles.y - self.ideal_yaw);
	if (delta > 45 && delta < 315)
		return FALSE;
	return TRUE;
};


//=============================================================================

//WK Selective AIs -- only use demons for now
// SB and the other ones
float()	DemonCheckAttack;
//float()	SoldierCheckAttack;
float()	ShamCheckAttack;




float() CheckAnyAttack =
{
	if (!enemy_vis)
		return FALSE;
	if (self.classname == "monster_demon1")
		return DemonCheckAttack ();
/*	else if (self.classname == "monster_army")
		return SoldierCheckAttack ();*/ //- OfN - already commented
    else if (self.classname == "monster_wizard") ///////////////////////
        return WizardCheckAttack ();
	else if (self.classname == "monster_shambler")
		return ShamCheckAttack ();

    return CheckAttack ();
};


/*
=============
ai_run_melee

Turn and close until within an angle to launch a melee attack
=============
*/
void() ai_run_melee =
{
	AI_Check_Contents(self); //CH check if in lava
	self.ideal_yaw = enemy_yaw;
	ChangeYaw ();

	if (FacingIdeal())
	{
		self.th_melee ();
		self.attack_state = AS_STRAIGHT;
	}
};


/*
=============
ai_run_missile

Turn in place until within an angle to launch a missile attack
=============
*/
void() ai_run_missile =
{
    AI_Check_Contents(self); //CH check if in lava
	self.ideal_yaw = enemy_yaw;
	ChangeYaw ();
	if (FacingIdeal())
	{
		self.th_missile ();
		self.attack_state = AS_STRAIGHT;
	}
};

/*
=============
ai_run_fire

Turn in place until within an angle to launch a missile attack
=============
*/
void() ai_run_fire =
{
AI_Check_Contents(self); //CH check if in lava
	self.ideal_yaw = enemy_yaw;
	ChangeYaw ();
	if (FacingIdeal())
	{
		self.th_fireball ();
		self.attack_state = AS_STRAIGHT;
	}
};


/*
=============
ai_run_slide

Strafe sideways, but stay at aproximately the same range
=============
*/
void() ai_run_slide =
{
AI_Check_Contents(self); //CH check if in lava
	local float	ofs;
	
	self.ideal_yaw = enemy_yaw;
	ChangeYaw ();
	if (self.lefty)
		ofs = 90;
	else
		ofs = -90;
	
	if (walkmove (self.ideal_yaw + ofs, movedist))
		return;
		
	self.lefty = 1 - self.lefty;
	
	walkmove (self.ideal_yaw - ofs, movedist);
};


/*
=============
ai_run

The monster has an enemy it is trying to kill
=============
*/
void(float dist) ai_run =
{
	AI_Check_Contents(self); //CH check if in lava
	
	if (self.tfstate & TFSTATE_TRANQUILISED)
		movedist = dist * (AI_TRANQ_FACTOR_UP / AI_TRANQ_FACTOR_DN); //Tranq
	else
		movedist = dist;

	if (infokey(nil,"ceasefire")=="on") //CH
	{
        enemy_vis=FALSE;
        self.enemy=nil;
        self.goalentity=nil;

        if (self.movetarget)
        	self.th_walk ();
		else
	    	self.th_stand ();

        return;
    }

// see if the enemy is dead
	if (self.enemy.health <= 0 || self.enemy.has_disconnected)
	{
		self.enemy = nil;
	// FIXME: look all around for other targets
		/*if (self.oldenemy.health > 0 && !(self.oldenemy.has_disconnected))
		{
			self.enemy = self.oldenemy;
			HuntTarget ();
		}
		else
		{*///FIXES MAD MONSTERS? NO - currently fixed? (?)= NO
			if (self.movetarget)
				self.th_walk ();
			else
				self.th_stand ();

			return;
		//}
	}

    //- OfN - don't make them hunt for ever if not visible!! -//
    if (self.enemy && random() < 0.010 && !visible2(self,self.enemy))
    {                                       
        enemy_vis=FALSE; 

	self.enemy = nil; // FindTarget ignores self.enemy, duh (fixes stuck monsters)

        if (self.movetarget)
        	self.th_walk ();
		else
	    	self.th_stand ();
		return;
    }
    //-----------------------------------------//

	self.show_hostile = time + 1;		// wake up other monsters

// check knowledge of enemy
	
	enemy_vis = visible(self.enemy);
	if (enemy_vis)
		self.search_time = time + 3;

// look for other coop players

    //-ofn - FIXME:

// WK Stupid demon fix?	if (coop && self.search_time < time)
	if (self.search_time < time)
	{
		self.search_time = time + 3; //- OfN - Solves running stuck monters? NO

        if (FindTarget ())
			return;
	} //- OfN - It was really stupid FIXME 

	enemy_infront = infront(self.enemy);
	enemy_range = range(self.enemy);
	enemy_yaw = vectoyaw(self.enemy.origin - self.origin);
	
	if (self.attack_state == AS_MISSILE)
	{
//RPrint ("ai_run_missile\n");
		ai_run_missile ();
		return;
	}
	if (self.attack_state == AS_MELEE)
	{
//RPrint ("ai_run_melee\n");
		ai_run_melee ();
		return;
	}
	if (self.attack_state == AS_FIREBALL) //CH only for demons.. GR why?
	{
//RPrint ("ai_run_fire\n");
		ai_run_fire ();
		return;
	}

	if (CheckAnyAttack ())
		return;					// beginning an attack
		
	if (self.attack_state == AS_SLIDING)
	{
		ai_run_slide ();
		return;
	}
		
// head straight in
	if (self.tfstate & TFSTATE_TRANQUILISED)
		movetogoal (dist * (AI_TRANQ_FACTOR_UP / AI_TRANQ_FACTOR_DN)); //Tranq
	else
		movetogoal (dist);		// done in C code...
};


