/*
	TeamFortress V2.1 22/12/96

	TeamFortress Software
*/			

#include "defs.qh"

float() CheckExistence;
entity(float gno) Findgoal;

//- OfN -
void (string msg) Real_RPrint;
void(entity who) MakeMeDebug;

//==============================================================
// A remove function which makes sure the entity hasn't already
// been removed, and that it isn't the NIL object.
#ifdef DEBUG
void(entity te) dremove =
{
	if (!te)
	{
		RPrint("***BUG BUG BUG BUG BUG BUG BUG BUG BUG BUG***\n");
		RPrint("WORLD has nearly been removed. Don't worry!\n");
		RPrint("***BUG BUG BUG BUG BUG BUG BUG BUG BUG BUG***\n"); 
		return;
	}

    if (te.classname == "player") //- OfN -
	{
		RPrint("***BUG BUG BUG BUG BUG BUG BUG BUG BUG BUG***\n");
		RPrint("Player entity was going to be removed. Don't worry!\n");
		RPrint("***BUG BUG BUG BUG BUG BUG BUG BUG BUG BUG***\n"); 
		return;
	}
#if 0
	if (te.is_removed == TRUE)
	{
		RPrint("***BUG BUG BUG BUG BUG BUG BUG***\n");
		RPrint("  Entity has been removed twice. \n");
		RPrint("***BUG BUG BUG BUG BUG BUG BUG***\n"); 
		return;
	}
#endif

	te.is_removed = TRUE;
	remove(te);
};
#endif

//==============================================================
// A command which just dumps your current location to the screen

//- OfN
// any client can remotely debug the server after using impulse 195 if "allow_debug" is set to 1 
// and its and admin
// then RPrints will be sprinted to him also
// i coded this cause i dont have access to console in prozac server and wanted to see the dprints
// all the dprints in the code were replaced with RPrints
void (string msg) Real_RPrint =
{
    dprint(msg);
    
    if (!debug_target)
        return;

    sprint(debug_target,PRINT_HIGH,msg);
};

void (float oneline) printtrace =
{
	local string sep = oneline ? "  " : "\n";
	RPrint ("allsolid: " + ftos (trace_allsolid) + sep);
	RPrint ("startsolid: " + ftos (trace_startsolid) + sep);
	RPrint ("fraction: " + ftos (trace_fraction) + sep);
	RPrint ("endpos: " + vtos (trace_endpos) + sep);
	RPrint ("plane_normal: " + vtos (trace_plane_normal) + sep);
	RPrint ("plane_dist: " + ftos (trace_plane_dist) + sep);
	RPrint ("ent: " + (trace_ent ? trace_ent.classname : "no") + sep);
	RPrint ("inopen: " + ftos (trace_inopen) + sep);
	RPrint ("inwater: " + ftos (trace_inwater) + "\n");

	if (trace_ent.solid == SOLID_NOT)
		RPrint ("SV_Move on crack: clipped on SOLID_NOT.");
	else if (trace_ent.solid == SOLID_TRIGGER)
		RPrint ("SV_Move on crack: clipped on SOLID_TRIGGER.");
};
