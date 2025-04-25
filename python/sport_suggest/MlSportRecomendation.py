import os
from flask import Flask, request, jsonify
from flask_cors import CORS
from dotenv import load_dotenv
import pandas as pd
from sklearn.neighbors import NearestNeighbors

load_dotenv()

app = Flask(__name__)
CORS(app)

@app.route('/api/recommendSports', methods=['POST'])
def recommend():
    try:
        # Parse incoming JSON
        data = request.get_json()
        print("Received data:", data)  # Log incoming data
        
        required_scores = [
            'enduranceScore', 'strengthScore', 'powerScore', 'speedScore',
            'agilityScore', 'flexibilityScore', 'nervousSystemScore',
            'durabilityScore', 'handlingScore'
        ]

        # Check for missing values
        missing = [score for score in required_scores if data.get(score) is None]
        if missing:
            print("Missing required scores:", missing)  # Log missing scores
            return jsonify({"error": f"Missing required scores: {', '.join(missing)}"}), 400

        # Extract input vector
        input_vector = [data[score] for score in required_scores]
        print("Input vector for KNN:", input_vector)  # Log input vector

        # Load CSV data
        csv_path = os.getenv("CSV_PATH", "python/sport_suggest/recomendation_csv.csv")
        if not os.path.exists(csv_path):
            print("CSV file not found at:", csv_path)  # Log CSV path issue
            return jsonify({"error": f"CSV file not found at: {csv_path}"}), 500

        df = pd.read_csv(csv_path)
        print("CSV data loaded successfully.")  # Log successful CSV load

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
            print("CSV file is missing one or more required columns.")  # Log column validation issue
            return jsonify({"error": "CSV file is missing one or more required columns"}), 500

        # Rename columns to match required_scores
        df = df.rename(columns=column_mapping)
        if df.empty:
            print("CSV file is empty.")  # Log empty CSV issue
            return jsonify({"error": "CSV file is empty"}), 500

        # Extract training features
        X = df[required_scores].values

        # Fit KNN on original data
        knn = NearestNeighbors(n_neighbors=3)
        knn.fit(X)
        print("KNN model trained successfully.")  # Log successful KNN training

        # Find nearest neighbors for input vector
        distances, indices = knn.kneighbors([input_vector])
        nearest_indices = indices[0]
        print("Nearest indices found:", nearest_indices)  # Log nearest indices
        print("Distances to nearest neighbors:", distances[0])  # Log distances to nearest neighbors

        # Return top 3 recommended sports
        recommended_sports = df.iloc[nearest_indices]['SPORT'].tolist()
        print("Recommended sports:", recommended_sports) 
        return jsonify({"recommended_sports": recommended_sports})

    except Exception as e:
        print("Internal server error:", str(e))  # Log internal server error
        return jsonify({"error": f"Internal server error: {str(e)}"}), 500

if __name__ == '__main__':
    app.run(host="0.0.0.0",debug=False, port=9000, threaded=True, use_reloader=False)
