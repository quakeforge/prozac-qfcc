#include "defs.qh"

// This makes the chances of each death message easier to understand.  I hope.
#define FRAC(x, y) ((x) * 1.0 / (y))

void (entity targ, entity attacker) Obituary;
void (entity targ, entity attacker) Obituary_Player;
void (entity targ, entity attacker) Obituary_Player_by_Cybernet;
void (entity targ, entity attacker) Obituary_Player_by_Antihack;
void (entity targ, entity attacker) Obituary_Player_by_Antidismantle;
void (entity targ, entity attacker) Obituary_Player_by_Wizard;
void (entity targ, entity attacker) Obituary_Player_by_Demon1;
void (entity targ, entity attacker) Obituary_Player_by_Army;
void (entity targ, entity attacker) Obituary_Player_by_Shambler;
void (entity targ, entity attacker) Obituary_Player_by_Teledeath;
void (entity targ, entity attacker) Obituary_Player_by_Teledeath2;
void (entity targ, entity attacker) Obituary_Player_by_Goal;
void (entity targ, entity attacker) Obituary_Player_by_Player;
void (entity targ, entity attacker) Obituary_Player_by_Dispenser;
void (entity targ, entity attacker) Obituary_Player_by_ForceField;
void (entity targ, entity attacker) Obituary_Player_by_SentryTesla;
void (entity targ, entity attacker) Obituary_Player_by_Teleporter;
void (entity targ, entity attacker) Obituary_Player_Misc;
void (entity targ, entity attacker) Obituary_Monster;
void (entity targ, entity attacker) Obituary_Monster_Wizard;
void (entity targ, entity attacker) Obituary_Monster_Wizard_by_Tesla;
void (entity targ, entity attacker) Obituary_Monster_Wizard_by_Sentry;
void (entity targ, entity attacker) Obituary_Monster_Wizard_by_Player;
void (entity targ, entity attacker) Obituary_Monster_Wizard_by_Army;
void (entity targ, entity attacker) Obituary_Monster_Wizard_by_Demon1;
void (entity targ, entity attacker) Obituary_Monster_Wizard_by_Shambler;
void (entity targ, entity attacker) Obituary_Monster_Wizard_by_Wizard;
void (entity targ, entity attacker) Obituary_Monster_Demon1;
void (entity targ, entity attacker) Obituary_Monster_Demon1_by_Tesla;
void (entity targ, entity attacker) Obituary_Monster_Demon1_by_Sentry;
void (entity targ, entity attacker) Obituary_Monster_Demon1_by_Player;
void (entity targ, entity attacker) Obituary_Monster_Demon1_by_Army;
void (entity targ, entity attacker) Obituary_Monster_Demon1_by_Demon1;
void (entity targ, entity attacker) Obituary_Monster_Demon1_by_Shambler;
void (entity targ, entity attacker) Obituary_Monster_Demon1_by_Wizard;
void (entity targ, entity attacker) Obituary_Monster_Army;
void (entity targ, entity attacker) Obituary_Monster_Army_by_Tesla;
void (entity targ, entity attacker) Obituary_Monster_Army_by_Sentry;
void (entity targ, entity attacker) Obituary_Monster_Army_by_Player;
void (entity targ, entity attacker) Obituary_Monster_Army_by_Shambler;
void (entity targ, entity attacker) Obituary_Monster_Army_by_Demon1;
void (entity targ, entity attacker) Obituary_Monster_Army_by_Army;
void (entity targ, entity attacker) Obituary_Monster_Army_by_Wizard;
void (entity targ, entity attacker) Obituary_Monster_Shambler;
void (entity targ, entity attacker) Obituary_Monster_Shambler_by_Tesla;
void (entity targ, entity attacker) Obituary_Monster_Shambler_by_Sentry;
void (entity targ, entity attacker) Obituary_Monster_Shambler_by_Player;
void (entity targ, entity attacker) Obituary_Monster_Shambler_by_Demon1;
void (entity targ, entity attacker) Obituary_Monster_Shambler_by_Shambler;
void (entity targ, entity attacker) Obituary_Monster_Shambler_by_Army;
void (entity targ, entity attacker) Obituary_Monster_Shambler_by_Wizard;
void (entity targ, entity attacker) Obituary_Monster_Misc;
void (entity targ, entity attacker) Obituary_Building;
void (entity targ, entity attacker) Obituary_Building_by_Tesla;
void (entity targ, entity attacker) Obituary_Building_by_Self;
void (entity targ, entity attacker) Obituary_Building_by_Teledeath;
void (entity targ, entity attacker) Obituary_Building_by_Player;
void (entity targ, entity attacker) Obituary_Building_by_Army;


/*
===========
Obituary

called when a something dies
============
*/
void (entity targ, entity attacker) Obituary =
{
	if (prematch >= time)
		return;

	if (targ.classname == "player")
		Obituary_Player (targ, attacker);
	else if (IsMonster (targ))
		Obituary_Monster (targ, attacker);
	else if (IsBuilding (targ) && targ.classname != "building_sentrygun_base")
		Obituary_Building (targ, attacker);
};

void (entity targ, entity attacker) Obituary_Player =
{
	//WK No Obituary for the cursed!
	if (targ.penance_time > time - 1)
	{
		Give_Frags_Out (targ, targ, -1, 0, 1, 1, 0);
	}

	if (targ.martyr_enemy != targ)
		deathmsg = targ.stored_deathmsg;

	if (deathmsg == DMSG_CYBERNET)
		Obituary_Player_by_Cybernet (targ, attacker);
	else if (deathmsg == DMSG_ANTIHACK)
		Obituary_Player_by_Antihack (targ, attacker);
	else if (deathmsg == DMSG_ANTIDISM)
		Obituary_Player_by_Antidismantle (targ, attacker);
	else if (attacker.classname == "monster_wizard")
		Obituary_Player_by_Wizard (targ, attacker);
	else if (attacker.classname == "monster_demon1")
		Obituary_Player_by_Demon1 (targ, attacker);
	else if (attacker.classname == "monster_army")
		Obituary_Player_by_Army (targ, attacker);
	else if (attacker.classname == "monster_shambler")
		Obituary_Player_by_Shambler (targ, attacker);
	else if (attacker.classname == "teledeath")
		Obituary_Player_by_Teledeath (targ, attacker);
	else if (attacker.classname == "teledeath2")
		Obituary_Player_by_Teledeath2 (targ, attacker);
	else if (attacker.classname == "info_tfgoal")
		Obituary_Player_by_Goal (targ, attacker);
	else if (attacker.classname == "player")
		Obituary_Player_by_Player (targ, attacker);
	else if (attacker.classname == "building_dispenser")
		Obituary_Player_by_Dispenser (targ, attacker);
	else if (attacker.classname == "force_field")
		Obituary_Player_by_ForceField (targ, attacker);
	else if (attacker.classname == "building_sentrygun"
			 || attacker.classname == "building_tesla")
		Obituary_Player_by_SentryTesla (targ, attacker);
	else if (attacker.classname == "building_teleporter")
		Obituary_Player_by_Teleporter (targ, attacker);
	else
		Obituary_Player_Misc (targ, attacker);
};

void (entity targ, entity attacker) Obituary_Player_by_Cybernet =
{
	bprint (PRINT_MEDIUM, targ.netname);
	bprint (PRINT_MEDIUM, " will abort the hack next time\n");

	Give_Frags_Out (targ, targ, -1, 0, 1, 1, 0);
};

void (entity targ, entity attacker) Obituary_Player_by_Antihack =
{
	local string tst = GetBuildingName (attacker);

	if (random () < FRAC (1, 2)) {
		bprint (PRINT_MEDIUM, targ.netname);
		bprint (PRINT_MEDIUM, " is electrocuted trying to hack ");
		bprint (PRINT_MEDIUM, attacker.real_owner.netname);
		bprint (PRINT_MEDIUM, "'s ");
		bprint (PRINT_MEDIUM, tst);
		bprint (PRINT_MEDIUM, "\n");
	} else {
		bprint (PRINT_MEDIUM, targ.netname);
		bprint (PRINT_MEDIUM, " should never tried to hack ");
		bprint (PRINT_MEDIUM, attacker.real_owner.netname);
		bprint (PRINT_MEDIUM, "'s ");
		bprint (PRINT_MEDIUM, tst);
		bprint (PRINT_MEDIUM, "\n");
	}

	Give_Frags_Out (targ, targ, -1, 0, 1, 1, 0);
};

void (entity targ, entity attacker) Obituary_Player_by_Antidismantle =
{
	local string tst = GetBuildingName (attacker);

	if (random () < FRAC (1, 2)) {
		bprint (PRINT_MEDIUM, targ.netname);
		bprint (PRINT_MEDIUM, " tries to dismantle ");
		bprint (PRINT_MEDIUM, attacker.real_owner.netname);
		bprint (PRINT_MEDIUM, "'s ");
		bprint (PRINT_MEDIUM, tst);
		bprint (PRINT_MEDIUM, " with the wrong tool\n");
	} else {
		bprint (PRINT_MEDIUM, targ.netname);
		bprint (PRINT_MEDIUM, " is electrocuted trying to dismantle ");
		bprint (PRINT_MEDIUM, attacker.real_owner.netname);
		bprint (PRINT_MEDIUM, "'s ");
		bprint (PRINT_MEDIUM, tst);
		bprint (PRINT_MEDIUM, "\n");
	}

	Give_Frags_Out (targ, targ, -1, 0, 1, 1, 0);
};

void (entity targ, entity attacker) Obituary_Player_by_Wizard =
{
	custom_demon_name (attacker); //CH

	if (attacker.real_owner == targ) {
		Give_Frags_Out (attacker.real_owner, attacker.real_owner, -2, 0, 1, 1, 0);

		bprint (PRINT_MEDIUM, "The scrag ");
		bprint (PRINT_MEDIUM, attacker.netname);
		bprint (PRINT_MEDIUM, " kills his owner, ");
		bprint (PRINT_MEDIUM, targ.netname);
		bprint (PRINT_MEDIUM, "\n");
	} else if (!Teammate (targ.team_no, attacker.real_owner.team_no)
			   || attacker.real_owner.team_no < 1) {
		local float rnum = random ();
		if (rnum < FRAC (1, 3))	{
			bprint (PRINT_MEDIUM, targ.netname);
			bprint (PRINT_MEDIUM, " was nullified by the scrag ");
			bprint (PRINT_MEDIUM, attacker.netname);
			bprint (PRINT_MEDIUM, " (");
			bprint (PRINT_MEDIUM, attacker.real_owner.netname);
			bprint (PRINT_MEDIUM, ")\n");
		} else if (rnum < FRAC (2, 3)) {
			bprint (PRINT_MEDIUM, targ.netname);
			bprint (PRINT_MEDIUM, " didn't survive ");
			bprint (PRINT_MEDIUM, attacker.netname);
			bprint (PRINT_MEDIUM, "'s (");
			bprint (PRINT_MEDIUM, attacker.real_owner.netname);
			bprint (PRINT_MEDIUM, ") acid\n");
		} else {
			bprint (PRINT_MEDIUM, attacker.real_owner.netname);
			bprint (PRINT_MEDIUM, "'s scrag, ");
			bprint (PRINT_MEDIUM, attacker.netname);
			bprint (PRINT_MEDIUM, ", removes ");
			bprint (PRINT_MEDIUM, targ.netname);
			bprint (PRINT_MEDIUM, "\n");
		}

		Give_Frags_Out (attacker.real_owner, attacker.real_owner, 1, 0, 1, 1, 0);
	} else if (Teammate (targ.team_no, attacker.real_owner.team_no)) {
		if (random () < FRAC (1, 2)) {
			bprint (PRINT_MEDIUM, "The supposed friendly scrag ");
			bprint (PRINT_MEDIUM, attacker.netname);
			bprint (PRINT_MEDIUM, " (");
			bprint (PRINT_MEDIUM, attacker.real_owner.netname);
			bprint (PRINT_MEDIUM, ")");
			bprint (PRINT_MEDIUM, " killed ");
			bprint (PRINT_MEDIUM, targ.netname);
			bprint (PRINT_MEDIUM, "\n");
		} else {
			bprint (PRINT_MEDIUM, attacker.netname);
			bprint (PRINT_MEDIUM, " (");
			bprint (PRINT_MEDIUM, attacker.real_owner.netname);
			bprint (PRINT_MEDIUM, ") proves that scrags are able to teamkill with ");
			bprint (PRINT_MEDIUM, targ.netname);
			bprint (PRINT_MEDIUM, "'s help\n");
		}
	}
};

void (entity targ, entity attacker) Obituary_Player_by_Demon1 =
{
	custom_demon_name (attacker); //CH

	if (attacker.real_owner == targ) {
		Give_Frags_Out (attacker.real_owner, attacker.real_owner, -2, 0, 1, 1, 0);

		if (deathmsg == DMSG_DEMON_FIRE) {
			bprint (PRINT_MEDIUM, attacker.netname);
			bprint (PRINT_MEDIUM, " threw his rage to his owner ");
			bprint (PRINT_MEDIUM, targ.netname);
			bprint (PRINT_MEDIUM, "\n");
		} else {
			if (random () < FRAC (1, 2)) {
				bprint (PRINT_MEDIUM, attacker.netname);
				bprint (PRINT_MEDIUM, " exacts revenge on its summoner, ");
				bprint (PRINT_MEDIUM, targ.netname);
				bprint (PRINT_MEDIUM, "\n");
			} else {
				bprint (PRINT_MEDIUM, targ.netname);
				bprint (PRINT_MEDIUM, " is dragged into the pit by his own demon, ");
				bprint (PRINT_MEDIUM, attacker.netname);
				bprint (PRINT_MEDIUM, "\n");
			}
		}
	}
	else if (deathmsg == DMSG_DEMON_FIRE)
	{
		local float rnum = random ();
		if (rnum < FRAC (1, 4)) {
			bprint (PRINT_MEDIUM, targ.netname);
			bprint (PRINT_MEDIUM, " was burned alive by ");
			bprint (PRINT_MEDIUM, attacker.netname);
			bprint (PRINT_MEDIUM, " (");
			bprint (PRINT_MEDIUM, attacker.real_owner.netname);
			bprint (PRINT_MEDIUM, ")\n");
		} else if (rnum < FRAC (2, 4)) {
			bprint (PRINT_MEDIUM, targ.netname);
			bprint (PRINT_MEDIUM, " thought he was safe from ");
			bprint (PRINT_MEDIUM, attacker.netname);
			bprint (PRINT_MEDIUM, " (");
			bprint (PRINT_MEDIUM, attacker.real_owner.netname);
			bprint (PRINT_MEDIUM, ")\n");
		} else if (rnum < FRAC (3, 4)) {
			bprint (PRINT_MEDIUM, targ.netname);
			bprint (PRINT_MEDIUM, " died from ");
			bprint (PRINT_MEDIUM, attacker.netname);
			bprint (PRINT_MEDIUM, "'s (");
			bprint (PRINT_MEDIUM, attacker.real_owner.netname);
			bprint (PRINT_MEDIUM, ") fire balls\n");
		} else {
			bprint (PRINT_MEDIUM, attacker.real_owner.netname);
			bprint (PRINT_MEDIUM, "'s demon, ");
			bprint (PRINT_MEDIUM, attacker.netname);
			bprint (PRINT_MEDIUM, ", burned ");
			bprint (PRINT_MEDIUM, targ.netname);
			bprint (PRINT_MEDIUM, " to a crisp\n");
		}
	} else {
		local float rnum = random ();
		if (rnum < FRAC (2, 20)) {
			bprint (PRINT_MEDIUM, targ.netname);
			bprint (PRINT_MEDIUM, " was eviscerated by ");
			bprint (PRINT_MEDIUM, attacker.netname);
			bprint (PRINT_MEDIUM, " (");
			bprint (PRINT_MEDIUM, attacker.real_owner.netname);
			bprint (PRINT_MEDIUM, ")\n");
		} else if (rnum < FRAC (10, 20)) {
			bprint (PRINT_MEDIUM, targ.netname);
			bprint (PRINT_MEDIUM, " was ripped limb from limb by ");
			bprint (PRINT_MEDIUM, attacker.netname);
			bprint (PRINT_MEDIUM, " (");
			bprint (PRINT_MEDIUM, attacker.real_owner.netname);
			bprint (PRINT_MEDIUM, ")\n");
		} else {
			bprint (PRINT_MEDIUM, attacker.real_owner.netname);
			bprint (PRINT_MEDIUM, "'s demon, ");
			bprint (PRINT_MEDIUM, attacker.netname);
			if (rnum < FRAC (15, 20))
				bprint (PRINT_MEDIUM, ", claws apart ");
			else
				bprint (PRINT_MEDIUM, ", rends apart ");
			bprint (PRINT_MEDIUM, targ.netname);
			bprint (PRINT_MEDIUM, "\n");
		}
	}

	if (!Teammate (targ.team_no, attacker.real_owner.team_no)
		|| attacker.real_owner.team_no < 1)
		Give_Frags_Out (attacker.real_owner, attacker.real_owner, 1, 0, 1, 1, 0);
};

void (entity targ, entity attacker) Obituary_Player_by_Army =
{
	custom_demon_name (attacker); //CH
	GetRank (attacker); // Sponsored by SB-1 Tech

	if (attacker.real_owner == targ) {
		Give_Frags_Out (attacker.real_owner, attacker.real_owner, -2, 0, 1, 1, 0);

		bprint (PRINT_MEDIUM, targ.netname);
		bprint (PRINT_MEDIUM, " is killed by his own mercenary ");
		bprint (PRINT_MEDIUM, attacker.undercover_name);
		bprint (PRINT_MEDIUM, attacker.netname);
		bprint (PRINT_MEDIUM, "\n");
	} else if (Teammate (targ.team_no, attacker.real_owner.team_no)) {
		local float rnum = random ();
		bprint (PRINT_MEDIUM, attacker.undercover_name);
		bprint (PRINT_MEDIUM, attacker.netname);

		if (rnum < FRAC (1, 4))
			bprint (PRINT_MEDIUM, " mows down a teammate\n");
		else if (rnum < FRAC (2, 4))
			bprint (PRINT_MEDIUM, " checks his glasses\n");
		else if (rnum < FRAC (3, 4))
			bprint (PRINT_MEDIUM, " gets a frag for the other team\n");
		else
			bprint (PRINT_MEDIUM, " loses another friend\n");

		return;
	} else {
		if (deathmsg == DMSG_AXE) {
			if (attacker.cutf_items & CUTF_KNIFE) {
				bprint (PRINT_MEDIUM, targ.netname);
				bprint (PRINT_MEDIUM, " is sliced and diced by ");
				bprint (PRINT_MEDIUM, attacker.undercover_name);
				bprint (PRINT_MEDIUM, attacker.netname);
				bprint (PRINT_MEDIUM, "'s (");
				bprint (PRINT_MEDIUM, attacker.real_owner.netname);
				bprint (PRINT_MEDIUM, ") blade\n");
			} else {
				bprint (PRINT_MEDIUM, targ.netname);
				bprint (PRINT_MEDIUM, " is split in two by a powerful axe blow from ");
				bprint (PRINT_MEDIUM, attacker.undercover_name);
				bprint (PRINT_MEDIUM, attacker.netname);
				bprint (PRINT_MEDIUM, " (");
				bprint (PRINT_MEDIUM, attacker.real_owner.netname);
				bprint (PRINT_MEDIUM, ")\n");
			}
		} else if (deathmsg == DMSG_BACKSTAB) {
			bprint (PRINT_MEDIUM, targ.netname);
			bprint (PRINT_MEDIUM, " is filleted by ");
			bprint (PRINT_MEDIUM, attacker.undercover_name);
			bprint (PRINT_MEDIUM, attacker.netname);
			bprint (PRINT_MEDIUM, " (");
			bprint (PRINT_MEDIUM, attacker.real_owner.netname);
			bprint (PRINT_MEDIUM, ")\n");
		} else if (deathmsg == DMSG_SHOTGUN) {
			bprint (PRINT_MEDIUM, targ.netname);
			bprint (PRINT_MEDIUM, " practices being ");
			bprint (PRINT_MEDIUM, attacker.undercover_name);
			bprint (PRINT_MEDIUM, attacker.netname);
			bprint (PRINT_MEDIUM, "'s (");
			bprint (PRINT_MEDIUM, attacker.real_owner.netname);
			bprint (PRINT_MEDIUM, ") clay pigeon\n");
		} else if (deathmsg == DMSG_NAILGUN) {
			bprint (PRINT_MEDIUM, targ.netname);
			bprint (PRINT_MEDIUM, " is turned into ");
			bprint (PRINT_MEDIUM, attacker.undercover_name);
			bprint (PRINT_MEDIUM, attacker.netname);
			bprint (PRINT_MEDIUM, "'s (");
			bprint (PRINT_MEDIUM, attacker.real_owner.netname);
			bprint (PRINT_MEDIUM, ") pincushion\n");
		} else if (deathmsg == DMSG_ROCKETL) {
			bprint (PRINT_MEDIUM, attacker.undercover_name);
			bprint (PRINT_MEDIUM, attacker.netname);
			bprint (PRINT_MEDIUM, " declares that ");
			bprint (PRINT_MEDIUM, targ.netname);
			bprint (PRINT_MEDIUM, " IS the rocket man\n");
		} else if (deathmsg == DMSG_SSHOTGUN) {
			bprint (PRINT_MEDIUM, targ.netname);
			bprint (PRINT_MEDIUM, " is turned into swiss cheese by ");
			bprint (PRINT_MEDIUM, attacker.undercover_name);
			bprint (PRINT_MEDIUM, attacker.netname);
			bprint (PRINT_MEDIUM, "'s (");
			bprint (PRINT_MEDIUM, attacker.real_owner.netname);
			bprint (PRINT_MEDIUM, ") buckshot\n");
		}
	
		Give_Frags_Out (attacker.real_owner, attacker.real_owner, 1, 0, 1, 1, 0);
		Give_Frags_Out (attacker, attacker, 1, 0, 1, 1, 0);
	}
};

void (entity targ, entity attacker) Obituary_Player_by_Shambler =
{
	custom_demon_name (attacker); //CH

	if (attacker.real_owner == targ) {
		Give_Frags_Out (attacker.real_owner, attacker.real_owner, -2, 0, 1, 1, 0);

		if (deathmsg == DMSG_LIGHTNING) {
			bprint (PRINT_MEDIUM, attacker.netname);
			bprint (PRINT_MEDIUM, " annihilates its owner ");
			bprint (PRINT_MEDIUM, targ.netname);
			bprint (PRINT_MEDIUM, " with a bolt of lightning\n");
		} else if (deathmsg == DMSG_DEMON_FIRE) {
			bprint (PRINT_MEDIUM, attacker.netname);
			bprint (PRINT_MEDIUM, " detonates its owner ");
			bprint (PRINT_MEDIUM, targ.netname);
			bprint (PRINT_MEDIUM, " with a fireball\n");
		} else {
			if (random () < FRAC (1, 2)) {
				bprint (PRINT_MEDIUM, attacker.netname);
				bprint (PRINT_MEDIUM, " gets sick of its owner ");
				bprint (PRINT_MEDIUM, targ.netname);
				bprint (PRINT_MEDIUM, "\n");
			} else {
				bprint (PRINT_MEDIUM, targ.netname);
				bprint (PRINT_MEDIUM, " screams as ");
				bprint (PRINT_MEDIUM, attacker.netname);
				bprint (PRINT_MEDIUM, " turns on his owner\n");
			}
		}
	} else {
		if (deathmsg == DMSG_LIGHTNING) {
			local float rnum = random ();
			if (rnum < FRAC (4, 20)) {
				bprint (PRINT_MEDIUM, targ.netname);
				bprint (PRINT_MEDIUM, "'s body crackles with electricity as ");
				bprint (PRINT_MEDIUM, attacker.netname);
				bprint (PRINT_MEDIUM, " (");
				bprint (PRINT_MEDIUM, attacker.real_owner.netname);
				bprint (PRINT_MEDIUM, ") claims another victim\n");
			} else if (rnum < FRAC (10, 20)) {
				bprint (PRINT_MEDIUM, targ.netname);
				bprint (PRINT_MEDIUM, " meets a bolt of lightning directed by ");
				bprint (PRINT_MEDIUM, attacker.netname);
				bprint (PRINT_MEDIUM, " (");
				bprint (PRINT_MEDIUM, attacker.real_owner.netname);
				bprint (PRINT_MEDIUM, ")\n");
			} else if (rnum < FRAC (15, 20)) {
				bprint (PRINT_MEDIUM, targ.netname);
				bprint (PRINT_MEDIUM, "'s goose is cooked by ");
				bprint (PRINT_MEDIUM, attacker.netname);
				bprint (PRINT_MEDIUM, "'s (");
				bprint (PRINT_MEDIUM, attacker.real_owner.netname);
				bprint (PRINT_MEDIUM, ") lightning\n");
			} else {
				bprint (PRINT_MEDIUM, attacker.real_owner.netname);
				bprint (PRINT_MEDIUM, "'s shambler, ");
				bprint (PRINT_MEDIUM, attacker.netname);
				bprint (PRINT_MEDIUM, ", teaches ");
				bprint (PRINT_MEDIUM, targ.netname);
				bprint (PRINT_MEDIUM, " to cook without gas\n");
			}
		} else if (deathmsg == DMSG_DEMON_FIRE) {
			if (random () < FRAC (1, 2)) {
				bprint (PRINT_MEDIUM, targ.netname);
				bprint (PRINT_MEDIUM, " is obliterated by ");
				bprint (PRINT_MEDIUM, attacker.netname);
				bprint (PRINT_MEDIUM, " (");
				bprint (PRINT_MEDIUM, attacker.real_owner.netname);
				bprint (PRINT_MEDIUM, ")'s fireball\n");
			} else {
				bprint (PRINT_MEDIUM, targ.netname);
				bprint (PRINT_MEDIUM, " is turned into little ");
				bprint (PRINT_MEDIUM, targ.netname);
				bprint (PRINT_MEDIUM, "s by ");
				bprint (PRINT_MEDIUM, attacker.netname);
				bprint (PRINT_MEDIUM, " (");
				bprint (PRINT_MEDIUM, attacker.real_owner.netname);
				bprint (PRINT_MEDIUM, ")'s fireball\n");
			}
		} else {
			local float rnum = random ();
			if (rnum < FRAC (2, 100)) {
				bprint (PRINT_MEDIUM, targ.netname);
				bprint (PRINT_MEDIUM, " screams as ");
				bprint (PRINT_MEDIUM, attacker.netname);
				bprint (PRINT_MEDIUM, " (");
				bprint (PRINT_MEDIUM, attacker.real_owner.netname);
				bprint (PRINT_MEDIUM, ")'s claws slash down\n");
			} else if (rnum < FRAC (10, 100)) {
				bprint (PRINT_MEDIUM, targ.netname);
				bprint (PRINT_MEDIUM, " was torn asunder by ");
				bprint (PRINT_MEDIUM, attacker.netname);
				bprint (PRINT_MEDIUM, " (");
				bprint (PRINT_MEDIUM, attacker.real_owner.netname);
				bprint (PRINT_MEDIUM, ")\n");
			} else if (rnum < FRAC (50, 100)) {
				bprint (PRINT_MEDIUM, targ.netname);
				bprint (PRINT_MEDIUM, " is smashed into next week by ");
				bprint (PRINT_MEDIUM, attacker.netname);
				bprint (PRINT_MEDIUM, " (");
				bprint (PRINT_MEDIUM, attacker.real_owner.netname);
				bprint (PRINT_MEDIUM, ")\n");
			} else {
				bprint (PRINT_MEDIUM, attacker.real_owner.netname);
				bprint (PRINT_MEDIUM, "'s shambler, ");
				bprint (PRINT_MEDIUM, attacker.netname);
				if (rnum < FRAC (75, 100))
					bprint (PRINT_MEDIUM, ", tears ");
				else
					bprint (PRINT_MEDIUM, ", rips ");
				bprint (PRINT_MEDIUM, targ.netname);
				bprint (PRINT_MEDIUM, " to shreds\n");
			}
		}
	
		if (!Teammate (targ.team_no, attacker.real_owner.team_no) || attacker.real_owner.team_no < 1)
			Give_Frags_Out (attacker.real_owner, attacker.real_owner, 1, 0, 1, 1, 0);
	}
};

void (entity targ, entity attacker) Obituary_Player_by_Teledeath =
{
	bprint (PRINT_MEDIUM, targ.netname);
	bprint (PRINT_MEDIUM, " was telefragged by ");
	bprint (PRINT_MEDIUM, attacker.owner.netname);
	bprint (PRINT_MEDIUM, "\n");

	if (!Teammate (targ.team_no, attacker.owner.team_no) || attacker.owner.team_no < 1)
		Give_Frags_Out (attacker.owner, attacker.owner, 1, 0, 1, 1, 0);
};

void (entity targ, entity attacker) Obituary_Player_by_Teledeath2 =
{
	bprint (PRINT_MEDIUM, "Satan's power deflects ");
	bprint (PRINT_MEDIUM, targ.netname);
	bprint (PRINT_MEDIUM, "'s telefrag\n");

	Give_Frags_Out (targ, targ, -1, 1, 1, 1, 0);
};

void (entity targ, entity attacker) Obituary_Player_by_Goal =
{ // Killed by a goal
	if (attacker.deathtype != "")
	{
		bprint (PRINT_MEDIUM, targ.netname);
		bprint (PRINT_MEDIUM, attacker.deathtype);
	}
	logfrag (targ, targ);
};

void (entity targ, entity attacker) Obituary_Player_by_Player =
{
	if (targ == attacker) {
		local string deathstring;

		// killed self
		Give_Frags_Out (attacker, attacker, -1, 0, 1, 1, 1);

		bprint (PRINT_MEDIUM, targ.netname);

		if (deathmsg == DMSG_GREN_HAND)
			deathstring = " grenades himself\n";
		else if (deathmsg == DMSG_MARTYR)
			deathstring = " dies for the cause\n";
		else if (deathmsg == DMSG_BERSERK) {
			if (random () < FRAC (1, 2))
				deathstring = " collapses from exhaustion\n";
			else
				deathstring = " goes down fighting\n";
		} else if (deathmsg == DMSG_GREN_NAIL)
			deathstring = " hammers himself\n";
		else if (deathmsg == DMSG_GREN_FRAG)
			deathstring = " fragments himself\n";
		else if (deathmsg == DMSG_LAND_MINE)
			deathstring = " forgot where he put his minefield\n";
		else if (deathmsg == DMSG_GREN_MIRV)
			deathstring = " goes to pieces\n";
		else if (deathmsg == DMSG_GREN_PIPE)
			deathstring = " ambushes himself with his own pipebombs\n";
		else if (deathmsg == DMSG_GREN_GAS)
			deathstring = " chokes on his own gas\n";
		else if (deathmsg == DMSG_GREN_EMP)
			deathstring = " explodes his ammo and body\n";
		else if (deathmsg == DMSG_GREN_FLASH)
			deathstring = " is charred by his own flash grenade\n";
		else if (deathmsg == DMSG_GREN_EMP_AMMO)
			deathstring = " detonates an ammo box too close to him\n";
		else if (deathmsg == DMSG_DETPACK)
			deathstring = " set the detpack and forgot to run\n";
		else if (deathmsg == DMSG_BIOWEAPON)
			deathstring = " died by his own infection!\n";
		else if (deathmsg == DMSG_FF_HACKED)
			deathstring = " is fried in his own force field\n";
		else if (deathmsg == DMSG_FF_STUCK_HACKED)
			deathstring = " is caught and shocked to death in his own force field\n";
		else if (deathmsg == DMSG_SPANNERFIELD)
			deathstring = " learns something about spanners and force fields...\n";
		else if (deathmsg == DMSG_MAUSER)
			deathstring = " assassinated himself!\n";
		else if (deathmsg == DMSG_DAEDALUS)
			deathstring = " flew too close to the sun!\n";
		else if (deathmsg == DMSG_AIRG || deathmsg == DMSG_AIRG_WATER)
			deathstring = " Airfists his own ass!\n";
		else if (deathmsg == DMSG_JUDOKA)
			deathstring = " broke his own arms!\n";
		else if (deathmsg == DMSG_AXE)
			deathstring = " drove an axe through his own head!\n";
		else if (deathmsg == DMSG_BACKSTAB)
			deathstring = " drove a knife into his own heart!\n";
		else if (deathmsg == DMSG_FGTRAP)
			deathstring = " explodes with his own (trapped) field generator!\n";
		else if (deathmsg == DMSG_CALTROP)
			deathstring = " stepped on too many of his own caltrops\n";
		else if (deathmsg == DMSG_FLYCALTROP)
			deathstring = " was spiked by his own catlrop\n";
		else if (deathmsg == DMSG_ROCKETL) {
			if (random () < FRAC (1, 2))
				deathstring = " becomes bored with life\n";
			else
				deathstring = " checks if his weapon is loaded\n";
		} else if (deathmsg == DMSG_CLUSTER_ROCKET)
			deathstring = " eats his clusters\n";
		else if (deathmsg == DMSG_LASERCANNON)
			deathstring = " blasts himself\n";
		else if (deathmsg == DMSG_INCENDIARY)
			deathstring = " chars himself with an incendiary rocket\n";
		else if (deathmsg == DMSG_GRENADEL)
			deathstring = " tries to put the pin back in\n";
		else if (deathmsg == DMSG_FLAME)
			deathstring = " torches himself\n";
		else if (deathmsg == DMSG_HOVER) //WK
			deathstring = " dies from uncomfortable boots\n";
		else if (deathmsg == DMSG_LIGHTNING)
			deathstring = " electrocutes himself\n";
		else if (deathmsg == DMSG_LIGHTNING && targ.waterlevel > 1)
			deathstring = " discharges into the water.\n";
		else
			deathstring = " kills himself!\n";

		bprint (PRINT_MEDIUM, targ.netname);
		bprint (PRINT_MEDIUM, deathstring);
	} else if (teamplay && Teammate (targ.team_no, attacker.team_no)) {
		// killed a team member
		if (Teammate (targ.team_no, attacker.team_no) )
			Give_Frags_Out (attacker, attacker, -1, 0, 1, 1, 0);
		else
			Give_Frags_Out (attacker, attacker, 1, 0, 1, 1, 0);

		if (deathmsg == DMSG_MEDIKIT) {
			bprint (PRINT_MEDIUM, targ.netname);
			bprint (PRINT_MEDIUM, " didn't survive the operation.\n");
		} else if (deathmsg == DMSG_EXPBODY) {
			bprint (PRINT_MEDIUM, targ.netname);
			bprint (PRINT_MEDIUM, " has been killed as a side effect of ");
			bprint (PRINT_MEDIUM, attacker.netname);
			bprint (PRINT_MEDIUM, "'s body explosion\n");
			return;
		} else {
			local float rnum = random ();

			if (rnum < FRAC (1, 4)) {
				bprint (PRINT_MEDIUM, attacker.netname);
				bprint (PRINT_MEDIUM, " mows down teammate ");
				bprint (PRINT_MEDIUM, targ.netname);
			} else if (rnum < FRAC (2, 4)) {
				bprint (PRINT_MEDIUM, attacker.netname);
				bprint (PRINT_MEDIUM, " checks his glasses after killing ");
				bprint (PRINT_MEDIUM, targ.netname);
			} else if (rnum < FRAC (3, 4)) {
				bprint (PRINT_MEDIUM, attacker.netname);
				bprint (PRINT_MEDIUM, " gets a frag for the other team with ");
				bprint (PRINT_MEDIUM, targ.netname);
				bprint (PRINT_MEDIUM, "'s death");
			} else {
				bprint (PRINT_MEDIUM, targ.netname);
				bprint (PRINT_MEDIUM, " doesn't wuv ");
				bprint (PRINT_MEDIUM, attacker.netname);
				bprint (PRINT_MEDIUM, " any more! Wah!");
			}
	
			bprint (PRINT_MEDIUM, "\n");
		}
	} else {
		local string deathstring;
		local string deathstring2;

		Give_Frags_Out (attacker, targ, 1, 1, 1, 1, 1);

		if (attacker.tfstate & TFSTATE_INSPIRED) {
			attacker.inspirator.real_frags += 0.5;
			if (!(toggleflags & TFLAG_TEAMFRAGS))
				attacker.inspirator.frags = attacker.inspirator.real_frags;
		}

		if (attacker.aura && attacker.crusader_inspirator != world) {
			attacker.crusader_inspirator.real_frags += 0.5;
			if (!(toggleflags & TFLAG_TEAMFRAGS))
				attacker.crusader_inspirator.frags = attacker.crusader_inspirator.real_frags;
		}

		if (deathmsg == DMSG_CLUSTER_ROCKET) {
			if (random () < FRAC (1, 2)) {
				deathstring = " is put away by ";
				deathstring2 = "'s cluster rockets\n";
			} else {
				deathstring = " is destroyed by ";
				deathstring2 = "'s cluster rockets\n";
			}
		} else if (deathmsg == DMSG_EXPBODY) {
			deathstring = " is killed by ";
			deathstring2 = "'s body explosion\n";
		} else if (deathmsg == DMSG_GREN_HAND) {
			deathstring = " surfs on a grenade from ";
			deathstring2 = "\n";
		} else if (deathmsg == DMSG_GREN_NAIL) {
			deathstring = " gets flayed by ";
			deathstring2 = "'s nail grenade\n";
		} else if (deathmsg == DMSG_GREN_FRAG) {
			local float rnum = random ();

			if (rnum < FRAC (2, 4)) {
				deathstring = " is slashed apart by ";
				deathstring2 = "'s frag grenade\n";
			} else if (rnum < FRAC (3, 4)) {
				deathstring = "'s jugular artery is severed by ";
				deathstring2 = "'s frag grenade.\n";
			} else {
				deathstring = "'s carotoid artery is severed by ";
				deathstring2 = "'s frag grenade.\n";
			}
		} else if (deathmsg == DMSG_GREN_MIRV) {
			deathstring = " gets spammed by ";
			deathstring2 = "'s Mirv grenade\n";
		} else if (deathmsg == DMSG_CALTROP) {
			deathstring = " collects one too many of ";
			deathstring2 = "'s caltrops\n";
		} else if (deathmsg == DMSG_FLYCALTROP) {
			deathstring = " was spiked by ";
			deathstring2 = "'s caltrops\n";
		} else if (deathmsg == DMSG_GREN_PIPE) {
			deathstring = " is caught by ";
			deathstring2 = "'s pipebomb trap\n";
		} else if (deathmsg == DMSG_GREN_GAS) {
			deathstring = " gags on ";
			deathstring2 = "'s noxious gasses\n";
		} else if (deathmsg == DMSG_GREN_EMP) {
			deathstring = "'s ammo detonates him as ";
			deathstring2 = "'s EMP fries it.\n";
		} else if (deathmsg == DMSG_GREN_FLASH) {
			deathstring = " is charred by ";
			deathstring2 = "'s flash grenade.\n";
		} else if (deathmsg == DMSG_GREN_EMP_AMMO) {
			deathstring = " stands near some ammo as ";
			deathstring2 = "'s EMP nukes it\n";
		} else if (deathmsg == DMSG_DETPACK) {
			deathstring = " reaches orbit via ";
			deathstring2 = "'s detpack\n";
		} else if (deathmsg == DMSG_DETPACK_DIS) {
			deathstring = " cut the red wire of ";
			deathstring2 = "'s detpack\n";
		} else if (deathmsg == DMSG_BIOWEAPON) {
			deathstring = " dies from ";
			deathstring2 = "'s mysterious tropical disease\n";
		} else if (deathmsg == DMSG_MAUSER) {
			sprint (attacker, PRINT_HIGH, "You mercilessly slaughter ");
			sprint (attacker, PRINT_HIGH, targ.netname);
			sprint (attacker, PRINT_HIGH, "!\n");
			return;
		} else if (deathmsg == DMSG_DAEDALUS) {
			deathstring = " is melted by ";
			deathstring2 = "'s Daedalus impulse rifle\n";
		} else if (deathmsg == DMSG_BIOWEAPON_ATT) {
			deathstring = " escapes infection from ";
			deathstring2 = " by dying first\n";
		} else if (deathmsg == DMSG_GRENADEL) {
			if (targ.health < -40) {
				deathstring = " was gibbed by ";
				deathstring2 = "'s grenade\n";
			} else {
				deathstring = " eats ";
				deathstring2 = "'s pineapple\n";
			}
		} else if (deathmsg == DMSG_STUCK_FORCEFIELD) {
			deathstring = " is fried in ";
			deathstring2 = "'s force field\n";
		} else if (deathmsg == DMSG_FORCEFIELD) {
			deathstring = " had a shocking experience on ";
			deathstring2 = "'s force field\n";
		} else if (deathmsg == DMSG_FGTRAP) {
			deathstring = " explodes with ";
			deathstring2 = "'s trapped field generator\n";
		} else if (deathmsg == DMSG_ROCKETL) {
			if (targ.health < -40) {
				deathstring = " was gibbed by ";
				deathstring2 = "'s rocket\n" ;
			} else {
				deathstring = " rides ";
				deathstring2 = "'s rocket\n";
			}
		} else if (deathmsg == DMSG_HOVER) {
			deathstring = " choked on ";
			deathstring2 = "'s hover exhaust\n";
		} else if (deathmsg == DMSG_LAND_MINE) {
			if (targ.health < -40) {
				if (random () < FRAC (4, 5))
					deathstring = " was turned into a shower of gibs by ";
				else
					deathstring = " was launched 80 ft into the air by ";
			} else {
				if (random () < FRAC (4, 5))
					deathstring = " walked over ";
				else
					deathstring = " was launched 40 ft into the air by ";
			}
			deathstring2 = "'s land mine\n";
		} else if (deathmsg == DMSG_FLAME) {
			local float rnum = random ();

			if (rnum < FRAC (1, 5)) {
				deathstring =  " is burnt up by ";
				deathstring2 = "'s flame\n";
			} else if (rnum < FRAC (2, 5)) {
				deathstring =  " is fried by ";
				deathstring2 = "'s fire\n";
			} else if (rnum < FRAC (3, 5)) {
				deathstring =  " feels ";
				deathstring2 = "'s fire of wrath\n";
			} else if (rnum < FRAC (4, 5)) {
				deathstring =  " is reduced to ashes by ";
				deathstring2 = "\n";
			} else {
				deathstring = " is grilled by ";
				deathstring2 = "'s flame\n";
			}
		} else if (deathmsg == DMSG_AXE) {
			if (attacker.cutf_items & CUTF_KNIFE) {
				if (attacker.job & JOB_WARLOCK)
					deathstring = " is forced to donate his blood to ";
				else
					deathstring = " was knife-murdered by ";
			} else
				deathstring = " was axe-murdered by ";

			deathstring2 = "\n";

			if (attacker.demon_blood < MAX_KNIFE_BLOOD) //SB - OfN defined max now
				attacker.demon_blood = attacker.demon_blood + 1;
		} else if (deathmsg == DMSG_SPANNER) {
			deathstring = " was spanner-murdered by ";
			deathstring2 = "\n";
		} else if (deathmsg == DMSG_SHOTGUN) {
			deathstring = " chewed on ";
			deathstring2 = "'s boomstick\n";
		} else if (deathmsg == DMSG_SSHOTGUN) {
			deathstring = " ate 2 loads of ";
			deathstring2 = "'s buckshot\n";
		} else if (deathmsg == DMSG_NAILGUN) {
			deathstring = " was nailed by ";
			deathstring2 = "\n";
		} else if (deathmsg == DMSG_SNG) {
			deathstring = " was spiked by ";
			deathstring2 = "'s super nailgun\n";
		} else if (deathmsg == DMSG_LIGHT_ASSAULT) {
			local float rnum = random ();

			if (rnum < FRAC (1, 10)) {
				deathstring = " wishes ";
				deathstring2 = "'s gun was still an SNG\n";
			} else if (rnum < FRAC (5, 10)) {
				deathstring = " gets felled by ";
				deathstring2 = "'s light assault cannon\n";
			} else {
				deathstring = " gets sawn almost in half by ";
				deathstring2 = "\n";
			}
		} else if (deathmsg == DMSG_LIGHTNING) {
			local float rnum = random ();

			if (rnum < FRAC (1, 10)) {
				deathstring = " has never seen a lightning gun in TF before. (";
				deathstring2 = " has.)\n";
			} else if (rnum < FRAC (2, 10)) {
				deathstring = " is thunderstruck by ";
				deathstring2 = "'s gun\n";
			} else if (rnum < FRAC (4, 10)) {
				deathstring = " is electrocuted by ";
				deathstring2 = "'s thunderbolt\n";
			} else if (rnum < FRAC (7, 10)) {
				deathstring = " is shocked to death by ";
				deathstring2 = "'s lightning gun\n";
			} else {
				deathstring = " accepts ";
				if (attacker.waterlevel > 1)
					deathstring2 = "'s discharge\n";
				else
					deathstring2 = "'s shaft\n";
			}
		} else if (deathmsg == DMSG_HOOK) {
			deathstring = " grappled with ";
			deathstring2 = "\n";
		} else if (deathmsg == DMSG_JUDOKA) {
			deathstring = " had his arms broken by ";
			deathstring2 = "\n";
		} else if (deathmsg == DMSG_AIRG) {
			deathstring = " is ventilated by ";
			deathstring2 = "\n";
		} else if (deathmsg == DMSG_LASERCANNON) {
			deathstring = " was blasted by ";
			deathstring2 = "'s laser cannon\n";
		} else if (deathmsg == DMSG_DISPEL) {
			deathstring = " is banished to the netherworld by ";
			deathstring2 = "\n";
		} else if (deathmsg == DMSG_AIRG_WATER) {
			if (random () < FRAC (1, 2)) {
				deathstring = " learns to swim backwards with ";
				deathstring2 = "'s help\n";
			} else {
				deathstring = " is underwater-airfisted by ";
				deathstring2 = "\n";
			}
		} else if (deathmsg == DMSG_SNIPERRIFLE) {
			if (attacker.cutf_items & CUTF_OTR) {
				deathstring = " learns from ";
				deathstring2 = " what an OTR bullet is\n";
			} else {
				if (random () < FRAC (1, 2)) {
					deathstring = " takes a bullet in the chest from ";
					deathstring2 = "\n";
				} else {
					deathstring = " succumbs to sniperfire from ";
					deathstring2 = "\n";
				}
			}
		} else if (deathmsg == DMSG_SNIPERHEADSHOT) {
			if (attacker.cutf_items & CUTF_OTR && random () < FRAC (3, 5)) {
				deathstring = "'s head flies away due to ";
				deathstring2 = " and his OTR bullets\n";
			} else {
				if (random () < FRAC (1, 2)) {
					deathstring = " gets a third eye from ";
					deathstring2 = "\n";
				} else {
					deathstring = " gets his head blown off by ";
					deathstring2 = "\n";
				}
			}
		} else if (deathmsg == DMSG_SNIPERLEGSHOT) {
			if (attacker.cutf_items & CUTF_OTR && random () < FRAC (1, 4)) {
				deathstring = " owns a metallic replacement for his legs from ";
				deathstring2 = "\n";
			} else {
				if (random () < FRAC (1, 2)) {
					deathstring = " is made legless by ";
					deathstring2 = "\n";
				} else {
					deathstring = " gets his legs blown off by ";
					deathstring2 = "\n";
				}
			}
		} else if (deathmsg == DMSG_AUTORIFLE) {
			deathstring = " collects ";
			deathstring2 = "'s bullet spray.\n";
		} else if (deathmsg == DMSG_ASSAULTCANNON) {
			deathstring = " gets sawn in half by ";
			deathstring2 = "\n";
		} else if (deathmsg == DMSG_BACKSTAB) {
			if (random () < FRAC (1, 2)) {
				deathstring = " gets assassinated by ";
				deathstring2 = "\n";
			} else {
				deathstring = " is knifed from behind by ";
				deathstring2 = "\n";
			}
			if (attacker.demon_blood < MAX_KNIFE_BLOOD) //SB
				attacker.demon_blood = attacker.demon_blood + 1;
		} else if (deathmsg == DMSG_TRANQ) {
			deathstring = " is put to sleep by ";
			deathstring2 = "\n";
		} else if (deathmsg == DMSG_LASERBOLT) {
			deathstring = " gets a hole in his heart from ";
			deathstring2 = "'s railgun\n";
		} else if (deathmsg == DMSG_INCENDIARY) {
			deathstring = " gets well done by ";
			deathstring2 = "'s incendiary rocket\n";
		} else {
			deathstring = " has a BUG death (";
			deathstring2 = ")\n";
		}

		bprint (PRINT_MEDIUM, targ.netname);
		bprint (PRINT_MEDIUM, deathstring);
		bprint (PRINT_MEDIUM, attacker.netname);
		bprint (PRINT_MEDIUM, deathstring2);
	}
};

void (entity targ, entity attacker) Obituary_Player_by_Dispenser =
{
	if (!(attacker.is_malfunctioning & SCREWUP_TWO)
		&& !(attacker.is_malfunctioning & SCREWUP_FOUR)) {
		if (targ == attacker.real_owner) {
			bprint (PRINT_MEDIUM, targ.netname);
			bprint (PRINT_MEDIUM, " dispenses with himself\n");

			Give_Frags_Out (attacker, targ, -1, 0, 1, 1, 0);
		} else {
			bprint (PRINT_MEDIUM, targ.netname);
			bprint (PRINT_MEDIUM, " didn't insert the correct change into ");
			bprint (PRINT_MEDIUM, attacker.real_owner.netname);
			bprint (PRINT_MEDIUM, "'s dispenser\n");

			if (Teammate (targ.team_no, attacker.team_no))
				Give_Frags_Out (attacker, attacker, -1, 0, 1, 1, 0);
			else
				Give_Frags_Out (attacker, targ, 1, 0, 1, 1, 0);
		}
	} else {
		if (targ == attacker.real_owner) {
			bprint (PRINT_MEDIUM, attacker.martyr_enemy.netname);
			bprint (PRINT_MEDIUM, " laughs as ");
			bprint (PRINT_MEDIUM, targ.netname);
			bprint (PRINT_MEDIUM, " is blown apart by his trapped dispenser\n");

			Give_Frags_Out (attacker.real_owner, attacker, -1, 0, 1, 1, 0);
		} else if (targ == attacker.martyr_enemy) {
			bprint (PRINT_MEDIUM, targ.netname);
			bprint (PRINT_MEDIUM, " should've stayed away from ");
			bprint (PRINT_MEDIUM, attacker.real_owner.netname);
			bprint (PRINT_MEDIUM, "'s dispenser\n");

			Give_Frags_Out (attacker.martyr_enemy, attacker, -1, 0, 1, 1, 0);
		} else {
			bprint (PRINT_MEDIUM, attacker.martyr_enemy.netname);
			bprint (PRINT_MEDIUM, " laughs as ");
			bprint (PRINT_MEDIUM, targ.netname);
			bprint (PRINT_MEDIUM, " is blown to pieces by ");
			bprint (PRINT_MEDIUM, attacker.real_owner.netname);
			bprint (PRINT_MEDIUM, "'s trapped dispenser\n");

			Give_Frags_Out (attacker.martyr_enemy, targ, 1, 0, 1, 1, 0);
		}
	}
};

void (entity targ, entity attacker) Obituary_Player_by_ForceField =
{
	if (targ == attacker.real_owner) {
		bprint (PRINT_MEDIUM, attacker.martyr_enemy.netname);
		bprint (PRINT_MEDIUM, " laughs as ");
		bprint (PRINT_MEDIUM, targ.netname);
		bprint (PRINT_MEDIUM, " fries in his own hacked force field\n");

		Give_Frags_Out (attacker.real_owner, attacker, -1, 0, 1, 1, 0);
	} else if (targ == attacker.martyr_enemy) {
		bprint (PRINT_MEDIUM, targ.netname);
		bprint (PRINT_MEDIUM, " hacked the wrong thing in  ");
		bprint (PRINT_MEDIUM, attacker.real_owner.netname);
		bprint (PRINT_MEDIUM, "'s force field generator\n");

		Give_Frags_Out (attacker.martyr_enemy, attacker, -1, 0, 1, 1, 0);
	} else {
		bprint (PRINT_MEDIUM, attacker.martyr_enemy.netname);
		bprint (PRINT_MEDIUM, " laughs as ");
		bprint (PRINT_MEDIUM, targ.netname);
		bprint (PRINT_MEDIUM, " is fried in ");
		bprint (PRINT_MEDIUM, attacker.real_owner.netname);
		bprint (PRINT_MEDIUM, "'s hacked force field\n");

		Give_Frags_Out (attacker.martyr_enemy, targ, 1, 0, 1, 1, 0);
	}
};

void (entity targ, entity attacker) Obituary_Player_by_SentryTesla =
{
	if (targ == attacker.real_owner) {
		local string deathstring;

		if (deathmsg == DMSG_SENTRYGUN_ROCKET)
			deathstring = " intercepts his sentry gun's rocket\n";
		else if (deathmsg == DMSG_SENTRYGUN_BULLET)
			deathstring = " crossed his sentry gun's line of fire\n";
		else if (deathmsg == DMSG_BUG_ZAPPER)
			deathstring = " was electrocuted by his own sentry\n";
		else
			deathstring = " let his sentry turn against him\n"; //CH

		bprint (PRINT_MEDIUM, targ.netname);
		bprint (PRINT_MEDIUM, deathstring);
	} else {
		local string deathstring;
		local string deathstring2;

		if (Teammate (targ.team_no, attacker.team_no))
			Give_Frags_Out (attacker.real_owner, targ, -1, 1, 1, 1, 0);
		else {
			Give_Frags_Out (attacker, targ, 1, 0, 2, 0, 0); //gun
			Give_Frags_Out (attacker.real_owner, targ, 1, 1, 1, 1, 0);
		}

		if (deathmsg == DMSG_SENTRYGUN_ROCKET) {
			deathstring = " hates ";
			deathstring2 = "'s sentry gun\n";
		} else if (deathmsg == DMSG_SENTRYGUN_BULLET) {
			deathstring = " is mown down by ";
			deathstring2 = "'s sentry gun\n";
		} else if (deathmsg == DMSG_TESLA) {
			local float rnum = random ();

			if (rnum < FRAC (2, 4)) {
				deathstring = " was electrocuted by ";
				deathstring2 = "'s tesla coil\n";
			} else if (rnum < FRAC (3, 4)) {
				deathstring = " was shocked to pieces by ";
				deathstring2 = "'s tesla sentry\n";
			} else {
				deathstring = " was annihilated by ";
				deathstring2 = "'s tesla gun\n";
			}
		} else if (deathmsg == DMSG_BUG_ZAPPER) {
			local float rnum = random ();

			if (rnum < FRAC (1, 5)) {
				deathstring = " made a frying sound after running into ";
				deathstring2 = "'s Sentry Point Defense System\n";
			} else if (rnum < FRAC (2, 5)) {
				deathstring = " is cooked at 400 degrees by ";
				deathstring2 = "'s sentry gun\n";
			} else if (rnum < FRAC (3, 5)) {
				deathstring = " is disintegrated by ";
				deathstring2 = "'s Sentry Point Defense System\n";
			} else if (rnum < FRAC (4, 5)) {
				deathstring = " is obliterated by ";
				deathstring2 = "'s sentry gun\n";
			} else {
				deathstring = " decides ";
				deathstring2 = "'s sentry isn't so cuddly after all!\n";
			}
		} else {
			deathstring = " is given a BUG death from ";
			deathstring2 = "'s sentry\n";
		}

		bprint (PRINT_MEDIUM, targ.netname);
		bprint (PRINT_MEDIUM, deathstring);
		bprint (PRINT_MEDIUM, attacker.real_owner.netname);
		bprint (PRINT_MEDIUM, deathstring2);
	}
};

void (entity targ, entity attacker) Obituary_Player_by_Teleporter =
{
	sprint (attacker.martyr_enemy, PRINT_HIGH, targ.netname);
	sprint (attacker.martyr_enemy, PRINT_HIGH, " disappears into the void.\n");
};

void (entity targ, entity attacker) Obituary_Player_Misc =
{
	local string deathstring;

	Give_Frags_Out (targ, targ, -1, 1, 1, 1, 0);
//	logfrag (targ, targ);

	if (targ.watertype == CONTENTS_WATER) {
		local float rnum = random ();

		if (rnum < FRAC (1, 4))
			deathstring = " sleeps with the fishes\n";
		else if (rnum < FRAC (2, 4))
			deathstring = " ate before swimming\n"; //CH
		else if (rnum < FRAC (3, 4))
			deathstring = " was searching for Atlantis when he drowned\n";
		else
			deathstring = " thought he was Jacques Cousteau, but forgot his diving gear!\n";
	} else if (targ.watertype == CONTENTS_SLIME) {
		if (random () < FRAC (1, 2))
			deathstring = " gulped a load of slime\n";
		else
			deathstring = " can't exist on slime alone\n";
	} else if (targ.watertype == CONTENTS_LAVA) {
		if (targ.health < -15)
			deathstring = " burst into flames\n";
		else if (random () < FRAC (1, 2))
			deathstring = " turned into hot slag\n";
		else
			deathstring = " visits the Volcano God\n";
	} else if (attacker.classname == "explo_box") {
		deathstring = " blew up\n";
	} else if (attacker.solid == SOLID_BSP && attacker != world) {
		deathstring = " was squished\n";
	} else if (attacker.classname == "trap_shooter"
			   || attacker.classname == "trap_spikeshooter"
			   || attacker.classname == "trap_tf_spikeshooter"
			   || attacker.classname == "trap_tf_shooter") {
		if (attacker.deathtype)
			deathstring = attacker.deathtype;
		else if (attacker.spawnflags == SPAWNFLAG_LASER)
			deathstring = " had surgery from a laser\n";
		else if (attacker.spawnflags == SPAWNFLAG_TFROCKET)
			deathstring = " took a ride on a rocket\n";
		else if (attacker.spawnflags == SPAWNFLAG_TFGRENADE)
			deathstring = " tried to eat a wild pineapple\n";
		else if (attacker.spawnflags == SPAWNFLAG_TFFLAME)
			deathstring = " was burned alive\n";
		else if (attacker.spawnflags == SPAWNFLAG_SUPERSPIKE)
			deathstring = " was nailed to the ground\n";
		else
			deathstring = " was spiked\n";
	} else if (attacker.classname == "fireball") {
		deathstring = " ate a lavaball\n";
	} else if (attacker.classname == "trigger_changelevel") {
		deathstring = " tried to leave\n";
	} else if (targ.deathtype == "falling" && attacker == world) {
		targ.deathtype = "";
		deathstring = " fell to his death\n";
	} else { //- OfN - unknown death by himself
		local float rnum = random ();

		if (rnum < FRAC (1, 5))
			deathstring = " died happily\n";
		else if (rnum < FRAC (2, 5))
			deathstring = " knows how to die with style\n";
		else if (rnum < FRAC (3, 5))
			deathstring = " simply dies\n";
		else if (rnum < FRAC (4, 5))
			deathstring = " had an original death\n";
		else
			deathstring = " wishes we had better death messages\n";
	}

	bprint (PRINT_HIGH, targ.netname);
	bprint (PRINT_MEDIUM, deathstring);
};

void (entity targ, entity attacker) Obituary_Monster =
{
	if (targ.classname == "monster_wizard")
		Obituary_Monster_Wizard (targ, attacker);
	else if (targ.classname == "monster_demon1")
		Obituary_Monster_Demon1 (targ, attacker);
	else if (targ.classname == "monster_army")
		Obituary_Monster_Army (targ, attacker);
	else if (targ.classname == "monster_shambler")
		Obituary_Monster_Shambler (targ, attacker);
};

void (entity targ, entity attacker) Obituary_Monster_Wizard =
{
	custom_demon_name (targ);

	if (attacker.classname == "building_tesla")
		Obituary_Monster_Wizard_by_Tesla (targ, attacker);
	else if (attacker.classname == "building_sentry")
		Obituary_Monster_Wizard_by_Sentry (targ, attacker);
	else if (attacker.classname == "player")
		Obituary_Monster_Wizard_by_Player (targ, attacker);
	else if (attacker.classname == "monster_army")
		Obituary_Monster_Wizard_by_Army (targ, attacker);
	else if (attacker.classname == "monster_demon1")
		Obituary_Monster_Wizard_by_Demon1 (targ, attacker);
	else if (attacker.classname == "monster_shambler")
		Obituary_Monster_Wizard_by_Shambler (targ, attacker);
	else if (attacker.classname == "monster_wizard")
		Obituary_Monster_Wizard_by_Wizard (targ, attacker);
	else
		Obituary_Monster_Misc (targ, attacker);
};

void (entity targ, entity attacker) Obituary_Monster_Wizard_by_Tesla =
{
	if (teamplay
		&& (attacker.real_owner.team_no > 0)
		&& (targ.real_owner.team_no > 0)) {
		if (!Teammate (targ.real_owner.team_no, attacker.real_owner.team_no)) {
			Give_Frags_Out (attacker, targ, 1, 0, 2, 0, 0); //Tesla
			Give_Frags_Out (attacker.real_owner, targ, 1, 0, 1, 1, 0);

			bprint (PRINT_MEDIUM, targ.real_owner.netname);
			bprint (PRINT_MEDIUM, "'s scrag, ");
			bprint (PRINT_MEDIUM, targ.netname);
			bprint (PRINT_MEDIUM, ", was shocked to death by ");
			bprint (PRINT_MEDIUM, attacker.real_owner.netname);
			bprint (PRINT_MEDIUM, "'s tesla sentry\n");
		} else {
			Give_Frags_Out (attacker, targ, -1, 0, 2, 0, 0); //Tesla
			Give_Frags_Out (attacker.real_owner, targ, -1, 0, 1, 1, 0);

			bprint (PRINT_MEDIUM, targ.real_owner.netname);
			bprint (PRINT_MEDIUM, "'s friendly scrag, ");
			bprint (PRINT_MEDIUM, targ.netname);
			bprint (PRINT_MEDIUM, ", was shocked to death by ");
			bprint (PRINT_MEDIUM, attacker.real_owner.netname);
			bprint (PRINT_MEDIUM, "'s tesla sentry\n");
		}
	}
};

void (entity targ, entity attacker) Obituary_Monster_Wizard_by_Sentry =
{
	if (teamplay
		&& (attacker.real_owner.team_no > 0)
		&& (targ.real_owner.team_no > 0)) {
		if (!Teammate (targ.real_owner.team_no, attacker.real_owner.team_no)) {
			Give_Frags_Out (attacker, targ, 1, 0, 2, 0, 0); //Sentry
			Give_Frags_Out (attacker.real_owner, targ, 1, 0, 1, 1, 0);

			bprint (PRINT_MEDIUM, targ.real_owner.netname);
			bprint (PRINT_MEDIUM, "'s scrag, ");
			bprint (PRINT_MEDIUM, targ.netname);
			bprint (PRINT_MEDIUM, ", was pulverized by ");
			bprint (PRINT_MEDIUM, attacker.real_owner.netname);
			bprint (PRINT_MEDIUM, "'s sentry gun\n");
		} else {
			Give_Frags_Out (attacker, targ, -1, 0, 2, 0, 0); //Sentry
			Give_Frags_Out (attacker.real_owner, targ, -1, 0, 1, 1, 0);

			bprint (PRINT_MEDIUM, targ.real_owner.netname);
			bprint (PRINT_MEDIUM, "'s friendly scrag, ");
			bprint (PRINT_MEDIUM, targ.netname);
			bprint (PRINT_MEDIUM, ", was pulverized by ");
			bprint (PRINT_MEDIUM, attacker.real_owner.netname);
			bprint (PRINT_MEDIUM, "'s sentry gun\n");
		}
	}
};

void (entity targ, entity attacker) Obituary_Monster_Wizard_by_Player =
{
	if (teamplay
		&& (attacker.team_no > 0)
		&& (self.real_owner.team_no > 0)) {
		if (Teammate (targ.real_owner.team_no, attacker.team_no)) {
			if (attacker == self.real_owner) {
				Give_Frags_Out (attacker, targ, -2, 0, 1, 1, 0);

				bprint (PRINT_MEDIUM, attacker.netname);
				if (deathmsg == DMSG_LASERCANNON)
					bprint (PRINT_MEDIUM, " cuts his own scrag in half!\n");
				else
					bprint (PRINT_MEDIUM, " kills his own scrag!\n");
			} else {
				Give_Frags_Out (attacker, targ, -1, 0, 1, 1, 0);

				bprint (PRINT_MEDIUM, attacker.netname);
				if (deathmsg == DMSG_LASERCANNON)
					bprint (PRINT_MEDIUM, " blasts the friendly scrag ");
				else
					bprint (PRINT_MEDIUM, " mows down the friendly scrag ");
				bprint (PRINT_MEDIUM, targ.netname);
				bprint (PRINT_MEDIUM, " (");
				bprint (PRINT_MEDIUM, targ.real_owner.netname);
				bprint (PRINT_MEDIUM, ")\n");
			}
		} else {
			Give_Frags_Out (attacker, targ, 1, 0, 1, 1, 0);

			if (deathmsg == DMSG_LASERCANNON) {
				bprint (PRINT_MEDIUM, attacker.netname);
				bprint (PRINT_MEDIUM, " cuts ");
				bprint (PRINT_MEDIUM, targ.real_owner.netname);
				bprint (PRINT_MEDIUM, "'s scrag in several parts\n");
			} else {
				bprint (PRINT_MEDIUM, targ.real_owner.netname);
				bprint (PRINT_MEDIUM, "'s scrag, ");
				bprint (PRINT_MEDIUM, targ.netname);
				bprint (PRINT_MEDIUM, ", was killed by ");
				bprint (PRINT_MEDIUM, attacker.netname);
				bprint (PRINT_MEDIUM, "\n");
			}

			MonsterKill (attacker); // adds knife kill to warlock if needed
		}
	}
};

void (entity targ, entity attacker) Obituary_Monster_Wizard_by_Army =
{
	custom_demon_name (attacker);
	GetRank (attacker);

	if (Teammate (targ.real_owner.team_no, attacker.real_owner.team_no)) {
		Give_Frags_Out (attacker, targ, -1, 0, 1, 1, 0);

		bprint (PRINT_MEDIUM, attacker.undercover_name);
		bprint (PRINT_MEDIUM, attacker.netname);
		bprint (PRINT_MEDIUM, " (");
		bprint (PRINT_MEDIUM, attacker.real_owner.netname);
		bprint (PRINT_MEDIUM, ") mows down the friendly scrag ");
		bprint (PRINT_MEDIUM, targ.netname);
		bprint (PRINT_MEDIUM, " (");
		bprint (PRINT_MEDIUM, targ.real_owner.netname);
		bprint (PRINT_MEDIUM, ")\n");
	} else {
		Give_Frags_Out (attacker, targ, 1, 0, 1, 1, 0);

		bprint (PRINT_MEDIUM, targ.real_owner.netname);
		bprint (PRINT_MEDIUM, "'s scrag, ");
		bprint (PRINT_MEDIUM, targ.netname);
		bprint (PRINT_MEDIUM, ", is killed by ");
		bprint (PRINT_MEDIUM, attacker.undercover_name);
		bprint (PRINT_MEDIUM, attacker.netname);
		bprint (PRINT_MEDIUM, " (");
		bprint (PRINT_MEDIUM, attacker.real_owner.netname);
		bprint (PRINT_MEDIUM, ")\n");
	}
};

void (entity targ, entity attacker) Obituary_Monster_Wizard_by_Demon1 =
{
	custom_demon_name (attacker);
	if (Teammate (targ.real_owner.team_no, attacker.real_owner.team_no)) {
		Give_Frags_Out (attacker, targ, -1, 0, 1, 1, 0);

		bprint (PRINT_MEDIUM, attacker.netname);
		bprint (PRINT_MEDIUM, " (");
		bprint (PRINT_MEDIUM, attacker.real_owner.netname);
		bprint (PRINT_MEDIUM, ") eviscerates the friendly scrag ");
		bprint (PRINT_MEDIUM, targ.netname);
		bprint (PRINT_MEDIUM, " (");
		bprint (PRINT_MEDIUM, targ.real_owner.netname);
		bprint (PRINT_MEDIUM, ")\n");
	} else {
		Give_Frags_Out (attacker, targ, 1, 0, 1, 1, 0);

		bprint (PRINT_MEDIUM, targ.real_owner.netname);
		bprint (PRINT_MEDIUM, "'s scrag, ");
		bprint (PRINT_MEDIUM, targ.netname);
		bprint (PRINT_MEDIUM, ", is returned to hell by ");
		bprint (PRINT_MEDIUM, attacker.netname);
		bprint (PRINT_MEDIUM, " (");
		bprint (PRINT_MEDIUM, attacker.real_owner.netname);
		bprint (PRINT_MEDIUM, ")\n");
	}
};

void (entity targ, entity attacker) Obituary_Monster_Wizard_by_Shambler =
{
	custom_demon_name (attacker);
	if (Teammate (targ.real_owner.team_no, attacker.real_owner.team_no)) {
		Give_Frags_Out (attacker, targ, -1, 0, 1, 1, 0);

		bprint (PRINT_MEDIUM, "The shambler ");
		bprint (PRINT_MEDIUM, attacker.netname);
		bprint (PRINT_MEDIUM, " (");
		bprint (PRINT_MEDIUM, attacker.real_owner.netname);
		bprint (PRINT_MEDIUM, ") annihilates the friendly scrag ");
		bprint (PRINT_MEDIUM, targ.netname);
		bprint (PRINT_MEDIUM, " (");
		bprint (PRINT_MEDIUM, targ.real_owner.netname);
		bprint (PRINT_MEDIUM, ")\n");
	} else {
		Give_Frags_Out (attacker, targ, 1, 0, 1, 1, 0);

		bprint (PRINT_MEDIUM, targ.real_owner.netname);
		bprint (PRINT_MEDIUM, "'s scrag, ");
		bprint (PRINT_MEDIUM, targ.netname);
		bprint (PRINT_MEDIUM, ", learns a lesson from the shambler ");
		bprint (PRINT_MEDIUM, attacker.netname);
		bprint (PRINT_MEDIUM, " (");
		bprint (PRINT_MEDIUM, attacker.real_owner.netname);
		bprint (PRINT_MEDIUM, ")\n");
	}
};

void (entity targ, entity attacker) Obituary_Monster_Wizard_by_Wizard =
{
	custom_demon_name (attacker);
	if (Teammate (targ.real_owner.team_no, attacker.real_owner.team_no)) {
		Give_Frags_Out (attacker, targ, -1, 0, 1, 1, 0);

		bprint (PRINT_MEDIUM, attacker.netname);
		bprint (PRINT_MEDIUM, " (");
		bprint (PRINT_MEDIUM, attacker.real_owner.netname);
		bprint (PRINT_MEDIUM, ") annihilates the colleague ");
		bprint (PRINT_MEDIUM, targ.netname);
		bprint (PRINT_MEDIUM, " (");
		bprint (PRINT_MEDIUM, targ.real_owner.netname);
		bprint (PRINT_MEDIUM, ")\n");
	} else {
		Give_Frags_Out (attacker, targ, 1, 0, 1, 1, 0);

		bprint (PRINT_MEDIUM, attacker.real_owner.netname);
		bprint (PRINT_MEDIUM, "'s scrag, ");
		bprint (PRINT_MEDIUM, attacker.netname);
		bprint (PRINT_MEDIUM, ", shows to ");
		bprint (PRINT_MEDIUM, targ.netname);
		bprint (PRINT_MEDIUM, " (");
		bprint (PRINT_MEDIUM, targ.real_owner.netname);
		bprint (PRINT_MEDIUM, ") who is the best\n");
	}
};

void (entity targ, entity attacker) Obituary_Monster_Demon1 =
{
	custom_demon_name (targ); //CH

	if (attacker.classname == "building_tesla")
		Obituary_Monster_Demon1_by_Tesla (targ, attacker);
	else if (attacker.classname == "building_sentry")
		Obituary_Monster_Demon1_by_Sentry (targ, attacker);
	else if (attacker.classname == "player")
		Obituary_Monster_Demon1_by_Player (targ, attacker);
	else if (attacker.classname == "monster_army")
		Obituary_Monster_Demon1_by_Army (targ, attacker);
	else if (attacker.classname == "monster_demon1")
		Obituary_Monster_Demon1_by_Demon1 (targ, attacker);
	else if (attacker.classname == "monster_shambler")
		Obituary_Monster_Demon1_by_Shambler (targ, attacker);
	else if (attacker.classname == "monster_wizard")
		Obituary_Monster_Demon1_by_Wizard (targ, attacker);
	else
		Obituary_Monster_Misc (targ, attacker);
};

void (entity targ, entity attacker) Obituary_Monster_Demon1_by_Tesla =
{
	if (teamplay
		&& (attacker.real_owner.team_no > 0)
		&& (targ.real_owner.team_no > 0)) {
		if (!Teammate (targ.real_owner.team_no, attacker.real_owner.team_no)) {
			Give_Frags_Out (attacker, targ, 1, 0, 2, 0, 0); //Tesla
			Give_Frags_Out (attacker.real_owner, targ, 1, 0, 1, 1, 0);

			bprint (PRINT_MEDIUM, targ.real_owner.netname);
			bprint (PRINT_MEDIUM, "'s demon, ");
			bprint (PRINT_MEDIUM, targ.netname);
			bprint (PRINT_MEDIUM, ", was shocked to death by ");
			bprint (PRINT_MEDIUM, attacker.real_owner.netname);
			bprint (PRINT_MEDIUM, "'s tesla sentry\n");
		} else {
			Give_Frags_Out (attacker, targ, -1, 0, 2, 0, 0); //Tesla
			Give_Frags_Out (attacker.real_owner, targ, -1, 0, 1, 1, 0);

			bprint (PRINT_MEDIUM, targ.real_owner.netname);
			bprint (PRINT_MEDIUM, "'s friendly demon, ");
			bprint (PRINT_MEDIUM, targ.netname);
			bprint (PRINT_MEDIUM, ", was shocked to death by ");
			bprint (PRINT_MEDIUM, attacker.real_owner.netname);
			bprint (PRINT_MEDIUM, "'s tesla sentry\n");
		}
	}
};

void (entity targ, entity attacker) Obituary_Monster_Demon1_by_Sentry =
{
	if (teamplay
		&& (attacker.real_owner.team_no > 0)
		&& (targ.real_owner.team_no > 0)) {
		if (!Teammate (targ.real_owner.team_no, attacker.real_owner.team_no)) {
			Give_Frags_Out (attacker, targ, 1, 0, 2, 0, 0); //Sentry
			Give_Frags_Out (attacker.real_owner, targ, 1, 0, 1, 1, 0);

			bprint (PRINT_MEDIUM, targ.real_owner.netname);
			bprint (PRINT_MEDIUM, "'s demon, ");
			bprint (PRINT_MEDIUM, targ.netname);
			bprint (PRINT_MEDIUM, ", was pulped by ");
			bprint (PRINT_MEDIUM, attacker.real_owner.netname);
			bprint (PRINT_MEDIUM, "'s sentry gun\n");
		} else {
			Give_Frags_Out (attacker, targ, -1, 0, 2, 0, 0); //Sentry
			Give_Frags_Out (attacker.real_owner, targ, -1, 0, 1, 1, 0);

			bprint (PRINT_MEDIUM, targ.real_owner.netname);
			bprint (PRINT_MEDIUM, "'s friendly demon, ");
			bprint (PRINT_MEDIUM, targ.netname);
			bprint (PRINT_MEDIUM, ", was pulped by ");
			bprint (PRINT_MEDIUM, attacker.real_owner.netname);
			bprint (PRINT_MEDIUM, "'s sentry gun\n");
		}
	}
};

void (entity targ, entity attacker) Obituary_Monster_Demon1_by_Player =
{
	if (teamplay
		&& (attacker.team_no > 0)
		&& (self.real_owner.team_no > 0)) {
		if (Teammate (targ.real_owner.team_no, attacker.team_no))	{
			if (attacker == self.real_owner) {
				Give_Frags_Out (attacker, targ, -2, 0, 1, 1, 0);
				bprint (PRINT_MEDIUM, attacker.netname);
				bprint (PRINT_MEDIUM, " kills his own fiend!\n");
			} else {
				Give_Frags_Out (attacker, targ, -1, 0, 1, 1, 0);

				bprint (PRINT_MEDIUM, attacker.netname);
				bprint (PRINT_MEDIUM, " mows down the friendly demon ");
				bprint (PRINT_MEDIUM, targ.netname);
				bprint (PRINT_MEDIUM, " (");
				bprint (PRINT_MEDIUM, targ.real_owner.netname);
				bprint (PRINT_MEDIUM, ")\n");
			}
		} else {
			Give_Frags_Out (attacker, targ, 1, 0, 1, 1, 0);

			bprint (PRINT_MEDIUM, targ.real_owner.netname);
			bprint (PRINT_MEDIUM, "'s demon, ");
			bprint (PRINT_MEDIUM, targ.netname);
			bprint (PRINT_MEDIUM, ", was killed by ");
			bprint (PRINT_MEDIUM, attacker.netname);
			bprint (PRINT_MEDIUM, "\n");

			MonsterKill (attacker); // adds knife kills to warlock
		}
	}
};

void (entity targ, entity attacker) Obituary_Monster_Demon1_by_Army =
{
	custom_demon_name (attacker);
	GetRank (attacker);
	if (Teammate (targ.real_owner.team_no, attacker.real_owner.team_no)) {
		Give_Frags_Out (attacker, targ, -1, 0, 1, 1, 0);

		bprint (PRINT_MEDIUM, attacker.undercover_name);
		bprint (PRINT_MEDIUM, attacker.netname);
		bprint (PRINT_MEDIUM, " (");
		bprint (PRINT_MEDIUM, attacker.real_owner.netname);
		bprint (PRINT_MEDIUM, ") mows down the friendly demon ");
		bprint (PRINT_MEDIUM, targ.netname);
		bprint (PRINT_MEDIUM, " (");
		bprint (PRINT_MEDIUM, targ.real_owner.netname);
		bprint (PRINT_MEDIUM, ")\n");
	} else {
		Give_Frags_Out (attacker, targ, 1, 0, 1, 1, 0);

		bprint (PRINT_MEDIUM, targ.real_owner.netname);
		bprint (PRINT_MEDIUM, "'s demon, ");
		bprint (PRINT_MEDIUM, targ.netname);
		bprint (PRINT_MEDIUM, ", didn't have a prayer against ");
		bprint (PRINT_MEDIUM, attacker.undercover_name);
		bprint (PRINT_MEDIUM, attacker.netname);
		bprint (PRINT_MEDIUM, " (");
		bprint (PRINT_MEDIUM, attacker.real_owner.netname);
		bprint (PRINT_MEDIUM, ")\n");
	}
};

void (entity targ, entity attacker) Obituary_Monster_Demon1_by_Demon1 =
{
	custom_demon_name (attacker);
	if (Teammate (targ.real_owner.team_no, attacker.real_owner.team_no)) {
		Give_Frags_Out (attacker, targ, -1, 0, 1, 1, 0);

		bprint (PRINT_MEDIUM, attacker.netname);
		bprint (PRINT_MEDIUM, " (");
		bprint (PRINT_MEDIUM, attacker.real_owner.netname);
		bprint (PRINT_MEDIUM, ") eviscerates the friendly demon ");
		bprint (PRINT_MEDIUM, targ.netname);
		bprint (PRINT_MEDIUM, " (");
		bprint (PRINT_MEDIUM, targ.real_owner.netname);
		bprint (PRINT_MEDIUM, ")\n");
	} else {
		Give_Frags_Out (attacker, targ, 1, 0, 1, 1, 0);

		bprint (PRINT_MEDIUM, targ.real_owner.netname);
		bprint (PRINT_MEDIUM, "'s demon, ");
		bprint (PRINT_MEDIUM, targ.netname);
		bprint (PRINT_MEDIUM, ", realises too late that ");
		bprint (PRINT_MEDIUM, attacker.netname);
		bprint (PRINT_MEDIUM, " (");
		bprint (PRINT_MEDIUM, attacker.real_owner.netname);
		bprint (PRINT_MEDIUM, ") wasn't just trying to be friendly\n");
	}
};

void (entity targ, entity attacker) Obituary_Monster_Demon1_by_Shambler =
{
	custom_demon_name (attacker);
	if (Teammate (targ.real_owner.team_no, attacker.real_owner.team_no)) {
		Give_Frags_Out (attacker, targ, -1, 0, 1, 1, 0);

		bprint (PRINT_MEDIUM, attacker.netname);
		bprint (PRINT_MEDIUM, " (");
		bprint (PRINT_MEDIUM, attacker.real_owner.netname);
		bprint (PRINT_MEDIUM, ") annihilates the friendly demon ");
		bprint (PRINT_MEDIUM, targ.netname);
		bprint (PRINT_MEDIUM, " (");
		bprint (PRINT_MEDIUM, targ.real_owner.netname);
		bprint (PRINT_MEDIUM, ")\n");
	} else {
		Give_Frags_Out (attacker, targ, 1, 0, 1, 1, 0);

		bprint (PRINT_MEDIUM, targ.real_owner.netname);
		bprint (PRINT_MEDIUM, "'s demon, ");
		bprint (PRINT_MEDIUM, targ.netname);
		bprint (PRINT_MEDIUM, ", is given a firm farewell to the netherworld by ");
		bprint (PRINT_MEDIUM, attacker.netname);
		bprint (PRINT_MEDIUM, " (");
		bprint (PRINT_MEDIUM, attacker.real_owner.netname);
		bprint (PRINT_MEDIUM, ")\n");
	}
};

void (entity targ, entity attacker) Obituary_Monster_Demon1_by_Wizard =
{
	custom_demon_name (attacker);
	if (Teammate (targ.real_owner.team_no, attacker.real_owner.team_no)) {
		Give_Frags_Out (attacker, targ, -1, 0, 1, 1, 0);

		bprint (PRINT_MEDIUM, attacker.netname);
		bprint (PRINT_MEDIUM, " (");
		bprint (PRINT_MEDIUM, attacker.real_owner.netname);
		bprint (PRINT_MEDIUM, ") kills the friendly demon ");
		bprint (PRINT_MEDIUM, targ.netname);
		bprint (PRINT_MEDIUM, " (");
		bprint (PRINT_MEDIUM, targ.real_owner.netname);
		bprint (PRINT_MEDIUM, ")\n");
	} else {
		Give_Frags_Out (attacker, targ, 1, 0, 1, 1, 0);

		bprint (PRINT_MEDIUM, targ.real_owner.netname);
		bprint (PRINT_MEDIUM, "'s demon, ");
		bprint (PRINT_MEDIUM, targ.netname);
		bprint (PRINT_MEDIUM, ", is killed by the scrag ");
		bprint (PRINT_MEDIUM, attacker.netname);
		bprint (PRINT_MEDIUM, " (");
		bprint (PRINT_MEDIUM, attacker.real_owner.netname);
		bprint (PRINT_MEDIUM, ")\n");
	}
};

void (entity targ, entity attacker) Obituary_Monster_Army =
{
	custom_demon_name (targ); //CH
	GetRank (targ);

	if (attacker.classname == "building_tesla")
		Obituary_Monster_Army_by_Tesla (targ, attacker);
	else if (attacker.classname == "building_sentry")
		Obituary_Monster_Army_by_Sentry (targ, attacker);
	else if (attacker.classname == "player")
		Obituary_Monster_Army_by_Player (targ, attacker);
	else if (attacker.classname == "monster_shambler")
		Obituary_Monster_Army_by_Shambler (targ, attacker);
	else if (attacker.classname == "monster_demon1")
		Obituary_Monster_Army_by_Demon1 (targ, attacker);
	else if (attacker.classname == "monster_army")
		Obituary_Monster_Army_by_Army (targ, attacker);
	else if (attacker.classname == "monster_wizard")
		Obituary_Monster_Army_by_Wizard (targ, attacker);
	else
		Obituary_Monster_Misc (targ, attacker);
};

void (entity targ, entity attacker) Obituary_Monster_Army_by_Tesla =
{
	if (teamplay
		&& (attacker.real_owner.team_no > 0)
		&& (targ.real_owner.team_no > 0)) {
		if (!Teammate (targ.real_owner.team_no, attacker.real_owner.team_no)) {
			Give_Frags_Out (attacker, targ, 1, 0, 2, 0, 0); //Tesla
			Give_Frags_Out (attacker.real_owner, targ, 1, 0, 1, 1, 0);

			bprint (PRINT_MEDIUM, targ.real_owner.netname);
			bprint (PRINT_MEDIUM, "'s mercenary soldier, ");
			bprint (PRINT_MEDIUM, targ.undercover_name);
			bprint (PRINT_MEDIUM, targ.netname);
			bprint (PRINT_MEDIUM, ", was shocked to death by ");
			bprint (PRINT_MEDIUM, attacker.real_owner.netname);
			bprint (PRINT_MEDIUM, "'s tesla sentry\n");
		} else {
			Give_Frags_Out (attacker, targ, -1, 0, 2, 0, 0); //Tesla
			Give_Frags_Out (attacker.real_owner, targ, -1, 0, 1, 1, 0);

			bprint (PRINT_MEDIUM, targ.real_owner.netname);
			bprint (PRINT_MEDIUM, "'s friendly soldier, ");
			bprint (PRINT_MEDIUM, targ.undercover_name);
			bprint (PRINT_MEDIUM, targ.netname);
			bprint (PRINT_MEDIUM, ", was shocked to death by ");
			bprint (PRINT_MEDIUM, attacker.real_owner.netname);
			bprint (PRINT_MEDIUM, "'s tesla sentry\n");
		}
	}
};

void (entity targ, entity attacker) Obituary_Monster_Army_by_Sentry =
{
	if (teamplay
		&& (attacker.real_owner.team_no > 0)
		&& (targ.real_owner.team_no > 0)) {
		if (!Teammate (targ.real_owner.team_no, attacker.real_owner.team_no)) {
			Give_Frags_Out (attacker, targ, 1, 0, 2, 0, 0); //Sentry
			Give_Frags_Out (attacker.real_owner, targ, 1, 0, 1, 1, 0);

			bprint (PRINT_MEDIUM, targ.real_owner.netname);
			bprint (PRINT_MEDIUM, "'s mercenary soldier, ");
			bprint (PRINT_MEDIUM, targ.undercover_name);
			bprint (PRINT_MEDIUM, targ.netname);
			bprint (PRINT_MEDIUM, ", discovers ");
			bprint (PRINT_MEDIUM, attacker.real_owner.netname);
			bprint (PRINT_MEDIUM, "'s sentry isn't that easy to kill\n");
		} else {
			Give_Frags_Out (attacker, targ, -1, 0, 2, 0, 0); //Sentry
			Give_Frags_Out (attacker.real_owner, targ, -1, 0, 1, 1, 0);

			bprint (PRINT_MEDIUM, targ.real_owner.netname);
			bprint (PRINT_MEDIUM, "'s friendly soldier, ");
			bprint (PRINT_MEDIUM, targ.undercover_name);
			bprint (PRINT_MEDIUM, targ.netname);
			bprint (PRINT_MEDIUM, ", should have known better than to cross ");
			bprint (PRINT_MEDIUM, attacker.real_owner.netname);
			bprint (PRINT_MEDIUM, "'s sentry gun's line of fire\n");
		}
	}
};

void (entity targ, entity attacker) Obituary_Monster_Army_by_Player =
{
	if (teamplay
		&& (attacker.team_no > 0)
		&& (self.real_owner.team_no > 0)) {
		if (Teammate (targ.real_owner.team_no, attacker.team_no)) {
			if (attacker == self.real_owner) {
				Give_Frags_Out (attacker, targ, -2, 0, 1, 1, 0);

				bprint (PRINT_MEDIUM, attacker.netname);
				bprint (PRINT_MEDIUM, " kills his own soldier!\n");
			} else {
				Give_Frags_Out (attacker, targ, -1, 0, 1, 1, 0);

				bprint (PRINT_MEDIUM, attacker.netname);
				bprint (PRINT_MEDIUM, " mows down the friendly soldier ");
				bprint (PRINT_MEDIUM, targ.undercover_name);
				bprint (PRINT_MEDIUM, targ.netname);
				bprint (PRINT_MEDIUM, " (");
				bprint (PRINT_MEDIUM, targ.real_owner.netname);
				bprint (PRINT_MEDIUM, ")\n");
			}
		} else {
			Give_Frags_Out (attacker, targ, 1, 0, 1, 1, 0);

			bprint (PRINT_MEDIUM, targ.real_owner.netname);
			bprint (PRINT_MEDIUM, "'s mercenary soldier, ");
			bprint (PRINT_MEDIUM, targ.undercover_name);
			bprint (PRINT_MEDIUM, targ.netname);
			bprint (PRINT_MEDIUM, ", was killed by ");
			bprint (PRINT_MEDIUM, attacker.netname);
			bprint (PRINT_MEDIUM, "\n");
		}
	}
};

void (entity targ, entity attacker) Obituary_Monster_Army_by_Shambler =
{
	custom_demon_name (attacker);
	if (Teammate (targ.real_owner.team_no, attacker.real_owner.team_no)) {
		Give_Frags_Out (attacker, targ, -1, 0, 1, 1, 0);

		bprint (PRINT_MEDIUM, attacker.netname);
		bprint (PRINT_MEDIUM, " (");
		bprint (PRINT_MEDIUM, attacker.real_owner.netname);
		bprint (PRINT_MEDIUM, ") slaps the friendly soldier ");
		bprint (PRINT_MEDIUM, targ.undercover_name);
		bprint (PRINT_MEDIUM, targ.netname);
		bprint (PRINT_MEDIUM, " (");
		bprint (PRINT_MEDIUM, targ.real_owner.netname);
		bprint (PRINT_MEDIUM, ") into oblivion\n");
	} else {
		Give_Frags_Out (attacker, targ, 1, 0, 1, 1, 0);
		bprint (PRINT_MEDIUM, targ.real_owner.netname);
		bprint (PRINT_MEDIUM, "'s soldier, ");
		bprint (PRINT_MEDIUM, targ.undercover_name);
		bprint (PRINT_MEDIUM, targ.netname);
		bprint (PRINT_MEDIUM, ", is smacked down by ");
		bprint (PRINT_MEDIUM, attacker.netname);
		bprint (PRINT_MEDIUM, " (");
		bprint (PRINT_MEDIUM, attacker.real_owner.netname);
		bprint (PRINT_MEDIUM, ")\n");
	}
};

void (entity targ, entity attacker) Obituary_Monster_Army_by_Demon1 =
{
	custom_demon_name (attacker);
	if (Teammate (targ.real_owner.team_no, attacker.real_owner.team_no)) {
		Give_Frags_Out (attacker, targ, -1, 0, 1, 1, 0);

		bprint (PRINT_MEDIUM, attacker.netname);
		bprint (PRINT_MEDIUM, " (");
		bprint (PRINT_MEDIUM, attacker.real_owner.netname);
		bprint (PRINT_MEDIUM, ") disembowels the friendly soldier ");
		bprint (PRINT_MEDIUM, targ.undercover_name);
		bprint (PRINT_MEDIUM, targ.netname);
		bprint (PRINT_MEDIUM, " (");
		bprint (PRINT_MEDIUM, targ.real_owner.netname);
		bprint (PRINT_MEDIUM, ")\n");
	} else {
		Give_Frags_Out (attacker, targ, 1, 0, 1, 1, 0);

		bprint (PRINT_MEDIUM, targ.real_owner.netname);
		bprint (PRINT_MEDIUM, "'s soldier, ");
		bprint (PRINT_MEDIUM, targ.undercover_name);
		bprint (PRINT_MEDIUM, targ.netname);
		bprint (PRINT_MEDIUM, ", is now listed as KIA thanks to ");
		bprint (PRINT_MEDIUM, attacker.netname);
		bprint (PRINT_MEDIUM, " (");
		bprint (PRINT_MEDIUM, attacker.real_owner.netname);
		bprint (PRINT_MEDIUM, ")\n");
	}
};

void (entity targ, entity attacker) Obituary_Monster_Army_by_Army =
{
	custom_demon_name (attacker);
	GetRank (attacker);

	if (targ == attacker) { //- OfN - It *may* happen
		bprint (PRINT_MEDIUM, attacker.real_owner.netname);
		bprint (PRINT_MEDIUM, "'s soldier, ");
		bprint (PRINT_MEDIUM, attacker.undercover_name);
		bprint (PRINT_MEDIUM, attacker.netname);
		bprint (PRINT_MEDIUM, ", explodes with his own rockets!\n");
		return;
	}

	if (Teammate (targ.real_owner.team_no, attacker.real_owner.team_no)) {
		Give_Frags_Out (attacker, targ, -1, 0, 1, 1, 0);

		bprint (PRINT_MEDIUM, attacker.undercover_name);
		bprint (PRINT_MEDIUM, attacker.netname);
		bprint (PRINT_MEDIUM, " (");
		bprint (PRINT_MEDIUM, attacker.real_owner.netname);
		bprint (PRINT_MEDIUM, ") mows down comrade-in-arms ");
		bprint (PRINT_MEDIUM, targ.undercover_name);
		bprint (PRINT_MEDIUM, targ.netname);
		bprint (PRINT_MEDIUM, " (");
		bprint (PRINT_MEDIUM, targ.real_owner.netname);
		bprint (PRINT_MEDIUM, ")\n");
	} else {
		Give_Frags_Out (attacker, targ, 1, 0, 1, 1, 0);

		bprint (PRINT_MEDIUM, targ.real_owner.netname);
		bprint (PRINT_MEDIUM, "'s soldier, ");
		bprint (PRINT_MEDIUM, targ.undercover_name);
		bprint (PRINT_MEDIUM, targ.netname);
		bprint (PRINT_MEDIUM, ", takes a bullet in the chest from ");
		bprint (PRINT_MEDIUM, attacker.undercover_name);
		bprint (PRINT_MEDIUM, attacker.netname);
		bprint (PRINT_MEDIUM, " (");
		bprint (PRINT_MEDIUM, attacker.real_owner.netname);
		bprint (PRINT_MEDIUM, ")\n");
	}
};

void (entity targ, entity attacker) Obituary_Monster_Army_by_Wizard =
{
	custom_demon_name (attacker);
	if (Teammate (targ.real_owner.team_no, attacker.real_owner.team_no)) {
		Give_Frags_Out (attacker, targ, -1, 0, 1, 1, 0);

		bprint (PRINT_MEDIUM, "The scrag ");
		bprint (PRINT_MEDIUM, attacker.netname);
		bprint (PRINT_MEDIUM, " (");
		bprint (PRINT_MEDIUM, attacker.real_owner.netname);
		bprint (PRINT_MEDIUM, ") kills the friendly soldier ");
		bprint (PRINT_MEDIUM, targ.undercover_name);
		bprint (PRINT_MEDIUM, targ.netname);
		bprint (PRINT_MEDIUM, " (");
		bprint (PRINT_MEDIUM, targ.real_owner.netname);
		bprint (PRINT_MEDIUM, ")\n");
	} else {
		Give_Frags_Out (attacker, targ, 1, 0, 1, 1, 0);

		bprint (PRINT_MEDIUM, targ.real_owner.netname);
		bprint (PRINT_MEDIUM, "'s soldier, ");
		bprint (PRINT_MEDIUM, targ.undercover_name);
		bprint (PRINT_MEDIUM, targ.netname);
		bprint (PRINT_MEDIUM, ", is killed by the scrag ");
		bprint (PRINT_MEDIUM, attacker.netname);
		bprint (PRINT_MEDIUM, " (");
		bprint (PRINT_MEDIUM, attacker.real_owner.netname);
		bprint (PRINT_MEDIUM, ")\n");
	}
};

void (entity targ, entity attacker) Obituary_Monster_Shambler =
{
	custom_demon_name (targ); //CH

	if (attacker.classname == "building_tesla")
		Obituary_Monster_Shambler_by_Tesla (targ, attacker);
	else if (attacker.classname == "building_sentry")
		Obituary_Monster_Shambler_by_Sentry (targ, attacker);
	else if (attacker.classname == "player")
		Obituary_Monster_Shambler_by_Player (targ, attacker);
	else if (attacker.classname == "monster_demon1")
		Obituary_Monster_Shambler_by_Demon1 (targ, attacker);
	else if (attacker.classname == "monster_shambler")
		Obituary_Monster_Shambler_by_Shambler (targ, attacker);
	else if (attacker.classname == "monster_army")
		Obituary_Monster_Shambler_by_Army (targ, attacker);
	else if (attacker.classname == "monster_wizard")
		Obituary_Monster_Shambler_by_Wizard (targ, attacker);
	else
		Obituary_Monster_Misc (targ, attacker);
};

void (entity targ, entity attacker) Obituary_Monster_Shambler_by_Tesla =
{
	if (teamplay
		&& (attacker.real_owner.team_no > 0)
		&& (targ.real_owner.team_no > 0)) {
		if (!Teammate (targ.real_owner.team_no, attacker.real_owner.team_no)) {
			Give_Frags_Out (attacker, targ, 1, 0, 2, 0, 0); //Tesla
			Give_Frags_Out (attacker.real_owner, targ, 1, 0, 1, 1, 0);

			bprint (PRINT_MEDIUM, targ.real_owner.netname);
			bprint (PRINT_MEDIUM, "'s shambler, ");
			bprint (PRINT_MEDIUM, targ.netname);
			bprint (PRINT_MEDIUM, ", was given a shocking surprise by ");
			bprint (PRINT_MEDIUM, attacker.real_owner.netname);
			bprint (PRINT_MEDIUM, "'s tesla sentry\n");
		} else {
			Give_Frags_Out (attacker, targ, -1, 0, 2, 0, 0); //Tesla
			Give_Frags_Out (attacker.real_owner, targ, -1, 0, 1, 1, 0);
			bprint (PRINT_MEDIUM, targ.real_owner.netname);
			bprint (PRINT_MEDIUM, "'s friendly shambler, ");
			bprint (PRINT_MEDIUM, targ.netname);
			bprint (PRINT_MEDIUM, ", shouldn't play so close to ");
			bprint (PRINT_MEDIUM, attacker.real_owner.netname);
			bprint (PRINT_MEDIUM, "'s tesla sentry\n");
		}
	}
};

void (entity targ, entity attacker) Obituary_Monster_Shambler_by_Sentry =
{
	if (teamplay
		&& (attacker.real_owner.team_no > 0)
		&& (targ.real_owner.team_no > 0)) {
		if (!Teammate (targ.real_owner.team_no, attacker.real_owner.team_no)) {
			Give_Frags_Out (attacker, targ, 1, 0, 2, 0, 0); //Sentry
			Give_Frags_Out (attacker.real_owner, targ, 1, 0, 1, 1, 0);

			bprint (PRINT_MEDIUM, targ.real_owner.netname);
			bprint (PRINT_MEDIUM, "'s shambler, ");
			bprint (PRINT_MEDIUM, targ.netname);
			bprint (PRINT_MEDIUM, ", really needs to learn to dodge ");
			bprint (PRINT_MEDIUM, attacker.real_owner.netname);
			bprint (PRINT_MEDIUM, "'s sentry gun\n");
		} else {
			Give_Frags_Out (attacker, targ, -1, 0, 2, 0, 0); //Sentry
			Give_Frags_Out (attacker.real_owner, targ, -1, 0, 1, 1, 0);
			bprint (PRINT_MEDIUM, targ.real_owner.netname);
			bprint (PRINT_MEDIUM, "'s friendly shambler, ");
			bprint (PRINT_MEDIUM, targ.netname);
			bprint (PRINT_MEDIUM, ", shouldn't play so close to ");
			bprint (PRINT_MEDIUM, attacker.real_owner.netname);
			bprint (PRINT_MEDIUM, "'s sentry gun\n");
		}
	}
};

void (entity targ, entity attacker) Obituary_Monster_Shambler_by_Player =
{
	if (teamplay
		&& (attacker.team_no > 0)
		&& (self.real_owner.team_no > 0)) {
		if (Teammate (targ.real_owner.team_no, attacker.team_no)) {
			if (attacker == self.real_owner) {
				Give_Frags_Out (attacker, targ, -2, 0, 1, 1, 0);

				bprint (PRINT_MEDIUM, attacker.netname);
				bprint (PRINT_MEDIUM, " kills his own shambler!\n");
			} else {
				Give_Frags_Out (attacker, targ, -1, 0, 1, 1, 0);

				bprint (PRINT_MEDIUM, attacker.netname);
				bprint (PRINT_MEDIUM, " mows down the friendly shambler ");
				bprint (PRINT_MEDIUM, targ.netname);
				bprint (PRINT_MEDIUM, " (");
				bprint (PRINT_MEDIUM, targ.real_owner.netname);
				bprint (PRINT_MEDIUM, ")\n");
			}
		} else {
			Give_Frags_Out (attacker, targ, 1, 0, 1, 1, 0);

			bprint (PRINT_MEDIUM, targ.real_owner.netname);
			bprint (PRINT_MEDIUM, "'s shambler, ");
			bprint (PRINT_MEDIUM, targ.netname);
			bprint (PRINT_MEDIUM, ", was felled by ");
			bprint (PRINT_MEDIUM, attacker.netname);
			bprint (PRINT_MEDIUM, "\n");

			MonsterKill (attacker); // adds knife kills to warlock
		}
	}
};

void (entity targ, entity attacker) Obituary_Monster_Shambler_by_Demon1 =
{
	custom_demon_name (attacker);

	if (Teammate (targ.real_owner.team_no, attacker.real_owner.team_no)) {
		Give_Frags_Out (attacker, targ, -1, 0, 1, 1, 0);

		bprint (PRINT_MEDIUM, attacker.netname);
		bprint (PRINT_MEDIUM, " (");
		bprint (PRINT_MEDIUM, attacker.real_owner.netname);
		bprint (PRINT_MEDIUM, ") checks its aura after killing ");
		bprint (PRINT_MEDIUM, targ.netname);
		bprint (PRINT_MEDIUM, " (");
		bprint (PRINT_MEDIUM, targ.real_owner.netname);
		bprint (PRINT_MEDIUM, ")\n");
	} else {
		Give_Frags_Out (attacker, targ, 1, 0, 1, 1, 0);

		bprint (PRINT_MEDIUM, targ.real_owner.netname);
		bprint (PRINT_MEDIUM, "'s shambler, ");
		bprint (PRINT_MEDIUM, targ.netname);
		bprint (PRINT_MEDIUM, ", is torn apart by ");
		bprint (PRINT_MEDIUM, attacker.netname);
		bprint (PRINT_MEDIUM, " (");
		bprint (PRINT_MEDIUM, attacker.real_owner.netname);
		bprint (PRINT_MEDIUM, ")\n");
	}
};

void (entity targ, entity attacker) Obituary_Monster_Shambler_by_Shambler =
{
	custom_demon_name (attacker);

	if (Teammate (targ.real_owner.team_no, attacker.real_owner.team_no)) {
		Give_Frags_Out (attacker, targ, -1, 0, 1, 1, 0);

		bprint (PRINT_MEDIUM, attacker.netname);
		bprint (PRINT_MEDIUM, " (");
		bprint (PRINT_MEDIUM, attacker.real_owner.netname);
		bprint (PRINT_MEDIUM, ") electrifies the friendly shambler ");
		bprint (PRINT_MEDIUM, targ.netname);
		bprint (PRINT_MEDIUM, " (");
		bprint (PRINT_MEDIUM, targ.real_owner.netname);
		bprint (PRINT_MEDIUM, ")\n");
	} else {
		Give_Frags_Out (attacker, targ, 1, 0, 1, 1, 0);

		bprint (PRINT_MEDIUM, targ.real_owner.netname);
		bprint (PRINT_MEDIUM, "'s shambler, ");
		bprint (PRINT_MEDIUM, targ.netname);
		bprint (PRINT_MEDIUM, ", finds losing against shambler ");
		bprint (PRINT_MEDIUM, attacker.netname);
		bprint (PRINT_MEDIUM, " (");
		bprint (PRINT_MEDIUM, attacker.real_owner.netname);
		bprint (PRINT_MEDIUM, ") to be a fatal experience\n");
	}
};

void (entity targ, entity attacker) Obituary_Monster_Shambler_by_Army =
{
	custom_demon_name (attacker);
	GetRank (attacker);

	if (Teammate (targ.real_owner.team_no, attacker.real_owner.team_no)) {
		Give_Frags_Out (attacker, targ, -1, 0, 1, 1, 0);

		bprint (PRINT_MEDIUM, targ.netname);
		bprint (PRINT_MEDIUM, " (");
		bprint (PRINT_MEDIUM, targ.real_owner.netname);
		bprint (PRINT_MEDIUM, ") is caught in the crossfire from ");
		bprint (PRINT_MEDIUM, attacker.undercover_name);
		bprint (PRINT_MEDIUM, attacker.netname);
		bprint (PRINT_MEDIUM, " (");
		bprint (PRINT_MEDIUM, attacker.real_owner.netname);
		bprint (PRINT_MEDIUM, ")\n");
	} else {
		Give_Frags_Out (attacker, targ, 1, 0, 1, 1, 0);

		bprint (PRINT_MEDIUM, attacker.undercover_name);
		bprint (PRINT_MEDIUM, attacker.netname);
		bprint (PRINT_MEDIUM, " (");
		bprint (PRINT_MEDIUM, attacker.real_owner.netname);
		bprint (PRINT_MEDIUM, ") proves to ");
		bprint (PRINT_MEDIUM, targ.netname);
		bprint (PRINT_MEDIUM, " (");
		bprint (PRINT_MEDIUM, targ.real_owner.netname);
		bprint (PRINT_MEDIUM, ") that size doesn't matter\n");
	}
};

void (entity targ, entity attacker) Obituary_Monster_Shambler_by_Wizard =
{
	custom_demon_name (attacker);

	if (Teammate (targ.real_owner.team_no, attacker.real_owner.team_no)) {
		Give_Frags_Out (attacker, targ, -1, 0, 1, 1, 0);

		//bprint (PRINT_MEDIUM, attacker.undercover_name);
		bprint (PRINT_MEDIUM, "The scrag ");
		bprint (PRINT_MEDIUM, attacker.netname);
		bprint (PRINT_MEDIUM, " (");
		bprint (PRINT_MEDIUM, attacker.real_owner.netname);
		bprint (PRINT_MEDIUM, ") kills the friendly soldier ");
		bprint (PRINT_MEDIUM, targ.netname);
		bprint (PRINT_MEDIUM, " (");
		bprint (PRINT_MEDIUM, targ.real_owner.netname);
		bprint (PRINT_MEDIUM, ")\n");
	} else {
		Give_Frags_Out (attacker, targ, 1, 0, 1, 1, 0);

		bprint (PRINT_MEDIUM, targ.netname);
		bprint (PRINT_MEDIUM, " (");
		bprint (PRINT_MEDIUM, targ.real_owner.netname);
		bprint (PRINT_MEDIUM, ") had his army career truncated by the scrag ");
		//bprint (PRINT_MEDIUM, attacker.undercover_name);
		bprint (PRINT_MEDIUM, attacker.netname);
		bprint (PRINT_MEDIUM, " (");
		bprint (PRINT_MEDIUM, attacker.real_owner.netname);
		bprint (PRINT_MEDIUM, ")\n");
	}
};

void (entity targ, entity attacker) Obituary_Building =
{
	if (targ == attacker)
		Obituary_Building_by_Self (targ, attacker);
	else if (attacker.classname == "building_tesla")
		Obituary_Building_by_Tesla (targ, attacker);
	else if (attacker.classname == "teledeath")
		Obituary_Building_by_Teledeath (targ, attacker);
	else if (attacker.classname == "player")
		Obituary_Building_by_Player (targ, attacker);
	else if (attacker.classname == "monster_army")
		Obituary_Building_by_Army (targ, attacker);
};

void (entity targ, entity attacker) Obituary_Building_by_Tesla =
{
	local string deathstring;

	if (!Teammate (targ.real_owner.team_no, attacker.real_owner.team_no)
		&& (targ.classname == "building_sentrygun"
			|| targ.classname == "building_tesla")) {
		Give_Frags_Out (attacker, targ, 1, 0, 2, 0, 0); //Tesla
		Give_Frags_Out (attacker.real_owner, targ, 1, 0, 1, 1, 0);
	}

	if (targ.classname == "building_dispenser")
		deathstring = "'s dispenser was zapped by ";
	else if (targ.classname == "building_sentrygun")
		deathstring = "'s sentrygun was no match for ";
	else if (targ.classname == "building_camera")
		deathstring = "'s security camera was vaporized by ";
	else if (targ.classname == "building_sensor")
		deathstring = "'s motion sensor was obliterated by ";
	else if (targ.classname == "building_teleporter")
		deathstring = "'s teleporter pad was short circuted by ";
	else if (targ.classname == "building_tesla")
		deathstring = "'s tesla sentry lost the battle against ";
	else if (targ.classname == "building_sensor")
		deathstring = "'s motion sensor was fucked up by ";
	else if (targ.classname == "building_fieldgen")
		deathstring = "'s field generator was destroyed by ";
	else
		deathstring = "'s unknown building (BUG) ";

	bprint (PRINT_MEDIUM, targ.real_owner.netname);
	bprint (PRINT_MEDIUM, deathstring);
	bprint (PRINT_MEDIUM, attacker.real_owner.netname);
	bprint (PRINT_MEDIUM, "'s tesla sentry\n");
};

void (entity targ, entity attacker) Obituary_Building_by_Self =
{
	bprint (PRINT_MEDIUM, targ.real_owner.netname);
	bprint (PRINT_MEDIUM, "'s ");
	bprint (PRINT_MEDIUM, GetBuildingName (targ));
	bprint (PRINT_MEDIUM, " destroys itself.\n");
};

void (entity targ, entity attacker) Obituary_Building_by_Teledeath =
{
	bprint (PRINT_MEDIUM, targ.real_owner.netname);
	bprint (PRINT_MEDIUM, "'s ");
	bprint (PRINT_MEDIUM, GetBuildingName (targ));
	bprint (PRINT_MEDIUM, " was telefragged by ");
	bprint (PRINT_MEDIUM, attacker.owner.netname);
	bprint (PRINT_MEDIUM, "\n");
};

void (entity targ, entity attacker) Obituary_Building_by_Player =
{
	if (attacker == targ.real_owner) {
		bprint (PRINT_MEDIUM, targ.real_owner.netname);
		bprint (PRINT_MEDIUM, " destroys his ");
		bprint (PRINT_MEDIUM, GetBuildingName (targ));
		bprint (PRINT_MEDIUM, "\n");
		return;
	} else {
		bprint (PRINT_MEDIUM, targ.real_owner.netname);
		bprint (PRINT_MEDIUM, "'s ");
		bprint (PRINT_MEDIUM, GetBuildingName (targ));
		bprint (PRINT_MEDIUM, " was destroyed by ");
		bprint (PRINT_MEDIUM, attacker.netname);
		bprint (PRINT_MEDIUM, "\n");

		if (!Teammate (targ.real_owner.team_no, attacker.team_no)
			&& (targ.classname == "building_sentrygun"
				|| targ.classname == "building_tesla"))
			Give_Frags_Out (attacker, targ, 1, 0, 1, 1, 0);
	}
};

void (entity targ, entity attacker) Obituary_Building_by_Army =
{
	custom_demon_name (attacker);
	GetRank (attacker);

	bprint (PRINT_MEDIUM, targ.real_owner.netname);
	bprint (PRINT_MEDIUM, "'s ");
	bprint (PRINT_MEDIUM, GetBuildingName (targ));
	bprint (PRINT_MEDIUM, " was destroyed by ");
	bprint (PRINT_MEDIUM, attacker.undercover_name);
	bprint (PRINT_MEDIUM, attacker.netname);
	bprint (PRINT_MEDIUM, " (");
	bprint (PRINT_MEDIUM, attacker.real_owner.netname);
	bprint (PRINT_MEDIUM, ")\n");

	if (!Teammate (targ.real_owner.team_no, attacker.real_owner.team_no)
		&& (targ.classname == "building_sentrygun"
			|| targ.classname == "building_tesla"))
		Give_Frags_Out (attacker, targ, 1, 0, 1, 1, 0);
};

void (entity targ, entity attacker) Obituary_Monster_Misc =
{
	local string deathstring;

	if (attacker.classname == "explo_box")
		deathstring = " blew up\n";
	else if (attacker.solid == SOLID_BSP && attacker != world)
		deathstring = " was squished\n";
	else if (attacker.classname == "trap_shooter"
			 || attacker.classname == "trap_spikeshooter"
			 || attacker.classname == "trap_tf_spikeshooter"
			 || attacker.classname == "trap_tf_shooter") {
		if (attacker.deathtype)
			deathstring = attacker.deathtype;
		else if (attacker.spawnflags == SPAWNFLAG_LASER)
			deathstring = " had surgery from a laser\n";
		else if (attacker.spawnflags == SPAWNFLAG_TFROCKET)
			deathstring = " took a ride on a rocket\n";
		else if (attacker.spawnflags == SPAWNFLAG_TFGRENADE)
			deathstring = " tried to eat a wild pineapple\n";
		else if (attacker.spawnflags == SPAWNFLAG_TFFLAME)
			deathstring = " was burned alive\n";
		else if (attacker.spawnflags == SPAWNFLAG_SUPERSPIKE)
			deathstring = " was nailed to the ground\n";
		else
			deathstring = " was spiked\n";
	} else if (attacker.classname == "fireball")
		deathstring = " ate a lavaball\n";
	else if (attacker.classname == "teledeath")
		deathstring = " was telefragged by " + attacker.owner.netname + "\n";
	else
		deathstring = " dies\n";

	bprint (PRINT_HIGH, "The ");
	bprint (PRINT_HIGH, GetMonsterName (targ));
	bprint (PRINT_HIGH, " ");
	bprint (PRINT_HIGH, targ.netname);
	bprint (PRINT_HIGH, " (");
	bprint (PRINT_HIGH, targ.real_owner.netname);
	bprint (PRINT_HIGH, ")");
	bprint (PRINT_HIGH, deathstring);
};

