/*
==============================================================================

			SOURCE FOR GLOBALVARS_T C STRUCTURE

==============================================================================
*/

#include "defs.qh"

//
// system globals
//
entity	self;
entity	other;
entity	world;
float		time;
float		frametime;

entity	newmis;				// if this is set, the entity that just
							// run created a new missile that should
							// be simulated immediately

float		force_retouch;		// force all entities to touch triggers
								// next frame.  this is needed because
								// non-moving things don't normally scan
								// for triggers, and when a trigger is
								// created (like a teleport trigger), it
								// needs to catch everything.
								// decremented each frame, so set to 2
								// to guarantee everything is touched
string	mapname;

float		serverflags;		// propagated from level to level, used to
								// keep track of completed episodes

float		total_secrets;
float		total_monsters;

float		found_secrets;		// number of secrets found
float		killed_monsters;	// number of monsters killed


// spawnparms are used to encode information about clients across server
// level changes
float		parm1, parm2, parm3, parm4, parm5, parm6, parm7, parm8, parm9, parm10, parm11, parm12, parm13, parm14, parm15, parm16;

//
// global variables set by built in functions
//	
vector	v_forward, v_up, v_right;	// set by makevectors()
	
// set by traceline / tracebox
float		trace_allsolid;
float		trace_startsolid;
float		trace_fraction;
vector	trace_endpos;
vector	trace_plane_normal;
float		trace_plane_dist;
entity	trace_ent;
float		trace_inopen;
float		trace_inwater;

entity	msg_entity;				// destination of single entity writes

//
// required prog functions
//
void() 		main;						// only for testing

void()		StartFrame;

void() 		PlayerPreThink;
void() 		PlayerPostThink;

void()		ClientKill;
void()		ClientConnect;
void() 		PutClientInServer;		// call after setting the parm1... parms
void()		ClientDisconnect;

void()		SetNewParms;			// called when a client first connects to
									// a server. sets parms so they can be
									// saved off for restarts

void()		SetChangeParms;			// call to set parms for self so they can
									// be saved for a level transition


//================================================
void		end_sys_globals;		// flag for structure dumping
//================================================

/*
==============================================================================

			SOURCE FOR ENTVARS_T C STRUCTURE

==============================================================================
*/

//
// system fields (*** = do not set in prog code, maintained by C code)
//
.float		modelindex;		// *** model index in the precached list
.vector		absmin, absmax;	// *** origin + mins / maxs

.float		ltime;		// local time for entity
.float		lastruntime;	// *** to allow entities to run out of sequence

.float		movetype;
.float		solid;

.vector		origin;		// ***
.vector		oldorigin;		// ***
.vector		velocity;
.vector		angles;
.vector		avelocity;

.string		classname;		// spawn function
.string		model;
.float		frame;
.float		skin;
.float		effects;

.vector		mins, maxs;		// bounding box extents reletive to origin
.vector		size;			// maxs - mins

.void()		touch;
.void()		use;
.void()		think;
.void()		blocked;		// for doors or plats, called when can't push other

.float		nextthink;
.entity		groundentity;

// stats
.float		health;
.float		frags;
.float		weapon;			// one of the IT_SHOTGUN, etc flags
.string		weaponmodel;
.float		weaponframe;
.float		currentammo;
.float		ammo_shells, ammo_nails, ammo_rockets, ammo_cells;

.float		items;			// bit flags

.float		takedamage;
.entity		chain;
.float		deadflag;

.vector		view_ofs;			// add to origin to get eye point


.float		button0;		// fire
.float		button1;		// use
.float		button2;		// jump

.float		impulse;		// weapon changes

.float		fixangle;
.vector		v_angle;		// view / targeting angle for players

.string		netname;

.entity 		enemy; 		//WK We use this on players now, for the martyr code

.float		flags;

.float		colormap;
.float		team;

.float		max_health;		// players maximum health is stored here

.float		teleport_time;	// don't back up

.float		armortype;		// save this fraction of incoming damage
.float		armorvalue;		//Current NUMBER of armor being worn

.float		waterlevel;		// 0 = not in, 1 = feet, 2 = wast, 3 = eyes
.float		watertype;		// a contents value

.float		ideal_yaw;
.float		yaw_speed;

.entity		aiment;

.entity 		goalentity;		// a movetarget or an enemy

.float		spawnflags;

.string		target;
.string		targetname;

// damage is accumulated through a frame. and sent as one single
// message, so the super shotgun doesn't generate huge messages
.float		dmg_take;
.float		dmg_save;
.entity		dmg_inflictor;

.entity		owner;		// who launched a missile
.vector		movedir;	// mostly for doors, but also used for waterjump

.string		message;		// trigger messages

.float		sounds;		// either a cd track number or sound number

.string		noise, noise1, noise2, noise3;	// contains names of wavs to play

//================================================
void		end_sys_fields;			// flag for structure dumping
//================================================

/*
==============================================================================

				VARS NOT REFERENCED BY C CODE

==============================================================================
*/

//
// globals
//
float	movedist;

entity	activator;		// the entity that activated a trigger or brush

entity	damage_attacker;	// set by T_Damage
float	framecount;

float	skill;

// cvars checked each frame
//
float		teamplay;
float		timelimit;
float		fraglimit;
float		deathmatch;



//================================================

//
// NIL fields (FIXME: make globals)
//
.string		wad;
.string 	map;
.float		worldtype;	// 0=medieval 1=metal 2=base

//================================================

.string		killtarget;

//
// quakeed fields
//
.float		light_lev;		// not used by game, but parsed by light util
.float		style;


//
// monster ai
//

.void()		th_stand;

.void()		th_walk;
.void()		th_run;
.void()		th_missile;
.void()		th_melee;

.void(entity attacker, float damage)		th_pain;
.void()		th_die;


.entity		oldenemy;		// mad at this player before taking damage

.float	speed;

.float	lefty;

.float	search_time; 		//WK Used for hover boots. :/
.float	attack_state;		//WK Not usable?


//
// player only fields
//
.float		walkframe;

//WK
.float 		maxspeed;
.float 		gravity;
//WK -- Holds how much money we have left while building, and
// for toggling between engineer and spy menus in the game (hackish, yes)
.float 		money;
.float 		custom_speed;
.float 		ff_count;	//How many friendlies killed
//.float		be_count;	//Bad Engy count, break threshold, RESTICTED BUILD
.float		penance_time; //Time your penance will cease
.float		last_attacked_time; //Time that you were last shot at
.entity		inspirator; //Holds pointer to your chaplan
.float		has_cheated; //Holds if the user has tried to cheat or not
// SB - for demons
//.float		demon_points;  UNUSED - OfN
.float		demon_choice;
.float		demon_blood;
.entity		demon_one;
.entity		demon_two; //- OfN Not used for demons, used for hacking

//- OfN -
.float      army_ready; //- if #TRUE, soldier ready for teleport, this is set by the army_timer's
.float      num_mines; // OfN Number of guerilla mines the player has
                       // Also used for friendly hacks on machines

//- OfN - Cool gibs data stored on each TF_T_Damage
//.vector    gb_origin; // Origin of last damage
//.float     gb_disable; // if #TRUE don't use cool gibs

// hacker defences
//.float		hacker_defence; // -OfN by SB, I use num_mines instead, for hacker improvements/ice

//For the demon
.void()		th_fireball;

.float		hover_time; //How much fuel we have left in boots

.float 		done_custom;

//END WK

.entity		scaned; //CH used for scanner.

.float 		attack_finished;
.float		pain_finished;

.float		invincible_finished;
.float		invisible_finished;
.float		super_damage_finished;
.float		radsuit_finished;

.float		invincible_time, invincible_sound;
.float		invisible_time, invisible_sound;
.float		super_time, super_sound;
.float		rad_time;
.float		fly_sound;

.float		axhitme;

.float		show_hostile;	// set to time+0.2 whenever a client fires a
							// weapon or takes damage.  Used to alert
							// monsters that otherwise would let the player go
.float		jump_flag;		// player jump flag
.float		swim_flag;		// player swimming sound flag
.float		air_finished;	// when time > air_finished, start drowning
.float		bubble_count;	// keeps track of the number of bubbles
.string		deathtype;		// keeps track of how the player died

//
// object stuff
//
.string		mdl;
.vector		mangle;			// angle at start

.vector		oldorigin;		// only used by secret door

.float		t_length, t_width;


//
// doors, etc
//
.vector		dest, dest1, dest2;
.float		wait;			// time from firing to restarting
.float		delay;			// time from activation to firing
.entity		trigger_field;	// door's trigger entity
.string		noise4;

//
// monsters
//
.float 		pausetime;
.entity 	movetarget;


//
// doors
//
.float		aflag;
.float		dmg;			// damage done by door when hit
	
//
// misc
//
.float		cnt; 			// misc flag
	
//
// subs
//
.void()		think1;
.vector		finaldest, finalangle;

//
// triggers
//
.float		count;			// for counting triggers


//
// plats / doors / buttons
//
.float		lip;
.float		state;
.vector		pos1, pos2;		// top and bottom positions
.float		height;

//
// sounds
//
.float		waitmin, waitmax;
.float		distance;
.float		volume;

//===========================================================================
	

//
// builtin functions
//

void(vector ang)	makevectors			= #1;		// sets v_forward, etc globals
void(entity e, vector o) setorigin		= #2;
void(entity e, string m) setmodel		= #3;		// set movetype and solid first
void(entity e, vector min, vector max) setsize = #4;
// #5 was removed
//void() break					= #6;	no longer parses in qfcc and not needed
float() random					= #7;		// returns 0 - 1
void(entity e, float chan, string samp, float vol, float atten) sound = #8;
vector(vector v) normalize			= #9;
void(string e) error				= #10;
void(string e) objerror				= #11;
float(vector v) vlen				= #12;
float(vector v) vectoyaw			= #13;
entity() spawn					= #14;
void(entity e) remove				= #15;

// sets trace_* globals
// nomonsters can be:
// An entity will also be ignored for testing if forent == test,
// forent->owner == test, or test->owner == forent
// a forent of NIL is ignored
void(vector v1, vector v2, float nomonsters, entity forent) traceline = #16;	

entity() checkclient				= #17;	// returns a client to look for
entity(entity start, .string fld, string match) find = #18;
string(string s) precache_sound		= #19;
string(string s) precache_model		= #20;
void(entity client, string s)stuffcmd 	= #21;
entity(vector org, float rad) findradius  = #22;

//void(float level, string s) bprint	= #23;
//void(entity client, float level, string s) sprint = #24;
void(...) bprint					= #23;
void(...) sprint 					= #24;

void(...) bprint2					= #23;
void(...) sprint2 				= #24;

void(...) bprint3					= #23;
void(...) sprint3 				= #24;

void(...) bprint4					= #23;
void(...) sprint4 				= #24;

void(...) bprint5					= #23;
void(...) sprint5 				= #24;

void(...) bprint6					= #23;
void(...) sprint6 				= #24;

void(...) bprint7					= #23;
void(...) sprint7 				= #24;

void(...) bprint8					= #23;

void(string s) dprint				= #25;
void() coredump					= #28;		// prints all edicts
void() traceon					= #29;		// turns statment trace on
void() traceoff					= #30;
void(entity e) eprint				= #31;		// prints an entire edict
float(float yaw, float dist) walkmove	= #32;	// returns #TRUE or #FALSE
// #33 was removed
float() droptofloor= #34;	// #TRUE if landed on floor
void(float style, string value) lightstyle = #35;
float(float v) rint				= #36;		// round to nearest int
float(float v) floor				= #37;		// largest integer <= v
float(float v) ceil				= #38;		// smallest integer >= v
// #39 was removed
float(entity e) checkbottom			= #40;		// true if self is on ground
float(vector v) pointcontents			= #41;		// returns a CONTENT_*
// #42 was removed
float(float f) fabs 				= #43;
vector(entity e, float speed) aim 		= #44;		// returns the shooting vector
float(string s) cvar 				= #45;		// return cvar.value
void(string s) localcmd 			= #46;		// put string into local que
entity(entity e) nextent 			= #47;		// for looping through all ents
void(vector o, vector d, float color, float count) particle = #48;// start a particle effect
void() ChangeYaw 					= #49;		// turn towards self.ideal_yaw
										// at self.yaw_speed
// #50 was removed
vector(vector v) vectoangles			= #51;

//
// direct client message generation
//
void(float to, float f) WriteByte		= #52;
void(float to, float f) WriteChar		= #53;
void(float to, float f) WriteShort		= #54;
void(float to, float f) WriteLong		= #55;
void(float to, float f) WriteCoord		= #56;
void(float to, float f) WriteAngle		= #57;
void(float to, string s) WriteString	= #58;
void(float to, entity s) WriteEntity	= #59;


void(float step) movetogoal			= #67;

string(string s) precache_file		= #68;	// no effect except for -copy
void(entity e) makestatic			= #69;
void(string s) changelevel 			= #70;

//#71 was removed

void(string var, string val) cvar_set 	= #72;	// sets cvar.value

//void(entity client, string s) centerprint = #73;	// sprint, but in middle
void(...) centerprint = #73;
#ifndef STATUSBAR
void(entity pl, string s1) CenterPrint = #73;
void(entity pl, string s1, string s2) CenterPrint2 = #73;
#endif

void(vector pos, string samp, float vol, float atten) ambientsound = #74;

string(string s) precache_model2		= #75;		// registered version only
string(string s) precache_sound2		= #76;		// registered version only
string(string s) precache_file2		= #77;		// registered version only

void(entity e) setspawnparms			= #78;		// set parm1... to the
												// values at level start
												// for coop respawn

void(entity killer, entity killee) logfrag = #79;	// add to stats
string(entity e, string key) infokey	= #80;		// get a key value (NIL = serverinfo)
void(vector where, float set) multicast 	= #82;  // sends the temp message
													// to a set of clients,
													// possibly in PVS or PHS
entity (entity ent) testentitypos = #92;
integer (entity ent, vector mins, vector maxs, vector point) hullpointcontents = #93;
vector (integer hull, integer max) getboxbounds = #94;
integer () getboxhull = #95;
void (integer hull) freeboxhull = #96;
void (integer hull, vector right, vector forward, vector up,
	  vector mins, vector maxs) rotate_bbox = #97;
void (vector start, vector mins, vector maxs, vector end, float type,
	  entity passent) checkmove = #98;				// Wrapper around SV_Move.

void (entity ent, string key, string value) setinfokey = #102;
float (string path, string mode) cfopen = #103;
void (float desc) cfclose = #104;
string (float desc) cfread = #105;
float (float desc, string buf) cfwrite = #106;
float (float desc) cfeof = #107;
float () cfquota = #108;

string (...) sprintf = #109;

string (float f) ftos = #26;
integer (float f) ftoi = #110;
float (integer i) itof = #110;
string (integer i) itos = #112;
float (string s) stof = #81;
integer (string s) stoi = #113;
vector (string s) stov = #114;
string (vector v) vtos = #27;

//============================================================================

//
// subs.qc
//
void(vector tdest, float tspeed, void() func) SUB_CalcMove;
void(entity ent, vector tdest, float tspeed, void() func) SUB_CalcMoveEnt;
void(vector destangle, float tspeed, void() func) SUB_CalcAngleMove;
void() SUB_CalcMoveDone;
void() SUB_CalcAngleMoveDone;
void() SUB_UseTargets;
void() SUB_Remove;


//
//	combat.qc
//
void(entity targ, entity inflictor, entity attacker, float damage) T_Damage;


float (entity e, float healamount, float ignore) T_Heal; // health function

float(entity targ, entity inflictor) CanDamage;

//
//  tforttm.qc
//
void (entity pl, float topcolor, float bottomcolor) SetPlayerColor;

string (string s) quotename;


//===========================================================================
// TEAMFORTRESS Defs
//===========================================================================
.float      	playerclass;		
.float		nextpc;			// The playerclass you'll respawn as
.float		last_impulse;		// The previous impulse command from this player
.float		armorclass;			// Type of *special* armor being worn
.float 		tf_items;			// Another flag for player items
.float 		job;				// WK Yet another flag for player items
.float		job_finished;		// WK Time for job ability to end/reload
.float		tf_items_flags;		// Flags for the player items
.float		no_grenades_1;		// Number of grenades of type 1 being carried
.float		no_grenades_2;		// Number of grenades of type 2 being carried
.float		tp_grenades_1;		// 1st type of grenades being carried
.float		tp_grenades_2;		// 2nd type of grenades being carried
.float		got_aliases;		// controls state of alias checker
.float		got_aliases_bits;	// version number bits
.float		got_aliases_num;	// batch of aliases that are done
.float		got_aliases_time;	// time next alias will be set automatically
.float 		cheat_check;		// Time when we'll next check for team cheats
.float 		is_removed;			// TRUE if the entity has been removed
.float		is_undercover;		// TRUE for a SPY if they're undercover
.float		is_building;	 	// TRUE for an ENGINEER if they're building something
.float		is_detpacking;	 	// TRUE for a DEMOMAN if they're setting a detpack
.float		is_feigning;		// TRUE for a SPY if they're feigning death
.float		is_haxxxoring;		// TRUE if the player is hax0ring something
.float		is_toffingadet;		// TRUE if the player is arming a C4 det
.float		is_unabletospy;		// TRUE for a SPY if they can't go undercover
.float		is_malfunctioning;  //- SB/OfN For buildings and cyberaug players to determine if screwed up
.float		is_abouttodie;		// Oh no I am a martyr and about to die
//.float		is_cameraviewing;	// We're gazing out of the camera

.float      is_killed;           // avoids stack overflow on killed() ?? (only skips killed() for buildings)
.float      option;             // - OfN - used for megatf effect_random_sound support, and for camera/sensor build-destroy overflow control
.float      option2;            // - OfN - used for megatf effect_random_sound support


.float		has_disconnected;		// TRUE if the player has disconnected
.float		has_dispenser;		// TRUE for an ENGINEER if he has a dispenser
.float		has_sentry;			// TRUE for an ENGINEER if he has a sentry
.float		has_tesla;			// TRUE for an ENGINEER if he has a tesla
.float		has_camera;			// TRUE for an ENGINEER if he has a camera
.float		has_sensor;			// TRUE for an ENGINEER if he has a motion sensor
.float		has_teleporter;		// contains # of teleporters
.float      has_fieldgen;       // contains # of field generators
.float		admin_flag;			// TRUE if player has admin access
.entity		admin_kick;			// Contains the current client to kick
.entity		martyr_enemy;		// The last guy that shot the martyr. self = nobody
.float		stored_deathmsg; // OfN - UNUSED? - ofn nope hehe
.float		cluster_mode;		// 0=nothing 1=normal 2=cluster

//- OfN fields ---------------------------------//
.float has_holo; // holds player's holo status
// Rotation entities fields
.vector neworigin;
.vector rotate;
.float  endtime;
.float  rotate_type;
.string path;
.string group;
.string event;
.float duration;
// AirFist fields -
.float AIRG_Timeout;
.float AIRG_FireCount;
.float AIRG_Flags;
.entity AIRG_FlyTracker;

// crusader fields
.float	aura;		// The aura of the player
.float	aura_time;	// When the aura runs out
.entity  crusader_inspirator; // different than inspirator for chapplan

// OfN Warlock monsters
.entity summon_one;
.entity summon_two;


// laser cannon fields -
// NONE, i used alternative ones
//.vector old_velocity; // I use neworigin
.float reload_laser_cannon;

// fieldgen fields
.float	fieldgen_status;
.float	fieldgen_hasfield;
.entity	fieldgen_field;

.vector forcefield_offset;
//----------------------------------------------//


// TeamFortress State Flags
.float 	tfstate;					// State flags for TeamFortress

.entity	linked_list;		// Used just like chain. Has to be separate so
						// it doesn't interfere with chain. See T_RadiusScan
.entity	observer_list;		// Used by undefined classes, see TF_MovePlayer

// Defines used by TF_T_Damage (see combat.qc)

// Playerclass handling variables
.float	maxammo_shells;		// Class holding details
.float	maxammo_nails;
.float	maxammo_cells;
.float	maxammo_rockets;
.float	items_allowed;
.float	armor_allowed; //Maximum color armor we can have. 0.3 for scouts...
.float 	maxarmor; 	   //Maximum number of armor we can have. 200 for soldiers...
//WK .float	maxfbspeed;			// Maximum forward/back speed
//WK .float	maxstrafespeed;		// Maximum side speed

.float	weaponmode;			// Used for multiple mode weapons

.float	motd; 			// Used to display MOTD
.float  current_menu;			// is set to the number of the current menu, is 0 if they are not in a menu
.float  menu_count;			// keeps track of display times for menus
.float  menu_displaytime;		// keep track of how many times this menu is refreshed

.integer rotated_bbox;
				   

/*==================================================*/
/* Toggleable Game Settings							*/
/*==================================================*/
float toggleflags;					// toggleable flags

float respawn_delay_time;

// FortressMap stuff
float number_of_teams; // number of teams supported by the map
float illegalclasses;   // Illegal playerclasses for all teams
float illegalclasses1;  // Illegal playerclasses for team 1
float illegalclasses2;  // Illegal playerclasses for team 2
float illegalclasses3;  // Illegal playerclasses for team 3
float illegalclasses4;  // Illegal playerclasses for team 4
float civilianteams;    // Bitfield holding Civilian teams

float team1col;		// Colours for each of the 4 teams
float team2col;		// If there's enough demand, we'll
float team3col;		// allow more than four teams...
float team4col;		// but there's no demand at all, so no
float team1score;	// Goal Score of each team
float team2score;	
float team3score;	
float team4score;	
float team1lives;	// Number of lives each team's players have
float team2lives;	
float team3lives;	
float team4lives;


//--- OfN global vars ----//
float pay_msgs;
float team_prefix;
float max_mines;
//float allow_mauser;
//float allow_antigrav;

float no_clusters;
float no_c4;
float no_otr;
float no_laser;
float no_grapple;
float headless;
float custom_mode;
float stock_mode;
float nicecolors;
float relax_cheatcheck;
//float cool_gibs;
float army_delay;
float no_monstercolors;
float no_army;
float no_chaplan;
float no_detpush;
//- REMOTE DEBUG GLOBALS -//
entity debug_target; // server dprints will go to this client too
float allow_debug;
//-------------------------//
float allow_watermonsters; // if so, grunts and monsters can be in water, in check_contents ai.qc

// Chris' Teamplay Plus Mode
/*float chris; // Is Chris mode on or off

float team1rounds; // No. of rounds won per team
float team2rounds;
float team3rounds;
float team4rounds;

float team1total; // no. of players alive per team
float team2total;
float team3total;
float team4total;

float roundstowin; // No. of rounds required to win
float roundendtime; // The end time of the current round
float roundtime; // Time per round
float livesperguy; // Number of lives per guy
// end Chris*/
float team1maxplayers;	// Max number of players allowed in each team
float team2maxplayers;	
float team3maxplayers;  
float team4maxplayers;  
float team1advantage;  // only used if the teamplay equalisation bits are set
float team2advantage;  // stores the damage ratio players take/give
float team3advantage;
float team4advantage;
//WK Holds the next time that we'll allow a spam grenade to be thrown.
float team1nextspam;
float team2nextspam;
float team3nextspam;
float team4nextspam;

.float team_no;		// The team you belong to
.float old_team_no;	// WK The team you used belong to
.float lives;		// The number of lives you have left

.float infection_team_no; // The team_no of the person who infected you

// CTF stuff
float CTF_Map;

float		coop;
float       rj;					// Rocket Jump Modifier



// Defines for the playerclass

.entity building;	  // The building the ENGINEER is using
.float building_wait; // Used to prevent using a building again immediately
.entity real_owner;


.float real_frags;	// Used to store the players frags when TeamFrags is On

.float respawn_time;	// players can't respawn within this time.
.float suicide_time;	// players can't suicide within this time.

/*==================================================*/
/* New Weapon Defines		                        */
/*==================================================*/
.float weapons_carried;		// the weapons the player is carrying
.float current_weapon;		// the weapon the player is using


//WK On to the third 24-wide bitfield for holding purchases
.float cutf_items;

.float ammo_medikit;			 // Ammo used for the medikit
.float maxammo_medikit;

.float ammo_detpack;					// Ammo used for the detpack
.float maxammo_detpack;
.float ammo_c4det; // ammo for c4 throwable det

										// by scanners that only detect movement

/*==================================================*/
/* Variables used for New Weapons and Reloading     */
/*==================================================*/
.float reload_shotgun;
.float reload_super_shotgun;
.float reload_grenade_launcher;
.float reload_rocket_launcher;
.float reload_light_assault;

// Assault Cannon
.float heat;

// Team Color Cheat Checking
.float immune_to_chec; //xxxx

// Make sure people don't do too many saveme sounds
.float last_saveme_sound;


/*==========================================================================*/
/* TEAMFORTRESS GOALS														*/
/*==========================================================================*/

// Variables used in the Goals
.float goal_no;				// Goal number of this goal
.float group_no;	 		// Goal group this goal is in
.float goal_state;			// State of this goal
.float owned_by;			// The team this goal/item/whatever belongs to

// Goal Activation details
.float goal_activation;		// Bitfields. Determines how this goal is activated
.float goal_effects;		// Bitfields. Determines which players are affected by this goal
.float goal_result;			// Bitfields. Determines the results of activation
.float goal_group;			// Bitfields. Determines how groups are affected by activation of this goal

.float else_goal;			// A Goal that's activated if this one fails to activate

.float if_goal_is_active;
.float if_goal_is_inactive;
.float if_goal_is_removed; 
.float if_group_is_active; 
.float if_group_is_inactive;
.float if_group_is_removed;

// Goal Result details
.float activate_goal_no;
.float inactivate_goal_no;
.float remove_goal_no;
.float restore_goal_no;		
.float activate_group_no;	
.float inactivate_group_no;	
.float remove_group_no;		
.float restore_group_no;

// Item State behaviour
.float has_item_from_group;
.float remove_item_group;
.float return_item_no;
.float if_item_has_moved;
.float if_item_hasnt_moved;

// Spawnpoint behaviour
.float remove_spawnpoint;
.float restore_spawnpoint;
.float remove_spawngroup;
.float restore_spawngroup;

// Item Displaying details
.float display_item_status1;	// Goal displays the status of these items
.float display_item_status2;	
.float display_item_status3;	
.float display_item_status4;	
.string team_str_home;		  // Displayed when the item is at home base
.string team_str_moved;		  // Displayed when the item has been moved
.string team_str_carried;     // Displayed when the item is being carried
.string non_team_str_home;	  // Displayed when the item is at home base
.string non_team_str_moved;	  // Displayed when the item has been moved
.string non_team_str_carried; // Displayed when the item is being carried

.vector	goal_min; //CH
.vector	goal_max; //CH

// Goal/Timer/GoalItem/Trigger existence checking
.float ex_skill_min;			// Exists when the skill is >= this value
.float ex_skill_max;			// Exists when the skill is <= this value
//.float ex_num_players_min;		// Exists when the number of players is >= this value
//.float ex_num_players_max;		// Exists when the number of players is <= this value

// Score increases
.float increase_team1;			// Increase the scores of particular teams
.float increase_team2;
.float increase_team3;
.float increase_team4;

// Centerprinting
.string broadcast;				// Centerprinted to all, overridden by the next two
.string team_broadcast;			// Centerprinted to AP's team members, but not the AP
.string non_team_broadcast; 	// Centerprinted to non AP's team members
.string owners_team_broadcast;  // Centerprinted to the members of the team that own the Goal/Item
.string netname_broadcast;				// same as above, prepended by AP netname and bprinted
.string netname_team_broadcast;			// same as above, prepended by AP netname and bprinted
.string netname_non_team_broadcast; 	// same as above, prepended by AP netname and bprinted
.string netname_owners_team_broadcast;  // same as above, prepended by AP netname and bprinted

.string team_drop;				// Centerprinted to item owners team
.string non_team_drop;			// Centerprinted to everone not on item owners team
.string netname_team_drop;		// same as above, prepended by AP netname and bprinted
.string netname_non_team_drop;  // same as above, prepended by AP netname and bprinted

string team_menu_string;	
.float all_active;

.float item_list;			// Used to keep track of which goalitems are 
							// affecting the player at any time.
							// GoalItems use it to keep track of their own 
							// mask to apply to a player's item_list
float item_list_bit;		// Global, used to determine what the bit of
							// each new GoalItem will be.

.float delay_time;			// For delayed goal results
.float dont_do_triggerwork;

// Abbreviations for the above
.float g_a;		// goal_activation
.float g_e;		// goal_effects

.string t_s_h;	// team_str_home
.string t_s_m;	// team_str_moved
.string t_s_c;	// team_str_carried
.string n_s_h;	// non_team_str_home
.string n_s_m;	// non_team_str_moved
.string n_s_c;	// non_team_str_carried

.string b_b;	// broadcast
.string b_t;	// team_broadcast
.string b_n;	// non_team_broadcast
.string b_o;	// owners_team_broadcast
.string n_b;	// netname_broadcast
.string n_t;	// netname_team_broadcast
.string n_n;	// netname_non_team_broadcast
.string n_o;	// netname_owners_team_broadcast

.string d_t;	// team_drop
.string d_n;	// non_team_drop
.string d_n_t;	// netname_team_drop
.string d_n_n;	// netname_non_team_drop

/*==========================================================================*/
/* Flamethrower																*/
/*==========================================================================*/
float num_world_flames;

.float numflames; //number of flames on entity
// .float timecount; //timelength of the flames on entity
// this uses .health now
.string flame_id;  // has to be string so that the C function find() can be used


/*==========================================================================*/
/* Limit handling for various things										*/
/*==========================================================================*/
// pipebomb limits
// when the limit is exceeded, older pipebombs explode
float num_world_pipebombs;
float num_team_pipebombs_1;
float num_team_pipebombs_2;
float num_team_pipebombs_3;
float num_team_pipebombs_4;

// ammobox limits
// when the limit is exceeded, older ammoboxes disappear
float num_world_ammoboxes;
float num_team_ammoboxes_1;
float num_team_ammoboxes_2;
float num_team_ammoboxes_3;
float num_team_ammoboxes_4;

/*==================================================*/
/* Spy variables	 								*/
/*==================================================*/
.float undercover_team;		// The team the Spy is pretending to be in
.float undercover_skin;		// The skin the Spy is pretending to have
.string undercover_name;   	// The name of the player the Spy is pretending to be


float	spy_off;	// Spy class off/on
float	invis_only; // Spy invisible instead of color/skin changing
float allow_hook;	// Allow players to use the hook
float jello;	//WK Jello water! If this is true, you bounce on water
float light_damage; //WK Armor more expensive, damage at 75%
float prematch;	//WK Jello water! If this is true, you bounce on water
float bounty; 	//WK Bounty system off/on
float custom_money;   // WK Set starting money
float team_with_flag; // CG steal4d who has flag code
float friends1_mask;  // KK masks of friendly teams, code for > 2 team maps
float friends2_mask;
float friends3_mask;
float friends4_mask;

.float	hook_out;

/*==================================================*/
/* Camera defines	 								*/
/*==================================================*/
#ifdef DEMO_STUFF
float live_camera;
.float camdist;
.vector camangle;
.entity camera_list;
#endif

/*==================================================*/
/* QuakeWorld defines 								*/
/*==================================================*/
// some redecs for printing in QW

float already_chosen_map;
float triggered_cycle;

// grappling hook variables

.entity	hook;	
.float	on_hook;
.float  fire_held_down;// flag - TRUE if player is still holding down the
                       // fire button after throwing a hook.


// sniper location damage stuff

.vector head_shot_vector;
.float leg_damage;

.float cheat_level;
.float speed_level;

// flash grenade level
.float FlashTime;

// status bar stuff
.float StatusRefreshTime;		// time to next refresh the status bar
								// any function that uses a CenterPrintnt
								// should reset this value
.float StatusBarSize;		// the size of the bar. 1 is default, 0 is off
.float StatusBarRes;		// the gfx res the player's running in
.float StatusBarScreen;		//CH what screen to jump to when next called.

/*==================================================*/
/* Death Message defines							*/
/*==================================================*/
float deathmsg;		// Global, which is set before every T_Damage, to indicate
					// the death message that should be used.
