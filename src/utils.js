function calculateTotal(price, tax) {
  return price + tax;
}

function getUserName(user) {
  if (!user || !user.name) return '';
  return user.name.toUpperCase();
}

function validateRange(value, min = 0, max = 120) {
  return value >= min && value <= max;
}

module.exports = { calculateTotal, getUserName, validateRange };
