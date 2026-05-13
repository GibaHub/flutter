class ApiConstants {
  static const String baseUrl = 'http://192.168.1.220:55443';
  static const String authEndpoint = '/api/oauth2/v1/token';
  static const String getClient = '/consulta/v1/cliente';
  static const String postPayment = '/cliente/v1/payments';
  static const String getNews = '/cliente/v1/news';
  static const String postNews = '/cliente/v1/news';
  static const String registerCustomer =
      '/appcometa/customers/cadastrousuariosapp';
  static const String resendToken = '/appcometa/customers/reenviotoken';
  static const String updatePassword =
      '/appcometa/customers/updateuserpasswords';
  static const String validateUser = '/appcometa/customers/validausuariosapp';
}
