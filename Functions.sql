USE [u_burkiewi]

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
