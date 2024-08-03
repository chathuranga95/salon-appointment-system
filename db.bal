import ballerina/sql;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

configurable string host = ?;
configurable string username = ?;
configurable string password = ?;
configurable string database = ?;
configurable int port = 3306;

final mysql:Client dbClient = check new (host, username, password, database, port);

isolated function getBookedSlots(string date) returns Slot[]|error {
    sql:ParameterizedQuery bookedSlotsQuery = `SELECT
    s.date AS date, s.hour AS hour, s.partition AS partition, b.name AS barber
     FROM appointments a, slots s, barbers b
        WHERE a.slot_id = s.id AND a.barber_id = b.id AND s.date = ${date}`;
    stream<Slot, error?> slotStream = dbClient->query(bookedSlotsQuery);
    return check from Slot slot in slotStream
        select slot;
}

isolated function getUserBookings(string userId) returns Booking[]|error {
    sql:ParameterizedQuery bookingsQuery = `SELECT
    a.id AS bookingRef, s.date AS date, s.hour AS hour, s.partition AS partition, b.name AS barber
     FROM appointments a, slots s, barbers b
        WHERE a.slot_id = s.id AND a.barber_id = b.id AND a.user_id = ${userId}`;
    stream<Booking, error?> bookingStream = dbClient->query(bookingsQuery);
    return check from Booking slot in bookingStream
        select slot;
}

isolated function getBarbers() returns string[]|error {
    sql:ParameterizedQuery getBarbersQuery = `SELECT id, name FROM barbers`;
    stream<Barber, error?> barberStream = dbClient->query(getBarbersQuery);
    return check from Barber barber in barberStream
        select barber.name;
}

isolated function getBarberId(string barber) returns int|BarberNotFountError|error {
    sql:ParameterizedQuery barberFindQuery = `SELECT id, name FROM barbers WHERE name = ${barber}`;
    Barber|error filteredBarber = dbClient->queryRow(barberFindQuery);
    if (filteredBarber is sql:NoRowsError) {
        return <BarberNotFountError>error("Barber not found");
    }
    if (filteredBarber is error) {
        return filteredBarber;
    }
    return filteredBarber.id;
}

isolated function getAvailableSlots(string date) returns Slot[]|error {
    Slot[] bookedSlots = check getBookedSlots(date);
    int[] workingHours = getWorkingHours();
    int[] partitions = getPartitions();
    string[] barbers = check getBarbers();

    Slot[] availableSlots = [];
    foreach int workingHour in workingHours {
        foreach int partition in partitions {
            foreach string barber in barbers {
                Slot currentSlot = {date, hour: workingHour, partition, barber};
                if bookedSlots.indexOf(currentSlot) == () {
                    availableSlots.push(currentSlot);
                }
            }
        }
    }

    return availableSlots;
}

isolated function checkSlotAvailability(string date, int hour, int partition, string barber) returns boolean|error {
    if (getWorkingHours().indexOf(hour) == () || getPartitions().indexOf(partition) == ()) {
        return false;
    }
    sql:ParameterizedQuery query = `SELECT COUNT(*) as count
     FROM appointments a, slots s, barbers b
    WHERE a.slot_id = s.id AND a.barber_id = b.id
    AND s.date = ${date} AND s.hour = ${hour} AND s.partition = ${partition} AND b.name = ${barber}`;
    CountResponse countResponse = check dbClient->queryRow(query);
    return countResponse.count == 0;
}

isolated function placeBooking(NewBookingRequest bookingRequest) returns BookingResponse|BarberNotFountError|SlotNotAvailableError|error {
    boolean isSlotAvailable = check checkSlotAvailability(bookingRequest.date, bookingRequest.hour, bookingRequest.partition, bookingRequest.barber);
    if (!isSlotAvailable) {
        return <SlotNotAvailableError>error("Slot is not available");
    }

    int barberId = check getBarberId(bookingRequest.barber);

    sql:ParameterizedQuery insertSlotQuery = `INSERT INTO slots (date, hour, partition, barber_id)
    VALUES (${bookingRequest.date}, ${bookingRequest.hour}, ${bookingRequest.partition}, ${barberId})`;

    sql:ExecutionResult insertSlotResult = check dbClient->execute(insertSlotQuery);
    int|string? slotId = insertSlotResult.lastInsertId;

    if !(slotId is int) {
        return error("Error getting slot id");
    }

    sql:ParameterizedQuery insertBookingQuery = `INSERT INTO appointments (slot_id, barber_id, user_id)
    VALUES (${slotId}, ${barberId}, ${bookingRequest.userId})`;

    sql:ExecutionResult insertBookingResult = check dbClient->execute(insertBookingQuery);
    int|string? bookingRef = insertBookingResult.lastInsertId;

    if !(bookingRef is int) {
        return error("Error getting booking reference");
    }

    return {
        bookingRef,
        date: bookingRequest.date,
        userId: bookingRequest.userId,
        hour: bookingRequest.hour,
        partition: bookingRequest.partition,
        barber: bookingRequest.barber
    };
}

isolated function deleteBooking(int bookingRef) returns boolean|error {
    sql:ParameterizedQuery deleteBookingQuery = `DELETE FROM appointments WHERE id = ${bookingRef}`;
    sql:ExecutionResult deleteBookingResult = check dbClient->execute(deleteBookingQuery);
    return deleteBookingResult.affectedRowCount == 1;
}
