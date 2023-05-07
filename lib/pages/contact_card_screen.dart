import 'package:flutter/material.dart';
import "./contact_details.dart";
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactCardScreen extends StatelessWidget {
  final ContactDetails contactDetails;

  ContactCardScreen({required this.contactDetails});

  Future<void> _saveContact(BuildContext context) async {
    // Check and request permission to access contacts
    PermissionStatus permissionStatus = await Permission.contacts.status;
    if (permissionStatus.isDenied || permissionStatus.isRestricted) {
      permissionStatus = await Permission.contacts.request();
      if (!permissionStatus.isGranted) return;
    }

    // Create a new contact with the extracted information
    final contact = Contact(
      givenName: contactDetails.name,
      emails: [Item(label: "email", value: contactDetails.email)],
      phones: [Item(label: "mobile", value: contactDetails.phoneNumber)],
      company: contactDetails.notes,
    );

    // Save the contact
    await ContactsService.addContact(contact);

    // Show a success dialog
    _showSuccessDialog(context);
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Contact saved successfully'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Card'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${contactDetails.name}'),
            SizedBox(height: 8),
            Text('Email: ${contactDetails.email}'),
            SizedBox(height: 8),
            Text('Phone Number: ${contactDetails.phoneNumber}'),
            SizedBox(height: 8),
            Text('Notes: ${contactDetails.notes}'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _saveContact(context);
              },
              child: Text('Save Contact'),
            ),
          ],
        ),
      ),
    );
  }
}
