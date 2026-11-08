import '../../core/exceptions/app_exception.dart';

/// Converte JSON em model e transforma dados malformados em [AppException].
T converterJson<T>(
  Map<String, dynamic> json,
  T Function(Map<String, dynamic>) fromJson,
) {
  try {
    return fromJson(json);
  } on FormatException {
    throw AppException.dados();
  } on TypeError {
    throw AppException.dados();
  }
}
