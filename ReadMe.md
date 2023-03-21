LabourDB DEPLOYMENT.

This is the DB project which can be deployed via VS 2019.
It contains the two tables which automatically will be populated with data after deployment.
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

In case if you are not will be ready to download and deploy ... you can use InitScriptWithSolution.sql and perform it in ManagementStudio</br>
There is a code for the query which should return the **NumberOfNotSatisfiedRules** based on the initial script.

```sql
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
	FROM TimeBreaksInfo tbi `
```
