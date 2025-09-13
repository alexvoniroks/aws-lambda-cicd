#!/bin/bash

# AWS Lambda Packaging Script
# This script packages Lambda functions for deployment
# Usage: ./scripts/package.sh [function-name] [environment]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
FUNCTION_NAME=${1:-"hello-world"}
ENVIRONMENT=${2:-"dev"}
BUILD_DIR="builds"
SRC_DIR="src"
PACKAGE_NAME="${FUNCTION_NAME}-${ENVIRONMENT}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo -e "${BLUE}🚀 AWS Lambda Packaging Script${NC}"
echo "================================="
echo -e "${YELLOW}Function:${NC} $FUNCTION_NAME"
echo -e "${YELLOW}Environment:${NC} $ENVIRONMENT"
echo -e "${YELLOW}Timestamp:${NC} $TIMESTAMP"
echo ""

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check prerequisites
check_prerequisites() {
    echo "🔍 Checking prerequisites..."
    
    # Check if source directory exists
    if [ ! -d "$SRC_DIR" ]; then
        print_error "Source directory '$SRC_DIR' not found!"
        exit 1
    fi
    
    # Check if lambda function file exists
    if [ ! -f "$SRC_DIR/lambda_function.py" ]; then
        print_error "Lambda function file '$SRC_DIR/lambda_function.py' not found!"
        exit 1
    fi
    
    # Check if Python is installed
    if ! command -v python3 &> /dev/null; then
        print_error "Python 3 is not installed or not in PATH"
        exit 1
    fi
    
    # Check if zip is available
    if ! command -v zip &> /dev/null; then
        print_error "zip command is not available"
        exit 1
    fi
    
    print_status "Prerequisites check passed"
}

# Clean up previous builds
cleanup_builds() {
    echo "🧹 Cleaning up previous builds..."
    
    if [ -d "$BUILD_DIR" ]; then
        rm -rf "$BUILD_DIR"
        print_status "Removed existing build directory"
    fi
    
    mkdir -p "$BUILD_DIR"
    print_status "Created fresh build directory"
}

# Install Python dependencies
install_dependencies() {
    echo "📦 Installing Python dependencies..."
    
    # Create temporary directory for dependencies
    TEMP_DIR="$BUILD_DIR/temp_deps"
    mkdir -p "$TEMP_DIR"
    
    if [ -f "$SRC_DIR/requirements.txt" ]; then
        # Check if requirements.txt has content
        if [ -s "$SRC_DIR/requirements.txt" ]; then
            print_status "Found requirements.txt with dependencies"
            
            # Install dependencies to temporary directory
            pip3 install -r "$SRC_DIR/requirements.txt" -t "$TEMP_DIR" --no-cache-dir
            
            # Remove unnecessary files to reduce package size
            find "$TEMP_DIR" -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
            find "$TEMP_DIR" -type f -name "*.pyc" -delete 2>/dev/null || true
            find "$TEMP_DIR" -type f -name "*.pyo" -delete 2>/dev/null || true
            find "$TEMP_DIR" -type d -name "*.dist-info" -exec rm -rf {} + 2>/dev/null || true
            find "$TEMP_DIR" -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true
            
            print_status "Dependencies installed and cleaned"
        else
            print_warning "requirements.txt is empty, skipping dependency installation"
        fi
    else
        print_warning "No requirements.txt found, skipping dependency installation"
    fi
}

# Package Lambda function
package_function() {
    echo "📦 Packaging Lambda function..."
    
    PACKAGE_DIR="$BUILD_DIR/$PACKAGE_NAME"
    mkdir -p "$PACKAGE_DIR"
    
    # Copy source files
    echo "📂 Copying source files..."
    cp -r "$SRC_DIR"/* "$PACKAGE_DIR/"
    
    # Remove test files and unnecessary directories
    if [ -d "$PACKAGE_DIR/tests" ]; then
        rm -rf "$PACKAGE_DIR/tests"
        print_status "Removed test directory from package"
    fi
    
    # Copy dependencies if they exist
    TEMP_DIR="$BUILD_DIR/temp_deps"
    if [ -d "$TEMP_DIR" ] && [ "$(ls -A $TEMP_DIR)" ]; then
        echo "📚 Adding dependencies to package..."
        cp -r "$TEMP_DIR"/* "$PACKAGE_DIR/"
        print_status "Dependencies added to package"
    fi
    
    # Create the ZIP file
    ZIP_FILE="$BUILD_DIR/${PACKAGE_NAME}_${TIMESTAMP}.zip"
    echo "🗜️  Creating ZIP archive..."
    
    cd "$PACKAGE_DIR"
    zip -r "../$(basename $ZIP_FILE)" . -x "*.pyc" "*/__pycache__/*" "*/tests/*" > /dev/null
    cd - > /dev/null
    
    # Create a latest symlink
    LATEST_ZIP="$BUILD_DIR/${PACKAGE_NAME}_latest.zip"
    ln -sf "$(basename $ZIP_FILE)" "$LATEST_ZIP"
    
    print_status "Package created: $ZIP_FILE"
    print_status "Latest package link: $LATEST_ZIP"
}

# Validate package
validate_package() {
    echo "🔍 Validating package..."
    
    ZIP_FILE="$BUILD_DIR/${PACKAGE_NAME}_${TIMESTAMP}.zip"
    
    # Check if ZIP file exists and is not empty
    if [ ! -f "$ZIP_FILE" ]; then
        print_error "Package file not found: $ZIP_FILE"
        exit 1
    fi
    
    if [ ! -s "$ZIP_FILE" ]; then
        print_error "Package file is empty: $ZIP_FILE"
        exit 1
    fi
    
    # Display package contents
    echo "📋 Package contents:"
    unzip -l "$ZIP_FILE" | head -20
    
    # Check package size
    SIZE=$(stat -f%z "$ZIP_FILE" 2>/dev/null || stat -c%s "$ZIP_FILE" 2>/dev/null)
    SIZE_MB=$((SIZE / 1024 / 1024))
    
    echo ""
    echo -e "${BLUE}📊 Package Statistics:${NC}"
    echo "  Size: $SIZE bytes ($SIZE_MB MB)"
    echo "  Files: $(unzip -l "$ZIP_FILE" | grep -c "^  [0-9]")"
    
    # Check if package is too large (Lambda limit is 50MB zipped, 250MB unzipped)
    if [ $SIZE_MB -gt 45 ]; then
        print_warning "Package size ($SIZE_MB MB) is approaching Lambda limit (50MB)"
        print_warning "Consider optimizing dependencies or using Lambda Layers"
    else
        print_status "Package size is within limits"
    fi
}

# Upload to S3 (optional)
upload_to_s3() {
    if [ "$UPLOAD_TO_S3" = "true" ]; then
        echo "☁️ Uploading to S3..."
        
        if [ -z "$S3_BUCKET" ]; then
            print_error "S3_BUCKET environment variable not set"
            exit 1
        fi
        
        ZIP_FILE="$BUILD_DIR/${PACKAGE_NAME}_${TIMESTAMP}.zip"
        S3_KEY="lambda-packages/$FUNCTION_NAME/$(basename $ZIP_FILE)"
        
        if command -v aws &> /dev/null; then
            aws s3 cp "$ZIP_FILE" "s3://$S3_BUCKET/$S3_KEY"
            print_status "Package uploaded to s3://$S3_BUCKET/$S3_KEY"
        else
            print_error "AWS CLI not found. Please install AWS CLI to upload to S3"
            exit 1
        fi
    fi
}

# Test package locally (optional)
test_package() {
    if [ "$RUN_TESTS" = "true" ]; then
        echo "🧪 Testing package locally..."
        
        # Create test event
        TEST_EVENT='{"test": "data", "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}'
        
        # Extract package to temp directory for testing
        TEST_DIR="$BUILD_DIR/test_extract"
        mkdir -p "$TEST_DIR"
        
        ZIP_FILE="$BUILD_DIR/${PACKAGE_NAME}_${TIMESTAMP}.zip"
        unzip -q "$ZIP_FILE" -d "$TEST_DIR"
        
        # Try to import the lambda function
        cd "$TEST_DIR"
        if python3 -c "import lambda_function; print('✅ Lambda function imports successfully')" 2>/dev/null; then
            print_status "Package validation successful"
        else
            print_error "Package validation failed - lambda function cannot be imported"
            cd - > /dev/null
            exit 1
        fi
        
        cd - > /dev/null
        rm -rf "$TEST_DIR"
    fi
}

# Generate deployment info
generate_deployment_info() {
    echo "📝 Generating deployment information..."
    
    INFO_FILE="$BUILD_DIR/${PACKAGE_NAME}_deployment_info.json"
    ZIP_FILE="$BUILD_DIR/${PACKAGE_NAME}_${TIMESTAMP}.zip"
    
    # Calculate SHA256 hash
    if command -v shasum &> /dev/null; then
        HASH=$(shasum -a 256 "$ZIP_FILE" | cut -d' ' -f1)
    elif command -v sha256sum &> /dev/null; then
        HASH=$(sha256sum "$ZIP_FILE" | cut -d' ' -f1)
    else
        HASH="unavailable"
    fi
    
    # Get file size
    SIZE=$(stat -f%z "$ZIP_FILE" 2>/dev/null || stat -c%s "$ZIP_FILE" 2>/dev/null)
    
    # Create deployment info JSON
    cat > "$INFO_FILE" << EOF
{
  "function_name": "$FUNCTION_NAME",
  "environment": "$ENVIRONMENT",
  "package_file": "$(basename $ZIP_FILE)",
  "package_size": $SIZE,
  "package_hash": "$HASH",
  "build_timestamp": "$TIMESTAMP",
  "build_date": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "source_directory": "$SRC_DIR",
  "build_directory": "$BUILD_DIR"
}
EOF
    
    print_status "Deployment info saved: $INFO_FILE"
}

# Cleanup temporary files
cleanup_temp() {
    echo "🧹 Cleaning up temporary files..."
    
    TEMP_DIR="$BUILD_DIR/temp_deps"
    PACKAGE_DIR="$BUILD_DIR/$PACKAGE_NAME"
    
    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
    
    if [ -d "$PACKAGE_DIR" ]; then
        rm -rf "$PACKAGE_DIR"
    fi
    
    print_status "Temporary files cleaned up"
}

# Main execution flow
main() {
    echo "🚀 Starting Lambda packaging process..."
    echo ""
    
    check_prerequisites
    cleanup_builds
    install_dependencies
    package_function
    validate_package
    upload_to_s3
    test_package
    generate_deployment_info
    cleanup_temp
    
    echo ""
    echo -e "${GREEN}🎉 Packaging completed successfully!${NC}"
    echo ""
    echo -e "${BLUE}📦 Package Information:${NC}"
    echo "  Function: $FUNCTION_NAME"
    echo "  Environment: $ENVIRONMENT"
    echo "  Package: $BUILD_DIR/${PACKAGE_NAME}_${TIMESTAMP}.zip"
    echo "  Latest: $BUILD_DIR/${PACKAGE_NAME}_latest.zip"
    echo ""
    echo -e "${BLUE}🔧 Usage with Terraform:${NC}"
    echo "  Update your terraform configuration to use:"
    echo "  local_existing_package = \"$BUILD_DIR/${PACKAGE_NAME}_latest.zip\""
    echo ""
    echo -e "${BLUE}🔧 Usage with AWS CLI:${NC}"
    echo "  aws lambda update-function-code \\"
    echo "    --function-name $FUNCTION_NAME \\"
    echo "    --zip-file fileb://$BUILD_DIR/${PACKAGE_NAME}_latest.zip"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --upload-s3)
            UPLOAD_TO_S3="true"
            shift
            ;;
        --s3-bucket)
            S3_BUCKET="$2"
            shift 2
            ;;
        --test)
            RUN_TESTS="true"
            shift
            ;;
        --help)
            echo "AWS Lambda Packaging Script"
            echo ""
            echo "Usage: $0 [function-name] [environment] [options]"
            echo ""
            echo "Arguments:"
            echo "  function-name    Name of the Lambda function (default: hello-world)"
            echo "  environment      Target environment (default: dev)"
            echo ""
            echo "Options:"
            echo "  --upload-s3      Upload package to S3"
            echo "  --s3-bucket      S3 bucket name for upload"
            echo "  --test           Run local tests on package"
            echo "  --help           Show this help message"
            echo ""
            echo "Environment Variables:"
            echo "  UPLOAD_TO_S3     Set to 'true' to upload to S3"
            echo "  S3_BUCKET        S3 bucket name for uploads"
            echo "  RUN_TESTS        Set to 'true' to run local tests"
            echo ""
            echo "Examples:"
            echo "  $0                                    # Package hello-world for dev"
            echo "  $0 my-function prod                   # Package my-function for prod"
            echo "  $0 my-function dev --upload-s3 --s3-bucket my-bucket"
            echo "  $0 my-function prod --test"
            exit 0
            ;;
        *)
            if [ -z "$FUNCTION_NAME_SET" ]; then
                FUNCTION_NAME="$1"
                FUNCTION_NAME_SET=true
            elif [ -z "$ENVIRONMENT_SET" ]; then
                ENVIRONMENT="$1"
                ENVIRONMENT_SET=true
            else
                print_error "Unknown argument: $1"
                exit 1
            fi
            shift
            ;;
    esac
done

# Run main function
main
