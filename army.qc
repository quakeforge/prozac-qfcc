#include "defs.qh"
#include "menu.qh"
#include "monsters.qh"

/*=======================================================//
// ARMY.QC - CustomTF 3.2.OfN              - 30/1/2001 - //
// by Sergio FumaÒa Grunwaldt - OfteN aka superCOCK2000  //
=========================================================//
 Army job stuff
=========================================================*/

float(entity obj, entity builder) CheckArea;
void(entity player) PrintArmyTime;
void(entity sld, entity player, string msg) PrintFromSoldier;
entity(entity player) GetArmyTimer;
string(entity thething) GetEnemyName;
float() TeleSoldier;

$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8 stand9
$frame stand10 stand11 stand12 stand13

void() JobArmy =
{
	if (self.current_menu == MENU_ARMY && self.job & JOB_DEMON_OUT)
	{
		if (self.demon_one.is_haxxxoring == 0)
			self.demon_one.is_haxxxoring = 1;
		else
			self.demon_one.is_haxxxoring = 0;
	}
    
    self.current_menu = MENU_ARMY;
	self.menu_count = MENU_REFRESH_RATE;   
};

void() Menu_Army1;
void() Menu_Army2;

void() Menu_Army =
{
    if (self.job & JOB_DEMON_OUT)
    {
        if (self.demon_one.is_haxxxoring == 1) Menu_Army2();
        else Menu_Army1();        
    }
    else Menu_Army1();
};

void() Menu_Army1 =
{
	local float readytime,temp;
    local string st,st2,st3;

    if (self.army_ready==FALSE)
    {           
        local entity ArmyTimer;
        ArmyTimer=GetArmyTimer(self);

        readytime=fabs(floor(ArmyTimer.nextthink - time));
        if (readytime<60)
        {
          st=ftos(readytime);
          st2=" seconds";
        }
        else
        {
          temp=floor(readytime/60);//+1;
          if (temp>1)
            st2=" minutes";
          else
            st2=" minute";

          st=ftos(floor(readytime/60));//+1);
        }
    }
   
    if (self.job & JOB_DEMON_OUT)
    {
/*        if (self.demon_one.goalentity==self)
            st="ó.. Stay there!           ";
        else
            st="ó.. Follow me!            ";*/ 
            
        if (self.demon_one.martyr_enemy==world && self.demon_one.demon_two==world)
            st3 = "  ì.. Set primary ˜·˘ÔÈÓÙ    \n  î.. Set secondary ˜·˘ÔÈÓÙ  ";
        
        else if (self.demon_one.martyr_enemy!=world && self.demon_one.demon_two==world && visible2(self.demon_one,self.demon_one.martyr_enemy))
            st3 = " ì.. Set primary ˜·˘ÔÈÓÙ    \n  î.. Set secondary ˜·˘ÔÈÓÙ  ";
        else if (self.demon_one.martyr_enemy!=world && self.demon_one.demon_two==world)
            st3 = "ã ì.. Set primary ˜·˘ÔÈÓÙ    \n  î.. Set secondary ˜·˘ÔÈÓÙ  ";

        else if (self.demon_one.martyr_enemy==world && self.demon_one.demon_two!=world && visible2(self.demon_one,self.demon_one.demon_two))
            st3 = "  ì.. Set primary ˜·˘ÔÈÓÙ    \n î.. Set secondary ˜·˘ÔÈÓÙ  ";
        else if (self.demon_one.martyr_enemy==world && self.demon_one.demon_two!=world)
            st3 = "  ì.. Set primary ˜·˘ÔÈÓÙ    \nã î.. Set secondary ˜·˘ÔÈÓÙ  ";
        
        else if (self.demon_one.martyr_enemy!=world && self.demon_one.demon_two!=world && visible2(self.demon_one,self.demon_one.demon_two) && visible2(self.demon_one,self.demon_one.martyr_enemy))
            st3 = " ì.. Set primary ˜·˘ÔÈÓÙ    \n î.. Set secondary ˜·˘ÔÈÓÙ  ";
        else if (self.demon_one.martyr_enemy!=world && self.demon_one.demon_two!=world && visible2(self.demon_one,self.demon_one.demon_two))
            st3 = "ã ì.. Set primary ˜·˘ÔÈÓÙ    \n î.. Set secondary ˜·˘ÔÈÓÙ  ";
        else if (self.demon_one.martyr_enemy!=world && self.demon_one.demon_two!=world && visible2(self.demon_one,self.demon_one.martyr_enemy))
            st3 = " ì.. Set primary ˜·˘ÔÈÓÙ    \nã î.. Set secondary ˜·˘ÔÈÓÙ  ";
        else if (self.demon_one.martyr_enemy!=world && self.demon_one.demon_two!=world)
            st3 = "ã ì.. Set primary ˜·˘ÔÈÓÙ    \nã î.. Set secondary ˜·˘ÔÈÓÙ  ";

        st2=" ¡„ÙÈÔÓ:                  \n\n";
        
        if (self.army_ready == TRUE)
            st2=" ¡„ÙÈÔÓ: ºsoldier waitingæ\n\n";

        custom_demon_name(self.demon_one);

//1 ì
//2 î
//3 ï
//4 ñ
//5 ó
        
        
        //CenterPrint5(self, self.demon_one.undercover_name, self.demon_one.netname,"\n\n", st2, "\n\nî.. Soldier inventory     \n\nï.. Set primary ˜·˘ÔÈÓÙ  \nñ.. Set secondary ˜·˘ÔÈÓÙ\nó.. Follow me!            \nò.. Stay there!           \n\nöÆÆ Detonate soldier brain\n\ní.. ŒÔÙËÈÓÁ               \n");
        
        local string st4;
        st4="\nï.. Follow me!            \nñ.. Stay there!           \nó.. Use your waypoints!   ";
        
        if (self.demon_one.penance_time==1)
            st4="\n* ï.. Follow me!              \nñ.. Stay there!           \nó.. Use your waypoints!   ";
        else if (self.demon_one.penance_time==2)
            st4="\nï.. Follow me!            \n* ñ.. Stay there!             \nó.. Use your waypoints!   ";
        else if (self.demon_one.penance_time==3)
            st4="\nï.. Follow me!            \nñ.. Stay there!           \n* ó.. Use your waypoints!     ";
        
        CenterPrint7(self, self.demon_one.undercover_name, self.demon_one.netname,"\n\n", st2, 
st3,st4,"\n\nöÆÆ Detonate soldier brain\n\ní.. ŒÔÙËÈÓÁ               \n");
        return;
    }
    else
    {
        if (self.army_ready==TRUE)
        {
            CenterPrint(self, " ¡„ÙÈÔÓ:                  \n\nì.. Teleport soldier      \n\ní.. ŒÔÙËÈÓÁ               \n\n\nReady for teleporting!");
        }
        else
        {
            CenterPrint3(self, " ¡„ÙÈÔÓ:                  \n\n\n\ní.. ŒÔÙËÈÓÁ               \n\n\nPreparing teleporting...\n\n‘ÈÌÂ ÏÂÊÙ: ",st,st2);
        }

    }

  //ideas:
  
  //((centered soldier status
  // \n attacking)) ((xxxx)) - seeking xxxx - standing - on patrol|walking - following you - following u (forced)//1 prt (2 vars, one for displaying and keep preference and the other for ai)

  //((1.. tactic mode:        normal - agressive - static // 1 prt))
  // 2.. ignore enemy:   on - off
  // normal - tries to return to waypoints when enemy not visible (like in the aussie version)
  // agressive - he tries to reach enemy when not visible (like before when no tactic stuff)
  // patrol - forces grunty to use waypoints - and reports when he cant
  // static - soldier dont move when attacking if no waypoints, if there r he moves on the line between them
  // passive - makes soldier to ignore enemy completely

  //NO! AI improvement - 0 none 1 desires to be close to enemy 2 desires to be farther

  //((3.. obstacle:     sort - stop  // 1 prt
  //4.. talk mode:     on - off))
  //((5.. reports:   all - most - some - off // 1 prt

  //st=

  //6.. show soldier's inventory
  //

  // health:)) ((500)) ((hp // 1 prt

    // 0.. NOTHING)) // 1 prt
  //FULL
  // (when in patrol or others) hmmm... forgot my xxxx waypoint, sorry!
  
  // when forced "follow me", random time until "lemme kill them!" and restore status
  // when forced "follow me" super_time controls time between the "i can see the enemy from here"

  // inv in new menu, so spacing nicer

  // "use ur waypoints!" in first menu

  // follow me, stay there and use ur waypoints defined in a variable to restore last intention when enemy becomes not visible

  //self.demon_one = AssignEasyWaypoint
  // scan for other targets when aggressive and enemy not visible
  // when aggressive augmnet probability of direct walk to last seen mark
  // * primary

  //in waypoint donothing, if soldier already have assinged the corresponding waypoint to another entity dremove(self);
};

void() Menu_Army2 =
{
    local string st,st2,st3,st4,st5,st6,st7;
    
    st3="";

    if (self.demon_one.enemy!=world && visible2(self.demon_one,self.demon_one.enemy))
    {
        st2="ùü ”ÔÏ‰ÈÂÚ ”Ù·ÙıÛ ùü\n\nAttacking ";
        st3=GetEnemyName(self.demon_one.enemy);
    }
    else if (self.demon_one.enemy!=world)
    {
        st2="ùü ”ÔÏ‰ÈÂÚ ”Ù·ÙıÛ ùü\n\nSeeking ";
        st3=GetEnemyName(self.demon_one.enemy);
    }
    else if (self.demon_one.goalentity==self)
        st2="ùü ”ÔÏ‰ÈÂÚ ”Ù·ÙıÛ ùü\n\nFollowing You";
    else if (self.demon_one.goalentity==world)
        st2="ùü ”ÔÏ‰ÈÂÚ ”Ù·ÙıÛ ùü\n\nStanding";
    else if (self.demon_one.goalentity!=world)
        st2="ùü ”ÔÏ‰ÈÂÚ ”Ù·ÙıÛ ùü\n\nOn Patrol";    

    st5=""; // this will be static range
    
   if (self.demon_one.is_malfunctioning==0)
    {
        if (self.demon_one.is_detpacking==0 && self.demon_one.is_toffingadet==1)
            st4="\n\nì.. ‘·„ÙÈ„ ÕÔ‰Â:    normal\nî.. ≈ÓÁ·ÁÂ ≈ÓÂÌ˘:   no    \nï.. œÓ œ‚ÛÙ·„ÏÂ:    stop  \n";
        else if (self.demon_one.is_detpacking==1 && self.demon_one.is_toffingadet==1)
            st4="\n\nì.. ‘·„ÙÈ„ ÕÔ‰Â:    normal\nî.. ≈ÓÁ·ÁÂ ≈ÓÂÌ˘:   yes   \nï.. œÓ œ‚ÛÙ·„ÏÂ:    stop  \n";
        else if (self.demon_one.is_detpacking==0 && self.demon_one.is_toffingadet==0)
            st4="\n\nì.. ‘·„ÙÈ„ ÕÔ‰Â:    normal\nî.. ≈ÓÁ·ÁÂ ≈ÓÂÌ˘:   no    \nï.. œÓ œ‚ÛÙ·„ÏÂ:    jump  \n";
        else if (self.demon_one.is_detpacking==1 && self.demon_one.is_toffingadet==0)
            st4="\n\nì.. ‘·„ÙÈ„ ÕÔ‰Â:    normal\nî.. ≈ÓÁ·ÁÂ ≈ÓÂÌ˘:   yes   \nï.. œÓ œ‚ÛÙ·„ÏÂ:    jump  \n";
    }
    else if (self.demon_one.is_malfunctioning==1)
    {
        if (self.demon_one.is_detpacking==0 && self.demon_one.is_toffingadet==1)
            st4="\n\nì.. ‘·„ÙÈ„ ÕÔ‰Â:    seek  \nî.. ≈ÓÁ·ÁÂ ≈ÓÂÌ˘:   no    \nï.. œÓ œ‚ÛÙ·„ÏÂ:    stop  \n";
        else if (self.demon_one.is_detpacking==1 && self.demon_one.is_toffingadet==1)
            st4="\n\nì.. ‘·„ÙÈ„ ÕÔ‰Â:    seek  \nî.. ≈ÓÁ·ÁÂ ≈ÓÂÌ˘:   yes   \nï.. œÓ œ‚ÛÙ·„ÏÂ:    stop  \n";
        else if (self.demon_one.is_detpacking==0 && self.demon_one.is_toffingadet==0)
            st4="\n\nì.. ‘·„ÙÈ„ ÕÔ‰Â:    seek  \nî.. ≈ÓÁ·ÁÂ ≈ÓÂÌ˘:   no    \nï.. œÓ œ‚ÛÙ·„ÏÂ:    jump  \n";
        else if (self.demon_one.is_detpacking==1 && self.demon_one.is_toffingadet==0)
            st4="\n\nì.. ‘·„ÙÈ„ ÕÔ‰Â:    seek  \nî.. ≈ÓÁ·ÁÂ ≈ÓÂÌ˘:   yes   \nï.. œÓ œ‚ÛÙ·„ÏÂ:    jump  \n";
    }
    else if (self.demon_one.is_malfunctioning==2)
    {
        if (self.demon_one.army_ready == 0)
           st5="ñ.. ”Ù·ÙÈ„ “·ÓÁÂ:   none  \n";        
        else if (self.demon_one.army_ready == 1)
           st5="ñ.. ”Ù·ÙÈ„ “·ÓÁÂ:   small \n";
        else if (self.demon_one.army_ready == 2)
           st5="ñ.. ”Ù·ÙÈ„ “·ÓÁÂ:   medium\n";
        else if (self.demon_one.army_ready == 3)
           st5="ñ.. ”Ù·ÙÈ„ “·ÓÁÂ:   large \n";

        if (self.demon_one.is_detpacking==0 && self.demon_one.is_toffingadet==1)
            st4="\n\nì.. ‘·„ÙÈ„ ÕÔ‰Â:    static\nî.. ≈ÓÁ·ÁÂ ≈ÓÂÌ˘:   no    \nï.. œÓ œ‚ÛÙ·„ÏÂ:    stop  \n";
        else if (self.demon_one.is_detpacking==1 && self.demon_one.is_toffingadet==1)
            st4="\n\nì.. ‘·„ÙÈ„ ÕÔ‰Â:    static\nî.. ≈ÓÁ·ÁÂ ≈ÓÂÌ˘:   yes   \nï.. œÓ œ‚ÛÙ·„ÏÂ:    stop  \n";
        else if (self.demon_one.is_detpacking==0 && self.demon_one.is_toffingadet==0)
            st4="\n\nì.. ‘·„ÙÈ„ ÕÔ‰Â:    static\nî.. ≈ÓÁ·ÁÂ ≈ÓÂÌ˘:   no    \nï.. œÓ œ‚ÛÙ·„ÏÂ:    jump  \n";
        else if (self.demon_one.is_detpacking==1 && self.demon_one.is_toffingadet==0)
            st4="\n\nì.. ‘·„ÙÈ„ ÕÔ‰Â:    static\nî.. ≈ÓÁ·ÁÂ ≈ÓÂÌ˘:   yes   \nï.. œÓ œ‚ÛÙ·„ÏÂ:    jump  \n";
    }
    
   if (self.demon_one.num_mines==0)
        st6="ò.. “ÂÔÚÙÛ:        all   \n\nô.. Inventory  í.. ŒÔÙËÈÓÁ\n\nÕ·¯ »–: ";
    else if (self.demon_one.num_mines==1) 
        st6="ò.. “ÂÔÚÙÛ:        most  \n\nô.. Inventory  í.. ŒÔÙËÈÓÁ\n\nÕ·¯ »–: ";
    else if (self.demon_one.num_mines==2) 
        st6="ò.. “ÂÔÚÙÛ:        some  \n\nô.. Inventory  í.. ŒÔÙËÈÓÁ\n\nÕ·¯ »–: ";
    else if (self.demon_one.num_mines==3) 
        st6="ò.. “ÂÔÚÙÛ:        none  \n\nô.. Inventory  í.. ŒÔÙËÈÓÁ\n\nÕ·¯ »–: ";                                     
                                     
                                     // "ô.. Soldier inventory...  "
    st7=ftos(floor(self.demon_one.max_health));

    CenterPrint7(self,st,st2,st3,st4,st5,st6,st7);
};

void(float inp) Menu_Army_Input1;
void(float inp) Menu_Army_Input2;

void(float inp) Menu_Army_Input =
{
    if (self.job & JOB_DEMON_OUT)
    {
        if (self.demon_one.is_haxxxoring == 1) Menu_Army_Input2(inp);
        else Menu_Army_Input1(inp);        
    }
    else Menu_Army_Input1(inp);
};

void(float inp) Menu_Army_Input2 =
{
	if (inp == 10 || self.demon_one==world) // NOTHING
	{	
		ResetMenu();
		self.impulse = 0;
		self.demon_one.is_haxxxoring = 0; // go back to first menu
        return;
	}

    if (inp == 1)
    {
        self.impulse = 0;
        self.demon_one.is_malfunctioning=self.demon_one.is_malfunctioning+1;

        if (self.demon_one.is_malfunctioning > 2)
        self.demon_one.is_malfunctioning=0;
        return;
    }  

    if (inp == 2) // engage enemy??
    {
        self.impulse = 0;
        if (self.demon_one.is_detpacking == 0)
        {
            self.demon_one.is_detpacking=1;
            PrintFromSoldier(self.demon_one,self,"i'm gonna kill them all!\n");
        }
        else
        {
            self.demon_one.is_detpacking=0;
            self.demon_one.has_teleporter = 0;
			self.demon_one.effects = self.demon_one.effects - (self.demon_one.effects & EF_DIMLIGHT);

            if (self.demon_one.enemy!=world)//self.demon_one.goalentity)
            {
                self.demon_one.enemy=world;                
                self.demon_one.goalentity = ReturnEasyWaypoint(self.demon_one,self.demon_one);
            }

            PrintFromSoldier(self.demon_one,self,"Ignoring enemy!\n");
        }
    }  

    if (inp == 3) // jump or stop??
    {
        self.impulse = 0;
        if (self.demon_one.is_toffingadet == 0) self.demon_one.is_toffingadet=1;
        else self.demon_one.is_toffingadet=0;
    }

    if (inp == 4 && self.demon_one.is_malfunctioning == 2) // static range, small mdeium or large
    {
        self.impulse = 0;
        self.demon_one.army_ready=self.demon_one.army_ready+1;

        if (self.demon_one.army_ready > 3)
        self.demon_one.army_ready=0;
        return;
    }  


    if (inp == 6)
    {
        self.impulse = 0;
        self.demon_one.num_mines=self.demon_one.num_mines+1;

        if (self.demon_one.num_mines > 3)
        self.demon_one.num_mines=0;
        return;
    }

    else if (inp == 7) // Army info
	{
        ResetMenu();
        local entity oself;
        oself=self;
        self=self.demon_one;
        Grunty_StateInv();
        self=oself;
		self.impulse = 0;
        return;
	}

};

void(float inp) Menu_Army_Input1 =
{
	local float r;
	local entity SummonTimer;
	local float cost;
	local entity te;
	local float points;

	//self.demon_choice = 0; // reset demon choice var
	
	if (inp == 10) // NOTHING
	{	
		ResetMenu();
		self.impulse = 0;
     
        if (self.army_ready == FALSE && !(self.job & JOB_DEMON_OUT))
        {
            sprint(self,PRINT_HIGH,"Still ");
            PrintArmyTime(self);
            sprint(self,PRINT_HIGH," time left until next teleporting\n");
            self.job_finished=time+0.5;
        }
        
        return;
	}
    else if (inp == 1 && self.demon_one == world) // Teleport it!
	{	
		if (self.army_ready == TRUE && self.demon_one==world && !(self.job & JOB_DEMON_OUT))
        {
           ResetMenu();
           //StartTeleArmy();
           
           if (TeleSoldier())
           {
               self.army_ready=FALSE; // needed for setarmytimer
               SetArmyTimer(); // prepare reserve soldier
               self.job = self.job | JOB_DEMON_OUT; 
           }

           self.impulse = 0;
        }
		
        return;
	}	
	else if (inp == 8) // Kill it!
	{
		if (self.demon_one!=world)
        {            
            ResetMenu();
            sprint(self,PRINT_HIGH,"You detonate the micro-explosive implanted in his brain!\n");
            //PrintFromSoldier(self.demon_one,self,"(head): aw! what happens?!\n");
            kill_my_demon();
            teamprefixsprint(self.team_no, self);
            teamsprint(self.team_no,self, self.netname);
	        teamsprint(self.team_no,self, " detonates his soldier\n");
            self.impulse = 0;
		} 
        
          //  sprint(self,PRINT_HIGH,"You do not have a soldier in-battle currently\n");
		
		return;
	}
	else if (inp == 1 && self.demon_one != world) // primary waypoint
	{
        
        if (self.demon_one.martyr_enemy != world)
            RemoveWaypoint(self.demon_one.martyr_enemy,self.demon_one);
        
        if (self.demon_one.demon_two != world)
            RemoveWaypoint(self.demon_one.demon_two,self.demon_one);

            //dremove(self.demon_one.martyr_enemy);

        /*if (self.demon_one.demon_two != world)
			dremove(self.demon_one.demon_two);*/ // OfN - prova

    	self.demon_one.martyr_enemy = CreateWaypoint(self.origin, WAYPOINT_LIFE, WAYPOINT_TYPE_PRIMARY);
		self.demon_one.martyr_enemy.goalentity = world;
		
        self.demon_one.penance_time=3;
        if (visible2(self.demon_one,self.demon_one.martyr_enemy)) self.demon_one.goalentity = self.demon_one.martyr_enemy;
		
        ResetMenu(); // reset menu?
		
        self.impulse = 0;

        PrintFromSoldier(self.demon_one,self,"yes sir!\n");

		return;
	}
	else if (inp == 2 && self.demon_one != world) // secondary waypoint
	{
        if (self.demon_one.demon_two != world)
            RemoveWaypoint(self.demon_one.demon_two,self.demon_one);

        if (self.demon_one.martyr_enemy==world)
        {
            self.impulse=0;
            PrintFromSoldier(self.demon_one,self,"you must set my primary waypoint first!\n");
            ResetMenu(); // reset menu?
            return;
        }

            //dremove(self.demon_one.demon_two);

		self.demon_one.demon_two = CreateWaypoint(self.origin, WAYPOINT_LIFE, WAYPOINT_TYPE_SECONDARY);
		self.demon_one.demon_two.goalentity = self.demon_one.martyr_enemy;
		//self.demon_one.goalentity = self.demon_one.demon_two; 
        self.demon_one.job = 2;
        self.demon_one.penance_time=3;
        self.demon_one.goalentity = ReturnEasyWaypoint(self.demon_one,self.demon_one);
		if (self.demon_one.martyr_enemy!=world) self.demon_one.martyr_enemy.goalentity = self.demon_one.demon_two;
		
        ResetMenu(); // reset menu?
        
        self.impulse = 0;        

        PrintFromSoldier(self.demon_one,self,"Ok\n");

		return;
	}
	else if (inp == 3 && self.demon_one != world) // FOLLOW ME, GRUNTY!
	{
        if (self.demon_one.enemy!=world)
        {
            if (visible2(self.demon_one,self.demon_one.enemy))
            {
                PrintFromSoldier(self.demon_one,self,"i'm fighting the enemy!\n");
                ResetMenu();
                self.impulse=0;
                self.demon_one.penance_time = 1;
                return;
            }            
        }

        self.demon_one.has_teleporter = 0;
      	self.demon_one.effects = self.demon_one.effects - (self.demon_one.effects & EF_DIMLIGHT);
        self.demon_one.penance_time = 1;

        if (self.demon_one.goalentity != self)
		{
			self.demon_one.goalentity = self;			
            PrintFromSoldier(self.demon_one,self,"Ok!\n");
        }
		else
		{
			PrintFromSoldier(self.demon_one,self,"Already following you!\n");
		}

        ResetMenu();
		self.impulse = 0;
    	return;
	}

    else if (inp == 4 && self.demon_one != world) // Stay there!
	{
        if (self.demon_one.enemy!=world)
        {
            if (visible2(self.demon_one,self.demon_one.enemy))
            {
                PrintFromSoldier(self.demon_one,self,"i'm fighting the enemy!\n");
                ResetMenu();
                self.impulse=0;
                self.demon_one.penance_time = 2;
                return;
            }

            self.demon_one.has_teleporter = 0;
        	self.demon_one.effects = self.demon_one.effects - (self.demon_one.effects & EF_DIMLIGHT);
        }

		self.demon_one.goalentity = world;
        PrintFromSoldier(self.demon_one,self,"Holding position...\n");

        self.demon_one.penance_time = 2;

        ResetMenu();
		self.impulse = 0;
    	return;
	}

    else if (inp == 5 && self.demon_one != world) // Use your waypoints!
	{
        if (self.demon_one.enemy!=world)
        {
            if (visible2(self.demon_one,self.demon_one.enemy))
            {
                PrintFromSoldier(self.demon_one,self,"i'm fighting the enemy!\n");
                ResetMenu();
                self.impulse=0;
                self.demon_one.penance_time = 3;
                return;
            }
            self.demon_one.has_teleporter = 0;
        	self.demon_one.effects = self.demon_one.effects - (self.demon_one.effects & EF_DIMLIGHT);
        }

        self.demon_one.penance_time = 3;
        self.demon_one.goalentity = ReturnEasyWaypoint(self.demon_one,self.demon_one);

		if (self.demon_one.goalentity != world)
        {
            PrintFromSoldier(self.demon_one,self,"Moving on!\n");
        }
        /*else
        {
            PrintFromSoldier(self.demon_one,self,"Where are my waypoints?\n");
        }*/

        self.demon_one.has_teleporter = 0;
    	self.demon_one.effects = self.demon_one.effects - (self.demon_one.effects & EF_DIMLIGHT);

        ResetMenu();
		self.impulse = 0;
    	return;
	}

};


float() TeleSoldier =
{
    makevectors (self.v_angle);
	v_forward_z = 0;
	v_forward = normalize(v_forward) * 64;

	newmis = spawn();
	newmis.owner = newmis; //WK Self
	newmis.real_owner = self;
    
    newmis.classname = "monster_army";
    setmodel (newmis, "progs/grunty.mdl");

    newmis.origin = self.origin + v_forward;
	newmis.has_camera = 4;
	custom_demon_name(newmis); 
 
    if (!CheckArea(newmis,self)) { //No room for el diablo
		sprint(self,PRINT_HIGH,"Not enough room to teleport soldier!\n");
		newmis.think = SUB_Remove;
		newmis.nextthink = time + 0.1;
		return FALSE;
	}

    spawn_tfog(newmis.origin);
    
    setmodel (newmis, "progs/grunty.mdl");
	setsize (newmis, '-16 -16 -24', '16 16 32');

    newmis.skin = self.team_no - 1;
    
    //
    //newmis.colormap=self.colormap;
    //newmis.skin=self.skin;
    //newmis.team=self.team;

    teamprefixsprint(self.team_no,self);
    teamsprint(self.team_no,self,self.netname);
	teamsprint(self.team_no,self," teleported Private Class III ");
    //teamsprint(self.team_no,self, "");
	teamsprint(self.team_no,self,newmis.netname);
	teamsprint(self.team_no,self,"\n");

	self.job_finished = time + 1;	//Don't let em kill demon for 15 secs.
									// SB 15 is tight; 10
									// 10 is tight; 5
                                    // OfN 5 is tight; 3 ;)

	//newmis.velocity = v_forward * 10 + '0 0 250';
	newmis.velocity = v_forward * 10;
	newmis.angles = vectoangles(newmis.velocity);
	if (newmis.flags & FL_ONGROUND)
		newmis.flags = newmis.flags - FL_ONGROUND;

	newmis.movetype = MOVETYPE_TOSS;
    newmis.solid = SOLID_SLIDEBOX;
	newmis.takedamage = DAMAGE_AIM;
    
    newmis.health = GRUNTY_HP;
	newmis.has_tesla = 1; // SB level multiplier
	newmis.has_sensor = 1; // SB level
	newmis.has_sentry = 2; // SB frags to level
	
    newmis.frame = $stand13;
	
    newmis.th_stand = grunty_stand;
	newmis.th_run = grunty_run;
	newmis.th_missile = GruntyCheckFire;
	newmis.th_pain = grunty_pain;
	newmis.custom_speed = 10; // 10
	newmis.yaw_speed = 55;
	
    //#ifdef GRUNTY_EXTRA_WEAPONS
    //newmis.weapons_carried = WEAP_AXE + WEAP_SHOTGUN + WEAP_NAILGUN + GRUNTY_EXTRA_WEAPONS;
    //#else
    newmis.weapons_carried = WEAP_AXE + WEAP_SHOTGUN + WEAP_NAILGUN;
    //#endif
    
    newmis.tf_items = 0;
	newmis.view_ofs = '0 0 22';
	newmis.money = 100;
	newmis.respawn_time = time + 20;
	newmis.suicide_time = time + 20;
	newmis.ammo_shells = 25;
	newmis.ammo_nails = 50;
	newmis.ammo_rockets = 8; //was 4
	newmis.ammo_cells = 10;
	newmis.maxammo_shells = 50; // was 75;
	newmis.maxammo_nails = 200;//was 200;
	newmis.maxammo_rockets = 20;
	newmis.maxammo_cells = 100;
	newmis.current_weapon = WEAP_SHOTGUN;
	newmis.th_die = custom_grunt_die;
	newmis.think = walkmonster_start;
	newmis.nextthink = time + 1;
	newmis.armorclass = 0; //- OfN none // AT_SAVESHOT; // kevlar
	newmis.last_saveme_sound = 0; // ? oh that
	
    //newmis.touch = SUB_Null;
    newmis.touch = grunty_touch; //-OfN- 
    newmis.has_holo = time+2; // touch messages delay
    newmis.is_detpacking=1; //resets engage enemy to "yes"

    newmis.real_owner.demon_one = newmis; // DEMON ONE

	newmis.max_health = newmis.health;

    newmis.ltime=time; // trhown or felt on water?
    newmis.martyr_enemy=world;
    newmis.demon_one=world;
    newmis.demon_two=world;
    
    sprint(self,PRINT_HIGH,"You teleport your soldier.\n");
    //PrintFromSoldier(self.demon_one,self,"Your orders?\n");

    newmis.message = "XX"; // flag to identify monsters/army for sentry targetting

    newmis.team_no = self.team_no;

    GetRank(newmis); // needed for army menu first update

    return TRUE;

};

//==============================================================//

void() ArmyTimerThink;


void() SetArmyTimer =
{
    if (self.army_ready!=FALSE || self.job & JOB_DEMON_OUT) return;

    if (GetArmyTimer(self)!=world) return;
    
    newmis = spawn();
    newmis.classname="army_timer";
    newmis.owner=self;

    newmis.think = ArmyTimerThink;
    newmis.nextthink = time + (60*army_delay)+60-(120*random()); // +/- 1 random minute

#ifdef ARMY_TEST
    newmis.nextthink = time + 5; 
#endif

    self.army_ready=FALSE;    
};


void() ArmyTimerThink =
{
    //if (self.classname!="army_timer") return; not needed

                                      //FIXME: This shouldnt be needed
    if (self.owner.has_disconnected || !(self.owner.job & JOB_ARMY))
	{
        dremove(self);
        return;
    }

    if (self.owner.demon_one!=world)
    {
        sprint(self.owner,PRINT_HIGH,"You have another soldier waiting!\n");
        self.owner.army_ready = TRUE;
        dremove(self);
    }
    else
    {
        sprint(self.owner,PRINT_HIGH,"Soldier is ready for teleporting!\n");
        self.owner.army_ready = TRUE;
        dremove(self);                
//        self.nextthink = time + (60*army_delay)+60-(120*random());

  #ifdef ARMY_TEST
//        self.nextthink = time + 5; 
  #endif

    }
};

entity(entity player) GetArmyTimer =
{
    local entity te;
    te = find(world, classname, "army_timer");
    while (te)
	{
		if (te.owner == player)
          return te;
        
		te = find(te, classname, "army_timer");
	}

    return world;
};

void() RemoveArmyTimer =
{
    local entity te;
    te=GetArmyTimer(self);
    if (te!=world)
        dremove(te);
};

string (float num) Digitize;

void(entity player) PrintArmyTime =
{
    if (player.army_ready==TRUE || player.classname!="player") return;

    local string st;
    local float fl,fl2,fl3;
    local entity ArmyTimer;

    ArmyTimer=GetArmyTimer(player);

    if (ArmyTimer==world) return;

    fl=fabs(floor(ArmyTimer.nextthink - time));
    
    fl3=floor(fl/60);
    
    st=ftos(fl3);
   
    sprint(player,PRINT_HIGH,st);
    sprint(player,PRINT_HIGH,":");

    fl2=fabs(fl-fl3*60);
    st=Digitize(fl2);
    sprint(player,PRINT_HIGH,st);
};

string (float num) Digitize =
{
    if (num>9) 
        return ftos(num);
    else
    {
        if (num==0)
            return "00";
        else if (num==1)
            return "01";
        else if (num==2)
            return "02";
        else if (num==3)
            return "03";
        else if (num==4)
            return "04";
        else if (num==5)
            return "05";
        else if (num==6)
            return "06";
        else if (num==7)
            return "07";
        else if (num==8)
            return "08";
        else if (num==9)
            return "09";
    }
};

//=======================================================//

void(entity sld, entity player, string msg) PrintFromSoldier =
{
    if (sld.classname!="monster_army" || player.classname!="player") return;
    
    custom_demon_name(sld);
    sprint(player,PRINT_HIGH,sld.netname);
    sprint(player,PRINT_HIGH,"ç ");
    sprint(player,PRINT_HIGH,msg);
};

string(entity sld) GetOwnerMessage =
{
    local float rnum;
    rnum=random();   
    
    if (sld.goalentity!=sld.real_owner)
    {
        if (rnum < 0.2 && sld.health < 200)
           return "tell my wife I love her!\n";
        else if (rnum < 0.2)
            return "remember I can't swim! heh\n";
        else if (rnum < 0.4)
            return "ready to kill!\n";  
        else if (rnum < 0.6)
            return "i'm looking for the enemy\n";
        else if (rnum < 0.8)
            return "i'm prepared!\n";            
        else return "awaiting your orders!\n";
    }
    else
    {
        if (rnum < 0.5)
            return "i'm following you!\n";
        else return "where do you want to go?\n";
    }

};

string(entity sld) GetFriendlyMessage =
{
    local float rnum;
    rnum=random();

    if (rnum < 0.5)
      return "try to not shoot me when fighting enemy! heh\n";
    else return "lets destroy the enemy!\n";
    //else return "Hope I don't crash the server\n";
};
