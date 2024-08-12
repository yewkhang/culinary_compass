from flask import Flask, request, jsonify
from flask_cors import CORS
import pandas as pd

app = Flask(__name__)
CORS(app)

def capitalize_first_letter(s):
    return s.title()

@app.route('/process_data', methods=['POST'])
def process_data():
    data = request.json
    
    # Convert JSON data to DataFrame
    df = pd.DataFrame(data)

    # Convert dish names to title case
    df['Name'] = df['Name'].apply(capitalize_first_letter)

    # Calculate average rating for each location
    location_avg_rating = df.groupby('Location')['Rating'].mean().reset_index()
    location_avg_rating.columns = ['Location', 'average_rating']

    # Group by location and dish name to aggregate tags and retain dish names
    grouped = df.groupby(['Location', 'Name']).agg({
        'Tags': lambda tags: list(set([tag for sublist in tags for tag in sublist]))
    }).reset_index()

    # Merge the average rating back to the grouped data
    grouped = grouped.merge(location_avg_rating, on='Location', how='left')

    # Prepare result in the required format
    result = []
    for location, group in grouped.groupby('Location'):
        dishes = []
        for _, row in group.iterrows():
            dishes.append({
                'Name': row['Name'],
                'Tags': row['Tags']
            })
        result.append({
            'Location': location,
            'dishes': dishes,
            'average_rating': row['average_rating']
        })

    return jsonify(result)

if __name__ == '__main__':
    app.run(debug=True)