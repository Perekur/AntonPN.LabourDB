CREATE PROCEDURE FillTimeCards(
	@employeesCount int,
    @startDate date,
    @endDate date = null)
AS
BEGIN
    SET NOCOUNT ON;
	
	Declare @Timecards table (EmployeeId uniqueidentifier, BusinessDate date, StartDate datetime, EndDate dateTime)
	Declare @EmployeeIds table (Id uniqueidentifier);

	set @endDate = isnull (@endDate, getDate());

	-- populate the fake employees
	Insert into @EmployeeIds (Id)
	Select Top 100 NEWID() from sys.objects;

	-- generate duration of few session
	Declare @startTime dateTime;

	WHILE @startDate <= @endDate
	BEGIN
		set @startTime = DateAdd(HOUR, 8, cast(@startDate as dateTime));
		
		delete @Timecards;

		-- time slot generator: generate random time slot between 8AM and.. during 8 hour working day
		-- here assuming that store can work till the 22:00 for populate the endDate properly.
		WITH timeSlotGenerator as
		(
			select
				start_time = @startTime,
				is_break = 0
			union all
			select 
				start_time = DateAdd(MINUTE, Cast(duration_factor as int), @startTime),
				is_break = case when ROW_NUMBER() OVER(ORDER BY DateAdd(MINUTE, Cast(duration_factor as int), @startTime)) % 2 = 1 then 1 else 0 end
			from (
				select
					duration_factor = random_number / SUM(random_number)  OVER() * 8 * 60
				from (
					SELECT TOP (CAST (3 + RAND(CHECKSUM(NEWID()))*2 as int))
					RAND(CHECKSUM(NEWID())) AS random_number FROM sys.objects
				) gen_random_numbers
			) gen_durations
		)
		INSERT INTO @Timecards (employeeId, businessDate, StartDate, EndDate)
		SELECT 
			emp.Id,
			businessDate = @startDate,
			startDate = start_time,
			endDate = end_time 
		FROM @EmployeeIds emp
		CROSS APPLY (
			select 
				start_time, 
				end_time= LEAD(start_time) over(order by start_time),
				is_break
			from timeSlotGenerator 
		) AS timeSlots 
		WHERE timeSlots.is_break=0
	

		-- For the debugging
		Insert into  Timecards (employeeId, businessDate, StartDate, EndDate)
		select employeeId
			, businessDate
			, StartDate
			, EndDate = case when isnull(tc.EndDate, tc.StartDate) <= tc.StartDate
							 then DATEADD(HOUR, 22, CAST (tc.BusinessDate as datetime))
							 else tc.EndDate end
		from @Timecards tc
		
		-- Advance to the next day
		SET @startDate = DATEADD(DAY, 1, @startDate);
	END;
END;
