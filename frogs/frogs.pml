/* Start condition MMM_FFF */
/* End condition FFF_MMM */
/* We will use M = 1 and F = 2 */


byte board[7];


inline check_solution() {
    int i;
    bool result = true;

    byte solution[7];
    solution[0] = 2;
    solution[1] = 2;
    solution[2] = 2;
    solution[3] = 0;
    solution[4] = 1;
    solution[5] = 1;
    solution[6] = 1;

    /* check for equality */
    for (i : 0 .. 6) {
    if
    :: board[i] != solution[i] ->
         result = false;
         break
    :: else -> skip
    fi
    }

    assert(result == false)

}


proctype frog(byte position) {
    byte gender;

    atomic {
        gender = board[position];
        printf("Process %d gender: %d\n", _pid, gender);
        }

        /* Keep trying to make moves.  If we can't, check if we are in the
         * solution state and set the bool so we get an assertion
         */
        do  :: 
        atomic {
            if :: (gender == 1)->
                    /* Move right */
                    if  ::  (position+1 < 7) &&
                            (board[position+1] == 0)->

                            board[position] = 0;
                            position++;
                            board[position] = gender;
                    /* Jump right */
                        :: (position+2 < 7) &&
                           (board[position+2] == 0)->

                           board[position] = 0;
                           position = position + 2;
                           board[position] = gender;

                        :: else->
                            check_solution();
                    fi

                :: (gender == 2)->
                    /* Move left */
                    if :: (position-1 >= 0) &&
                          (board[position-1] == 0)->

                          board[position] = 0;
                          position--;
                          board[position] = gender;

                    /* Jump left */
                      :: (position-2 >= 0) &&
                         (board[position-2] == 0)->

                         board[position] = 0;
                         position = position - 2;
                         board[position] = gender;

                      :: else->
                         check_solution();

                    fi
            fi
        }
        od
}

init {

    /* Run our frogs */
    board[0] = 1;
    board[1] = 1;
    board[2] = 1;
    board[3] = 0;
    board[4] = 2;
    board[5] = 2;
    board[6] = 2;

    run frog(0);
    run frog(1);
    run frog(2);
    run frog(4);
    run frog(5);
    run frog(6);
}
