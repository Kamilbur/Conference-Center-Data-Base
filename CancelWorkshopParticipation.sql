-- =============================================
-- Author:		Kamil Burkiewicz
-- Create date: 21.01.2020
-- Description:	----------
-- =============================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE CancelWorkshopParticipation
	@WorkshopParticipantID int
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
	BEGIN TRANSACTION
		IF NOT EXISTS
			(
				SELECT * FROM WorkshopParticipants
				WHERE WorkshopParticipantsID = @WorkshopParticipantID
			)
		BEGIN
			;THROW 51000, 'There is no workshop participant with such ID.', 1
		END

		IF 
			(
				(SELECT isCancelled FROM WorkshopParticipants
				 WHERE WorkshopParticipantsID = @WorkshopParticipantID) = 1
			)
		BEGIN
			;THROW 51000, 'Workshop participation already cancelled.', 1
		END

		UPDATE WorkshopParticipants
		SET isCancelled = 1
		WHERE WorkshopParticipantsID = @WorkshopParticipantID

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
