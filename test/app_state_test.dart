import 'package:flutter_test/flutter_test.dart';
import 'package:sign_voice/core/app_state.dart';

void main() {
  group('AppState.bindAccount', () {
    test('clears local data when switching accounts', () {
      final state = AppState();
      state.bindAccount(
        'first-user',
        asGuest: false,
        displayName: 'First User',
        userEmail: 'first@example.com',
      );
      state.saveConversation(
        'A conversation',
        ConversationDirection.signToSpeech,
      );
      state.addWord('Xin chào');
      state.toggleSign('Xin chào');

      state.bindAccount(
        'second-user',
        asGuest: false,
        displayName: 'Second User',
        userEmail: 'second@example.com',
      );

      expect(state.history, isEmpty);
      expect(state.sentence, isEmpty);
      expect(state.favorites, isEmpty);
      expect(state.name, 'Second User');
      expect(state.email, 'second@example.com');
    });

    test('preserves local data when the same account is rebound', () {
      final state = AppState();
      state.bindAccount('user', asGuest: false);
      state.saveConversation(
        'A conversation',
        ConversationDirection.signToSpeech,
      );

      state.bindAccount(
        'user',
        asGuest: false,
        displayName: 'Updated Name',
      );

      expect(state.history, hasLength(1));
      expect(state.name, 'Updated Name');
    });
  });
}
