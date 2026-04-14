# Presentation Folder Issues

This file summarizes the primary problems found in `lib/presentation`, including compile/lint issues, broken or inconsistent navigation flows, unused screens, and no-op UI handlers.

## 1. Compile / lint issues

- `lib/presentation/mainscreen.dart`
  - Unused import: `package:sidi/presentation/appointments_screen.dart`.
  - The bottom navigation "Book" tab currently renders `BookingScreen`, while `AppointmentsScreen` exists and is not used in the main nav. This looks like a flow mismatch.

## 2. Navigation and flow inconsistencies

- `lib/presentation/mainscreen.dart`
  - The Book tab points to `BookingScreen`, which shows static content.
  - `ProfileScreen` already routes "My Bookings" to `AppointmentsScreen`, but the bottom Book tab does not.

- `lib/presentation/bookingscreen.dart`
  - Static placeholder UI with no booking API integration or data display.
  - The screen has no active booking-related navigation targets.

- `lib/presentation/appointmentbooking.dart`
  - `ConfirmationScreen` is defined but not referenced anywhere in the repo.
  - This makes the booking confirmation page dead code.

- `lib/presentation/stylistlistscreen.dart`
  - `BOOK NOW` and `VIEW` handlers are empty (`onTap: () {}`).
  - The user cannot actually navigate from stylist cards to detail/booking.

- `lib/presentation/timeslotscreen.dart`
  - The "CONTINUE TO PAYMENT" button is a no-op.
  - The "Enhance your session" button is also a no-op.
  - This breaks the booking funnel at the payment step.

## 3. Unused screens / widgets

- `lib/presentation/elitescreen.dart`
  - The screen appears unused anywhere in the repo.
  - It also contains many empty action handlers.

- `lib/presentation/appointmentbooking.dart`
  - No active route references were found for `ConfirmationScreen`.

- `lib/presentation/widgets/appointmentcard.dart`
  - Contains no-op button handlers.

## 4. No-op UI callbacks

The following screens have buttons or actions defined with empty callbacks, which is a UX defect and indicates incomplete flow implementation:

- `lib/presentation/loginscreen.dart`
  - "Forgot Password?" button has `onPressed: () {}`.

- `lib/presentation/stylistlistscreen.dart`
  - `BOOK NOW`, `VIEW` actions are empty.

- `lib/presentation/bookingscreen.dart`
  - Buttons like `RESERVE SPACE` are no-op.

- `lib/presentation/appointments_screen.dart`
  - Some booking cards contain `onPressed: () {}` placeholders.

- `lib/presentation/appointmentbooking.dart`
  - Multiple buttons in the confirmation UI are no-op.

- `lib/presentation/notificationsscreen.dart`
  - Notification card actions are empty.

- `lib/presentation/timeslotscreen.dart`
  - Continue and enhance buttons are no-op.

- `lib/presentation/elitescreen.dart`
  - Several action buttons are no-op.

- `lib/presentation/widgets/appointmentcard.dart`
  - Buttons inside the appointment card are no-op.

## 5. UX / data load issues

- `lib/presentation/appointments_screen.dart`
  - If booking fetch returns no data, the UI shows a message but does not offer retry.

- `lib/presentation/bookingscreen.dart`
  - Presents a search bar and discovery UI without any actual search or booking interaction.

## 6. Recommendations

- Replace the Book tab in `MainScreen` with `AppointmentsScreen` or wire `BookingScreen` to real booking data.
- Remove dead imports and unused screens such as `Elitescreen` and `AppointmentBooking` if they are not part of the intended user flow.
- Implement the empty callbacks in `StylistListScreen`, `TimeSlotScreen`, `NotificationsScreen`, and other placeholder action buttons.
- Add retry/error handling to `AppointmentsScreen` when booking fetch fails.
- Optionally rename or reorganize presentation screens to reduce confusion between `BookingScreen`, `AppointmentsScreen`, and the booking flow.
