#include "defs.qh"
#include "menu.qh"
/*=======================================================//
// field.QC - CustomTF 3.2.OfN             - 30/1/2001 - //
// by Sergio Fumaña Grunwaldt - OfteN aka superCOCK2000  //
=========================================================//
 Field generator stuff - Written all by myself! :)
 I took the model and some sounds from deadlode mod
 One sound is from megaTF
=========================================================*/

// field generator flags, DO NOT MODIFY

#define FIELDGEN_ISOFF      0 // no field, not linked, and its not trying to link (several possible reasons)
#define FIELDGEN_ISIDLE     1 // no field, not linked, trying to link with other generator
#define FIELDGEN_ISDISABLED 2 // no field, linked, its disabled temporary (teammate passing thru field)
#define FIELDGEN_ISENABLED  3 // field, linked, and cells enough, waiting for shock, only hum sound
#define FIELDGEN_ISWORKING  4 // field, linked, glowing and all the field visual/sound effects are on

// field generator settings

#define FIELDGEN_SHOCKTIME      2   // seconds the generators remains glowing and doing lightning after a shock
#define FIELDGEN_LINKTIME       3.5 // seconds between tries to link with other generator
#define FIELDGEN_TIMEDISABLED   1   // was 3 // then 2
#define FIELDGEN_CELLSCOST      2   // cells cost for each "FIELDGEN_ISWORKING" pass
#define FIELDGEN_DMG            80  // normal damag when touching
#define FIELDGEN_DMGINSIDE      120 // damage when trapped inside field

/*===============================================================================================

EXPLANATION OF HOW THE ENTITY FIELDS ARE USED ( thnx? np.. =) )
---------------------------------------------

For field generator entity:
---------------------------

.fieldgen_status - Holds current status of every field generator, FIELDGEN_XXXX determines
.fieldgen_hasfield - Boolean value, determines if field generator is currently supporting a force field
.fieldgen_field  - This points to the force field, if none its always 'world'
.no_grenades_1   - Controls delay between tries to link (only affects sound currently, it tries to link every frame)
.no_grenades_1   - Controls delay for field to go up again after beeing disabled
.tp_grenades_1   - Controls delay of the WORKING status
.has_teleporter  - Used to flash generators when field is activated
.has_camera      - Controls delay between cells take
.has_tesla       - Boolean, forced status.

For force field entity:
-----------------------

.demon_one      - Points to the first field generator
.demon_two      - Points to the 2nd generator
.fieldgen_status       - Hum sound running, boolean
.fieldgen_hasfield     - Shield sound running, boolean
.has_tesla      - Controls delay between hums
.has_sentry     - Controls delay between shield sounds
.dmg            - Next damage the field will do
.has_camera     - Used to control the rate at which the field touch sound/visual effects are done (4hz)

================================================================================================*/

void() CheckDistance;
entity(entity fieldgen) Find_OtherGen;
float(entity fieldgen1, entity fieldgen2) FieldGens_CanLink;
float(entity fieldgen) FieldGen_CanIdle;
float(entity field) IsValidFieldGen;
float (vector targ, vector check) vis2orig;
float(entity field) IsValidField;
void(entity tfield, entity gen1) Field_UpdateSounds;
void(entity tfield) Field_MakeVisual;
float(entity tfield) FieldIsImproved;
float(entity tfield) FieldIsMalfunctioning;
void() Field_touch;
void() Field_touch_SUB;
float(entity e1, entity e2) EntsTouching2;
void(entity tfield, vector where, entity thing) FieldExplosion;
float(entity tfield, entity who) Field_ItCanPass;
float(entity tfield, entity who) Field_ShouldDamage;

#ifdef FIELD_FORCEMODE

entity(entity myself) GetMyFieldGen;
float(entity tfield) Field_GetForcedStatus;
void(float value) SetFieldForcedStatus; // player function (self = player) cuts disabled time also
float() GetFieldForcedStatus; // player

#endif

//=========================================================================================
// field generator model and sounds

void() Field_Precache =
{
  	precache_sound ("misc/null.wav");
    precache_sound2("misc/ffhum.wav");
    precache_sound2("misc/ffbeep.wav");
    precache_sound2("misc/ffield.wav");
    precache_sound2("misc/ffact.wav");
    precache_sound2("misc/fffail.wav");
    precache_model2("progs/ffgen2.mdl");
};

//================================================================================================
// checks for field generators and removes itself if needed, checks for stuck entities on field 

void() Field_think =
{
    if (self.classname != "force_field")
    {
        RPrint("BUG: Not a force field entity was in 'FieldThink()'!\n");
        return;
    }

    self.has_camera = FALSE;

    // checks for removal...
    if (!IsValidFieldGen(self.demon_one) || !IsValidFieldGen(self.demon_two))
    {
        if (IsValidFieldGen(self.demon_one))
        {
            self.demon_one.fieldgen_hasfield = FALSE;
            self.demon_one.fieldgen_field = world;
        }

        if (IsValidFieldGen(self.demon_two))
        {
            self.demon_two.fieldgen_hasfield = FALSE;
            self.demon_two.fieldgen_field = world;
        }

        self.demon_one = world;
        self.demon_two = world;
        
        dremove(self);

        RPrint("Debug: Field entity removed in Field_think()\n"); //shouldnt happen
    }
    else
        self.nextthink = time + 0.25; // 4hz check

    if (IsValidFieldGen(self.demon_one))
    if (self.demon_one.fieldgen_status == FIELDGEN_ISWORKING)
        Field_MakeVisual(self);        
   
    // checks for anything stuck in field :)
    local entity te;
    local float frange;

    frange = FIELDGEN_RANGE;

    if (FieldIsImproved(self) & IMPROVED_FOUR)
        frange = FIELDGEN_HACKEDRANGE;

    te = findradius(self.origin,frange);
    while (te)
	{
		if (te != self)
        if (te != self.demon_one)
        if (te != self.demon_two)
        if (te.velocity == '0 0 0')
//		if (!IsBuilding(te)) // no screwing with the buildings :)
		if (te.classname != "force_field")
        if (EntsTouching2(te,self))
        {
            other = te;
            deathmsg = DMSG_STUCK_FORCEFIELD; 
            self.dmg = FIELDGEN_DMGINSIDE; // this gonna hurt
            Field_touch_SUB();
		}

		te = te.chain;
	}
};

//=============================================================================================
// is one entity actually inside the other one? (this avoids using a stupid trigger)

float(entity e1, entity e2) EntsTouching2 =
{
    if (e1.absmin_x > e2.absmax_x)
        return FALSE;
    if (e1.absmin_y > e2.absmax_y)
        return FALSE;
    if (e1.absmin_z > e2.absmax_z)
        return FALSE;

    if (e1.absmax_x < e2.absmin_x)
        return FALSE;
    if (e1.absmax_y < e2.absmin_y)
        return FALSE;
    if (e1.absmax_z < e2.absmin_z)
        return FALSE;

    return TRUE;
};

//=================================================================================
// these 2 functions return the current hacks that should apply to the field

float(entity tfield) FieldIsImproved =
{
    if (IsValidFieldGen(tfield.demon_one) && IsValidFieldGen(tfield.demon_two))
        return tfield.demon_one.num_mines | tfield.demon_two.num_mines;

    if (IsValidFieldGen(tfield.demon_one))
        return tfield.demon_one.num_mines;

    if (IsValidFieldGen(tfield.demon_two))
        return tfield.demon_two.num_mines;

    return 0;
};

float(entity tfield) FieldIsMalfunctioning =
{
    if (IsValidFieldGen(tfield.demon_one) && IsValidFieldGen(tfield.demon_two))
        return tfield.demon_one.is_malfunctioning | tfield.demon_two.is_malfunctioning;

    if (IsValidFieldGen(tfield.demon_one))
        return tfield.demon_one.is_malfunctioning;

    if (IsValidFieldGen(tfield.demon_two))
        return tfield.demon_two.is_malfunctioning;

    return 0;
};

//=================================================================
// self is the field, disables it

void() DisableField =
{
    if (IsValidFieldGen(self.demon_one))
    {
        self.demon_one.fieldgen_status = FIELDGEN_ISDISABLED;
        self.demon_one.no_grenades_2 = time + FIELDGEN_TIMEDISABLED;            
    }
            
    if (IsValidFieldGen(self.demon_two))
    {
        self.demon_two.fieldgen_status = FIELDGEN_ISDISABLED;
        self.demon_two.no_grenades_2 = time + FIELDGEN_TIMEDISABLED;
    }

    sound (self, CHAN_VOICE, "misc/ffbeep.wav", 0.4, ATTN_IDLE);
};

//=========================================================================================
// applies damage and makes the sound and visual effect for the forcefield shock

void() Field_touch_SUB =
{
    local float doFX;
    doFX = TRUE;

    if (FieldIsMalfunctioning(self) & SCREWUP_THREE) // reduce output
        self.dmg = 1;

    if (other.classname == "player") // PLAYERS
    {
    	if (other.playerclass == PC_UNDEFINED) // Observers
	    	return;
        
        if (Field_ItCanPass(self, other))  
        {
            DisableField();                        
            return;
        }
        else
        {
            self.velocity = self.velocity - (self.velocity*4) + '0 0 1';
            
            if (Field_ShouldDamage(self,other))
                TF_T_Damage (other, self, self.real_owner, self.dmg, TF_TD_NOTTEAM, TF_TD_ELECTRICITY);
        }

    }
    else // non player entities
    {
        if (IsMonster(other))
        {
            if (Field_ItCanPass(self, other))
            {
                DisableField();
                return;
            }
            else if (Field_ShouldDamage(self,other))
                TF_T_Damage (other, self, self.real_owner, self.dmg, TF_TD_NOTTEAM, TF_TD_ELECTRICITY);
        }
        
        // excludes entities that shouldnt be moved, doors plats etc..
        if(other.movetype == MOVETYPE_NONE 
            || other.movetype == MOVETYPE_PUSH)
            //|| other.movetype == MOVETYPE_NOCLIP
            return;
		if (IsBuilding(other))
			return;

        other.velocity_z = other.velocity_z + 100;
        if (other.origin_x < self.origin_x)
            other.velocity_x = other.velocity_x - 200 * random();
        else
            other.velocity_x = other.velocity_x + 200 * random();

        if (other.origin_y < self.origin_y)
            other.velocity_y = other.velocity_y - 200 * random();
        else
            other.velocity_y = other.velocity_y + 200 * random();
    }

    FieldExplosion(self,other.origin,other);
    PutFieldWork(self);
};

#ifdef FIELD_FORCEMODE

//==========================================================================
// gets one of our field generators

entity(entity myself) GetMyFieldGen =
{
    local entity te;
    local float foundit;
    te = world;
    foundit = FALSE;

    te = find(world, classname, "building_fieldgen");
    while (te != world && foundit == FALSE)
    {
        if (te.real_owner == myself) // is it ours?
            foundit = TRUE; // yeah, found it
        
        if (foundit == FALSE) // our search must continue...
            te = find(te, classname, "building_fieldgen");
    }

    return te;
};


//=========================================================================
// these functions retrieve and set the current 'forced status' on a field

float(entity tfield) Field_GetForcedStatus =
{
    if (IsValidFieldGen(tfield.demon_one) && IsValidFieldGen(tfield.demon_two))
    {
        if (tfield.demon_two.has_tesla || tfield.demon_one.has_tesla)
            return TRUE;
    }
    else if (IsValidFieldGen(tfield.demon_one))
    {
        if (tfield.demon_one.has_tesla)
            return TRUE;
    }
    else if (IsValidFieldGen(tfield.demon_two))
    {
        if (tfield.demon_two.has_tesla)
            return TRUE;
    }

    return FALSE;
};

//==============================================================================
// player functions called on menu.qc to disable/enable forced status on field

void(float value) SetFieldForcedStatus =
{
    local entity gen1, gen2;
    gen1 = GetMyFieldGen(self);
    gen2 = Find_OtherGen(gen1);

    if (IsValidFieldGen(gen1))
    {
        gen1.has_tesla = value;
        if (value)
            gen1.no_grenades_2 = time;
    }

    if (IsValidFieldGen(gen2))
    {
        gen2.has_tesla = value;
        if (value)
            gen2.no_grenades_2 = time;
    }
};

float() GetFieldForcedStatus =
{
    local entity gen1, gen2;
    gen1 = GetMyFieldGen(self);
    gen2 = Find_OtherGen(gen1);

    if (IsValidFieldGen(gen1) && IsValidFieldGen(gen2))
    {
        if (gen1.has_tesla || gen2.has_tesla)
            return TRUE;
    }
    else if (IsValidFieldGen(gen1))
        return gen1.has_tesla;
    else if (IsValidFieldGen(gen2))
        return gen2.has_tesla;

    return FALSE;

};

#endif

//=========================================================================
// returns TRUE if 'who' entity should be able to pass thru the field

float(entity tfield, entity who) Field_ItCanPass =
{
    if (FieldIsMalfunctioning(tfield) & SCREWUP_ONE)
        return FALSE;

    if (who == tfield.real_owner) // field owner - always pass
        return TRUE;

/*
    if (Field_GetForcedStatus(tfield)) 
        return FALSE;
*/

    if (who.classname == "player") // PLAYERS
    {
        if (Teammate(who.team_no, tfield.real_owner.team_no)) // teammate
            return TRUE;

        if (Teammate(who.undercover_team, tfield.real_owner.team_no)) // spies disguised as our team
            return TRUE;
    }
    else if (IsMonster(who))  // MONSTERS/ARMY
    {
        if (Teammate(who.real_owner.team_no, tfield.real_owner.team_no)) // team monster
            return TRUE;
    }

    return FALSE;
};

//=========================================================================
// returns TRUE if 'who' entity should be damaged by the field

float(entity tfield, entity who) Field_ShouldDamage =
{
    if (FieldIsMalfunctioning(tfield) & SCREWUP_ONE)
        return TRUE;

    if (who.classname == "player") // PLAYERS
    {
        if (who == tfield.real_owner) // field owner
            return FALSE;

        if (Teammate(who.team_no, tfield.real_owner.team_no)) // teammate
            return FALSE;

        if (Teammate(who.undercover_team, tfield.real_owner.team_no)) // spies disguised as our team
            return FALSE;
    }
    else if (IsMonster(who))  // MONSTERS/ARMY
    {
        if (Teammate(who.real_owner.team_no, tfield.real_owner.team_no)) // team monster
            return FALSE;
    }

    return TRUE;
};

//=============================================================================
// applies the particle effect and electric sound (at max 4hz rate)

void(entity tfield, vector where, entity thing) FieldExplosion =
{
    if (!tfield.has_camera)
    {
        if (thing == world || thing.is_removed) return;

        local vector whereFX;
        whereFX = where;
        whereFX_z = tfield.origin_z;

        spawnFOG(whereFX);
        sound(tfield,CHAN_BODY,"effects/crunch.wav",0.5,ATTN_NORM);

        tfield.has_camera = TRUE; // cya soon
    }
};

void(entity field) PutFieldWork =
{
    if (IsValidFieldGen(field.demon_one))
        field.demon_one.tp_grenades_1 = time + FIELDGEN_SHOCKTIME;        
    if (IsValidFieldGen(field.demon_two))
        field.demon_two.tp_grenades_1 = time + FIELDGEN_SHOCKTIME;
};

void() Field_touch =
{
    if (other.classname == "force_field") return; //avoid weird loops with other fields

    self.dmg = FIELDGEN_DMG;

    deathmsg = DMSG_FORCEFIELD;
    Field_touch_SUB();
};

//===================================================================================
// creates the force field between the 2 generators (only if none currently on)

void(entity gen1, entity gen2) Create_Field =
{
    if (gen1.fieldgen_hasfield || gen2.fieldgen_hasfield)
        return;

/*	dprint("gen1:\n");
	eprint(gen1.fieldgen_field);
	dprint("gen2:\n");
	eprint(gen2.fieldgen_field);
	dprint("done\n"); */

    if (gen1.fieldgen_field != world || gen2.fieldgen_field != world) // CHECK
        return;

    // already checked b4 on CanLink -> CanIdle
    /*if (!IsValidFieldGen(gen1) || !IsValidFieldGen(gen2))
        return;*/
        
    gen1.fieldgen_status = FIELDGEN_ISENABLED;
    gen2.fieldgen_status = FIELDGEN_ISENABLED;

    gen1.fieldgen_hasfield = TRUE;
    gen2.fieldgen_hasfield = TRUE;

    local entity tfield;

    // generate field
    tfield = spawn();
    tfield.classname = "force_field";
    tfield.owner = world;
    tfield.real_owner = gen1.real_owner; // --> player

    tfield.think = Field_think;
    tfield.touch = Field_touch;
    tfield.nextthink = time + 0.25;

	// set pos and size
	tfield.size_x = vlen (gen1.origin - gen2.origin) - 10;
	tfield.size_y = 4;
	tfield.size_z = 48; // was 64, but this looks more realistic
	tfield.maxs = tfield.size * 0.5; // FIXME: / 2 is broken
	tfield.mins = tfield.maxs * -1; // FIXME: -1 * only did first float
	tfield.origin = gen1.origin + (gen2.origin - gen1.origin) * 0.5;
	tfield.origin_z = AVG (gen1.absmax_z, gen2.absmax_z) - tfield.maxs_z;
	tfield.absmax = tfield.origin + tfield.maxs;
	tfield.absmin = tfield.origin + tfield.mins;

	local vector right, forward, up;
//	local string foo;

	up = '0 0 1';
	right = normalize (gen2.origin - gen1.origin);
	forward = crossproduct (up, right);

//	foo = "right: " + vtos (right) + "  forward: " + vtos (forward)
//		  + "  up: " + vtos (up) + "  mins: " + vtos (tfield.mins)
//		  + "  maxs: " + vtos (tfield.maxs) + "\n";
//	dprint (foo);
	tfield.rotated_bbox = getboxhull();
	rotate_bbox (tfield.rotated_bbox, right, forward, up, tfield.mins,
				 tfield.maxs);

	tfield.angles = (gen2.origin - gen1.origin);

    // apply stuff
    tfield.movetype = MOVETYPE_NONE;
    tfield.solid = SOLID_BBOX;
    setsize(tfield, tfield.mins, tfield.maxs);
    setorigin(tfield, tfield.origin);

    // assign the pointers on the field generators
    gen1.fieldgen_field = tfield;
    gen2.fieldgen_field = tfield;

    // assign the pointers to generators on ourselves
    tfield.demon_one = gen1;
    tfield.demon_two = gen2;

    //make activating sound
    sound (tfield, CHAN_VOICE, "misc/ffact.wav", 0.2, ATTN_NORM);

    // flash generators
    gen1.effects = EF_DIMLIGHT;
    gen1.has_teleporter = TRUE;
    gen1.skin = 2;
    gen2.effects = EF_DIMLIGHT;
    gen2.has_teleporter = TRUE;
    gen2.skin = 2;
};

//=================================================================0
// removes the force field (if any)

void(entity gen1, entity gen2) Remove_Field =
{
	if (IsValidFieldGen(gen1))
	{   
		if (IsValidField(gen1.fieldgen_field))
		{
			freeboxhull (gen1.fieldgen_field.rotated_bbox);
			dremove(gen1.fieldgen_field);
		}
		gen1.fieldgen_hasfield = FALSE;
		gen1.fieldgen_field = world;
		if (IsValidFieldGen(gen2))
		{
			gen2.fieldgen_hasfield = FALSE;
			gen2.fieldgen_field = world;
		}
	}
	else if (IsValidFieldGen(gen2))
	{
		if (IsValidField(gen2.fieldgen_field))
		{
			freeboxhull (gen2.fieldgen_field.rotated_bbox);
			dremove(gen2.fieldgen_field);
		}
		gen2.fieldgen_hasfield = FALSE;
		gen2.fieldgen_field = world;
	}
};

float(entity field) IsValidField =
{
    if (field == world)
        return FALSE;
    
    if (field.classname != "force_field")
        return FALSE;

    return TRUE;
};

float(entity field) IsValidFieldGen =
{
    if (field == world)
        return FALSE;
    
    if (field.classname != "building_fieldgen")
        return FALSE;
  
    return TRUE;
};

//========================================================
// starts or removes sounds on the field

void(entity tfield, entity gen1) Field_UpdateSounds =
{
    //fieldgen_status : hum
    //fieldgen_hasfield : shield
    
    if (IsValidField(tfield)) // only if there is a field currently
    {
        local float playhum, playshield;
        playhum = FALSE; playshield = FALSE;

        /*if (gen1.fieldgen_status == FIELDGEN_ISOFF) // for some reason we r not working
        {
            playhum = FALSE;
            playshield = FALSE;
        }
        else if (gen1.fieldgen_status == FIELDGEN_ISIDLE) // awaiting for link
        {
            playhum = FALSE;
            playshield = FALSE;
        }
        else if (gen1.fieldgen_status == FIELDGEN_ISDISABLED) // teammate passing thru the field?
        {
            playhum = FALSE;
            playshield = FALSE;            
        }
        else*/
        
        if (gen1.fieldgen_status == FIELDGEN_ISENABLED)
        {
            playhum = TRUE;
            playshield = FALSE;
        }
        else if (gen1.fieldgen_status == FIELDGEN_ISWORKING)
        {
            playhum = TRUE;
            playshield = TRUE;        
        }

        // MAKE THE SHIT SOUND !
        if (!playhum)
        {
            if (tfield.fieldgen_status)
            {
                sound(tfield,CHAN_MISC,"misc/null.wav",0.5,ATTN_NORM);
                tfield.fieldgen_status = FALSE;
            }
        }
        else
        {
            if (!tfield.fieldgen_status || tfield.has_tesla < time)
            {
                sound(tfield,CHAN_MISC,"misc/ffhum.wav",0.3,ATTN_NORM);
                tfield.has_tesla = time + 1;
                tfield.fieldgen_status = TRUE;
            }
        }

        if(!playshield)
        {
            if (tfield.fieldgen_hasfield)
            {
                sound(tfield,CHAN_ITEM,"misc/null.wav",0.2,ATTN_NORM);
                tfield.fieldgen_hasfield = FALSE;
            }
        }
        else
        {
            if (!tfield.fieldgen_hasfield || tfield.has_sentry < time)
            {
                //TODO?: lower volume as (FIELDGEN_SHOCKTIME - time) decreases
                
                sound(tfield,CHAN_ITEM,"misc/ffield.wav",0.4,ATTN_NORM);
                tfield.has_sentry = time + 1;
                tfield.fieldgen_hasfield = TRUE;
            }
        }
    
    }


};

//====================================================================
// do the lightning stuff while field is FIELDGEN_ISWORKING

void(entity tfield) Field_MakeVisual =
{
    if (IsValidField(tfield))
    {      
        local vector f;
        
		f = tfield.origin + (tfield.angles * 0.5 * (random() * 2 - 1));

        WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
        if (random() > 0.5)
            WriteByte (MSG_BROADCAST, TE_LIGHTNING2);
        else
            WriteByte (MSG_BROADCAST, TE_LIGHTNING1);
	    WriteEntity (MSG_BROADCAST, tfield);
	    WriteCoord (MSG_BROADCAST, f_x);
	    WriteCoord (MSG_BROADCAST, f_y);
	    WriteCoord (MSG_BROADCAST, tfield.origin_z - 12);
	    WriteCoord (MSG_BROADCAST, f_x);
	    WriteCoord (MSG_BROADCAST, f_y);
	    WriteCoord (MSG_BROADCAST, tfield.origin_z + 12);
    }
};

//==================================================
// called every frame by the field generators

void() FieldGen_think =
{
    local entity othergen;
    othergen = Find_OtherGen(self); // get our brother
    
    if (FieldGens_CanLink(self,othergen))
        Create_Field(self,othergen); // checks redundancy itself
    else
        Remove_Field(self,othergen); // checks redundancy itself

    // field main loop (ai? heh.. my cat is smarter than these force fields)
    if (self.fieldgen_status == FIELDGEN_ISOFF) // for some reason we r not working
    {
        self.effects = 0;
        self.skin = 0;

        if (FieldGen_CanIdle(self)) // can we go idle?
            self.fieldgen_status = FIELDGEN_ISIDLE;

    }
    else if (self.fieldgen_status == FIELDGEN_ISIDLE) // awaiting for link
    {
        self.effects = 0;
        self.skin = 0;
        
        if (self.no_grenades_1 < time) // trying to link sound/flash time
        {
            sound (self, CHAN_WEAPON, "misc/fffail.wav", 0.5, ATTN_IDLE);
            self.skin = 1;
            self.effects = EF_DIMLIGHT;
            self.no_grenades_1 = time + FIELDGEN_LINKTIME;
        }

    }
    else if (self.fieldgen_status == FIELDGEN_ISDISABLED) // teammate passing thru the field?
    {
        self.effects = 0;
        self.skin = 0;

        // time check
        if (self.no_grenades_2 < time) // can we go idle?
        {    
            self.fieldgen_status = FIELDGEN_ISIDLE;
            self.tp_grenades_1 = 0;
        }
        
    }
    else if (self.fieldgen_status == FIELDGEN_ISENABLED)
    {
        if (!self.has_teleporter)
        {
            self.effects = 0;
            self.skin = 1;
        }

        if (self.fieldgen_hasfield == FALSE)
            self.fieldgen_status = FIELDGEN_ISIDLE;
        
        if (self.tp_grenades_1 >= time)
            self.fieldgen_status = FIELDGEN_ISWORKING;
    }
    else if (self.fieldgen_status == FIELDGEN_ISWORKING)
    {
        self.effects = EF_DIMLIGHT;
        self.skin = 2;        

        if (self.has_camera <= time)
        {
            self.ammo_cells = self.ammo_cells - FIELDGEN_CELLSCOST;
            self.has_camera = time + 1;
        }

        if (self.fieldgen_hasfield == FALSE)
            self.fieldgen_status = FIELDGEN_ISIDLE;
        else if (self.tp_grenades_1 <= time)
            self.fieldgen_status = FIELDGEN_ISENABLED;
    }

    Field_UpdateSounds(self.fieldgen_field, self); // update force field sounds

    if (!FieldGen_CanIdle(self)) // turn us off if needed
        self.fieldgen_status = FIELDGEN_ISOFF;
   
    self.has_teleporter = FALSE; // resets 'flash' status bypass
    self.nextthink = time + 0.1;
};

//=======================================================================
// returns TRUE if the generator could currently go to idle status

float(entity fieldgen) FieldGen_CanIdle =
{
    if (!(IsValidFieldGen(fieldgen)))
        return FALSE;

    if (fieldgen.ammo_cells >= FIELDGEN_CELLSCOST &&
        !(fieldgen.is_malfunctioning & SCREWUP_FOUR)
        && fieldgen.health > 0)
        return TRUE;

    return FALSE;
};

//=======================================================================
// returns TRUE if both generators could currently generate the field

float(entity fieldgen1, entity fieldgen2) FieldGens_CanLink =
{
    if (!(IsValidFieldGen(fieldgen1)) || !(IsValidFieldGen(fieldgen2)))
        return FALSE;

    if (!visible2(fieldgen1,fieldgen2))
        return FALSE;
    
    local float r;
    r = vlen(fieldgen1.origin - fieldgen2.origin); // get distance between generators

//    if ((fieldgen1.num_mines & IMPROVED_FOUR && fieldgen2.num_mines & IMPROVED_FOUR) && r > FIELDGEN_HACKEDRANGE2)
//        return FALSE;
  
    /*if (fieldgen1.num_mines & IMPROVED_FOUR || fieldgen2.num_mines & IMPROVED_FOUR)
    {
        if ((fieldgen1.num_mines & IMPROVED_FOUR && fieldgen2.num_mines & IMPROVED_FOUR) && r > FIELDGEN_HACKEDRANGE2)
            return FALSE;
        else
        if ((fieldgen1.num_mines & IMPROVED_FOUR || fieldgen2.num_mines & IMPROVED_FOUR) && r > FIELDGEN_HACKEDRANGE)
            return FALSE;                 
    }*/

    if ((fieldgen1.num_mines & IMPROVED_FOUR || fieldgen2.num_mines & IMPROVED_FOUR) && r > FIELDGEN_HACKEDRANGE)
        return FALSE;

    if (r > FIELDGEN_RANGE && !(fieldgen1.num_mines & IMPROVED_FOUR || fieldgen2.num_mines & IMPROVED_FOUR))
        return FALSE;

    if (fieldgen1.origin_z != fieldgen2.origin_z)
        return FALSE;

    if (fieldgen1.fieldgen_status == FIELDGEN_ISDISABLED || fieldgen2.fieldgen_status == FIELDGEN_ISDISABLED)
        return FALSE;

    if (fieldgen1.fieldgen_status == FIELDGEN_ISOFF || fieldgen2.fieldgen_status == FIELDGEN_ISOFF)
        return FALSE;

    if (FieldGen_CanIdle(fieldgen1) && FieldGen_CanIdle(fieldgen2))
        return TRUE;
    
    return FALSE;
};

//=============================================================================================
// initialize field generator stuff just after beeing built, called on engineer.qc

void(entity field) Field_Built =
{
    field.touch = SUB_Null;
    field.think = FieldGen_think;
    field.nextthink = time + 0.1;
    field.fieldgen_status = FIELDGEN_ISIDLE; // we start on IDLE status (searching for other gen to link)
    field.fieldgen_hasfield = FALSE;
    field.no_grenades_1 = time + 3;
    field.fieldgen_field = world;
};

//==============================================================
// returns our other generator (if any)

entity(entity fieldgen) Find_OtherGen =
{
    local entity te;
    local float foundit;
    te = world;
    foundit = FALSE;

    te = find(world, classname, "building_fieldgen");
    while (te != world && foundit == FALSE)
    {
        if (te.real_owner == fieldgen.real_owner) // is it ours?
        if (te != fieldgen)                       // and not the same generator..
            foundit = TRUE; // yeah, found it
        
        if (foundit == FALSE) // our search must continue...
            te = find(te, classname, "building_fieldgen");
    }

    return te;
};

//=========================================================================================
// returns the place where field gen could be built related to player current pos and yaw
// called on engineer.qc, place is the origin passed where other kind of buildings are built

vector(vector place) WhereGen =
{
// FIXME: remove function if we allow rotation
	return place;

    // if we have no field generator currently, it can be placed anywhere
    if (self.has_fieldgen == 0) return place;

    local vector retval;
    local float r, distx, disty, foundit;
    local entity te;

    foundit = FALSE;

    // find the other generator
    te = find(world, classname, "building_fieldgen");
    while (te != world && foundit == FALSE)
    {
        if (te.real_owner == self) // is it ours?
            foundit = TRUE; // yeah, found it
        
        if (foundit == FALSE) // our search must continue...
            te = find(te, classname, "building_fieldgen");
    }

    // check for error getting the other gen
    if (te == world || te.classname != "building_fieldgen" || foundit == FALSE)
    {
        RPrint("BUG: Error on field generator placement routine. 'WhereGen()'\n");
        return place;
    }

    // calculate the new generator pos
    distx = fabs(place_x - te.origin_x);
    disty = fabs(place_y - te.origin_y);
    retval = place;

    if (distx < disty)
    {
        retval_x = te.origin_x; // adjust it in line

        r = vlen(self.origin - retval); // get distance from us (player)
        if (r > 200) // we r too far away?
            retval = place; // then bypass the calc
    }
    else
    {
        retval_y = te.origin_y; // adjust line up

        r = vlen(self.origin - retval); // get distance from us (player)
        if (r > 200) // we r too far away?
            retval = place; // then bypass the calc
    }
    
    // print message if they wont link
    if (!vis2orig(te.origin,retval))
        sprint(self, PRINT_HIGH, "Your field generators won't link, there are obstacles between them!\n");
    
    r = vlen(te.origin - retval); // get distance between generators
    if (te.num_mines & IMPROVED_FOUR && r > FIELDGEN_HACKEDRANGE)
        sprint(self, PRINT_HIGH, "Your field generators are too far away to link, even hacked\n");
    
    if (r > FIELDGEN_RANGE && !(te.num_mines & IMPROVED_FOUR))
        sprint(self, PRINT_HIGH, "Your field generators are too far away to link\n");
    /*else if (retval_z != te.origin_z)
        sprint(self, PRINT_HIGH, "Your field generators are at different heights, they won't link\n");*/
    
    if (retval_x != te.origin_x && retval_y != te.origin_y)
        sprint(self, PRINT_HIGH, "Your field generators are not lined up, they won't link\n");

    // return the final building place
    return retval;
};

//======================================================================
// damn! our field generator was destroyed. Force field must go down..

void() FieldGen_Die =
{
    self.real_owner.has_fieldgen = self.real_owner.has_fieldgen - 1;
    if (self.real_owner.has_fieldgen < 0) self.real_owner.has_fieldgen = 0;

    WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
    WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);
	multicast (self.origin, MULTICAST_PHS);

    // check if field should be removed..
    local entity othergen;
    othergen = Find_OtherGen(self);
    if (IsValidFieldGen(othergen))
    {
       Remove_Field(self, othergen);    
    }
    else
    {
       Remove_Field(self, world); // extra removal, not needed i think...
    }

    sprint(self.real_owner, PRINT_HIGH, "Your field generator was destroyed.\n");

    //TODO: gibs, one of the tesla, one custom

    dremove(self);
};

//=========================================================================
// Engineer has used a Spanner on the field generator

void(entity field) Engineer_UseFieldGen =
{
	self.building = field;
    
    if (Teammate(self.building.real_owner.team_no,self.team_no) && self.building.is_malfunctioning & SCREWUP_THREE)
    {        
        //if (self.building.is_malfunctioning & SCREWUP_FOUR)
		//{         
        sprint(self,PRINT_HIGH,"Trapped field generator, have a nice day!\n");
            
        deathmsg = DMSG_FGTRAP;
        T_RadiusDamage (self.building, self.building, FGTRAP_DMG, world);
//            TF_T_Damage(self.building, self.building, self.building, 2000, 0, TF_TD_OTHER);
        return;
        //}
    }

    local entity dist_checker;
	local string st;

	sprint(self, PRINT_HIGH, "Field Generator has ");
	st = ftos(field.health);
	sprint(self, PRINT_HIGH, st);
    sprint(self, PRINT_HIGH, "¯");
	st = ftos(field.max_health);
    sprint(self, PRINT_HIGH, st);
	sprint(self, PRINT_HIGH, " èåáìôè, ");
	st = ftos(field.ammo_cells);
	sprint(self, PRINT_HIGH, st);
	sprint(self, PRINT_HIGH, "¯");
	st = ftos(field.maxammo_cells);
    sprint(self, PRINT_HIGH, st);
	sprint(self, PRINT_HIGH, " ãåììó\n");

    // Pop up the menu
	self.current_menu = MENU_ENGINEER_FIX_FIELDGEN;
	self.menu_count = MENU_REFRESH_RATE;

	//dodgy
	if (teamplay != 0 && !Teammate(self.building.real_owner.team_no,self.team_no)) {
		Menu_EngineerFix_FieldGen_Input(4);
		return;
	}

	// Start a Distance checker, which removes the menu if the player
	// gets too far away from the sentry.
	dist_checker = spawn();
	dist_checker.classname = "timer";
	dist_checker.owner = self;
	dist_checker.enemy = field;
	dist_checker.think = CheckDistance;
	dist_checker.nextthink = time + 0.3;
};
