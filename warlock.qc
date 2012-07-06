#include "defs.qh"
/*=======================================================//
// Warlock.QC - CustomTF 3.2.OfN           - 30/1/2001 - //
=========================================================//
 Warlock stuff
=========================================================*/

void() SummonThink; // external, used by demon menu thing
entity (vector location, float life, float type) CreateWaypoint; // Create a new grunty waypoint

//- OfN - Gets the name of monster class (shambler, fiend, scrag or soldier)
string(entity themonster) GetMonsterName;
void() MonsterTouch;
void(vector where) spawnFOG;

void (entity themonster) PutMonsterStand;
void (entity themonster) PutMonsterWalk;

//WK Done -----------------------------

// SB - demon summon menu

void() Menu_Demon =
{
	local string str1,st,st3,st2;
	
	str1 = ftos(self.demon_blood);

    //if (self.job & JOB_BLOODY_KNIFE)
    //    st2="ÛÂÌÏÏÄÝ";

	if (self.demon_one)
    {    
        custom_demon_name(self.demon_one);
        st=GetMonsterName(self.demon_one);
        CenterPrint6(self, self.demon_one.netname," ¼",st,"¾",
"\n\n Áãôéïî:                  \n\n“.. Come here, damn beast!   \n”.. Patrol the zone!         \n•.. Stop there!              \n\nš®® Unsummon!                \n\n’.. Îïôèéîç                  \n\nËîéæå Ëéììó: "
        , str1);
    }
    else
    {

        if (self.job & JOB_BLOODY_KNIFE)
           st="\n Áãôéïî:           \n\n“.. Summon Scrag      (âìïïä)";
        else
           st="\n Áãôéïî:           \n\n“.. Summon Scrag      (blood)";
                  
        if (self.demon_blood>1)
            st2="\n”.. Summon Fiend    (2 ëéììó)";
        else
            st2="\n”.. Summon Fiend    (2 kills)";

        /*if (self.demon_blood>0)
        {
            if (self.demon_blood>1)
                st2="\n”.. Summon Knight       (1 ëéììó)\n•.. Summon Fiend        (2 ëéììó)";
            else     
                st2="\n”.. Summon Knight       (1 ëéììó)\n•.. Summon Fiend        (2 kills)";
        }
        else     
        {
            if (self.demon_blood>1)
                st2="\n”.. Summon Knight       (1 kills)\n•.. Summon Fiend        (2 ëéììó)";
            else     
                st2="\n”.. Summon Knight       (1 kills)\n•.. Summon Fiend        (2 kills)";

        }*/


        /*if (self.demon_blood>2)
           st3="\n–.. Summon Hell Knight  (3 ëéììó)";
        else
           st3="\n–.. Summon Hell Knight  (3 kills)";*/

        if (self.demon_blood>3)
           st3="\n•.. Summon Shambler (4 ëéììó)";
        else
           st3="\n•.. Summon Shambler (4 kills)";
                  


        CenterPrint6(self, st,st2,st3,"\n\n’.. Îïôèéîç                  \n\nËîéæå Ëéììó: ", str1,"\^/" + ftos (MAX_KNIFE_BLOOD));

    }

    // Ignore enemy!
    // Engage enemy!


    //menu 2
    //health
    //frags
    //status
    //enemy
            
};

/*
** Warlock Profession -
** Hit an enemy with knife for blood, use that to summon a happy demon
*/
void() SummonThink =
{
	if (self.heat == 0)
	{
		self.heat = 1;
		stuffcmd(self.owner,"v_idlescale 0\n");
		self.nextthink = time + 1.5;
		return;
	}
	local entity oself;
	oself = self;
	self = self.owner;
	custom_demon_create(oself.has_tesla);
    spawnFOG(oself.origin);
 
    self = oself;
	dremove(self);
};

void(float inp) Menu_Demon_Input =
{
	local entity SummonTimer;
	local float points;

	self.demon_choice = 0; // reset demon choice var
	
    if (inp == 10) // nothing
	{	
		ResetMenu();
		self.impulse = 0;
        return;
	}
    if (inp == 1 && self.demon_one) // Come here!
    {	        
        if (!IsMonster(self.demon_one)) return;

		local string st;
        st=GetMonsterName(self.demon_one);
        
        self.demon_one.enemy=nil;//
	self.demon_one.oldenemy=nil;
        self.demon_one.goalentity=self;
	self.demon_one.movetarget=self;
        self.demon_one.nextthink=time+0.1;

        PutMonsterWalk(self.demon_one);

        sprint(self,PRINT_HIGH,"You call your ");
        sprint(self,PRINT_HIGH,st);
        sprint(self,PRINT_HIGH,".\n");
        ResetMenu();
        self.impulse=0;
        return;
	}
    else if (inp == 2 && self.demon_one) // patrol
	{	
		if (!IsMonster(self.demon_one)) return;

		local string st;
        st=GetMonsterName(self.demon_one);
        
	self.demon_one.enemy=nil;
        self.demon_one.oldenemy=nil;////
        self.demon_one.goalentity=self.demon_one;
	self.demon_one.movetarget=self.demon_one;
        self.demon_one.nextthink=time+0.1;
        
        PutMonsterWalk(self.demon_one);

        sprint(self,PRINT_HIGH,"Your ");
        sprint(self,PRINT_HIGH,st);
        sprint(self,PRINT_HIGH," will patrol the zone now...\n");

        ResetMenu();
        self.impulse=0;
        return;
	}
    else if (inp == 3 && self.demon_one) // stop there!
	{	
		if (!IsMonster(self.demon_one)) return;

		local string st;
        st=GetMonsterName(self.demon_one);
        
        self.demon_one.enemy=nil;//
        self.demon_one.oldenemy=nil;////
        self.demon_one.goalentity=nil;
	self.demon_one.movetarget=nil;
        self.demon_one.nextthink=time+0.1;
        
        PutMonsterStand(self.demon_one);

        ResetMenu();
        self.impulse=0;
        return;
	}
    else if (inp == 1) // scrag
	{	
		self.demon_choice = 1;
		ResetMenu();
		self.impulse = 0;
	}
	else if (inp == 2) // fiend
	{
		self.demon_choice = 2;
		ResetMenu();
		self.impulse = 0;

	}
	else if (inp >= 3 && inp < 8) // shambler
	{
		self.demon_choice = inp;
		ResetMenu();
		self.impulse = 0;
	}
	else if (inp == 8) // unsummon
	{
		if (self.job & JOB_DEMON_OUT)
	        {
	            local string MName;
	       	     MName=GetMonsterName(self.demon_one);    
	
       			teamprefixsprint(self.team_no, self);
       			teamsprint(self.team_no,self, self.netname);
			teamsprint(self.team_no,self, " unsummons his ");
    
            		teamsprint(self.team_no,self, MName);
            		teamsprint(self.team_no,self, "\n");

            		kill_my_demon();
        	}
        	else return;

        	ResetMenu();
		self.impulse = 0;
		return;
	}
    else
      return;
	

    if (self.job & JOB_DEMON_OUT)
    {
        sprint(self, PRINT_HIGH, "You already have a monster summoned.\n");
        //ResetMenu();
        self.impulse = 0;
        return;
    }	

#ifndef WARLOCK_TEST

    if (self.demon_blood < 8 && self.demon_choice >= 4)
    {
	self.impulse = 0;
	return;
    }

    if (self.demon_blood < 4 && self.demon_choice == 3)
    {
        sprint (self, PRINT_HIGH, "You need to kill 4 enemies with your knife to summon a shambler.\n");
        //ResetMenu();
        self.impulse = 0;
        return;
    } // temp

/*    if (self.demon_blood < 3 && self.demon_choice == 4)
    {
        sprint (self, PRINT_HIGH, "You need to kill 4 enemies with your knife to summon a hell knight.\n");
        //ResetMenu();
        self.impulse = 0;
        return;
    } // temp*/

    if (self.demon_blood < 2 && self.demon_choice == 2)
    {
        sprint (self, PRINT_HIGH, "You need to kill 2 enemies with your knife to summon a fiend.\n");
        //ResetMenu();
        self.impulse = 0;
        return;
    }

    /*if (self.demon_blood < 1 && self.demon_choice == 2)
    {
        sprint (self, PRINT_HIGH, "You need to kill 1 enemies with your knife to summon a knight.\n");
        //ResetMenu();
        self.impulse = 0;
        return;
    } // temp*/

    if (!(self.job & JOB_BLOODY_KNIFE) && self.demon_choice == 1)
    {
        sprint(self,PRINT_HIGH,"You have to get blood from an enemy to summon a scrag.\n");
        //ResetMenu();
        self.impulse = 0;
        return;
    }

#endif

    ResetMenu();

    //points = self.demon_blood;

    // TEMP
    points = 5;

    if (self.demon_choice == 5)
    {
	if (infokey(nil, "shamking") == "off")
	{
	    self.impulse = 0;
	    return;
	}
	points = 4 + self.demon_blood / 4;
	self.demon_blood = 0;
	self.demon_choice = 3;
    }
    else if (self.demon_choice == 4)
    {
	if (infokey(nil, "bsham") == "off")
	{
	    self.impulse = 0;
	    return;
	}
	points = 6;
	self.demon_blood = self.demon_blood - 8;
	self.demon_choice = 3;
    }	
    else if (self.demon_choice == 3)
        self.demon_blood = self.demon_blood - 4;
    else if (self.demon_choice == 2)
        self.demon_blood = self.demon_blood - 2;
    //else
    //	self.demon_blood = 0;
    
    if (self.job & JOB_BLOODY_KNIFE && self.demon_choice == 1)
        self.job = self.job - JOB_BLOODY_KNIFE; //- OfN - caused bug
    
    if (self.current_weapon == WEAP_AXE && self.demon_choice == 1)
    {
        self.weaponmode = 0; // Remove blood on the knife
        self.weaponmodel = "progs/v_knife.mdl";
    }

    stuffcmd(self,"v_idlescale 100000\n");

    //r = random(); //Random summon sounds. :)
    //if (r < 0.33) 
        sound (self, CHAN_WEAPON, "boss2/sight.wav", 1, ATTN_NORM);
    //else if (r < 0.66)
    //	sound (self, CHAN_WEAPON, "wizard/widle2.wav", 1, ATTN_NORM);
    //else
    //	sound (self, CHAN_WEAPON, "shambler/sdeath.wav", 1, ATTN_NORM);

    SummonTimer = spawn ();
    SummonTimer.classname = "timer";
    SummonTimer.owner = self;
    SummonTimer.nextthink = time + (points * 1.5) - 6 ; //Small delays are cool
    SummonTimer.think = SummonThink;
    SummonTimer.has_tesla = points;
    SummonTimer.heat = 0;
    self.job_finished = time + 5; //Delay if summon goes bad SB reduced to 5
    self.attack_finished = time + 2.1;

};
//====================================================//
//Returns a random name for a demon, or pulls it from one's localinfo
void(entity demon) custom_demon_name =
{
	local string happy = "FIXME:custom_demon_name";
	local float r;

	// Why doesn't this work? When people set their own names,
	//	the demon's name gets corrupted. Do we need a strcpy()?
	/*CH
	has_camera		0 = Ignore and set name as 'demon'
				1 = Using random name
				2 = Failed infokey, get random
				3 = Using Custom name
				4 = Set name when called
	*/
	if (demon.has_camera == 3 || demon.has_camera == 4) //CH // SB - if we have a d already, use rand name
	{
		happy = infokey(demon.real_owner,"demon");
		if (!happy)
			happy = infokey(demon.real_owner,"d");
		if (!happy)
			demon.has_camera = 2;
		else
			demon.has_camera = 3;
	}
	if (demon.has_camera == 2)
	{	
		//Make random name
		r = random();
		if ( demon.classname == "monster_demon1" )
		{
			//Make random name
			if (r < 0.1)
				happy = "The Fiend Lazarat";
			else if (r < 0.2)
				happy = "Lysanter of Blood";
			else if (r < 0.3)
				happy = "Childers Nightmare";
			else if (r < 0.4)
				happy = "Minion of Lesric";
			else if (r < 0.5)
				happy = "Archdemon Boris";
			else if (r < 0.6)
				happy = "Talon";
			else if (r < 0.7)
				happy = "Oathrender";
			else if (r < 0.8)
				happy = "The Fiend Roeder";
			else if (r < 0.9)
				happy = "The Fiend Warrek";
			else
				happy = "Mourning Breath";
		}
		else if ( demon.classname == "monster_army" )
		{
			if ( r < 0.1 )
				happy = "F.Lee";
			else if ( r < 0.2 )
				happy = "A.Hoffman";
			else if ( r < 0.3 )
				happy = "J.Garcia";
			else if ( r < 0.4 )
				happy = "H.Dail";
			else if ( r < 0.5 )
				happy = "R.Gustafson";
			else if ( r < 0.6 )
				happy = "F.Gump";
			else if ( r < 0.7 )
				happy = "A.McNab";
			else if ( r < 0.8 )
				happy = "C.Ryan";
			else if ( r < 0.9 )
				happy = "K.Johnson";
			else
				happy = "W.Kerney";
		}
		else if ( demon.classname == "monster_shambler" )
		{
			if (r < 0.2)
				happy = "Necrotopos";
			else if (r < 0.4)
				happy = "Gorgon";
			else if (r < 0.6)
				happy = "Ogroth";
			else if (r < 0.8)
				happy = "Krogoth";
			else
				happy = "Llama Crusher";
		}
        else if ( demon.classname == "monster_wizard" ) //- OfN -
		{
			if (r < 0.25)
                happy = "Dark Spawn";
            else if (r <0.5)
                happy = "White Poison";
            else if (r <0.75)
                happy = "Lorgrath";
            else happy = "Phitermos";
		}
        /*else if (demon.classname == "monster_knight" ) //- OfN -
		{
			if (r < 0.25)
                happy = "Frannege";
            else if (r <0.5)
                happy = "Jenobahg";
            else if (r <0.75)
                happy = "Crainmerg";
            else happy = "Biosenberg";
		}
        else if (demon.classname == "monster_hknight" ) //- OfN -
		{
			if (r < 0.25)
                happy = "Sir Heinmenberg";
            else if (r <0.5)
                happy = "Sir Grigben";
            else if (r <0.75)
                happy = "Sir Tossendor";
            else happy = "Sir Gennoveh";
		}*/

        demon.netname = happy;
		demon.has_camera = 1;
	}

	if (demon.has_camera == 0)
		happy = "demon";
	if (demon.has_camera != 1)
		demon.netname = happy;
};


void (float points) custom_demon_create = 
{
	//Play random summoning sound here
	//r = random();
	//if (r < 0.33)
	    sound (self, CHAN_VOICE, "ambience/thunder1.wav", 1, ATTN_NORM);
	//else if (r < 0.66)
	//    sound (self, CHAN_WEAPON, "boss1/sight1.wav", 1, ATTN_NORM);
	//else
	  //  sound (self, CHAN_WEAPON, "boss1/out1.wav", 1, ATTN_NORM);

	makevectors (self.v_angle);
	v_forward.z = 0;
	v_forward = normalize(v_forward) * 64;

	newmis = spawn();
	newmis.owner = newmis; //WK Self
	newmis.real_owner = self;
	
	if (self.demon_choice == 1)
	{
		newmis.classname = "monster_wizard";
		#ifdef no_tf_monsters    
        newmis.mdl = "progs/wizard.mdl";
        #else
        newmis.mdl = "progs/tf_wiz.mdl";
        #endif
	}
	/*else if (self.demon_choice == 2)
	{
		newmis.classname = "monster_knight";
        newmis.mdl = "progs/knight.mdl";        
	}*/
	else if (self.demon_choice == 2)
	{
        newmis.classname = "monster_demon1";
		#ifdef no_tf_monsters
        newmis.mdl = "progs/demon.mdl";
        #else
        newmis.mdl = "progs/tf_demon.mdl";
        #endif
	}
    /*else
	{
        newmis.classname = "monster_hknight";
        newmis.mdl = "progs/hknight.mdl";
	}*/
	else if (self.demon_choice >= 3)
	{
		newmis.classname = "monster_shambler";
		#ifdef no_tf_monsters
        newmis.mdl = "progs/shambler.mdl";
        #else
        newmis.mdl = "progs/tf_sham.mdl";
        #endif
	}
	
    // CHECK: why this was comented?
    newmis.team_no = self.team_no; //Go team red! ;)

    newmis.origin = self.origin + v_forward;
	newmis.has_camera = 4;
	custom_demon_name(newmis); //SB - Share and Enjoy - ceaf put health in here
	//setorigin (newmis, self.origin + v_forward*50 + '0 0 16');
	//setsize (newmis, VEC_HULL_MIN, VEC_HULL_MAX);
	if (!CheckArea(newmis,self)) { //No room for el diablo
		sprint(self,PRINT_HIGH,"Not enough room to summon creature!\n");
		newmis.think = SUB_Remove;
		newmis.nextthink = time + 0.1;
        //self.job &= ~JOB_DEMON_OUT); // FIXME - This shouldn't be needed - OfN done
		return;
	}

    if ( self.demon_choice == 1 )
	{
        #ifdef no_tf_monsters
        setmodel (newmis, "progs/wizard.mdl");
        #else
        setmodel (newmis, "progs/tf_wiz.mdl");
        #endif

        setsize (newmis, '-16 -16 -24', '16 16 40');
        setorigin (newmis, newmis.origin + '0 0 30');
	}
    /*else if ( self.demon_choice == 2 )
	{
        setmodel (newmis, "progs/knight.mdl");
        //setsize (self, '-16 -16 -24', '16 16 40');
        setsize (newmis, VEC_HULL2_MIN, VEC_HULL2_MAX);	
		setorigin (newmis, newmis.origin + '0 0 30');
	}*/
	else if ( self.demon_choice == 2 )
	{
		#ifdef no_tf_monsters
        setmodel (newmis, "progs/demon.mdl");
        #else
        setmodel (newmis, "progs/tf_demon.mdl");
		#endif
        
        setsize (newmis, VEC_HULL2_MIN, VEC_HULL2_MAX);	
		setorigin (newmis, newmis.origin + '0 0 30');
    }
	/*else if ( self.demon_choice == 4 )
	{
        setmodel (newmis, "progs/hknight.mdl");
        //setsize (self, '-16 -16 -24', '16 16 40');
        setsize (newmis, VEC_HULL2_MIN, VEC_HULL2_MAX);
		setorigin (newmis, newmis.origin + '0 0 30');
	}*/
    else  if (self.demon_choice >= 3)
    {
        #ifdef no_tf_monsters
        setmodel (newmis, "progs/shambler.mdl");
        #else
        setmodel (newmis, "progs/tf_sham.mdl");
        #endif

		setsize (newmis, VEC_HULL2_MIN, VEC_HULL2_MAX);
		setorigin (newmis, newmis.origin + '0 0 30');
    }

	
	//Test successful, so go ahead and finish summon

    #ifndef no_tf_monsters
    if (no_monstercolors)
      newmis.skin=0;      
    else
      newmis.skin=self.team_no;
    #endif
    
    newmis.ltime=time;
    
    local string MName;
    MName=GetMonsterName(newmis);    

    teamprefixsprint(self.team_no,self);
    teamsprint(self.team_no,self,self.netname);
	teamsprint(self.team_no,self," has summoned the ");
    
    teamsprint(self.team_no,self,MName);
    teamsprint(self.team_no,self," ");
	teamsprint(self.team_no,self,newmis.netname);
	teamsprint(self.team_no,self,"\n");


	self.job |= JOB_DEMON_OUT; 
	self.job_finished = time + 3;	//Don't let em kill demon for 15 secs.
									// SB 15 is tight; 10
									// 10 is tight; 5
                                    // OfN 5 is tight; 3 ;)
	
    if (self.demon_choice==2) 
        sound (self, CHAN_BODY, "demon/sight2.wav", 1, ATTN_NORM);    

	newmis.velocity = v_forward * 10;// + '0 0 250';
    newmis.angles = vectoangles(newmis.velocity);

	newmis.flags &= ~FL_ONGROUND;
    
    newmis.velocity = v_forward * 10;
    
    newmis.movetype = MOVETYPE_TOSS;
    newmis.solid = SOLID_SLIDEBOX;
	newmis.takedamage = DAMAGE_AIM;

    if (self.demon_choice==1)
    {
        newmis.velocity='0 0 0';
        newmis.movetype = MOVETYPE_STEP;
    }

	/*if ( newmis.classname == "monster_hknight" )
	{
		newmis.health = HKNIGHT_HP; //WK 300
		newmis.armorclass = AT_SAVEFIRE; //AT_SAVESHOT | AT_SAVEFIRE;
		newmis.last_saveme_sound = 0;

    	newmis.th_stand = hknight_stand1;
    	newmis.th_walk = hknight_walk1;
    	newmis.th_run = hknight_run1;
    	newmis.th_melee = hknight_melee;
    	newmis.th_missile = hknight_magicc1;
    	newmis.th_pain = hknight_pain;
    	newmis.th_die = hknight_die;
        
        newmis.think = walkmonster_start;
		newmis.nextthink = time + 1;
		//newmis.touch = Demon_JumpTouch;
		
        //newmis.touch = nil;

   		sprint(self, PRINT_HIGH, "You summon a hell knight.\n");
	}
    else if ( newmis.classname == "monster_knight" )
	{
		newmis.health = KNIGHT_HP; //WK 300
		newmis.armorclass = AT_SAVEFIRE; //AT_SAVESHOT | AT_SAVEFIRE;
		newmis.last_saveme_sound = 0;

    	newmis.th_stand = knight_stand1;
    	newmis.th_walk = knight_walk1;
    	newmis.th_run = knight_run1;
    	newmis.th_melee = knight_atk1;
    	newmis.th_pain = knight_pain;
    	newmis.th_die = knight_die;

		newmis.think = walkmonster_start;
		newmis.nextthink = time + 1;
		//newmis.touch = Demon_JumpTouch;
		
        //newmis.touch = nil;

   		sprint(self, PRINT_HIGH, "You summon a knight.\n");
	}*/
    if ( newmis.classname == "monster_demon1" )
	{
		newmis.health = DEMON_HP; //WK 300
		newmis.armorclass = AT_SAVEFIRE; //AT_SAVESHOT | AT_SAVEFIRE;
		newmis.last_saveme_sound = 0;
		newmis.has_tesla = 0; //CH determines if jello jump
		newmis.has_sentry = 0; //CH stuck jump
		newmis.th_stand = demon1_stand1;
		newmis.th_walk = demon1_walk1;
		newmis.th_run = demon1_run1;
		newmis.th_die = custom_demon_die;
		newmis.th_melee = Demon_MeleeAttack;		// one of two attacks
		newmis.th_missile = demon1_jump1;			// jump attack
		newmis.th_pain = demon1_pain;
		newmis.th_fireball = demon1_fire1; //CH
		newmis.think = walkmonster_start;
		newmis.nextthink = time + 1;
		//newmis.touch = Demon_JumpTouch;
		
        //newmis.touch = nil;

   		sprint(self, PRINT_HIGH, "You summon a fiend.\n");
	}
	else if ( newmis.classname == "monster_shambler" )
	{
		newmis.health = (points * 2200) - 7000; //750 + points * 350; //WK 300
		if (newmis.health < 300) newmis.health = 300;
		newmis.armorclass = AT_SAVEEXPLOSION;// ofn- AT_SAVEEXPLOSION | AT_SAVEMELEE;
		newmis.last_saveme_sound = 0;
		newmis.has_tesla = points;
		newmis.has_sentry = 0;
		newmis.has_fieldgen = 0;
		newmis.th_stand = sham_stand1;
		newmis.th_walk = sham_walk1;
		newmis.th_run = sham_run;
		newmis.th_die = custom_shambler_die;
		newmis.th_melee = sham_melee;		// one of two attacks
		newmis.th_missile = sham_magic1;
		newmis.th_pain = sham_pain;
		newmis.th_fireball = sham_fireball; //- OfN - this, uglyness apart, didn't work anyway
		newmis.think = walkmonster_start;
		newmis.nextthink = time + 1;
		//newmis.touch = Demon_JumpTouch;
		//newmis.touch = nil;
		////newmis.real_owner.demon_blood = 0; marduk bug
		if (newmis.has_tesla > 6)
			sprint (self, PRINT_HIGH, "You summon a shambler king.\n");
		else if (newmis.has_tesla == 6)
			sprint (self, PRINT_HIGH, "You summon a battle shambler.\n");
		else
			sprint(self, PRINT_HIGH, "You summon a shambler.\n");
	}
	else
	{
        
        newmis.health = SCRAG_HP;
		newmis.think =flymonster_start_go;// walkmonster_start;
        newmis.th_stand = wiz_stand1;
	    newmis.th_walk = wiz_walk1;
	    newmis.th_run = wiz_run1;
	    newmis.th_missile = Wiz_Missile;
    	newmis.th_pain = Wiz_Pain;
	    newmis.th_die = wiz_die;

		newmis.nextthink = time + 0.05;
		//newmis.armorclass = 0; //- OfN - none AT_SAVESHOT; // kevlar
		newmis.last_saveme_sound = 0; // ? oh that
		//newmis.touch = nil;

		sprint(self, PRINT_HIGH, "You summon a scrag.\n");

    }

    newmis.touch=MonsterTouch;
    newmis.is_malfunctioning = 0;

    newmis.message = "XX"; // flag to identify monsters/army for sentry targetting

	newmis.real_owner.demon_one = newmis;
	newmis.max_health = newmis.health;
};

void () custom_demon_precache =
{
	#ifdef no_tf_monsters
    precache_model ("progs/demon.mdl");
    #else
    precache_model ("progs/tf_demon.mdl");
    #endif

	precache_model ("progs/h_demon.mdl");

	precache_sound ("demon/ddeath.wav");
	precache_sound ("demon/dhit2.wav");
	precache_sound ("demon/djump.wav");
	precache_sound ("demon/dpain1.wav");
	precache_sound ("demon/idle1.wav");
	precache_sound ("demon/sight2.wav");

	precache_model ("progs/soldier.mdl");
	precache_model ("progs/h_guard.mdl");
	precache_model ("progs/gib1.mdl");
	precache_model ("progs/gib2.mdl");
	precache_model ("progs/gib3.mdl");

	precache_sound ("soldier/death1.wav");
	precache_sound ("soldier/idle.wav");
	precache_sound ("soldier/pain1.wav");
	precache_sound ("soldier/pain2.wav");
	precache_sound ("soldier/sattck1.wav");
	precache_sound ("soldier/sight1.wav");
	
	#ifdef no_tf_monsters
    precache_model ("progs/shambler.mdl");
    #else
    precache_model ("progs/tf_sham.mdl");
    #endif

	precache_model ("progs/s_light.mdl");
	precache_model ("progs/h_shams.mdl");
	precache_model ("progs/bolt.mdl");
	
	precache_sound ("shambler/sattck1.wav");
	precache_sound ("shambler/sboom.wav");
	precache_sound ("shambler/sdeath.wav");
	precache_sound ("shambler/shurt2.wav");
	precache_sound ("shambler/sidle.wav");
	precache_sound ("shambler/ssight.wav");
	precache_sound ("shambler/melee1.wav");
	precache_sound ("shambler/melee2.wav");
	precache_sound ("shambler/smack.wav");

	//Also use ambience/thunder1 for out of knife
	precache_sound ("boss1/sight1.wav"); //Out of knife
	precache_sound ("boss1/out1.wav"); //Out of knife
	precache_sound ("boss2/sight.wav"); //Summon
//	precache_sound ("wizard/widle2.wav"); //Summon - OfN cacheed on wizard.qc
	precache_sound ("shambler/sdeath.wav"); //Summon

    //------------------------------------//
    /*precache_model ("progs/knight.mdl");
	precache_model ("progs/h_knight.mdl");

	precache_sound ("knight/kdeath.wav");
	precache_sound ("knight/khurt.wav");
	precache_sound ("knight/ksight.wav");
	precache_sound ("knight/sword1.wav");
	precache_sound ("knight/sword2.wav");
	precache_sound ("knight/idle.wav");
    //----------------------------------//


    precache_model2 ("progs/hknight.mdl");
	precache_model2 ("progs/k_spike.mdl");
	precache_model2 ("progs/h_hellkn.mdl");

	
	precache_sound2 ("hknight/attack1.wav");
	precache_sound2 ("hknight/death1.wav");
	precache_sound2 ("hknight/pain1.wav");
	precache_sound2 ("hknight/sight1.wav");
	precache_sound ("hknight/hit.wav");		// used by C code, so don't sound2
	precache_sound2 ("hknight/slash1.wav");
	precache_sound2 ("hknight/idle.wav");
	precache_sound2 ("hknight/grunt.wav");

	precache_sound ("knight/sword1.wav");
	precache_sound ("knight/sword2.wav");*/

};
void () kill_my_demon;

void (entity player) kill_his_demon = 
{
   if (player.classname!="player") return;
   
   local entity temp;

   temp=self;

   self=player;
   kill_my_demon();

   self=temp;
};


void () kill_my_demon = 
{
	local entity te;
	local entity oself;
	//WK Clean up demons
	te = find(nil, classname, "monster_demon1");
	while (te)
	{
		if (te.real_owner == self) {
			oself = self;
			self = te;
			
            //Must get... blood....
			ThrowGib ("progs/h_demon.mdl", -100);
			ThrowGib ("progs/gib1.mdl", -10);
            ThrowGib ("progs/gib2.mdl", -70);
            ThrowGib ("progs/gib3.mdl", -80);
            
			sound (self, CHAN_VOICE, "demon/ddeath.wav", 1, ATTN_NORM);
			self = oself;
			te.think = SUB_Remove;
			te.touch = nil;
			te.nextthink = time + 0.1;

			sprint(self, PRINT_HIGH, "Your fiend is dead.\n");
			self.job &= ~JOB_DEMON_OUT;
		}

		te = find(te, classname, "monster_demon1");
	}
	
	te = find(nil, classname, "monster_army");
	
	while (te)
	{
		if (te.real_owner == self && !te.is_malfunctioning)
		{
			oself = self;
			self = te;
			self.health = -100;
			//Must get... blood....
			ThrowGib ("progs/h_guard.mdl", -100);
			ThrowGib ("progs/gib1.mdl", -10);
			ThrowGib ("progs/gib2.mdl", -70);
            ThrowGib ("progs/gib3.mdl", -70);
            ThrowGib ("progs/gib2.mdl", -70);
			sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
//			custom_grunt_die;
			te.think = SUB_Remove;
			te.touch = nil;
			te.nextthink = time + 0.1;

            //-----------------------// NOT NEEDED
            /*te.th_stand = dont_think;
            te.th_run = dont_think;
            te.th_missile = dont_think;
            te.th_pain = dont_think;*/
            //--------------------------//


/*			if (self.martyr_enemy)
				dremove(self.martyr_enemy);

            if (self.demon_one)
				dremove(self.demon_one);
			

            if (self.demon_two)
				dremove(self.demon_two);
*/

        if (self.martyr_enemy)
		#ifdef ARMY_DEBUG
        RemoveWaypoint(self.martyr_enemy, "KillMyDemon() martyr", self);
        #else
        RemoveWaypoint(self.martyr_enemy, self);
        #endif
        
        //dremove(self.martyr_enemy);
	    
        if (self.demon_one)
		#ifdef ARMY_DEBUG
        RemoveWaypoint(self.demon_one, "KillMyDemon() demon_one", self);
        #else
        RemoveWaypoint(self.demon_one, self);
        #endif
        
        //dremove(self.demon_one);
	    
        if (self.demon_two)
		
        #ifdef ARMY_DEBUG
        RemoveWaypoint(self.demon_two, "KillMyDemon() demon_two", self);
        #else
        RemoveWaypoint(self.demon_two, self);
        #endif

            //dremove(self);// needed? to avoid false drown death bug_? nope

			self = oself;
                                        //grunt
			sprint (self, PRINT_HIGH, "Your soldier is dead.\n");
			self.job &= ~JOB_DEMON_OUT;

            self.demon_one = nil;
            SetArmyTimer();
			//TF_T_Damage(te, nil, nil, 4000, 0, 0);
		}

		te = find(te, classname, "monster_army");
	}

	/*te = find(nil, classname, "monster_knight");
	
	while (te)
	{
		if (te.real_owner == self)
		{
			oself = self;
			self = te;
			ThrowGib ("progs/h_knight.mdl", -100);
			ThrowGib ("progs/gib1.mdl", -10);
			ThrowGib ("progs/gib3.mdl", -30);
			ThrowGib ("progs/gib3.mdl", -70);
			sound (self, CHAN_VOICE, "knight/kdeath.wav", 1, ATTN_NORM);
            
			//sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
			te.think = SUB_Remove;
			te.touch = nil;
			te.nextthink = time + 0.1;
			self = oself;

			//self.job &= ~JOB_DEMON_OUT);
			sprint (self, PRINT_HIGH, "Your knight is dead.\n");
			//TF_T_Damage(te, nil, nil, 4000, 0, 0);
		}
		te = find(te, classname, "monster_knight");
	}

    te = find(nil, classname, "monster_hknight");
	
	while (te)
	{
		if (te.real_owner == self)
		{
			oself = self;
			self = te;
			ThrowGib ("progs/h_hellkn.mdl", -100);
			ThrowGib ("progs/gib1.mdl", -10);
			ThrowGib ("progs/gib3.mdl", -30);
			ThrowGib ("progs/gib3.mdl", -70);
			sound (self, CHAN_VOICE, "hknight/death1.wav", 1, ATTN_NORM);
			te.think = SUB_Remove;
			te.touch = nil;
			te.nextthink = time + 0.1;
			self = oself;

			//self.job &= ~JOB_DEMON_OUT);
			sprint (self, PRINT_HIGH, "Your hell knight is dead.\n");
			//TF_T_Damage(te, nil, nil, 4000, 0, 0);
		}
		te = find(te, classname, "monster_hknight");
	}*/
    
    te = find(nil, classname, "monster_shambler");
	
	while (te)
	{
		if (te.real_owner == self)
		{
				oself = self;
				self = te;
				ThrowGib ("progs/h_shams.mdl", -100);
				ThrowGib ("progs/gib1.mdl", -10);
				ThrowGib ("progs/gib3.mdl", -30);
				ThrowGib ("progs/gib3.mdl", -70);
				sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
				te.think = SUB_Remove;
				te.touch = nil;
				te.nextthink = time + 0.1;
				self = oself;	

				//self.job &= ~JOB_DEMON_OUT);
				sprint (self, PRINT_HIGH, "Your shambler is dead.\n");
				//TF_T_Damage(te, nil, nil, 4000, 0, 0);
		}
		te = find(te, classname, "monster_shambler");
	}

    
    te = find(nil, classname, "monster_wizard");
	
	while (te)
	{
		if (te.real_owner == self)
		{
			oself = self;
			self = te;
			ThrowGib ("progs/h_wizard.mdl", -100);
			ThrowGib ("progs/gib1.mdl", -10);
			ThrowGib ("progs/gib3.mdl", -30);
			ThrowGib ("progs/gib3.mdl", -70);
			sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
			te.think = SUB_Remove;
			te.touch = nil;
			te.nextthink = time + 0.1;
			self = oself;


			sprint (self, PRINT_HIGH, "Your scrag is dead.\n");
			//TF_T_Damage(te, nil, nil, 4000, 0, 0);
		}
		te = find(te, classname, "monster_wizard");
	}   


    	self.job &= ~JOB_DEMON_OUT;
    	self.demon_one = nil;

    	self.summon_one = nil;
	self.summon_two = nil;
};

void() MonsterTouch =
{
/*    if (self.real_owner==other && self.health > 0) // if it is our monster
    {
        if (self.goalentity==other) // if it was following us
        {
            self.goalentity=self; //stop it
            self.nextthink=time+0.1;
            PutMonsterStand(self);
        }
    } */
};

//===================================================//
void (entity themonster) PutMonsterStand =
{
    if (themonster.classname=="monster_shambler")
        themonster.think=sham_stand1;
    else if (themonster.classname=="monster_demon1")
        themonster.think=demon1_stand1;
    else if (themonster.classname=="monster_wizard")
        themonster.think=wiz_stand1;     
    /*else if (themonster.classname=="monster_knight")
        themonster.think=knight_stand1;   
    else if (themonster.classname=="monster_hknight")
        themonster.think=hknight_stand1;   */
};

void (entity themonster) PutMonsterWalk =
{
    if (themonster.classname=="monster_shambler")
        themonster.think=sham_walk1;
    else if (themonster.classname=="monster_demon1")
        themonster.think=demon1_walk1;
    else if (themonster.classname=="monster_wizard")
        themonster.think=wiz_walk1;     
    
    /*else if (themonster.classname=="monster_knight")
        themonster.think=knight_walk1;   
    else if (themonster.classname=="monster_hknight")
        themonster.think=hknight_walk1;*/
};

//============================================================================
// OfN - Called everytime a monster dies on die think, has_holo is set to 0

void (entity player) UpdateSummons =
{
    // are we a player?
    if (player.classname != "player")
    {
        RPrint("Non-player entity in UpdateSummons()\n");
        return;
    }

    // are we a warlock?
    if (!(player.job & JOB_WARLOCK))
    {
        RPrint("Non-warlock player in UpdateSummons()\n");
        return;
    }

    // Update our first summon
    if (player.summon_one)
    {
        if (!IsMonster(player.summon_one))
        {
            RPrint("Non-monster in .summon_one in UpdateSummons()\n");
            return;
        }
        
        if (player.summon_one.has_holo == 0) // set to 0 on die thinks
            player.summon_one = nil;
    }

    // Update our second summon
    if (player.summon_two)
    {
        if (!IsMonster(player.summon_two))
        {
            RPrint("Non-monster for .summon_two in UpdateSummons()\n");
            return;
        }
        
        if (player.summon_two.has_holo == 0) // set to 0 on die thinks
            player.summon_two = nil;
    }

};
