/*=======================================================//
// ofnents.QC - CustomTF 3.2.OfN           - 30/1/2001 - //
// by Sergio Fumaña Grunwaldt - OfteN aka superCOCK2000  //
=========================================================//
 Additional map entities, spawn functions
=========================================================*/

void() model_solid =
{
    if (self.mdl != "")
        precache_model(self.mdl);
    
    self.movetype = #MOVETYPE_NONE;
	self.solid = #SOLID_BBOX;
	
    setmodel (self, self.mdl);
    setsize(self, self.mins, self.maxs);
    setorigin(self, self.origin);  
};

void() model_nonsolid =
{
    if (self.mdl != "")
    	precache_model(self.mdl);
    
    self.movetype = #MOVETYPE_NONE;
	self.solid = #SOLID_NOT;
	
    setmodel (self, self.mdl);
	setorigin(self, self.origin);
    makestatic (self); //CRASH This used to have no args. Possible?
};