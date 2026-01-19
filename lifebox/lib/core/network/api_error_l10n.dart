import 'package:lifebox/l10n/app_localizations.dart';
import 'api_exception.dart';

extension ApiErrorL10n on ApiErrorKey {
  String message(AppLocalizations l10n) {
    switch (this) {
      case ApiErrorKey.invalidRequest:
        return l10n.badRequest;
      case ApiErrorKey.unauthorized:
        return l10n.unauthorized;
      case ApiErrorKey.forbidden:
        return l10n.forbidden;
      case ApiErrorKey.notFound:
        return l10n.notFound;
      case ApiErrorKey.conflict:
        return l10n.conflict;
      case ApiErrorKey.validationError:
        return l10n.validationError;
      case ApiErrorKey.serverError:
        return l10n.serverError;
      case ApiErrorKey.unknown:
        return l10n.unknown;
    }
  }
}
