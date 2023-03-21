CREATE TABLE dbo.BreakRules (	
	ID int Identity(1,1),	
	MinBreakMinutes int  ,
	BreakRequiredAfter  decimal(10,2) ,
	TakeBreakWithin  decimal(10,2) 
)