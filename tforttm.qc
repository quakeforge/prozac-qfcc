/* 
	TeamFortress 2.1	-	22/1/97

	TeamFortress Software
	Robin Walker, John Cook, Ian Caughley.

	Functions handling all the help displaying for TeamFortress. 
*/
#include "defs.qh"
// Prototypes
// Team Functions
float() TeamFortress_TeamPutPlayerInTeam;
float(float tno) TeamFortress_TeamSet;
float(float tno) TeamGetColor;
void(float tno) TeamFortress_TeamSetColor;
void() TeamFortress_CheckTeamCheats;
void(float tno, float scoretoadd) TeamFortress_TeamIncreaseScore;
float(float tno) TeamFortress_TeamGetScore;
float (float tno) TeamFortress_TeamGetLives;
float(float tno) TeamFortress_TeamGetNoPlayers;
float (float tno) TeamFortress_TeamGetMaxPlayers;
float() TeamFortress_TeamGetWinner;
void(float tno) TeamFortress_TeamShowScores;
string(float tno) TeamFortress_TeamGetColorString;
void(entity Player) TeamFortress_TeamShowMemberClasses;
float(float tno) TeamFortress_TeamGetIllegalClasses;
float(float tno) TeamFortress_TeamIsCivilian;
void(entity p) SetTeamName;
string(float tno) GetTrueTeamName;

//-------- OfN ---------------------------------//
void(float tno, entity ignore) teamprefixsprint;

//- OfN - Extra cheat checking...
float (string skin_str) Is_TF_Skin;
float (float tno, float theColor ) IsValidTopColor;

//=========================================================================
// TEAM FUNCTIONS
//=========================================================================
// Put the player into the team with the least number of players in it. Return TRUE if successful
float() TeamFortress_TeamPutPlayerInTeam =
{
	local float lowest, lowest_num;
	local float i, i_num;
	local float teams_with_vacancy = 0;
	local float maxplayers, curplayers;

	for (i = 1; i <= number_of_teams; i = i + 1) {
		maxplayers = TeamFortress_TeamGetMaxPlayers (i);
		curplayers = TeamFortress_TeamGetNoPlayers (i);
		if (curplayers < maxplayers)
			teams_with_vacancy = teams_with_vacancy + 1;
	}

	lowest = 0;
	lowest_num = -1;
	for (i = 1; i <= number_of_teams; i = i + 1) {
		i_num = TeamFortress_TeamGetNoPlayers(i);
		if (TeamFortress_TeamGetMaxPlayers (i) > i_num) {
			if (i_num < lowest_num // eww, ugly
				|| lowest_num == -1
				|| (i_num == lowest_num
					&& random () < 1 / teams_with_vacancy)) {
				lowest = i;
				lowest_num = i_num;
			}
		}
	}

	if (lowest == 0) { // ummm, I don't think this should be possible..
		sprint (self, PRINT_HIGH, "All teams are full!\n");
		return 0;
	}

	return TeamFortress_TeamSet (lowest);
};

//=========================================================================
// Return the color for the team corresponding to the no passed in
float(float tno) TeamGetColor =
{
	if (tno == 1)
		return DARKBLUE;
	if (tno == 2)
		return RED;
	if (tno == 3)
		return YELLOW;
	if (tno == 4)
		return DARKGREEN;

	return 0;
};

//=========================================================================
// Set the color for the team corresponding to the no passed in, to self.team_no
void(float tno) TeamFortress_TeamSetColor =
{
	if (tno == 1)
	{
		team1col = DARKBLUE;
		return;
	}
	if (tno == 2)
	{
		team2col = RED;
		return;
	}
	if (tno == 3)
	{
		team3col = YELLOW;
		return;
	}
	if (tno == 4)
	{
		team4col = DARKGREEN;
		return;
	}
};

string(float tno) GetTeamName =
{
	local string st;

	if (tno == 1)
	{
	    /*if (world.b_b && world.b_b)
        {
            return world.b_b;
        }*/

        st = infokey(NIL, "team1");
		if (!st)
			st = infokey(NIL, "t1");

		if (!st || st == "")
			return "blue";
	}
	else if (tno == 2)
	{
	    /*if (world.b_t != "" && world.b_t)
        {
            return world.b_t;
        }*/
        
        st = infokey(NIL, "team2");
		if (!st)
			st = infokey(NIL, "t2");

		if (!st)
			return "red";
	}
	else if (tno == 3)
	{
		/*if (world.b_n != "" && world.b_n)
        {
            return world.b_n;
        }*/
        
        st = infokey(NIL, "team3");
		if (!st)
			st = infokey(NIL, "t3");

		if (!st)
			return "yell";
	}
	else if (tno == 4)
	{
		/*if (world.b_o != "" && world.b_o)
        {
            return world.b_o;
        }*/

        st = infokey(NIL, "team4");
		if (!st)
			st = infokey(NIL, "t4");

		if (!st)
			return "teal";
	}
	else 
		st = "";

	return st;
};
//returns only the team color
string(float tno) GetTrueTeamName =
{
	if (tno == 1)
		return "Âìõå";
	else if (tno == 2)
		return "Òåä";
	else if (tno == 3)
		return "Ùåììï÷";
	else if (tno == 4)
		return "Çòååî";
	else 
		return "ERROR";
};

void(entity p) SetTeamName =
{
	local string st;

	st = GetTeamName(p.team_no);
	stuffcmd(p, "team \""); //careful about empty team
	stuffcmd(p, st);
	stuffcmd(p, "\"\n");
	setinfokey(p, "team", st);
};

//=========================================================================
// Set the current player's.team_no to self.impulse. Return TRUE if successful
float(float tno) TeamFortress_TeamSet =
{
	local string st;
	local float tc, tc2;

	if (teamplay < 1)
	{
		sprint (self, PRINT_HIGH, "Teamplay is not On, so FortressTeams are inactive.\n");
		return FALSE;
	}
	
/*	if (chris)
		if (prematch > time)
		{
			sprint(self, PRINT_HIGH, "Sorry, Chris' Teamplay Plus Mode is active and a round is in progress. Please wait for the next round to begin.\n");
			PlayerObserverMode();
		}*/

	if (tno > number_of_teams && number_of_teams != 0)
	{
		sprint (self, PRINT_HIGH, "There can be only ");
		st = ftos(number_of_teams);
		sprint (self, PRINT_HIGH, st);
		sprint (self, PRINT_HIGH, " teams on this map.\nTry again\n");
		return FALSE;
	}

	if (self.team_no > 0)
	{
		sprint (self, PRINT_HIGH, "You're already in Team No ");
		st = ftos(self.team_no);
		sprint (self, PRINT_HIGH, st);
		sprint (self, PRINT_HIGH, ".\n");
		return FALSE;
	}

	tc = TeamFortress_TeamGetNoPlayers(tno);
	if (tc >= TeamFortress_TeamGetMaxPlayers(tno))
	{
	    //- OfN
        if (mapname == "huntedr")
        {
            if (tno == 3)
                sprint (self, PRINT_HIGH, "The game has already enough assassins, be a bodyguard.\n");
            else if (tno == 1)
                sprint (self, PRINT_HIGH, "You wanna be the vicepresident or what?\n");
        }
        else
            sprint (self, PRINT_HIGH, "That team is full. Pick another.\n");

		return FALSE;
	}

	// If the color for the team this player is changing to is 0,
	// then this is the first player in this team, and we set the
	// teamcolor to this player's pants color.
	// If not, we change this player's color to this team.
	if (TeamGetColor(tno) == 0)
	{
		TeamFortress_TeamSetColor(tno);
		// If the color wasn't set
		if (TeamGetColor(tno) == 0)
		{
			sprint (self, PRINT_HIGH, "You can't start a new team with your color, since another ");
			sprint (self, PRINT_HIGH, "already using that color. Change your pants color, then try again.\n");
			return FALSE;
		}

		// Announce the new team
		bprint(PRINT_HIGH, self.netname);
		bprint(PRINT_HIGH, " has started Team No ");
		st = ftos(tno);
		bprint(PRINT_HIGH, st);
		bprint(PRINT_HIGH, ".\n");

		// Prevent the cheatchecking mechanism from nabbing them b4 the 
		// color command works.
		makeImmune(self,time+10);
		//self.immune_to_check = time + 10;
		tc = TeamGetColor (tno) - 1;
		tc2 = TeamGetNiceColor (tno);
		SetPlayerColor (self, tc, tc2);
		self.team_no = tno;
		self.lives = TeamFortress_TeamGetLives(tno);

		SetTeamName(self);

		// Set the Civilian Class of anyone in a Civilian Team
		if (self.playerclass == PC_UNDEFINED)
		{
			if (TeamFortress_TeamIsCivilian(self.team_no))
			{
				self.impulse = 1;
				TeamFortress_ChangeClass();
			}
		}

		return TRUE;
	}

	// Announce the new teammember
	bprint(PRINT_HIGH, self.netname);
	bprint(PRINT_HIGH, " has joined Team No ");
	st = ftos(tno);
	bprint(PRINT_HIGH, st);
	bprint(PRINT_HIGH, ".\n");

	tc = TeamGetColor (tno) - 1;
	tc2 = TeamGetNiceColor (tno);
	SetPlayerColor (self, tc, tc2);

	self.team_no = tno;
	// Prevent the cheatchecking mechanism from nabbing them b4 the 
	// color command works.
//	makeImmune(self,time+10);
	//self.immune_to_check = time + 10;
	self.lives = TeamFortress_TeamGetLives(tno);

	// Tell them what class the other members of their team are
	TeamFortress_TeamShowMemberClasses(self);

	SetTeamName(self);

	// Set the Civilian Class of anyone in a Civilian Team
	if (self.playerclass == PC_UNDEFINED)
	{
		if (TeamFortress_TeamIsCivilian(self.team_no))
		{
			self.impulse = 1;
			TeamFortress_ChangeClass();
		}
	}
//RJM
 	if (toggleflags & TFLAG_TEAMFRAGS)
		self.frags = TeamFortress_TeamGetScore(self.team_no);
//RJM

    //- OfN Team3 should have less players than red in Hunted
    if (mapname == "huntedr")
    {
        local float result;
        result = floor(TeamFortress_TeamGetNoPlayers(2) * HUNTED_YELLOWTEAM_FACTOR);
        team3maxplayers = result;
        if (team3maxplayers < 1) team3maxplayers = 1;
    }

	return TRUE;
};

//=========================================================================
// Make sure no-one is changing their colors
void() TeamFortress_CheckTeamCheats =
{
/*
	local string st, sk;
	local float tc, tc2;
	local float rate;

	if (self.immune_to_chec > time)
		return;

	if (self.deadflag)
		return;

#ifdef COOP_MODE
	if (coop && !deathmatch)	// don't worry about it if in coop game
		return;
#endif

	//WK Add in hack for "skins" cheat. This is as good a place as any
	if (!self.netname) {
		stuffcmd(self,"name \"I'm a cheater even when RENAMED\"\n");
		stuffcmd(self,"disconnect\n");
	}

	//WK Limit rate to 10k?
	st = infokey(self,"rate");
	if (st)
		rate = stof(st);
	if (rate > 10000) {
		stuffcmd(self,"rate 10000\n");
	}

    //- OfN - Added checking for topcolor changes... (see IsValidTopColor in OfteN.qc)
    local float tTopColor;
    st = infokey(self,"topcolor");
    tTopColor=stof(st);

	// Have they changed color?
	if (self.team_no > 0 && teamplay > 0)
	{
		// QuakeWorld
		st = infokey(self, "bottomcolor");
		tc = stof(st);
		// if they're a spy, check to see if they've changed colors manually
		if ((self.cutf_items & CUTF_SPY_KIT) && self.undercover_team != 0)
		{
			if ((TeamGetColor(self.undercover_team) - 1) != tc || !IsValidTopColor(self.undercover_team,tTopColor))
			{
			#ifdef CHEAT_WARNINGS
				RPrint(self.netname);
				RPrint(" had his colors reset.\n");
			#endif

				tc = TeamGetColor (self.undercover_team) - 1;
				tc2 = TeamGetNiceColor (self.undercover_team);
				SetPlayerColor (self, tc, tc2);

//				bprint2(PRINT_MEDIUM, self.netname, " has been kicked for changing color.\n");
//				sprint(self, PRINT_HIGH, "You have been kicked for changing your color. Don't do it.\n");
//				stuffcmd(self, "disconnect\n");
				return;
			}
		}
		else if (tc != (TeamGetColor(self.team_no) - 1) || !IsValidTopColor(self.team_no,tTopColor))
		{
		#ifdef CHEAT_WARNINGS
			RPrint(self.netname);
			RPrint(" had his colors reset.\n");
		#endif

			tc = TeamGetColor (self.team_no) - 1;
			tc2 = TeamGetNiceColor (self.team_no);
			SetPlayerColor (self, tc, tc2);

//			bprint2(PRINT_MEDIUM, self.netname, " has been kicked for changing color.\n");
//			sprint(self, PRINT_HIGH, "You have been kicked for changing your color. Don't do it.\n");
//			stuffcmd(self, "disconnect\n");
			return;
		}

		// Have they changed their skin?
		if (self.playerclass != PC_UNDEFINED)
		{
			//WK For some reason, this isn't reading right for el PC_CUSTOM
			st = infokey(self, "skin");
			tc = 0;

            // OfN kick custom player classes using a non TF-skin
            if (self.playerclass == PC_CUSTOM && !Is_TF_Skin(st))
            {
   				TeamFortress_SetSkin(self);

//				bprint2(PRINT_MEDIUM, self.netname, " has been kicked for changing skin.\n");
//				sprint(self, PRINT_HIGH, "You have been kicked for changing your skin. Don't do it.\n");
//				stuffcmd(self, "disconnect\n");                
            }

			if ((self.cutf_items & CUTF_SPY_KIT) && self.undercover_skin != 0)
			{
				//WK tc = PC_SPY;
				tc = self.playerclass;
				self.playerclass = self.undercover_skin;
			}

			if ( self.playerclass == PC_SCOUT )
				sk = "tf_scout";
			else if ( self.playerclass == PC_SNIPER )
				sk = "tf_snipe";
			else if ( self.playerclass == PC_SOLDIER )
				sk = "tf_sold";
			else if ( self.playerclass == PC_DEMOMAN )
				sk = "tf_demo";
			else if ( self.playerclass == PC_MEDIC )
				sk = "tf_medic";
			else if ( self.playerclass == PC_HVYWEAP )
				sk = "tf_hwguy";
			else if ( self.playerclass == PC_PYRO )
				sk = "tf_pyro";
			else if ( self.playerclass == PC_SPY )
				sk = "tf_spy";
			else if ( self.playerclass == PC_ENGINEER )
				sk = "tf_eng";
			else
			{
				if ((self.cutf_items & CUTF_SPY_KIT) && self.undercover_skin != 0)
				{
					self.playerclass = tc;
				}
				return; //WK Don't check as a safety precaution.
			}

			if (self.cutf_items & CUTF_SPY_KIT && self.undercover_skin != 0)
				{
					//sprint(self,PRINT_HIGH,"Mommy Wuvs You!\n");
					self.playerclass = tc;
				}

			//WK Ignore our custom, spy-kitting friends. Kick everyone else
			if ((st != sk) && !((self.playerclass == PC_CUSTOM) && (self.cutf_items & CUTF_SPY_KIT)))
			{
				#ifdef CHEAT_WARNINGS
					RPrint(self.netname);
					RPrint(" had his skin reset.\n");
				#endif

				TeamFortress_SetSkin(self);

//				bprint2(PRINT_MEDIUM, self.netname, " has been kicked for changing skin.\n");
//				sprint(self, PRINT_HIGH, "You have been kicked for changing your skin. Don't do it.\n");
//				stuffcmd(self, "disconnect\n");
			}

		}


		// Have they Changed their Team?
		st = GetTeamName(self.team_no);
		if (st != infokey(self, "team"))
		{
		if (self.penance_time < time) { //Ignore if we're cursed

		#ifdef CHEAT_WARNINGS
			RPrint(self.netname);
			RPrint(" had his team reset.\n");
		#endif

			// Set the player's team
			SetTeamName(self);
//			bprint2(PRINT_MEDIUM, self.netname, " has been kicked for changing team.\n");
//			sprint(self, PRINT_HIGH, "You have been kicked for changing your team. Don't do it.\n");
//			stuffcmd(self, "disconnect\n");
			return;
		}
		}
	}
*/
};

void (entity pl, float topcolor, float bottomcolor) SetPlayerColor =
{
	local string top;
	local string bottom;

	top = ftos (topcolor);
	bottom = ftos (bottomcolor);

	setinfokey (pl, "topcolor", top);
	setinfokey (pl, "bottomcolor", bottom);

	stuffcmd (pl, "topcolor " + top + "\n");
	stuffcmd (pl, "bottomcolor " + bottom + "\n");
//	stuffcmd (pl, "color " + top + " " + bottom + "\n");
};

float (string key, string value) UserInfoCallback =
{ // FIXME: remove the cheat poller
	local string oldval;
	oldval = infokey (self, key);

	if (value == oldval) { // generic reject
//		dprint ("[oldval [" + self.netname + "](" + key + ")(" + value + ")(" + oldval + ")]\n");
	}
//	dprint ("[[" + self.netname + "](" + key + ")(" + value + ")(" + oldval + ")]\n");

	else if (key == "topcolor") { // FIXME: some topcolors may be allowed
		RPrint ("items: " + ftos (self.cutf_items & CUTF_SPY_KIT) + "  ");
		RPrint ("skin: " + ftos (self.is_undercover) + "\n");
		if ((self.cutf_items & CUTF_SPY_KIT) && self.is_undercover) {
			setinfokey(self, "topcolor", oldval);
			stuffcmd(self, "color \"" + oldval + "\"\n");
		} else
			setinfokey (self, key, value);
	}	else if (key == "bottomcolor") {
		setinfokey (self, "bottomcolor", oldval);
		stuffcmd (self, "bottomcolor \"" + oldval + "\"\n");
	} else if (key == "skin") { // FIXME: some other skins may be allowed
		stuffcmd(self, "skin \"" + oldval + "\"\n");
	} else if (key == "name") {
		self.netname = value;
		setinfokey (self, key, value);
	} else if (key == "team") {
		stuffcmd (self, "team \"" + oldval + "\"\n");
	} else {
		// accept everything else
		setinfokey (self, key, value);
//		RPrint ("[default [" + self.netname + "](" + key + ")(" + value + ")(" + oldval + ")]\n");
	}
	return 1;
};

//=========================================================================
// Increase the score of a team
void(float tno, float scoretoadd) TeamFortress_TeamIncreaseScore =
{
	local entity e;

	if (tno == 0 || scoretoadd == 0)
		return;

	if (tno == 1)
		team1score = team1score + scoretoadd;
	if (tno == 2)
		team2score = team2score + scoretoadd;
	if (tno == 3)
		team3score = team3score + scoretoadd;
	if (tno == 4)
		team4score = team4score + scoretoadd;

	// If TeamFrags is on, update all the team's player's frags.
 	if (toggleflags & TFLAG_TEAMFRAGS)
	{
		RPrint ("Teamfrags is on!\n");
		e = find(NIL, classname, "player");
		while (e)
		{
			if (e.team_no == tno)
				e.frags = TeamFortress_TeamGetScore(tno);
			e = find(e, classname, "player");
		}
	}
};

//=========================================================================
// Return the score of a team
float (float tno) TeamFortress_TeamGetScore =
{
	if (tno == 1)
		return team1score;
	if (tno == 2)
		return team2score;
	if (tno == 3)
		return team3score;
	if (tno == 4)
		return team4score;

	return 0;
};

//=========================================================================
// Return the number of lives each team member in a team has
float (float tno) TeamFortress_TeamGetLives =
{
	if (tno == 1)
		return team1lives;
	if (tno == 2)
		return team2lives;
	if (tno == 3)
		return team3lives;
	if (tno == 4)
		return team4lives;

	return 0;
};

//=========================================================================
// Return the number of players in a team
float (float tno) TeamFortress_TeamGetNoPlayers =
{
	local float size_team = 0;
	local entity search;
	//local string st;

	search = find (NIL, classname, "player");
	while (search)
	{
		if (search.team_no == tno)
			size_team = size_team + 1;
		search = find (search, classname, "player");
	}

	return size_team;
};

//=========================================================================
// Return the number of lives each team member in a team has
float (float tno) TeamFortress_TeamGetMaxPlayers =
{
	if (tno == 1)
		return team1maxplayers;
	if (tno == 2)
		return team2maxplayers;
	if (tno == 3)
		return team3maxplayers;
	if (tno == 4)
		return team4maxplayers;

	return 0;
};

//=========================================================================
// Return the team that's winning
float() TeamFortress_TeamGetWinner =
{
	local float i,j,highest,highestteam;

	i = 1;
	highest = 0;
	highestteam = 0;
	while (i < (number_of_teams + 1))
	{
		j = TeamFortress_TeamGetScore(i);
		if (j > highest)
		{
			highest = j;
			highestteam = i;
		}
		i = i + 1;
	}

	return highestteam;
};

//=========================================================================
// Return the team that's winning
/*CH i saw no uses
float() TeamFortress_TeamGetSecond =
{
	local float i,j,highest,highestteam, secondteam, second;

	i = 1;
	highestteam = TeamFortress_TeamGetWinner();
	highest = TeamFortress_TeamGetScore(highestteam);
	secondteam = 0;
	second = 0;
	while (i < (number_of_teams + 1))
	{
		j = TeamFortress_TeamGetScore(i);
		if (j < highest && j > second)
		{
			second = j;
			secondteam = i;
		}
		i = i + 1;
	}

	return secondteam;
};
*/
//=========================================================================
// Display all the Team Scores
void(float all) TeamFortress_TeamShowScores =
{
	local string st;
	local float i,j;

	i = 1;
	// short scores
	if (all == 2)
	{
		while (i <= number_of_teams)
		{
			if (TeamGetColor(i) > 0)
			{
				j = TeamFortress_TeamGetScore(i);
				st = TeamFortress_TeamGetColorString(i);

				bprint(PRINT_HIGH, st);
				bprint(PRINT_HIGH, ": ");
				st = ftos(j);
				bprint(PRINT_HIGH, st);
				bprint(PRINT_HIGH, " ");
			}
			i = i + 1;
		}
		bprint (PRINT_HIGH, "\n");
		return;
	}

	// long scores
	while (i <= number_of_teams)
	{
		if (TeamGetColor(i) > 0)
		{
			if (all)
				bprint (PRINT_HIGH, "Team ");
			else
				sprint (self, PRINT_HIGH, "Team ");

			st = ftos(i);
			if (all)
				bprint (PRINT_HIGH, st);
			else
				sprint (self, PRINT_HIGH, st);

			if (all)
				bprint (PRINT_HIGH, " (");
			else
				sprint (self, PRINT_HIGH, " (");

			st = TeamFortress_TeamGetColorString(i);
			if (all)
				bprint (PRINT_HIGH, st);
			else
				sprint (self, PRINT_HIGH, st);

			if (all)
				bprint (PRINT_HIGH, ") : ");
			else
				sprint (self, PRINT_HIGH, ") : ");
			
			j = TeamFortress_TeamGetScore(i);
			st = ftos(j);

			if (all)
				bprint (PRINT_HIGH, st);
			else
				sprint (self, PRINT_HIGH, st);

			if (all)
				bprint (PRINT_HIGH, "\n");
			else
				sprint (self, PRINT_HIGH, "\n");
		}
		i = i + 1;
	}
};

//=========================================================================
// Return a string containing the color of the team passed in tno
string(float tno) TeamFortress_TeamGetColorString =
{
	local float col;

	col = TeamGetColor(tno);
	if (col == 1)
		return "White";
	if (col == 2)
		return "Brown";
	if (col == 3)
		return "LightBlue"; //- OfN was blue
	if (col == 4)
		return "Green";
	if (col == 5)
		return "Red";
	if (col == 6)
		return "Tan";
	if (col == 7)
		return "Pink";
	if (col == 8)
		return "Orange";
	if (col == 9)
		return "Purple";
	if (col == 10)
		return "DarkPurple";
	if (col == 11)
		return "Grey";
	if (col == 12)
		return "DarkGreen";
	if (col == 13)
		return "Yellow";

	return "Blue"; // was DarkBlue
};

//=========================================================================
// Print to the Player's screen a list of all the members of his/her
// team, and the class they've chosen
void(entity Player) TeamFortress_TeamShowMemberClasses =
{
	/*local string st;
	st = infokey(NIL, "no_showmembers");	*/
    
    local entity e;
	local float found;

	found = FALSE;

	e = find(NIL, classname, "player");
	while (e)
	{
		if (((e.team_no == Player.team_no) || (e.team_no == 0)) && (e != Player))
		{
			if (e.model) // check if valid player
			{
				if (!found)
				{
					found = TRUE;
					sprint (self, PRINT_HIGH, "The other members of your team are:\n");
				}

				sprint (Player, PRINT_HIGH, e.netname);
				sprint (Player, PRINT_HIGH, " : ");
				if (e.playerclass != PC_CUSTOM)
					TeamFortress_PrintClassName(Player,e.playerclass, (e.tfstate & TFSTATE_RANDOMPC));
				else
					TeamFortress_PrintJobName(Player,e.job);
					
			}
		}
		e = find(e, classname, "player");
	}

	if (!found)
	{
		sprint (Player, PRINT_HIGH, "There are no other players on your team.\n");
	}
};


void() CalculateTeamEqualiser =
{
	local float t1, t2, t3, t4;
	local float t_ave, calc;

	team1advantage = 1;
	team2advantage = 1;
	team3advantage = 1;
	team4advantage = 1;

	if (number_of_teams < 2)
	{
		// not enought teams!
		// wait a while, then try again (more teams may be created)
		self.nextthink = time + 60;
		return;
	}
	
	if (teamplay & TEAMPLAY_LESSPLAYERSHELP)
	{

		t1 = TeamFortress_TeamGetNoPlayers(1);
		t2 = TeamFortress_TeamGetNoPlayers(2);
		t3 = TeamFortress_TeamGetNoPlayers(3);
		t4 = TeamFortress_TeamGetNoPlayers(4);

		if ((t1 + t2 + t3 + t4) < 1)  // is there any players at all?
		{
			self.nextthink = time + 30;
			return;
		}
		
		t_ave = (t1 + t2 + t3 + t4) / number_of_teams;

		// calulate teams equalisation ratio
		if (t1 > 0)
		{
			calc = (t_ave / t1) - 1;

			if (calc != 0)
				calc = (calc / 3) + 1;
			else
				calc = calc + 1;

			team1advantage = calc;
		}
		
		if (t2 > 0 && number_of_teams >= 2)
		{
			calc = (t_ave / t2) - 1;

			if (calc != 0)
				calc = (calc / 3) + 1;
			else
				calc = calc + 1;

			team2advantage = calc;
		}

		if (t3 > 0 && number_of_teams >= 3)
		{
			calc = (t_ave / t3) - 1;

			if (calc != 0)
				calc = (calc / 3) + 1;
			else
				calc = calc + 1;

			team3advantage = calc;
		}

		if (t4 > 0 && number_of_teams >= 4)
		{
			calc = (t_ave / t4) - 1;

			if (calc != 0)
				calc = (calc / 3) + 1;
			else
				calc = calc + 1;

			team4advantage = calc;
		}
	}
	
	if (teamplay & TEAMPLAY_LESSSCOREHELP)
	{
		t1 = team1score + TEAM_HELP_RATE;
		
		if (number_of_teams >= 2)
				t2 = team2score + TEAM_HELP_RATE;
		else
				t2 = 0;

		if (number_of_teams >= 3)
			t3 = team3score + TEAM_HELP_RATE;
		else
			t3 = 0;

		if (number_of_teams >= 4)
			t4 = team4score + TEAM_HELP_RATE;
		else 
			t4 = 0;


		// calulate teams equalisation ratio
		t_ave = (t2 + t3 + t4) / (number_of_teams - 1);

		calc = (t_ave / t1) - 1;

		if (calc != 0)
			calc = (calc / 3) + 1;
		else
			calc = calc + 1;

		team1advantage = calc * team1advantage;
	
		if (number_of_teams >= 2)
		{
			t_ave = (t1 + t3 + t4) / (number_of_teams - 1);

			calc = (t_ave / t2) - 1;

			if (calc != 0)
				calc = (calc / 3) + 1;
			else
				calc = calc + 1;

			team2advantage = calc * team2advantage;
		}

		if (number_of_teams >= 3)
		{
			t_ave = (t2 + t1 + t4) / (number_of_teams - 1);
	
			calc = (t_ave / t3) - 1;

			if (calc != 0)
				calc = (calc / 3) + 1;
			else
				calc = calc + 1;

			team3advantage = calc * team3advantage;
		}

		if (number_of_teams >= 4)
		{
			t_ave = (t2 + t3 + t1) / (number_of_teams - 1);

			calc = (t_ave / t4) - 1;

			if (calc != 0)
				calc = (calc / 3) + 1;
			else
				calc = calc + 1;

			team4advantage = calc * team4advantage;
		}
	}		

	self.nextthink = time + 10;
};


void() SetupTeamEqualiser =
{
	team1advantage = 1;
	team2advantage = 1;
	team3advantage = 1;
	team4advantage = 1;
	
	if (!(teamplay & (TEAMPLAY_LESSPLAYERSHELP | TEAMPLAY_LESSSCOREHELP)))
		return;

	// setup teamplay timer
	local entity TE;

	TE = spawn();
	TE.classname = "Team Equaliser";
	TE.think = CalculateTeamEqualiser;
	TE.nextthink = time + 30;	
};


float (entity targ, entity attacker, float damage) TeamEqualiseDamage =
{
	if (targ.classname != "player" || attacker.classname != "player")
		return damage;

	if (Teammate(targ.team_no, attacker.team_no))
		return damage;

	local float adv = 0, newdam;

	// increase damage done by attacker's team advantage
	if (attacker.team_no == 1)
		adv = team1advantage;
	else if (attacker.team_no == 2)
		adv = team2advantage;
	else if (attacker.team_no == 3)
		adv = team3advantage;
	else if (attacker.team_no == 4)
		adv = team4advantage;

	if (adv == 0)
	{
		RPrint("There is a team with an advantage of 0\n");
		adv = 0.1;
	}

	newdam = damage * adv;

	// reduce damage done by target's team advantage
	if (targ.team_no == 1)
		adv = team1advantage;
	else if (targ.team_no == 2)
		adv = team2advantage;
	else if (targ.team_no == 3)
		adv = team3advantage;
	else if (targ.team_no == 4)
		adv = team4advantage;
	
	if (adv == 0)
	{
		RPrint("There is a team with an advantage of 0\n");
		adv = 0.1;
	}

	newdam = newdam * (1 / adv);

	return newdam;
};

//=========================================================================
// StatusQuery
void() TeamFortress_StatusQuery =
{
	local float ft;
	local string st;

	sprint (self, PRINT_HIGH, "players per team: ");

	ft = TeamFortress_TeamGetNoPlayers(1);	
	st = ftos(ft);
	sprint (self, PRINT_HIGH, st);
	sprint (self, PRINT_HIGH, "  ");
	ft = TeamFortress_TeamGetNoPlayers(2);	
	st = ftos(ft);
	sprint (self, PRINT_HIGH, st);

	sprint (self, PRINT_HIGH, "  ");
	ft = TeamFortress_TeamGetNoPlayers(3);	
	st = ftos(ft);
	sprint (self, PRINT_HIGH, st);
	sprint (self, PRINT_HIGH, "  ");
	ft = TeamFortress_TeamGetNoPlayers(4);	
	st = ftos(ft);
	sprint (self, PRINT_HIGH, st);
	sprint (self, PRINT_HIGH, "\n");

	sprint (self, PRINT_HIGH, "    equalisation: ");

	st = ftos(team1advantage);
	sprint (self, PRINT_HIGH, st);
	sprint (self, PRINT_HIGH, "  ");
	st = ftos(team2advantage);
	sprint (self, PRINT_HIGH, st);
	sprint (self, PRINT_HIGH, "  ");
	st = ftos(team3advantage);
	sprint (self, PRINT_HIGH, st);
	sprint (self, PRINT_HIGH, "  ");
	st = ftos(team4advantage);
	sprint (self, PRINT_HIGH, st);

	sprint (self, PRINT_HIGH, "\n");

	st = ftos(teamplay);
	sprint (self, PRINT_HIGH, "Teamplay is ");
	sprint (self, PRINT_HIGH, st);
	sprint (self, PRINT_HIGH, "\n");

};

//=========================================================================
// Return the illegal classes for this team
float(float tno) TeamFortress_TeamGetIllegalClasses =
{
	if (tno == 1)
		return illegalclasses1;
	if (tno == 2)
		return illegalclasses2;
	if (tno == 3)
		return illegalclasses3;
	if (tno == 4)
		return illegalclasses4;

	return 0;
};

//=========================================================================
// Return TRUE if this team is restricted to Civilian class
float(float tno) TeamFortress_TeamIsCivilian =
{
	if (tno == 1)
	{
		if (civilianteams & TEAM1_CIVILIANS)
			return TRUE;
	}
	else if (tno == 2)
	{
		if (civilianteams & TEAM2_CIVILIANS)
			return TRUE;
	}
	else if (tno == 3)
	{
		if (civilianteams & TEAM3_CIVILIANS)
			return TRUE;
	}
	else // if (tno == 4)
	{
		if (civilianteams & TEAM4_CIVILIANS)
			return TRUE;
	}

	return FALSE;
};

//=========================================================================
// Sprints to all the members on one team except one 
void(float tno, entity ignore, string st) teamsprint =
{
	// Don't do teamprints in DM
	if (tno == 0)
		return;
    
    local entity te;

	te = find(NIL, classname, "player");
	while (te)
	{
		if (Teammate(te.team_no,tno) && te != ignore)
		{
            sprint(te, PRINT_HIGH, st);
		}

		te = find(te, classname, "player");
	}
};



