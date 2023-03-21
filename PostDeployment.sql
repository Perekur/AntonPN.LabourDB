/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/

-- Fill BreakRules
if (NOT EXISTS(select top 1 1 from BreakRules))
BEGIN
    INSERT INTO BreakRules (MinBreakMinutes ,	BreakRequiredAfter   ,	TakeBreakWithin)
    Values(30,6,5);

    INSERT INTO BreakRules (MinBreakMinutes ,	BreakRequiredAfter   ,	TakeBreakWithin)
    Values(30,9,9);

    INSERT INTO BreakRules (MinBreakMinutes ,	BreakRequiredAfter   ,	TakeBreakWithin)
    Values(30,12,11);
END



-- Fill timecards
DECLARE @EmployeeID uniqueidentifier 
DECLARE @BusinessDate smalldatetime


-- Fill TimeCards
if ((NOT EXISTS(select top 1 1 from dbo.TimeCards)))
BEGIN
    -- fill data of FillTimeCards
    exec dbo.[FillTimeCards] @employeesCount=1000, @startDate='2022-01-01 00:00:00.000'

    delete dbo.TimeCards 
    where BusinessDate between '2/27/2023' and '2/28/2023'

     -- the script from the task
    SET @EmployeeID =newid()
    set @BusinessDate ='2/28/2023'

    INSERT INTO  dbo.TimeCards  (EmployeeID, BusinessDate,	StartDate,	EndDate)
    Values(@EmployeeID, @BusinessDate,'2/28/2023 5:55','2/28/2023 9:24')
    INSERT INTO  dbo.TimeCards  (EmployeeID, BusinessDate,	StartDate,	EndDate)
    Values(@EmployeeID, @BusinessDate,'2/28/2023 9:55','2/28/2023 16:18')

    set @BusinessDate= '2/27/2023'
    INSERT INTO  dbo.TimeCards  (EmployeeID, BusinessDate,	StartDate,	EndDate)
    Values(@EmployeeID, @BusinessDate,'2/27/2023 6:00','2/27/2023 17:20')


    SET @EmployeeID =newid()
    set @BusinessDate ='2/28/2023'

    INSERT INTO  dbo.TimeCards  (EmployeeID, BusinessDate,	StartDate,	EndDate)
    Values(@EmployeeID, @BusinessDate,'2/28/2023 5:20','2/28/2023 8:30')
    INSERT INTO  dbo.TimeCards  (EmployeeID, BusinessDate,	StartDate,	EndDate)
    Values(@EmployeeID, @BusinessDate,'2/28/2023 8:45','2/28/2023 13:03')
    INSERT INTO  dbo.TimeCards  (EmployeeID, BusinessDate,	StartDate,	EndDate)
    Values(@EmployeeID, @BusinessDate,'2/28/2023 13:33','2/28/2023 17:00')
    INSERT INTO  dbo.TimeCards  (EmployeeID, BusinessDate,	StartDate,	EndDate)
    Values(@EmployeeID, @BusinessDate,'2/28/2023 17:25','2/28/2023 19:00')
END




