-- =============================================
-- Author:		Kamil Burkiewicz
-- Create date: 21.01.2020
-- Description:	----------
-- =============================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE CancelConferenceDayReservation
	@ReservationID int
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
	BEGIN TRANSACTION
		IF NOT EXISTS
			(
				SELECT * FROM ConferenceDayReservations
				WHERE ReservationID = @ReservationID
			)
		BEGIN
			;THROW 51000, 'There is no reservation with such ID.', 1
		END

		IF 
			(
				(SELECT isCancelled FROM ConferenceDayReservations
				 WHERE ReservationID = @ReservationID) = 1
			)
		BEGIN
			;THROW 51000, 'Reservation already cancelled.', 1
		END

		UPDATE ConferenceDayReservations
		SET isCancelled = 1
		WHERE ReservationID = @ReservationID

		DECLARE cursor_ConferenceParticipants CURSOR LOCAL FAST_FORWARD FOR 
			SELECT DISTINCT ConferenceParticipantsID FROM ConferenceParticipants
			WHERE ReservationID = @ReservationID;
		
		DECLARE @ConferenceParticipantID int;

		OPEN cursor_ConferenceParticipants 
		FETCH NEXT FROM cursor_ConferenceParticipants INTO @ConferenceParticipantID
		WHILE @@FETCH_STATUS = 0
		  BEGIN 
			EXEC CancelConferenceParticipation @ConferenceParticipantID;

			FETCH NEXT FROM cursor_ConferenceParticipants INTO @ConferenceParticipantID
		  END 
		CLOSE cursor_ConferenceParticipants 
		DEALLOCATE cursor_ConferenceParticipants



		DECLARE cursor_WorkshopsReservation CURSOR LOCAL FAST_FORWARD FOR 
			SELECT DISTINCT WorkshopReservationID FROM WorkshopReservations
			WHERE ReservationID = @ReservationID;
		
		DECLARE @WorkshopReservationID int;

		OPEN cursor_WorkshopsReservation 
		FETCH NEXT FROM cursor_WorkshopsReservation INTO @WorkshopReservationID
		WHILE @@FETCH_STATUS = 0
		  BEGIN 
			EXEC CancelWorkshopReservation @WorkshopReservationID;

			FETCH NEXT FROM cursor_ConferenceParticipants INTO @WorkshopReservationID
		  END 
		CLOSE cursor_WorkshopsReservation 
		DEALLOCATE cursor_WorkshopsReservation

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
