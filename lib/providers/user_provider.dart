import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

part 'user_provider.g.dart';

@Riverpod(keepAlive: true)
class UserNotifier extends _$UserNotifier {
  @override
  Future<UserModel?> build() async => UserService.getUser();

  Future<void> saveUser(UserModel user) async {
    await UserService.saveUser(user);
    state = AsyncValue.data(user);
  }
}