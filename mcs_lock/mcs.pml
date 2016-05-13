/*
* Promela model of an MCS lock
* Author: Dave Sizer
* Date: 5/13/16
*/
#define NPROCS 3

mcs_node nodes[NPROCS];
byte alloc_next;

typedef mcs_node {
    int next;
    bool is_locked;
}

typedef mcs_lock {
    int queue; // tail

}

inline allocate_node(mcs_lock) {
    assert(alloc_next < NPROCS);
    nodes[alloc_next].next = -1;
    nodes[alloc_next].is_locked = false;
    alloc_next++;
}

inline acquire(int node) {

}

inline release(int node) {

}
