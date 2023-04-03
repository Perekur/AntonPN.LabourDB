LabourDB - create test DB before perform next steps
```sql
CREATE DATABASE LabourDB;
```
The LabourDB.sqlproj can be opened via VS 2019 and should be published into mentioned database.</br>
It contains two tables accordingly to initial description and also there is stored procedure which allow to generate random data and test query for the larger set than was provided in the task.
```sql
Timecards TABLE(	
		ID int Identity(1,1),	
		BusinessDate smalldatetime ,
		StartDate datetime ,
		EndDate datetime,
		EmployeeID uniqueidentifier  	
)
BreakRules TABLE(	
	ID int Identity(1,1),	
	MinBreakMinutes int  ,
	BreakRequiredAfter  decimal(10,2) ,
	TakeBreakWithin  decimal(10,2) 
)
```

The vw_ViolatedBreakRules can be used for review the **NumberOfNotSatisfiedRules**
```sql
    select * from [dbo].[vw_ViolatedBreakRules]
```

In case if you don't wan't to deploy DB.. you can use initial script for generate fake data for couple of employees</br>
The script was saved in **InitScriptWithSolution.sql** so it can be opened in the ManagementStudio</br>
The query which return the  **NumberOfNotSatisfiedRules** per EmployeeId and BusinessDate you can find in the end of the mentioned file.

```sql
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
    FROM @TimeCards TC
) 
SELECT 
	EmployeeID,
	BusinessDate,
	NumberOfNotSatisfiedRules = sum(violatedBreakRules.NumberOfNotSatisfiedRules)
	FROM TimeBreaksInfo tbi CROSS APPLY
	( 
		select 
			NumberOfNotSatisfiedRules = count(*)
		from @BreakRules br 
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
having sum(violatedBreakRules.NumberOfNotSatisfiedRules) > 0
order by EmployeeID, BusinessDate
```
