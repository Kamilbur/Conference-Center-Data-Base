USE [u_burkiewi]


-- TWORZENIE TABEL

CREATE TABLE Conference
(
   ConferenceID     int           NOT NULL PRIMARY KEY IDENTITY (1,1),
   Title            nvarchar(100) NOT NULL,
   StartDate        datetime      NOT NULL,
   EndDate          datetime      NOT NULL,
   StudentsDiscount decimal(3, 3) NOT NULL CHECK (StudentsDiscount <= 1 and StudentsDiscount >= 0),
   MaxParticipants  int           NOT NULL CHECK (MaxParticipants > 0 and MaxParticipants < 200),
   CONSTRAINT Conference_date CHECK (EndDate > StartDate), CHECK(DATEDIFF(day, EndDate, StartDate)<7)
);

-- Table: ConferenceDay
CREATE TABLE ConferenceDay
(
   ConferenceDayID int  NOT NULL PRIMARY KEY IDENTITY (1,1),
   ConferenceID    int  NOT NULL,
   ConferenceDate  date NOT NULL,
   BeginningTime   time NOT NULL,
   EndTime         time NOT NULL,
   CONSTRAINT ConferenceDay_time CHECK (EndTime >= BeginningTime), CHECK(DATEDIFF(hour, EndTime, BeginningTime)<20)
);

-- Table: ConferenceDayReservations
CREATE TABLE ConferenceDayReservations
(
   ReservationID    int      NOT NULL PRIMARY KEY IDENTITY (1,1),
   CustomerID       int      NOT NULL,
   ConferenceDayID  int      NOT NULL,
   ReservationDate  datetime NOT NULL,
   ReservedSeats    int      NOT NULL CHECK (ReservedSeats > 0),
   NumberOfStudents int      NOT NULL CHECK (NumberOfStudents >= 0),
   isPaid           bit      NOT NULL DEFAULT(0),
   isCancelled      bit      NOT NULL DEFAULT(0),

--     CONSTRAINT ConferenceDayReservations_pk PRIMARY KEY  (ReservationID)
);

-- Table: ConferenceParticipants
CREATE TABLE ConferenceParticipants
(
   ConferenceParticipantsID int NOT NULL PRIMARY KEY IDENTITY (1,1),
   ReservationID            int NOT NULL,
   ParticipantID            int NOT NULL,
isCancelled bit  NOT NULL DEFAULT(0),

--     CONSTRAINT ConferenceParticipants_pk PRIMARY KEY  (ConferenceParticipantsID)
);

-- Table: Customers
CREATE TABLE Customers
(
   CustomerID int          NOT NULL PRIMARY KEY IDENTITY (1,1),
   Name       nvarchar(60) NOT NULL,
   isCompany  bit          NOT NULL,
   Address    nvarchar(95) NOT NULL,
   City       nvarchar(60) NOT NULL,
   Region     nvarchar(60) NOT NULL,
   Email      nvarchar(60) NOT NULL,
   Phone      nvarchar(20) NOT NULL,
--     CONSTRAINT Customers_pk PRIMARY KEY  (CustomerID)
);

-- Table: Participants
CREATE TABLE Participants
(
   ParticipantID int          NOT NULL PRIMARY KEY IDENTITY (1,1),
   CustomerID    int          NOT NULL,
   StudentIDCard nvarchar(10) NULL,
   FirstName     nvarchar(60) NOT NULL,
   LastName      nvarchar(60) NOT NULL,
);

-- Table: PricePerDay
CREATE TABLE PricePerDay
(
   PriceID                  int      NOT NULL PRIMARY KEY IDENTITY (1,1),
   ConferenceID             int      NOT NULL,
   Price                    money    NOT NULL CHECK (Price > 0),
   ReservationIntervalStart datetime NOT NULL,
   ReservationIntervalEnd   datetime NOT NULL,
   CONSTRAINT PricePerDay_date CHECK (DATEDIFF(day, ReservationIntervalEnd, ReservationIntervalStart) = 14)
)

-- Table: Workshop
CREATE TABLE Workshop
(
   WorkshopID      int           NOT NULL PRIMARY KEY IDENTITY (1,1),
   ConferenceDayID int           NOT NULL,
   Name            nvarchar(100) NOT NULL,
   StartDate       datetime      NOT NULL,
   EndDate         datetime      NOT NULL,
   Price           money         NOT NULL,
   MaxParticipants int           NOT NULL CHECK (MaxParticipants > 0),
   Description     ntext         NOT NULL,
   CONSTRAINT Workshop_date CHECK (DATEDIFF(day, EndDate, StartDate) = 0), CHECK(DATEDIFF(hour, EndDate, StartDate)<15)
);

-- Table: WorkshopParticipants
CREATE TABLE WorkshopParticipants (
   WorkshopParticipantsID int  NOT NULL PRIMARY KEY ,
   WorkshopReservationID int  NOT NULL,
   ConferenceParticipantsID int  NOT NULL,
isCancelled bit  NOT NULL DEFAULT(0),

);


-- Table: WorkshopReservations
CREATE TABLE WorkshopReservations
(
   WorkshopReservationID int NOT NULL PRIMARY KEY IDENTITY (1,1),
   WorkshopID            int NOT NULL,
   ReservationID         int NOT NULL,
   ReservedSeats       int NOT NULL CHECK (ReservedSeats >= 0),
isCancelled bit  NOT NULL DEFAULT(0),

--     CONSTRAINT WorkshopReservations_pk PRIMARY KEY  (WorkshopReservationID)
);

-- foreign keys
-- Reference: ConferenceDayReservations_ConferenceDay (table: ConferenceDayReservations)
ALTER TABLE ConferenceDayReservations
   ADD CONSTRAINT ConferenceDayReservations_ConferenceDay
       FOREIGN KEY (ConferenceDayID)
           REFERENCES ConferenceDay (ConferenceDayID);

-- Reference: ConferenceDayReservations_Customers (table: ConferenceDayReservations)
ALTER TABLE ConferenceDayReservations
   ADD CONSTRAINT ConferenceDayReservations_Customers
       FOREIGN KEY (CustomerID)
           REFERENCES Customers (CustomerID);

-- Reference: ConferenceDay_Conference (table: ConferenceDay)
ALTER TABLE ConferenceDay
   ADD CONSTRAINT ConferenceDay_Conference
       FOREIGN KEY (ConferenceID)
           REFERENCES Conference (ConferenceID);

-- Reference: ConferenceParticipants_ConferenceDayReservations (table: ConferenceParticipants)
ALTER TABLE ConferenceParticipants
   ADD CONSTRAINT ConferenceParticipants_ConferenceDayReservations
       FOREIGN KEY (ReservationID)
           REFERENCES ConferenceDayReservations (ReservationID);

-- Reference: ConferenceParticipants_Participants (table: ConferenceParticipants)
ALTER TABLE ConferenceParticipants
   ADD CONSTRAINT ConferenceParticipants_Participants
       FOREIGN KEY (ParticipantID)
           REFERENCES Participants (ParticipantID);

-- Reference: Participants_Customers (table: Participants)
ALTER TABLE Participants
   ADD CONSTRAINT Participants_Customers
       FOREIGN KEY (CustomerID)
           REFERENCES Customers (CustomerID);

-- Reference: PricePerDay_Conference (table: PricePerDay)
ALTER TABLE PricePerDay
   ADD CONSTRAINT PricePerDay_Conference
       FOREIGN KEY (ConferenceID)
           REFERENCES Conference (ConferenceID);

-- Reference: WorkshopParticipants_ConferenceParticipants (table: WorkshopParticipants)
ALTER TABLE WorkshopParticipants
   ADD CONSTRAINT WorkshopParticipants_ConferenceParticipants
       FOREIGN KEY (ConferenceParticipantsID)
           REFERENCES ConferenceParticipants (ConferenceParticipantsID);

-- Reference: WorkshopParticipants_WorkshopReservations (table: WorkshopParticipants)
ALTER TABLE WorkshopParticipants
   ADD CONSTRAINT WorkshopParticipants_WorkshopReservations
       FOREIGN KEY (WorkshopReservationID)
           REFERENCES WorkshopReservations (WorkshopReservationID);

-- Reference: WorkshopReservations_ConferenceDayReservations (table: WorkshopReservations)
ALTER TABLE WorkshopReservations
   ADD CONSTRAINT WorkshopReservations_ConferenceDayReservations
       FOREIGN KEY (ReservationID)
           REFERENCES ConferenceDayReservations (ReservationID);

-- Reference: WorkshopReservations_Workshop (table: WorkshopReservations)
ALTER TABLE WorkshopReservations
   ADD CONSTRAINT WorkshopReservations_Workshop
       FOREIGN KEY (WorkshopID)
           REFERENCES Workshop (WorkshopID);

-- Reference: Workshop_ConferenceDay (table: Workshop)
ALTER TABLE Workshop
   ADD CONSTRAINT Workshop_ConferenceDay
       FOREIGN KEY (ConferenceDayID)
           REFERENCES ConferenceDay (ConferenceDayID);

ALTER TABLE Customers
   ADD CONSTRAINT EmailCheck
       CHECK (Email like '%_@__%.__%')

ALTER TABLE Participants
   ADD CONSTRAINT StudentCardCheck
       CHECK (StudentIDCard LIKE '[0-9][0-9][0-9][0-9][0-9][0-9]%')

-- INDEKSY

create  index Conference_ConferenceID on Conference(ConferenceID);
create  index ConferenceDay_ConferenceDayID on ConferenceDay(ConferenceDayID) on [primary]
create  index PricePerDay_PriceID on PricePerDay(PriceID);
create  index Customers_CustomerID on Customers(CustomerID);
create  index Workshop_WorkshopID on Workshop(WorkshopID);
create  index ConferenceDayReservations_ReservationID on ConferenceDayReservations(ReservationID);
create  index Participants_ParticipantID on Participants(ParticipantID);
create  index WorkshopReservations_WorkshopReservationID on WorkshopReservations(WorkshopReservationID);
create  index ConferenceParticipants_ConferenceParticipantsID on ConferenceParticipants(ConferenceParticipantsID);
create  index WorkshopParticipants_WorkshopParticipantsID on WorkshopParticipants(WorkshopParticipantsID);


-- PROCEDURY

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE AddConference 
	@Title nvarchar(100),
	@StartDate datetime,
	@EndDate datetime,
	@StudentsDiscount decimal(3,3),
	@MaxParticipants int
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
	BEGIN TRANSACTION

		INSERT INTO	Conference (Title,	StartDate, EndDate, StudentsDiscount, MaxParticipants)
		VALUES (@Title, @StartDate, @EndDate, @StudentsDiscount, @MaxParticipants)

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



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE AddConferenceDay 
   @ConferenceID    int,
   @ConferenceDate  date,
   @BeginningTime   time,
   @EndTime         time
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
	BEGIN TRANSACTION
		IF NOT EXISTS
			(
				SELECT * FROM Conference
				WHERE ConferenceID = @ConferenceID
			)
		BEGIN
			;THROW 51000, 'There is no conference with such ID.', 1
		END

		IF EXISTS 
			(
				SELECT * FROM ConferenceDay
				WHERE ConferenceDate = @ConferenceDate
			)
		BEGIN
			;THROW 51000, 'This day is already occupied.', 1
		END

		INSERT INTO ConferenceDay (ConferenceID, ConferenceDate, BeginningTime, EndTime)
		VALUES (@ConferenceID, @ConferenceDate, @BeginningTime, @EndTime)

	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		DECLARE @errorMsg nvarchar(2048)
				= 'Cannot add Conference Day. Error message: ' + ERROR_MESSAGE();
		;THROW 51000, @errorMsg, 1
	END CATCH
END
GO



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



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE AddPricePerDay 
	@ConferenceID             int,
	@Price                    money,
	@ReservationIntervalStart datetime,
	@ReservationIntervalEnd   datetime
AS
BEGIN
	SET NOCOUNT ON;

    BEGIN TRY
	BEGIN TRANSACTION

		IF NOT EXISTS
			(
				SELECT * FROM Conference
				WHERE ConferenceID = @ConferenceID
			)
		BEGIN
			;THROW 51000, 'There is no Conference with such ID.', 1
		END

		INSERT INTO PricePerDay (ConferenceID, Price, ReservationIntervalStart, ReservationIntervalEnd)
		VALUES (@ConferenceID, @Price, @ReservationIntervalStart, @ReservationIntervalEnd)

	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		DECLARE @errorMsg nvarchar(2048)
				= 'Cannot add Price Per Day. Error message: ' + ERROR_MESSAGE();
		;THROW 51000, @errorMsg, 1
	END CATCH

END
GO



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE AddWorkshop
	@ConferenceDayID int,
	@Name            nvarchar(100),
	@StartDate       datetime,
	@EndDate         datetime,
	@Price           money,
	@MaxParticipants int,
	@Description     ntext
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
	BEGIN TRANSACTION
		IF NOT EXISTS
			(
				SELECT * FROM ConferenceDay
				WHERE ConferenceDayID = @ConferenceDayID
			)
		BEGIN
			;THROW 51000, 'There is no ConferenceDay with such ID.', 1
		END

		INSERT INTO Workshop (ConferenceDayID, Name, StartDate, EndDate, Price, MaxParticipants, Description)
		VALUES (@ConferenceDayID, @Name, @StartDate, @EndDate, @Price, @MaxParticipants, @Description)

	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		DECLARE @errorMsg nvarchar(2048)
				= 'Cannot add Workshop. Error message: ' + ERROR_MESSAGE();
		;THROW 51000, @errorMsg, 1
	END CATCH
END
GO



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



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE AddWorkshopReservation
   @WorkshopID            int,
   @ReservationID         int,
   @ReservedSeats         int
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
	BEGIN TRANSACTION

		IF NOT EXISTS
			(
				SELECT * FROM Workshop
				WHERE WorkshopID = @WorkshopID
			)
		BEGIN
			;THROW 51000, 'There is no workshop with such ID', 1
		END

		IF NOT EXISTS
			(
				SELECT * FROM ConferenceDayReservations
				WHERE ReservationID = @ReservationID
			)
		BEGIN
			;THROW 51000, 'There is no reservation with such ID', 1
		END

		DECLARE @TakenSeats INT;
		SET @TakenSeats = (SELECT SUM(ReservedSeats) FROM WorkshopReservations
							WHERE WorkshopID = @WorkshopID
							GROUP BY WorkshopID);


		IF 
			(
				(SELECT MaxParticipants FROM Workshop
				 WHERE WorkshopID = @WorkshopID) < @ReservedSeats + @TakenSeats
			)
		BEGIN
			;THROW	51000, 'Workshop participants limit exceeded.', 1
		END

		IF 
			(
				(SELECT ConferenceDayID FROM ConferenceDayReservations
				 WHERE ReservationID = @ReservationID)
				 <>
				(SELECT ConferenceDayID FROM Workshop
				 WHERE WorkshopID = @WorkshopID)
			)
		BEGIN
			;THROW 51000, 'There was no reservation for this day of conference.', 1
		END

		INSERT INTO	WorkshopReservations (WorkshopID, ReservationID, ReservedSeats)
		VALUES (@WorkshopID, @ReservationID, @ReservedSeats)

	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		DECLARE @errorMsg nvarchar(2048)
				= 'Cannot add workshop reservation. Error message: ' + ERROR_MESSAGE();
		;THROW 51000, @errorMsg, 1
	END CATCH
END
GO



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE CancelConferenceParticipation
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
			;THROW 51000, 'There is no conference participant with such ID.', 1
		END

		IF 
			(
				(SELECT isCancelled FROM dbo.ConferenceParticipants
				 WHERE ConferenceParticipantsID = @ConferenceParticipantsID) = 1
			)
		BEGIN
			;THROW 51000, 'Conference participation already cancelled.', 1
		END

		UPDATE ConferenceParticipants
		SET isCancelled = 1
		WHERE ConferenceParticipantsID = @ConferenceParticipantsID

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



-- FUNKCJE
GO
create function getPrice(@ConferenceID integer,
                        @resDate date)
   returns money
as
begin
   declare @result money=(select price
                          from PricePerDay
                          where @ConferenceID = PricePerDay.ConferenceID
                            and @resDate >= ReservationIntervalStart
                            and @resDate <= ReservationIntervalEnd)
   return @result;
end
GO



GO
create function sumWorkshopCosts(
   @ReservationID integer
)
   returns money
as
begin
   declare @Workshops table
                      (
                          ID            int,
                          ReservedSeats int,
                          Price         money
                      )
   insert @Workshops
   select WorkshopReservationID, ReservedSeats, Workshop.Price
   from WorkshopReservations
            inner join Workshop on Workshop.WorkshopID = WorkshopReservations.WorkshopReservationID
               where isCancelled=0

   declare @rowsCount integer = (select count(ReservedSeats) from WorkshopReservations)
   declare @i integer =1
   declare @workshopCosts money=0

   while(@i < @rowsCount)
       begin
           declare @ID integer = (select ID from @Workshops where ID = @i)

           if (@ID = @ReservationID)
               begin
                   declare @seats integer = (select ID from @Workshops where ID = @i)
                   declare @price integer = (select ID from @Workshops where ID = @i)
                   set @workshopCosts = @workshopCosts + (@seats * @price)
               end
       end
   return @workshopCosts;
end
GO



GO
create function sumCosts(
   @ReservationID integer
)
   returns money
as
begin
   declare @reservationDate datetime = (select ReservationDate
                                        from ConferenceDayReservations
                                        where @ReservationID = ConferenceDayReservations.ReservationID)

   declare @pricePerDay money = [dbo].[getPrice]((select ConferenceID
                                          from ConferenceDay
                                                   inner join ConferenceDayReservations
                                                              on ConferenceDayReservations.ConferenceDayID =
                                                                 ConferenceDay.ConferenceDayID
                                          where @ReservationID = ConferenceDayReservations.ReservationID),
                                         @reservationDate)

   declare @studentsDiscount decimal(3, 3) = (select StudentsDiscount
                                              from Conference
                                                       inner join ConferenceDay on ConferenceDay.ConferenceID = Conference.ConferenceID
                                                       inner join ConferenceDayReservations
                                                                  on ConferenceDayReservations.ConferenceDayID =
                                                                     ConferenceDay.ConferenceDayID
                                              where @ReservationID = ConferenceDayReservations.ReservationID)

   declare @noOfStudents integer=(select NumberOfStudents
                                  from ConferenceDayReservations
                                  where @ReservationID = ConferenceDayReservations.ReservationID)
   declare @reservedSeats integer=(select ReservedSeats
                                   from ConferenceDayReservations
                                   where @ReservationID = ConferenceDayReservations.ReservationID)


   return ([dbo].[sumWorkshopCosts](@ReservationID) + @noOfStudents * (@pricePerDay - @pricePerDay * @studentsDiscount) +
           (@reservedSeats - @noOfStudents) * @pricePerDay)

end
GO



GO
create function availableConferenceSeats(
   @ConferenceDayID int
)
   returns int
as
begin
   declare @maxSeats integer = (select MaxParticipants
                                from Conference
                                         inner join ConferenceDay on ConferenceDay.ConferenceID = Conference.ConferenceID
                                where ConferenceDay.ConferenceDayID = @ConferenceDayID)

   declare @reservedSeats integer = (select sum(ReservedSeats)
                                     from ConferenceDayReservations
                                     where ConferenceDayID = @ConferenceDayID)

   return (@maxSeats - @reservedSeats)

end
GO


GO
create function availableWorkshopSeats(
   @WorkshopID int
)
   returns int
as
begin
   declare @maxSeats integer = (select MaxParticipants
                                from Workshop
                                where Workshop.WorkshopID = @WorkshopID)

   declare @reservedSeats integer = (select sum(ReservedSeats)
                                     from WorkshopReservations
                                     where WorkshopID = @WorkshopID)


   return (@maxSeats - @reservedSeats)

end
GO



GO
create function confDayWorkshopParticipants(@ConferenceID int,
                                           @Date datetime,
                                           @WorkshopID int)
   returns @table table
                  (
                      ParticipantID int,
                      FirstName     nvarchar(60),
                      LastName      nvarchar(60),
                      StudentIDCard nvarchar(10)
                  )
as
begin
   insert @table
   select p.ParticipantID,
          p.FirstName     as 'First Name',
          p.LastName      as 'Last Name',
          p.StudentIDCard as 'StudentIDCard Number'
   from Participants as p
            inner join WorkshopParticipants wp on p.ParticipantID = wp.ConferenceParticipantsID
            inner join WorkshopReservations wr on wp.WorkshopReservationID = wr.WorkshopReservationID
            inner join ConferenceDayReservations cdr on cdr.ReservationID = wr.ReservationID
            inner join ConferenceDay cd on CDR.ConferenceDayID = cd.ConferenceDayID
   where cd.ConferenceID = @ConferenceID
     and cd.ConferenceDate = @Date
     and @WorkshopID = wr.WorkshopID

   return
end
GO



GO
create function confDayParticipants(@ConferenceID int,
                                   @Date datetime)
   returns @table table
                  (
                      ParticipantID int,
                      FirstName     nvarchar(60),
                      LastName      nvarchar(60),
                      StudentIDCard nvarchar(10)
                  )
as
begin
   insert @table
   select p.ParticipantID,
          p.FirstName     as 'First Name',
          p.LastName      as 'Last Name',
          p.StudentIDCard as 'StudentIDCard Number'
   from Participants as p
            inner join ConferenceParticipants CP on p.ParticipantID = CP.ParticipantID
            inner join ConferenceDayReservations CDR on CP.ReservationID = CDR.ReservationID
            inner join ConferenceDay cd on CDR.ConferenceDayID = cd.ConferenceDayID
   where cd.ConferenceID = @ConferenceID
     and cd.ConferenceDate = @Date

   return
end
GO



-- WIDOKI
GO
create view v_ConferenceDayParticipants as
select p.FirstName       as 'First Name',
      p.LastName        as 'Last Name',
      c.Name            as 'Company Name',
      conf.Title        as 'Conference Title',
      cd.ConferenceDate as 'Conference Date'
from Participants as p
        inner join conferenceParticipants as cp on cp.ParticipantID = p.ParticipantID
        inner join ConferenceDayReservations as cdr on cdr.ReservationID = cp.ReservationID
        inner join Customers as c on c.CustomerID = cdr.CustomerID
        inner join ConferenceDay as cd on cd.ConferenceDayID = cdr.ConferenceDayID
        inner join Conference as conf on conf.ConferenceID = cd.ConferenceID
GO



GO
create view v_WorkshopParticipants as
select p.FirstName       as 'First Name',
      p.LastName        as 'Last Name',
      w.Name            as 'Workshop Name',
      c.Title           as 'Conference Title',
      cd.ConferenceDate as 'Conference Date'
from Participants as p
        inner join WorkshopParticipants as wp on wp.ConferenceParticipantsID = p.ParticipantID
        inner join WorkshopReservations as wr on wr.WorkshopReservationID = wp.WorkshopReservationID
        inner join Workshop w on w.WorkshopID = wr.WorkshopID
        inner join ConferenceDay cd on w.ConferenceDayID = cd.ConferenceDayID
        inner join Conference c on cd.ConferenceID = c.ConferenceID
GO



GO
create view v_Payments as
select c.CustomerID,
      c.Name                      as 'Customer Name',
      conf.Title                  as 'Conference Title',
      [dbo].[sumCosts](cdr.ReservationID) as 'Charge',
      cdr.isPaid                  as 'Paid?'
from Customers as c
        inner join ConferenceDayReservations cdr on c.CustomerID = cdr.CustomerID
        inner join ConferenceDay CD on cdr.ConferenceDayID = CD.ConferenceDayID
        inner join Conference conf on CD.ConferenceID = conf.ConferenceID
group by conf.Title, c.Name, cdr.ReservationID, cdr.isPaid, c.CustomerID
GO



GO
CREATE VIEW v_BestCustomers AS
SELECT
TOP 10
[Customer Name]
,
COUNT(cdr.ReservationID) AS 'Number of Conference Reservations'
,
SUM([Charge]) AS 'Sum of Payments'
FROM v_Payments
        INNER JOIN ConferenceDayReservations AS cdr ON cdr.CustomerID = v_Payments.CustomerID
GROUP BY [Customer Name]
GO



GO
create view v_ConferenceSummary as
select conf.Title                                  as 'Conference Title',
      sum(cdr.ReservedSeats)                         'Reserved Seats',
      [dbo].[availableConferenceSeats](conf.ConferenceID) as 'Available Conference Seats',
      sum(cdr.NumberOfStudents)                   as 'Number of Students',
      (sum(cdr.ReservedSeats) - sum(cdr.NumberOfStudents))   as 'Number of not Student People',
      count(cdr.ReservationID)                    as 'Number of Conference reservations',
      count(w.WorkShopID)                         as 'Number of Available Workshops',
      count(wr.WorkshopReservationID)             as 'Number of Reservations for Workshops',
      sum(wr.ReservedSeats)                       as 'Reserved Seats for Workshops',
      [dbo].[availableWorkshopSeats](WorkshopReservationID) as 'Available Workshop Seats'
from Conference as conf
        inner join ConferenceDay cd on conf.ConferenceID = cd.ConferenceID
        inner join ConferenceDayReservations cdr on cd.ConferenceDayID = cdr.ConferenceDayID
        inner join WorkshopReservations wr on cdr.ReservationID = wr.ReservationID
        inner join Workshop w on w.WorkshopID = wr.WorkshopReservationID
group by conf.Title, conf.ConferenceID, WorkshopReservationID
GO


GO
create view v_WorkshopSummary as
select conf.Title              as 'Conference Title',
      w.Name                  as 'Workshop Name',
      count(wr.ReservedSeats) as 'Seats Reserved for Workshop',
      [dbo].[availableWorkshopSeats](wr.WorkshopID) as 'Available Seats for Workshop'

from Workshop as w
        inner join WorkshopReservations wr on w.WorkshopID = wr.WorkshopID
        inner join ConferenceDay as cd on w.ConferenceDayID = cd.ConferenceDayID
        inner join Conference conf on CD.ConferenceID = conf.ConferenceID
group by w.Name, wr.WorkshopID, conf.Title
GO

-- TRIGGERY

/* sprawdza czy nie zarejestrowano wiêcej osób ni¿ zadeklarowano*/
GO
create trigger CheckReservedSeats_ConferenceDayReservations
   on ConferenceDayReservations
   after insert, update
   as
begin
   declare @reservationID int

   set @reservationID = (select ReservationID from inserted)

   declare @participantsAdded int = (select count(*)
                                     from ConferenceParticipants
                                     where ReservationID = @reservationID and isCancelled=0)
   declare @participantsDeclared int = (select ReservedSeats
                                        from ConferenceDayReservations
                                        where ReservationID = @reservationID)

   if (@participantsAdded > @participantsDeclared)
       begin
           RAISERROR ('Number of participants added is greater than declared number of participants', -1, -1);
           ROLLBACK TRANSACTION
       end
end
GO



/* sprawdza czy nie zosta³a przekroczona iloœæ mniejsc na nady warsztat*/
GO
create trigger CheckReservedSeats_WorkshopReservations
   on WorkshopReservations
   after insert, update
   as
begin
   declare @wReservationID int

   set @wReservationID = (select WorkshopReservationID from inserted)

   declare @participantsAdded int = (select count(*)
                                     from WorkshopParticipants
                                     where WorkshopReservationID = @wReservationID and isCancelled=0)

   declare @participantsDeclared int = (select ReservedSeats
                                        from WorkshopReservations
                                        where WorkshopReservationID = @wReservationID)

   if (@participantsAdded > @participantsDeclared)
       begin
           raiserror ('Number of participants added to workshop is greater than declared number of participants', -1, -1);
           rollback transaction
       end
end
GO



/* aktualizuje studentow*/
GO
create trigger UpdateNumberOfStudents
   on ConferenceDayReservations
   after insert, update
   as
begin
   declare @reservationID int = (select ReservationID from inserted)

   declare @noOfStudents int = (select count(*) from ConferenceParticipants
                                   inner join Participants P on ConferenceParticipants.ParticipantID = P.ParticipantID
                                   where p.StudentIDCard is not null and isCancelled=0 and  @reservationID=ReservationID)

   if (@noOfStudents is not null)
   begin
       update ConferenceDayReservations
       set NumberOfStudents=@noOfStudents
       from inserted where inserted.ReservationID=ConferenceDayReservations.ReservationID
   end
end
GO



/* sprawdza czy osoba jest zapisana tylko na jeden warsztat w danym czasie i czy jest zapisana na dan¹ konferencje*/
GO
create trigger CheckWorkshopParticipants
    on WorkshopParticipants
    after insert, update
    as begin
        declare @personID int = (select ConferenceParticipantsID from inserted)



        declare @noOfWorkshops int = (select count(*) from WorkshopParticipants
                                        inner join  WorkshopReservations WR on WorkshopParticipants.WorkshopReservationID = WR.WorkshopReservationID
                                        inner join Workshop W on WR.WorkshopID = W.WorkshopID
                                        inner join  Workshop w2 on w2.ConferenceDayID=w.ConferenceDayID
                                        where @personID=ConferenceParticipantsID and
                                              wr.isCancelled=0 and WorkshopParticipants.isCancelled=0 and
                                              ((w.StartDate<w2.StartDate and w2.StartDate<w.EndDate) or
                                               (w2.StartDate<w.StartDate and w.StartDate<w2.EndDate)))
        if @noOfWorkshops>0
        begin
            raiserror ('this person is already enrolled in the workshop in this time ', 16, 1);
            rollback transaction
        end
end
GO



GO
create trigger NewPastConference on Conference
   after insert
   as begin

       declare @startDate datetime = (select StartDate from inserted)

       if (@startDate<GETDATE())
       begin
           raiserror ('Conference cannot happen in teh past ', 16, 1);
           rollback transaction
       end
end
GO