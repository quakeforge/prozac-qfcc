// button and multiple button
#include "defs.qh"

#define BUTTON_START_OUT	32 

void() button_wait;
void() button_return;

void() button_wait =
{
	self.state = STATE_TOP;
	self.nextthink = self.ltime + self.wait;
	self.think = button_return;
	activator = self.enemy;
	SUB_UseTargets();
	self.frame = 1;			// use alternate textures
};

void() button_done =
{
	self.state = STATE_BOTTOM;
};

void() button_return =
{
	self.goal_state = TFGS_INACTIVE;

	self.state = STATE_DOWN;
	SUB_CalcMove (self.pos1, self.speed, button_done);
	self.frame = 0;			// use normal textures
	if (self.health)
		self.takedamage = DAMAGE_YES;	// can be shot again
};


void() button_blocked =
{	// do nothing, just don't come all the way back out
};


void() button_fire =
{
	if (self.state == STATE_UP || self.state == STATE_TOP)
		return;

	sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);

	self.state = STATE_UP;
	SUB_CalcMove (self.pos2, self.speed, button_wait);
};


void() button_use =
{
	self.enemy = activator;
	button_fire ();
};

/*void() button_touch =
{
	local entity te;

	if (other.classname != "player")
		return;

	if (self.goal_activation & TFGA_SPANNER)
		return;

	if (!Activated(self,other))
	{
		// If an else goal should be activated, activate it
		if (self.else_goal != 0)
		{
			te = Findgoal(self.else_goal);
			if (te)
				DoResults(te, other, (self.goal_result & TFGR_ADD_BONUSES));
		}

		return;
	}

	self.enemy = other;
	button_fire ();
};*/

void() button_touch =
{
	local entity te;

	if (other.classname != "player")
		return;

    // OfN --------------------------------------//
    //- BUGFIX Avoid observers touching buttons  //
	if (other.playerclass == PC_UNDEFINED)
		return;
    //------------------------------------------//

	if (self.goal_activation & TFGA_SPANNER)
		return;

	if (!Activated(self,other))
	{
		// If an else goal should be activated, activate it
		if (self.else_goal != 0)
		{
			te = Findgoal(self.else_goal);
			if (te)
				DoResults(te, other, (self.goal_result & TFGR_ADD_BONUSES));
		}

		return;
	}

	self.enemy = other;
	button_fire ();
};


void() button_killed =
{
	if (self.goal_activation & TFGA_SPANNER)
		return;

	self.enemy = damage_attacker;
	self.health = self.max_health;
	self.takedamage = DAMAGE_NO;	// wil be reset upon return
	button_fire ();
};


/*QUAKED func_button (0 .5 .8) ?
When a button is touched, it moves some distance in the direction of it's angle, triggers all of it's targets, waits some time, then returns to it's original position where it can be triggered again.

"angle"		determines the opening direction
"target"	all entities with a matching targetname will be used
"speed"		override the default 40 speed
"wait"		override the default 1 second wait (-1 = never return)
"lip"		override the default 4 pixel lip remaining at end of move
"health"	if set, the button must be killed instead of touched
"sounds"
0) steam metal
1) wooden clunk
2) metallic click
3) in-out

TF Note:
If the spawnflags has the BUTTON_START_OUT (32), then the button
will automatically fire at the start of the level, allowing you
to light in the out position.

*/
void() func_button =
{
	if (CheckExistence() == FALSE)
	{
		dremove(self);
		return;
	}

	if (self.sounds == 0)
	{
		precache_sound ("buttons/airbut1.wav");
		self.noise = "buttons/airbut1.wav";
	}
	if (self.sounds == 1)
	{
		precache_sound ("buttons/switch21.wav");
		self.noise = "buttons/switch21.wav";
	}
	if (self.sounds == 2)
	{
		precache_sound ("buttons/switch02.wav");
		self.noise = "buttons/switch02.wav";
	}
	if (self.sounds == 3)
	{
		precache_sound ("buttons/switch04.wav");
		self.noise = "buttons/switch04.wav";
	}
	
	SetMovedir ();

	self.movetype = MOVETYPE_PUSH;
	self.solid = SOLID_BSP;
	setmodel (self, self.model);

	self.blocked = button_blocked;
	self.use = button_use;

	if (self.health)
	{
		self.max_health = self.health;
		self.th_die = button_killed;
		self.takedamage = DAMAGE_YES;
	}
	else
		self.touch = button_touch;

	if (!self.speed)
		self.speed = 40;
	if (!self.wait)
		self.wait = 1;
	if (!self.lip)
		self.lip = 4;

	self.state = STATE_BOTTOM;

	self.pos1 = self.origin;
	self.pos2 = self.pos1 + self.movedir*(fabs(self.movedir*self.size) - self.lip);

	if (self.spawnflags & BUTTON_START_OUT)
		button_fire ();
};


