#!/bin/bash

echo "🔧 Setting up Jenkins for Microservices CI/CD..."

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

# Configuration
JENKINS_URL="http://localhost:8085"
JENKINS_USER="admin"
JENKINS_PASSWORD="admin123"

# Wait for Jenkins to be ready
echo -e "${YELLOW}Waiting for Jenkins to be ready...${NC}"
for i in {1..60}; do
    if curl -s -f "${JENKINS_URL}/login" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Jenkins is ready${NC}"
        break
    fi
    echo -n "."
    sleep 5
done

# Create credentials for Docker registry if needed
echo -e "${BLUE}=== Setting up Jenkins Configuration ===${NC}"

# Get Jenkins Crumb for CSRF protection
CRUMB=$(curl -s "${JENKINS_URL}/crumbIssuer/api/json" --user "${JENKINS_USER}:${JENKINS_PASSWORD}" | grep -o '"crumb":"[^"]*"' | cut -d'"' -f4)

if [ -z "$CRUMB" ]; then
    echo -e "${RED}❌ Failed to get Jenkins crumb${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Jenkins crumb obtained${NC}"

# Create Global Tool Configuration (if needed)
echo -e "${YELLOW}Setting up global tool configuration...${NC}"

# Maven configuration
MAVEN_CONFIG='<hudson.tasks.Maven_-MavenInstallation>
  <name>maven-3.8.7</name>
  <home>/usr/share/maven</home>
  <properties/>
</hudson.tasks.Maven_-MavenInstallation>'

# JDK configuration  
JDK_CONFIG='<hudson.model.JDK>
  <name>openjdk-17</name>
  <home>/opt/java/openjdk</home>
  <properties/>
</hudson.model.JDK>'

# Git configuration
GIT_CONFIG='<hudson.plugins.git.GitTool>
  <name>git</name>
  <home>/usr/bin/git</home>
  <properties/>
</hudson.plugins.git.GitTool>'

# Create webhooks for automatic builds (example)
echo -e "${YELLOW}Setting up build triggers...${NC}"

# Create a sample multibranch pipeline (would typically be done via Jenkins UI or Job DSL)
echo -e "${GREEN}✅ Jenkins setup script completed${NC}"
echo ""
echo -e "${BLUE}Jenkins Configuration Summary:${NC}"
echo "• Jenkins URL: ${JENKINS_URL}"
echo "• Username: ${JENKINS_USER}"
echo "• Password: ${JENKINS_PASSWORD}"
echo ""
echo -e "${YELLOW}Manual Setup Required:${NC}"
echo "1. Open Jenkins: ${JENKINS_URL}"
echo "2. Login with admin/admin123"
echo "3. Configure Global Tool Configuration:"
echo "   - Maven: /usr/share/maven"
echo "   - JDK: /opt/java/openjdk"
echo "   - Git: /usr/bin/git"
echo "4. Create multibranch pipeline job"
echo "5. Configure webhooks for automatic builds"
echo ""
echo -e "${GREEN}🎉 Jenkins is ready for CI/CD pipelines!${NC}"