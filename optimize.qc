/*======================================================
	OPTIMIZE.QC			Custom TeamFortress v2.1	
	(c) Craig Hauser				10/4/00
========================================================
This has the optimizations that I have done, basically if
I saw something similar being run in multi places I made
a function and put it here.
======================================================*/

#include "defs.qh"

float (float t1, float t2) Teammate;
float (entity targ, entity check) visible2;
float (entity targ, entity check) visible2x;
void(entity targ, entity inflictor, entity attacker, float damage, float T_flags, float T_AttackType) TF_T_Damage;
//checks client passed into and returns true if valid used for sents etc
//entity looking at, entity thats looking, (0-1) checks visible, (0-range) checks range, (0-1) do special tesla checks, (0-1) should check for ceasefire
float(entity targ, entity checker, float chkvis, float chkrng, float istesla, float chkcease) Pharse_Client =
{
		local float ismotion = 0;
		if (istesla == 2)
		{
			istesla = 0;
			ismotion = 1;
		}
		if (targ.classname != "player")
			return FALSE;
		if (chkcease)
			if (infokey(NIL,"ceasefire")=="on")
				return FALSE;
		if (targ.playerclass == PC_UNDEFINED)
			return FALSE;
		if (targ.done_custom & CUSTOM_BUILDING)
			return FALSE;
		if (targ.health <= 0)
			return FALSE;
		if (targ.has_disconnected)
			return FALSE;
		if (teamplay)
		{
			if (Teammate(targ.team_no, checker.team_no))
				{
					if (istesla)
					{
						if (!(checker.tf_items & NIT_SECURITY_CAMERA)) //CH Cyto's idea
							return FALSE;
					} else
					{
						return FALSE;
					}
				}
			if (Teammate(targ.undercover_team,checker.team_no))
				{
					if (istesla)
					{
						//- OfN jammer only for scanner -// nope
                        if (!(checker.tf_items & NIT_AUTOID) || targ.cutf_items & CUTF_JAMMER)
                        //if (!(checker.tf_items & NIT_AUTOID))
							return FALSE;
					}
					else
					{						
                        if (! (ismotion && checker.num_mines & IMPROVED_FOUR)) 
                            return FALSE;

                        // - OfN return FALSE;
					}
				}
		}
		if (targ == checker.real_owner)
		{
			if (istesla)
			{
				if (!(checker.tf_items & NIT_SECURITY_CAMERA)) //CH Cyto's idea
					return FALSE;
			} else
			{
				return FALSE;
			}
		}
		if (targ.is_feigning)
		{
			if (istesla)
			{
				if (!(checker.tf_items & NIT_AUTOID))
					return FALSE;
			}
			else //if (checker.classname != "monster_army") - OfN soldiers cant detect feigning spies now
			{
				return FALSE;
			}
		}
		if (targ.flags & FL_NOTARGET)
			return FALSE;
		if (targ.items & IT_INVISIBILITY && (checker.classname != "building_sensor")) //|| checker.classname != "monster_army"))
			return FALSE;
		if (targ.job & JOB_THIEF && (targ.job & JOB_ACTIVE || targ.job & JOB_FULL_HIDE))
		{
			chkrng /= 2; // harder to see
			if (istesla)
			{
				//- OfN jammer only for scanner -// nope
                if (!(checker.tf_items & NIT_AUTOID) || targ.cutf_items & CUTF_JAMMER)
                //if (!(checker.tf_items & NIT_AUTOID))
					return FALSE;
			}
			else if (!ismotion)// && checker.classname != "monster_army" && checker.classname != "monster_demon1")
				return FALSE;
		}
		if (chkvis && checker.classname == "building_sentrygun" && !(checker.tf_items & NIT_TURRET)) // - OfN - hackish fix for sentry gun targetting
		{
            if (!visible2x(targ,checker)) // - OfN - hackish fix for sentry gun targetting
 				return FALSE;
        }
        else if (chkvis)
			if (!visible2(targ,checker))
 				return FALSE;
		if (chkrng)
		{
			if (ismotion && targ.cutf_items & CUTF_JAMMER)  // range cut in half if victim has scan jammer
				chkrng /= 2;
			local float r;
			
			r = vlen(targ.origin - checker.origin);
			if (r > chkrng)
				return FALSE;
		

			if (ismotion) // motion sensor can't detect targets moving slowly or not at all
			{
				local float minmove = SENSOR_MINSPEED * (1.5 - r/chkrng) ;

				if (vlen(targ.velocity) < minmove)
					return FALSE;
			}
		}
	return TRUE;
};
//gives entity passed into number of frags passed
/*
*/
#if 0
void (entity atk, entity targ, float numfrags, float howgive, float chkreal, float chkvamp) Give_Frags_Out =
{
	
	if (howgive == 2)
		atk.frags = atk.frags + numfrags;
	else if (howgive == 1)
		atk.real_frags = atk.real_frags + numfrags;
	else
		bprint(PRINT_HIGH, "Error in Give_Frags_Out!\n");
			
	if (fraggetlog)
		logfrag (targ, atk);

	if (chkvamp)
	{
		if (teamplay & TEAMPLAY_VAMPIRE && targ) // handle when targ is cleared
		{
			targ.real_frags = targ.real_frags - numfrags;
			if (!(toggleflags & TFLAG_TEAMFRAGS))
				targ.frags = targ.real_frags;
		}
	}	

	if (attacker.classname == "player")
	{
	 	if (!(toggleflags & TFLAG_TEAMFRAGS))
	 	{
			atk.frags = atk.real_frags;
		}
	}
};
#endif

//replaces det guns
//classname to find, entity checking, (0-1) check for ownership
void(string search, entity person, float chkown) Find_And_Dmg =
{
	local entity te;
	te = find(NIL, classname, search);
	while (te)
	{
		if (chkown)
		{
			if (te.real_owner == person)
				TF_T_Damage(te, person, person, te.health+100, TF_TD_IGNOREARMOUR, TF_TD_OTHER);
		}
		else
		{
			TF_T_Damage(te, person, person, te.health+100, TF_TD_IGNOREARMOUR, TF_TD_OTHER);
		}
		te = find(te, classname, search);
	}
};

float () isMelee =
{
	if (self.current_weapon == WEAP_AXE || self.current_weapon == WEAP_SPANNER || self.current_weapon == WEAP_MEDIKIT)
		return TRUE;
	else
		return FALSE;
};
