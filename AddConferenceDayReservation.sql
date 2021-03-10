-- =============================================
-- Author:		Kamil Burkiewicz
-- Create date: 21.01.2020
-- Description:	----------
-- =============================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE AddConferenceDayReservation 
   @CustomerID       int,
   @ConferenceDayID  int,
   @ReservationDate  datetime,
   @ReservedSeats    int,
   @NumberOfStudents int,
   @isPaid           bit

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

		DECLARE @TakenSeats int;
		SET @TakenSeats = (SELECT SUM(ReservedSeats) FROM ConferenceDayReservations
							WHERE ConferenceDayID = @ConferenceDayID
							GROUP BY ConferenceDayID);


		IF 
			(
				(SELECT MaxParticipants FROM Conference AS conf
				 INNER JOIN ConferenceDay AS cd
					ON conf.ConferenceID = cd.ConferenceID
				 WHERE cd.ConferenceDayID = @ConferenceDayID) < @ReservedSeats + @TakenSeats
			)
		BEGIN
			;THROW	51000, 'Conference participants limit exceeded.', 1
		END

		INSERT INTO ConferenceDayReservations (CustomerID, ConferenceDayID, ReservationDate, ReservedSeats, NumberOfStudents, isPaid)
		VALUES (@CustomerID, @ConferenceDayID, @ReservationDate, @ReservedSeats, @NumberOfStudents, @isPaid)

	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		DECLARE @errorMsg nvarchar(2048)
				= 'Cannot add Conference Day Reservation. Error message: ' + ERROR_MESSAGE();
		;THROW 51000, @errorMsg, 1
	END CATCH
END
GO
