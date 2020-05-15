libname miniprj 'D:\Marc - DSA\SAS_2 - Advanced SAS Programming\sas project';

data miniprj.wireless;
	length acctno $13 actdt 3 deactdt 3 deactreason $4 goodcredit 3 rateplan 3
			dealertype $2 Age 3 Province $2 Sales 3;
	infile 'D:\Marc - DSA\SAS_2 - Advanced SAS Programming\sas project\New_wireless_pipe.txt' 
		dsd delimiter='|' /* dlm='|' */firstobs=2;
	informat actdt mmddyy10. deactdt mmddyy10. sales dollar8.;
	input acctno $ actdt deactdt deactreason $ goodcredit rateplan 
		  dealertype $ AGE Province $ sales;
	format actdt mmddyy10. deactdt mmddyy10. sales dollar8.2;
run;


data Wireless2;
	infile 'D:\Marc - DSA\SAS_2 - Advanced SAS Programming\sas project\New_wireless_Fixed.txt' firstobs=1;
	input
	@1 Acctno $13.
	@15 actdt mmddyy10.
	@26 deactdt mmddyy10.
	@41 deactreason $4.
	@53 goodcredit 1. 
	@62 rateplan 1.
	@65 dealertype $2.
	@74 Age 2.
	@80 Province $2.
	@85 Sales dollar8.2
	;
	format sales dollar8.2;
run;
/* 1.1 Explore and describe the dataset briefly. For example, is the acctno unique? What
is the number of accounts activated and deactivated? When is the earliest and
latest activation/deactivation dates available? And so on….
*/

proc contents data=miniprj.wireless;
run;

proc sort data=miniprj.wireless nodupkey dupout=miniprj.duplicate_data;
	by Acctno;
run;

proc means data=miniprj.wireless N;
	var actdt;
	where deactdt =.;
run;

proc means data=miniprj.wireless N Min Max;
	var actdt deactdt;
	format actdt mmddyy10. deactdt mmddyy10.;
run;

proc summary data=miniprj.wireless;
	var actdt deactdt;
	output out=miniprj.summary_data;
run;



/*******/

proc freq data=miniprj.wireless;
	table province;
	where deactdt=.;
	
run;

proc freq data=miniprj.wireless;
	table province;
	where deactdt=.;
	
run;



/**************/



proc print data=miniprj.wireless (obs=10);
	format sales dollar8.2;
run;


proc sort data=miniprj.wireless out=miniprj.Wireless_sort;
	by age province;
run;

proc format; * library=miniprj;
	value agegrp low-20 = 'Under 20'
				 21-40 = '21 to 40 YRS'
				 41-60 = '41 to 60 YRS'
				 60-high='60 YRS and over';

	value $provincefmt 'AB'='Alberta'
					  'BC'='British Columbia'
					  'NS'='Nova Scotia'
					  'ON'='Ontario'
					  'QC'='Quebec';

	value salesfmt   low-100='Under $100'
					 100-500= 'Between $100 to $500'
					 500-800= 'Between $500 to $800'
					 800-high= '$800 and over';

	value monthfmt	1='January'
					2='February'
					3='March'
					4='April'
					5='May'
					6='June'
					7='July'
					8='August'
					9='September'
					10='October'
					11='November'
					12='December';


run;


/* 1.2 What is the age and province distributions of active and deactivated customers?
Use dashboards to present and illustrate. */

option fmtsearch=(miniprj);
proc freq data=miniprj.wireless_sort;
	table province*age;
	where deactdt ne .;
	format age agegrp. province $provincefmt.;
	title 'Province by age distribution for deactivated accounts';
run;


proc freq data=miniprj.wireless_sort;
	table province*age;
	where deactdt = .;
	format age agegrp. province $provincefmt.;
	title 'Province by age distribution for active accounts';
run;
	



/* 1.3 */


proc tabulate data=miniprj.wireless;
	var sales;
	class age;
	table age, sales(n pctn='Percent');
	format age agegrp.;
	title 'Sales amount for age segment';
run;


ods graphics on;
goptions reset=all;
proc gchart data=miniprj.wireless;
	pie sales/discrete value=inside
	percent=inside
	slice=outside;
	format sales salesfmt.;
run;
ods graphics off;



/* 1.4------------------
---1)------------------*/

proc sort data=miniprj.wireless out=miniprj.sorted;
	by descending actdt;
run;

data miniprj.tenure_data;
	set miniprj.wireless;
	maxdate='19jan2001'd;
	if deactdt = . then tenure = maxdate - actdt;
	else tenure = deactdt - actdt;
run;

proc means data = miniprj.tenure_data;
	var tenure;
	title 'Statistic for tenure';
run;


/* 1.4------------------
---2)------------------*/


data miniprj.monthlystatus;
	set miniprj.tenure_data;
	if deactdt ne .;
	year=year(actdt);
	month=month(actdt);
run;




proc freq data=miniprj.monthlystatus;
	table year * month;
	format month monthfmt.;
	title 'Statistic of accounts deactivated by month';
run;

/*
ods graphics on;
goption reset=all;
proc sgplot data=miniprj.monthlystatus;
	histogram month/showbins scale=count;
	density month/type=kernel;
	format month monthfmt.;
run;

ods graphics on;
goption reset=all;
proc sgplot data=miniprj.monthlystatus;
	vbar year/groupdisplay=cluster;
	format month monthfmt.;
run;
ods graphics off;*/


/* 1.4------------------
---3)------------------*/

proc format; *library=miniprj;
	value tenurefmt low-30='Less than 30 days'
					31-60='31 - 60 days'
					61-365='61 - one year'
					366-high='over one year';
run;

data miniprj.segmentation;
	Acctnum=input(acctno, 13.);
	set miniprj.tenure_data;
	if deactdt ne . then acctstatus = 'Deactivated';
	else acctstatus = 'Active';
run;


proc freq data=miniprj.segmentation;
	table acctstatus*tenure;
	format tenure tenurefmt.;
	
run;


/* 1.4------------------
---4)------------------*/

proc tabulate data=miniprj.segmentation;
	var goodcredit rateplan;
	class tenure dealertype;
	table goodcredit, tenure * rateplan, dealertype;
	*table Goodcredit, (tenure all)*(n pctn), (dealertype rateplan);
	format tenure tenurefmt.;
run;


proc tabulate data=miniprj.segmentation;
	var goodcredit rateplan;
	class tenure dealertype;
	table goodcredit, tenure * rateplan, dealertype;
	*table Goodcredit, (tenure all)*(n pctn), (dealertype rateplan);
	format tenure tenurefmt.;
run;


/* 1.4------------------
---5)------------------*/

proc freq data = miniprj.segmentation;
	table acctstatus*tenure;
	format tenure tenurefmt.;
	title 'Association between accout status and tenure'; 
run;

proc format; *library=miniprj;
	value tenure2fmt low-30='Less than 30 days'
					31-90='1 - 3 months'
					91-180='3 - 6 months'
					181-270='6 - 9 months'
					271-365='9 months - one year'
					366-high='over one year';
run;

proc freq data = miniprj.segmentation;
	table acctstatus*tenure;
	format tenure tenure2fmt.;
	title 'Association between accout status and tenure'; 
run;
