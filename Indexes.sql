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