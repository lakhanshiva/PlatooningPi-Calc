mtype = {drive, merge_done, merging, align_done, aligning};
chan leader = [1] of { mtype };
chan align_status = [2] of {mtype};
chan merge_status = [2] of {mtype};
chan cur_id = [1] of {int};
chan cur_ldr = [1] of {int};

chan y = [1] of { mtype };

mtype curact = drive;

proctype Leader()
{
	curact = drive;
	leader!curact;
}

proctype Wait(chan y)
{
	y!merge_done;

}
