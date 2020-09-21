import 'package:contact_list/contact_list.dart';
import 'package:contact_list/contact.dart';
import 'package:contact_list_example/contacts_list_view.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: Text(
            'Contacts',
            style: const TextStyle(
              color: Colors.black,
            ),
          ),
        ),
        body: ContactsBody(),
      ),
    );
  }
}

class ContactsBody extends StatefulWidget {
  @override
  _ContactsBodyState createState() => _ContactsBodyState();
}

class _ContactsBodyState extends State<ContactsBody> {
  TextEditingController _searchController;
  List<Contact> _contacts;
  List<Contact> _recent = [];
  String _searchQuery;
  GlobalKey<ContactsListViewState> _keyIndexedListViewState;
  String _errorMessage;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _keyIndexedListViewState = GlobalKey();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    if (await Permission.contacts.request().isGranted) {
      Iterable<Contact> contacts;
      contacts = await getContacts();

      if (!mounted) return;

      setState(() {
        _contacts = contacts.toList();
      });
    } else {
     setState(() {
       _errorMessage = 'Permission to get contacts is not granted';
     });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage?.isNotEmpty ?? false)
      return Center(child: Text(_errorMessage,style: TextStyle(fontSize: 24,),textAlign: TextAlign.center,));
    else if (_contacts == null)
      return const Center(child: CircularProgressIndicator());
    else
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _buildSearchBlock(context),
            Expanded(
              child: ContactsListView(
                _contacts.map((e) => e.displayName).toList(),
                key: _keyIndexedListViewState,
                itemBuilder: (context, index) {
                  final contact = _contacts[index];
                  return ContactItem(
                    contact: contact,
                    onTap: () {
                      setState(() {
                        _recent = {
                          ...?_recent,
                          contact,
                        }.toList();
                        Scaffold.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Added to recent'),
                          ),
                        );
                      });
                    },
                  );
                },
                titleBuilder: (context) {
                  return const ListTile(
                    title: Text('Contacts'),
                  );
                },
                headers: [
                  HeaderSection(
                    itemCount: _recent.length,
                    index: '★',
                    itemBuilder: (context, index) {
                      final contact = _recent[index];
                      return ContactItem(contact: contact);
                    },
                    titleBuilder: (context) {
                      return const ListTile(
                        title: Text('Recent'),
                      );
                    },
                  )
                ],
                itemHeight: 60,
              ),
            ),
          ],
        ),
      );
  }

  Padding _buildSearchBlock(BuildContext context) {
    return Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Row(
              children: <Widget>[
                Flexible(
                  flex: 3,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (query) {
                      _onSearchQueryChanged(query, context);
                    },
                    decoration: const InputDecoration(
                      hintText: 'Search people',
                      isDense: true,
                      suffixIcon: Icon(Icons.search),
                      contentPadding: EdgeInsets.fromLTRB(12, 0, 12, 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(24),
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(
                  flex: 1,
                ),
                IconButton(
                  alignment: Alignment.center,
                  color: Colors.indigo,
                  icon: const Icon(Icons.add),
                  onPressed: () {},
                )
              ],
            ),
          );
  }

  void _onSearchQueryChanged(String query, BuildContext context) {
    setState(() {
      if ((_searchQuery?.isEmpty ?? true) && (query?.isNotEmpty ?? false)) {
        Scaffold.of(context).showBottomSheet(_buildBottomSheet);
      }
      _searchQuery = query;
    });
  }

  BottomSheet _buildBottomSheet(BuildContext context) {
    return BottomSheet(
      elevation: 8,
      onClosing: () {},
      builder: (_) {
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              FlatButton(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _searchController.clear();
                    Navigator.of(context).pop();
                  });
                },
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.close),
                    const Text('close'),
                  ],
                ),
              ),
              FloatingActionButton(
                backgroundColor: Colors.indigo,
                onPressed: () {
                  _keyIndexedListViewState.currentState
                      .scrollToText(_searchQuery);
                },
                child: const Icon(Icons.done),
              )
            ],
          ),
        );
      },
    );
  }
}

class ContactItem extends StatelessWidget {
  final Contact contact;
  final GestureTapCallback onTap;

  const ContactItem({
    Key key,
    @required this.contact,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundImage:
            contact.avatar != null ? MemoryImage(contact.avatar) : null,
      ),
      title: Text(contact.displayName),
    );
  }
}
