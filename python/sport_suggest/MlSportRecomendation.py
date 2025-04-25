import os
from flask import Flask, request, jsonify
from flask_cors import CORS
from dotenv import load_dotenv
import pandas as pd
from sklearn.neighbors import NearestNeighbors

load_dotenv()

app = Flask(__name__)
CORS(app)

@app.route('/api/recommend', methods=['POST'])
def recommend():
    try:
        # Parse incoming JSON
        data = request.get_json()
        
        required_scores = [
            'enduranceScore', 'strengthScore', 'powerScore', 'speedScore',
            'agilityScore', 'flexibilityScore', 'nervousSystemScore',
            'durabilityScore', 'handlingScore'
        ]

        # Check for missing values
        missing = [score for score in required_scores if data.get(score) is None]
        if missing:
            return jsonify({"error": f"Missing required scores: {', '.join(missing)}"}), 400

        # Extract input vector
        input_vector = [data[score] for score in required_scores]

        # Load CSV data
        csv_path = os.getenv("CSV_PATH", "recomendation_csv.csv")
        if not os.path.exists(csv_path):
            return jsonify({"error": f"CSV file not found at: {csv_path}"}), 500

        df = pd.read_csv(csv_path)

        # Validate required columns
        column_mapping = {
            'END': 'enduranceScore',
            'STR': 'strengthScore',
            'PWR': 'powerScore',
            'SPD': 'speedScore',
            'AGI': 'agilityScore',
            'FLX': 'flexibilityScore',
            'NER': 'nervousSystemScore',
            'DUR': 'durabilityScore',
            'HAN': 'handlingScore'
        }

        # Check if all required columns are present in the CSV
        if not all(col in df.columns for col in column_mapping.keys()) or 'SPORT' not in df.columns:
            return jsonify({"error": "CSV file is missing one or more required columns"}), 500

        # Rename columns to match required_scores
        df = df.rename(columns=column_mapping)
        if df.empty:
            return jsonify({"error": "CSV file is empty"}), 500

        # Fit KNN
        try:
            knn = NearestNeighbors(n_neighbors=3)  # Set to 3 for top 3 recommendations
            knn.fit(df[required_scores])
        except Exception as e:
            return jsonify({"error": f"KNN training failed: {str(e)}"}), 500

        # Predict nearest neighbors
        distances, indices = knn.kneighbors([input_vector])
        nearest_indices = indices[0]

        # Return top 3 recommended sports
        recommended_sports = df.iloc[nearest_indices]['SPORT'].tolist()
        return jsonify({"recommended_sports": recommended_sports})

    except Exception as e:
        return jsonify({"error": f"Internal server error: {str(e)}"}), 500


if __name__ == '__main__':
    port = int(os.getenv("PORT", 9000))
    print(f"Server running on http://localhost:{port}")
    app.run(debug=True, port=port)
