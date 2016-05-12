/* 
* A Promela model of a ticket lock
* Author: Dave Sizer
* Date  : 5/12/2016
*/
#define N 3

int ticket, serving;
byte nCS;
bool executed[4];

#define mutex (nCS <= 1)
#define nostarve (executed[1] && executed[2] && executed[3])

proctype ticket_lock() {

    int mytick;
    atomic {
        mytick = ticket;
        ticket++;
    }

    (mytick == serving);

    /* Begin crtical section */
    executed[_pid] = true;
    nCS++;
    nCS--;
    /* End crtitical section */

    serving = mytick + 1;

}

init {
    byte proc;
    atomic {
        ticket = 1;
        serving = 1;
        nCS = 0;
        proc = 1;
        do 
        :: (proc <= N)->
            run ticket_lock();
            proc++

        :: (proc > N)->
            break
        od

    }
}
