#include "defs.qh"
/*=======================================================//
// mtfents.QC - CustomTF 3.2.OfN           - 30/1/2001 - //
// by Sergio Fumaña Grunwaldt - OfteN aka superCOCK2000  //
=========================================================//
 
 I'll add mega-tf map entities support here
 sure there are differences.

=========================================================*/

void() ambient_sound =
{
	/*if (CheckExistence() == FALSE)
	{
		dremove(self);
		return;
	}*/

    if (self.noise)
	{
        if (self.volume == 0)
            self.volume = 1;

        precache_sound(self.noise);
	    precache_sound2(self.noise);

    	ambientsound (self.origin, self.noise, self.volume, ATTN_NORM);
    }
    else
        dremove(self);

};

void() ers_think =
{
    local float nextsound;
    nextsound = self.option + random()*(self.option2 - self.option);

    self.nextthink = time + nextsound;

    if (self.noise=="weaponfire")
    {
        local float fsound;
        local string thesound;
        fsound = random();
        if (fsound < 0.20)
            thesound="effects/explode1.wav";
        else if (fsound < 0.40)
            thesound="effects/explode2.wav";
        else if (fsound < 0.60)
            thesound="effects/minigun.wav";
        else if (fsound < 0.80)
            thesound="effects/m60.wav";
        else
            thesound="effects/rocket.wav";
        
      	sound(self, CHAN_MISC, thesound, self.volume, ATTN_NORM);
    }
    else
      	sound(self, CHAN_MISC, self.noise, self.volume, ATTN_NORM);
};

void() effect_random_sound =
{
	/*if (CheckExistence() == FALSE)
	{
		dremove(self);
		return;
	}*/

    if (self.noise)
	{
        if (self.volume == 0)
            self.volume = 1;

        precache_sound(self.noise);
	    //precache_sound2(self.noise);

        if (self.option==0)
            self.option=5;
        if (self.option2==0)
            self.option2=10;       
        if (self.option > self.option2)
            self.option = self.option2;

        local float nextsound;
        nextsound = self.option + random()*(self.option2 - self.option);

        self.think = ers_think;
        self.nextthink = time + nextsound;

    	//sound(self, CHAN_MISC, self.noise, self.volume, ATTN_NORM);
    }
    else
        dremove(self);

};

void() ambient_jungle =
{
	/*if (CheckExistence() == FALSE)
	{
		dremove(self);
		return;
	}*/
    if (self.volume == 0)
      self.volume = 1;

	precache_sound ("ambience/jungle.wav");
	ambientsound (self.origin, "ambience/jungle.wav", self.volume, ATTN_NORM);
};

void() ambient_diesel =
{
    if (self.volume == 0)
      self.volume = 1;

	precache_sound ("ambience/diesel.wav");
	ambientsound (self.origin, "ambience/diesel.wav", self.volume, ATTN_NORM);
};

void() ambient_chopper =
{
    if (self.volume == 0)
      self.volume = 1;

	precache_sound ("ambience/chopper.wav");
	ambientsound (self.origin, "ambience/chopper.wav", self.volume, ATTN_NORM);
};

void() ambient_eerie =
{
    if (self.volume == 0)
      self.volume = 1;

	precache_sound ("ambience/eerie.wav");
	ambientsound (self.origin, "ambience/eerie.wav", self.volume, ATTN_NORM);
};

void() ambient_ocean =
{
    if (self.volume == 0)
      self.volume = 1;

	precache_sound ("ambience/ocean.wav");
	ambientsound (self.origin, "ambience/ocean.wav", self.volume, ATTN_NORM);
};

void() ambient_peakwind =
{
    if (self.volume == 0)
      self.volume = 1;

	precache_sound ("ambience/peakwind.wav");
	ambientsound (self.origin, "ambience/peakwind.wav", self.volume, ATTN_NORM);
};

void() ambient_lavapit =
{
    if (self.volume == 0)
      self.volume = 1;

	precache_sound ("ambience/lavapit.wav");
	ambientsound (self.origin, "ambience/lavapit.wav", self.volume, ATTN_NORM);
};

void() ambient_unholy =
{
    if (self.volume == 0)
      self.volume = 1;

	precache_sound ("ambience/unholy.wav");
	ambientsound (self.origin, "ambience/unholy.wav", self.volume, ATTN_NONE);
};

void() ambient_flagflap =
{
    if (self.volume == 0)
      self.volume = 1;

	precache_sound ("ambience/flagflap.wav");

    /*local float attn_value;
    if (self.option == 0)
        attn_value = ATTN_STATIC; // default is ATTN_STATIC
    else attn_value = ATTN_NORM; // used in ditch2*/

	ambientsound (self.origin, "ambience/flagflap.wav", self.volume, ATTN_NORM); // 
};

void() ambient_high_wind =
{
    if (self.volume == 0)
      self.volume = 1;

	precache_sound ("ambience/2windy.wav");
	ambientsound (self.origin, "ambience/2windy.wav", self.volume, ATTN_NORM);
};

void() ambient_meadow =
{
    if (self.volume == 0)
      self.volume = 1;

	precache_sound ("ambience/meadow.wav");
	ambientsound (self.origin, "ambience/meadow.wav", self.volume, ATTN_NORM);
};

void() ambient_brook =
{
    if (self.volume == 0)
      self.volume = 1;

    local float attn_value;
    if (self.option == 0)
        attn_value = ATTN_NORM; // default is ATTN_NORM
    else attn_value = ATTN_IDLE; // used in ditch2

	precache_sound ("ambience/brook.wav");
	ambientsound (self.origin, "ambience/brook.wav", self.volume, attn_value);
};

void() ambient_ice_moving =
{
    if (self.volume == 0)
      self.volume = 1;

	precache_sound ("ambience/icemove.wav");
	ambientsound (self.origin, "ambience/icemove.wav", self.volume, ATTN_NORM);
};

void() ambient_nightpond =
{
    if (self.volume == 0)
      self.volume = 1;

	precache_sound ("ambience/nitepond.wav");
	ambientsound (self.origin, "ambience/nitepond.wav", self.volume, ATTN_NORM);
};

void() ambient_alert =
{
    if (self.volume == 0)
      self.volume = 1;

	precache_sound ("ambience/redalert.wav");
	ambientsound (self.origin, "ambience/redalert.wav", self.volume, ATTN_NONE);
};

void() ambient_chant =
{
    if (self.volume == 0)
      self.volume = 1;

	precache_sound ("ambience/chant.wav");
	ambientsound (self.origin, "ambience/chant.wav", self.volume, ATTN_NORM);
};

void() ambient_onboard =
{
    if (self.volume == 0)
      self.volume = 1;

	precache_sound ("ambience/onboard.wav");
	ambientsound (self.origin, "ambience/onboard.wav", self.volume, ATTN_NONE);
};

void() ambient_rocket_engine =
{
    if (self.volume == 0)
      self.volume = 1;

	precache_sound ("ambience/onboard.wav");
	ambientsound (self.origin, "ambience/onboard.wav", self.volume, ATTN_NORM);
};

void() ambient_weaponfire =
{
    precache_sound("effects/explode1.wav");
    precache_sound("effects/explode2.wav");
    precache_sound("effects/minigun.wav");
    precache_sound("effects/m60.wav");
    precache_sound("effects/rocket.wav");
	    //precache_sound2(self.noise);

    if (self.volume == 0)
      self.volume = 1;

    if (self.option==0)
        self.option=5;
    if (self.option2==0)
        self.option2=10;       
    if (self.option > self.option2)
        self.option = self.option2;

    self.noise="weaponfire";

    local float nextsound;
    nextsound = self.option + random()*(self.option2 - self.option);

    self.think = ers_think;
    self.nextthink = time + nextsound;

};

// TODO:

/*void() rf_splash =
{
    
};*/

void() rf_touch =
{
    if (other.classname!="player" || self.pain_finished > time) return;

    if (other.cutf_items & CUTF_STEALTH) return; // if we got stealth doesnt make the sound

    self.pain_finished = time + 6 + 6*random();
    self.solid = SOLID_TRIGGER;  

    if (other.velocity == '0 0 0')
        return;

    sound (self, CHAN_MISC, "effects/rockfall.wav", 0.5, ATTN_NORM);
};

void() effect_rockfall =
{
    precache_sound("effects/rockfall.wav");
    setsize (self, '-20 -20 -20', '20 20 20');
    self.touch = rf_touch;
    self.solid = SOLID_TRIGGER;
    setorigin (self, self.origin);
};

void()	ab_exp1	=[	0,		ab_exp2	] 
{
    local string thesound;

    if (random() < 0.65)
       thesound="effects/explode1.wav";
    else thesound="effects/explode2.wav";

    sound(self, CHAN_MISC, thesound, self.owner.volume, ATTN_NONE);

};
void()	ab_exp2	=[	1,		ab_exp3	] {};
void()	ab_exp3	=[	2,		ab_exp4	] {};
void()	ab_exp4	=[	3,		ab_exp5	] {};
void()	ab_exp5	=[	4,		ab_exp6	] {};
void()	ab_exp6	=[	5,		SUB_Remove	] {};


void() ab_think =
{
    local float nextburst;
    //local string thesound;
    nextburst = self.option + random()*(self.option2 - self.option);
    self.nextthink = time + nextburst;

    // Generate the explosion entity: //
    newmis=spawn();
    setmodel (newmis, "progs/s_explod.spr");
    newmis.origin_z = self.origin_z;
    newmis.origin_x = self.origin_x - 300 + random()*600;
    newmis.origin_y = self.origin_y - 300 + random()*600;
    setorigin(newmis,newmis.origin);
    newmis.solid = SOLID_NOT; // NEEDED?
    newmis.nextthink = time;
    newmis.think = ab_exp1;
    newmis.owner = self;        
    newmis.touch = SUB_Null;

    newmis.movetype = MOVETYPE_FLY;
    newmis.velocity = '0 0 300';
    newmis.effects = EF_BRIGHTLIGHT;
 	
};

void() effect_airburst =
{
    precache_model ("progs/s_explod.spr");

    precache_sound("effects/explode1.wav");
    precache_sound("effects/explode2.wav");    

    if (self.option==0)
        self.option=5;
    if (self.option2==0)
        self.option2=10;       

    if (self.option > self.option2)
        self.option = self.option2;

    self.noise="weaponfire";

    if (self.volume == 0)
      self.volume = 1;

    local float nextburst;
    nextburst = self.option + random()*(self.option2 - self.option);

    self.think = ab_think;
    self.nextthink = time + nextburst;
};

//- THIS IS FROM HYPNOTIC -//
void() bobbingwater_think =
{
   local vector ang;

   self.count = self.count + self.speed * ( time - self.ltime );
   
   if ( self.count > 360 )
   {
      self.count = self.count - 360;
   }

   ang_x = self.count;
   ang_y = 0;
   ang_z = 0;
   makevectors( ang );
   self.origin_z = v_forward_z * self.cnt;
   setorigin( self, self.origin );
   self.ltime = time;
   self.nextthink = time + 0.02;
};

void() func_bobbingwater =
{
   self.angles = '0 0 0';
   self.movetype = MOVETYPE_STEP;
   self.solid = SOLID_NOT;
   
   setmodel (self,self.model);
   
   self.think = bobbingwater_think;

   self.count = 0;
   self.cnt = self.size_z / 2;
   
   if ( !self.speed )
   {
      self.speed = 4;
   }

   self.speed = 360 / self.speed;

   self.nextthink = time + 0.02;
   self.ltime = time;
};
