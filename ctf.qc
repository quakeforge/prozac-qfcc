#include "defs.qh"
/*
	TeamFortress 1.38	-	11/12/96

	TeamFortress Software
	Functions for CTF Support
*/

// Functions in this file
void() TeamFortress_CTF_FlagInfo;

//=========================================================================
// Display the whereabouts of the flags
void() TeamFortress_CTF_FlagInfo =
{
	local entity te;

	// Flag 1
	te = Finditem(CTF_FLAG1);
	if (te.goal_state == TFGS_ACTIVE)
	{
		if (self == te.owner)
		{
			sprint(self, PRINT_HIGH, "You have the enemy flag. ");
		}
		else
		{
			sprint(self, PRINT_HIGH, te.owner.netname);
			sprint(self, PRINT_HIGH, " has");
			if (self.team_no == 1)
				sprint(self, PRINT_HIGH, " your flag. ");
			else
				sprint(self, PRINT_HIGH, " the enemy flag. ");
		}
	}
	else if (te.origin != te.oldorigin)
	{
		if (self.team_no == 1)
			sprint(self, PRINT_HIGH, "Your flag is lying about. ");
		else
			sprint(self, PRINT_HIGH, "The enemy flag is lying about. ");
	}
	else
	{
		if (self.team_no == 1)
			sprint(self, PRINT_HIGH, "Your flag is in your base. ");
		else
			sprint(self, PRINT_HIGH, "The enemy flag is in their base. ");
	}

	// Flag 2
	te = Finditem(CTF_FLAG2);
	if (te.goal_state == TFGS_ACTIVE)
	{
		if (self == te.owner)
			sprint(self,  PRINT_HIGH, "You have the enemy flag.\n");
		else
		{
			sprint(self, PRINT_HIGH, te.owner.netname);
			sprint(self, PRINT_HIGH, " has");
			if (self.team_no == 2)
				sprint(self, PRINT_HIGH, " your flag.\n");
			else
				sprint(self, PRINT_HIGH, " the enemy flag.\n");
		}
	}
	else if (te.origin != te.oldorigin)
	{
		if (self.team_no == 2)
			sprint(self, PRINT_HIGH, "Your flag is lying about.\n");
		else
			sprint(self, PRINT_HIGH, "The enemy flag is lying about.\n");
	}
	else
	{
		if (self.team_no == 2)
			sprint(self, PRINT_HIGH, "Your flag is in your base.\n");
		else
			sprint(self, PRINT_HIGH, "The enemy flag is in their base.\n");
	}
};
