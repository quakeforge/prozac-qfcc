#include "defs.qh"
#include "waypoint.qh"

/*
	Generic WayPoint code

	The datastructures are intentionally obscured so that they can be
	changed when we have more powerful stuff.
*/

// is adding fields in individual files bad practice?  well, it's not
// like they're supposed to be accessed externally
.vector waypoint0;
.vector waypoint1;
.vector waypoint2;
.vector waypoint3;
.integer waypoint_count;

#define MAX_WAYPOINTS 4
#define WAYPOINT_TOUCHDIST 50

/* private functions */
vector (entity ent, integer index) _Waypoint_Get;
void (entity ent, integer index, vector loc) _Waypoint_Set;
/* end private functions */

boolean (entity ent, integer index) Waypoint_IsValid =
{
	return index > 0 && index < ent.waypoint_count;
};

integer (entity ent) Waypoint_Count =
{
	return ent.waypoint_count;
};

vector (entity ent, integer index) Waypoint_Get =
{
	if (!Waypoint_IsValid (ent, index))
		error ("Waypoint_Get: invalid waypoint.\n");
	return _Waypoint_Get (ent, index);
};

void (entity ent, integer index, vector loc) Waypoint_Set =
{
	if (!Waypoint_IsValid (ent, index))
		error ("Waypoint_Set: invalid waypoint.\n");
	_Waypoint_Set (ent, index, loc);
};

void (entity ent, vector loc) Waypoint_Append =
{
	Waypoint_Add (ent, ent.waypoint_count, loc);
};

boolean (entity ent, integer index) Waypoint_IsTouching =
{
	return vlen(Waypoint_Get (ent, index) - ent.origin) < WAYPOINT_TOUCHDIST;
};

void (entity ent, integer index, vector loc) Waypoint_Add =
{
	local integer i;

	if (ent.waypoint_count >= MAX_WAYPOINTS)
		error ("Waypoint_Add: maximum waypoints hit!\n");

	// I error here because I want ent.waypoint_count to be used when
	// appending, not MAX_WAYPOINTS
	if (index > ent.waypoint_count)
		error ("Waypoint_Add: index past end of array.\n");

	// Make room for new waypoint
	for (i = ent.waypoint_count; i >= index; i -= 1)
		_Waypoint_Set (ent, i + 1, _Waypoint_Get (ent, i));

	_Waypoint_Set (ent, index, loc);
	ent.waypoint_count += 1;
};

void (entity ent, integer index) Waypoint_Remove =
{
	local integer i;

	if (!Waypoint_IsValid (ent, index))
		error ("Waypoint_Remove: bad index number.\n");

	ent.waypoint_count -= 1;

	for (i = index; i < ent.waypoint_count; i += 1)
		_Waypoint_Set (ent, i, _Waypoint_Get (ent, i + 1));

	_Waypoint_Set (ent, i, '0 0 0'); // pointless, but what the hell..
};


/* Internally used functions.  Don't call them from outside this file. */
vector (entity ent, integer index) _Waypoint_Get =
{
	if (index == 0)
		return ent.waypoint0;
	else if (index == 1)
		return ent.waypoint1;
	else if (index == 2)
		return ent.waypoint2;
	else if (index == 3)
		return ent.waypoint3;
	else
		error ("_Waypoint_Get: bad waypoint index!\n");
};

void (entity ent, integer index, vector loc) _Waypoint_Set =
{
	if (index == 0)
		ent.waypoint0 = loc;
	else if (index == 1)
		ent.waypoint1 = loc;
	else if (index == 2)
		ent.waypoint2 = loc;
	else if (index == 3)
		ent.waypoint3 = loc;
	else
		error ("_Waypoint_Set: bad waypoint index!\n");
};
