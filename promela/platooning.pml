mtype = {drive, stay};
chan leader = [1] of { mtype };

mtype curact = drive;

active proctype Leader()
{
	curact = drive;
	leader!curact;
}
