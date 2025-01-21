import 'package:flutter/material.dart';
import 'package:contact_app/Screens/add_contact.dart';
import '../Database/dbhelper.dart';
import '../Models/contact_model.dart';
import 'contact_detail_screen.dart';

class ContactMainScreen extends StatefulWidget {
  const ContactMainScreen({super.key});

  @override
  State<ContactMainScreen> createState() => _ContactMainScreenState();
}

class _ContactMainScreenState extends State<ContactMainScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Contact> _contacts = [];
  List<Contact> _filteredContacts = [];

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final dbHelper = Dbhelper.instance;
    final contacts = await dbHelper.getContacts();
    setState(() {
      _contacts = contacts;
      _filteredContacts = contacts; // Show all contacts initially.
    });
  }

  void _filterContacts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredContacts = _contacts;
      } else {
        _filteredContacts = _contacts
            .where((contact) =>
                (contact.firstName + " " + contact.lastName)
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                contact.phone.contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          onChanged: _filterContacts,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
            filled: true,
            fillColor: Colors.grey[200],
            hintText: "Search Contacts",
            hintStyle: const TextStyle(color: Colors.grey),
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  "All Contacts",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadContacts,
                ),
              ],
            ),
            const SizedBox(height: 5),
            const Divider(height: 2, color: Colors.grey),
            const SizedBox(height: 5),
            Expanded(
              child: _filteredContacts.isEmpty
                  ? const Center(
                      child: Text(
                        "No Contacts Found",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredContacts.length,
                      itemBuilder: (context, index) {
                        final contact = _filteredContacts[index];
                        final displayName = contact.firstName.isEmpty &&
                                contact.lastName.isEmpty
                            ? contact.phone
                            : "${contact.firstName} ${contact.lastName}";
                        return ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.grey,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          title: Text(displayName),
                          subtitle: Text(contact.phone),
                          onTap: () async {
                            // Navigate to ContactDetailsPage and wait for updates
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ContactDetailsPage(
                                  contact: contact,
                                  onUpdate: _loadContacts, // Refresh after update
                                  onDelete: _loadContacts, // Refresh after delete
                                ),
                              ),
                            );
                            // Reload contacts when returning to this screen
                            _loadContacts();
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddContact()),
          );
          // Reload contacts after adding a new contact.
          _loadContacts();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
