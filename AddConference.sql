-- =============================================
-- Author:		Kamil Burkiewicz
-- Create date: 21.01.2020
-- Description:	----------
-- =============================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE AddConference 
	@Title nvarchar(100),
	@StartDate datetime,
	@EndDate datetime,
	@StudentsDiscount decimal(3,3),
	@MaxParticipants int
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
	BEGIN TRANSACTION

		INSERT INTO	Conference (Title,	StartDate, EndDate, StudentsDiscount, MaxParticipants)
		VALUES (@Title, @StartDate, @EndDate, @StudentsDiscount, @MaxParticipants)

	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		DECLARE @errorMsg nvarchar(2048)
				= 'Cannot add Conference. Error message: ' + ERROR_MESSAGE();
		;THROW 52000, @errorMsg, 1
	END CATCH
END
GO
