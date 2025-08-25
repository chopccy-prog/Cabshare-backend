// utils/notify.js
/**
 * noop WhatsApp notifier. Replace with Gupshup / Cloud API later.
 * All functions are safe to call; they only console.log for now.
 */

function sendBookingCreated({ userPhone, ride, booking }) {
  console.log('[WhatsApp] booking created ->', { to: userPhone, rideId: ride?.id, bookingId: booking?.id });
}

function sendBookingConfirmed({ userPhone, ride, booking }) {
  console.log('[WhatsApp] booking confirmed ->', { to: userPhone, rideId: ride?.id, bookingId: booking?.id });
}

function sendBookingCancelled({ userPhone, ride, booking, by }) {
  console.log('[WhatsApp] booking cancelled ->', { to: userPhone, by, rideId: ride?.id, bookingId: booking?.id });
}

module.exports = {
  sendBookingCreated,
  sendBookingConfirmed,
  sendBookingCancelled,
};
