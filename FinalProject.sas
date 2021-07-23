*STAT 224 Final Project;

*Step 1, Read in Data;

*user defined format for letter grades to number;
*PROC FORMAT...;

/*Code provided in lecture video  */
/*Reading all txt files into table called "final"
Columns of ID Date Course Credit Grade
Convert letter grade to numeric grade  */
data final;
	infile "/Data/*.txt" dlm="@" dsd missover;
	input ID $ Date Course $ Credit Grade $;
	if Grade = "A" then GPAgrade =4.0;
	else if Grade = "A-" then GPAgrade =3.7;
	else if Grade = "B+" then GPAgrade =3.4;
	else if Grade = "B" then GPAgrade = 3.0;
	else if Grade = "B-" then GPAgrade = 2.7;
	else if Grade = "C+" then GPAgrade = 2.4;	
	else if Grade = "C" then GPAgrade = 2.0;
	else if Grade = "C-" then GPAgrade = 1.7;
	else if Grade = "D+" then GPAgrade = 1.4;
	else if Grade = "D" then GPAgrade = 1.0;
	else if Grade = "D-" then GPAgrade = .7;
	else if Grade = "E" then GPAgrade = 0;
	else if Grade = "IE" then GPAgrade = 0;
	else if Grade = "UW" then GPAgrade = 0;
	else if Grade = "WE" then GPAgrade = 0;
	else GPAgrade = .;
run;


/*Code for Report 1  */
/*Code provided in lecture video  */
/*Create a table called "semester" from "final" table
Columns of ID Date semesterGPA
Calculate GPA per semester from "final" columns of GPAgrade and Credit  */
PROC SQL;
	create table semester as
	select ID, Date,
		sum(GPAgrade*Credit)/sum(Credit) as SemesterGPA
	from final
	Group By ID, Date
	;
quit;

/*Code provided in lecture video  */
/*Create a table called "EarnedCredit" from "final" table
Columns of ID Date EC
Calculate Earned Credit per semester from "final" columns of Credit  */
PROC SQL;
	create table EarnedCredit as
	select ID, Date, 
		sum(Credit) as EC
	from final
	where Grade in ("A" "A-" "B+" "B" "B-" "C+" "C" "C-" "D+" "D" "D-" "P")
	Group by ID, Date
	;
quit;

/*Create a table called "GradedCredit" from "final" table
Columns of ID Date GC
Calculate Graded Credit per semester from "final" columns of Credit  */
PROC SQL;
	create table GradedCredit as
	select ID, Date,
		sum(Credit) AS GC
	from final
	where Grade in ("A" "A-" "B+" "B" "B-" "C+" "C" "C-" "D+" "D" "D-")
	Group by ID, Date
	;
quit;

/*Code provided in lecture video  */
/*Create table called "report1"
Combine semester earnedcredit gradedcredit on ID and Date  */
PROC SQL;
	create table report1 as
	select *
	from semester 
		full join earnedcredit on semester.ID = earnedcredit.ID and semester.Date = earnedcredit.Date
		full join gradedcredit on semester.ID = gradedcredit.ID and semester.Date = gradedcredit.Date
	;
quit;

/*Help given by TA  */
/*From "report1" table split Date into Year and Term  */
data work.report1;
	set work.report1;
	Year = substrn(Date, 2, 3);
	Term = substrn(Date, 1, 1);
run; 

/*Order data in "report1" by ID Year Term  */
PROC SORT data = report1 out = report1;
	by ID Year Term;
run; 

/*Help Given by TA  */
/*Calculate cumulative weighted gpa and cumlative credit per semester
Create columns cumWeight cumCred in "report1"  */
data work.report1;
	set work.report1;
	if first.ID then cumWeight=0;
		cumWeight + SemesterGPA*GC;
	if first.ID then cumCred=0;
		cumCred + GC;
	by ID;
run;

/*Calcaulate cumulative GPA per semester as new column in "report1"  */
data work.report1;
	set work.report1;
	CumGPA = cumWeight/cumCred;
	by ID;
run;

/*Calculate cumlative earned credit
Create new column cumCredit in "report1"  */
data work.report1;
	set work.report1;
	if first.ID then cumCredit=0;
		cumCredit + EC;
	by ID;
run;

/*Calculate class standing for student per semester  */
data work.report1;
	set work.report1;
	if cumCredit < 30 then Standing = "Freshmen";
	else if 30 <= cumCredit < 60 then Standing = "Sophmore";
	else if 60 <= cumCredit < 90 then Standing = "Junior";
	else if 90 <= cumCredit then Standing = "Senior";	
run;

/*End of code for Report 1  */


/*Code for Report 2  */
/*Create second final table with only Math and Stat classes  */
PROC SQL;
	create table math as
	select *
	from final
	where substr(Course,1,4) = "MATH" or substr(Course,1,4) = "STAT"
	;
quit;

/*Create table called "Student_GPA" from "final" table
Columns of ID Overall_GPA
Calculate overall GPA per student */
PROC SQL;
	create table Student_GPAfinal as
	select ID, 
		sum(GPAgrade*Credit)/sum(Credit) as Overall_GPAfinal
	from final
	Group By ID
	;
quit;

/*Create table called "Student_EC" from "final" table
Columns of ID Overall_Earned_Credit
Calculate overall Earned Credit per student */
PROC SQL;
	create table Student_ECfinal as
	select ID, 
		sum(Credit) as Overall_Earned_Creditfinal
	from final
	where Grade in ("A" "A-" "B+" "B" "B-" "C+" "C" "C-" "D+" "D" "D-" "P")
	Group by ID
	;
quit;

/*Create table called "Student_GC" from "final" table
Columns of ID Overall_Graded_Credit
Calculate overall Graded Credit per student */
PROC SQL;
	create table Student_GCfinal as
	select ID, 
		sum(Credit) AS Overall_Graded_Creditfinal
	from final
	where Grade in ("A" "A-" "B+" "B" "B-" "C+" "C" "C-" "D+" "D" "D-")
	Group by ID
	;
quit;

/*Create table "TotalAB" from "final" table
Columns of ID Grade  */
PROC SQL;
	create table TotalABfinal as 
	select ID, Grade
	from final
	Group by ID
	;
quit;

/*Count grades of A’s B’s C’s D’s E’s (include E, UW, WE, and IE) W’s, P’s  */
data work.TotalABfinal;
	set work.TotalABfinal;
	if first.ID then AB=0;
		AB + 1;
	where Grade in ("A" "A-" "B+" "B" "B-" "C+" "C" "C-" "D+" "D" "D-" "P" "E" "UW" "WE" "IE" "W");
	by ID;
run; 

/*Keep the total counts as Classes
One Classes value per unique ID
Drop AB Grade  */
data work.TotalABfinal;
	set work.TotalABfinal;
	if last.ID then Classesfinal= AB;
	by ID;
	drop AB Grade;
run;

/*Remove all missing data to format "TotalAB" with one observation per student
Makes it easier to full join tables  */
data work.TotalABfinal;
	set work.TotalABfinal;
	if cmiss(of _all_) then delete;
run;

/*Create table "Repeats" from "final" table
Count number of duplicates of courses per student
Does not count classes that are repeatable classes (end with "R") */
PROC SQL;
	create table Repeatsfinal as 
	select ID, Course, count(*) as Count
	from final
	where Reverse(substr(Course,1,1)) ^= "R"
	Group by ID, Course
	having count(*) > 1
	;
quit;

/*Create table "TotalRepeats" from "Repeats" table
Sum the total of duplicate courses for each ID  */
PROC SQL;
	create table TotalRepeatsfinal as
	select ID, Count,
		sum(Count) as Repeatsfinal
	from Repeatsfinal
	Group by ID
	;
quit;

/*Drop count columns from "TotalRepeats"
Total count is kept */
data work.TotalRepeatsfinal;
	set work.TotalRepeatsfinal;
	drop Count;
run;

/*Remove all duplicates of data so there is only one total count per ID
Makes it easier for joining tables
Sort by ID Repeats */
PROC SORT data = TotalRepeatsfinal out = TotalRepeatsfinal nodupkey;
	by ID Repeatsfinal;
run;






/*Create table called "Student_GPA" from "final" table
Columns of ID Overall_GPA
Calculate overall GPA per student */
PROC SQL;
	create table Student_GPAmath as
	select ID, 
		sum(GPAgrade*Credit)/sum(Credit) as Overall_GPAmath
	from math
	Group By ID
	;
quit;

/*Create table called "Student_EC" from "final" table
Columns of ID Overall_Earned_Credit
Calculate overall Earned Credit per student */
PROC SQL;
	create table Student_ECmath as
	select ID, 
		sum(Credit) as Overall_Earned_Creditmath
	from math
	where Grade in ("A" "A-" "B+" "B" "B-" "C+" "C" "C-" "D+" "D" "D-" "P")
	Group by ID
	;
quit;

/*Create table called "Student_GC" from "final" table
Columns of ID Overall_Graded_Credit
Calculate overall Graded Credit per student */
PROC SQL;
	create table Student_GCmath as
	select ID, 
		sum(Credit) AS Overall_Graded_Creditmath
	from math
	where Grade in ("A" "A-" "B+" "B" "B-" "C+" "C" "C-" "D+" "D" "D-")
	Group by ID
	;
quit;

/*Create table "TotalAB" from "final" table
Columns of ID Grade  */
PROC SQL;
	create table TotalABmath as 
	select ID, Grade
	from math
	Group by ID
	;
quit;

/*Count grades of A’s B’s C’s D’s E’s (include E, UW, WE, and IE) W’s, P’s  */
data work.TotalABmath;
	set work.TotalABmath;
	if first.ID then AB=0;
		AB + 1;
	where Grade in ("A" "A-" "B+" "B" "B-" "C+" "C" "C-" "D+" "D" "D-" "P" "E" "UW" "WE" "IE" "W");
	by ID;
run; 

/*Keep the total counts as Classes
One Classes value per unique ID
Drop AB Grade  */
data work.TotalABmath;
	set work.TotalABmath;
	if last.ID then Classesmath= AB;
	by ID;
	drop AB Grade;
run;

/*Remove all missing data to format "TotalAB" with one observation per student
Makes it easier to full join tables  */
data work.TotalABmath;
	set work.TotalABmath;
	if cmiss(of _all_) then delete;
run;

/*Create table "Repeats" from "final" table
Count number of duplicates of courses per student
Does not count classes that are repeatable classes (end with "R") */
PROC SQL;
	create table Repeatsmath as 
	select ID, Course, count(*) as Count
	from math
	where Reverse(substr(Course,1,1)) ^= "R"
	Group by ID, Course
	having count(*) > 1
	;
quit;

/*Create table "TotalRepeats" from "Repeats" table
Sum the total of duplicate courses for each ID  */
PROC SQL;
	create table TotalRepeatsmath as
	select ID, Count,
		sum(Count) as Repeatsmath
	from Repeatsmath
	Group by ID
	;
quit;

/*Drop count columns from "TotalRepeats"
Total count is kept */
data work.TotalRepeatsmath;
	set work.TotalRepeatsmath;
	drop Count;
run;

/*Remove all duplicates of data so there is only one total count per ID
Makes it easier for joining tables
Sort by ID Repeats */
PROC SORT data = TotalRepeatsmath out = TotalRepeatsmath nodupkey;
	by ID Repeatsmath;
run;

/*Creat table "report2"
combine Student_GPA Student_GC TotalAB TotalRepeats*/
PROC SQL;
	create table report2math as
	select *
	from Student_GPAmath
		full join Student_ECmath on student_gpamath.ID = student_ecmath.ID
		full join Student_GCmath on student_gpamath.ID = student_gcmath.ID
		full join TotalABmath on student_GPAmath.ID = TotalABmath.ID
		full join TotalRepeatsmath on student_GPAmath.ID = TotalRepeatsmath.ID
	;
quit;

/*Creat table "report2"
combine Student_GPA Student_GC TotalAB TotalRepeats*/
PROC SQL;
	create table report2final as
	select *
	from Student_GPAfinal
		full join Student_ECfinal on student_gpafinal.ID = student_ecfinal.ID
		full join Student_GCfinal on student_gpafinal.ID = student_gcfinal.ID
		full join TotalABfinal on student_GPAfinal.ID = TotalABfinal.ID
		full join TotalRepeatsfinal on student_GPAfinal.ID = TotalRepeatsfinal.ID
	;
quit;

/*Combine both report2 tables (math/stat and overall) */
PROC SQL;
	create table report2 as
	select *
	from report2final
		full join report2math on report2math.ID = report2final.ID
	;
quit;

/* End of code for Report 2  */


/*Code for Report 3  */
/*Create table "TopGPA"
Columns of  ID Overall_GPA Overall_Earned_Credit
Only keep data with Earned Credit less than 130 and greater than 60 */
PROC SQL;
	create table TopGPA as 
	select ID, Overall_GPAfinal, Overall_Earned_Creditfinal
	from report2
	where 60 < Overall_Earned_Creditfinal < 130
	;
quit;

/*Sort "TopGPA" with descending Overall_GPA to display the top GPA's  */
PROC SORT data = TopGPA out = report3;
	by descending Overall_GPAfinal;
run;

/*End of code for Report 3  */

/*Create a final html report with four sections as described below  */
ods html file = "/folders/myfolders/Stat224/Final/FinalProject.html";

/*Report 1: By student, semester (earliest to latest)
Drop cumCred Year Term cumWeight cumCredit   */
title "Report 1";
PROC REPORT data = report1 (drop=cumCred Year Term cumWeight cumCredit);
quit;

/*Report 2: By student (overall)  */
title "Report 2";
PROC REPORT data = report2;
quit;

/*Report 3: Sorted by GPA a list of the top 10 percent of those that have more than
60 credit hours but less than 130
Display only 12 observations since 10% of 124 students ~ 12.4  */
title "Report 3";
PROC REPORT data = report3(OBS=12 drop= Overall_Earned_Creditfinal);
run;

/*End of html file  */
ods html close;

/*Report 4:  Boxplot that displays the distribution of Overall GPAs  */
title "Report 4";
PROC SGPLOT data = TopGPA;
  vbox Overall_GPAfinal;
run;
