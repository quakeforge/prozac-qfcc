#include "defs.qh"
/*
	TeamFortress 1.38	-	29/11/96

	TeamFortress Software
	Robin Walker, John Cook, Ian Caughley.

	Original Code by "Mike" <amichael@asu.alasu.edu>
	QuakeWorld version by Wedge
*/

/*
	Modified for CustomTF 2.3 3/28/00
	William Kerney
	Removed the ability to hook onto or damage teammates
	Stopped some crashing bugs with it
*/

// QuakeWorld version

/*
===========================================================================
Quakeworld-friendly grapple hook code by Wedge (Steve Bond)
           visit Quake Command http://www.nuc.net/quake 


Original 'Morning Star' (Grapple Hook) by "Mike" <amichael@asu.alasu.edu> 
I took care to preserve the speed and damage values of the original
Morning Star. Depending on latency, performance should be near exact.
===========================================================================
*/

// prototypes for WEAPONS.QC functions
float() crandom;
void (entity base) Remove_Chain;

//
// Reset_Grapple - Removes the hook and resets its owner's state.
//                 expects a pointer to the hook
//
void (entity rhook) Reset_Grapple =
{
	sound (rhook.owner, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NONE);

	if (rhook.goalentity) {
		Remove_Chain (rhook.goalentity);
	}

	rhook.owner.on_hook = FALSE;
	rhook.owner.hook_out = FALSE;
	rhook.owner.fire_held_down = FALSE;
	rhook.owner.weaponframe = 0;
	rhook.owner.gravity = 1; // FIXME: interferes with other gravity stuff
	rhook.owner.hook = NIL;

	rhook.think = SUB_Remove;
	rhook.nextthink = time;
};

//
// Grapple_Track - Constantly updates the hook's position relative to
//                 what it's hooked to. Inflicts damage if attached to
//                 a player that is not on the same team as the hook's
//                 owner.
//
void () Grapple_Track =
{
	// drop the hook if owner is dead or has released the button
	if (!self.owner.on_hook || self.owner.health <= 0) {
		Reset_Grapple (self.owner.hook);
		return;
	}

	if (self.owner.health <= 0 || self.owner.has_disconnected) { //CH does a real check if dead
		Reset_Grapple (self.owner.hook);
		return;
	}

	if (!self.enemy.solid) {
		Reset_Grapple (self.owner.hook);
		return;
	}

//WK
	if (self.enemy.classname == "player" && Teammate(self.enemy.team_no, self.owner.team_no)) {
		Reset_Grapple (self.owner.hook);
		return;
	}

	deathmsg = DMSG_HOOK;
	if (self.enemy.classname == "player") {
		T_Damage (self.enemy, self, self.owner, 2);
		if (self.enemy.health <= 0) {
			Reset_Grapple (self.owner.hook);
			return;
		}
	}

	// If the hook is not attached to the player, constantly
	// copy the target's velocity. Velocity copying DOES NOT work properly
	// for a hooked client. 
	if (self.enemy.classname != "player")
		self.velocity = self.enemy.velocity;

	self.nextthink = time + 0.1;
};

//
// MakeLink - spawns the chain link entities
//
entity () MakeLink =
{
	newmis = spawn ();

	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_NOT;
	newmis.owner = self;// SELF is the hook!

	newmis.avelocity = '200 200 200';

	setmodel (newmis, "progs/s_spike.mdl");
	setorigin (newmis, self.origin);
	setsize (newmis, '0 0 0' , '0 0 0');

	return  newmis;
};

//
// Remove_Chain - Removes all chain link entities; this is a separate
//                function because CLIENT also needs to be able
//                to remove the chain. Only one function required to
//                remove all links.
//
void (entity base) Remove_Chain =
{
	base.think = SUB_Remove;
	base.nextthink = time;
	if (base.goalentity) {
		base.goalentity.think = SUB_Remove;
		base.goalentity.nextthink = time;
		if (base.goalentity.goalentity) {
			base.goalentity.goalentity.think = SUB_Remove;
			base.goalentity.goalentity.nextthink = time;
		}
	}

	base.owner.hook.goalentity = NIL;
};

//
// Update_Chain - Repositions the chain links each frame. This single function
//                maintains the positions of all of the links. Only one link
//                is thinking every frame. 
//
void () Update_Chain =
{
	local vector temp;

	if (!self.owner.hook_out)
	{
//		Remove_Chain (self);
		return;
	}

	//CH Using a show grapple loc thing,  it was updating while dead.
	if (self.owner.health <= 0 || self.owner.has_disconnected)
	{
		Reset_Grapple (self.owner.hook);
		return;
	}

	// reset if it gets insane
	if (vlen (self.origin - self.owner.origin) >= 3000) {
		Reset_Grapple (self.owner.hook);
		return;
	} else if (!self.owner.on_hook && vlen (self.owner.hook.velocity) < 10) {
		Reset_Grapple (self.owner.hook);
		return;
	}

	temp = (self.owner.hook.origin - self.owner.origin);

	// These numbers are correct assuming 3 links.
	// 4 links would be *20 *40 *60 and *80
	setorigin (self, self.owner.origin + temp * 0.25);
	setorigin (self.goalentity, self.owner.origin + temp * 0.5);
	setorigin (self.goalentity.goalentity, self.owner.origin + temp * 0.75);
	self.velocity = '0 0 0';
	self.goalentity.velocity = '0 0 0';
	self.goalentity.goalentity.velocity = '0 0 0';

	self.nextthink = time + 0.1;
};

//
// Build_Chain - Builds the chain (linked list)
//
void () Build_Chain =
{
	self.goalentity = MakeLink();
	self.goalentity.think = Update_Chain;
	self.goalentity.nextthink = time + 0.1;
	self.goalentity.owner = self.owner;

	self.goalentity.goalentity = MakeLink();
	self.goalentity.goalentity.owner = self.owner;

	self.goalentity.goalentity.goalentity = MakeLink();
	self.goalentity.goalentity.goalentity.owner = self.owner;
};

//
// Check_Overhead - Makes sure there is sufficient headroom above the player
//                  so that setorigin doesn't stick them into a wall. I tried
//                  to compare pointcontents, but that was too flaky.
//
float () Check_Overhead =
{

	makevectors (self.owner.angles);

	// The following comparisons could be optimized by doing away with
	// SRC and END, and plugging the values directly into the traceline
	// function calls. Using SRC and END made debugging easier. You
	// decide if it's worth it.
	
	// argh, checkmove makes this SO much easier

	checkmove(self.owner.origin, self.owner.mins, self.owner.maxs, self.owner.origin + '0 0 1', MOVE_NORMAL, self.owner);

	if (trace_fraction != 1.0)
		return FALSE;

	return TRUE;
};


//
// Anchor_Grapple - Tries to anchor the grapple to whatever it touches
//
void () Anchor_Grapple =
{
	local float test;

	if (other == self.owner)
		return;

	// DO NOT allow the grapple to hook to any projectiles, no matter WHAT!
	// if you create new types of projectiles, make sure you use one of the
	// classnames below or write code to exclude your new classname so
	// grapples will not stick to them.
	if (other.classname == "missile"
		|| other.classname == "grenade"
		|| other.classname == "spike"
		|| other.classname == "hook"
		|| other.classname == "pipebomb"
		|| other.classname == "force_field") //CH maybe fix crash?
			return;

	if (IsBuilding(other)) //WK don't hook onto buildings? GR Yes, this caused bug
		return;

	// Don't stick the the sky.
	if (pointcontents(self.origin) == CONTENTS_SKY)
	{
		Reset_Grapple (self);
		return;
	}

	sound (self, CHAN_WEAPON, "player/axhit2.wav", 1, ATTN_NORM);
	//WK Only deal the initial damage to buttons so we can open stuff
	if (other.takedamage)
		if (other.classname == "func_button")
			T_Damage (other, self, self.owner, 1);

	self.velocity = '0 0 0';
	self.avelocity = '0 0 0';

	// conveniently clears the sound channel of the CHAIN1 sound,
	// which is a looping sample and would continue to play. Tink1 is
	// the least offensive choice, as NULL.WAV loops and clogs the
	// channel with silence
	sound (self.owner, CHAN_WEAPON, "weapons/tink1.wav", 1, ATTN_NORM);

	if (!self.owner.button0)
	{
		Reset_Grapple (self);
		return;
	}

	// our last chance to avoid being picked up off of the ground.
	// check over the client's head to make sure there is one unit
	// clearance so we can lift him off of the ground.
	test = Check_Overhead ();
	if (!test)
	{
		Reset_Grapple (self);
		return;
	}

	self.owner.on_hook = TRUE;

	if (self.owner.flags & FL_ONGROUND)
	{
		self.owner.flags = self.owner.flags - FL_ONGROUND;
		setorigin(self.owner,self.owner.origin + '0 0 1');
	}

	// CHAIN2 is a looping sample. Use LEFTY as a flag so that client.qc
	// will know to only play the tink sound ONCE to clear the weapons
	// sound channel. (Lefty is a leftover from AI.QC, so I reused it to
	// avoid adding a field)
	self.owner.lefty = TRUE;

	self.enemy = other;// remember this guy!
	self.think = Grapple_Track;
	self.nextthink = time;
	self.solid = SOLID_NOT;
	self.touch = NIL;
};


//
// Throw_Grapple - called from WEAPONS.QC, 'fires' the grapple
//
void () Throw_Grapple =
{
	if (self.hook_out)// reject subsequent calls from player.qc
		return;

		KickPlayer(-1, self);

	// chain out sound (loops)

	newmis = spawn();
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;
	newmis.owner = self;// newmis belongs to me
	self.hook = newmis;// This is my newmis
	newmis.classname = "hook";

	makevectors (self.v_angle);
	newmis.velocity = v_forward * 800;
//	newmis.avelocity = '0 0 -500';

	// set the facing of the grapple
	newmis.angles = vectoangles(newmis.velocity);

	newmis.touch = Anchor_Grapple;
	newmis.think = Build_Chain;
	newmis.nextthink = time + 0.1;// don't jam newmis and links into same packet

	setmodel (newmis,"progs/hook.mdl");
	setorigin (newmis, self.origin + v_forward * 16 + '0 0 16');
	setsize(newmis, '0 0 0' , '0 0 0 ');

	self.hook_out = TRUE;
	self.fire_held_down = TRUE;
};

//
// Service_Grapple - called each frame by CLIENT.QC if client is ON_HOOK
//
void () Service_Grapple =
{
	local   vector  hook_dir;

	self.gravity = 0;

	// drop the hook if player lets go of button
	if (!self.button0)
	{
		self.fire_held_down = FALSE;

		if (self.current_weapon == WEAP_HOOK) {
			Reset_Grapple (self.hook);
			return;
		}
	}
	// If hooked to a player, track them directly!
	if (self.hook.enemy.classname == "player")
		hook_dir = (self.hook.enemy.origin - self.origin);
	else // else, track to hook
		hook_dir = (self.hook.origin - self.origin);

	// set the facing of the grapple
//	self.hook.angles = vectoangles(self.hook.velocity);

	self.velocity = normalize(hook_dir) * self.maxspeed * 1.5;

	if (vlen(hook_dir) <= 100 && self.lefty)	// cancel chain sound
	{
		// If there is a chain, ditch it now. We're
		// close enough. Having extra entities lying around
		// is never a good idea.
		if (self.hook.goalentity) {
			Remove_Chain (self.hook.goalentity);
		}

		self.lefty = FALSE;	// we've reset the sound channel.
	}
};
