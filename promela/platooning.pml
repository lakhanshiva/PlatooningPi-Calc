/*
	Platooning Code
	Author: Lakhan Shiva Kamireddy
	University of Colorado Boulder
	Note: Pending sanity check
*/
mtype = {drive, merge_done, merging, align_done, aligning, keep_dist};
chan leader = [1] of { mtype };
chan follow = [1] of { mtype };
chan get_id = [1] of {int};
chan set_ldr = [1] of {int};
chan get_ldr = [1] of {int};

chan y = [10] of { mtype };
chan x = [2] of { mtype };
chan msg = [1] of {mtype};
chan check_join = [2] of { mtype, int};

mtype curact = drive;

proctype Leader()
{
	curact = drive;
	leader!curact;
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

proctype Listen(chan ly, lz)
{
	chan z = [1] of { mtype };
	int id;

	/*x(y)*/	
	
	/*y(id)*/
	ly?id;	

	/*Check(y,id)*/
	bool ok;

	/*(vz)check_join<z,id>*/
	check_join!z,id;
	
	/*z(ok)*/
	z?ok;

	/*Ans(y,ok)*/
	/*y!ok*/
	y!ok;	
	
	/*if(ok == True) then Rcv_Ldr(y)*/
	if
	:: (ok == 1) -> 
		/*Rcv_Ldr(y)*/
		int ldr;

		/*y(ldr)*/
		y?ldr;
		printf("Curr leader is %d\n",ldr);

		/*set_ldr!ldr*/
		set_ldr!ldr;

		/*Align(y);*/
		mtype align_status = aligning;
		/*Delay*/
		align_status = align_done;
	
		/*Wait(y)*/
		int fid;

		/*get_id(id)*/
		get_id?fid;
	
		/*y!id*/
		y!fid;

		/*y.Merge(y)*/
		mtype merge_status = merging;
		/*Delay*/
		merge_status = merge_done;
		y!merge_status;
	fi
	
}

proctype Joiner(chan laa)
{
	laa!3;
	/*(vx)(b<x>||!Listen(x)) - broadcasts message x to any vehicle in the range*/

}

init
{	
	chan j = [1] of { int };
	bool flag = 0;
	run Leader();
	run Cooperate(x, msg, y);
	run Follow();
	run Joiner(j);
	run Listen(j, y);
}
