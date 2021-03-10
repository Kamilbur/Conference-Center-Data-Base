-- =============================================
-- Author:		Kamil Burkiewicz
-- Create date: 21.01.2020
-- Description:	----------
-- =============================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE UpdateParticipantInfo
	@ParticipantID int,
	@StudentIDCard NVARCHAR(10),
	@FirstName NVARCHAR(60),
	@LastName NVARCHAR(60)
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

		IF @FirstName IS NOT NULL
		BEGIN
			UPDATE Participants
			SET FirstName = @FirstName
			WHERE ParticipantID = @ParticipantID
		END

		IF @StudentIDCard IS NOT NULL
		BEGIN
			UPDATE Participants
			SET StudentIDCard = @StudentIDCard
			WHERE ParticipantID = @ParticipantID
		END

		IF @LastName IS NOT NULL
		BEGIN
			UPDATE Participants
			SET LastName = @LastName
			WHERE ParticipantID = @ParticipantID
		END



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
