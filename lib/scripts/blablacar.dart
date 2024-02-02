import 'package:http/http.dart' as http;

void main() async {
  // URL desejada
  String url =
      'https://edge.blablacar.com.br/trip/search/v7?from_place_id=eyJpIjoiQ2hJSm9jQjh6TEVNeHBRUnR6dGh0OEJ2R0o0IiwicCI6MSwidiI6MSwidCI6W119&to_place_id=eyJpIjoiQ2hJSjBXR2tnNEZFenBRUnJsc3pfd2hMcVpzIiwicCI6MSwidiI6MSwidCI6W119&departure_date=2024-02-05&transport_type=carpooling&passenger_gender=MALE&search_uuid=129aa194-2b63-4fa0-b794-e18fb22000d6&requested_seats=1&search_origin=HOME';

  // Realizando a requisição GET
  try {
    final response = await http.get(headers: {
      "accept": "application/json",
      "accept-language": "pt-BR",
      "authorization": "Bearer d2fdf4fa-5f5e-485f-8a30-e4b6a1e235d1",
      "content-type": "application/json",
      "x-client": "SPA|1.0.0",
      "x-correlation-id": "3c921b1d-a34e-4a17-90e4-3114488f84d9",
      "x-currency": "BRL",
      "x-locale": "pt_BR",
      "x-visitor-id": "3941b6f3-7d24-4efc-98ed-179ca49514cc"
    }, Uri.parse(url));

    // Verificando se a requisição foi bem-sucedida (código 200)
    if (response.statusCode == 200) {
      // Convertendo a resposta para uma string
      String responseBody = response.body;

      // Faça algo com os dados recebidos, por exemplo, imprima no console
      print('Resposta da API: $responseBody');
    } else {
      // Se a requisição não foi bem-sucedida, imprima o código de status
      print('Erro na requisição: ${response.statusCode}');
    }
  } catch (e) {
    // Tratando exceções, como falha na conexão
    print('Erro durante a requisição: $e');
  }
}
