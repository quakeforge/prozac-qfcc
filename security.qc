#include "defs.qh"
/*======================================================
	SECURITY.QC			Custom TeamFortress v3.1

	(c) Craig Hauser			26/3/00
========================================================
Functions for the security camera
======================================================*/
void() Security_Camera_Idle;
float() Security_Camera_FindTarget;
void(entity attacker, float damage) Security_Camera_Pain;
void() Security_Camera_Die;
void() Security_Camera_PrintTarget;
void() Security_Camera_Spawn;
float() Security_Camera_FindFakeTarget;
void() SecurityCameraTossTouch;

//used for print
string(float tno) GetTrueTeamName;
string(float pc) TeamFortress_GetClassName;
string(float pc) TeamFortress_GetJobName;

//===================================================================
void() Security_Camera_Idle =
{
	if (Security_Camera_FindTarget())
		self.nextthink = time + 2; //CH if found wait 2 sec before do another check
	else
		self.nextthink = time + 0.5; //CH else 2 checks per sec
	self.think = Security_Camera_Idle;
};
//========
float() Security_Camera_FindTarget =
{
	local entity client = nil;
	local float	r, gotone, loopc;

	if (self.is_malfunctioning & SCREWUP_TWO) // SB how tragic, camera can't see
		return FALSE;
		
	if (self.is_malfunctioning & SCREWUP_THREE) // oh no, we're reading incorrect signals
	{
		if (Security_Camera_FindFakeTarget())
			return TRUE;
		else
			return FALSE;
	}

	// Try a few checks to make it react faster
	r = 0;
	loopc = 0;
	gotone = FALSE;

    local float trange; //- OfN - Hack
    trange=1000;

    if (self.num_mines & IMPROVED_ONE)
        trange=1250;

	//CH Theortetically this will check every client on the server now
	while (loopc < 32 && gotone == FALSE)
	{
		client = checkclient();
		gotone = TRUE;

		if (!client)
			gotone = FALSE;

		if (!Pharse_Client(client, self, 1, trange, 0, 1))
			gotone = FALSE;

		loopc = loopc + 1;
		if (gotone) loopc = 1000;
	}

	if (!gotone)
		return FALSE;

	// Found a Target
	self.enemy = client;
	if (self.enemy.classname != "player")
	{
		self.enemy = self.enemy.enemy;
		if (self.enemy.classname != "player")
		{
			self.enemy = nil;
			return FALSE;
		}
	}
	
	// Spotted sound
	if (self.heat == 3) { //CH so it does not beep all the time.
		sound (self, CHAN_WEAPON, "weapons/camera_beep.wav", 1, ATTN_NORM);
		self.heat = 0;
	}
	else
		self.heat = self.heat + 1;

	Security_Camera_PrintTarget ();

	return TRUE;
};

float() Security_Camera_FindFakeTarget =
{
	local entity client = nil;
	local float	r, gotone, loopc;

	if (self.is_malfunctioning & SCREWUP_THREE) // SB how tragic, camera can't see
		return FALSE;

	// Try a few checks to make it react faster
	r = 0;
	loopc = 0;
	gotone = FALSE;
	// Pick a random client
	while (loopc < 32 && gotone == FALSE)
	{
		client = checkclient();
		gotone = TRUE;

		if (!client)
			gotone = FALSE;

		if (random() < 0.05)
			gotone = FALSE;

		if (client.playerclass == PC_UNDEFINED) {
			return FALSE;
		}
		if (client.done_custom & CUSTOM_BUILDING) {
			return FALSE;
		}
		if (client.health <= 0) {
			return FALSE;
		}
		if (client.has_disconnected) {
			return FALSE;
		}
		loopc = loopc + 1;
		if (gotone) loopc = 1000;
	}

	if (!gotone)
		return FALSE;

	// Found a Target
	self.enemy = client;
	if (self.enemy.classname != "player")
	{
		self.enemy = self.enemy.enemy;
		if (self.enemy.classname != "player")
		{
			self.enemy = nil;
			return FALSE;
		}
	}
	
	// Spotted sound
	if (self.heat == 3) { //CH so it does not beep all the time.
		sound (self, CHAN_WEAPON, "weapons/camera_beep.wav", 1, ATTN_NORM);
		self.heat = 0;
	}
	else
		self.heat = self.heat + 1;

	if (!(self.is_malfunctioning & SCREWUP_ONE))
		Security_Camera_PrintTarget ();

	return TRUE;
};
//========
void(entity attacker, float damage) Security_Camera_Pain =
{
	sound (self, CHAN_WEAPON, "weapons/camera_beep.wav", 1, ATTN_NORM);
};
//======
void() Security_Camera_Die =
{
	sprint(self.real_owner, PRINT_HIGH, "Your security camera was destroyed.\n");
	self.real_owner.has_camera = FALSE;

//	ThrowGib("progs/tgib1.mdl", -70);
//	ThrowGib("progs/tgib2.mdl", -70);
//	ThrowGib("progs/tgib3.mdl", -70);

	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_EXPLOSION);
	WriteCoord (MSG_MULTICAST, self.origin.x);
	WriteCoord (MSG_MULTICAST, self.origin.y);
	WriteCoord (MSG_MULTICAST, self.origin.z);
	multicast (self.origin, MULTICAST_PHS);
    dremove(self);
    //SwitchFromCamera();
};
//==========
//Prints the person to owner/team
//Outputs: "<>SECURITY CAMERA<>  Team_color class/job (netname)\n"
void() Security_Camera_PrintTarget =
{
	local string st;

	sprint(self.real_owner, PRINT_HIGH, "сецуриты цамера  "); //<>Security camera<>
	st = GetTrueTeamName(self.enemy.team_no);
	sprint(self.real_owner, PRINT_HIGH, st);

	sprint(self.real_owner, PRINT_HIGH, " ");
			if (self.enemy.playerclass != PC_CUSTOM)
				st = TeamFortress_GetClassName(self.enemy.playerclass);
			else 
				st = TeamFortress_GetJobName(self.enemy.job);
	sprint(self.real_owner, PRINT_HIGH, st);
	sprint(self.real_owner, PRINT_HIGH, " (");
	sprint(self.real_owner, PRINT_HIGH, self.enemy.netname);
	sprint(self.real_owner, PRINT_HIGH, ")\n");
};
//==========
void() Security_Camera_Spawn =
{
	if (self.ammo_cells < BUILD_COST_CAMERA)
	{
		sprint(self,PRINT_HIGH,"Not enough cells to build a Security Camera\n");		
	}
	else
	{
	self.ammo_cells = self.ammo_cells - BUILD_COST_CAMERA;
	self.has_camera = TRUE;
	newmis = spawn();
	newmis.movetype = MOVETYPE_BOUNCE;
	newmis.solid = SOLID_BBOX;
	setsize (newmis, '-16 -16 -3', '16 16 5');
//	setsize (newmis, '-8 -8 -8', '8 8 8');
	newmis.takedamage = DAMAGE_AIM;
	newmis.classname = "building_camera";
	newmis.netname = "security_camera";
	newmis.origin = self.origin;
	newmis.owner = self;
	newmis.real_owner = self;
	makevectors (self.v_angle);
	newmis.avelocity = '0 0 0';
	newmis.velocity = v_forward*800 + v_up * 200 + v_right*10 + v_up*10;
	setorigin(newmis, newmis.origin);
	newmis.angles = '0 0 0';
	newmis.angles.y = anglemod(self.angles.y + 180);
//	newmis.skin = 1;
	newmis.th_die = Security_Camera_Die; 		// Death function
	newmis.th_pain = Security_Camera_Pain;
	newmis.mdl = "progs/camera.mdl"; //CH temp model
	setmodel (newmis, newmis.mdl);
	newmis.team_no = self.team_no;
	newmis.colormap = self.colormap;
	newmis.heat = 0; //Beeps

	newmis.think = Security_Camera_Die;
	newmis.nextthink = time + 5;

	newmis.health = newmis.max_health = BUILD_HEALTH_CAMERA;
	newmis.touch = SecurityCameraTossTouch;

    newmis.num_mines=0; // OfN - reset HACKER improvements

	W_SetCurrentAmmo();
	}
};
//========
void() SecurityCameraTossTouch = 
{
	if (other || other == self.real_owner)
		return;
	self.owner = nil;
	local int pc = entpointcontents(self);
	if (pc == CONTENTS_SOLID || pc == CONTENTS_SKY)
	{
		Security_Camera_Die();
		return;
	}

	sprint (self.real_owner, PRINT_HIGH, "You finish building the Security Camera.\n");

    teamprefixsprint(self.real_owner.team_no,self.real_owner); //- OfN
    teamsprint(self.real_owner.team_no, self.real_owner, self.real_owner.netname);
	teamsprint(self.real_owner.team_no, self.real_owner, " has built a Security Camera.\n");

    self.real_owner.option = time + 2; // so ppl cant destroy it for 2 seconds

	self.movetype = MOVETYPE_NONE;
	setsize (self, self.mins, self.maxs);
	self.takedamage = DAMAGE_AIM;
	sound (self, CHAN_WEAPON, "weapons/guerilla_set.wav", 1, ATTN_NORM);
	self.think = Security_Camera_Idle;
	self.nextthink = time + 1;
};
