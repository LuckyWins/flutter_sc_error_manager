library sc_error_manager;

import 'package:flutter/widgets.dart';
import 'package:screenshot/screenshot.dart';
import 'package:teledart/model.dart';
import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';

class SCErrorManager {
  static String _telegramBotApiKey;
  static int _chatId;
  static bool _withScreenshot;

  SCErrorManager({
    @required String telegramBotApiKey,
    @required int chatId,
    bool withScreenshot = false
  }) {
    _telegramBotApiKey ??= telegramBotApiKey;
    _chatId ??= chatId;
    _withScreenshot = withScreenshot ?? false;
  }

  static final TeleDart _teledart = TeleDart(Telegram(_telegramBotApiKey), Event());

  static final ScreenshotController screenshotController = ScreenshotController();

  /// [text] message text
  /// if app wrapped with ScErrorWidget, message send w/ screenshot
  static Future<Message> sendMessage(String text) async {
    try {
      var message = "$text";

      if (_withScreenshot) {
        var screenshot = await screenshotController.capture(
          // pixelRatio: 1.5
        );

        return _teledart.telegram.sendPhoto(
            _chatId,
            screenshot,
            caption: message
        );
      } else {
        return _teledart.telegram.sendMessage(
            _chatId,
            message
        );
      }
    } catch (error, _) {
      return Future.value(null);
    }
  }
}

class ScErrorWidget extends StatelessWidget {
  final Widget child;

  ScErrorWidget({
    @required String telegramBotApiKey,
    @required int chatId,
    @required this.child
  }) {
    SCErrorManager(
        telegramBotApiKey: telegramBotApiKey,
        chatId: chatId,
        withScreenshot: true
    );
  }

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: SCErrorManager.screenshotController,
      child: child,
    );
  }

}