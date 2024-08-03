type BookingsResponse record {
    Booking[] data;
};

type Slot record {|
    string date;
    int hour;
    int partition;
    string barber;
|};

type Barber record {|
    int id;
    string name;
|};

type NewBookingRequest record {|
    string date;
    string userId;
    int hour;
    int partition;
    string barber;
|};

type SlotsResponse record {|
    Slot[] data;
|};

type Booking record {|
    int bookingRef;
    string date;
    int hour;
    int partition;
    string barber;
|};

type CountResponse record {|
    int count;
|};

type BookingResponse record {
    int bookingRef;
    string date;
    string userId;
    int hour;
    int partition;
    string barber;
};

type BarberNotFountError distinct error;

type SlotNotAvailableError distinct error;
