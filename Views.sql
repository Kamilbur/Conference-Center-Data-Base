/* -------------------------widoki--------------------------------------------------------------------------------------------- */
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