import sys
import os
import io
from flask import Flask, request, jsonify
import firestoreDB as db
from dotenv import load_dotenv
from AI_Agents.Conversable_Agent import main as agent
from emailservice import send_email
from DataTypes import Item
import uuid
import AI_Agents.Seach_Agent as SearchAgent
import AI_Agents.Product_Selection_Agent as ProductSelectionAgent
import AI_Agents.Data_Extract_Agent as DataExtractAgent
import AI_Agents.Data_frame_creator_Agent as DataFrameCreatorAgent
from flask_cors import CORS
load_dotenv()

# Example request data
# {
#     "item_name": "Tomato Sauce Bottle", 
#     "custom_domains": [""],
#     "tags": ["Tomato","Quality"],
#     "location":[6.943749,79.982535]
# }

app = Flask(__name__)
CORS(app)

def csv_to_list_firebase(csv):
    """
    Converts a CSV file containing product data into a list of Item objects.
    
    Args:
        csv_file_path (str): Path to the CSV file
        
    Returns:
        list: List of Item objects containing product information
    """
    df = csv
    df = df.fillna('')  # Replace NaN values with empty strings
    items_list = []
    for _, row in df.iterrows():
        item = Item(
            name=row['product_name'],
            price=float(row['price']), 
            description=row['description'],
            link=row['product_url'],
            rate=float(row['product_rating']) if row['product_rating'] != '' else 0,
            image_link=row['image'],
            currency=row['currency']
        )
        # Only add items that have at least one of: name, price, or link
        if item.name != '' or item.price !='' or item.link != '':
            items_list.append(item)
    return items_list

@app.route('/api/recommend', methods=['POST'])
def recommend():
    try:
        print("\n<====================>")
        print("RECOMMENDATION REQUEST")
        print("<====================>")

        request_id = str(uuid.uuid4())
        
        # Get request data and create machine customer
        print("Getting request data...")
        request_data = request.get_json()
        if (request_data["custom_domains"] == []):
            request_data["custom_domains"] = None
        print(f"Request data received")
        print("Item Name:", request_data["item_name"])
        print("Custom Domains:", request_data["custom_domains"])
        print("Tags:", request_data["tags"])
        print("Location:", request_data["location"])        

        database1 = db.FirestoreDB()
        state,csv_file = database1.check_csv(request_data['item_name'])
        
        print("Check csv data")
        if state:
            print("Found existing CSV file for this item and country...")
        else:
            print(f"Agent workflow started for request {request_id}...")
            # Run the agent - output will only go to file
            agent(request_data["item_name"], 
                  request_data["custom_domains"], 
                  request_data["tags"],
                  request_data["location"],
                  request_id)

            print("Agent workflow completed...")
            state,csv_file = database1.check_csv(request_data['item_name'])
                
        # Get items from CSV and create model
        print("\nLoading items from CSV...")
        # items = ic.csv_to_list(os.path.join("Final_products", csv_filename))
        items = csv_to_list_firebase(csv_file)
        print(items)
        print(f"Loaded {len(items)} items")
        
        print("Sending email...")
        print(send_email("Akindu Himan", "akinduhiman2@gmail.com", items, request_data["item_name"]))
        return jsonify({"status": "success and email sent"})
    
    except Exception as e:
        print(f"Error during model execution: {str(e)}")
        return jsonify({"status": "error", "message": str(e)}), 500
    
@app.route('/api/health', methods=['GET']) 
def health(): 
    print("got the request")
    return jsonify({"status": "healthy"}),200

if __name__ == '__main__':
    app.run(host="0.0.0.0",debug=False, port=8000, threaded=True, use_reloader=False)
