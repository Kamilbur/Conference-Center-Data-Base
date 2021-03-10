-- =============================================
-- Author:		Kamil Burkiewicz
-- Create date: 21.01.2020
-- Description:	----------
-- =============================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE UpdateCustomerInfo
	@CustomerID int,
	@Name nvarchar(60),
	@Address nvarchar(95),
	@City nvarchar(60),
	@Region nvarchar(60),
	@Email nvarchar(60),
	@Phone nvarchar(20)
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
			;THROW 51000, 'There is no customer with such ID.', 1
		END

		IF @Name IS NOT NULL
		BEGIN
			UPDATE Customers
			SET Name = @Name
			WHERE CustomerID = @CustomerID
		END

		IF @Address IS NOT NULL
		BEGIN
			UPDATE Customers
			SET Address = @Address
			WHERE CustomerID = @CustomerID
		END

		IF @City IS NOT NULL
		BEGIN
			UPDATE Customers
			SET City = @City
			WHERE CustomerID = @CustomerID
		END

		IF @Region IS NOT NULL
		BEGIN
			UPDATE Customers
			SET Region = @Region
			WHERE CustomerID = @CustomerID
		END

		IF @Email LIKE '%@%'
		BEGIN
			IF @Email IS NOT NULL
			BEGIN
				UPDATE Customers
				SET Email = @Email
				WHERE CustomerID = @CustomerID
			END
		END

		DECLARE @ShortestPhonePossibleLen int = 9;  -- '123 456 789'
		DECLARE @LongestPhonePossibleLen  int = 12; -- '+48 123 456 789'

		IF LTRIM(@Phone) <> '' AND LEN(@Phone) <= @LongestPhonePossibleLen AND LEN(@Phone) >= @ShortestPhonePossibleLen
		BEGIN
			IF @Phone IS NOT NULL
			BEGIN
				UPDATE Customers
				SET Phone = @Phone
				WHERE CustomerID = @CustomerID
			END
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
