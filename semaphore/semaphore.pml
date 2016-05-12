typedef Semaphore {
    byte count, queued;
    chan c;
}

inline initSem(S,n) {
    S.queued = 0;
    S.count = n;
    S.c = [0] of { bit }
}

inline wait(S) {
    atomic {
        if :: S.count >= 1 -> S.count--;
           :: else ->
                /* Wait on the channel for a signal when we are unblocked */
                S.queued++;
                S.c?1
        fi

    }

}

inline signal(S) {
    atomic {
        if :: (S.queued > 0)->
            S.c!1;
            S.queued--;
           :: else->
            S.count++;
        fi
    }
}
