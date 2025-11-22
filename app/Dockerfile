
FROM python:3.10-slim

# Set the working directory inside the container
WORKDIR /app

# Copy requirements file first (to use Docker layer caching)
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY . .

# Expose the Flask port
EXPOSE 5000

# Run the Flask application
CMD ["python", "app.py"]