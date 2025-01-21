import 'dart:io';

import 'package:contact_app/Database/dbhelper.dart';
import 'package:contact_app/Models/contact_model.dart';
import 'package:contact_app/Screens/contact_edit_screen.dart';
import 'package:flutter/material.dart';

class ContactDetailsPage extends StatefulWidget {
  final Contact contact;
  final Function onUpdate; // Callback to refresh the main screen
  final Function onDelete; // Callback to refresh the main screen

  const ContactDetailsPage({
    super.key,
    required this.contact,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<ContactDetailsPage> createState() => _ContactDetailsPageState();
}

class _ContactDetailsPageState extends State<ContactDetailsPage> {
  @override
  void initState() {
    _updatedContact();
    super.initState();
  }

  Future<void> _updatedContact() async {
    // Call the onUpdate callback to refresh the main screen
    widget.onUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: const Text("Contact Details")),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              // Navigate to EditContactPage and wait for the result
              final updatedContact = await Navigator.push<Contact>(
                context,
                MaterialPageRoute(
                  builder: (context) => EditContactPage(
                    contact: widget.contact,
                    onUpdate: widget.onUpdate, // Pass the callback
                  ),
                ),
              );

              // If contact is updated, refresh the UI
              if (updatedContact != null) {
                widget.contact.firstName = updatedContact.firstName;
                widget.contact.lastName = updatedContact.lastName;
                widget.contact.phone = updatedContact.phone;
                widget.contact.email = updatedContact.email;
                widget.contact.company = updatedContact.company;
                widget.contact.state = updatedContact.state;
                widget.contact.city = updatedContact.city;
                widget.contact.street = updatedContact.street;

                widget.onUpdate(); // Trigger a refresh for the main screen
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () {
              _showDeleteConfirmationDialog(context);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Material(
                  elevation: 5,
                  borderRadius: BorderRadius.circular(60),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: widget.contact.dppath != null &&
                            widget.contact.dppath!.isNotEmpty
                        ? Image.file(
                            File(widget
                                .contact.dppath!), // Load the image from file
                            height: 120,
                            width: 120,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            "assets/images/p1.png", // Fallback image
                            height: 120,
                            width: 120,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildContactDetail("First Name", widget.contact.firstName),
              _buildContactDetail("Last Name", widget.contact.lastName),
              _buildContactDetail("Phone Number", widget.contact.phone),
              _buildContactDetail("Email", widget.contact.email),
              _buildContactDetail("Company", widget.contact.company),
              _buildContactDetail("State", widget.contact.state),
              _buildContactDetail("City", widget.contact.city),
              _buildContactDetail("Street", widget.contact.street),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactDetail(String label, String value) {
    if (value.isEmpty) return const SizedBox(); // Hide empty fields
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text("Are you sure you want to delete this contact?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _deleteContact(context,
                    widget.contact.id!); // Delete the contact if confirmed
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _deleteContact(BuildContext context, int contactId) async {
    final dbHelper = Dbhelper.instance;
    await dbHelper.deleteContact(contactId); // Delete from database

    // Show a confirmation snack bar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Contact deleted successfully")),
    );

    // Call the onDelete callback to refresh the main screen
    widget.onDelete(); // Trigger the refresh

    // Pop the contact details page and return to the main screen
    Navigator.pop(context); // Close the details page
  }
}
