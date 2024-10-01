import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:file_selector/file_selector.dart';

class GeoJsonToShapefileService {
  Future<void> convertGeoJsonToShapefile(String geoJsonString) async {
    try {
      // Enviar o arquivo GeoJSON para o serviço Flask
      var request = http.MultipartRequest('POST', Uri.parse('http://localhost:5000/convert'));
      request.files.add(http.MultipartFile.fromString('file', geoJsonString, filename: 'polyline.geojson'));

      var response = await request.send();

      if (response.statusCode == 200) {
        // Lê a resposta JSON contendo os nomes dos arquivos
        String responseBody = await response.stream.bytesToString();
        Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
        List<String> files = List<String>.from(jsonResponse['files']);

        // Selecionar o diretório onde os arquivos serão salvos
        final String? selectedDirectory = await getDirectoryPath();
        if (selectedDirectory == null) {
          // O usuário cancelou a seleção do diretório
          return;
        }

        // Baixar e salvar cada arquivo individualmente
        for (String fileName in files) {
          var fileResponse = await http.get(Uri.parse('http://localhost:5000/download/$fileName'));

          if (fileResponse.statusCode == 200) {
            final String outputFilePath = '$selectedDirectory/$fileName';
            final File outputFile = File(outputFilePath);
            await outputFile.writeAsBytes(fileResponse.bodyBytes);
            print('Arquivo salvo em: $outputFilePath');
          } else {
            print('Erro ao baixar o arquivo: $fileName');
          }
        }
      } else {
        print('Erro ao converter GeoJSON para Shapefile: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Erro: $e');
    }
  }
}
