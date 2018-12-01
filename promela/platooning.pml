/*
	Platooning Code (2018)
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
chan follower_id = [1] of {int};

chan y = [10] of { mtype };
chan x = [2] of { mtype };
chan check_join = [2] of { mtype, int};
int cur_ldr = 2;

mtype curact = drive;

proctype Leader()
{
	curact = drive;
	leader!curact;
}

proctype Cooperate(chan lk, ll)
{
	chan y2 = [10] of { mtype };

	/*msg?x -> receive a broadcasted message(by joiner) and binds it to x*/
	ll?lk;
	
	/*(vy)((x!y).Ident(y))*/
	/*should it be (vy)((x?y).Ident(y)) in the paper ?*/ 
	/*x!y*/
	lk!y2;

	/*Ident(get_id, y)*/
	int id;
	/*Follower's id - let this be 1. we will write it to get_id channel*/
	/*Added this since, something has to be in get_id*/
	get_id!1;

	int f;
	/*flag is set to 1*/
	
	/*get_id(id)*/
	get_id?id;
	
	/*y!id*/
	y2!id;
	
	/*y(flag)*/
	y2?f;

	/*Let us write 2 to get_ldr (the leader number)*/
	get_ldr!2;
	cur_ldr = 2;

	/*Respond(y, flag)*/
	if
	:: (f == 1) ->
		/*Send_Ldr(get_ldr, y)*/
		int ldr;

		/*get_ldr(ldr)*/
		get_ldr?ldr;
		//printf("Curr get leader is %d\n",ldr);

		/*y!ldr*/
		y2!ldr;

		/*Rcv_Ldr(y, set_ldr);*/
		int nldr;

		/*y(nldr)*/
		y2?nldr;
		//printf("Curr set leader is %d\n",nldr);

		/*set_ldr!nldr*/
		set_ldr!nldr;

		/*Align(y);*/
		mtype align_status = aligning;
		/*Delay*/
		align_status = align_done;
		
		/*align_done*/
		
		/*Wait(y)*/
		mtype merge_status = merging;
		/*Delay*/
		merge_status = merge_done;

		/*merge_done*/
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
	/*channel j is considered x in the process*/
	/*x(y)*/	
	//Since x and y channels are of incompatible types, getting directly from channel j

	/*y(id)*/
	ly?id;
	printf("Printing joiner id %d\n", id);	

	/*Check(y,id)*/
	bool ok;

	/*(vz)check_join<z,id>*/
	/*check_join sub process matched id for compatibility and puts a 1 on the z which is ok*/
	/*Will assume the behavior for now*/
	/*Let id be compatible and let z have 1*/	
	z!1;

	/*z(ok)*/
	z?ok;

	/*Ans(y,ok)*/
	/*y!ok*/
	y!ok;	
	
	/*if(ok == True) then Rcv_Ldr(y)*/
	if
	:: (ok == 1) -> 
		/*Rcv_Ldr(y)*/
		printf("Passed if condition\n");
		int ldr;

		/*y(ldr)*/
		/*y chan is of incompatible type */
		ldr = cur_ldr;
		printf("Curr leader is %d\n",ldr);

		/*set_ldr!ldr*/
		set_ldr!ldr;

		/*Align(y);*/
		mtype align_status = aligning;
		/*Delay*/
		align_status = align_done;
	
		/*Wait(y)*/
		int fid;

		/*Added this since, something has to be in get_id*/
		get_id!ldr;

		/*get_id(id)*/
		get_id?fid;
	
		/*y!id*/
		/*y is of incompatible type*/
		/*We write to follower_id channel*/
		follower_id!fid;
		
		/*Test-remove later*/
		//follower_id?fid;
		//printf("Test print fid %d\n",fid);

		/*y.Merge(y)*/
		/*Merge(y)*/
		mtype merge_status = merging;
		/*Delay*/
		merge_status = merge_done;
		
		/*merge_start'.merge_done.y'.Follower*/
		printf("End of joiner process\n");		
	fi
	
}

proctype Joiner(chan laa)
{
	laa!3;
	/*(vx)(b<x>||!Listen(x)) - broadcasts message x to any vehicle in the range*/
	/*In the program we are broadcasting to channel j*/

}

init
{	
	chan j = [1] of { int };
	run Leader();
	run Joiner(j);
	run Listen(j, y);
	run Cooperate(x, j);
	run Follow();
}
