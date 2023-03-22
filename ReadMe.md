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
