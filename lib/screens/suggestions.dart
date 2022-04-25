import 'dart:io';
import 'package:english_words/english_words.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_me/screens/login.dart';
import 'package:hello_me/screens/saved_delete_confirmation.dart';
import 'package:hello_me/screens/user_profile.dart';
import 'package:hello_me/user_manager.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snapping_sheet/snapping_sheet.dart';


class RandomWords extends StatefulWidget {
  const RandomWords({Key? key}) : super(key: key);

  @override
  State<RandomWords> createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  final _saved = <dynamic>{};
  final _biggerFont = const TextStyle(fontSize: 18);
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CurrentUser _currentUser = CurrentUser.instance();
  final _profileController = SnappingSheetController();

  final _deleteSnackBar = const SnackBar(
      content: Text('Deletion is not implemented yet')
  );

  final _logoutSnackBar = const SnackBar(
      content: Text('Successfully logged out')
  );

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentUser>(
        builder: (context, currentUser, child) {
          _currentUser = currentUser;
          var userStatus = currentUser.status;

          return Scaffold (
            appBar: AppBar(
              title: const Text('Startup Name Generator'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.star),
                  onPressed: _pushSaved,
                  tooltip: 'Saved Suggestions',
                ),
                IconButton(
                  icon: userStatus == Status.authenticated ?
                  const Icon(Icons.exit_to_app) :
                  const Icon(Icons.login),
                  onPressed: userStatus == Status.authenticated ? () async{
                    await currentUser.signOut();
                    ScaffoldMessenger.of(context).showSnackBar(_logoutSnackBar);
                    setState(() {
                      _saved.clear();
                    });
                  } :
                  _pushLogin,
                  tooltip: userStatus == Status.authenticated ? 'logout' : 'login',
                ),
              ],
            ),
            body: _buildSuggestionsScreen(context),
          );
        }
    );
  }

  Widget _buildSuggestionsScreen(BuildContext context) {
    if (_currentUser.status == Status.authenticated) {
      return SnappingSheet(
        child: _buildSuggestions(),
        controller: _profileController,
        grabbingHeight: 50,
        grabbing: Scaffold(
          body: InkWell(
            onTap: () {
              if (_profileController.currentPosition > 25) {
                _profileController.snapToPosition(
                    const SnappingPosition.pixels(positionPixels: 25)
                );
              }
              else {
                _profileController.snapToPosition(
                    const SnappingPosition.factor(positionFactor: 0.25)
                );
              }
            },
            child: Container(
              height: 50,
              color: Colors.grey,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text('Welcome back ' + _currentUser.user!.email!),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.keyboard_arrow_up),
                  ),
                ],
              ),
            ),
          ),
        ),
        sheetBelow: SnappingSheetContent(
          draggable: true,
          child: const UserProfile(),
        ),
      );
    }
    return _buildSuggestions();
  }

  Future getUserSaved() async{
    var user = _currentUser.user;
    bool hasLocalSaved = _saved.isNotEmpty;
    if (user != null) {
      await _firestore.collection('usersData').doc(user.email).get().then((snapshot) {
        if (snapshot.exists) {
          var data = snapshot.data();
          if (data != null) {
            setState(() {
              _saved.addAll(data['saved']);
            });
          }
        }
      });
      if (hasLocalSaved) {
        await _firestore.collection('usersData').doc(user.email).set({"saved": FieldValue.arrayUnion(_saved.toList())}, SetOptions(merge: true));
      }
    }
  }

  void _pushSaved() async{
    if (_currentUser.status == Status.authenticated) {
      await getUserSaved();
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          final tiles = _saved.map(
                (pair) {
              return Dismissible(
                background: Container(
                  color: Theme.of(context).colorScheme.primary,
                  child: Row(
                    children: [
                      Icon(
                          Icons.delete,
                          color: Theme.of(context).colorScheme.onPrimary
                      ),
                      Text(
                        'Delete Saved Suggestion',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary
                        ),
                      )
                    ],
                  ),
                ),
                key: ValueKey<String>(pair),
                onDismissed: (DismissDirection direction) {
                  setState(() {
                    removeSaved(pair);
                  });
                },
                child: ListTile(
                  title: Text(
                    pair,
                    style: _biggerFont,
                  ),
                ),
                confirmDismiss: (DismissDirection direction) async{
                  return await showConfirmationDialog(context, pair) == true;
                },
              );
            },
          );
          final divided = tiles.isNotEmpty
              ? ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList()
              : <Widget>[];

          return Scaffold(
            appBar: AppBar(
              title: const Text('Saved Suggestions'),
            ),
            body: ListView(children: divided),
          );
        },
      ),
    );
  }

  void _pushLogin() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return CustomForm();
        },
      ),
    );
  }

  void _pushUserProfile() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return const UserProfile();
        },
      ),
    );
  }

  Widget _buildSuggestions() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      // The itemBuilder callback is called once per suggested
      // word pairing, and places each suggestion into a ListTile
      // row. For even rows, the function adds a ListTile row for
      // the word pairing. For odd rows, the function adds a
      // Divider widget to visually separate the entries. Note that
      // the divider may be difficult to see on smaller devices.
      itemBuilder: (context, i) {
        // Add a one-pixel-high divider widget before each row
        // in the ListView.
        if (i.isOdd) {
          return const Divider();
        }

        // The syntax "i ~/ 2" divides i by 2 and returns an
        // integer result.
        // For example: 1, 2, 3, 4, 5 becomes 0, 1, 1, 2, 2.
        // This calculates the actual number of word pairings
        // in the ListView,minus the divider widgets.
        final index = i ~/ 2;
        // If you've reached the end of the available word
        // pairings...
        if (index >= _suggestions.length) {
          // ...then generate 10 more and add them to the
          // suggestions list.
          _suggestions.addAll(generateWordPairs().take(10));
        }
        return Dismissible(
          background: Container(
            color: Theme.of(context).colorScheme.primary,
            child: Row(
              children: [
                Icon(
                    Icons.delete,
                    color: Theme.of(context).colorScheme.onPrimary
                ),
                Text(
                  'Delete Suggestion',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary
                  ),
                )
              ],
            ),
          ),
          key: ValueKey<WordPair>(_suggestions[index]),
          onDismissed: (DismissDirection direction) {
            setState(() {
              _suggestions.removeAt(index);
            });
          },
          child: _buildRow(_suggestions[index]),
          confirmDismiss: (DismissDirection direction) async{
            ScaffoldMessenger.of(context).showSnackBar(_deleteSnackBar);
            return null;
          },
        );
      },
    );
  }

  Widget _buildRow(pair) {
    final alreadySaved = _saved.contains(pair.asPascalCase.toString());
    return ListTile(
      title: Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
      trailing: Icon(
        alreadySaved ? Icons.star : Icons.star_border,
        color: alreadySaved ? Theme.of(context).colorScheme.primary : null,
        semanticLabel: alreadySaved ? 'Remove from saved' : 'Save',
      ),
      onTap: () {
        setState(() {
          if (alreadySaved) {
            removeSaved(pair.asPascalCase.toString());
          } else {
            addSaved(pair);
          }
        });
      },
    );
  }

  void addSaved(pair) async{
    _saved.add(pair.asPascalCase.toString());
    var user = _currentUser.user;
    if (user != null) {
      await _firestore.collection('usersData').doc(user.email).set({"saved": FieldValue.arrayUnion(_saved.toList())}, SetOptions(merge: true));
    }
  }
  void removeSaved(pair) async{
    _saved.remove(pair);
    var user = _currentUser.user;
    if (user != null) {
      _firestore.collection('usersData').doc(user.email).update({"saved": FieldValue.delete()}).then((value) async{
        await _firestore.collection('usersData').doc(user.email).update({"saved": FieldValue.arrayUnion(_saved.toList())});
      });
    }
  }
}