import 'package:chatview/chatview.dart';

class Data {
  static const profileImage =
      "https://raw.githubusercontent.com/SimformSolutionsPvtLtd/flutter_showcaseview/master/example/assets/simform.png";
  static final messageList = [
    Message(
      id: '1',
      message: "Hi!",
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      sendBy: '1', // userId of who sends the message
    ),
    Message(
      id: '2',
      message: "Hi!",
      createdAt: DateTime.now(),
      sendBy: '2',
    ),
    Message(
      id: '3',
      message: "We can meet?I am free",
      createdAt: DateTime.now(),
      sendBy: '1',
    ),
    Message(
      id: '4',
      message: "Can you write the time and place of the meeting?",
      createdAt: DateTime.now(),
      sendBy: '1',
    ),
    Message(
      id: '5',
      message: "That's fine",
      createdAt: DateTime.now(),
      sendBy: '2',
      reaction: Reaction(reactions: ['\u{2764}'], reactedUserIds: ['1']),
    ),
    Message(
      id: '6',
      message: "When to go ?",
      createdAt: DateTime.now(),
      sendBy: '3',
    ),
    Message(
      id: '7',
      message: "I guess Simform will reply",
      createdAt: DateTime.now(),
      sendBy: '4',
    ),
    Message(
      id: '8',
      message: "https://bit.ly/3JHS2Wl",
      createdAt: DateTime.now(),
      sendBy: '2',
      reaction: Reaction(
        reactions: ['\u{2764}', '\u{1F44D}', '\u{1F44D}'],
        reactedUserIds: ['2', '3', '4'],
      ),
      replyMessage: const ReplyMessage(
        message: "Can you write the time and place of the meeting?",
        replyTo: '1',
        replyBy: '2',
        messageId: '4',
      ),
    ),
    Message(
      id: '9',
      message: "Done",
      createdAt: DateTime.now(),
      sendBy: '1',
      reaction: Reaction(
        reactions: [
          '\u{2764}',
          '\u{2764}',
          '\u{2764}',
        ],
        reactedUserIds: ['2', '3', '4'],
      ),
    ),
    Message(
      id: '10',
      message: "Thank you!!",
      createdAt: DateTime.now(),
      sendBy: '1',
      reaction: Reaction(
        reactions: ['\u{2764}', '\u{2764}', '\u{2764}', '\u{2764}'],
        reactedUserIds: ['2', '4', '3', '1'],
      ),
    ),
    Message(
      id: '11',
      message: "https://miro.medium.com/max/1000/0*s7of7kWnf9fDg4XM.jpeg",
      createdAt: DateTime.now(),
      messageType: MessageType.image,
      sendBy: '1',
      reaction: Reaction(reactions: ['😄'], reactedUserIds: ['2']),
    ),
    Message(
      id: '12',
      message: '''
ああああ
```
AAAAAAAAddddddddddddddddddddddddddaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
```

https://www.youtube.com/watch?v=aKLq-M71ZB0&list=PLT0aFqMLFiVUTdjjz84MgLJurDB417Vrx&index=23
      ''',
      createdAt: DateTime.now(),
      sendBy: '2',
      messageType: MessageType.custom, // TODO
    ),
    Message(
      id: '13',
      message:
          'https://www.youtube.com/watch?v=aKLq-M71ZB0&list=PLT0aFqMLFiVUTdjjz84MgLJurDB417Vrx&index=23',
      createdAt: DateTime.now(),
      sendBy: '2',
      messageType: MessageType.custom, // TODO
    ),

    Message(
      id: '14',
      message: 'おはようございます',
      createdAt: DateTime.now(),
      sendBy: '2',
      messageType: MessageType.custom, // TODO
    ),

    Message(
      id: '15',
      message: '''
おはようございます

```
    Message(
      title: '',
      id: '14',
      message: 'おはようございます',
      createdAt: DateTime.now(),
      sendBy: '2',
      status: MessageStatus.read,
      messageType: MessageType.custom, // TODO
    ),
```

`あああ`

''',
      createdAt: DateTime.now(),
      sendBy: '2',
      messageType: MessageType.custom, // TODO
    ),

    Message(
      id: '16',
      message: '''
おはようご`あああ`ざいます`あああ`**あああ**

```javascript
if (true) {
    console.log('AA');
  }
```

`あああ`

''',
      createdAt: DateTime.now(),
      sendBy: '2',
      messageType: MessageType.custom, // TODO
      reaction: Reaction(
        reactions: ['\u{2764}', '😃', '\u{2764}', '\u{2764}'],
        reactedUserIds: ['2', '4', '3', '1'],
      ),
    ),
    // Message(
    //   id: '13',
    //   message:
    //       "https://www.youtube.com/watch?v=aKLq-M71ZB0&list=PLT0aFqMLFiVUTdjjz84MgLJurDB417Vrx&index=23",
    //   createdAt: DateTime.now(),
    //   sendBy: '2',
    //   reaction: Reaction(
    //     reactions: ['\u{2764}', '\u{1F44D}', '\u{1F44D}'],
    //     reactedUserIds: ['2', '3', '4'],
    //   ),
    //   status: MessageStatus.read,
    //   messageType: MessageType.custom,
    // ),
    // Message(
    //   id: '14',
    //   message:
    //       "https://www.youtube.com/watch?v=aKLq-M71ZB0&list=PLT0aFqMLFiVUTdjjz84MgLJurDB417Vrx&index=23",
    //   createdAt: DateTime.now(),
    //   sendBy: '2',
    //   reaction: Reaction(
    //     reactions: ['\u{2764}', '\u{1F44D}', '\u{1F44D}'],
    //     reactedUserIds: ['2', '3', '4'],
    //   ),
    //   status: MessageStatus.read,
    //   messageType: MessageType.text,
    // ),
  ];
}
