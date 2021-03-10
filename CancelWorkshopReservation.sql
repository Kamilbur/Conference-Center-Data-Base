-- =============================================
-- Author:		Kamil Burkiewicz
-- Create date: 21.01.2020
-- Description:	----------
-- =============================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE CancelWorkshopReservation
	@WorkshopReservationID int
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
	BEGIN TRANSACTION
		IF NOT EXISTS
			(
				SELECT * FROM WorkshopReservations
				WHERE WorkshopReservationID = @WorkshopReservationID
			)
		BEGIN
			;THROW 51000, 'There is no workshop reservation with such ID.', 1
		END

		IF 
			(
				(SELECT isCancelled FROM WorkshopReservations
				 WHERE WorkshopReservationID = @WorkshopReservationID) = 1
			)
		BEGIN
			;THROW 51000, 'Workshop reservation already cancelled.', 1
		END

		UPDATE WorkshopReservations
		SET isCancelled = 1
		WHERE WorkshopReservationID = @WorkshopReservationID

		DECLARE cursor_WorkshopParticipants CURSOR LOCAL FAST_FORWARD FOR 
			SELECT DISTINCT WorkshopParticipantsID FROM WorkshopParticipants
			WHERE WorkshopReservationID = @WorkshopReservationID;
		
		DECLARE @WorkshopParticipantID int;

		OPEN cursor_WorkshopParticipants 
		FETCH NEXT FROM cursor_WorkshopParticipants INTO @WorkshopParticipantID
		WHILE @@FETCH_STATUS = 0
		  BEGIN 
			EXEC CancelWorkshopParticipation @WorkshopParticipantID;

			FETCH NEXT FROM cursor_WorkshopParticipants INTO @WorkshopParticipantID
		  END 
		CLOSE cursor_WorkshopParticipants 
		DEALLOCATE cursor_WorkshopParticipants

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
