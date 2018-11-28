mtype = {drive, merge_done, merging, align_done, aligning, keep_dist};
chan leader = [1] of { mtype };
chan follow = [1] of { mtype };
chan get_id = [1] of {int};
chan set_ldr = [1] of {int};
chan get_ldr = [1] of {int};

chan y = [10] of { mtype };
chan x = [2] of { mtype };
chan msg = [1] of {mtype};

mtype curact = drive;

proctype Leader()
{
	curact = drive;
	leader!curact;
}

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

proctype Cooperate(chan lk, ll, lm)
{
	/*msg?x -> receive a broadcasted message(by joiner) and binds it to x*/
	ll?lk;
	
	/*(vy)((x!y).Ident(y)*/
	/*should it be (vy)((x?y).Ident(y) in the paper ?*/ 
	/*x!y*/
	lk!lm;

	/*Ident(get_id, y)*/
	int id;
	/*Follower's id - let this be 1. we will write it to get_id channel*/
	get_id!1;

	bool f;
	/*flag is set to 1*/
	
	/*get_id(id)*/
	get_id?id;
	
	/*y!id*/
	lm!id;
	
	/*y(flag)*/
	lm?f;

	/*Let us write 2 to get_ldr (the leader number)*/
	get_ldr!2;

	/*Respond(y, flag)*/
	if
	:: (f == 1) ->
		/*Send_Ldr(get_ldr, y)*/
		int ldr;

		/*get_ldr(ldr)*/
		get_ldr?ldr;
		printf("Curr get leader is %d\n",ldr);

		/*y!ldr*/
		lm!ldr;

		/*Rcv_Ldr(y, set_ldr);*/
		int nldr;

		/*y(nldr)*/
		lm?nldr;
		printf("Curr set leader is %d\n",nldr);

		/*set_ldr!nldr*/
		set_ldr!nldr;

		/*Align(y);*/
		mtype align_status = aligning;
		/*Delay*/
		align_status = align_done;
		
		/*y!align_done*/
		lm!align_status;
		
		/*Wait(y)*/
		mtype merge_status = merging;
		/*Delay*/
		merge_status = merge_done;

		/*y!merge_done*/
		lm!merge_status;
	fi
}

proctype Follow()
{
	follow!keep_dist;
}

init
{	
	bool flag = 0;
	run Leader();
	/*run Wait(y);*/
	/*run Align(y);*/
	/*run Rcv_Ldr(y, set_ldr);*/
	/*run Send_Ldr(get_ldr, y);*/
	/*run Respond(y, flag);*/
	/*run Ident(get_id, y);*/
	run Cooperate(x, msg, y);
	run Follow();
}
