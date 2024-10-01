from flask import Flask, request, send_from_directory, jsonify
import os
import fiona
import json
from shapely.geometry import shape, mapping
from fiona.crs import from_epsg

app = Flask(__name__)
UPLOAD_FOLDER = './uploads'
OUTPUT_FOLDER = './outputs'

# Garantir que as pastas de upload e output existam
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(OUTPUT_FOLDER, exist_ok=True)

@app.route('/convert', methods=['POST'])
def convert_geojson_to_shapefile():
    if 'file' not in request.files:
        return jsonify({"error": "No file part"}), 400

    file = request.files['file']
    if file.filename == '':
        return jsonify({"error": "No selected file"}), 400

    if file:
        geojson_path = os.path.join(UPLOAD_FOLDER, file.filename)
        file.save(geojson_path)

        shapefile_base = 'output'
        shapefile_path = os.path.join(OUTPUT_FOLDER, shapefile_base + '.shp')

        # Lê o GeoJSON e escreve como Shapefile
        with open(geojson_path) as src:
            geojson = json.load(src)
            schema = {
                'geometry': 'LineString',
                'properties': {'id': 'int'},
            }

            with fiona.open(shapefile_path, 'w', driver='ESRI Shapefile', schema=schema, crs=from_epsg(4326)) as shp:
                for i, feature in enumerate(geojson['features']):
                    geom = shape(feature['geometry'])
                    shp.write({
                        'geometry': mapping(geom),
                        'properties': {'id': i},
                    })

        # Listar os arquivos do Shapefile a serem retornados
        shapefile_files = [
            shapefile_base + '.shp',
            shapefile_base + '.shx',
            shapefile_base + '.dbf',
            shapefile_base + '.prj'
        ]

        # Enviar os arquivos do Shapefile individualmente
        return jsonify({"files": shapefile_files}), 200

@app.route('/download/<filename>', methods=['GET'])
def download_file(filename):
    return send_from_directory(OUTPUT_FOLDER, filename)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
