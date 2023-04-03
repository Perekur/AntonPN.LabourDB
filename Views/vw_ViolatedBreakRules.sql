	CREATE VIEW [dbo].[vw_ViolatedBreakRules]
	AS 
	-- query which will return not satisfied rules breakRules
	WITH TimeBreaksInfo AS (
		SELECT 
			TC.EmployeeId,
			TC.BusinessDate,
			TC.StartDate as WorkingSessionStart,
			TC.endDate AS WorkingSessionEnd,
			BreakDurationInMinutes = DateDiff(MINUTE, TC.EndDate, LEAD(TC.startDate) OVER (PARTITION BY TC.EmployeeId, TC.BusinessDate ORDER BY TC.startDate ASC)),
			PrevSessionsDurationInHours = SUM(DateDiff(MINUTE, TC.StartDate, TC.endDate)/60.0) OVER (PARTITION BY TC.EmployeeId, TC.BusinessDate ORDER BY  TC.StartDate ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING),
			LastWorkingSessionDurationInHours = DateDiff(MINUTE, TC.StartDate, TC.endDate)/60.0
		FROM TimeCards TC
	) 
	SELECT 
		EmployeeID,
		BusinessDate,
		NumberOfNotSatisfiedRules = sum(violatedBreakRules.NumberOfNotSatisfiedRules)
		FROM TimeBreaksInfo tbi CROSS APPLY
		( 
			select 
				NumberOfNotSatisfiedRules = count(*)
			from BreakRules br 
			where 
				br.BreakRequiredAfter between tbi.PrevSessionsDurationInHours and (isnull(tbi.PrevSessionsDurationInHours,0) + LastWorkingSessionDurationInHours)
				and 
				(
				   br.BreakRequiredAfter + TakeBreakWithin < (isnull(tbi.PrevSessionsDurationInHours,0) + LastWorkingSessionDurationInHours)
					or
					IsNull(BreakDurationInMinutes, MinBreakMinutes) < MinBreakMinutes
				)
		) violatedBreakRules
	group by EmployeeID, BusinessDate