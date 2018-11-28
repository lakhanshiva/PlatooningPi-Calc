mtype = {drive, merge_done, merging, align_done, aligning};
chan leader = [1] of { mtype };
chan cur_id = [1] of {int};
chan cur_ldr = [1] of {int};

chan y = [10] of { mtype };

mtype curact = drive;
mtype merge_status = merging;
mtype align_status = aligning;

proctype Leader()
{
	curact = drive;
	leader!curact;
}

proctype Wait(chan l)
{
	merge_status = merging;
	/*Delay*/
	merge_status = merge_done;
	l!merge_status;
}

proctype Align(chan m)
{
	align_status = aligning;
	/*Delay*/
	align_status = align_done;
	m!align_status;
}

init
{
	run Leader();
	run Wait(y);
	run Align(y);
}

