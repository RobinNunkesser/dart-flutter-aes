import 'package:aes_cbc/aes.dart';
import 'package:test/test.dart';
import 'dart:math';
import 'dart:typed_data';

void main() {
  test('Encryption and decryption with padding', () {
    final random = Random.secure();
    final plaintext =
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.';
    // The block size is always 128-bits (16 bytes)
    final blockSize = 16;
    // Apply PKCS#7 padding
    final paddingLength = blockSize - (plaintext.length % blockSize);
    final paddedPlaintext = Uint8List.fromList([
      ...plaintext.codeUnits,
      ...List<int>.filled(paddingLength, paddingLength),
    ]);
    // Generate random key (256-bit) and IV (128-bit)
    final key = Uint8List.fromList(
      List<int>.generate(32, (i) => random.nextInt(256)),
    );
    final iv = Uint8List.fromList(
      List<int>.generate(16, (i) => random.nextInt(256)),
    );
    // Encrypt and decrypt
    final cipherText = aesCbcEncrypt(key, iv, paddedPlaintext);
    final decryptedPaddedPlaintext = aesCbcDecrypt(key, iv, cipherText);

    // Remove PKCS#7 padding
    final padLen = decryptedPaddedPlaintext.isEmpty
        ? 0
        : decryptedPaddedPlaintext.last;

    // Convert decrypted bytes back to string
    final decryptedPlaintext = String.fromCharCodes(
      decryptedPaddedPlaintext.sublist(
        0,
        decryptedPaddedPlaintext.length - padLen,
      ),
    );

    print('Plaintext: $plaintext');
    print('Key: $key');
    print('IV: $iv');
    print('Ciphertext: $cipherText');
    print('Decrypted Plaintext: $decryptedPlaintext');

    expect(decryptedPaddedPlaintext, paddedPlaintext);
    expect(decryptedPlaintext, plaintext);
  });
}
