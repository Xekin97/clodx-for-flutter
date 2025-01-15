import './main.dart';

NormalClod<T> clod<T>(T value) {
  return NormalClod<T>(ClodNormalValue(value));
}

PickClod<T> pickClod<T>(Picker<T> value) {
  return PickClod<T>(ClodPickValue(value));
}

MakeClod<T> makeClod<T>(Maker<T> value) {
  return MakeClod<T>(ClodMakeValue(value));
}
