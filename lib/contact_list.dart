import 'dart:async';

import 'package:contact_list/contact.dart';
import 'package:flutter/services.dart';

const MethodChannel _channel = const MethodChannel('com.manoilo.contact_list');

Future<List<Contact>> getContacts() async {
  Iterable contacts = await _channel.invokeMethod('getContacts');
  return _parseContacts(contacts);
}

List<Contact> _parseContacts(Iterable contacts) {
  return contacts.map<Contact>((m) => Contact.fromMap(m)).toList();
}
