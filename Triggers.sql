/* ------------------------------------------------triggery-------------------*/

/* sprawdza czy nie zarejestrowano więcej osób niż zadeklarowano*/
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

/* sprawdza czy nie została przekroczona ilość miejsc na dany warsztat */
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

/* aktualizuje studentów */
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

/* sprawdza czy osoba jest zapisana tylko na jeden warsztat w danym czasie i czy jest zapisana na daną konferencję */
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
