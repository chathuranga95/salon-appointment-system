import ballerina/http;
import ballerina/log;

listener http:Listener endpoint = new (9090);

service / on endpoint {
    # Delete a booking
    #
    # + bookingRef - Reference ID of the booking
    # + return - returns can be any of following types 
    # http:Ok (Booking successfully deleted)
    # http:BadRequest (Bad request)
    # http:InternalServerError (Internal Server Error)
    resource function delete booking(int bookingRef) returns http:Ok|http:BadRequest|http:InternalServerError {
        log:printDebug("Deleting booking", bookingRef = bookingRef);

        string errorMessage = "Error while deleting the booking";
        boolean|error isDeleted = deleteBooking(bookingRef);
        if isDeleted is error {
            log:printError(errorMessage, 'error = isDeleted, bookingRef = bookingRef);
            return <http:InternalServerError>{body: {message: errorMessage}};
        }
        return <http:Ok>{body: {message: "Booking deleted successfully"}};
    }

    # Get placed appointments for a user
    #
    # + userId - ID of the user
    # + return - returns can be any of following types 
    # http:Ok (List of placed appointments for the given user)
    # http:BadRequest (Bad request)
    # http:InternalServerError (Internal Server Error)
    resource function get bookings(string userId) returns BookingsResponse|http:BadRequest|http:InternalServerError {
        log:printDebug("Retrieving bookings for user", userId = userId);

        string errorMessage = "Error while bookings for the user";
        Booking[]|error bookings = getUserBookings(userId);
        if bookings is error {
            log:printError(errorMessage, 'error = bookings, userId = userId);
            return <http:InternalServerError>{body: {message: errorMessage}};
        }
        return {data: bookings};
    }

    # Get available appointment slots
    #
    # + date - Date for which to get available slots
    # + hour - Specific hour for which to get available slots
    # + return - returns can be any of following types 
    # http:Ok (List of available appointment slots)
    # http:BadRequest (Bad request)
    # http:InternalServerError (Internal Server Error)
    resource function get slots(string date, int? hour) returns SlotsResponse|http:BadRequest|http:InternalServerError {
        log:printDebug("Retrieving available slots for date", date = date, hour = hour);

        string errorMessage = "Error while retrieving available slots";
        Slot[]|error slots = getAvailableSlots(date);
        if slots is error {
            log:printError(errorMessage, 'error = slots, date = date, hour = hour);
            return <http:InternalServerError>{body: {message: errorMessage}};
        }
        return {data: slots};
    }

    # Place a new booking
    #
    # + return - returns can be any of following types 
    # http:Ok (Booking successfully placed)
    # http:BadRequest (Bad request)
    # http:InternalServerError (Internal Server Error)
    resource function post booking(NewBookingRequest payload) returns BookingResponse|http:BadRequest|http:InternalServerError {
        log:printDebug("Placing a new booking", payload = payload);

        string errorMessage = "Error while placing the booking";
        BookingResponse|error bookingRef = placeBooking(payload);

        if bookingRef is BarberNotFountError|SlotNotAvailableError {
            return <http:BadRequest>{body: {message: bookingRef.message()}};
        }
        if bookingRef is error {
            log:printError(errorMessage, 'error = bookingRef, payload = payload);
            return <http:InternalServerError>{body: {message: errorMessage}};
        }
        return bookingRef;
    }
}
