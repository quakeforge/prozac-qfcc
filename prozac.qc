
#pragma DONT_COMPILE_THIS_FILE

/*=======================================================//
// prozac.QC - CustomTF 3.2.OfN            - 10/3/2001 - //
// by Sergio Fumaña Grunwaldt - OfteN aka superCOCK2000  //
=========================================================//
 ProZac MOTD welcome message
=========================================================*/

string (float mframe) GetProzacMOTD =
{
    //return ftos(mframe);

    if (mframe < 30)
        return "";

    if (mframe < 35) // žŸ
        return "\n\nŸ";

    if (mframe < 40)
        return "\n\nžžŸ";

    if (mframe < 45)
        return "\n\nžžžžŸ";

    if (mframe < 50)
        return "\n\nžžžžžžŸ";

    if (mframe < 55)
        return "\n\nžžžžžžžžŸ";

    if (mframe < 60)
        return "\n\nžžžžžžžžžžŸ";

    if (mframe < 65)
        return "\n\nžžžžžžžžžžžžŸ";

    if (mframe < 75)
        return "\n\nžžžžžžžžžžžžžžŸ";

    if (mframe < 80)
        return "\n\nžžžžžžžžžžžžžžžžŸ";

    if (mframe < 85)
        return "\n\nžžžžžžžžžžžžžžžžžžŸ";

    if (mframe < 90)
        return "\n\nžžžžžžžžžžžžžžžžžžžžŸ";

    if (mframe < 95)
        return "\n\nžžžžžžžžžžžžžžžžžžžžžžŸ";

    if (mframe < 100)
        return "\n\nžžžžžžžžžžžžžžžžžžžžžžžžŸ";

    //if (mframe < 105)
    //    return "\n\nžžžžžžžžžžžžžžžžžžžžžžžžžžŸ";

    //if (mframe < 110)
    //    return "\n\nžžžžžžžžžžžžžžžžžžžžžžžžžžžžŸ";

};