

import '../UpdateError.dart';
import '../UpdateInfo.dart';

abstract class ICheckAgent{
  void setInfo(UpdateInfo info);
  void setError(UpdateError error);
}