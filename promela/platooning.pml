/*
	Platooning Code (2018)
	Author: Lakhan Shiva Kamireddy
	University of Colorado Boulder
*/
mtype = {drive, merge_done, merging, align_done, aligning, keep_dist};
chan leader = [1] of { mtype };
chan follow = [1] of { mtype };
chan get_id = [1] of {int};
chan set_ldr = [2] of {int};
chan get_ldr = [1] of {int};
chan follower_id = [1] of {int};

chan y = [1] of { mtype }; //This is only used in joiner process
chan check_join = [2] of { mtype, int};
int cur_ldr = 1;
int joiner_val = 4;
int ldr_proc_cnt = 0;
int jnr_proc_cnt = 0;
int flr_proc_cnt = 0;

mtype curact = drive;

proctype Leader()
{
	curact = drive;
	ldr_proc_cnt++;

	/*Let us write 2 to get_ldr (the leader number)*/
	get_ldr!1;
	cur_ldr = 1;

	leader!curact;
	printf("Executed Leader process\n");
	
	/*Making sure there is only one leader process at any time
	  Leader is started with pid 1. If a second leader get's started, following assertion gets violated.*/
	assert(ldr_proc_cnt == 1);
}

proctype Cooperate(chan lk)
{
	chan y2 = [10] of { int };
	int j_id;
	printf("Starting cooperate process\n");
	/*msg?x -> receive a broadcasted message(by joiner) and binds it to x*/
	
	/*(vy)((x!y).Ident(y))*/
	/*should it be (vy)((x?y).Ident(y)) in the paper ?*/ 
	/*x!y*/
	lk?j_id;	
		
	int f_id;
	int temp;
	
	/*Test-checking what is in y2*/
	y2!j_id;
	y2?j_id;
	printf("Cooperate process j_id is %d\n", j_id);
	
	if
	:: (j_id != 0) ->

	y2!j_id;

	/*Ident(get_id, y)*/
	int id;
	/*Follower's id - let this be 1. we will write it to get_id channel*/
	/*Added this since, something has to be in get_id*/
	get_id!2;
	
	/*Test-print follower id*/
	get_id?f_id;
	printf("Follower id is %d\n", f_id);
	get_id!f_id;

	int f;
	/*flag is set to 1*/
	
	/*get_id(id)*/
	get_id?id;
	
	/*y!id*/
	y2!id;
	
	/*y(flag)*/
	y2?f;
	
	/*output y*/
	y2?temp;
	
	/*Test - testing what is in f*/
	printf("Cooperate process, printing flag: %d\n", f);

	/*Respond(y, flag)*/
	if
	:: (f != 0) ->
		printf("Passed cooperate process' if condition\n");
		/*Send_Ldr(get_ldr, y)*/
		/*Acc to the descr, Send_Ldr transmits the vehicle preceding the Follower
		  to Joiner, which is 1 in this case*/
		int ldr;

		/*get_ldr(ldr)*/
		get_ldr?ldr;
		/*get_ldr is giving us the preceding vehicle id*/
		printf("Current leader in cooperate process is %d\n",ldr);

		/*The follower coomunicates the preceding vehicle id to the joiner*/
		lk!ldr;

		/*y!ldr*/
		/*Making this y2!nldr since, our new preceding vehicle is Joiner*/
		y2!j_id;

		/*Rcv_Ldr(y, set_ldr);*/
		/*Acc to descr, when joiner is in position, in Rcv_ldr routine,
		  the Follower sets the Joiner as its new preceding vehicle*/
		int nldr;

		/*y(nldr)*/
		/*nldr is the new ldr*/
		y2?nldr;
		printf("Current new leader in cooperate process is %d\n",nldr);

		/*set_ldr!nldr*/
		set_ldr!nldr;

		/*Align(y);*/
		mtype align_status = aligning;
		/*Delay*/
		/*Here, the distance is increased to d*/
		align_status = align_done;
		
		/*align_done*/
		
		/*Wait(y)*/
		mtype merge_status = merging;
		/*Delay*/
		/*Here the joiner vehicle is fully merging into the platoon*/
		merge_status = merge_done;

		/*merge_done*/
	fi
	fi
	printf("End of Cooperate process\n");
}

proctype Follow()
{
	follow!keep_dist;
	flr_proc_cnt++;

	/*The folowing assertion fails if the joiner fails to become follower after executing merge*/
	assert(flr_proc_cnt > jnr_proc_cnt);
}

proctype Listen(chan ly)
{
	chan mm = [1] of { int };/*We will use channel mm at the end of successful join*/
	chan z = [1] of { int };
	int id = 4; /*Id of the Joiner vehicle*/
	int f_id;
	int v_id = 1; /*Joiner wants to join behind a vehicle of id 1*/

	/*channel j is considered x in the process*/
	/*x(y)*/	
	//Since x and y channels are of incompatible types, getting directly from channel j

	/*y(id)*/
	//ly?id;
	//printf("Printing joiner id %d\n", id);
	
	/*Wait until the ly channel has the id communicated by Follower process*/
	ly?f_id;
	printf("Printing from listen process preceding vehicle id %d\n", f_id);
	/*Here the joiner process knows before hand that it wants to join behind
	  vehicle with id 1. This is checked in the check_join routine*/	

	/*Check(y,id)*/
	bool ok;

	/*(vz)check_join<z,id>*/
	if
	:: (f_id == v_id) ->
		/*check_join sub process matched id for compatibility and puts a 1 on the z which is ok*/
		/*id is compatible and let z have 1*/	
		z!1;
		printf("The id received from follower is compatible\n");
	fi

	/*z(ok)*/
	z?ok;

	/*Ans(y,ok)*/
	/*y!ok*/
	y!ok;	
	
	/*if(ok == True) then Rcv_Ldr(y)*/
	if
	:: (ok == 1) -> 
		/*Rcv_Ldr(y)*/
		printf("Passed listen proc if condition\n");
		int ldr;

		/*y(ldr)*/
		/*y chan is of incompatible type */
		ldr = cur_ldr;
		printf("Current leader in Listen process is %d\n",ldr);

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
		printf("End of Listen process\n");
	
		/*After merge fully complete, the joiner will take the role of the follower*/
		joiner_val = 0;
		run Joiner(mm);
		printf("Joiner becomes follower\n");
		run Follow();
		jnr_proc_cnt++;
	fi
	
}

proctype Joiner(chan laa)
{
	laa!joiner_val;
	//laa!4;
	/*(vx)(b<x>||!Listen(x)) - broadcasts message x to any vehicle in the range
	  with it's intention to join*/
	/*In the program we are broadcasting to channel j*/

}

/*proctype Monitor()
{
	assert(cur_ldr == 2);
}*/

init
{	
	chan j = [1] of { int };
	run Leader();
	run Joiner(j);
	run Cooperate(j);
	run Listen(j);
	run Follow();
	//run Monitor();
}
