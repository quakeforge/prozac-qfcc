/*======================================================
	COMBAT.QC			Custom TeamFortress v3.2	

	(c) TeamFortress Software Pty Ltd 	29/2/97
	(c) William Kerney			5/19/00
========================================================
All the functions pertaining to killing people
======================================================*/
#include "defs.qh"
#include "jobs.qh"

void(string gibname, float dm) ThrowGib;	
void() T_MissileTouch;
void() info_player_start;
void(entity targ, entity attacker) Obituary;

// TeamFortress Prototypes
void(entity Goal, entity AP, float addb) DoResults;
float(entity Goal, entity AP) Activated;
void() monster_death_use;
float (entity targ, entity attacker, float damage) TeamEqualiseDamage;
void(entity bastard,float threshold) createBastard;
void (entity targ,float pain) RevealThief;

//WK
void() GuerillaExplode;
float(entity tester) IsBuilding;
//float(entity happyboy,float newtime) makeImmune;

//- OfN -
float(entity thing) IsMonster;
void(entity body) ExpBody;
string(entity thebuilding) GetBuildingName;
string(entity thething) GetEnemyName;
void(entity tfield, vector where, entity thing) FieldExplosion;
void(entity field) PutFieldWork;

#ifndef COOP_MODE

/*================
monster_death_use (from monsters.qc)

When a monster dies, it fires all of its targets with the current
enemy as activator.
================
*/
void() monster_death_use =
{
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

/*
============
CanDamage

Returns true if the inflictor can directly damage the target.  Used for
explosions and melee attacks.
============
*/
float(entity targ, entity inflictor) CanDamage =
{
    local vector soffset; // - OfN - hackish fix for turretized sentry guns
    soffset='0 0 0';

    // bmodels need special checking because their origin is 0,0,0
	if (targ.movetype == MOVETYPE_PUSH)
	{
		traceline(inflictor.origin, 0.5 * (targ.absmin + targ.absmax), TRUE, self);
		if (trace_fraction == 1)
			return TRUE;
		if (trace_ent == targ)
			return TRUE;
		return FALSE;
	}

    if (targ.classname == "building_sentrygun" && (targ.tf_items & NIT_TURRET))
        soffset='0 0 -20';

    // OfN - Force field
    traceline(inflictor.origin, targ.origin + soffset, FALSE, self);
    if (trace_ent.classname == "force_field")
    {
        FieldExplosion(trace_ent,trace_endpos,trace_ent);
        PutFieldWork(trace_ent);
        return FALSE;
    }

	traceline(inflictor.origin, targ.origin + soffset, TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	/*traceline(inflictor.origin, targ.origin + '15 15 0' + soffset, TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '-15 -15 0' + soffset, TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '-15 15 0' + soffset, TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '15 -15 0' + soffset, TRUE, self);
	if (trace_fraction == 1)
		return TRUE;*/ // OfN - Fixes dets thru wall?

	return FALSE;
};


/*
============
Killed
============
*/
void(entity targ, entity attacker) Killed =
{
    // SOLVES BUG ???? // Stack overflow?
    if (targ.is_killed == TRUE)
    {
        if (IsBuilding(targ))
        {
            local string st;
            RPrint("(OfN WARNING:) Building: '");
            st=GetBuildingName(targ);
            RPrint(st);
            RPrint("' was going to be Killed() again!\n");
            RPrint("Attacker: '");
            st=GetEnemyName(attacker);
            RPrint(st);
            RPrint("\n");
            return;
        }

        if (targ.classname == "player")
        {
            local string st;
            RPrint("(OfN WARNING:) Player: '");
            RPrint(targ.netname);

            if (targ.cutf_items & CUTF_EXPBODY)
            {
                RPrint(" (with expbody) ");
            }
            else
            {
                RPrint(" (without expbody) ");
            }
            

            RPrint("' is Killed() again!\n");
            RPrint("Attacker: '");
            st=GetEnemyName(attacker);
            RPrint(st);

            if (attacker.classname == "player" && attacker.cutf_items & CUTF_EXPBODY)
            {
                RPrint(" (with expbody) ");
            }
            else
            {
                RPrint(" (without expbody) ");
            }
            RPrint("\n");          
        }
        else
        {
            // NOT BUGS, HAPPEN OFTEN WITH BUTTONS ETC..
            
            /*RPrint("(OfN WARNING:) Object: '");
            RPrint(targ.classname);
            RPrint("' is Killed() again!\n");
            RPrint("Attacker: '");
            st=GetEnemyName(attacker);
            RPrint(st);
            if (attacker.classname == "player" && attacker.cutf_items & CUTF_EXPBODY)
            {
                RPrint(" (with expbody) ");
            }
            else
            {
                RPrint(" (without expbody) ");
            }
            RPrint("\n");            */
        }
    }        

    targ.is_killed = TRUE;
    /////////////////////////////////////
    
    local entity oself;

//WK Have cursed person respawn immediately
	if (targ.classname == "player") {
		if (targ.penance_time > time) {
			targ.real_frags = targ.real_frags - 1;
		 	if (!(toggleflags & TFLAG_TEAMFRAGS))
				targ.frags = targ.real_frags;
			targ.health = 50; //Give em a little so they can die again
            targ.is_killed = FALSE;
			return;	
		}
	}

	oself = self;
	self = targ;
	
	// don't let sbar look bad if a player
	if (self.health < -99)
		self.health = -99;		

	// doors, triggers, etc // - ofn added sensor, it now calls clientobituary when dead
	if ((self.movetype == MOVETYPE_PUSH || self.movetype == MOVETYPE_NONE) && self.classname != "building_camera" && self.classname!="building_sensor") //CH stop bug.
	{	
		self.th_die ();
		self = oself;
		return;
	}

	self.enemy = attacker;

	// bump the monster counter
	if (self.flags & FL_MONSTER)
	{
		killed_monsters = killed_monsters + 1;
		WriteByte (MSG_ALL, SVC_KILLEDMONSTER);
	}

	Obituary(self, attacker);
	
	self.takedamage = DAMAGE_NO;
	self.touch = NIL;

	monster_death_use();
	self.th_die ();

	self = oself;
};


/*
============
T_Damage

The damage is coming from inflictor, but get mad at attacker
This should be the only function that ever reduces health.
============
*/
void(entity targ, entity inflictor, entity attacker, float damage) T_Damage =
{
	//WK Just call TF_T_Damage instead, so no updating two functions
	//WK that do exactly the same thing.
	TF_T_Damage(targ,inflictor,attacker,damage,0,0);
};

 /*
 ============
 TF_T_Damage
 same thing as T_Damage (see above), just with some more details

 T_Flags:
	TF_TD_IGNOREARMOUR: bypasses the armour of the target
	TF_TD_NOTTEAM: doesn't damage a team member
	TF_TD_NOTSELF: doesn't damage self

 The following is used to determine whether this attack is affected 
 the type of armor the defender is wearing.
 T_AttackType:		
	TF_TD_OTHER		:	type ignored
	TF_TD_SHOT			: 	bullet damage
	TF_TD_NAIL			:	nailgun damage
	TF_TD_EXPLOSION	:	explosion damage
	TF_TD_ELECTRICITY	:	electricity damage
	TF_TD_FIRE			:	fire damage

	TF_TD_NOSOUND		:	Special Value. Health is adjusted without
						    any sound, painframe, etc
							Health is _set_ to damage, not altered.

============
*/
void(entity targ, entity inflictor, entity attacker, float damage, float T_flags, float T_AttackType) TF_T_Damage =
{
    local	vector	dir;
	local	entity	oldself, te;
	local	float	save;
	local	float	take;
	local float mirror;
	local float dist;
	local string output;
	local float knockem;

	mirror = 0;
	if (infokey(NIL,"ceasefire")=="on") //Cyto
		return;
	if (!targ)
		return;
	if (!targ.takedamage)
		return;

	//WK Set off land mines GR Done with .th_pain now
#if 0
	if (targ.classname == "grenade" && targ.netname == "land_mine")
	{
		targ.martyr_enemy = inflictor;
		targ.think = GuerillaExplode;
		targ.nextthink = time + 0.1;
		return;
	}
#endif

#ifndef REALLY_BUGGY_CODE // This really really sucks
	if (inflictor.martyr_enemy && (Teammate(attacker.team_no, targ.team_no) || Teammate(attacker.team_no,targ.real_owner.team_no)))
	{
		if (!Teammate(inflictor.martyr_enemy.team_no, targ.real_owner.team_no) && !Teammate(inflictor.martyr_enemy.team_no, targ.team_no))
		{
			attacker = inflictor.martyr_enemy;
		}
	}

	//Don't blame people for their airfisted rockets/grenades/detpacks if they hit a teammate
	if ((inflictor.AIRG_Flags & 4) && inflictor != attacker && inflictor.AIRG_FlyTracker.classname == "player")
	{
		local entity targplayer = targ;

		if (targplayer.classname != "player")
			targplayer = targplayer.real_owner;

		if (!Teammate(inflictor.AIRG_FlyTracker.team_no, targplayer.team_no) &&
		    Teammate(attacker.team_no, targplayer.team_no))
			attacker = inflictor.AIRG_FlyTracker;
	}
#endif

	//BOOKKEEPING
	//WK Store last person who shot martyr into .enemy
	//(This conflicts with cameraman, but hey...)
	//Remember last person who shot us, so we can give him a frag
	if (targ.cutf_items & CUTF_EXPBODY && !targ.is_abouttodie)
	{
		//if (targ.classname == "player" && attacker.classname == "player" && !Teammate(targ.team_no, attacker.team_no))
		targ.martyr_enemy = attacker;
		targ.stored_deathmsg = deathmsg; //- OfN - UNUSED? GR yep, so is is_abouttodie pretty much
	}
	if (targ.classname == "player") //WK Time holding the last time we've been shot
		targ.last_attacked_time = time; //WK For chaplan healing purposes


	//BUTTON TRIGGERING
	if (attacker.classname == "player")
	{
		//if (targ.classname != "player" && !IsBuilding(targ) && targ.classname != "monster_demon1")
        if (targ.classname != "player" && !IsBuilding(targ) && !IsMonster(targ))
		{
			if (!Activated(targ,attacker))
			{
				// If an else goal should be activated, activate it
				if (targ.else_goal != 0)
				{
					te = Findgoal(targ.else_goal);
					if (te)
						DoResults(te, attacker, (targ.goal_result & TFGR_ADD_BONUSES));
				}

				return;
			}
		}
	}
	// used by buttons and triggers to set activator for target firing
	damage_attacker = attacker;


	// INVINCIBILITY
	if (targ.flags & FL_GODMODE)
		return;
	if (targ.invincible_finished >= time)
	{
		if (self.invincible_sound < time)
		{
			sound (targ, CHAN_ITEM, "items/protect3.wav", 1, ATTN_NORM);
			self.invincible_sound = time + 2;
		}
		return;
	}

	//CHAPLAIN CALCULATIONS
	// WK See if they're close enough to chap to get protection
	if (attacker.classname == "player" && attacker.tfstate & TFSTATE_INSPIRED) {
		dist = vlen(attacker.origin - attacker.inspirator.origin);
		output = ftos(dist);
		if (dist > CHAPLAN_RADIUS) { //We've strayed from the flock
			sprint(attacker,PRINT_HIGH,"You have strayed from the flock\n");
			attacker.tfstate = attacker.tfstate - TFSTATE_INSPIRED;
			attacker.super_damage_finished = 0;
			attacker.items = attacker.items & ~IT_QUAD;
			attacker.effects &= ~EF_ANYGLOW;
		}
	}
	if (targ.classname == "player" && targ.tfstate & TFSTATE_INSPIRED) {
		dist = vlen(targ.origin - targ.inspirator.origin);
		if (dist > CHAPLAN_RADIUS) { //We've strayed from the flock
			sprint(targ,PRINT_HIGH,"You have strayed from the flock\n");
			targ.tfstate = targ.tfstate - TFSTATE_INSPIRED;
			targ.super_damage_finished = 0;
			targ.items = targ.items & ~IT_QUAD;
			targ.effects &= ~EF_ANYGLOW;
		}
	}

	// QUAD DAMAGE
	if (attacker.super_damage_finished > time) {
		if (attacker.tfstate & TFSTATE_INSPIRED)
			damage = damage * 1.5;
		if (attacker.job & JOB_BERSERKER && attacker.job & JOB_ACTIVE)
            damage = damage * 2;
        else
			damage = damage * 4;
	}

   	if (attacker.aura == AURA_POWER)
		damage = damage * 1.5;
	
	if (targ.aura == AURA_RESISTANCE) {
		damage = damage * 0.66;
		if (self.invincible_sound < time) {
			sound (targ, CHAN_ITEM, "auras/aura1.wav", 1, ATTN_NORM);
			self.invincible_sound = time + 1.5;
		}
	}


	//DAMAGE ADJUSTMENT
	//- OfN - if (deathmsg != DMSG_MARTYR && targ.classname != "monster_demon1" && targ.classname != "monster_shambler" && targ.classname != "monster_army")

    if (deathmsg != DMSG_MARTYR && !IsMonster(targ))
	{ 
		if (targ.tfstate & TFSTATE_INSPIRED) //Chaplan defense
			damage = damage * 0.66;
		//WK Ping fairness code. LPB is < 200 ping
		//haha, yeah right.
#if 0
		if (attacker.classname == "player" && targ.classname == "player" && attacker != targ)
		{
			foo = infokey(attacker,"ping");
			ping = 200;
			if (foo)
				ping = stof(foo);
			ping = (ping + 1000) / 1200;
			if (ping < 0.8) ping = 0.8;
			if (ping > 1.2) ping = 1.2;
			damage = damage * ping;
		}
#endif
		if (teamplay & (TEAMPLAY_LESSSCOREHELP | TEAMPLAY_LESSPLAYERSHELP))
			damage = TeamEqualiseDamage(targ, attacker, damage);
	}

	//MIRROR DAMAGE
	//WK - Check to see if we hit a friend
	if (Teammate(targ.team_no, attacker.team_no) && (targ != attacker) && attacker.classname == "player" && targ.classname == "player")  {
		//We just hit someone on our team!
		if (T_flags & TF_TD_NOTTEAM)
		{
			//Direct damage
			if (teamplay & TEAMPLAY_FULLMIRRORDIRECT)
				mirror = mirror + damage;
			if (teamplay & TEAMPLAY_HALFMIRRORDIRECT)
				mirror = mirror + damage / 2;
		}
		else
		{
			//Explosive damage
			if (teamplay & TEAMPLAY_FULLMIRROREXPLOSIVE)
				mirror = mirror + damage;
			if (teamplay & TEAMPLAY_HALFMIRROREXPLOSIVE)
				mirror = mirror + damage / 2;
		}
		//Don't inflict damage on a (teamkiller or spy)-hitter
		if (mirror > 0 && !(targ.is_feigning || targ.is_undercover) && !(targ.penance_time > time)) //Hurt the jerk!
			TF_T_Damage (attacker, attacker, attacker, mirror, 0, TF_TD_OTHER);
	}
	//WK Slight mirror demon protection GR Also do sentries here
	//Do 2 points of damage to a friendly teammate shooting a friendly demon
	//SB 2 damage? no way, we're doing the full mirror damage
	//- Ofn- if ((targ.classname == "monster_demon1" || targ.classname == "monster_army" || targ.classname == "monster_shambler") && targ.real_owner)
	if ((IsMonster(targ) || IsBuilding(targ)) && targ.real_owner) {
        targ.armorvalue = 1;
#ifdef NO_BUILDING_TK
		if (IsBuilding (targ) && attacker != targ.real_owner)
			return;
#endif
		if (T_flags & TF_TD_NOTTEAM)
		{
			//Direct damage
			if (teamplay & TEAMPLAY_FULLMIRRORDIRECT)
				mirror = mirror + damage;
			if (teamplay & TEAMPLAY_HALFMIRRORDIRECT)
				mirror = mirror + damage / 2;
		}
		else
		{
			//Explosive damage
			if (teamplay & TEAMPLAY_FULLMIRROREXPLOSIVE)
				mirror = mirror + damage;
			if (teamplay & TEAMPLAY_HALFMIRROREXPLOSIVE)
				mirror = mirror + damage / 2;
		}
		if (Teammate(targ.real_owner.team_no,attacker.team_no) && (targ.real_owner != attacker) && attacker.classname == "player")
			TF_T_Damage (attacker, attacker, attacker, mirror, 0, TF_TD_OTHER);
	}
	//WK Friendly Sentrygun protection - you can't hurt friendly sentries GR Why not?

	if (IsBuilding(targ))
		targ.armorvalue = 1; //CH so that the armors are counted

	// SPECIAL ARMOR CALCULATIONS
	if ((targ.armorclass != 0) && (T_AttackType != 0))
	{
		// OTR changed, it now just does less damage but ignores armor.
		if ((targ.armorclass & AT_SAVESHOT) && (T_AttackType == TF_TD_SHOT)) {
			damage = floor(damage * 0.5);
			//WK Cap max damage you can take with kevlar on, like in Real Life(tm)
			//WK The purpose being to cut down on the power of snipers
			if(targ.classname == "player") // SB kevlar fixed so it caps damage now, also spacing much nicer :)
			{
                
		                if (light_damage)
				{
					if (damage > 75)
						damage = 75;
				}
				else if (damage > 100) damage = 100;

			}
		}
		else if ((targ.armorclass & AT_SAVEMELEE) && (T_AttackType = TF_TD_MELEE))
		{
			damage = floor(damage * 0.5);

			if ((targ.velocity_x > 0 || targ.velocity_y > 0 || targ.velocity_z > 0) && random() > 0.6)
				return;
		}
		else if ((targ.armorclass & AT_SAVEEXPLOSION) && (T_AttackType == TF_TD_EXPLOSION))
			damage = floor(damage * 0.5);
		else if ((targ.armorclass & AT_SAVEELECTRICITY) && (T_AttackType == TF_TD_ELECTRICITY))
			damage = floor(damage * 0.5);
		else if ((targ.armorclass & AT_SAVENAIL) && (T_AttackType == TF_TD_NAIL))
			damage = floor(damage * 0.5);
		else if ((targ.armorclass & AT_SAVEFIRE) && (T_AttackType == TF_TD_FIRE))
			damage = floor(damage * 0.5);
	}

	//ARMOR PROTECTION CALCULATION
	// save damage based on the target's armor level
	if (T_flags & TF_TD_IGNOREARMOUR)
	{
		take = damage;
		save = 0;
	}
	else
	{
		save = ceil(targ.armortype*damage);
		if (save >= targ.armorvalue)
		{
			save = targ.armorvalue;
			targ.armortype = 0;	// lost all armor
			targ.armorclass = 0; // lost special armor
			targ.items = targ.items & ~(IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3);
			if (targ.classname == "player")
			    TeamFortress_SetSpeed(targ);
		}
		//WK Flags prevent armor damage too
		if (T_flags & TF_TD_NOTTEAM)
		{
			if (Teammate(targ.team_no,attacker.team_no) && (targ != attacker)) 
			{
				if (teamplay & TEAMPLAY_NOARMORDIRECT)
					targ.armorvalue = targ.armorvalue;
				else if (teamplay & TEAMPLAY_HALFARMORDIRECT)
					targ.armorvalue = targ.armorvalue - save / 2;
				else 
					targ.armorvalue = targ.armorvalue - save;	
			}
			else
					targ.armorvalue = targ.armorvalue - save;
		}
		else
		{
			if (Teammate(targ.team_no, attacker.team_no) && (targ != attacker))
			{
				if (teamplay & TEAMPLAY_NOARMOREXPLOSIVE)
					targ.armorvalue = targ.armorvalue;
				else if (teamplay & TEAMPLAY_HALFARMOREXPLOSIVE)
					targ.armorvalue = targ.armorvalue - save / 2;
				else
					targ.armorvalue = targ.armorvalue - save;
			}
			else
					targ.armorvalue = targ.armorvalue - save;
		}
		//		targ.armorvalue = targ.armorvalue - save;
		take = ceil(damage-save);
		if (targ.armorvalue > 0 && (targ.armorvalue + save > 100) && targ.classname == "player")
		    TeamFortress_SetSpeed(targ); // speed up the less armor you have
	}
	// add to the damage total for clients, which will be sent as a single
	// message at the end of the frame
	// FIXME: remove after combining shotgun blasts?
	if (targ.flags & FL_CLIENT)
	{
		targ.dmg_take = targ.dmg_take + take;
		targ.dmg_save = targ.dmg_save + save;
		targ.dmg_inflictor = inflictor;
	}

	// KNOCKATION CALCULATION
	if ( (inflictor) && (targ.movetype == MOVETYPE_WALK) )
	{
		// Nail Gren doesn't knock ppl
		//WK People with Aspect of HWGUY are immune to knockation
		//WK Martyrs are immune to bullet damage, so AC's and Turrets
		// can't be annoying and just simply stop them.
		//SB That's annoying. They can now :)
		knockem = 1;
		if (targ.cutf_items & CUTF_HWGUY) knockem = 0;
		//if (targ.job & JOB_MARTYR && targ.job & JOB_ACTIVE && T_AttackType != TF_TD_SHOT) knockem = 1;
		if (deathmsg == DMSG_GREN_NAIL) knockem = 0;
		if (knockem)
		{
			// give them some immunity to cheat check
			//targ.immune_to_check = time + (damage / 20);
			makeImmune(targ,time+(damage/20));

			dir = targ.origin - (inflictor.absmin + inflictor.absmax) * 0.5;
			dir = normalize(dir);

			// Increase kickback for smaller weapons
			if ( (damage < 60) & ((attacker.classname == "player") & (targ.classname == "player")) & ( attacker.netname != targ.netname)) 
				targ.velocity = targ.velocity + dir * damage * 11;
			else                        
				targ.velocity = targ.velocity + dir*damage*8;
			if ( (rj > 1) & ((attacker.classname == "player") & (targ.classname == "player")) & ( attacker.netname == targ.netname)) 
				targ.velocity = targ.velocity + dir * damage * rj;
			if (targ.classname == "player" && targ.cutf_items & CUTF_GYMNAST)
				targ.velocity = targ.velocity + dir * damage * 8;
		}
	}


	// TEAMPLAY FLAGS
	if (attacker.classname == "player" && targ.classname == "player")	{
		if (T_flags & TF_TD_NOTTEAM)	{
			if (Teammate(targ.team_no, attacker.team_no) && (targ != attacker))	{
				if (teamplay & TEAMPLAY_NODIRECT) return;
				else if (teamplay & TEAMPLAY_HALFDIRECT) take = take / 2;
			}
		}
		else	{
			if (Teammate(targ.team_no, attacker.team_no) && (targ != attacker))	{
				if (teamplay & TEAMPLAY_NOEXPLOSIVE) return;
				else if (teamplay & TEAMPLAY_HALFEXPLOSIVE) take = take / 2;	
			}
		}
	}

	if (T_flags & TF_TD_NOTSELF) {
		if (targ == attacker) return;
	}

	// do the damage, min 1
	if (take < 1) take = 1;

	//Make thief visible when he's shot
	if (take > 1 && targ != attacker && (targ.job & JOB_THIEF && (targ.job & JOB_ACTIVE || targ.job & JOB_FULL_HIDE)))
		if (!Teammate(targ.team_no, attacker.team_no))
			RevealThief(targ,TRUE);

	targ.health = targ.health - take;

	if (targ.armorvalue < 1) {
		targ.armorclass = 0; // lost special armor
		targ.armorvalue = 0;
	}

	if (targ.health < 1 && targ.health > 0) //WK Stop the scoreboard coming up
		targ.health = 1;
        
	if (targ.health <= 0) {
		if (inflictor.classname == "detpack" && inflictor.weaponmode == 1 && inflictor.enemy == targ)
			deathmsg = DMSG_DETPACK_DIS;

		//WK Autotrigger martyr - OfN - Now exp.body
		//BUG, berserk made exp body not work, fixed?
		if ((targ.cutf_items & CUTF_EXPBODY) && attacker && targ.is_abouttodie == FALSE)
		{
			//oldself = self;
			//self = targ;
			targ.health = 1;
            targ.martyr_enemy=attacker;
			ExpBody(targ);
			//self = oldself;
            targ.is_abouttodie = TRUE;
			return;
		}// /////// OFTEN ///////////

		//WK Make sure the NIL doesn't have a bastard level
		if (attacker.classname != "player" || targ.classname != "player") {
			//bprint(PRINT_MEDIUM,"Non player death or kill\n");
			Killed(targ, attacker);
			return;
		}

		//WK Handle Total Bastard Checking
		//If they kill more than a certain number of friends in a certain period, they are booted
		if (Teammate(targ.team_no, attacker.team_no) && targ != attacker && !(targ.penance_time > time) && !(targ.is_undercover) && prematch < time)
		{
			//A teamkill
			local string st;
			local float threshold;
			threshold = 0;
			st = infokey(NIL, "curse");
			if (st)
				threshold = stof(st);


			attacker.ff_count = attacker.ff_count + 1; //Increase their bastard rating
			if (threshold >= 1) {
				if (attacker.ff_count >= threshold) createBastard(attacker,threshold);
				if ((attacker.ff_count == threshold - 1) || (attacker.ff_count == threshold - 0.5)) {
					sprint (attacker, PRINT_MEDIUM, "One more teamkill and you will be cursed.\n");
				}
			}
		}
		if (!Teammate(targ.team_no, attacker.team_no) || targ.penance_time > time) {
			attacker.ff_count = attacker.ff_count - 0.5;
			if (attacker.ff_count < 0) attacker.ff_count = 0;
		}

		if (targ.penance_time > time) //A penitent loses frags
			Killed(targ, targ);
		else
			Killed(targ, attacker);
		return;

	}        

	// react to the damage
	oldself = self;
	self = targ;

	if (self.th_pain)
	{
		self.th_pain (attacker, take);
	}

	self = oldself;
};

/*
============
T_RadiusDamage
============
*/
void(entity inflictor, entity attacker, float damage, entity ignore) T_RadiusDamage =
{
	local	float 	points;
	local	entity	head, te; 
	local	vector	org;

	head = findradius(inflictor.origin, damage+40);
	
	while (head)
	{
		if (head != ignore)
		{
			//WK Set off all land mines in blast radius
			if (head.classname == "grenade" && head.netname == "land_mine")
			{
				if (deathmsg != DMSG_LAND_MINE) { 
                    //head.has_tesla = 2; //- ofn - ur mine explodes better than is destroyed
					head.think = GuerillaExplode;
					head.nextthink = time + 0.1;
				}
			}
			// Check for TeamFortress Goals that can be triggered by Detpacks
			else if (head.classname == "info_tfgoal")
			{
				if (inflictor.classname == "detpack")
				{
					// Don't activate timer goals
					if ((head.goal_activation & TFGA_TOUCH_DETPACK) && (head.search_time == 0))
					{
						traceline (inflictor.origin, head.origin, TRUE, inflictor);

						if (trace_fraction == 1)
						{
							// Does the AP match the AP Criteria?
							if (Activated(head,attacker))
							{
								DoResults(head, attacker, TRUE);
							}
							else
							{
								// If an else goal should be activated, activate it
								if (head.else_goal != 0)
								{
									te = Findgoal(head.else_goal);
									if (te)
										DoResults(te, attacker, (head.goal_result & TFGR_ADD_BONUSES));
								}

								return;
							}
						}
					}
				}
			}
			else if (head.takedamage)
			{
				org = head.origin + (head.mins + head.maxs)*0.5;
				points = 0.5*vlen (inflictor.origin - org);
				if (points < 0)
					points = 0;
				points = damage - points;
				if (head == attacker)
					points = rint(points * 0.75);
				if (head.classname == "building_camera")
					points = 10;
				if (points > 0)
				{
					if (CanDamage (head, inflictor))
					{
		                TF_T_Damage (head, inflictor, attacker, points, TF_TD_NOTTEAM, TF_TD_EXPLOSION);
					}
					//Turrets have fucked up bounding boxes due to their natures
					//So we have to make them susceptible to blast damage here
					//But only 50% damage, since they are turrets...
					else if ((head.classname == "building_sentrygun" || head.classname == "building_tesla") && head.tf_items & NIT_TURRET) {
							points = rint(points / 2);
							TF_T_Damage (head, inflictor, attacker, points, TF_TD_NOTTEAM, TF_TD_EXPLOSION);
						
					}
				}
			}
		}
		head = head.chain;
	}
};

/*
============
T_BeamDamage // OfN - UNUSED so.. i coment it out
============
*/

/*void(entity attacker, float damage) T_BeamDamage =
{
	local	float 	points;
	local	entity	head;
	
	head = findradius(attacker.origin, damage+40);
	
	while (head)
	{
		if (head.takedamage)
		{
			points = 0.5*vlen (attacker.origin - head.origin);
			if (points < 0)
				points = 0;
			points = damage - points;
			if (head == attacker)
				points = points * 0.5;
			if (points > 0)
			{
				if (CanDamage (head, attacker))
				{
				
					//if (head.classname == "monster_shambler")						
					//	T_Damage (head, attacker, attacker, points*0.5);
					//else

						T_Damage (head, attacker, attacker, points);
				}
			}
		}
		head = head.chain;
	}
};*/
