#include "defs.qh"
/*====================================================
	SCOUT.QC

	TeamFortress v2.5	 29/2/97
	Craig Hauser	 26/3/00
======================================================
Functions for the SCOUT class and associated weaponry                          
======================================================*/
// Functions outside this file

// Functions inside this file
// Concussion Grenade Functions
void() ConcussionGrenadeTouch;
void() ConcussionGrenadeExplode;
void() ConcussionGrenadeTimer;
// Scanner Functions
void(float scanrange,float inAuto) TeamFortress_Scan;
void(entity inflictor, entity attacker, float bounce, entity ignore) T_RadiusBounce;
entity(entity scanner, float scanrange, float enemies, float friends) T_RadiusScan;

//void(entity pl, string s1) CenterPrint;
void(entity pl, float fTime, string s1) StatusPrint;

//=========================================================================
// Touch Function for Flash Grenade
void() FlashGrenadeTouch =
{
	// If the Flash Grenade hits a player, it just bounces off
	sound (self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM);
	if (self.velocity == '0 0 0')
		self.avelocity = '0 0 0';
};

#ifdef NET_SERVER
	#define SMOOTH_FLASH 0.3
#else
    #define SMOOTH_FLASH 0.1
#endif

void() FlashTimer =
{
	local entity te;

	te = self.owner;

	if (te.has_disconnected) //WK Safety, now that we call this to clean up after death
		return;

	te.FlashTime = te.FlashTime - SMOOTH_FLASH;

	if (te.FlashTime < 4 && te.FlashTime != -1)
	{
		te.FlashTime = 0;
		stuffcmd(te, "v_cshift 0 0 0 0\n");
		return;
	}

	local string st;

	// Sequential III math proved useful!  GR
	st = ftos(-0.1 * (te.FlashTime - 5) * (te.FlashTime - 115));

	stuffcmd(te, "v_cshift 0 0 0 " + st + "\n");

	self.nextthink = time + SMOOTH_FLASH;
};

//=========================================================================
// Flash Grenade explode function, for when the PRIMETIME runs out
void() FlashGrenadeExplode =
{
	local entity te;
	local float loopc = 0;

	self.effects = self.effects | EF_BRIGHTLIGHT;


	sound (self, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NORM);

	// Find all people in area
	while (loopc < 32)
	{	
		te = checkclient();
		// Player?
		if (te && te.classname == "player")
		{
			makevectors(te.v_angle);
			// Damage player and explode
			// no, don't damage
			if (te.health > 0 && (normalize(self.origin - te.origin) * v_forward > -0.5) && visible(te))
			{
				local float ft = 60 - (vlen(self.origin - te.origin) * 6 / 50);

				if (te.FlashTime == 0)
				{
					// create flash timer
					newmis = spawn();
					newmis.classname = "timer";
					newmis.netname = "flashtimer";
					newmis.team_no = self.owner.team_no;
					newmis.owner = te;
					newmis.think = FlashTimer;
					newmis.nextthink = time + 0.1;
					newmis.heat = 1;
				}

				if (ft > 0)
					te.FlashTime = ft;

				stuffcmd (te, "v_cshift 255 255 255 245; bf\n"); // big white flash
			}
		}

		loopc++;
	}

#ifdef DEMO_STUFF
	// Remove any camera's locks on this missile
	if (self.enemy)
		CamProjectileLockOff();
#endif

	dremove(self);
};



//=========================================================================
// Touch function for a concussion grenade
void() ConcussionGrenadeTouch =
{
	// concussion grenades bounce off other players now

	sound (self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM);	// bounce sound
	if (self.velocity == '0 0 0')
		self.avelocity = '0 0 0';
};

//=========================================================================
// Concussion grenade explosion function
void() ConcussionGrenadeExplode =
{	
	T_RadiusBounce (self, self.owner, 240, NIL);

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
	dremove(self);
};

//=========================================================================
// Concussion grenade timer to remove idlescale
void() ConcussionGrenadeTimer =
{
	if (self.owner.invincible_finished > time)
	{
		sprint(self.owner, PRINT_HIGH, "The power heals your concussion\n");
		stuffcmd(self.owner, "v_idlescale 0\n");
		self.owner.mangle = '0 0 0';
		self.owner.tfstate &= ~TFSTATE_CONCUSSIONED;
		dremove(self);
		return;
	}


#ifdef GR_CONCUSS_BUBBLETIME
	if (self.has_tesla < time)
	{
		newmis = spawn();
		setmodel (newmis, "progs/s_bubble.spr");
		setorigin (newmis, self.owner.origin);
		newmis.movetype = MOVETYPE_NOCLIP;
		newmis.solid = SOLID_NOT;
		newmis.velocity = '0 0 15';
		newmis.nextthink = time + 0.5;
		newmis.think = bubble_bob;
		newmis.touch = bubble_remove;
		newmis.classname = "bubble";
		newmis.frame = 0;
		newmis.cnt = 0;
		setsize(newmis, '-8 -8 -8', '8 8 8');

		self.has_tesla += GR_CONCUSS_BUBBLETIME;
	}
#endif

	self.health = self.health - GR_CONCUSS_DEC;
	
	// medic recovers twice as fast
	if (self.owner.weapons_carried & WEAP_MEDIKIT) //WK
		self.health = self.health - GR_CONCUSS_DEC;
	if (self.owner.cutf_items & CUTF_STEALTH)
		self.health = self.health - GR_CONCUSS_DEC;
	if (self.owner.cutf_items & CUTF_GYMNAST)
		self.health = self.health - GR_CONCUSS_DEC;

	if (self.health < 0)
		self.health = 0;

	if (self.health == 0)
	{
		sprint (self.owner, PRINT_HIGH, "Your head better now\n");
#ifdef OLD_CONC_GRENADE
		stuffcmd (self.owner, "v_idlescale 0\n");
#endif
		self.owner.mangle = '0 0 0';
		self.owner.tfstate &= ~TFSTATE_CONCUSSIONED;
		dremove(self);
		return;
	}

	self.nextthink = time + GR_CONCUSS_TIME;

#ifdef OLD_CONC_GRENADE
	stuffcmd(self.owner, "v_idlescale " + ftos (self.health * GR_CONCUSS_IDLE) + "\n");
#else	

	if (self.has_camera < time)
	{
		self.owner.mangle = '0 0 0';

#ifdef GR_CONCUSS_SETANGLE	
		msg_entity = self.owner;
		WriteByte (MSG_ONE, SVC_SETANGLE);
		WriteAngleV (MSG_ONE, self.owner.v_angle);
#endif

		self.has_camera = time + GR_CONCUSS_FIXTIME;
	}

	local float r = random();
	local float amount = self.health;

	if (amount > GR_CONCUSS_MAX)
		amount = GR_CONCUSS_MAX;

	amount *= (0.8 + random() * 0.2);

	local float x = random() * amount;
	local float y = amount - x;

	if (random() < 0.5)
		self.owner.mangle_x += x * GR_CONCUSS_X;
	else
		self.owner.mangle_x -= x * GR_CONCUSS_X;

	if (random() < 0.5)
		self.owner.mangle_y += y * GR_CONCUSS_Y;
	else
		self.owner.mangle_y -= y * GR_CONCUSS_Y;


	if (self.owner.mangle_x < -60)
		self.owner.mangle_x = -60;
	if (self.owner.mangle_x > 60)
		self.owner.mangle_x = 60;
	if (self.owner.mangle_y > 120)
		self.owner.mangle_y = 120;
	if (self.owner.mangle_y < -120)
		self.owner.mangle_y = -120;
		

	if (self.owner.waterlevel || (self.owner.flags & FL_ONGROUND))
	{
		local float vel = vlen (self.owner.velocity);

		x = random() * amount;
		y = amount - x;

		if (random() < 0.5)
			self.owner.velocity_x += x * GR_CONCUSS_KICK * vel;
		else
			self.owner.velocity_x -= x * GR_CONCUSS_KICK * vel;

		if (random() < 0.5)
			self.owner.velocity_y += y * GR_CONCUSS_KICK * vel;
		else
			self.owner.velocity_y -= y * GR_CONCUSS_KICK * vel;
	}

	//sprint (self.owner, PRINT_HIGH, "mangle: " + vtos (self.owner.mangle) + "\n");

#endif
};

//=========================================================================
// Handles the scanner function for Scouts
void(float scanrange,float inAuto) TeamFortress_Scan = 
{
	local string power;
	local entity list = NIL;
	local float scen, scfr;
	local vector lightningvec;

	// added in for the direction scanner code
	local float enemy_detected;
	local float any_detected;


	// prevent scan impulse from triggering anything else
	self.impulse = 0;
	self.last_impulse = 0;

	if (self.classname == "player")
	{
		if (!(self.tf_items & NIT_SCANNER))
			return;

		// If Impulse is TF_SCAN_ENEMY, toggle Scanning for Enemies
		if (scanrange == TF_SCAN_ENEMY)
		{
			if (self.tf_items_flags & NIT_SCANNER_ENEMY)
			{
				sprint (self, PRINT_HIGH, "Enemy Scanning disabled.\n");
				self.tf_items_flags = self.tf_items_flags & ~NIT_SCANNER_ENEMY;
				return;
			}
			sprint (self, PRINT_HIGH, "Enemy Scanning enabled.\n");
			self.tf_items_flags = self.tf_items_flags | NIT_SCANNER_ENEMY;
			return;
		}

		// If Impulse is TF_SCAN_FRIENDLY, toggle Scanning for Friendlies
		if (scanrange == TF_SCAN_FRIENDLY)
		{
			if (self.tf_items_flags & NIT_SCANNER_FRIENDLY)
			{
				sprint (self, PRINT_HIGH, "Friendly Scanning disabled.\n");
				self.tf_items_flags = self.tf_items_flags & ~NIT_SCANNER_FRIENDLY;
				return;
			}
			sprint (self, PRINT_HIGH, "Friendly Scanning enabled.\n");
			self.tf_items_flags = self.tf_items_flags | NIT_SCANNER_FRIENDLY;
			return;
		}

		// If the user doesn't have as many cells as he/she specified, just
		// use as many as they've got.

/*		local float scancost;

		scancost = ceil(scanrange / 20);

		if (scancost > self.ammo_cells)
		{
			scanrange = self.ammo_cells * 20;
			scancost = self.ammo_cells;
		}

		if (scanrange <= 0)
		{
			sprint(self, PRINT_HIGH, "No cells.\n");
			return;
		}
*/
		if (scanrange > NIT_SCANNER_MAXCELL)
			scanrange = NIT_SCANNER_MAXCELL;

		scen = 0;
		scfr = 0;
		// Set the Scanner flags
		if (self.tf_items_flags & NIT_SCANNER_ENEMY)
			scen = 1;
		if (self.tf_items_flags & NIT_SCANNER_FRIENDLY)
			scfr = 1;

		// If no entity type is enabled, don't scan
		if ((scen == 0) && (scfr == 0))
		{
			sprint(self, PRINT_HIGH, "All scanner functions are disabled.\nEnable with 'scane' or 'scanf'.\n");
			return;
		}

		// Use up cells to power the scanner
		// additions:
		// altered this so scanner could be more easily tested
//WK		self.ammo_cells = self.ammo_cells - scancost;
		scanrange = scanrange * NIT_SCANNER_POWER;

		if (!inAuto) { //WK Only sprint() if not autoscanner
			sprint (self, PRINT_HIGH, "Range: ");
			power = ftos(ceil(scanrange));
			sprint (self, PRINT_HIGH, power);
			sprint (self, PRINT_HIGH, ". Scanning...\n");
		}

		// Get the list of entities the scanner finds
		list = T_RadiusScan(self, scanrange, scen, scfr);
	}
	// Base Defence scanning code here

	// Reset the entity counts
	scen = 0;
	scfr = 0;

	// the vectors v_forward and v_right are required to 
	// 'triangulate' the enemies position
	makevectors(self.v_angle);

	// Walk the list
	// For now, just count the entities.
	// In the future, we'll display bearings :)
	// additions: the future is now!
	while (list)
	{
	if (list != self)
	{
		// sets the enemy_detected flag to TRUE if not on your team, FALSE if so
		any_detected = TRUE; // this flag is set to false if bogie is moving
							 // too slow to be detected (and velocity checking is on)

		if (vlen(list.origin - self.origin) <= scanrange) //CH Secondary check NEEDED!!!
		{
		// If this scanner is a motion detector, don't record
		// object that don't have the required velocity to be detected.
		if (self.tf_items_flags & NIT_SCANNER_MOVEMENT)
		{
			if (vlen(list.velocity) > NIT_SCANNER_MIN_MOVEMENT)
			{
				if (list.classname == "monster_demon1" && list.health > 0) //Because they dont have teams
				{
					if (Teammate(list.real_owner.team_no,self.team_no))
					{
						scfr = scfr + 1;
						enemy_detected = FALSE;
					}
					else
					{
						scen = scen + 1;
						enemy_detected = TRUE;
					}
				}
				else if (list.classname == "monster_army" && list.health > 0) //Because they dont have teams
				{
					if (Teammate(list.real_owner.team_no,self.team_no))
					{
						scfr = scfr + 1;
						enemy_detected = FALSE;
					}
					else
					{
						scen = scen + 1;
						enemy_detected = TRUE;
					}
				}
				else if (list.classname == "monster_shambler" && list.health > 0) //Because they dont have teams
				{
					if (Teammate(list.real_owner.team_no,self.team_no))
					{
						scfr = scfr + 1;
						enemy_detected = FALSE;
					}
					else
					{
						scen = scen + 1;
						enemy_detected = TRUE;
					}
				}
   				//- OfN -
                else if (list.classname == "monster_wizard" && list.health > 0) //Because they dont have teams
				{
					if (Teammate(list.real_owner.team_no,self.team_no))
					{
						scfr = scfr + 1;
						enemy_detected = FALSE;
					}
					else
					{
						scen = scen + 1;
						enemy_detected = TRUE;
					}
				}

				else if (list.classname == "item_tfgoal" && list.owned_by > 0 && list.team_no > 0 && self.team_no > 0) //Because they use owned_by
				{
					if (list.owned_by == self.team_no && list.team_no != self.team_no)
					{
						scfr = scfr + 1;
						enemy_detected = FALSE;
					}
					else if (list.owned_by == self.team_no && list.team_no == self.team_no)
					{
						scfr = scfr + 1;
						enemy_detected = FALSE;
					}
					else if (list.owned_by != self.team_no && list.team_no == self.team_no)
					{
						scen = scen + 1;
						enemy_detected = TRUE;
					}
					else
						any_detected = FALSE;
				}
				else if ((list.classname == "player" || list.classname == "building_sentrygun" || list.classname == "building_tesla" || list.classname == "building_teleporter") && list.health > 0 && !(list.cutf_items & CUTF_JAMMER))
				{
					if (Teammate(list.team_no, self.team_no))
					{
						scfr = scfr + 1;
						enemy_detected = FALSE;
					}
					else
					{
						scen = scen + 1;
						enemy_detected = TRUE;
					}
				}
				else
				{
					any_detected = FALSE;
				}
			}
			else
			{
				any_detected = FALSE;
			}
		}
		else
		{
				if (list.classname == "monster_demon1" && list.health > 0) //Because they dont have teams
				{
					if (Teammate(list.real_owner.team_no,self.team_no))
					{
						scfr = scfr + 1;
						enemy_detected = FALSE;
					}
					else
					{
						scen = scen + 1;
						enemy_detected = TRUE;
					}
				}
				if (list.classname == "monster_army" && list.health > 0) //Because they dont have teams
				{
					if (Teammate(list.real_owner.team_no, self.team_no))
					{
						scfr = scfr + 1;
						enemy_detected = FALSE;
					}
					else
					{
						scen = scen + 1;
						enemy_detected = TRUE;
					}
				}
				if (list.classname == "monster_shambler" && list.health > 0) //Because they dont have teams
				{
					if (Teammate(list.real_owner.team_no, self.team_no))
					{
						scfr = scfr + 1;
						enemy_detected = FALSE;
					}
					else
					{
						scen = scen + 1;
						enemy_detected = TRUE;
					}
				}
                //- OfN -
                if (list.classname == "monster_wizard" && list.health > 0) //Because they dont have teams
				{
					if (Teammate(list.real_owner.team_no, self.team_no))
					{
						scfr = scfr + 1;
						enemy_detected = FALSE;
					}
					else
					{
						scen = scen + 1;
						enemy_detected = TRUE;
					}
				}
				else if (list.classname == "item_tfgoal" && list.owned_by > 0 && list.team_no > 0 && self.team_no > 0) //Because they use owned_by
				{
					if (list.owned_by == self.team_no && list.team_no != self.team_no)
					{
						scfr = scfr + 1;
						enemy_detected = FALSE;
					}
					else if (list.owned_by == self.team_no && list.team_no == self.team_no)
					{
						scfr = scfr + 1;
						enemy_detected = FALSE;
					}
					else if (list.owned_by != self.team_no && list.team_no == self.team_no)
					{
						scen = scen + 1;
						enemy_detected = TRUE;
					}
					else
						any_detected = FALSE;
				}
				else if ((list.classname == "player" || list.classname == "building_sentrygun" || list.classname == "building_tesla" || list.classname == "building_teleporter") && list.health > 0 && !(list.cutf_items & CUTF_JAMMER))
				{
					if (Teammate(list.team_no, self.team_no))
					{
						scfr = scfr + 1;
						enemy_detected = FALSE;
					}
					else
					{
						scen = scen + 1;
						enemy_detected = TRUE;
					}
				}
				else
				{
					any_detected = FALSE;
				}
		}
		}
		else
		{
			any_detected = FALSE;
		}

		// this displays the direction of the detected player
		// using the cosine rule to find the angle   
		//  cos theta = A.B divided by |A||B|
		// it should return a value between 1 and -1
		if (any_detected)
		{
			// Get the unit vector
			lightningvec = normalize(list.origin - self.origin);
			lightningvec = lightningvec * (vlen(list.origin - self.origin) / 5);
			lightningvec = lightningvec + self.origin;

			// Create the Lightning 
			msg_entity = self;
			WriteByte (MSG_ONE, SVC_TEMPENTITY);
			WriteByte (MSG_ONE, TE_LIGHTNING1);
			WriteEntity (MSG_ONE, self);
			WriteCoord (MSG_ONE, self.origin_x);
			WriteCoord (MSG_ONE, self.origin_y);
			WriteCoord (MSG_ONE, self.origin_z + 8);
			WriteCoord (MSG_ONE, lightningvec_x);
			WriteCoord (MSG_ONE, lightningvec_y);
			WriteCoord (MSG_ONE, lightningvec_z + 8);

			self.scaned = list; //CH for the sbar
			if (!inAuto)
			{
				self.StatusRefreshTime = time + 0.2;
				self.StatusBarScreen = 5;
			}
		} // end if(any_detected)
	}
		list = list.linked_list;
	}

	// Display the counts
	// For Base Defences, it will display the counts to all team members
	if ((scen == 0) && (scfr == 0) && (!inAuto))
	{
		sprint (self, PRINT_HIGH, "No blips.\n");
		return;
	}

	// Update ammo levels
	//W_SetCurrentAmmo ();

	return;
};

//=========================================================================
// Acts just like T_RadiusDamage, but doesn't damage things, just pushes them away
// from the explosion at a speed relative to the distance from the explosion's origin.
void(entity inflictor, entity attacker, float bounce, entity ignore) T_RadiusBounce =
{
	local	float 	points;
	local	entity	head, te;
	local	vector	org;

	head = findradius(inflictor.origin, bounce+40);
	
	while (head)
	{
		if (head != ignore)
		{
			if (head.takedamage && head.classname != "monster_shambler")
			{
				org = head.origin + (head.mins + head.maxs)*0.5;
				points = 0.5*vlen (org - inflictor.origin);
				if (points < 0)
					points = 0;
				points = bounce - points;
				if (head.cutf_items & CUTF_GYMNAST)
					points = points * 2;

				if (!IsBuilding(head) && points > 0)
				{
					// Bounce!!
#ifdef	NEW_CONCUSS_BOUNCE
					head.velocity += normalize (org - inflictor.origin) * points * 8;
#else
					head.velocity = org - inflictor.origin;
					head.velocity *= points / 20;
#endif

					if (head.classname != "player")
					{
						if(head.flags & FL_ONGROUND)
							head.flags = head.flags - FL_ONGROUND;
					}
					else
					{
						//WK Add cheat immunity since they fly
						makeImmune(head,time+3);

						// Concuss 'em!!
						// If they are already concussed, set the concussion back up
						// Try to find a concusstimer entity for this player

						head.tfstate |= TFSTATE_CONCUSSIONED;

						te = find(NIL, classname, "timer");
						while (((te.owner != head) || (te.think != ConcussionGrenadeTimer)) && (te))
							te = find(te, classname, "timer");
						if (te)
						{
							te.health += GR_CONCUSS_AMOUNT;
#ifdef OLD_CONC_GRENADE
							stuffcmd(head, "v_idlescale " +
									ftos (te.health * GR_CONCUSS_IDLE) + "\n");
#endif
							te.nextthink = time + GR_CONCUSS_TIME;
						}
						else
						{
#ifdef OLD_CONC_GRENADE
							stuffcmd(head,"v_idlescale " + 
									ftos (GR_CONCUSS_AMOUNT * GR_CONCUSS_IDLE)+ "\n");
#endif
							stuffcmd(head,"bf\n");
							// Create a timer entity
							te = spawn();
							te.nextthink = time + GR_CONCUSS_TIME;
							te.think = ConcussionGrenadeTimer;
							te.team_no = attacker.team_no;
							te.classname = "timer";
							te.owner = head;
							te.health += GR_CONCUSS_AMOUNT;
							te.has_tesla = time + 0.1;
						}
					}
				}
			}
		}
		head = head.chain;
	}
};
//CH checks a player and returns True of False
float(entity scan, entity targ, float enemies, float friends) Scanner_Check_Player =
{
		if (targ.playerclass == PC_UNDEFINED) {
			return FALSE;
		}
		else if (targ.done_custom & CUSTOM_BUILDING) {
			return FALSE;
		}
		else if (targ.health <= 0) {
			return FALSE;
		}
		else if (targ.has_disconnected) {
			return FALSE;
		}
		else if (targ == scan) {
			return FALSE;
		}
		else if (targ.flags & FL_NOTARGET) {
			return FALSE;
		}
		else if (targ.cutf_items & CUTF_JAMMER)
			return FALSE;
//CH ALL NEW CHECKS ABOVE THIS LINE
		if (teamplay)
		{
			if ( friends &&  Teammate(targ.team_no,scan.team_no) )
				return TRUE;
			if ( enemies && !Teammate(targ.team_no,scan.team_no) )
				return TRUE;
		}
		else
			return TRUE;
	return FALSE;
};
//=========================================================================
// Returns a list of players within a radius around the origin, like findradius,
// except that some parsing of the list can be done based on the parameters passed in.
// Make sure you check that the return value is not NULL b4 using it.
entity(entity scanner, float scanrange, float enemies, float friends) T_RadiusScan =
{
	local entity head;
	local entity list_head;
	local entity list;
	local float gotatarget;
	list_head = NIL;
	list = NIL;

	head = findradius(scanner.origin, scanrange+40);

	while (head)
	{
		gotatarget = 0;
		if (head != scanner && (friends || enemies))	// Don't pick up the entity that's scanning
		{
			if (head.takedamage) //item_tfgoal does not take dammage
			{
				if (head.classname == "player")
				{
					gotatarget = Scanner_Check_Player(scanner, head, enemies, friends);
				}
				else if ((head.classname == "building_tesla" || head.classname == "building_sentrygun" || head.classname == "building_teleporter") && (head.health > 0)) //CH uses team_no :)
				{
					if (teamplay)
					{
						if ( friends &&  Teammate(head.team_no, scanner.team_no) )
							gotatarget = 1;
						if ( enemies && !Teammate(head.team_no, scanner.team_no) )
							gotatarget = 1;
					}
					else
						gotatarget = 1;
				}
				else if ((head.classname == "monster_demon1") && head.health > 0) //CH demons trace back to real_owner
				{
					if (teamplay)
					{
						if ( friends &&  Teammate(head.real_owner.team_no, scanner.team_no) )
							gotatarget = 1;
						if ( enemies && !Teammate(head.real_owner.team_no, scanner.team_no) )
							gotatarget = 1;
					}
					else
						gotatarget = 1;
				}
				else if ((head.classname == "monster_army") && head.health > 0) //CH demons trace back to real_owner
				{
					if (teamplay)
					{
						if ( friends &&  Teammate(head.real_owner.team_no, scanner.team_no) )
							gotatarget = 1;
						if ( enemies && !Teammate(head.real_owner.team_no, scanner.team_no) )
							gotatarget = 1;
					}
					else
						gotatarget = 1;
				}
				else if ((head.classname == "monster_shambler") && head.health > 0) //CH demons trace back to real_owner
				{
					if (teamplay)
					{
						if ( friends &&  Teammate(head.real_owner.team_no, scanner.team_no) )
							gotatarget = 1;
						if ( enemies && !Teammate(head.real_owner.team_no, scanner.team_no) )
							gotatarget = 1;
					}
					else
						gotatarget = 1;
				}
                //- OfN -
                else if ((head.classname == "monster_wizard") && head.health > 0) //CH demons trace back to real_owner
				{
					if (teamplay)
					{
						if ( friends &&  Teammate(head.real_owner.team_no, scanner.team_no) )
							gotatarget = 1;
						if ( enemies && !Teammate(head.real_owner.team_no, scanner.team_no) )
							gotatarget = 1;
					}
					else
						gotatarget = 1;
				}
			}
			else if (head.classname == "item_tfgoal") //CH flags used owned_by for what team it is
			{
				if (teamplay)
				{
					if ( friends && (head.team_no > 0) && (head.owned_by > 0) && (scanner.team_no > 0) && (head.team_no == scanner.team_no) && (head.owned_by == scanner.team_no) )
						gotatarget = 1;
					if ( friends && (head.team_no > 0) && (head.owned_by > 0) && (scanner.team_no > 0) && (head.team_no != scanner.team_no) && (head.owned_by == scanner.team_no) )
						gotatarget = 1;
					if ( enemies && (head.team_no > 0) && (head.owned_by > 0) && (scanner.team_no > 0) && (head.team_no == scanner.team_no) && (head.owned_by != scanner.team_no) )
						gotatarget = 1;
				}
				else
					gotatarget = 1;
			}
		}

		// Add this entity to the linked list if it matches the target criteria
		if (gotatarget)
		{
			if (list)
			{
				list.linked_list = head;
				list = list.linked_list;
			}
			else
			{
				list_head = head;
				list = head;
			}
		}

		head = head.chain;
	}

	return list_head;
};

//=========================================================================
// Caltrop Grenade explosion

#define GR_TYPE_CALTROP_NO 5

void (vector org, entity shooter) CreateCaltrop;
void() CaltropTouch;

void() CaltropGrenadeExplode =
{
	local float i;
	
/*	deathmsg = DMSG_GREN_CALTROP;
	T_RadiusDamage (self, self.owner, 50, NIL);
	
	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_EXPLOSION);
	WriteCoord (MSG_MULTICAST, self.origin_x);
	WriteCoord (MSG_MULTICAST, self.origin_y);
	WriteCoord (MSG_MULTICAST, self.origin_z);
	multicast (self.origin, MULTICAST_PHS);
	
	self.solid = SOLID_NOT;
	*/
	// Very well admiral. Engage the rebels.
	i = 0;
	while (i < GR_TYPE_CALTROP_NO)
	{
		CreateCaltrop(self.origin + '0 0 -1',self.owner);
		i = i + 1;
	}
	
	#ifdef DEMO_STUFF
		// Remove any camera's locks on this missile
		if (self.enemy)
			CamProjectileLockOff();
	#endif
	
	//BecomeExplosion();
	dremove(self);
};

void (vector org, entity shooter) CreateCaltrop =
{
	local float xdir,ydir,zdir;

	xdir = 80 * random() - 40;
	ydir = 80 * random() - 40;
	zdir = 15 + 15 * random();

	newmis = spawn ();
	newmis.owner = shooter;
	newmis.movetype = MOVETYPE_BOUNCE;
	newmis.solid = SOLID_TRIGGER;
    //newmis.solid = SOLID_BBOX;

	newmis.classname = "caltrop";
	newmis.weapon = DMSG_CALTROP;

	newmis.touch = CaltropTouch;
	newmis.think = SUB_Remove;

	newmis.nextthink = time + 14 + random()*6; // was 7+random()
	newmis.heat = time + 2; // The caltrop doesn't activate for 2 seconds
	
	newmis.velocity_x = xdir * 2;
	newmis.velocity_y = ydir * 2;
	newmis.velocity_z = zdir * 15;

	newmis.avelocity = '500 500 500';

	setmodel (newmis, "progs/caltrop.mdl");
	setsize (newmis, '-10 -10 -9', '0 0 0');
    //setsize (newmis, '-5 -5 -4', '5 5 5');

	setorigin (newmis, org);
};

void() CaltropTouch =
{
	if (self.velocity == '0 0 0')
    {
        self.avelocity = '0 0 0';
		self.angles = '0 0 0';
    }
	
	if (self.heat > time)
		return;
	
	if (other.takedamage && other.classname == "player")
	{
		if (Teammate(self.owner.team_no, other.team_no) && other != self.owner)
			return;
	
		//if (other.classname == "player")
	
		
        if (self.velocity == '0 0 0') // supposedly on the ground..
        {
			sprint(other, PRINT_HIGH, "Ouch! Ouch! Caltrops!\n");
            other.leg_damage = other.leg_damage + 2;
          	TeamFortress_SetSpeed(other);
            deathmsg = DMSG_CALTROP;
    		TF_T_Damage(other, self, self.owner, 16, 0, TF_TD_OTHER);
        }
        else // if its moving...
        {
			sprint(other, PRINT_HIGH, "Woah! Caltrops!\n");
            deathmsg = DMSG_FLYCALTROP;
    		TF_T_Damage(other, self, self.owner, 20 + random() * 9, 0, TF_TD_OTHER);
        }

        dremove(self);
	}
};

