/*
    Class is used to return Firebase Error Messages in German
 */
class FirebaseErrorMsg {
  /// Returns Firebase sign in exceptions in german language
  static String getSignInError(error) {
    var errorMessage;
    switch (error.code) {
      case "invalid-email":
        errorMessage =
            "Die angegebende E-Mail Adresse ist schlecht formatiert.";
        break;
      case "wrong-password":
        errorMessage = "Falsches Passwort";
        break;
      case "user-not-found":
        errorMessage = "Ein Account mit dieser E-Mail Adresse existiert nicht.";
        break;
      case "user-disabled":
        errorMessage = "Account mit dieser E-Mail Adresse wurde deaktiviert.";
        break;
      case "too-many-requests":
        errorMessage =
            "Zu viele Anfragen. Versuchen Sie es zu einem späteren Zeitpunkt erneut.";
        break;
      case "operation-not-allowed":
        errorMessage =
            "Das Einloggen über E-Mail und Passwort ist nicht erlaubt.";
        break;
      case "weak-password":
        errorMessage = "Das Passwort ist zu schwach.";
        break;
      case "email-already-in-use":
        errorMessage = "Email wird bereits verwendet";
        break;
      case "invalid-credential":
        errorMessage = "Your email is invalid";
        break;
      default:
        errorMessage =
            "Ein Fehler ist aufgetreten. Bitte überprüfen Sie Ihre Eingabe.";
    }
    return errorMessage;
  }
  /// Returns Firebase user Deletion exceptions in german language
  static String getDeleteUserError(error) {
    var errorMessage;
    switch (error.code) {
      case "requires-recent-login":
        errorMessage =
            "Diese Operation ist kritisch und benötigt eine aktuelle Authentifizierung. Loggen Sie sich erneut ein und wiederholen Sie die Anfrage";
        break;
      default:
        errorMessage =
            "Ein Fehler ist aufgetreten. Bitte überprüfen Sie Ihre Eingabe. " +
                error.toString();
    }
    return errorMessage;
  }
}
