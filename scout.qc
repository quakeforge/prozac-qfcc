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
	sound (self, #CHAN_WEAPON, "weapons/bounce.wav", 1, #ATTN_NORM);
	if (self.velocity == '0 0 0')
		self.avelocity = '0 0 0';
};

#ifdef NET_SERVER
	#define SMOOTH_FLASH 1
#else
    #define SMOOTH_FLASH 0.1
#endif

void() FlashTimer =
{
	local entity te;

	te = self.owner;

	if (te.has_disconnected) //WK Safety, now that we call this to clean up after death
		return;

	te.FlashTime = te.FlashTime - #SMOOTH_FLASH;

	if (te.FlashTime < 4)
	{
		te.FlashTime = 0;
		stuffcmd(te, "v_cshift 0\n");
		stuffcmd(te, "r_norefresh 0;wait;echo;wait;echo;wait;echo;wait;echo\n"); //WK
        // OfN- now we use the centerprint replacement
		//centerprint(te,"Your 	 eyes 	 finally 	 clear\n");
        StatusPrint(te,2,"Your 	 eyes 	 finally 	 clear\n");
		return;
	}

	local string st;

	st = ftos(te.FlashTime * 15); //WK Multiplier 10

	stuffcmd(te, "v_cshift ");
	stuffcmd(te, st);
	stuffcmd(te, " ");
	stuffcmd(te, st);
	stuffcmd(te, " ");
	stuffcmd(te, st);
	stuffcmd(te, " ");
	stuffcmd(te, st);
	stuffcmd(te, "\n");
	if (te.FlashTime > 15 || (te.FlashTime < 12 && te.FlashTime > 11) || (te.FlashTime < 9 && te.FlashTime > 7) || te.FlashTime < 5)
		if (self.heat != 1) {
			StatusPrint(te,2,"Your 	 eyes 	 burn\n		 with 		 the 		 pain\n	 of 	\n glowing phosphor\n			 			 			\n	 	 	 	 	\n");
			stuffcmd(te, "r_norefresh 1;wait;echo;wait;echo;wait;echo;wait;echo\n");
			self.heat = 1;
		}
	else
		if (self.heat != 0) {
			StatusPrint(te,2,"Your 	 eyes 	 water\n		 and 		 momentarily 		 lessen\n	 the 	\n Indescribable Pain\n			 			 			\n	 	 	 	 	\n");
			stuffcmd(te, "r_norefresh 0;wait;echo;wait;echo;wait;echo;wait;echo\n");
			self.heat = 0;
		}


	self.nextthink = time + #SMOOTH_FLASH;
};

//=========================================================================
// Flash Grenade explode function, for when the PRIMETIME runs out
void() FlashGrenadeExplode =
{
	local float expsize;
	local entity te, oldself;

	self.effects = self.effects | #EF_BRIGHTLIGHT;

	WriteByte (#MSG_BROADCAST, #SVC_TEMPENTITY);
	WriteByte (#MSG_BROADCAST, #TE_TAREXPLOSION);
	WriteCoord (#MSG_BROADCAST, self.origin_x);
	WriteCoord (#MSG_BROADCAST, self.origin_y);
	WriteCoord (#MSG_BROADCAST, self.origin_z);
#ifdef QUAKE_WORLD
	multicast (self.origin, #MULTICAST_PHS);
#endif

	// Find all people in area
	te = findradius(self.origin, 200);
	while (te)
	{	
		// Player?
		if (te.classname == "player")
		{
			// Damage player and explode
			deathmsg = #DMSG_GREN_FLASH;
			TF_T_Damage(te, self, self.owner, 60, 0, #TF_TD_FIRE);

			if (te.health > 0)
			{
				if (te.FlashTime == 0)
				{
					// create flash timer
					newmis = spawn();

					newmis.classname = "timer";
					newmis.netname = "flashtimer";
					newmis.team_no = self.owner.team_no;
					newmis.owner = te;
					newmis.think = FlashTimer;
					newmis.nextthink = time + 1;
					newmis.heat = 1;
				}

				te.FlashTime = 16; //WK 24 for non-owners

				local string st;

				st = ftos(te.FlashTime * 15);
				stuffcmd(te, "v_cshift ");
				stuffcmd(te, st);
				stuffcmd(te, " ");
				stuffcmd(te, st);
				stuffcmd(te, " ");
				stuffcmd(te, st);
				stuffcmd(te, " ");
				stuffcmd(te, st);
				stuffcmd(te, "\n");
				stuffcmd(te, "r_norefresh 1;wait;echo;wait;echo;wait;echo;wait;echo\n"); //WK
			    StatusPrint(te,2,"Your 	 eyes 	 burn\n		 with 		 the 		 pain\n	 of 	\n glowing phosphor\n			 			 			\n	 	 	 	 	\n");
			}
		}

		te = te.chain;
	}

#ifdef DEMO_STUFF
	// Remove any camera's locks on this missile
	if (self.enemy)
		CamProjectileLockOff();
#endif

#ifdef QUAKE_WORLD
	dremove(self);
#else
	BecomeExplosion();
#endif
};



//=========================================================================
// Touch function for a concussion grenade
void() ConcussionGrenadeTouch =
{
	// concussion grenades bounce off other players now

	sound (self, #CHAN_WEAPON, "weapons/bounce.wav", 1, #ATTN_NORM);	// bounce sound
	if (self.velocity == '0 0 0')
		self.avelocity = '0 0 0';
};

//=========================================================================
// Concussion grenade explosion function
void() ConcussionGrenadeExplode =
{	
	T_RadiusBounce (self, self.owner, 240, world);

#ifdef DEMO_STUFF
	// Remove any camera's locks on this missile
	if (self.enemy)
		CamProjectileLockOff();
#endif

	WriteByte (#MSG_BROADCAST, #SVC_TEMPENTITY);
	WriteByte (#MSG_BROADCAST, #TE_EXPLOSION);
	WriteCoord (#MSG_BROADCAST, self.origin_x);
	WriteCoord (#MSG_BROADCAST, self.origin_y);
	WriteCoord (#MSG_BROADCAST, self.origin_z);
#ifdef QUAKE_WORLD
	multicast (self.origin, #MULTICAST_PHS);
	dremove(self);
#else
	BecomeExplosion ();
#endif
};

//=========================================================================
// Concussion grenade timer to remove idlescale
void() ConcussionGrenadeTimer =
{
	local string st;

	if (self.owner.invincible_finished > time)
	{
		stuffcmd(self.owner, "v_idlescale 0\n");
		dremove(self);
		return;
	}

	// Bubble
	newmis = spawn();
	setmodel (newmis, "progs/s_bubble.spr");
	setorigin (newmis, self.owner.origin);
	newmis.movetype = #MOVETYPE_NOCLIP;
	newmis.solid = #SOLID_NOT;
	newmis.velocity = '0 0 15';
	newmis.nextthink = time + 0.5;
	newmis.think = bubble_bob;
	newmis.touch = bubble_remove;
	newmis.classname = "bubble";
	newmis.frame = 0;
	newmis.cnt = 0;
	setsize(newmis, '-8 -8 -8', '8 8 8');

	self.health = self.health - #GR_CONCUSS_DEC;
	
	// medic recovers twice as fast
	if (self.owner.weapons_carried & #WEAP_MEDIKIT) //WK
		self.health = self.health - #GR_CONCUSS_DEC;
	if (self.owner.cutf_items & #CUTF_STEALTH)
		self.health = self.health - #GR_CONCUSS_DEC;
	if (self.owner.cutf_items & #CUTF_GYMNAST)
		self.health = self.health - #GR_CONCUSS_DEC;

	if (self.health < 0)
		self.health = 0;
	self.nextthink = time + #GR_CONCUSS_TIME;

	st = ftos(self.health);
	stuffcmd(self.owner, "v_idlescale ");
	stuffcmd(self.owner, st);
	stuffcmd(self.owner, "\n");

	if (self.health == 0)
		dremove(self);
};

//=========================================================================
// Handles the scanner function for Scouts
void(float scanrange,float inAuto) TeamFortress_Scan = 
{
	local string power;
	local entity list;
	local float scen, scfr;
	local vector lightningvec;

	// added in for the direction scanner code
	local float enemy_detected;
	local float any_detected;

	local vector vf, vr, e;  // transformed versions of v_forward, v_right and the enemy vector
	local float res1, res2, res3; // for the vector work
	local float vf_e_angle, vr_e_angle; // results

	// prevent scan impulse from triggering anything else
	self.impulse = 0;
	self.last_impulse = 0;

	if (self.classname == "player")
	{
		if (!(self.tf_items & #NIT_SCANNER))
			return;

		// If Impulse is #TF_SCAN_ENEMY, toggle Scanning for Enemies
		if (scanrange == #TF_SCAN_ENEMY)
		{
			if (self.tf_items_flags & #NIT_SCANNER_ENEMY)
			{
				sprint (self, #PRINT_HIGH, "Enemy Scanning disabled.\n");
				self.tf_items_flags = self.tf_items_flags - #NIT_SCANNER_ENEMY;
				return;
			}
			sprint (self, #PRINT_HIGH, "Enemy Scanning enabled.\n");
			self.tf_items_flags = self.tf_items_flags | #NIT_SCANNER_ENEMY;
			return;
		}

		// If Impulse is #TF_SCAN_FRIENDLY, toggle Scanning for Friendlies
		if (scanrange == #TF_SCAN_FRIENDLY)
		{
			if (self.tf_items_flags & #NIT_SCANNER_FRIENDLY)
			{
				sprint (self, #PRINT_HIGH, "Friendly Scanning disabled.\n");
				self.tf_items_flags = self.tf_items_flags - #NIT_SCANNER_FRIENDLY;
				return;
			}
			sprint (self, #PRINT_HIGH, "Friendly Scanning enabled.\n");
			self.tf_items_flags = self.tf_items_flags | #NIT_SCANNER_FRIENDLY;
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
			sprint(self, #PRINT_HIGH, "No cells.\n");
			return;
		}
*/
		if (scanrange > #NIT_SCANNER_MAXCELL)
			scanrange = #NIT_SCANNER_MAXCELL;

		scen = 0;
		scfr = 0;
		// Set the Scanner flags
		if (self.tf_items_flags & #NIT_SCANNER_ENEMY)
			scen = 1;
		if (self.tf_items_flags & #NIT_SCANNER_FRIENDLY)
			scfr = 1;

		// If no entity type is enabled, don't scan
		if ((scen == 0) && (scfr == 0))
		{
			sprint(self, #PRINT_HIGH, "All scanner functions are disabled.\nEnable with 'scane' or 'scanf'.\n");
			return;
		}

		// Use up cells to power the scanner
		// additions:
		// altered this so scanner could be more easily tested
//WK		self.ammo_cells = self.ammo_cells - scancost;
		scanrange = scanrange * #NIT_SCANNER_POWER;

		if (!inAuto) { //WK Only sprint() if not autoscanner
			sprint (self, #PRINT_HIGH, "Range: ");
			power = ftos(ceil(scanrange));
			sprint (self, #PRINT_HIGH, power);
			sprint (self, #PRINT_HIGH, ". Scanning...\n");
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
		// sets the enemy_detected flag to #TRUE if not on your team, #FALSE if so
		any_detected = #TRUE; // this flag is set to false if bogie is moving
							 // too slow to be detected (and velocity checking is on)

		if (vlen(list.origin - self.origin) <= scanrange) //CH Secondary check NEEDED!!!
		{
		// If this scanner is a motion detector, don't record
		// object that don't have the required velocity to be detected.
		if (self.tf_items_flags & #NIT_SCANNER_MOVEMENT)
		{
			if (vlen(list.velocity) > #NIT_SCANNER_MIN_MOVEMENT)
			{
				if (list.classname == "monster_demon1" && list.health > 0) //Because they dont have teams
				{
					if (Teammate(list.real_owner.team_no,self.team_no))
					{
						scfr = scfr + 1;
						enemy_detected = #FALSE;
					}
					else
					{
						scen = scen + 1;
						enemy_detected = #TRUE;
					}
				}
				else if (list.classname == "monster_army" && list.health > 0) //Because they dont have teams
				{
					if (Teammate(list.real_owner.team_no,self.team_no))
					{
						scfr = scfr + 1;
						enemy_detected = #FALSE;
					}
					else
					{
						scen = scen + 1;
						enemy_detected = #TRUE;
					}
				}
				else if (list.classname == "monster_shambler" && list.health > 0) //Because they dont have teams
				{
					if (Teammate(list.real_owner.team_no,self.team_no))
					{
						scfr = scfr + 1;
						enemy_detected = #FALSE;
					}
					else
					{
						scen = scen + 1;
						enemy_detected = #TRUE;
					}
				}
   				//- OfN -
                else if (list.classname == "monster_wizard" && list.health > 0) //Because they dont have teams
				{
					if (Teammate(list.real_owner.team_no,self.team_no))
					{
						scfr = scfr + 1;
						enemy_detected = #FALSE;
					}
					else
					{
						scen = scen + 1;
						enemy_detected = #TRUE;
					}
				}

				else if (list.classname == "item_tfgoal" && list.owned_by > 0 && list.team_no > 0 && self.team_no > 0) //Because they use owned_by
				{
					if (list.owned_by == self.team_no && list.team_no != self.team_no)
					{
						scfr = scfr + 1;
						enemy_detected = #FALSE;
					}
					else if (list.owned_by == self.team_no && list.team_no == self.team_no)
					{
						scfr = scfr + 1;
						enemy_detected = #FALSE;
					}
					else if (list.owned_by != self.team_no && list.team_no == self.team_no)
					{
						scen = scen + 1;
						enemy_detected = #TRUE;
					}
					else
						any_detected = #FALSE;
				}
				else if ((list.classname == "player" || list.classname == "building_sentrygun" || list.classname == "building_tesla" || list.classname == "building_teleporter") && list.health > 0 && !(list.cutf_items & #CUTF_JAMMER))
				{
					if (Teammate(list.team_no, self.team_no))
					{
						scfr = scfr + 1;
						enemy_detected = #FALSE;
					}
					else
					{
						scen = scen + 1;
						enemy_detected = #TRUE;
					}
				}
				else
				{
					any_detected = #FALSE;
				}
			}
			else
			{
				any_detected = #FALSE;
			}
		}
		else
		{
				if (list.classname == "monster_demon1" && list.health > 0) //Because they dont have teams
				{
					if (Teammate(list.real_owner.team_no,self.team_no))
					{
						scfr = scfr + 1;
						enemy_detected = #FALSE;
					}
					else
					{
						scen = scen + 1;
						enemy_detected = #TRUE;
					}
				}
				if (list.classname == "monster_army" && list.health > 0) //Because they dont have teams
				{
					if (Teammate(list.real_owner.team_no, self.team_no))
					{
						scfr = scfr + 1;
						enemy_detected = #FALSE;
					}
					else
					{
						scen = scen + 1;
						enemy_detected = #TRUE;
					}
				}
				if (list.classname == "monster_shambler" && list.health > 0) //Because they dont have teams
				{
					if (Teammate(list.real_owner.team_no, self.team_no))
					{
						scfr = scfr + 1;
						enemy_detected = #FALSE;
					}
					else
					{
						scen = scen + 1;
						enemy_detected = #TRUE;
					}
				}
                //- OfN -
                if (list.classname == "monster_wizard" && list.health > 0) //Because they dont have teams
				{
					if (Teammate(list.real_owner.team_no, self.team_no))
					{
						scfr = scfr + 1;
						enemy_detected = #FALSE;
					}
					else
					{
						scen = scen + 1;
						enemy_detected = #TRUE;
					}
				}
				else if (list.classname == "item_tfgoal" && list.owned_by > 0 && list.team_no > 0 && self.team_no > 0) //Because they use owned_by
				{
					if (list.owned_by == self.team_no && list.team_no != self.team_no)
					{
						scfr = scfr + 1;
						enemy_detected = #FALSE;
					}
					else if (list.owned_by == self.team_no && list.team_no == self.team_no)
					{
						scfr = scfr + 1;
						enemy_detected = #FALSE;
					}
					else if (list.owned_by != self.team_no && list.team_no == self.team_no)
					{
						scen = scen + 1;
						enemy_detected = #TRUE;
					}
					else
						any_detected = #FALSE;
				}
				else if ((list.classname == "player" || list.classname == "building_sentrygun" || list.classname == "building_tesla" || list.classname == "building_teleporter") && list.health > 0 && !(list.cutf_items & #CUTF_JAMMER))
				{
					if (Teammate(list.team_no, self.team_no))
					{
						scfr = scfr + 1;
						enemy_detected = #FALSE;
					}
					else
					{
						scen = scen + 1;
						enemy_detected = #TRUE;
					}
				}
				else
				{
					any_detected = #FALSE;
				}
		}
		}
		else
		{
			any_detected = #FALSE;
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
			WriteByte (#MSG_ONE, #SVC_TEMPENTITY);
			WriteByte (#MSG_ONE, #TE_LIGHTNING1);
			WriteEntity (#MSG_ONE, self);
			WriteCoord (#MSG_ONE, self.origin_x);
			WriteCoord (#MSG_ONE, self.origin_y);
			WriteCoord (#MSG_ONE, self.origin_z + 8);
			WriteCoord (#MSG_ONE, lightningvec_x);
			WriteCoord (#MSG_ONE, lightningvec_y);
			WriteCoord (#MSG_ONE, lightningvec_z + 8);

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
		sprint (self, #PRINT_HIGH, "No blips.\n");
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
	local	string	st;

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
				if (head.cutf_items & #CUTF_GYMNAST)
					points = points * 2;

				if (!IsBuilding(head) && points > 0)
				{
					// Bounce!!
					head.velocity = org - inflictor.origin;
					head.velocity = head.velocity * (points / 20);

					if (head.classname != "player")
					{
						if(head.flags & #FL_ONGROUND)
							head.flags = head.flags - #FL_ONGROUND;
					}
					else
					{
						//WK Add cheat immunity since they fly
						makeImmune(head,time+3);

						// Concuss 'em!!
						// If they are already concussed, set the concussion back up
						// Try to find a concusstimer entity for this player
						te = find(world, classname, "timer");
						while (((te.owner != head) || (te.think != ConcussionGrenadeTimer)) && (te != world))
							te = find(te, classname, "timer");
						if (te != world)
						{
							stuffcmd(head,"v_idlescale 100\n");
							te.health = 100;
							te.nextthink = time + #GR_CONCUSS_TIME;
						}
						else
						{
							stuffcmd(head,"v_idlescale 100\n");
							stuffcmd(head,"bf\n");
							// Create a timer entity
							te = spawn();
							te.nextthink = time + #GR_CONCUSS_TIME;
							te.think = ConcussionGrenadeTimer;
							te.team_no = attacker.team_no;
							te.classname = "timer";
							te.owner = head;
							te.health = 100;
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
		if (targ.playerclass == #PC_UNDEFINED) {
			return #FALSE;
		}
		else if (targ.done_custom & #CUSTOM_BUILDING) {
			return #FALSE;
		}
		else if (targ.health <= 0) {
			return #FALSE;
		}
		else if (targ.has_disconnected) {
			return #FALSE;
		}
		else if (targ == scan) {
			return #FALSE;
		}
		else if (targ.flags & #FL_NOTARGET) {
			return #FALSE;
		}
		else if (targ.cutf_items & #CUTF_JAMMER)
			return #FALSE;
//CH ALL NEW CHECKS ABOVE THIS LINE
		if (teamplay)
		{
			if ( friends &&  Teammate(targ.team_no,scan.team_no) )
				return #TRUE;
			if ( enemies && !Teammate(targ.team_no,scan.team_no) )
				return #TRUE;
		}
		else
			return #TRUE;
	return #FALSE;
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
				if ((head.classname == "building_tesla" || head.classname == "building_sentrygun" || head.classname == "building_teleporter") && (head.health > 0)) //CH uses team_no :)
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
	T_RadiusDamage (self, self.owner, 50, world);
	
	WriteByte (#MSG_BROADCAST, #SVC_TEMPENTITY);
	WriteByte (#MSG_BROADCAST, #TE_EXPLOSION);
	WriteCoord (#MSG_BROADCAST, self.origin_x);
	WriteCoord (#MSG_BROADCAST, self.origin_y);
	WriteCoord (#MSG_BROADCAST, self.origin_z);
	#ifdef QUAKE_WORLD
		multicast (self.origin, #MULTICAST_PHS);
	#endif
	
	self.solid = #SOLID_NOT;
	*/
	// Very well admiral. Engage the rebels.
	i = 0;
	while (i < #GR_TYPE_CALTROP_NO)
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
	newmis.movetype = #MOVETYPE_BOUNCE;
	newmis.solid = #SOLID_TRIGGER;
    //newmis.solid = #SOLID_BBOX;

	newmis.classname = "caltrop";
	newmis.weapon = #DMSG_CALTROP;

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
			sprint(other, #PRINT_HIGH, "Ouch! Ouch! Caltrops!\n");
            other.leg_damage = other.leg_damage + 2;
          	TeamFortress_SetSpeed(other);
            deathmsg = #DMSG_CALTROP;
    		TF_T_Damage(other, self, self.owner, 16, 0, #TF_TD_OTHER);
        }
        else // if its moving...
        {
			sprint(other, #PRINT_HIGH, "Woah! Caltrops!\n");
            deathmsg = #DMSG_FLYCALTROP;
    		TF_T_Damage(other, self, self.owner, 20 + random() * 9, 0, #TF_TD_OTHER);
        }

        dremove(self);
	}
};

