#include "defs.qh"
void(float side) ShamFireball;
void() sham_fireballl1;
void() sham_fireballr1;
void() shambler_fire_touch;
void() shambler_fire_think;
float (entity targ, entity inflictor) CanDamage;

void() Napalm_touch;
/*
==============================================================================

SHAMBLER

==============================================================================
*/

$cd /raid/quake/id1/models/shams
$scale 1.5
$origin 0 0 24
$base base		
$skin base

$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8 stand9
$frame stand10 stand11 stand12 stand13 stand14 stand15 stand16 stand17

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 
$frame walk8 walk9 walk10 walk11 walk12

$frame	run1 run2 run3 run4 run5 run6

$frame smash1 smash2 smash3 smash4 smash5 smash6 smash7 
$frame smash8 smash9 smash10 smash11 smash12

$frame swingr1 swingr2 swingr3 swingr4 swingr5 
$frame swingr6 swingr7 swingr8 swingr9

$frame swingl1 swingl2 swingl3 swingl4 swingl5 
$frame swingl6 swingl7 swingl8 swingl9

$frame magic1 magic2 magic3 magic4 magic5 
$frame magic6 magic7 magic8 magic9 magic10 magic11 magic12

$frame pain1 pain2 pain3 pain4 pain5 pain6

$frame death1 death2 death3 death4 death5 death6 
$frame death7 death8 death9 death10 death11

void() sham_stand1	=[	$stand1,	sham_stand2	] {ai_stand();};
void() sham_stand2	=[	$stand2,	sham_stand3	] {ai_stand();};
void() sham_stand3	=[	$stand3,	sham_stand4	] {ai_stand();};
void() sham_stand4	=[	$stand4,	sham_stand5	] {ai_stand();};
void() sham_stand5	=[	$stand5,	sham_stand6	] {ai_stand();};
void() sham_stand6	=[	$stand6,	sham_stand7	] {ai_stand();};
void() sham_stand7	=[	$stand7,	sham_stand8	] {ai_stand();};
void() sham_stand8	=[	$stand8,	sham_stand9	] {ai_stand();};
void() sham_stand9	=[	$stand9,	sham_stand10] {ai_stand();};
void() sham_stand10	=[	$stand10,	sham_stand11] {ai_stand();};
void() sham_stand11	=[	$stand11,	sham_stand12] {ai_stand();};
void() sham_stand12	=[	$stand12,	sham_stand13] {ai_stand();};
void() sham_stand13	=[	$stand13,	sham_stand14] {ai_stand();};
void() sham_stand14	=[	$stand14,	sham_stand15] {ai_stand();};
void() sham_stand15	=[	$stand15,	sham_stand16] {ai_stand();};
void() sham_stand16	=[	$stand16,	sham_stand17] {ai_stand();};
void() sham_stand17	=[	$stand17,	sham_stand1	] {ai_stand();};

void() sham_walk1		=[      $walk1,        sham_walk2 ] {ai_walk(2*(self.has_tesla));};
void() sham_walk2       =[      $walk2,        sham_walk3 ] {ai_walk(2*(self.has_tesla));};
void() sham_walk3       =[      $walk3,        sham_walk4 ] {ai_walk(2*(self.has_tesla));};
void() sham_walk4       =[      $walk4,        sham_walk5 ] {ai_walk(self.has_tesla);};
void() sham_walk5       =[      $walk5,        sham_walk6 ] {ai_walk(1.5*(self.has_tesla));};
void() sham_walk6       =[      $walk6,        sham_walk7 ] {ai_walk(5*self.has_tesla);};
void() sham_walk7       =[      $walk7,        sham_walk8 ] {ai_walk(2*(self.has_tesla));};
void() sham_walk8       =[      $walk8,        sham_walk9 ] {ai_walk(3*(self.has_tesla-4));};
void() sham_walk9       =[      $walk9,        sham_walk10] {ai_walk(6*self.has_tesla);};
void() sham_walk10      =[      $walk10,       sham_walk11] {ai_walk(3*self.has_tesla);};
void() sham_walk11      =[      $walk11,       sham_walk12] {ai_walk(1.8*(self.has_tesla));};
void() sham_walk12      =[      $walk12,       sham_walk1 ] {ai_walk(1.8*(self.has_tesla));
if (random() > 0.8)
	sound (self, CHAN_VOICE, "shambler/sidle.wav", 1, ATTN_IDLE);};

void() sham_run = {
      sham_run1();
};

void() sham_run1       =[      $run1,        sham_run2      ] {ai_run(5*self.has_tesla);};
void() sham_run2       =[      $run2,        sham_run3      ] {ai_run(6*self.has_tesla);};
void() sham_run3       =[      $run3,        sham_run4      ] {ai_run(5*self.has_tesla);};
void() sham_run4       =[      $run4,        sham_run5      ] {ai_run(5*self.has_tesla);};
void() sham_run5       =[      $run5,        sham_run6      ] {ai_run(6*self.has_tesla);};
void() sham_run6       =[      $run6,        sham_run1      ] {ai_run(5*self.has_tesla);
if (random() > 0.8)
	sound (self, CHAN_VOICE, "shambler/sidle.wav", 1, ATTN_IDLE);

//if (self.enemy
};

void() sham_smash1     =[      $smash1,       sham_smash2    ] {
sound (self, CHAN_VOICE, "shambler/melee1.wav", 1, ATTN_NORM);
ai_charge(12);};
void() sham_smash2     =[      $smash2,       sham_smash3    ] {ai_charge(12);}; // spd trple
void() sham_smash3     =[      $smash3,       sham_smash4    ] {ai_charge(12);};
void() sham_smash4     =[      $smash4,       sham_smash5    ] {ai_charge(10);};
void() sham_smash5     =[      $smash5,       sham_smash6    ] {ai_charge(8);};
void() sham_smash6     =[      $smash6,       sham_smash7    ] {ai_charge(2);};
void() sham_smash7     =[      $smash7,       sham_smash8    ] {ai_charge(0);};
void() sham_smash8     =[      $smash8,       sham_smash9    ] {ai_charge(0);};
void() sham_smash9     =[      $smash9,       sham_smash10   ] {ai_charge(0);};
void() sham_smash10    =[      $smash10,      sham_smash11   ] {
local vector	delta;
local float 	ldmg;

	if (!self.enemy)
	{
		self.has_teleporter += 1;
		return;
	}
	ai_charge(0);

	delta = self.enemy.origin - self.origin;

	if (vlen(delta) > 200)
	{
		self.has_teleporter += 1;
		return;
	}
	if (!CanDamage (self.enemy, self))
	{
		self.has_teleporter += 1;
		return;
	}
		
	ldmg = (random() + random() + random()) * 200 + 30*self.has_tesla;
	deathmsg = 0;
	if (self.enemy.tf_items & NIT_GEL) ldmg = ldmg / 2;
	if (self.enemy.cutf_items & CUTF_DEMONLORE) ldmg = ldmg / 2;
	T_Damage (self.enemy, self, self, ldmg);
	sound (self, CHAN_VOICE, "shambler/smack.wav", 1, ATTN_NORM);

	SpawnMeatSpray (self.origin + v_forward*16, crandom() * 100 * v_right);
	SpawnMeatSpray (self.origin + v_forward*16, crandom() * 100 * v_right);

	self.has_teleporter -= 1;
};
void() sham_smash11    =[      $smash11,      sham_smash12   ] {ai_charge(10 * (0.7 + self.has_tesla * 0.2));}; // spd dbl
void() sham_smash12    =[      $smash12,      sham_run1	   ] {ai_charge(8 * (0.7 + self.has_tesla * 0.2));};

void() sham_swingr1;

void(float side) ShamClaw =
{
local vector	delta;
local float 	ldmg;


	if (!self.enemy)
	{
		self.has_teleporter += 1;
		return;
	}

	ai_charge(20 * (0.7 + self.has_tesla * 0.2)); //spd dbl

	delta = self.enemy.origin - self.origin;

	if (vlen(delta) > 200)
	{
		self.has_teleporter += 1;
		return;
	}	

	deathmsg = 0;
	
	ldmg = (random() + random() + random()) * 75 + 15*self.has_tesla;
	if (self.enemy.tf_items & NIT_GEL) ldmg = ldmg / 2;
	if (self.enemy.cutf_items & CUTF_DEMONLORE) ldmg = ldmg * 0.8;
	if (self.has_tesla == 5)
	{
		if (ldmg < self.enemy.health && self.enemy.health > 0)
			self.health = self.health + (ldmg / 20);
		else if (self.enemy.health > 0)
			self.health = self.health + (self.enemy.health / 20);
		if (self.health > self.max_health)
			self.health = self.max_health;
	}
	T_Damage (self.enemy, self, self, ldmg);
	sound (self, CHAN_VOICE, "shambler/smack.wav", 1, ATTN_NORM);

	if (side)
	{
		makevectors (self.angles);
		SpawnMeatSpray (self.origin + v_forward*16, side * v_right);
	}

	self.has_teleporter -= 1;
};

void() sham_swingl1	=[      $swingl1,      sham_swingl2   ] {
sound (self, CHAN_VOICE, "shambler/melee2.wav", 1, ATTN_NORM);
ai_charge(10);};
void() sham_swingl2 =[      $swingl2,      sham_swingl3   ] {ai_charge(6);}; //speed doubled
void() sham_swingl3 =[      $swingl3,      sham_swingl4   ] {ai_charge(14);};
void() sham_swingl4 =[      $swingl4,      sham_swingl5   ] {ai_charge(6);};
void() sham_swingl5 =[      $swingl5,      sham_swingl6   ] {ai_charge(14);};
void() sham_swingl6 =[      $swingl6,      sham_swingl7   ] {ai_charge(18);};
void() sham_swingl7 =[      $swingl7,      sham_swingl8   ] {ai_charge(10); ShamClaw(250);
if (self.enemy.health <= 0 || self.enemy.has_disconnected)
{
self.enemy = nil;
// FIXME: look all around for other targets
	/*if (self.oldenemy.health > 0)
	{
		self.enemy = self.oldenemy;
		HuntTarget ();
	}
	else
	{*/ //FIXES MAD SHAMBLERs?
		if (self.movetarget)
			self.th_walk ();
		else
			self.th_stand ();
		return;
	//}
}
};
void() sham_swingl8 =[      $swingl8,      sham_swingl9   ] {ai_charge(8);};
void() sham_swingl9 =[      $swingl9,      sham_run1  ] {
ai_charge(16);
if (self.enemy && random()<0.5)
	self.think = sham_swingr1;
};

void() sham_swingr1	=[      $swingr1,      sham_swingr2   ] {
sound (self, CHAN_VOICE, "shambler/melee1.wav", 1, ATTN_NORM);
ai_charge(2);};
void() sham_swingr2	=[      $swingr2,      sham_swingr3   ] {ai_charge(16);};
void() sham_swingr3 =[      $swingr3,      sham_swingr4   ] {ai_charge(28);};
void() sham_swingr4 =[      $swingr4,      sham_swingr5   ] {ai_charge(14);}; // speed dbl
void() sham_swingr5 =[      $swingr5,      sham_swingr6   ] {ai_charge(6);};
void() sham_swingr6 =[      $swingr6,      sham_swingr7   ] {ai_charge(12);};
void() sham_swingr7 =[      $swingr7,      sham_swingr8   ] {ai_charge(12); ShamClaw(-250);
if (self.enemy.health <= 0 || self.enemy.has_disconnected)
{
self.enemy = nil;
// FIXME: look all around for other targets
	/*if (self.oldenemy.health > 0)
	{
		self.enemy = self.oldenemy;
		HuntTarget ();
	}
	else
	{*/ //FIXES MAD SHAMBLERs? - no
		if (self.movetarget)
			self.th_walk ();
		else
			self.th_stand ();
		return;
	//}
}
};
void() sham_swingr8 =[      $swingr8,      sham_swingr9   ] {ai_charge(6);};
void() sham_swingr9 =[      $swingr9,      sham_run1  ] {ai_charge(2);
if ((self.enemy && random()<0.5))
	self.think = sham_swingl1;
};

void() sham_melee =
{
	local float chance;
	
	chance = random();
	self.has_sensor = 1;
	if (chance > 0.8)
		sham_smash1 ();
	else if (chance > 0.4)
		sham_swingr1 ();
	else
		sham_swingl1 ();
};


//============================================================================

void() CastLightning =
{
	local	vector	org, dir;
	local	float	ldmg;
	
	self.effects |= EF_DIMLIGHT;

	ai_face ();

	org = self.origin + '0 0 40';

	dir = (self.enemy.origin + '0 0 30') - org;
	dir = normalize (dir);

    // OfN - Check for force field
    traceline (org, self.origin + dir*3000, FALSE, self);

    if (trace_ent.classname == "force_field")
    {
        FieldExplosion(trace_ent,trace_endpos,trace_ent);
        PutFieldWork(trace_ent);

        WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
        WriteByte (MSG_MULTICAST, TE_LIGHTNING1);
        WriteEntity (MSG_MULTICAST, self);
        WriteCoord (MSG_MULTICAST, org.x);
        WriteCoord (MSG_MULTICAST, org.y);
        WriteCoord (MSG_MULTICAST, org.z);
        WriteCoord (MSG_MULTICAST, trace_endpos.x);
        WriteCoord (MSG_MULTICAST, trace_endpos.y);
        WriteCoord (MSG_MULTICAST, trace_endpos.z);
        multicast (org, MULTICAST_PHS);

       
	self.has_sentry += 1;
	return;
    }

    if (!trace_ent.takedamage)
	self.has_sentry += 1;
    else
	self.has_sentry -= 1;
    

    //_------------------------------------_//

	traceline (org, self.origin + dir*(3000 + self.has_tesla * 2), TRUE, self);

	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_LIGHTNING1);
	WriteEntity (MSG_MULTICAST, self);
	WriteCoord (MSG_MULTICAST, org.x);
	WriteCoord (MSG_MULTICAST, org.y);
	WriteCoord (MSG_MULTICAST, org.z);
	WriteCoord (MSG_MULTICAST, trace_endpos.x);
	WriteCoord (MSG_MULTICAST, trace_endpos.y);
	WriteCoord (MSG_MULTICAST, trace_endpos.z);

	ldmg = self.has_tesla * 2;
	if (self.has_tesla > 5)
		if (ldmg < self.enemy.health)
			self.health = self.health + (ldmg / 10);
		else
			self.health = floor(self.health + (self.enemy.health / 10));
		if (self.health > self.max_health)
			self.health = self.max_health;
	
	LightningDamage (org, trace_endpos, self, ldmg);

};

void() sham_magic1     =[      $magic1,       sham_magic2    ] {ai_face();
	sound (self, CHAN_WEAPON, "shambler/sattck1.wav", 1, ATTN_NORM);
};
void() sham_magic2     =[      $magic2,       sham_magic3    ] {ai_face();};
void() sham_magic3     =[      $magic3,       sham_magic4    ] {ai_face();self.nextthink = self.nextthink + 0.2;
local entity o;

self.effects |= EF_DIMLIGHT;
ai_face();
self.owner = spawn();
o = self.owner;
setmodel (o, "progs/s_light.mdl");
setorigin (o, self.origin);
o.angles = self.angles;
o.nextthink = time + 0.7;
o.think = SUB_Remove;
};
void() sham_magic4     =[      $magic4,       sham_magic5    ]
{
self.effects |= EF_DIMLIGHT;
self.owner.frame = 1;
};
void() sham_magic5     =[      $magic5,       sham_magic6    ]
{
self.effects |= EF_DIMLIGHT;
self.owner.frame = 2;
};
void() sham_magic6     =[      $magic6,       sham_magic9    ]
{
remove (self.owner);
CastLightning();
sound (self, CHAN_WEAPON, "shambler/sboom.wav", 1, ATTN_NORM);
};
void() sham_magic9     =[      $magic9,       sham_magic10   ]
{CastLightning();};
void() sham_magic10    =[      $magic10,      sham_magic11   ]
{CastLightning();};
void() sham_magic11    =[      $magic11,      sham_magic12   ]
{
if (self.has_tesla > 5)
	CastLightning();
};
void() sham_magic12    =[      $magic12,      sham_run1	   ] {self.effects = 0;};



void() sham_pain1       =[      $pain1, sham_pain2      ] {};
void() sham_pain2       =[      $pain2, sham_pain3      ] {};
void() sham_pain3       =[      $pain3, sham_pain4      ] {};
void() sham_pain4       =[      $pain4, sham_pain5      ] {};
void() sham_pain5       =[      $pain5, sham_pain6      ] {};
void() sham_pain6       =[      $pain6, sham_run1      ] {};

void(entity attacker, float damage)	sham_pain =
{
	// FIXME: TODO:
    //Check_PainAttacker(attacker);
    
    //self.real_owner.StatusRefreshTime = time + 0.2;
	//self.real_owner.StatusBarScreen = 3;  

    if (attacker.takedamage && self.has_tesla > 5 && attacker != self && !(IsMonsterNonArmy(attacker) && self.real_owner == attacker.real_owner))
    {
	if (self.enemy.classname != "player" || !Teammate(self.real_owner.team_no, self.enemy.team_no))
   	    self.oldenemy = self.enemy;

	if (attacker != self.enemy)  {
	    self.enemy = attacker;
	    HuntTarget();
	}
    }

    if (self.pain_finished > time)
		return;

    if (self.health <= 0)
		return;		// allready dying, don't go into pain frame
	  
    if (random()*self.has_tesla*100 > damage) // was 70
		return;		// didn't flinch

    sound (self, CHAN_VOICE, "shambler/shurt2.wav", 1, ATTN_NORM);

	//self.pain_finished = time + 2; wasnt comented
    self.pain_finished = time + 1.5 + random() * 1.2; //-OfN first was 1, then 1.5
	self.effects=0;
        
	sham_pain1 ();
};

void() sham_death1      =[      $death1,       sham_death2     ] {};
void() sham_death2      =[      $death2,       sham_death3     ] {};
void() sham_death3      =[      $death3,       sham_death4     ] {self.solid = SOLID_NOT;};
void() sham_death4      =[      $death4,       sham_death5     ] {};
void() sham_death5      =[      $death5,       sham_death6     ] {};
void() sham_death6      =[      $death6,       sham_death7     ] {};
void() sham_death7      =[      $death7,       sham_death8     ] {};
void() sham_death8      =[      $death8,       sham_death9     ] {};
void() sham_death9      =[      $death9,       sham_death10    ] {};
void() sham_death10     =[      $death10,      sham_death11    ] {};
void() sham_death11     =[      $death11,      sham_death11    ] 
{
    self.nextthink = time + 40 + 40*random();	
	self.think = SUB_Remove;
};

void() custom_shambler_die = 
{
	self.effects=0;
    
    if (self.real_owner.classname == "player" && self.real_owner.demon_one == self)
	{
		sprint(self.real_owner,PRINT_HIGH,"Your shambler is dead.\n");
		self.real_owner.job &= ~JOB_DEMON_OUT;
		self.real_owner.job_finished = time + 5; //Can't summon streams of demons SB can so
        self.real_owner.demon_one = nil;
	}
    
    // check for gib
	if (self.health < -50)
	{
        sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_MONSTERDIE);
	    ThrowGib ("progs/h_shams.mdl", self.health);
	    ThrowGib ("progs/gib1.mdl", self.health);
	    ThrowGib ("progs/gib2.mdl", self.health);
	    ThrowGib ("progs/gib3.mdl", self.health);
  	    
        ThrowGib ("progs/gib3.mdl", self.health);

        dremove(self);
        return;
    }

    sound (self, CHAN_VOICE, "shambler/sdeath.wav", 1, ATTN_MONSTERDIE);
    self.classname = "monster_corpse";
    self.think=nil;
    sham_death1();
};

float () CheckShamMelee =
{
	local vector dist;
	local float d;
	

	if (self.has_teleporter < -2)
		self.has_teleporter = -2;

	if (self.has_teleporter > 2 && self.has_teleporter > (14 - 2*self.has_tesla))
	{
		self.has_teleporter -= 0.1;
		return FALSE;
	}

	dist = self.enemy.origin - self.origin;
	d = vlen(dist);
	if (d < 150) //CH Check reach
	{
		return TRUE;
	}
	return FALSE;
};

float () CheckShamFireball =
{
	local	vector	dist;
	
	if (self.has_tesla <= 5)
	{
		return FALSE;
	}

	if (self.has_fieldgen < 0)
		self.has_fieldgen *= 0.8;

	if (self.has_fieldgen > 2 && (self.has_fieldgen > (14 - 2*self.has_tesla)))
	{
		self.has_fieldgen -= 0.1;
		return FALSE;
	}

	dist = self.enemy.origin - self.origin;
	
	if (random() < (0.4 - (dist.z / 1000)))
	{
		return FALSE;
	}


	return TRUE;
};


float () CheckShamLightning =
{
	local	vector	dist;
	local	float	d;
	local 	float	d2;
 
	if (self.has_sentry < 0)
		self.has_sentry *= 0.8;

	if (self.has_sentry > 2 && self.has_sentry > (14 - 2*self.has_tesla))
	{
		self.has_sentry -= 0.1;
		return FALSE;
	}

	if (!visible2(self.enemy, self)) //If can see
		return FALSE;
	dist = self.enemy.origin - self.origin;
	dist.z = 0; //CH only need x,y
	d2 = vlen(dist);
	dist = self.enemy.origin - self.origin;
	dist.x = dist.y = 0; //CH only need z
	d = vlen(dist);
	if (self.has_tesla > 6 && random() < 0.1)
		return TRUE;
	if (random() > self.has_tesla * (d2 / 300) * 0.07) //CH as not to fire all the time
		return FALSE;
	if (d2 < 1500 - self.has_tesla * 250 && d < 100)
		return FALSE;
	if (d2 > 2000 + self.has_tesla * 200) //Sham has lots of lightning range
		return FALSE;
	
	return TRUE;
};

float() CheckShamConvert = 
{
	if (self.has_tesla <= 6)
	    return FALSE;
	if (!IsMonsterNonArmy(self.enemy))
	    return FALSE;
	if (self.enemy.classname == "monster_shambler" && self.enemy.has_tesla > 6)
	    return FALSE;
	if (Teammate(self.real_owner.team_no, self.enemy.real_owner.team_no))
	    return FALSE;
	if (self.enemy.health > (self.enemy.max_health * 3 / 4))
	    return FALSE;

	if (self.enemy.classname == "monster_shambler" && self.enemy.has_tesla > 5)
	{
	    if (self.enemy.has_tesla > 6 || random() > 0.5)
		    return FALSE;
	}

	if (random() * 4000 < self.enemy.health)
	    return FALSE;

	sound (self, CHAN_VOICE, "boss1/sight1.wav", 1, ATTN_NORM);
	sprint (self.enemy.real_owner, PRINT_HIGH, "Your demon bows before its master!\n");

	self.enemy.martyr_enemy = self.enemy.real_owner;
	self.enemy.real_owner = self.real_owner;
	self.enemy.is_malfunctioning = TRUE;
	self.enemy.enemy = nil;
	self.enemy.think = self.enemy.th_walk;
	self.enemy.nextthink = time + 1;
	self.enemy.goalentity = self.enemy;
	//self.enemy.invincible_finished = self.enemy.nextthink;


	if (self.enemy.martyr_enemy.demon_one == self.enemy)
	{
	    self.enemy.martyr_enemy.job &= ~JOB_DEMON_OUT;
	    self.enemy.martyr_enemy.demon_one = nil;
	}
	
	self.enemy = nil;
	if (self.movetarget)
	    self.think = self.th_walk;
	else
	    self.think = self.th_stand;
	return TRUE;
};

float()	ShamCheckAttack =
{
	if (CheckShamConvert())
	{
		self.enemy = nil;
		return FALSE;
	}

	if (random() * 10 > self.has_tesla) //don't attack all the time, but do choose correctly if we're attacking.
		return FALSE;

// if close enough for slashing, go for it
	if (CheckShamMelee ())
	{
		self.attack_state = AS_MELEE;
		return TRUE;
	}
	
	if (CheckShamFireball ())
	{
		self.attack_state = AS_FIREBALL;
		return TRUE;
	}

	if (CheckShamLightning ())
	{
		self.attack_state = AS_MISSILE;
		return TRUE;
	}


	return FALSE;
};

// Shambler shoots fireballs!


void() sham_fireball =
{
	local float		r;
	
	r = random();
	
	if (r > 0.5)
		sham_fireballl1();
	else
		sham_fireballr1();
		
};

void() sham_fireballl1	=[      $swingl1,      sham_fireballl2   ] {
sound (self, CHAN_VOICE, "shambler/melee2.wav", 1, ATTN_NORM);
ai_charge(15 * (0.7 + self.has_tesla * 0.2));};
void() sham_fireballl2 =[      $swingl2,      sham_fireballl3   ] {ai_charge(9 * (0.7 + self.has_tesla * 0.2));}; //speed doubled
void() sham_fireballl3 =[      $swingl3,      sham_fireballl4   ] {ai_charge(21 * (0.7 + self.has_tesla * 0.2));};
void() sham_fireballl4 =[      $swingl4,      sham_fireballl5   ] {ai_charge(9 * (0.7 + self.has_tesla * 0.2));};
void() sham_fireballl5 =[      $swingl5,      sham_fireballl6   ] {ai_charge(21 * (0.7 + self.has_tesla * 0.2));};
void() sham_fireballl6 =[      $swingl6,      sham_fireballl7   ] {ai_charge(27 * (0.7 + self.has_tesla * 0.2));};
void() sham_fireballl7 =[      $swingl7,      sham_fireballl8   ] {ai_charge(15 * (0.7 + self.has_tesla * 0.2)); ShamFireball(250);};
void() sham_fireballl8 =[      $swingl8,      sham_fireballl9   ] {ai_charge(12 * (0.7 + self.has_tesla * 0.2));};
void() sham_fireballl9 =[      $swingl9,      sham_run1  ] {
ai_charge(24 * (0.7 + self.has_tesla * 0.2));
   if (random() < 0.2) {
	    if (!CheckShamMelee())
		self.think = sham_fireballr1;
	    else
		self.think = sham_swingr1;
   }
};

void() sham_fireballr1	=[      $swingr1,      sham_fireballr2   ] {
sound (self, CHAN_VOICE, "shambler/melee1.wav", 1, ATTN_NORM);
ai_charge(3 * (0.7 + self.has_tesla * 0.2));};
void() sham_fireballr2	=[      $swingr2,      sham_fireballr3   ] {ai_charge(24 * (0.7 + self.has_tesla * 0.2));};
void() sham_fireballr3 =[      $swingr3,      sham_fireballr4   ] {ai_charge(42 * (0.7 + self.has_tesla * 0.2));};
void() sham_fireballr4 =[      $swingr4,      sham_fireballr5   ] {ai_charge(21 * (0.7 + self.has_tesla * 0.2));}; // speed dbl
void() sham_fireballr5 =[      $swingr5,      sham_fireballr6   ] {ai_charge(9 * (0.7 + self.has_tesla * 0.2));};
void() sham_fireballr6 =[      $swingr6,      sham_fireballr7   ] {ai_charge(18 * (0.7 + self.has_tesla * 0.2));};
void() sham_fireballr7 =[      $swingr7,      sham_fireballr8   ] {ai_charge(18 * (0.7 + self.has_tesla * 0.2)); ShamFireball(-250);};
void() sham_fireballr8 =[      $swingr8,      sham_fireballr9   ] {ai_charge(9 * (0.7 + self.has_tesla * 0.2));};
void() sham_fireballr9 =[      $swingr9,      sham_run1  ] {ai_charge(30 * (0.7 + self.has_tesla * 0.2));
if (random() < 0.4) {
	if (!CheckShamMelee())
	    self.think = sham_fireballl1;
	else
	    self.think = sham_swingl1;
}
};

void(float side) ShamFireball =
{
	local	vector	org, dir;
	local	float	mult;	

	ai_face ();

#ifdef SHAMBLER_DEBUG
	sprint(self.real_owner, PRINT_HIGH, "Throwing fireballs at ");
	sprint(self.real_owner, PRINT_HIGH, self.enemy.classname);
	sprint(self.real_owner, PRINT_HIGH, "\n");
#endif

	makevectors (self.angles); // was offang
	
	sound (self, CHAN_WEAPON, "hknight/attack1.wav", 1, ATTN_NORM); //Odd, it was already precached

	if (side > 0) //CH cause to spawn on side of demon. GR - and actually outside the bounding box too!
		org = self.origin + (v_forward * 40) + (v_right * 20);
	else
		org = self.origin + (v_forward * 40) - (v_right * 20);

	org.z += 32;
#ifdef SHAMBLER_DEBUG
	sprint(self.real_owner, PRINT_HIGH, "org is ");
	sprint(self.real_owner, PRINT_HIGH, vtos(org));
#endif
// set missile speed

//CH demons are not good at throwing
//but shamblers are
	//dir.z = 0 - dir.z; //Random Z addage
	//dir.x = dir.x + (random() - 0.5)*0.20 / self.has_tesla; //Random X addage
	//dir.y = dir.y + (random() - 0.5)*0.20 / self.has_tesla; //Random Y addage
	
	newmis = spawn ();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;

	newmis.angles = self.angles;
	newmis.avelocity = '200 200 200';

	dir = normalize(self.enemy.origin - org);
	mult = 1300 + self.has_tesla*50; 
	newmis.velocity = dir * mult;

	newmis.touch = shambler_fire_touch;
	newmis.weapon = DMSG_DEMON_FIRE;
	newmis.classname = "demon_fire";

	newmis.think = shambler_fire_think;
	newmis.nextthink = time + 0.1;
	newmis.heat = time + 10;

	newmis.oldorigin = self.enemy.origin;
	setmodel (newmis, "progs/lavaball.mdl");
//	setsize (newmis, '-4 -8 -4', '4 8 4'); //CH actual mdl bounds GR well not that big
	setsize (newmis, '0 0 0', '0 0 0');
	setorigin (newmis, org);

#ifdef SHAMBLER_DEBUG
	sprint(self.real_owner, PRINT_HIGH, ", newmis.origin is ");
	sprint(self.real_owner, PRINT_HIGH, vtos(newmis.origin));
	sprint(self.real_owner, PRINT_HIGH, ".\n");

	sprint(self.real_owner, PRINT_HIGH, "self.enemy.origin is ");
	sprint(self.real_owner, PRINT_HIGH, vtos(self.enemy.origin));
	sprint(self.real_owner, PRINT_HIGH, ".\n");

	sprint(self.real_owner, PRINT_HIGH, "newmis.velocity is ");
	sprint(self.real_owner, PRINT_HIGH, vtos(newmis.velocity));
	sprint(self.real_owner, PRINT_HIGH, ", dir is ");
	sprint(self.real_owner, PRINT_HIGH, vtos(dir));
	sprint(self.real_owner, PRINT_HIGH, ".\n");
#endif
};


void() shambler_fire_think =
{
	local float speed;
	local vector dir;

	if (self.heat < time) {
	    dremove(self);
	    return;
	}

	if (vlen(self.oldorigin - self.origin) < vlen(self.velocity) / 3) {
	    self.think = SUB_Remove;
	    self.nextthink = self.heat;
	    return;
	}

	speed = vlen(self.velocity);
	dir = normalize(self.oldorigin - self.origin);

	self.velocity = dir * speed;
	self.nextthink = time + 0.1;
};
	

void() shambler_fire_touch =
{
	local float fire_dmg;
	local entity head;

	fire_dmg = (30 * self.has_tesla) + (random() * 25);

#ifdef SHAMBLER_DEBUG
	sprint(self.owner.real_owner, PRINT_HIGH, "fire_touch at ");
	sprint(self.owner.real_owner, PRINT_HIGH, vtos(self.origin));
	sprint(self.owner.real_owner, PRINT_HIGH, ".\n");
#endif

	if (entpointcontents(self) == CONTENTS_SKY)
	{
		self.owner.has_fieldgen += 1;
		dremove(self);
		return;
	}

	deathmsg = self.weapon;
	T_RadiusDamage (self, self.owner, fire_dmg, self.owner);

        head = findradius(self.origin, 10*self.owner.has_tesla);

	if (!head)
		self.owner.has_fieldgen += 1;

        while (head)
        {
                 if (head.takedamage)
                 {
                        deathmsg = DMSG_FLAME;

			if (head == self.owner)
				self.owner.has_fieldgen += 2;
			else if (head == self.owner.enemy)  // even if it's a teammate
				self.owner.has_fieldgen -= 1;
			else if (Teammate(head.team_no, self.owner.team_no))
				self.owner.has_fieldgen += 1;
			else
				self.owner.has_fieldgen -= 1;

                        // set 'em on fire
                        other = head;  // i can't believe this works!
                        Napalm_touch();
			Napalm_touch(); // set them on a lot of fire
                        if (other.classname == "player")
                           stuffcmd(other, "bf\nbf\n");
                        if (IsBuilding(other))
                           TF_T_Damage (head, self, self.owner, 35, TF_TD_NOTTEAM, TF_TD_FIRE);
                 }
                head = head.chain;
        }


	self.origin = self.origin - 8*normalize(self.velocity); //???

#ifdef DEMO_STUFF
	// Remove any camera's locks on this missile
	if (self.enemy)
		CamProjectileLockOff();
#endif

	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_EXPLOSION);
	WriteCoord (MSG_MULTICAST, self.origin.x);
	WriteCoord (MSG_MULTICAST, self.origin.y);
	WriteCoord (MSG_MULTICAST, self.origin.z);
	multicast (self.origin, MULTICAST_PHS);
	dremove(self);
};



