#include "defs.qh"
/*======================================================
	MEDIC.QC

	SB-1 Tech			15/12/2000
========================================================
Functions for the MEDIC class and associated weaponry                          
========================================================*/

// Functions within this file:

float (entity targ, entity attacker, float prob) BioInfect;
void () BioGrenadeTouch;
void () BioGrenadeExplode;

// Functions referenced from this file:

void() BioInfection_Decay;
void(entity p) TeamFortress_SetSpeed;

//=========================================================================
// Attacker attempts to infect targ.
float (entity targ, entity attacker, float prob) BioInfect =
{
	local entity BioInfection;
	local float r;
	
	// If they have medikit, don't infect them.
	if (targ.weapons_carried & WEAP_MEDIKIT)
		return FALSE;
	
	// Only allow one infection at once.
	if (targ.tfstate & TFSTATE_INFECTED)
		return FALSE;
	
	if (Teammate(targ.team_no, attacker.team_no) && targ != attacker)
		return FALSE;
	
	if (targ.invincible_finished > time)
		return FALSE;
	
	r = random();
	if (prob < r)
		return FALSE;
	
	r = random();
	//Melee armour stops infection 75% of the time
	if (targ.tf_items & NIT_GEL && r < 0.75)
		return FALSE;

    if (attacker == targ) // we infected ourselves! lol
    {
        sprint(attacker,PRINT_HIGH,"You infect yourself!\n");

        /*bprint(PRINT_HIGH,attacker.netname);
        bprint(PRINT_HIGH," infects himself!\n");*/
    }
    else
    {
        sprint(attacker,PRINT_HIGH,"Your grenade infects ");
        sprint(attacker,PRINT_HIGH,targ.netname);
        sprint(attacker,PRINT_HIGH,"!\n");
    }

	targ.tfstate |= TFSTATE_INFECTED;
	
	BioInfection = spawn ();
	BioInfection.classname = "timer";
	BioInfection.netname = "biotimer";
	BioInfection.owner = targ;
	BioInfection.nextthink = time + 2;
	BioInfection.think = BioInfection_Decay;
	BioInfection.enemy = attacker;
	
	targ.infection_team_no = attacker.team_no;
	
	return TRUE;
};

//=========================================================================
// Touch function for the bioinfection grenade.
void() BioGrenadeTouch =
{
	if (other == self.owner)
		return;		// don't explode on owner

	// Thrown grenades don't detonate when hitting an enemy

	sound (self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM);	// bounce sound
	if (self.velocity == '0 0 0')
		self.avelocity = '0 0 0';
};

//=========================================================================
// Biogrenade explosion. Does no damage...but infects...
void() BioGrenadeExplode =
{
	local entity dier; // He's the dier and he's dying
	
	dier = findradius(self.origin, BIO_GREN_RADIUS);
	while (dier)
	{
		if (dier.classname == "player")
			if (visible(dier))
				if (dier.takedamage)
				{
                    BioInfect(dier, self.owner, 1); // was 0.7
                }
		
		dier = dier.chain;
	}
	
	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_EXPLOSION);
	WriteCoord (MSG_MULTICAST, self.origin_x);
	WriteCoord (MSG_MULTICAST, self.origin_y);
	WriteCoord (MSG_MULTICAST, self.origin_z);
	multicast (self.origin, MULTICAST_PHS);
	dremove(self);
};

float(entity doc, entity patient, vector org) CureAdverseEffects =
{
	local entity te;
	
	// remove concussion from player
	// Try to find a concusstimer entity for this player
	te = find(NIL, classname, "timer");
	while (((te.owner != patient) || (te.think != ConcussionGrenadeTimer)) && (te))
	{
		te = find(te, classname, "timer");
	}

	if (te)
	{
		SpawnBlood(org, 20);
		patient.tfstate &= ~TFSTATE_CONCUSSIONED;
		if (doc == patient)
			sprint(doc, PRINT_HIGH, "The ground is behaving itself now.\n");
		else
		{
			sprint(patient, PRINT_HIGH, doc.netname, " heals you of your concussion\n");
			sprint(doc, PRINT_HIGH, "You heal ", patient.netname, "'s concussion\n");
		}
		// Give the medic a frag for doing it, only if it was caused by an enemy
		if (!Teammate(doc.team_no,te.team_no))
		{
			doc.real_frags = doc.real_frags + 1;
 			if (!(toggleflags & TFLAG_TEAMFRAGS))
				doc.frags = doc.real_frags;
		}
		TeamFortress_SetSpeed(patient);
		dremove(te);
		return TRUE;
	}

	// remove hallucination from player
	// Try to find a hallucination timer entity for this player
	if (patient.tfstate & TFSTATE_HALLUCINATING)
	{
		te = find(NIL, classname, "timer");
		while (((te.owner != patient) || (te.think != HallucinationTimer)) && (te))
		{
			te = find(te, classname, "timer");
		}

		if (te)
		{
			patient.tfstate &= ~TFSTATE_HALLUCINATING;
			SpawnBlood(org, 20);
			if (patient == doc)
				sprint(doc, PRINT_HIGH, "The visions have stopped.\n");
			else
			{
				sprint(patient, PRINT_HIGH, doc.netname, " heals you of your hallucinations\n");
				sprint(doc, PRINT_HIGH, "You halt ", patient.netname, "'s hallucinations\n");
			}
			// Give the medic a frag for doing it, only if it was caused by an enemy
			if (!Teammate(doc.team_no,te.team_no))
			{
				doc.real_frags = doc.real_frags + 1;
	 			if (!(toggleflags & TFLAG_TEAMFRAGS))
					doc.frags = doc.real_frags;
			}

			dremove(te);
			return TRUE;
		}
		else
		{
			RPrint("Warning: Error in Hallucination Timer logic.\n");
		}
	}

	// remove tranquilisation from player
	// Try to find a tranquilisation timer entity for this player
	if (patient.tfstate & TFSTATE_TRANQUILISED)
	{
		te = find(NIL, classname, "timer");
		while (((te.owner != patient) || (te.think != TranquiliserTimer)) && (te))
		{
			te = find(te, classname, "timer");
		}
		if (te)
		{
			patient.tfstate &= ~TFSTATE_TRANQUILISED;
			TeamFortress_SetSpeed(patient);
			
			SpawnBlood(org, 20);
			if (doc == patient)
				sprint(doc, PRINT_HIGH, "You feel more alert now.\n");
			else
			{
				sprint(patient, PRINT_HIGH, doc.netname, " heals you of your tranquilisation!\n");
				sprint(doc, PRINT_HIGH, "You heal ", patient.netname, "'s tranquilisation\n");
			}
			// Give the medic a frag for doing it, only if it was caused by an enemy
			if (!Teammate(doc.team_no,te.team_no))
			{
				doc.real_frags = doc.real_frags + 1;
	 			if (!(toggleflags & TFLAG_TEAMFRAGS))
					doc.frags = doc.real_frags;
			}

			dremove(te);
			return TRUE;
		}
		else
		{
			RPrint("Warning: Error in Tranquilisation Timer logic.\n");
		}
	}
	
	// check if the healed player is blinded
	/*if (patient.tfstate & TFSTATE_STASIS)
	{
		patient.tfstate &= ~TFSTATE_STASIS;
		TeamFortress_SetSpeed(patient);
		if (doc == patient)
			sprint(doc, PRINT_HIGH, "You can move freely again!\n");
		else
		{
			sprint(patient, PRINT_HIGH, doc.netname, " removes the effect of stasis on you!\n");
			sprint(doc, PRINT_HIGH, "You halt the effects of stasis on ", patient.netname, "!\n");
		}
//		patient.movetype = patient.stasismovetype;
		patient.gravity = patient.stasisGravity;
		patient.effects &= ~EF_BRIGHTFIELD;
		return 1;
	}*/

	// check if the healed player is infected
	if (patient.tfstate & TFSTATE_INFECTED)
	{
		local float healam;
		local entity te;
		
		healam = rint(patient.health / 2);
		// remove the infection
		patient.tfstate &= ~TFSTATE_INFECTED;
		
		te = find(NIL, netname, "biotimer");
		
		while (te)
		{
			if (te.classname == "timer")
				if (te.owner == patient)
					dremove(te);
			
			te = find(te, netname, "biotimer");
		}
		
		// some damage is caused (because of the use of leeches!)
		// remove half their remaining health
		deathmsg = DMSG_MEDIKIT;
		TF_T_Damage(patient, doc, doc, healam, 0, TF_TD_OTHER);

		SpawnBlood(org, 30);
		if (doc == patient)
			sprint(doc, PRINT_HIGH, "Your sores disappear.\n");
		else
		{
			sprint(patient, PRINT_HIGH, doc.netname, " cures your infection!\n");
			if (doc.classname == "player")
			{
				sprint(doc, PRINT_HIGH, "You have healed ");
				sprint(doc, PRINT_HIGH, patient.netname);
				sprint(doc, PRINT_HIGH, " of the infection.\n");	

				// Give the medic a frag for doing it, only if it was caused by an enemy
				if (!Teammate(patient.infection_team_no, doc.team_no))
				{
					doc.real_frags = doc.real_frags + 1;
		 			if (!(toggleflags & TFLAG_TEAMFRAGS))
						doc.frags = doc.real_frags;
				}
			}
		}

		return TRUE;
	}

	// put out the fire if they are burning
	if (patient.numflames > 0)
	{
		sound(patient, CHAN_WEAPON, "items/r_item1.wav", 1, ATTN_NORM);
		patient.numflames = 0;
		
		if (doc == patient)
			sprint (doc, PRINT_HIGH, "Your flames are extinguished!\n");
		else
		{
			sprint(patient, PRINT_HIGH, doc.netname, " stops you burning!\n");
			if (doc.classname == "player")
			{		
				sprint(doc, PRINT_MEDIUM, "You have put out ");
				sprint(doc, PRINT_MEDIUM, patient.netname);
				sprint(doc, PRINT_MEDIUM, "'s fire.\n");	
			}
		}
				
		return TRUE;
	}
};
