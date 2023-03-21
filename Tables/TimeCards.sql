CREATE TABLE [dbo].TimeCards
(
		ID int Identity(1,1),	
		BusinessDate smalldatetime ,
		StartDate datetime ,
		EndDate datetime,
		EmployeeID uniqueidentifier  
)
