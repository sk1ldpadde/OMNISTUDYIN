import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:omnistudin_flutter/Logic/chat_message_service/message.dart';
import 'package:omnistudin_flutter/Logic/chat_message_service/message_persistence_isolate.dart'; // Stellen Sie sicher, dass spawnMessagePollingService hier definiert ist
import 'package:omnistudin_flutter/Logic/chat_message_service/message_polling_isolate.dart'; // Stellen Sie sicher, dass spawnMessagePollingService hier definiert ist
import 'package:shared_preferences/shared_preferences.dart';


class ChatPage extends StatefulWidget {
  final String email; // Ändern Sie chatId in email

  const ChatPage({Key? key, required this.email}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final SendPort _pollingServicePort;
  List<types.Message> messageList = [];
  types.User _user = types.User(id: 'user-id', firstName: 'User', lastName: 'Name'); // Hier definieren und initialisieren wir _user




  @override
  void initState() {
    super.initState();
    messageList = [];
    _loadMessages();
    init();
  }


  Future<void> init() async {
    ReceivePort pageReceivePort = ReceivePort();

    // Start the message database service as an isolate
    startMessagePersistenceService(pageReceivePort);

    // Get the send port of the message persistence service
    SendPort dbIsolatePort = await pageReceivePort.first;
    _pollingServicePort = dbIsolatePort;
    // Start the message polling service as an isolate
    startMessagePollingService(dbIsolatePort, widget.email);
    ReceivePort responsePort = ReceivePort();
    responsePort.listen((message) {
      // Ensure that UI updates happen on the main isolate
      if (message is types.Message) {
        setState(() {
          messageList.add(message);
        });
      }
    });

    // Inform the database isolate about where to send responses.
    // Assuming the database service is expecting a "setupResponsePort" message with a SendPort.
    dbIsolatePort.send(["setupResponsePort", responsePort.sendPort]);

    // Now send a message to the database isolate asking for data.
    dbIsolatePort.send(["g"]);

    _loadMessages();
  }


  void _addMessage(types.Message message) {
    setState(() {
      messageList.insert(0, message);
    });
  }

  void _handleAttachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: SizedBox(
          height: 144,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleImageSelection();
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Photo'),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleFileSelection();
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('File'),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleFileSelection() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      final message = types.FileMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        mimeType: lookupMimeType(result.files.single.path!),
        name: result.files.single.name,
        size: result.files.single.size,
        uri: result.files.single.path!,
      );

      _addMessage(message);
    }
  }

  void _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);

      final message = types.ImageMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        height: image.height.toDouble(),
        id: const Uuid().v4(),
        name: result.name,
        size: bytes.length,
        uri: result.path,
        width: image.width.toDouble(),
      );

      _addMessage(message);
    }
  }

  void _handleMessageTap(BuildContext _, types.Message message) async {
    if (message is types.FileMessage) {
      var localPath = message.uri;

      if (message.uri.startsWith('http')) {
        try {
          final index =
          messageList.indexWhere((element) => element.id == message.id);
          final updatedMessage =
          (messageList[index] as types.FileMessage).copyWith(
            isLoading: true,
          );

          setState(() {
            messageList[index] = updatedMessage;
          });

          final client = http.Client();
          final request = await client.get(Uri.parse(message.uri));
          final bytes = request.bodyBytes;
          final documentsDir = (await getApplicationDocumentsDirectory()).path;
          localPath = '$documentsDir/${message.name}';

          if (!File(localPath).existsSync()) {
            final file = File(localPath);
            await file.writeAsBytes(bytes);
          }
        } finally {
          final index =
          messageList.indexWhere((element) => element.id == message.id);
          final updatedMessage =
          (messageList[index] as types.FileMessage).copyWith(
            isLoading: null,
          );

          setState(() {
            messageList[index] = updatedMessage;
          });
        }
      }

      await OpenFilex.open(localPath);
    }
  }

  void _handlePreviewDataFetched(
      types.TextMessage message,
      types.PreviewData previewData,
      ) {
    final index = messageList.indexWhere((element) => element.id == message.id);
    final updatedMessage = (messageList[index] as types.TextMessage).copyWith(
      previewData: previewData,
    );

    setState(() {
      messageList[index] = updatedMessage;
    });
  }

  void _handleSendPressed(types.PartialText message) async {
    ReceivePort responsePort = ReceivePort();
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );


    // Senden Sie die Nachricht an das Backend über den `sendPort`
    _pollingServicePort.send(['s', responsePort.sendPort, [_user, widget.email, textMessage]]);
    // Fügen Sie die Nachricht sofort der Liste `_messages` hinzu
    _addMessage(textMessage);
  }



  void _loadMessages() async {
    /*
      final mainReceivePort = ReceivePort();
      await Isolate.spawn((args) {
        final sendPort = args[0] as SendPort;
        final email = args[1] as String;
        startMessagePollingService([sendPort, email]);
      }, [mainReceivePort.sendPort, widget.email]);
      _pollingServicePort = await mainReceivePort.first;

    // Hier können Sie auch eine Ladeanimation anzeigen, während Nachrichten geladen werden
    // Zum Beispiel: setState(() { _isLoadingMessages = true; });

    Timer.periodic(const Duration(seconds: 2), (Timer t) async {
      final pollingResponsePort = ReceivePort();
      _pollingServicePort.send(['w', pollingResponsePort.sendPort, widget.email]); // Verwenden Sie widget.email
      final response = await pollingResponsePort.first;
      List<types.Message> messages = response as List<types.Message>;

      // Konvertieren Sie die abgerufenen Nachrichten in das Chat-Format und fügen Sie sie der _messages-Liste hinzu
      List<types.Message> chatMessages = messages.map((msg) {
        if (msg is types.TextMessage) {
          return types.TextMessage(
            author: _user,
            createdAt: msg.createdAt, // Verwenden Sie createdAt anstelle von timestamp
            id: msg.id,
            text: msg.text, // Verwenden Sie text anstelle von content
          );
        }
      }).where((msg) => msg != null).toList().cast<types.Message>();

      // Aktualisieren Sie den Zustand, um die geladenen Nachrichten im Chat anzuzeigen
      setState(() {
        _messages = chatMessages;
        // Hier können Sie auch die Ladeanimation ausblenden, wenn die Nachrichten geladen sind
        // Zum Beispiel: _isLoadingMessages = false;
      });
      print('Messages');
      print(_messages);
    });*/

    // Periodically print messages with "inf21113@gmail.com"
    Timer.periodic(const Duration(seconds: 2), (Timer t) async {
      // Create new port for responses from polling Isolate
      ReceivePort pollingResponsePort = ReceivePort();

      // Get all messages
      _pollingServicePort.send(['w', pollingResponsePort.sendPort, widget.email]);

      // Listen for response
      final pollingServiceResponse = await pollingResponsePort.first;

      // Print message for debug
      final List<types.Message> messages = await pollingServiceResponse;

      for (var message in messages) {
        print(message);
      }

    });
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: init(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text('Chat Page'),
            ),
            body: Chat(
              messages: messageList,
              onAttachmentPressed: _handleAttachmentPressed,
              onMessageTap: _handleMessageTap,
              onPreviewDataFetched: _handlePreviewDataFetched,
              onSendPressed: _handleSendPressed,
              showUserAvatars: true,
              showUserNames: true,
              user: _user,
              theme: const DefaultChatTheme(
                seenIcon: Text(
                  'read',
                  style: TextStyle(
                    fontSize: 10.0,
                  ),
                ),
              ),
            ),
          );
        } else {
          return CircularProgressIndicator(); // Zeigen Sie einen Ladeindikator an, während init() ausgeführt wird
        }
      },
    );
  }
}