import 'package:sqflite/sqflite.dart';

import 'package:omnistudin_flutter/Logic/chat_message_service/message.dart';

void startMessagePersistenceService(ReceivePort receivePort) async {
  // create a new isolate
  await Isolate.spawn(
    messagePersistenceService,
    receivePort.sendPort,
  );
}

void messagePersistenceService(SendPort sendPort) async {
  // create a new receive port
  final receivePort = ReceivePort();

  // send the receive port to the main isolate
  sendPort.send(receivePort.sendPort);

  // Avoid errors caused by flutter upgrade.
  // Importing 'package:flutter/widgets.dart' is required.
  WidgetsFlutterBinding.ensureInitialized();

  
  // Open the database and store the reference.
  final database = openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(await getDatabasesPath(), 'chat_messages.db'),
    // When the database is first created, create a table to store messages.
    onCreate: (db, version) {
      // Run the CREATE TABLE statement on the database.
      return db.execute('''
        CREATE TABLE messages (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          fromStudent TEXT NOT NULL,
          content TEXT NOT NULL,
          timestamp TEXT NOT NULL,
          isRead INTEGER NOT NULL,
          ownMsg INTEGER NOT NULL
        )
      ''');
    },
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: 1,
  );

  // Define a function that inserts messages into the database
  Future<void> insertMessage(Message msg) async {
    // Get a reference to the database.
    final db = await database;

    // Insert the Message into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same message is inserted twice.
    //
    // In this case, replace any previous data.
    await db.insert(
      'messages',
      msg.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // A method that retrieves all the messages from the messages table.
  Future<List<Message>> getMessages() async {
    // Get a reference to the database.
    final db = await database;

    // Query the table for all the messages.
    final List<Map<String, Object?>> messageMap = await db.query('messages');

    // Convert the list of each message's fields into a list of `Message` objects.
    return [
      for (final {
            'fromStudent': fromStudent,
            'content': content,
            'timestamp': timestamp,
            'isRead': isRead,
            'ownMsg': ownMsg,
          } in messageMap)
        Message(
          fromStudent: fromStudent as String,
          content: content as String,
          timestamp: DateTime.parse(timestamp as String),
          isRead: (isRead as int) == 1,
          ownMsg: (ownMsg as int) == 1,
        )
    ];
  }

  // Process incoming messages
  receivePort.listen((message) {
    if (message is List) {
      if (message[0] == 'i') {
        insertMessage(message[1]);
      }
    }
  });
}
