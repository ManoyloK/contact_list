import 'dart:typed_data';

class Contact {
  String identifier;
  String displayName;

  Uint8List avatar;

  Contact({
    this.identifier,
    this.displayName,
    this.avatar,
  });

  factory Contact.fromMap(Map contactMap) => Contact(
        identifier: contactMap["identifier"],
        displayName: contactMap["displayName"],
        avatar: contactMap["avatar"],
      );
}
