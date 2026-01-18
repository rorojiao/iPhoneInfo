#!/usr/bin/env bash
#
#  add_files_to_xcode.sh
#  Helper script to add new Swift files to Xcode project
#

set -euo pipefail

# Project configuration
PROJECT_FILE="iPhoneInfo.xcodeproj"
PROJECT_DIR="."

echo "Adding new Swift files to Xcode project..."
echo ""

# List of files to add
FILES=(
    "iPhoneInfo/Services/SubscriptionManager.swift"
    "iPhoneInfo/Services/CloudLeaderboardService.swift"
    "iPhoneInfo/Services/CloudSyncService.swift"
    "iPhoneInfo/Services/DataExportService.swift"
    "iPhoneInfo/Services/ShareCardService.swift"
    "iPhoneInfo/Views/SubscriptionView.swift"
    "iPhoneInfo/Views/ProFeatureGate.swift"
    "iPhoneInfo/Views/LeaderboardView.swift"
    "iPhoneInfo/Views/DataExportView.swift"
    "iPhoneInfo/Views/ShareResultView.swift"
)

# Function to add file to Xcode project
add_file_to_xcode() {
    local file="$1"
    local filename=$(basename "$file")
    local ext="${file##*.}"

    echo "Adding $file..."

    # Check if file exists
    if [[ ! -f "$file" ]]; then
        echo "❌ File not found: $file"
        return 1
    fi

    # Check if already in project
    if grep -q "$filename" "$PROJECT_FILE"; then
        echo "  Already in project"
        return 0
    fi

    # Generate unique IDs
    local file_id="A$(date +%s%N)"
    local build_file_id="A$((file_id + 1))"
    local file_ref_id="A$((file_id + 2))"

    # Add file reference
    sed -i.bak "/Begin PBXFileReference section/a\\
\\
$build_file_id /* $filename in Sources */ = {isa = PBXBuildFile; fileRef = $file_ref_id; };\\
" "$PROJECT_FILE"

    # Add file reference
    sed -i.bak "/Begin PBXFileReference section/a\\
\\
$file_ref_id /* $filename */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = $filename; sourceTree = "<group>"; };\\
" "$PROJECT_FILE"

    # Remove backup
    rm "$PROJECT_FILE.bak"

    echo "  ✓ Added"
}

# Add files
for file in "${FILES[@]}"; do
    add_file_to_xcode "$file"
done

echo ""
echo "✅ All files added to Xcode project!"
echo ""
echo "Next steps:"
echo "1. Open iPhoneInfo.xcodeproj in Xcode"
echo "2. In Xcode, go to 'Build Phases' → 'Compile Sources'"
echo "3. Clean build folder (Product > Clean Build Folder)"
echo "4. Build the project to verify everything compiles"
echo ""
echo "Note: Make sure your provisioning profile includes StoreKit capability."
