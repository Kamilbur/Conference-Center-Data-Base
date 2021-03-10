-- =============================================
-- Author:		Kamil Burkiewicz
-- Create date: 21.01.2020
-- Description:	----------
-- =============================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE AddConferenceParticipant
   @ReservationID            int,
   @ParticipantID            int
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
	BEGIN TRANSACTION

		IF NOT EXISTS
			(
				SELECT * FROM Participants
				WHERE ParticipantID = @ParticipantID
			)
		BEGIN
			;THROW 51000, 'There is no participant with such ID.', 1
		END

		IF NOT EXISTS
			(
				SELECT * FROM ConferenceDayReservations
				WHERE ReservationID = @ReservationID
			)
		BEGIN
			;THROW 51000, 'There is no reservation with such ID.', 1
		END

		INSERT INTO ConferenceParticipants (ReservationID, ParticipantID)
		VALUES (@ReservationID, @ParticipantID)

	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		DECLARE @errorMsg nvarchar(2048)
				= 'Cannot add Conference Participant. Error message: ' + ERROR_MESSAGE();
		;THROW 51000, @errorMsg, 1
	END CATCH
END
GO
