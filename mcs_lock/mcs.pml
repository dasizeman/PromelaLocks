/*
* Promela model of an MCS lock
* Author: Dave Sizer
* Date: 5/13/16
*/
#define NPROCS 3


byte nCS;
bool executed[4];

#define mutex (nCS <= 1)
#define nostarve (executed[1] && executed[2] && executed[3])

typedef mcs_node {
    int next;
    bool is_locked;
}

typedef mcs_lock {
    int queue; // tail

}

mcs_node nodes[NPROCS];
mcs_lock lock;

byte alloc_next;

inline allocate_node() {
    assert(alloc_next < NPROCS);
    nodes[alloc_next].next = -1;
    nodes[alloc_next].is_locked = false;
    alloc_next++;
}

inline acquire(node) {
    int pred;
    nodes[node].next = -1;

    atomic {
        pred = lock.queue;
        lock.queue = node;

    }

    if 
    :: (pred != -1)->
        nodes[node].is_locked = true;
        nodes[pred].next = node;

        (nodes[node].is_locked == false);

    :: else->
    fi


}

inline release(node) {
    bool cmp;
    if 
    :: (nodes[node].next == -1)->
        atomic {
            if 
            :: (node == lock.queue)->
                lock.queue = -1
                cmp = true;
            :: else->
                cmp = false;
            fi
        }
        if 
        :: (cmp == false)->
            // Wait for our next field to be set
            (nodes[node].next != -1);

            // Unlock the next node
            nodes[nodes[node].next].is_locked = false;
        :: else->
        fi


    :: else->
        // Unlock the next node
        nodes[nodes[node].next].is_locked = false;
    fi
        

}

proctype p() {
    int mynode;

    // Allocate ourselves a node
    atomic {
        mynode = alloc_next;
        allocate_node();
    }

    acquire(mynode);
    executed[_pid] = true;
    nCS++;
    nCS--;
    release(mynode);
}

init {
    byte proc;
    atomic {
        lock.queue = -1; 
        nCS = 0;
        proc = 1;
        do 
        :: (proc <= NPROCS)->
            run p();
            proc++

        :: (proc > NPROCS)->
            break
        od

    }
}
