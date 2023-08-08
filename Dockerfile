# Use the official Nginx base image
FROM nginx:latest

# Install git to clone the GitHub repository
RUN apt-get update && \
    apt-get install -y git

# Copy the contents of your web app code into the existing /usr/share/nginx/html directory
COPY . /usr/share/nginx/html/
