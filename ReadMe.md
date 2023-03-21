Use VS 2019..
Build and deploy LabourDB to the awailable mssql server.
It will allow to generate much more bigger table TimeCards.

Perform the next query for retrieve the NumberOfNotSatisfiedRules per EmployeeId and BusinessDay
select * from [dbo].[vw_ViolatedBreakRules]

In case if you are not ready to peform the previous steps.. you can run the source script
and use next simple query.. which also should return the NumberOfNotSatisfiedRules

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
