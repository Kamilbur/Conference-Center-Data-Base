-- =============================================
-- Author:		Kamil Burkiewicz
-- Create date: 21.01.2020
-- Description:	----------
-- =============================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE AddWorkshop
	@ConferenceDayID int,
	@Name            nvarchar(100),
	@StartDate       datetime,
	@EndDate         datetime,
	@Price           money,
	@MaxParticipants int,
	@Description     ntext
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
	BEGIN TRANSACTION
		IF NOT EXISTS
			(
				SELECT * FROM ConferenceDay
				WHERE ConferenceDayID = @ConferenceDayID
			)
		BEGIN
			;THROW 51000, 'There is no ConferenceDay with such ID.', 1
		END

		INSERT INTO Workshop (ConferenceDayID, Name, StartDate, EndDate, Price, MaxParticipants, Description)
		VALUES (@ConferenceDayID, @Name, @StartDate, @EndDate, @Price, @MaxParticipants, @Description)

	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		DECLARE @errorMsg nvarchar(2048)
				= 'Cannot add Workshop. Error message: ' + ERROR_MESSAGE();
		;THROW 51000, @errorMsg, 1
	END CATCH
END
GO
