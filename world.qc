//================================================================//
//- CustomTF Worldspawn and related stuff              OfteN      //
//- 30-01-2001----------------------------------------------------//

#include "defs.qh"


//-- OFTEN --//
void() Wiz_Precache;
void() Field_Precache;
void () UpdateInfos;
//==============//

void() InitBodyQue;
void() AddCommands;

void() main =
{
	dprint ("main function\n");
	
// these are just commands the the prog compiler to copy these files

	precache_file ("progs.dat");
	precache_file ("gfx.wad");
	precache_file ("quake.rc");
	precache_file ("default.cfg");

	precache_file ("end1.bin");
	precache_file2 ("end2.bin");

	precache_file ("demo1.dem");
	precache_file ("demo2.dem");
	precache_file ("demo3.dem");

//
// these are all of the lumps from the cached.ls files
//
	precache_file ("gfx/palette.lmp");
	precache_file ("gfx/colormap.lmp");

	precache_file2 ("gfx/pop.lmp");

	precache_file ("gfx/complete.lmp");
	precache_file ("gfx/inter.lmp");

	precache_file ("gfx/ranking.lmp");
	precache_file ("gfx/vidmodes.lmp");
	precache_file ("gfx/finale.lmp");
	precache_file ("gfx/conback.lmp");
	precache_file ("gfx/qplaque.lmp");

	precache_file ("gfx/menudot1.lmp");
	precache_file ("gfx/menudot2.lmp");
	precache_file ("gfx/menudot3.lmp");
	precache_file ("gfx/menudot4.lmp");
	precache_file ("gfx/menudot5.lmp");
	precache_file ("gfx/menudot6.lmp");

	precache_file ("gfx/menuplyr.lmp");
	precache_file ("gfx/bigbox.lmp");
	precache_file ("gfx/dim_modm.lmp");
	precache_file ("gfx/dim_drct.lmp");
	precache_file ("gfx/dim_ipx.lmp");
	precache_file ("gfx/dim_tcp.lmp");
	precache_file ("gfx/dim_mult.lmp");
	precache_file ("gfx/mainmenu.lmp");
	
	precache_file ("gfx/box_tl.lmp");
	precache_file ("gfx/box_tm.lmp");
	precache_file ("gfx/box_tr.lmp");
	
	precache_file ("gfx/box_ml.lmp");
	precache_file ("gfx/box_mm.lmp");
	precache_file ("gfx/box_mm2.lmp");
	precache_file ("gfx/box_mr.lmp");
	
	precache_file ("gfx/box_bl.lmp");
	precache_file ("gfx/box_bm.lmp");
	precache_file ("gfx/box_br.lmp");
	
	precache_file ("gfx/sp_menu.lmp");
	precache_file ("gfx/ttl_sgl.lmp");
	precache_file ("gfx/ttl_main.lmp");
	precache_file ("gfx/ttl_cstm.lmp");
	
	precache_file ("gfx/mp_menu.lmp");
	
	precache_file ("gfx/netmen1.lmp");
	precache_file ("gfx/netmen2.lmp");
	precache_file ("gfx/netmen3.lmp");
	precache_file ("gfx/netmen4.lmp");
	precache_file ("gfx/netmen5.lmp");
	
	precache_file ("gfx/sell.lmp");
	
	precache_file ("gfx/help0.lmp");
	precache_file ("gfx/help1.lmp");
	precache_file ("gfx/help2.lmp");
	precache_file ("gfx/help3.lmp");
	precache_file ("gfx/help4.lmp");
	precache_file ("gfx/help5.lmp");

	precache_file ("gfx/pause.lmp");
	precache_file ("gfx/loading.lmp");

	precache_file ("gfx/p_option.lmp");
	precache_file ("gfx/p_load.lmp");
	precache_file ("gfx/p_save.lmp");
	precache_file ("gfx/p_multi.lmp");

// sounds loaded by C code
	precache_sound ("misc/menu1.wav");
	precache_sound ("misc/menu2.wav");
	precache_sound ("misc/menu3.wav");

	precache_sound ("ambience/water1.wav");
	precache_sound ("ambience/wind2.wav");

// shareware
	precache_file ("maps/start.bsp");

	precache_file ("maps/e1m1.bsp");
	precache_file ("maps/e1m2.bsp");
	precache_file ("maps/e1m3.bsp");
	precache_file ("maps/e1m4.bsp");
	precache_file ("maps/e1m5.bsp");
	precache_file ("maps/e1m6.bsp");
	precache_file ("maps/e1m7.bsp");
	precache_file ("maps/e1m8.bsp");

// registered
	precache_file2 ("gfx/pop.lmp");

	precache_file2 ("maps/e2m1.bsp");
	precache_file2 ("maps/e2m2.bsp");
	precache_file2 ("maps/e2m3.bsp");
	precache_file2 ("maps/e2m4.bsp");
	precache_file2 ("maps/e2m5.bsp");
	precache_file2 ("maps/e2m6.bsp");
	precache_file2 ("maps/e2m7.bsp");

	precache_file2 ("maps/e3m1.bsp");
	precache_file2 ("maps/e3m2.bsp");
	precache_file2 ("maps/e3m3.bsp");
	precache_file2 ("maps/e3m4.bsp");
	precache_file2 ("maps/e3m5.bsp");
	precache_file2 ("maps/e3m6.bsp");
	precache_file2 ("maps/e3m7.bsp");

	precache_file2 ("maps/e4m1.bsp");
	precache_file2 ("maps/e4m2.bsp");
	precache_file2 ("maps/e4m3.bsp");
	precache_file2 ("maps/e4m4.bsp");
	precache_file2 ("maps/e4m5.bsp");
	precache_file2 ("maps/e4m6.bsp");
	precache_file2 ("maps/e4m7.bsp");
	precache_file2 ("maps/e4m8.bsp");

	precache_file2 ("maps/end.bsp");

	precache_file2 ("maps/dm1.bsp");
	precache_file2 ("maps/dm2.bsp");
	precache_file2 ("maps/dm3.bsp");
	precache_file2 ("maps/dm4.bsp");
	precache_file2 ("maps/dm5.bsp");
	precache_file2 ("maps/dm6.bsp");
};

void () edictticker_think =
{
	localcmd ("edictcount\n");
	self.nextthink = time + self.num_mines;
};

entity	lastspawn;

//=======================
/*QUAKED worldspawn (0 0 0) ?
Only used for the world entity.
Set message to the level name.
Set sounds to the cd track to play.

World Types:
0: medieval
1: metal
2: base
*/
//=======================
void() worldspawn =
{
	local string st; //WK
	local entity ticker;

	lastspawn = world = self;
	InitBodyQue ();

	last_team_no = 5;

	st = infokey(nil, "mapcfg");
	if (!(st == "0" || st == "off" || st == ""))
	{
		if (st == "1" || st == "on")
			st = "mapcfg";

		localcmd("exec mapcfg.cfg\n"); // generic stuff

		localcmd("exec \"");
		localcmd(st);
		localcmd("/");
		localcmd(infokey(nil, "map"));
		localcmd(".cfg\"\n");
	}

// custom map attributes
	st = infokey(nil, "*gamedir");
	if (st != "fortress")
	{
		if (st == "")
			localcmd("sv_gamedir fortress\n");
		else
			objerror("QW TF must be run with a gamedir of \"fortress\", not \""
					 + st + "\".\n");
	}
	
    //- OfteN globals -//
	UpdateInfos();
    debug_target=nil;
   	already_chosen_map = FALSE;
    triggered_cycle = FALSE;
    ////////////////////

	if (stof(infokey (nil, "edictticker")))
	{
		ticker = spawn();
		ticker.classname = "edictcount";
		ticker.nextthink = time + 5;
		ticker.think = edictticker_think;
		ticker.num_mines = stof(infokey (nil, "edictticker")); // I hate overloading, but I don't want to use a full thing just for this one stupid little hack.
	}

    // We set up Chris' Teamplay Plus Mode here cos that's fun
	/*st = infokey(nil, "chris");
	if (st == "on")
		chris = TRUE;
	else
		chris = stof(st);
		
	st = infokey(nil, "roundtime");
	roundtime = stof(st);
	if (!roundtime)
		roundtime = 300;
	
	roundstowin = 5;*/
    
	////////////////////////////////

	team_with_flag = 0;		//KK initial global sets

	// We load the masks from the map, overriding it with infokeys if
	// they exist
	st = infokey (nil, "friends1_mask");
	friends1_mask = stof (st ? st : self.noise1);
	st = infokey (nil, "friends2_mask");
	friends2_mask = stof (st ? st : self.noise2);
	st = infokey (nil, "friends3_mask");
	friends3_mask = stof (st ? st : self.noise3);
	st = infokey (nil, "friends4_mask");
	friends4_mask = stof (st ? st : self.noise4);


// the area based ambient sounds MUST be the first precache_sounds

// player precaches	
	W_Precache ();			// get weapon precaches

// sounds used from C physics code
	precache_sound ("demon/dland2.wav");		// landing thud
	precache_sound ("misc/h2ohit1.wav");		// landing splash

// setup precaches allways needed
	precache_sound ("items/itembk2.wav");		// item respawn sound
	precache_sound ("player/plyrjmp8.wav");		// player jump
	precache_sound ("player/land.wav");			// player landing
	precache_sound ("player/land2.wav");		// player hurt landing
	precache_sound ("player/drown1.wav");		// drowning pain
	precache_sound ("player/drown2.wav");		// drowning pain
	precache_sound ("player/gasp1.wav");		// gasping for air
	precache_sound ("player/gasp2.wav");		// taking breath
	precache_sound ("player/h2odeath.wav");		// drowning death

	precache_sound ("misc/talk.wav");			// talk
	precache_sound ("player/teledth1.wav");		// telefrag
	precache_sound ("misc/r_tele1.wav");		// teleport sounds
	precache_sound ("misc/r_tele2.wav");
	precache_sound ("misc/r_tele3.wav");
	precache_sound ("misc/r_tele4.wav");
	precache_sound ("misc/r_tele5.wav");
	precache_sound ("weapons/lock4.wav");		// ammo pick up
	precache_sound ("weapons/pkup.wav");		// weapon up
	precache_sound ("items/armor1.wav");		// armor up
	precache_sound ("weapons/lhit.wav");		//lightning
	precache_sound ("weapons/lstart.wav");		//lightning start
	precache_sound ("items/damage3.wav");

	precache_sound ("zombie/z_shot1.wav");		// For grenade

	precache_sound ("items/protect.wav");
	precache_sound ("items/protect2.wav");
	precache_sound ("items/protect3.wav");

	precache_sound ("misc/power.wav");			//lightning for boss

// player gib sounds
	precache_sound ("player/gib.wav");			// player gib sound
	precache_sound ("player/udeath.wav");		// player gib sound
	precache_sound ("player/tornoff2.wav");		// gib sound

// player pain sounds

	precache_sound ("player/pain1.wav");
	precache_sound ("player/pain2.wav");
	precache_sound ("player/pain3.wav");
	precache_sound ("player/pain4.wav");
	precache_sound ("player/pain5.wav");
	precache_sound ("player/pain6.wav");

// player death sounds
	precache_sound ("player/death1.wav");
	precache_sound ("player/death2.wav");
	precache_sound ("player/death3.wav");
	precache_sound ("player/death4.wav");
	precache_sound ("player/death5.wav");

// ax sounds	
	precache_sound ("weapons/ax1.wav");			// ax swoosh
	precache_sound ("player/axhit1.wav");		// ax hit meat
	precache_sound ("player/axhit2.wav");		// ax hit world

	precache_sound ("player/h2ojump.wav");		// player jumping into water
	precache_sound ("player/slimbrn2.wav");		// player enter slime
	precache_sound ("player/inh2o.wav");		// player enter water
	precache_sound ("player/inlava.wav");		// player enter lava
	precache_sound ("misc/outwater.wav");		// leaving water sound

	precache_sound ("player/lburn1.wav");		// lava burn
	precache_sound ("player/lburn2.wav");		// lava burn

	precache_sound ("misc/water1.wav");			// swimming
	precache_sound ("misc/water2.wav");			// swimming

	precache_model ("progs/player.mdl");
	precache_model ("progs/eyes.mdl");
	precache_model ("progs/h_player.mdl");
	precache_model ("progs/gib1.mdl");
	precache_model ("progs/gib2.mdl");
	precache_model ("progs/gib3.mdl");

	precache_model ("progs/s_bubble.spr");	// drowning bubbles
	precache_model ("progs/s_explod.spr");	// sprite explosion
	precache_model ("progs/s_light.spr");

	precache_model ("progs/v_axe.mdl");
	precache_model ("progs/v_shot.mdl");
	precache_model ("progs/v_nail.mdl");
	precache_model ("progs/v_rock.mdl");
	precache_model ("progs/v_shot2.mdl");
	precache_model ("progs/v_nail2.mdl");
	precache_model ("progs/v_rock2.mdl");
	precache_model ("progs/grenade.mdl");

	precache_model ("progs/bolt.mdl");		// for lightning gun
	precache_model ("progs/bolt2.mdl");		// for lightning gun
	precache_model ("progs/bolt3.mdl");		// for boss shock
	precache_model ("progs/lavaball.mdl");	// for testing
	
	precache_model ("progs/missile.mdl");
	precache_model ("progs/spike.mdl");
	precache_model ("progs/s_spike.mdl");

	precache_model ("progs/backpack.mdl");

	precache_model ("progs/zom_gib.mdl");
	precache_model ("progs/v_light.mdl");

	precache_model2 ("progs/laser.mdl");
	precache_sound2 ("enforcer/enfire.wav");
	precache_sound2 ("enforcer/enfstop.wav");
	precache_sound2 ("hknight/attack1.wav");

    //- OfN - Flare exp sound
    precache_sound2 ("items/flare1.wav");

    // Team Fortress Weapon MDLs
	precache_model2("progs/sight.spr");
//	precache_model2("progs/cross1.mdl");
    precache_model2("progs/v_medi.mdl");
    precache_model2("progs/v_bio.mdl");
	precache_model2("progs/hgren2.mdl");
	precache_model2("progs/biggren.mdl");

    //precache_model2("progs/lndmine.mdl"); 
    precache_model2("progs/flare.mdl");
    
	precache_model2("progs/v_srifle.mdl");
	precache_model2("progs/v_asscan.mdl");
	precache_model2("progs/detpack.mdl");
	precache_model2("progs/ammobox.mdl");
	precache_model2("progs/v_knife.mdl");	  // Spy's Knife
	precache_model2("progs/v_knife2.mdl");	  // Spy's Knife with Blood on it
	precache_model2("progs/v_span.mdl");	  // Engineer's Spanner
	precache_model2("progs/e_spike1.mdl");	  // Engineer's RailGun
	precache_model2("progs/e_spike2.mdl");	  // Engineer's RailGun
	precache_model2("progs/v_rail.mdl");   	  // Engineer's RailGun
	
    //precache_model2("progs/turrgun.mdl");	  // Sentry Gun
    
    //////////////////////////////////////////////////////
    precache_model2("progs/trrgn2.mdl");
    precache_sound2 ("weapons/sntr666.wav");
    precache_sound2 ("weapons/trr2lost.wav");

	//precache_model2("progs/turrbase.mdl");	  // Sentry Gun
    precache_model2("progs/trrbs2.mdl");	  // Sentry Gun

    //air-fist models and sounds--------//
    precache_model2("progs/v_airgun.mdl");
    precache_sound2("weapons/agfail.wav");
    precache_sound2("weapons/agwfail.wav");
    precache_sound2("weapons/agwater.wav");
    precache_sound2("weapons/agfire.wav");
    precache_model2("progs/s_ablast.spr");
    //----------------------------------//

    //laser cannon models and sounds---//
    precache_model2("progs/v_laserg.mdl");
    precache_model2("progs/lasrspik.mdl");    
    precache_sound2("weapons/laserric.wav");
    precache_sound2("weapons/laserg.wav");
    //-----------------------------------//

    //field gen precaches-------------//
    Field_Precache();
    //---------------------------------//

    //- OfN -
    precache_model2("progs/flarefly.mdl");
    precache_model2("progs/tesgib4.mdl");
  	precache_model ("progs/caltrop.mdl");		// A big, bad, caltrop

    precache_sound2("weapons/gren_emp.wav");    

	precache_model2("progs/t2gib1.mdl");		  // Sentry Gun Gib
	precache_model2("progs/t2gib2.mdl");		  // Sentry Gun Gib
	precache_model2("progs/t2gib3.mdl");		  // Sentry Gun Gib
  	
    //- extra gib
    precache_model2("progs/t2gib4.mdl");		  // Sentry Gun Gib
///////////////////////////////////////

    #ifdef no_new_dispenser
    precache_model2("progs/disp.mdl");		  // Tmp dispenser mdl
	precache_model2("progs/dgib1.mdl");		  // Dispenser Gib
	precache_model2("progs/dgib2.mdl");		  // Dispenser Gib
	precache_model2("progs/dgib3.mdl");		  // Dispenser Gib
    #else
    precache_model2("progs/disp2.mdl");		  // Tmp dispenser mdl
	precache_model2("progs/d2gib1.mdl");		  // Dispenser Gib
	precache_model2("progs/d2gib2.mdl");		  // Dispenser Gib
	precache_model2("progs/d2gib3.mdl");		  // Dispenser Gib
    #endif

	precache_model2("progs/grenade2.mdl");	  // New grenade
	precache_model2("progs/v_grap.mdl");	  // Grapple gun
	precache_model2("progs/hook.mdl");		  // Grapple hook
	if (headless==1)
       precache_model2("progs/headless.mdl");	  // Player with no head

    precache_model2("progs/sencer.mdl");

    precache_model2("progs/grunty.mdl");

    precache_model2("progs/tf_flag.mdl");
    precache_model2("progs/tf_stan.mdl");

    //- OfN
    Wiz_Precache();
    precache_sound2("weapons/detpack.wav");

	precache_sound2("speech/saveme1.wav");	  // Saveme Sound
	precache_sound2("speech/saveme2.wav");	  // Saveme Sound

    //- OfN sounds for flares and holo
    precache_sound2("effects/bodyhit1.wav");	  
    precache_sound2("effects/bodyhit2.wav");	

    //- OfN - Aura sounds
    precache_sound2("auras/aura1.wav");
    precache_sound2("auras/aura2.wav");
    precache_sound2("auras/aura3.wav");
    precache_sound2("auras/aura4.wav");
    
    //precache_sound2("weapons/pinpull.wav");
    //precache_sound2("weapons/throw.wav");

#ifdef SPEECH
	precache_sound2("speech/scout.wav");
	precache_sound2("speech/sniper.wav");
	precache_sound2("speech/soldier.wav");
	precache_sound2("speech/demoman.wav");
	precache_sound2("speech/medic.wav");
	precache_sound2("speech/hvyweap.wav");
	precache_sound2("speech/pyro.wav");
	precache_sound2("speech/spy.wav");
	precache_sound2("speech/engineer.wav");

	precache_sound2("speech/demo_dp.wav");
#endif
	

//
// Setup light animation tables. 'a' is total darkness, 'z' is maxbright.
//

	// 0 normal
	lightstyle(0, "m");
	
	// 1 FLICKER (first variety)
	lightstyle(1, "mmnmmommommnonmmonqnmmo");
	
	// 2 SLOW STRONG PULSE
	lightstyle(2, "abcdefghijklmnopqrstuvwxyzyxwvutsrqponmlkjihgfedcba");
	
	// 3 CANDLE (first variety)
	lightstyle(3, "mmmmmaaaaammmmmaaaaaabcdefgabcdefg");
	
	// 4 FAST STROBE
	lightstyle(4, "mamamamamama");
	
	// 5 GENTLE PULSE 1
	lightstyle(5,"jklmnopqrstuvwxyzyxwvutsrqponmlkj");
	
	// 6 FLICKER (second variety)
	lightstyle(6, "nmonqnmomnmomomno");
	
	// 7 CANDLE (second variety)
	lightstyle(7, "mmmaaaabcdefgmmmmaaaammmaamm");
	
	// 8 CANDLE (third variety)
	lightstyle(8, "mmmaaammmaaammmabcdefaaaammmmabcdefmmmaaaa");
	
	// 9 SLOW STROBE (fourth variety)
	lightstyle(9, "aaaaaaaazzzzzzzz");
	
	// 10 FLUORESCENT FLICKER
	lightstyle(10, "mmamammmmammamamaaamammma");

	// 11 SLOW PULSE NOT FADE TO BLACK
	lightstyle(11, "abcdefghijklmnopqrrqponmlkjihgfedcba");
	
	// styles 32-62 are assigned by the light program for switchable lights

	// 63 testing
	lightstyle(63, "a");

	AddCommands();
};

void() StartFrame =
{
	teamplay = cvar("teamplay");
	timelimit = cvar("timelimit") * 60;
	fraglimit = cvar("fraglimit");
	deathmatch = cvar("deathmatch");
	no_pogo_stick = cvar ("no_pogo_stick");
	framecount = framecount + 1;

	local string timeleft;
	timeleft = timelimit ? sprintf ("%.0f", (timelimit - time) / 60) : "";
	if (timeleft != infokey (nil, "timeleft"))
		localcmd ("serverinfo timeleft " + timeleft + "\n");
};

/*
==============================================================================

BODY QUE

==============================================================================
*/

entity	bodyque_head;

void() bodyque =
{	// just here so spawn functions don't complain after the world
	// creates bodyques
};


void() InitBodyQue =
{
	bodyque_head = spawn();
	bodyque_head.classname = "bodyque";
	bodyque_head.owner = spawn();
	bodyque_head.owner.classname = "bodyque";
	bodyque_head.owner.owner = spawn();
	bodyque_head.owner.owner.classname = "bodyque";
	bodyque_head.owner.owner.owner = spawn();
	bodyque_head.owner.owner.owner.classname = "bodyque";
	bodyque_head.owner.owner.owner.owner = bodyque_head;
};

// make a body que entry for the given ent so the ent can be
// respawned elsewhere
void(entity ent) CopyToBodyQue =
{
	bodyque_head.angles = ent.angles;
	bodyque_head.model = ent.model;
	bodyque_head.skin = ent.skin;
	bodyque_head.modelindex = ent.modelindex;
	bodyque_head.frame = ent.frame;
	bodyque_head.colormap = ent.colormap;
	bodyque_head.movetype = ent.movetype;
	bodyque_head.velocity = ent.velocity;
	bodyque_head.flags = 0;
	setorigin (bodyque_head, ent.origin);
	setsize (bodyque_head, ent.mins, ent.maxs);
	bodyque_head = bodyque_head.owner;
};


int(entity e) entpointcontents = {
	return hullpointcontents(world, e.mins, e.maxs, e.origin);
};

