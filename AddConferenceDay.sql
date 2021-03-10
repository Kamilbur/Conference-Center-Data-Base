-- =============================================
-- Author:		Kamil Burkiewicz
-- Create date: 21.01.2020
-- Description:	----------
-- =============================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE AddConferenceDay 
   @ConferenceID    int,
   @ConferenceDate  date,
   @BeginningTime   time,
   @EndTime         time
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
	BEGIN TRANSACTION
		IF NOT EXISTS
			(
				SELECT * FROM Conference
				WHERE ConferenceID = @ConferenceID
			)
		BEGIN
			;THROW 51000, 'There is no conference with such ID.', 1
		END

		IF EXISTS 
			(
				SELECT * FROM ConferenceDay
				WHERE ConferenceDate = @ConferenceDate
			)
		BEGIN
			;THROW 51000, 'This day is already occupied.', 1
		END

		INSERT INTO ConferenceDay (ConferenceID, ConferenceDate, BeginningTime, EndTime)
		VALUES (@ConferenceID, @ConferenceDate, @BeginningTime, @EndTime)

	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		DECLARE @errorMsg nvarchar(2048)
				= 'Cannot add Conference Day. Error message: ' + ERROR_MESSAGE();
		;THROW 51000, @errorMsg, 1
	END CATCH
END
GO
