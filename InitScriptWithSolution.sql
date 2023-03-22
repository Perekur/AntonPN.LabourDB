/*
Employees work one or several shifts per day.
Breaks has to be taken according to the list of Break Rules.
If employee works more then [BreakRequiredAfter] hours per day,
break should be taken within [TakeBreakWithin] hours and has to be not shorter than [MinBreakMinutes]

Based on Timecards and rules we need to get the following result set:
EmployeeId, Businessdate, NumberOfNotSatisfiedRules. 

*/

DECLARE @Timecards TABLE(	
		ID int Identity(1,1),	
		BusinessDate smalldatetime ,
		StartDate datetime ,
		EndDate datetime,
		EmployeeID uniqueidentifier  	
)
DECLARE @BreakRules TABLE(	
	ID int Identity(1,1),	
	MinBreakMinutes int  ,
	BreakRequiredAfter  decimal(10,2) ,
	TakeBreakWithin  decimal(10,2) 
)

-- fill timecards
DECLARE @EmployeeID uniqueidentifier 
DECLARE @BusinessDate smalldatetime

SET @EmployeeID =newid()
set @BusinessDate ='2/28/2023'

INSERT INTO  @Timecards (EmployeeID, BusinessDate,	StartDate,	EndDate)
Values(@EmployeeID, @BusinessDate,'2/28/2023 5:55','2/28/2023 9:24')
INSERT INTO  @Timecards (EmployeeID, BusinessDate,	StartDate,	EndDate)
Values(@EmployeeID, @BusinessDate,'2/28/2023 9:55','2/28/2023 16:18')

set @BusinessDate= '2/27/2023'
INSERT INTO  @Timecards (EmployeeID, BusinessDate,	StartDate,	EndDate)
Values(@EmployeeID, @BusinessDate,'2/27/2023 6:00','2/27/2023 17:20')

SET @EmployeeID =newid()
set @BusinessDate ='2/28/2023'

INSERT INTO  @Timecards (EmployeeID, BusinessDate,	StartDate,	EndDate)
Values(@EmployeeID, @BusinessDate,'2/28/2023 5:20','2/28/2023 8:30')
INSERT INTO  @Timecards (EmployeeID, BusinessDate,	StartDate,	EndDate)
Values(@EmployeeID, @BusinessDate,'2/28/2023 8:45','2/28/2023 13:03')
INSERT INTO  @Timecards (EmployeeID, BusinessDate,	StartDate,	EndDate)
Values(@EmployeeID, @BusinessDate,'2/28/2023 13:33','2/28/2023 17:00')
INSERT INTO  @Timecards (EmployeeID, BusinessDate,	StartDate,	EndDate)
Values(@EmployeeID, @BusinessDate,'2/28/2023 17:25','2/28/2023 19:00')

-- fill rules
INSERT INTO @BreakRules (MinBreakMinutes ,	BreakRequiredAfter   ,	TakeBreakWithin)
Values(30,6,5)
INSERT INTO @BreakRules (MinBreakMinutes ,	BreakRequiredAfter   ,	TakeBreakWithin)
Values(30,9,9)
INSERT INTO @BreakRules (MinBreakMinutes ,	BreakRequiredAfter   ,	TakeBreakWithin)
Values(30,12,11);


-- query which will return not satisfied rules breakRules
WITH TimeBreaksInfo AS (
    SELECT 
        TC.EmployeeId,
        TC.BusinessDate,
		TC.StartDate as CardStardDate,
        TC.endDate AS CardEndDate,
        NextCardStartDate = LEAD(TC.startDate) OVER (PARTITION BY TC.EmployeeId ORDER BY TC.BusinessDate ASC, TC.startDate ASC)
    FROM @TimeCards TC
) 
SELECT 
    tbi.EmployeeId,
    tbi.BusinessDate,
	NumberOfNotSatisfiedRules = (Select count(*) from @BreakRules BR where 
        (BR.BreakRequiredAfter < DATEDIFF(HOUR, tbi.CardStardDate, tbi.NextCardStartDate))
        OR (BR.MinBreakMinutes > DATEDIFF(MINUTE, tbi.CardEndDate, tbi.NextCardStartDate)))
	FROM TimeBreaksInfo tbi 
