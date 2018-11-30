mtype = {drive, merge_done, merging, align_done, aligning, keep_dist};
chan leader = [1] of { mtype };
chan follow = [1] of { mtype };
chan get_id = [1] of {int};
chan set_ldr = [1] of {int};
chan get_ldr = [1] of {int};

chan y = [10] of { mtype };
chan x = [2] of { mtype };
chan msg = [1] of {mtype};

proctype Wait(chan la)
{
	mtype merge_status = merging;
	/*Delay*/
	merge_status = merge_done;
	la!merge_status;
}

proctype Align(chan lb)
{
	mtype align_status = aligning;
	/*Delay*/
	align_status = align_done;
	lb!align_status;
}

proctype Rcv_Ldr(chan lc, ld)
{
	int nldr;

	/*y(nldr)*/
	lc?nldr;
	printf("Curr leader is %d\n",nldr);

	/*set_ldr!nldr*/
	ld!nldr;

	/*Align(lc);*/
}

proctype Send_Ldr(chan le, lf)
{
	int ldr;

	/*get_ldr(ldr)*/
	le?ldr;
	printf("Curr leader is %d\n",ldr);

	/*y!ldr*/
	lf!ldr;

	/*Rcv_Ldr(lf, ldr);*/
}

proctype Respond(chan lg, lh)
{
	if
	:: (lh == 1) ->
		/*Send_Ldr(lg)*/
	fi
}

proctype Ident(chan li, lj)
{
	int id, f;

	/*get_id(id)*/
	li?id;
	
	/*y!id*/
	lj!id;
	
	/*y(flag)*/
	lj?f;

	/*Respond(lj, f)*/
		
}

init
{	
	bool flag = 0;
	/*run Wait(y);*/
	/*run Align(y);*/
	/*run Rcv_Ldr(set_ldr, y);*/
	/*run Send_Ldr(get_ldr, y);*/
	/*run Respond(y, flag);*/
	/*run Ident(get_id, y);*/
}
