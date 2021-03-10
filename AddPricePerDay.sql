-- =============================================
-- Author:		Kamil Burkiewicz
-- Create date: 21.01.2020
-- Description:	----------
-- =============================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE AddPricePerDay 
	@ConferenceID             int,
	@Price                    money,
	@ReservationIntervalStart datetime,
	@ReservationIntervalEnd   datetime
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
			;THROW 51000, 'There is no Conference with such ID.', 1
		END

		INSERT INTO PricePerDay (ConferenceID, Price, ReservationIntervalStart, ReservationIntervalEnd)
		VALUES (@ConferenceID, @Price, @ReservationIntervalStart, @ReservationIntervalEnd)

	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		DECLARE @errorMsg nvarchar(2048)
				= 'Cannot add Price Per Day. Error message: ' + ERROR_MESSAGE();
		;THROW 51000, @errorMsg, 1
	END CATCH

END
GO
