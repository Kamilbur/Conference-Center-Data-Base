-- =============================================
-- Author:		Kamil Burkiewicz
-- Create date: 21.01.2020
-- Description:	----------
-- =============================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE AddCustomer
	@Name       nvarchar(60),
	@isCompany  bit,
	@Address    nvarchar(95),
	@City       nvarchar(60),
	@Region     nvarchar(60),
	@Email      nvarchar(60),
	@Phone      nvarchar(20)
AS
BEGIN

	SET NOCOUNT ON;

	BEGIN TRY
	BEGIN TRANSACTION

		IF EXISTS
			(
				SELECT * FROM Customers
				WHERE Email = @Email
			)
		BEGIN
			;THROW 51000, 'Email already used.', 1
		END

		INSERT INTO Customers (Name, isCompany, Address, City, Region, Email, Phone)
		VALUES (@Name, @isCompany, @Address, @City, @Region, @Email, @Phone)

	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		DECLARE @errorMsg nvarchar(2048)
				= 'Cannot add Customer. Error message: ' + ERROR_MESSAGE();
		;THROW 51000, @errorMsg, 1
	END CATCH
END
GO
