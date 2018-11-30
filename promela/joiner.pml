mtype = {drive, merge_done, merging, align_done, aligning, keep_dist};
chan leader = [1] of { mtype };
chan follow = [1] of { mtype };
chan get_id = [1] of {int};
chan set_ldr = [1] of {int};
chan get_ldr = [1] of {int};

chan y = [10] of { mtype };
chan x = [2] of { mtype };
chan msg = [1] of {mtype};

proctype Merge(chan ln)
{
	mtype merge_status = merging;
	/*Delay*/
	merge_status = merge_done;
	ln!merge_status;
		
}

proctype Wait(chan lo, lp)
{
	int id;

	/*get_id(id)*/
	lo?id;
	
	/*y!id*/
	lp!id;

	/*y.Merge(y)*/
		
}

proctype Align(chan lq)
{
	mtype align_status = aligning;
	/*Delay*/
	align_status = align_done;
	
	/*Wait(y)*/	
}

init
{	
	run Merge(y);
	run Wait(get_id, y);
	run Align(y);
}
