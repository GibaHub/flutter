import '../models/titulos_model.dart';
import 'api_service.dart';

class TitulosService {
  final ApiService _apiService = ApiService();

  Future<TitulosResponseModel> getTitulos() async {
    try {
      final response = await _apiService.getTitulosPagarReceber();
      return TitulosResponseModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao buscar títulos: $e');
    }
  }

  Future<List<TitulosReceberModel>> getTitulosReceber({String? filial}) async {
    try {
      final titulos = await getTitulos();
      var titulosReceber = titulos.titulosReceber;
      
      if (filial != null && filial.isNotEmpty) {
        titulosReceber = titulosReceber
            .where((titulo) => titulo.filial.toLowerCase().contains(filial.toLowerCase()))
            .toList();
      }
      
      return titulosReceber;
    } catch (e) {
      throw Exception('Erro ao buscar títulos a receber: $e');
    }
  }

  Future<List<TitulosPagarModel>> getTitulosPagar({String? filial}) async {
    try {
      final titulos = await getTitulos();
      var titulosPagar = titulos.titulosPagar;
      
      if (filial != null && filial.isNotEmpty) {
        titulosPagar = titulosPagar
            .where((titulo) => titulo.filial.toLowerCase().contains(filial.toLowerCase()))
            .toList();
      }
      
      return titulosPagar;
    } catch (e) {
      throw Exception('Erro ao buscar títulos a pagar: $e');
    }
  }
}