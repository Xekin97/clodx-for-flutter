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

T getClod<T>(NormalClod<T> clod) {
  return clod.current;
}

T setClod<T>(NormalClod<T> clod, T value) {
  return clod.make(value);
}

T export<T>(NormalClod<T> clod) {
  return clod.current;
}

T pick<T>(PickClod<T> clod) {
  return clod.pick();
}

void make<T>(MakeClod<T> clod, T value) {
  clod.make(value);
}
