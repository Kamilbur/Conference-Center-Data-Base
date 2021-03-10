-- =============================================
-- Author:		Kamil Burkiewicz
-- Create date: 21.01.2020
-- Description:	----------
-- =============================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE AddParticipant 
	@CustomerID    int,
	@StudentIDCard nvarchar(10),
	@FirstName     nvarchar(60),
	@LastName      nvarchar(60)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
	BEGIN TRANSACTION

		IF NOT EXISTS
			(
				SELECT * FROM Customers
				WHERE CustomerID = @CustomerID
			)
		BEGIN
			;THROW 51000, 'There is no customer with such ID', 1
		END

		INSERT INTO Participants (CustomerID, StudentIDCard, FirstName, LastName)
		VALUES (@CustomerID, @StudentIDCard, @FirstName, @LastName)

	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		DECLARE @errorMsg nvarchar(2048)
				= 'Cannot add Participant. Error message: ' + ERROR_MESSAGE();
		;THROW 51000, @errorMsg, 1
	END CATCH
END
GO
