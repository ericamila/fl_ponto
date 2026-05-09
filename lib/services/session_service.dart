class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  String? _token;
  String? _name;

  String? get token => _token;
  String? get name => _name;

  void setSession(String token, String? name) {
    _token = token;
    _name = name;
  }

  void clear() {
    _token = null;
    _name = null;
  }

  bool get isAuthenticated => _token != null;
}
