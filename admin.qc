/* 

	Functions handling TeamFortress Administration for Net Servers
	!NOTE! parm15 is used to pass admin status across maps
*/

#include "defs.qh"

#ifdef QUAKE_WORLD
//Goes for whole file
float() Admin_is_Disabled = 
{
    local string st;
    st = infokey(world, "no_admin");
    if (st == "1" || st == "on")
    {
        sprint(self, PRINT_HIGH, "All admin actions are disabled.\n");
        return TRUE;
    }
     
    return FALSE;
};

float(entity theAdmin) HasValidAdminTarget =
{
    if (theAdmin.admin_kick.classname != "player") {
        sprint(theAdmin, PRINT_HIGH, "No user selected!\n");
        theAdmin.admin_kick = world;
        return FALSE;
    }
    if (theAdmin.admin_kick.has_disconnected) {
        sprint(theAdmin, PRINT_HIGH, "User has disconnected!\n");
        theAdmin.admin_kick = world;
        return FALSE;
    }

    return TRUE;
};

float(entity person) Is_Admin =
{
	local string pass;

	if (person.admin_flag == TRUE) //I am admin :)
		return TRUE;
	else
	{
		pass = infokey(world, "adminpwd");
		if (pass != string_null)
		{
			if (infokey(person, "adminpwd") == pass)
			{
				person.admin_flag = TRUE;
				stuffcmd(person, "setinfo adminpwd \"\"\n"); //Remove from info
				return TRUE;
			}
		}
	}
	person.admin_flag = FALSE;
	return FALSE;			
};
void(entity person) Check_Admin_Password =
{
	if (person.admin_flag)
    {
        sprint(person, PRINT_HIGH, "You already have access as admin!\n");
        stuffcmd(person, "setinfo adminpwd \"\"\n"); //Remove from info
        return;
    }

    local string pass;
    pass = infokey(world, "adminpwd");
    if (pass != string_null)
    {
        if (infokey(person, "adminpwd") == pass)
        {
            person.admin_flag = TRUE;
            stuffcmd(person, "setinfo adminpwd \"\"\n"); //Remove from info
            sprint(person, PRINT_HIGH, "Admin password correct...\n");
            return;
        }
    }

    RPrint(person.netname);
    RPrint(" requests admin password check with an incorrect or inexistent password set.\n");
};
void() Admin_Kick_Cycle =
{
	if (!Is_Admin(self)) //If not an admin go away
	{
		sprint(self, PRINT_HIGH, "You are not allowed to use the 'get' command\n");
		return;
	}

    if (Admin_is_Disabled())
        return;

	local entity te;
	local float num;
	local float loopc;
	loopc = 0;
	num = FALSE;

    te = world;
	
    te = find(self.admin_kick, classname, "player");
	while (te != world && num == FALSE)
    {
        num = TRUE;

        if (te.has_disconnected)
            num = FALSE;
        
        if (self.admin_kick==te)
            num = FALSE;
        
        if (num == FALSE) te = find(te, classname, "player");
    }
    
    
    //te = world;
    
    /*while (num == FALSE && loopc < 32)
	{
		num = TRUE;
		te = checkclient();

		if (te.classname != "player")
			num = FALSE;
		else if (te.has_disconnected)
			num = FALSE;
        //- OfN -//
        else if (!te)
            num = FALSE;

        if (self.admin_kick==te)
            num = FALSE;
        
		loopc = loopc + 1;
	}*/
	//if (loopc >= 32) {
    if (te == world) {
		sprint(self, PRINT_HIGH, "No Clients Found!\n");
        self.admin_kick=world;
	} else {
		self.admin_kick = te; //Set current selected person
		//sprint(self, PRINT_HIGH, "You can type כידכ or גבמ to throw them out. Type חופ again to select someone else.");
        sprint(self, PRINT_HIGH, "Ãליומפ: ");
		sprint(self, PRINT_HIGH, self.admin_kick.netname);
        sprint(self, PRINT_HIGH, "\n");

	}
};
void() Admin_Kick_Person =
{
	if (!Is_Admin(self)) //If not an admin go away
	{
		sprint(self, PRINT_HIGH, "You are not allowed to use the 'kick' command\n");
		return;
	}

    if (Admin_is_Disabled())
        return;
    
    if (self.admin_kick != world) //Bad
	{
		//WK Add checks so that it doesn't crash the server!
		/*if (self.admin_kick.classname != "player") {
			self.admin_kick = world;
			return;
		}
		if (self.admin_kick.has_disconnected) {
			self.admin_kick = world;
			return;
		}*/

        if (!HasValidAdminTarget(self))
            return;

		bprint(PRINT_HIGH, self.admin_kick.netname);
		bprint(PRINT_HIGH, " has been kicked by the admin ");
		bprint(PRINT_HIGH, self.netname);
		bprint(PRINT_HIGH, "\n");

		stuffcmd(self.admin_kick, "disconnect\n"); //Kick them!

		self.admin_kick = world; //Clear it //WK BUG! Used to be ==
	}
    else
        sprint(self, PRINT_HIGH, "No target client selected!\n");
};
//WK Same code as Bloggy's, but with some happy code for banning
void() Admin_Ban_Person =
{
	local string foo;
	if (!Is_Admin(self)) //If not an admin go away
	{
		sprint(self, PRINT_HIGH, "You are not allowed to use the 'ban' command\n");
		return;
	}
	
    if (Admin_is_Disabled())
        return;
    
    if (self.admin_kick != world) //Bad
	{
		//WK Add checks so that it doesn't crash the server!
		/*if (self.admin_kick.classname != "player") {
			self.admin_kick = world;
			return;
		}
		if (self.admin_kick.has_disconnected) {
			self.admin_kick = world;
			return;
		}*/

        if (!HasValidAdminTarget(self))
            return;

		bprint(PRINT_HIGH, self.admin_kick.netname);
		bprint(PRINT_HIGH, " has been BANNED by the admin ");
		bprint(PRINT_HIGH, self.netname);
		bprint(PRINT_HIGH, "\n");

		foo = infokey(self.admin_kick,"ip");
		localcmd("addip ");
		localcmd(foo);
		localcmd("\n");

		stuffcmd(self.admin_kick, "disconnect\n"); //Kick them!

		self.admin_kick = world; //Clear it //WK BUG! Used to be ==
	}
    else
        sprint(self, PRINT_HIGH, "No target client selected!\n");
};

void (entity player) RemoveHolo;
float (float tno) TeamFortress_TeamGetLives;
void(entity p) SetTeamName;

//- OfN - my evil addition to the admin stuff
void() Admin_Cmd =
{
	local string st;

	if (!Is_Admin(self)) //If not an admin go away
	{
		sprint(self, PRINT_HIGH, "You are not allowed to use the 'cmnd' command\n");
		return;
	}

    if (Admin_is_Disabled())
        return;

	if (self.admin_kick != world) //Bad
	{
		//WK Add checks so that it doesn't crash the server!
		/*if (self.admin_kick.classname != "player") {
            sprint(self, PRINT_HIGH, "No user selected!\n");
            self.admin_kick = world;
			return;
		}
		if (self.admin_kick.has_disconnected) {
            sprint(self, PRINT_HIGH, "User has disconnected!\n");
			self.admin_kick = world;
            return;
        }*/
        
        if (!HasValidAdminTarget(self))
            return;
    
        st = infokey(self, "cmnd");
        if (st == string_null)
        {
            sprint(self, PRINT_HIGH, "You have no CMND set!\n");
        }
        else if (st == "curse")
        {
            local float tf;
            local string st2;
            
            tf = 0;
            st2 = infokey(world, "curse");
            
            if (st2 == string_null) 
                tf = stof(st2);
            
            bprint(PRINT_HIGH,"The admin ");
            bprint(PRINT_HIGH,self.netname);
            bprint(PRINT_HIGH," curses ");
            bprint(PRINT_HIGH,self.admin_kick.netname);
            bprint(PRINT_HIGH,"\n");

            createBastard(self.admin_kick,tf);

        }
        else if (st == "gimmedat")
        {
            sprint(self.admin_kick,PRINT_HIGH,"If you are using this to cheat, you are LAME!\n");

            self.admin_kick.money = 99999;

        }
        else if (st == "team1" || st == "team2" || st == "team3" || st == "team4")
        {
            local float targetteam, tc;
            local string st2;

            if (st == "team1")
                targetteam = 1;
            else if (st == "team2")
                targetteam = 2;
            else if (st == "team3")
            {
                if (number_of_teams < 3)
                {
                    sprint(self,PRINT_HIGH,"No team 3 on this map!\n");
                    return;
                }                

                targetteam = 3;
            }
            else
            {
                if (number_of_teams < 4)
                {
                    sprint(self,PRINT_HIGH,"No team 4 on this map!\n");
                    return;
                } 

                targetteam = 4;            
            }

            if (self.admin_kick.team_no == targetteam)
            {
                st = ftos(targetteam);
                sprint(self,PRINT_HIGH,"Player ");
                sprint(self,PRINT_HIGH,self.admin_kick.netname);
                sprint(self,PRINT_HIGH," is already on team ");
                sprint(self,PRINT_HIGH,st);
                sprint(self,PRINT_HIGH,"!\n");
                return;
            }

            if (self.admin_kick.playerclass == PC_UNDEFINED)
    		{
                sprint(self,PRINT_HIGH,"Player ");
                sprint(self,PRINT_HIGH,self.admin_kick.netname);
                sprint(self,PRINT_HIGH," is observing the game\n");
               
                return;
            }
    		if (self.admin_kick.done_custom & CUSTOM_BUILDING)
    		{
                sprint(self,PRINT_HIGH,"Player ");
                sprint(self,PRINT_HIGH,self.admin_kick.netname);
                sprint(self,PRINT_HIGH," is still customizing\n");
               
                return;
		    }

            local entity oself;
            oself = self;

            self = self.admin_kick;
            if (self.has_holo > 0 ) RemoveHolo(self);
            kill_my_demon();//FIXED?
        	DetonateMines(self);
            //RemoveArmyTimer();
        	DetonateAllGuns();     
            self = oself;

            // Set the player's color
        	stuffcmd(self.admin_kick, "color ");
        	tc = TeamFortress_TeamGetColor(targetteam) - 1;
        	st2 = ftos(tc);

            //- OfN - Nice colors
            if (nicecolors==1) st2 =TeamGetNiceColor(targetteam);
        
        	stuffcmd(self.admin_kick, st2);
        	stuffcmd(self.admin_kick, "\n");
            
            self.admin_kick.team_no = targetteam;
            makeImmune(self.admin_kick,time+15);

            self.admin_kick.lives = TeamFortress_TeamGetLives(targetteam);

            SetTeamName(self.admin_kick);

            bprint(PRINT_HIGH,"Player ");
            bprint(PRINT_HIGH,self.admin_kick.netname);
            bprint(PRINT_HIGH," is assigned to ");
            if (targetteam == 1)
                bprint(PRINT_HIGH,"team 1\n");
            else if (targetteam == 2)
                bprint(PRINT_HIGH,"team 2\n");
            else if (targetteam == 3)
                bprint(PRINT_HIGH,"team 3\n");
            else bprint(PRINT_HIGH,"team 4\n");

            oself = self;
            self = self.admin_kick;
            PutClientInServer();
            self = oself;                

            return; // job done!

        }
        else
        {
            stuffcmd(self.admin_kick,st); // execute command
            stuffcmd(self.admin_kick,"\n");
            sprint(self,PRINT_HIGH, "Command '");
            sprint(self,PRINT_HIGH, st);
            sprint(self,PRINT_HIGH, "' has been executed for ");
            sprint(self, PRINT_HIGH, self.admin_kick.netname);
            sprint(self, PRINT_HIGH, "\n");
        }
    }
    else
        sprint(self, PRINT_HIGH, "No target client selected!\n");
};

void() Admin_Call_Ceasefire =
{
	local string st;

	if (!Is_Admin(self)) //If not an admin go away
	{
		sprint(self, PRINT_HIGH, "You are not allowed to use the 'ceasefire' command\n");
		return;
	}

    if (Admin_is_Disabled())
        return;

	st = infokey(world, "ceasefire");
	if (st == "on")
	{
		localcmd("localinfo ceasefire \"off\"\n"); //Turn it off
        //bprint(PRINT_HIGH, self.netname);
		bprint(PRINT_HIGH, "The game resumes now...\n");
	}
	else
	{
		localcmd("localinfo ceasefire \"on\"\n"); //Turn it off
        bprint(PRINT_HIGH, self.netname);
		bprint(PRINT_HIGH, " forced a ceasefire.\n");
	}
};
//contains the list of impulses that can be used during ceasefire
//returns TRUE if its good
float(float inp) Good_Impulse =
{
	if (inp == TF_MEDIC_HELPME ||
	inp == TF_TAUNT ||
	inp == TF_TAUNT2 ||
	inp == TF_TAUNT3 ||
	inp == TF_TAUNT4 ||
    inp == TF_TAUNT5 ||
	inp == TF_ADMIN_KICK_CYCLE ||
	inp == TF_ADMIN_KICK_PERSON ||
	inp == TF_ADMIN_BAN_PERSON ||
	inp == TF_STATUS_QUERY ||
	inp == TF_ADMIN_CEASEFIRE ||
	inp == TF_DISPLAYLOCATION   ||
	inp == TF_STATUS_QUERY ||
	inp == TF_HELP_MAP ||
	inp == TF_INVENTORY ||
	inp == TF_SHOWTF ||
	inp == FLAG_INFO ||
	inp == I_CHEAT_ONE ||
	inp == I_CHEAT_TWO ||
	inp == I_CHEAT_THREE || 
    inp == IMPULSE_DEBUG || //- OfN -
    inp == IMPULSE_UPDATEINFO || //- OfN -
    inp == IMPULSE_CHECKADMIN || //- OfN -
    inp == IMPULSE_STUFFCMD) //- OfN -
		return TRUE;

	return FALSE;

};

//contains the list of impulses that can be used during ceasefire
//returns TRUE if its good
float(float inp) Good_Impulse_OnMenu =
{
	if (/*inp == TF_MEDIC_HELPME ||
	inp == TF_TAUNT ||
	inp == TF_TAUNT2 ||
	inp == TF_TAUNT3 ||
	inp == TF_TAUNT4 ||
    inp == TF_TAUNT5 ||*/
	inp == TF_ADMIN_KICK_CYCLE ||
	inp == TF_ADMIN_KICK_PERSON ||
	inp == TF_ADMIN_BAN_PERSON ||
	inp == TF_STATUS_QUERY ||
	inp == TF_ADMIN_CEASEFIRE ||
	inp == TF_DISPLAYLOCATION   ||
	inp == TF_STATUS_QUERY ||
	inp == TF_HELP_MAP ||
	inp == TF_INVENTORY ||
	inp == TF_SHOWTF ||
	inp == FLAG_INFO ||
	inp == I_CHEAT_ONE ||
	inp == I_CHEAT_TWO ||
	inp == I_CHEAT_THREE || 
    inp == IMPULSE_DEBUG || //- OfN -
    inp == IMPULSE_UPDATEINFO || //- OfN -
    inp == IMPULSE_CHECKADMIN || //- OfN -
    inp == IMPULSE_STUFFCMD) //- OfN -
		return TRUE;

	return FALSE;

};

#endif
