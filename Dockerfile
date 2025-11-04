# ================================
# Stage 1 — Build Environment
# ================================
FROM node:18-alpine AS build

# Set working directory
WORKDIR /app

# Copy package files (if you have them)
COPY package*.json ./

# Install dependencies
RUN npm install 

# Copy the rest of the app source
COPY . .

# ================================
# Stage 2 — Runtime Environment
# ================================
FROM node:18-alpine

WORKDIR /app

# Copy only necessary files from build stage
COPY --from=build /app /app

# Expose the port your app runs on
EXPOSE 3001

# Start the Node.js server
CMD ["node", "app.js"]

