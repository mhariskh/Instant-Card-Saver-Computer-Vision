import 'package:flutter/material.dart';
import "./contact_details.dart";
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart'; // Add this import

class ContactCardScreen extends StatelessWidget {
  final ContactDetails contactDetails;

  ContactCardScreen({required this.contactDetails});

  InputDecoration _customInputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Future<void> _saveContactDirectly(BuildContext context) async {
    final nameController = TextEditingController(text: contactDetails.name);
    final emailController = TextEditingController(text: contactDetails.email);
    final phoneNumberController =
        TextEditingController(text: contactDetails.phoneNumber);
    final notesController = TextEditingController(text: contactDetails.notes);
    final formKey = GlobalKey<FormState>();
    // Create a new contact with the contactDetails
    final contact = Contact(
      givenName: nameController.text,
      emails: [
        Item(label: "email", value: emailController.text),
      ],
      phones: [
        Item(label: "mobile", value: phoneNumberController.text),
      ],
      company: notesController.text,
    );

    // Save the contact
    ContactsService.addContact(contact);

    // Show a success dialog
    _showSuccessDialog(context);
  }

  Future<void> _saveContactWithEdit(BuildContext context) async {
    // Show dialog with editable fields
    final nameController = TextEditingController(text: contactDetails.name);
    final emailController = TextEditingController(text: contactDetails.email);
    final phoneNumberController =
        TextEditingController(text: contactDetails.phoneNumber);
    final notesController = TextEditingController(text: contactDetails.notes);
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Contact'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: _customInputDecoration('Name'),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: emailController,
                    decoration: _customInputDecoration('Email'),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: phoneNumberController,
                    decoration: _customInputDecoration('Phone Number'),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: notesController,
                    decoration: _customInputDecoration('Notes'),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop();
                  // Create a new contact with the edited information
                  final contact = Contact(
                    givenName: nameController.text,
                    emails: [
                      Item(label: "email", value: emailController.text),
                    ],
                    phones: [
                      Item(label: "mobile", value: phoneNumberController.text),
                    ],
                    company: notesController.text,
                  );

                  // Save the contact
                  ContactsService.addContact(contact);

                  // Show a success dialog
                  _showSuccessDialog(context);
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
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

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
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

  void _goToHomePage(BuildContext context) {
    // Replace 'HomePage' with the name of your home page widget
    void _goToHomePage(BuildContext context) {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Card'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Text(
                    contactDetails.name[0],
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
                title: contactDetails.name.isEmpty
                    ? Text("Name Not Found")
                    : Text(
                        contactDetails.name,
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
              ),
              Divider(),
              ListTile(
                title: Text('Email:',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                subtitle: contactDetails.email.isEmpty
                    ? Text('Email Not Found')
                    : Text('${contactDetails.email}',
                        style:
                            TextStyle(fontSize: 16, color: Colors.grey[700])),
              ),
              ListTile(
                title: Text('Phone Number:',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${contactDetails.phoneNumber}',
                        style:
                            TextStyle(fontSize: 16, color: Colors.grey[700])),
                    IconButton(
                      onPressed: () async {
                        final phoneNumber =
                            Uri.encodeComponent(contactDetails.phoneNumber);
                        final phoneUrl = 'tel:$phoneNumber';

                        if (await canLaunch(phoneUrl)) {
                          await launch(phoneUrl);
                        } else {
                          _showErrorDialog(
                              context, 'Could not launch phone app');
                        }
                      },
                      icon: Icon(Icons.call,
                          color: Theme.of(context).primaryColor),
                    ),
                  ],
                ),
              ),
              ListTile(
                title: Text('Notes:',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                subtitle: contactDetails.notes.isEmpty ||
                        contactDetails.notes == 'null' ||
                        contactDetails.notes == ' ' ||
                        contactDetails.notes == null
                    ? Text('Notes Not Found')
                    : Text('${contactDetails.notes}',
                        style:
                            TextStyle(fontSize: 16, color: Colors.grey[700])),
              ),
              SizedBox(height: 16),
              Center(
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await _saveContactDirectly(context);
                        },
                        child: Text('Save Directly'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          shadowColor: Color.fromARGB(255, 246, 159, 8),
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                          textStyle: TextStyle(fontSize: 18),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 16),
                        child: ElevatedButton(
                          onPressed: () {
                            _saveContactWithEdit(context);
                          },
                          child: Text('Edit Then Save'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shadowColor: Color.fromARGB(255, 8, 91, 246),
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 12),
                            textStyle: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _goToHomePage(context);
                  },
                  child: Text('Go to Home Page'),
                  style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).primaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
