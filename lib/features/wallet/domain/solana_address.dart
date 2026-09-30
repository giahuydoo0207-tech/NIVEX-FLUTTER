/// A first check of a pasted Solana address before it is sent to the backend,
/// which makes the final decision (including the ed25519 curve check).
///
/// Returns null when the text looks like a public address, otherwise a message
/// to show. The message never repeats the input, so a pasted secret is not
/// echoed on screen.
String? checkSolanaAddress(String input) {
  final value = input.trim();
  if (value.isEmpty) return 'Nhập địa chỉ ví Solana công khai của bạn.';
  if (value.split(RegExp(r'\s+')).length >= 12) {
    return 'Không nhập cụm từ khôi phục (seed phrase). Nova chỉ cần địa chỉ ví công khai.';
  }
  if (value.startsWith('[') ||
      (value.length >= 80 &&
          value.length <= 90 &&
          RegExp(r'^[A-Za-z0-9]+$').hasMatch(value))) {
    return 'Đây có vẻ là private key. Đừng chia sẻ nó; Nova chỉ cần địa chỉ ví công khai.';
  }
  final bytes = decodeBase58(value);
  if (bytes == null || bytes.length != 32) {
    return 'Địa chỉ ví không hợp lệ. Hãy dán địa chỉ ví Solana công khai '
        '(32–44 ký tự Base58).';
  }
  return null;
}

const _alphabet = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';

/// Decoded bytes, or null when [value] contains a non-Base58 character.
List<int>? decodeBase58(String value) {
  var number = BigInt.zero;
  var leadingZeros = 0;
  var counting = true;
  for (final char in value.split('')) {
    final digit = _alphabet.indexOf(char);
    if (digit < 0) return null;
    if (counting && digit == 0) {
      leadingZeros++;
    } else {
      counting = false;
    }
    number = number * BigInt.from(58) + BigInt.from(digit);
  }
  final bytes = <int>[];
  while (number > BigInt.zero) {
    bytes.insert(0, (number & BigInt.from(0xff)).toInt());
    number = number >> 8;
  }
  return [...List.filled(leadingZeros, 0), ...bytes];
}

/// `AbCd…WxYz` for display; the full address stays available to copy.
String shortSolanaAddress(String address) => address.length <= 12
    ? address
    : '${address.substring(0, 4)}…${address.substring(address.length - 4)}';
