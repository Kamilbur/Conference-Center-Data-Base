-- =============================================
-- Author:		Kamil Burkiewicz
-- Create date: 21.01.2020
-- Description:	----------
-- =============================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE AddWorkshopParticipant
   @WorkshopReservationID    int,
   @ConferenceParticipantsID int
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
	BEGIN TRANSACTION

		IF NOT EXISTS
			(
				SELECT * FROM ConferenceParticipants
				WHERE ConferenceParticipantsID = @ConferenceParticipantsID
			)
		BEGIN
			;THROW 51000, 'There is no ConferenceParticipants with such ID.', 1
		END

		IF NOT EXISTS
			(
				SELECT * FROM WorkshopReservations
				WHERE WorkshopReservationID = @WorkshopReservationID
			)
		BEGIN
			;THROW 51000, 'There is no WorkshopReservation with such ID.', 1
		END

		IF 
			(
				(SELECT ConferenceDayID FROM ConferenceDayReservations AS cdr
				 INNER JOIN ConferenceParticipants AS cp
					ON cp.ReservationID = cdr.ReservationID
				 WHERE cp.ConferenceParticipantsID = @ConferenceParticipantsID)
				 <>
				(SELECT ConferenceDayID FROM Workshop AS w
				 INNER JOIN WorkshopReservations AS wr
					ON w.WorkshopID = wr.WorkshopID
				 WHERE wr.WorkshopReservationID = @WorkshopReservationID)
			)
		BEGIN
			;THROW 51000, 'Participant having this ID does not have reservation on this day of conference,
							so he cannot participate in this workshop.', 1
		END
		
		INSERT INTO	WorkshopParticipants(WorkshopReservationID, ConferenceParticipantsID)
		VALUES (@WorkshopReservationID, @ConferenceParticipantsID)

	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		DECLARE @errorMsg nvarchar(2048)
				= 'Cannot add Workshop Participant. Error message: ' + ERROR_MESSAGE();
		;THROW 51000, @errorMsg, 1
	END CATCH
END
GO
