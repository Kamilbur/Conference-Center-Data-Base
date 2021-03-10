-- =============================================
-- Author:		Kamil Burkiewicz
-- Create date: 21.01.2020
-- Description:	----------
-- =============================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE AddWorkshopReservation
   @WorkshopID            int,
   @ReservationID         int,
   @ReservedSeats         int
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
	BEGIN TRANSACTION

		IF NOT EXISTS
			(
				SELECT * FROM Workshop
				WHERE WorkshopID = @WorkshopID
			)
		BEGIN
			;THROW 51000, 'There is no workshop with such ID', 1
		END

		IF NOT EXISTS
			(
				SELECT * FROM ConferenceDayReservations
				WHERE ReservationID = @ReservationID
			)
		BEGIN
			;THROW 51000, 'There is no reservation with such ID', 1
		END

		DECLARE @TakenSeats INT;
		SET @TakenSeats = (SELECT SUM(ReservedSeats) FROM WorkshopReservations
							WHERE WorkshopID = @WorkshopID
							GROUP BY WorkshopID);


		IF 
			(
				(SELECT MaxParticipants FROM Workshop
				 WHERE WorkshopID = @WorkshopID) < @ReservedSeats + @TakenSeats
			)
		BEGIN
			;THROW	51000, 'Workshop participants limit exceeded.', 1
		END

		IF 
			(
				(SELECT ConferenceDayID FROM ConferenceDayReservations
				 WHERE ReservationID = @ReservationID)
				 <>
				(SELECT ConferenceDayID FROM Workshop
				 WHERE WorkshopID = @WorkshopID)
			)
		BEGIN
			;THROW 51000, 'There was no reservation for this day of conference.', 1
		END

		INSERT INTO	WorkshopReservations (WorkshopID, ReservationID, ReservedSeats)
		VALUES (@WorkshopID, @ReservationID, @ReservedSeats)

	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		DECLARE @errorMsg nvarchar(2048)
				= 'Cannot add workshop reservation. Error message: ' + ERROR_MESSAGE();
		;THROW 51000, @errorMsg, 1
	END CATCH
END
GO
