FROM node:18-bullseye

# Install dependencies for Cypress
RUN apt-get update && apt-get install -y xvfb

# Set up a working directory
WORKDIR /app

# Copy package files first (for caching)
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application
COPY . .

CMD ["bash"]
