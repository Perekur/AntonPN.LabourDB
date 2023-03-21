CREATE VIEW [dbo].[vw_ViolatedBreakRules]
AS 
WITH timeBreaksInfo AS (
    SELECT 
        TC.EmployeeId,
        TC.BusinessDate,
		TC.StartDate as StartDate,
        TC.endDate AS EndDate,
        NextCardStartDate = LEAD(TC.startDate) OVER (PARTITION BY TC.EmployeeId ORDER BY TC.BusinessDate ASC, TC.startDate ASC)
    FROM dbo.TimeCards TC
) 
SELECT 
	tbi.*,
    work_duration_minutes = DATEDIFF(Minute, StartDate, EndDate),
    break_duration_minutes = DATEDIFF (Minute, EndDate, NextCardStartDate),
	NumberOfNotSatisfiedRules = breakRuleChecker.numberRules
	FROM timeBreaksInfo tbi CROSS APPLY
        (select count(*) as numberRules from BreakRules BR where 
        (BR.BreakRequiredAfter < DATEDIFF(HOUR, tbi.StartDate, tbi.EndDate))
		OR (BR.MinBreakMinutes > DATEDIFF(MINUTE, tbi.EndDate, tbi.NextCardStartDate))) breakRuleChecker