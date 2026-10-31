const { calculateTotal, getUserName, validateRange } = require('../src/utils');

test('calculateTotal suma correctamente', () => {
  expect(calculateTotal(100, 16)).toBe(116);
});

test('getUserName devuelve el nombre en mayúsculas', () => {
  expect(getUserName({ name: 'ana' })).toBe('ANA');
});

test('getUserName maneja usuario nulo', () => {
  expect(getUserName(null)).toBe('');
});

test('validateRange valida el rango correctamente', () => {
  expect(validateRange(50)).toBe(true);
  expect(validateRange(-1)).toBe(false);
});
