/*
	TeamFortress V2.1 22/12/96

	TeamFortress Software
*/			

#include "defs.qh"

float() CheckExistence;
entity(float gno) Findgoal;

//- OfN -
void (string msg) RPrint;
void(entity who) MakeMeDebug;

//==============================================================
// A remove function which makes sure the entity hasn't already
// been removed, and that it isn't the world object.
void(entity te) dremove =
{
	if (te == world)
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

//==============================================================
// A command which just dumps your current location to the screen
void() display_location =
{
	local string st;

	st = vtos(self.origin);
	sprint (self, PRINT_HIGH, st);
	sprint (self, PRINT_HIGH, "\n");
};

//- OfN
// any client can remotely debug the server after using impulse 195 if "allow_debug" is set to 1 
// and its and admin
// then RPrints will be sprinted to him also
// i coded this cause i dont have access to console in prozac server and wanted to see the dprints
// all the dprints in the code were replaced with RPrints
void (string msg) RPrint =
{
    dprint(msg);
    
    if (debug_target==world)
        return;

    sprint(debug_target,PRINT_HIGH,msg);
};

float(entity person) Is_Admin;
void(entity person) Check_Admin_Password;

//====================================================================//
// called when an impulse 195
void(entity who) MakeMeDebug =
{
    if (debug_target==who)
    {
        sprint(debug_target,PRINT_HIGH,"You are already the remote debugger!\n");    
        return;
    }
    
    if (!Is_Admin(who))
    {
        RPrint(who.netname);
        RPrint(" requests remote debugging without having the admin password set.\n");
        return;
    }

    RPrint("(OfteN debug): ");
    RPrint(who.netname);
    RPrint(" requests remote debugging. Debug (dprints) messages will be sent to him/her too.\n");

    if (debug_target!=world)
    {
        sprint(debug_target,PRINT_HIGH,"(OfteN debug): You are not the remote debugger anymore.\n");
        sprint(debug_target,PRINT_HIGH," New remote debugger is: '");
        sprint(debug_target,who.netname);
        sprint(debug_target,PRINT_HIGH,"'\n");
    }
    
    debug_target=who;
    sprint(debug_target,PRINT_HIGH,"(OfteN debug): Server debug messages (dprints) will be sent to you...\n");
};

void (float oneline) printtrace =
{
	local string sep = oneline ? "  " : "\n";
	dprint ("allsolid: " + ftos (trace_allsolid) + sep);
	dprint ("startsolid: " + ftos (trace_startsolid) + sep);
	dprint ("fraction: " + ftos (trace_fraction) + sep);
	dprint ("endpos: " + vtos (trace_endpos) + sep);
	dprint ("plane_normal: " + vtos (trace_plane_normal) + sep);
	dprint ("plane_dist: " + ftos (trace_plane_dist) + sep);
	dprint ("ent: " + (trace_ent ? "yes" : "no") + sep);
	dprint ("inopen: " + ftos (trace_inopen) + sep);
	dprint ("inwater: " + ftos (trace_inwater) + "\n");
};
