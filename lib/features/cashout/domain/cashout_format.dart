String formatVnd(double value) {
  final digits = value.round().toString();
  final buffer = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(digits[index]);
  }
  return '${buffer.toString()} VND';
}

String formatUsdc(double value) {
  return '${value.toStringAsFixed(2).replaceAll('.', ',')} USDC';
}
