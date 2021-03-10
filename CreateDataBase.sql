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
   CONSTRAINT ConferenceDay_time CHECK (EndTime > BeginningTime), CHECK(DATEDIFF(hour, EndTime, BeginningTime)<20)
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