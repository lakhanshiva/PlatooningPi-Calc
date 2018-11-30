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

proctype Merge(chan ln)
{
	mtype merge_status = merging;
	/*Delay*/
	merge_status = merge_done;
	ln!merge_status;
		
}

proctype Wait(chan lo, lp)
{
	int fid;

	/*get_id(id)*/
	lo?fid;
	
	/*y!id*/
	lp!fid;

	/*y.Merge(y)*/
		
}

proctype Align(chan lq)
{
	mtype align_status = aligning;
	/*Delay*/
	align_status = align_done;
	
	/*Wait(y)*/	
}

proctype Rcv_Ldr(chan lr, ls)
{
	int ldr;

	/*y(ldr)*/
	ls?ldr;
	printf("Curr leader is %d\n",ldr);

	/*set_ldr!ldr*/
	lr!ldr;

	/*Align(y);*/
}

proctype Ans(chan lt, lu)
{
	/*y!ok*/
	lu!lt;	
	
	/*if(ok == True) then Rcv_Ldr(y)*/
	if
	:: (lt == 1) -> 
		/*Rcv_Ldr(y)*/
		
	fi
}

proctype Check(chan lv, lw, lx)
{
	chan z = [1] of { mtype };
	bool ok;

	/*(vz)check_join<z,id>*/
	lv!z,lw;
	
	/*z(ok)*/
	z?ok;

	/*Ans(y,ok)*/
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
	/*int id = 3;*/
	/*run Merge(y);*/
	/*run Wait(get_id, y);*/
	/*run Align(y);*/
	/*run Rcv_Ldr(set_ldr, y);*/
	/*run Ans(ok, y);*/
	/*run Check(check_join, id, y);*/
	/*run Listen(x, y);*/

	chan j = [1] of { int };
	run Joiner(j);
	run Listen(j, y);		
}
