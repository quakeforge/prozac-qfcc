#include "defs.qh"

entity () real_spawn;
void (entity ent) initentity;

entity () spawn =
{
	local entity ent;

	ent = real_spawn ();
	initentity (ent);

	return ent;
};

void (entity ent) initentity =
{
	ent.classname = "";
	ent.netname = "";
	ent.targetname = "";
	ent.target = "";
	ent.team_str_home = "";
	ent.flame_id = "";
	ent.group = "";
	ent.message = "";

//	self.solid = SOLID_NOT;
//	self.movetype = MOVETYPE_NONE;
//	setmodel (self, "");
//	ent.model = "";
};
