// QW CenterPrinting hack
// these functions are only used if in normal quake

#include "defs.qh"


// replaces punchangle in QW
void(float psize, entity p) KickPlayer =
{
	msg_entity = p;
	if (psize > -3)
		WriteByte (MSG_ONE, SVC_SMALLKICK);
	else // (size < -3)
		WriteByte (MSG_ONE, SVC_BIGKICK);
};

void() muzzleflash =
{
	WriteByte (MSG_MULTICAST, SVC_MUZZLEFLASH);
	WriteEntity (MSG_MULTICAST, self);
	multicast (self.origin, MULTICAST_PVS);
};
