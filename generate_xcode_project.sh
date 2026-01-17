#!/bin/bash

# iPhone Info - Xcode Project Generator
# This script generates an Xcode project from Swift source files

echo "📱 Generating iPhone Info Xcode Project..."

# Create directory structure
mkdir -p iPhoneInfo.xcodeproj

# Find all Swift files
echo "📝 Scanning for Swift files..."

SWIFT_FILES=()

for file in iPhoneInfo/App/*.swift iPhoneInfo/Views/*.swift iPhoneInfo/Services/*.swift iPhoneInfo/Models/*.swift iPhoneInfo/Benchmark/*.swift; do
    if [ -f "$file" ]; then
        SWIFT_FILES+=("$file")
    fi
done

echo "📊 Found ${#SWIFT_FILES[@]} Swift files"

# Start building project file
PROJECT_FILE="iPhoneInfo.xcodeproj/project.pbxproj"

echo "📄 Building project file..."

# Write header
echo "// !$*UTF8*$!" > "$PROJECT_FILE"

echo "archiveVersion = 1;" >> "$PROJECT_FILE"
echo "objects = {" >> "$PROJECT_FILE"
echo "/* Begin PBXBuildFile section */" >> "$PROJECT_FILE"

# Generate file references
FILE_INDEX=1000000
for swift_file in "${SWIFT_FILES[@]}"; do
    FILE_INDEX=$((FILE_INDEX + 1))
    FILE_REF="A$(printf "%06d" $FILE_INDEX)"
    FILE_NAME=$(basename "$swift_file")
    echo "	$FILE_REF /* $FILE_NAME in Sources */ = {isa = PBXBuildFile; fileRef = $FILE_REF };"
done >> "$PROJECT_FILE"

echo "};"
echo "/* Begin PBXFileReference section */" >> "$PROJECT_FILE"

# End header
echo "	};" >> "$PROJECT_FILE"

# Build Sources group
echo "/* Begin PBXGroup section */" >> "$PROJECT_FILE"
echo "	/* Sources */ = {" >> "$PROJECT_FILE"

echo "		isa = PBXGroup;" >> "$PROJECT_FILE"
echo "		children = (" >> "$PROJECT_FILE"

# Add file references for each Swift file
for swift_file in "${SWIFT_FILES[@]}"; do
    FILE_NAME=$(basename "$swift_file")
    FILE_REF="A$(printf "%06d" $FILE_INDEX)"
    echo "			$FILE_REF /* $FILE_NAME in Sources */ = {isa = PBXBuildFile; fileRef = $FILE_REF };" >> "$PROJECT_FILE"
done

echo "		);" >> "$PROJECT_FILE"

echo "		path = Sources;" >> "$PROJECT_FILE"

echo "		sourceTree = \"<group>\";" >> "$PROJECT_FILE"
echo "	};" >> "$PROJECT_FILE"

# End PBXGroup section
echo "/* End PBXGroup section */" >> "$PROJECT_FILE"

# Build Models group
echo "/* Begin PBXGroup section */" >> "$PROJECT_FILE"
echo "	/* Models */ = {" >> "$PROJECT_FILE"

echo "		isa = PBXGroup;" >> "$PROJECT_FILE"
echo "		children = (" >> "$PROJECT_FILE"

for swift_file in iPhoneInfo/Models/*.swift; do
    FILE_INDEX=$((FILE_INDEX + 1))
    FILE_REF="A$(printf "%06d" $FILE_INDEX)"
    FILE_NAME=$(basename "$swift_file")
    echo "			$FILE_REF /* $FILE_NAME in Models */ = {isa = PBXBuildFile; fileRef = $FILE_REF };"
done >> "$PROJECT_FILE"

echo "		);" >> "$PROJECT_FILE"

echo "	);" >> "$PROJECT_FILE"

echo "		path = Models;" >> "$PROJECT_FILE"
echo "		sourceTree = \"<group>\";" >> "$PROJECT_FILE"

echo "	};" >> "$PROJECT_FILE"

# End PBXGroup section
echo "/* End PBXGroup section */" >> "$PROJECT_FILE"

# Build Services group
echo "/* Begin PBXGroup section */" >> "$PROJECT_FILE"
echo "	/* Services */ = {" >> "$PROJECT_FILE"

echo "		isa = PBXGroup;" >> "$PROJECT_FILE"
echo "		children = (" >> "$PROJECT_FILE"

for swift_file in iPhoneInfo/Services/*.swift; do
    FILE_INDEX=$((FILE_INDEX + 1))
    FILE_REF="A$(printf "%06d" $FILE_INDEX)"
    FILE_NAME=$(basename "$swift_file")
    echo "				$FILE_REF /* $FILE_NAME in Services */ = {isa = PBXBuildFile; fileRef = $FILE_REF };"
done >> "$PROJECT_FILE"

echo "	);" >> "$PROJECT_FILE"

echo "	);" >> "$PROJECT_FILE"

echo "		path = Services;" >> "$PROJECT_FILE"
echo "			sourceTree = \"<group>\";" >> "$PROJECT_FILE"

echo "	};" >> "$PROJECT_FILE"

# End PBXGroup section
echo "/* End PBXGroup section */" >> "$PROJECT_FILE"

# Build Views group
echo "/* Begin PBXGroup section */" >> "$PROJECT_FILE"
echo "	/* Views */ = {" >> "$PROJECT_FILE"

echo "		isa = PBXGroup;" >> "$PROJECT_FILE"
echo "		children = (" >> "$PROJECT_FILE"

for swift_file in iPhoneInfo/Views/*.swift; do
    FILE_INDEX=$((FILE_INDEX + 1))
    FILE_REF="A$(printf "%06d" $FILE_INDEX)"
    FILE_NAME=$(basename "$swift_file")
    echo "				$FILE_REF /* $FILE_NAME in Views */ = {isa = PBXBuildFile; fileRef = $FILE_REF };"
done >> "$PROJECT_FILE"

echo "	);" >> "$PROJECT_FILE"

echo "	);" >> "$PROJECT_FILE"

echo "		path = Views;" >> "$PROJECT_FILE"
echo "			sourceTree = \"<group>\";" >> "$PROJECT_FILE"

echo "	};" >> "$PROJECT_FILE"

# End PBXGroup section */
echo "/* End PBXGroup section */" >> "$PROJECT_FILE"

# Build Benchmark group
echo "/* Begin PBXGroup section */" >> "$PROJECT_FILE"
echo "/* Benchmark */ = {" >> "$PROJECT_FILE"

echo "		isa = PBXGroup;" >> "$PROJECT_FILE"
echo "		children = (" >> "$PROJECT_FILE"

for swift_file in iPhoneInfo/Benchmark/*.swift; do
    FILE_INDEX=$((FILE_INDEX + 1))
    FILE_REF="A$(printf "%06d" $FILE_INDEX)"
    FILE_NAME=$(basename "$swift_file")
    echo "					$FILE_REF /* $FILE_NAME in Benchmark */ = {isa = PBXBuildFile; fileRef = $FILE_REF };"
done >> "$PROJECT_FILE"

echo "	);" >> "$PROJECT_FILE"

echo "	);" >> "$PROJECT_FILE"

echo "	);" >> "$PROJECT_FILE"

echo "		path = Benchmark;" >> "$PROJECT_FILE"
echo "			sourceTree = \"<group>\";" >> "$PROJECT_FILE"

echo "	};" >> "$PROJECT_FILE"

# End PBXGroup section */
echo "/* End PBXGroup section */" >> "$PROJECT_FILE"

# End objects section
echo "};" >> "$PROJECT_FILE"

echo "/* Begin PBXFileReference section */" >> "$PROJECT_FILE"

# Add app and info.plist references
FILE_REF="A$(printf "%06d" $FILE_INDEX)"
echo "	/* iPhoneInfoApp.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = iPhoneInfoApp.swift; sourceTree = \"<group>\"; };" >> "$PROJECT_FILE"

FILE_REF="A$(printf "%06d" $((FILE_INDEX + 1)))"
echo "	/* ContentView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ContentView.swift; sourceTree = \"<group>\"; };" >> "$PROJECT_FILE"

FILE_REF="A$(printf "%06d" $((FILE_INDEX + 2)))"
echo "	/* DeviceModels.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = DeviceModels.swift; sourceTree = \"<group>\"; };" >> "$PROJECT_FILE"

FILE_REF="A$(printf "%06d" $((FILE_INDEX + 3)))"
echo "	/* DeviceInfoService.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = DeviceInfoService.swift; sourceTree = \"<group>\"; };" >> "$PROJECT_FILE"

FILE_REF="A$(printf "%06d" $((FILE_INDEX + 4)))"
echo "	/* ExtendedDeviceDetailsService.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ExtendedDeviceDetailsService.swift; sourceTree = \"<group>\"; };" >> "$PROJECT_FILE"

FILE_REF="A$(printf "%06d" $((FILE_INDEX + 5)))"
echo "	/* HomeView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = HomeView.swift; sourceTree = \"<group>\"; };" >> "$PROJECT_FILE"

FILE_REF="A$(printf "%06d" $((FILE_INDEX + 6)))"
echo "	/* BenchmarkView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = BenchmarkView.swift; sourceTree = \"<group>\"; };" >> "$PROJECT_FILE"

FILE_REF="A$(printf "%06d" $((FILE_INDEX + 7)))"
echo "	/* MonitorView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = MonitorView.swift; sourceTree = \"<group>\"; };" >> "$PROJECT_FILE"

FILE_REF="A$(printf "%06d" $((FILE_INDEX + 8)))"
echo "	/* CompareView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = CompareView.swift; sourceTree = \"<group>\"; };" >> "$PROJECT_FILE"

FILE_REF="A$(printf "%06d" $((FILE_INDEX + 9)))"
echo "	/* SettingsView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SettingsView.swift; sourceTree = \"<group>\"; };" >> "$PROJECT_FILE"

# End PBXFileReference section
echo "};" >> "$PROJECT_FILE"

echo "/* Begin PBXNativeTarget section */" >> "$PROJECT_FILE"

echo "	/* iPhoneInfo */ = {" >> "$PROJECT_FILE"
echo "	isa = PBXNativeTarget;" >> "$PROJECT_FILE"
echo "	buildConfigurationList = A1000031;" >> "$PROJECT_FILE"
echo "	buildPhases = (" >> "$PROJECT_FILE"

echo "	);" >> "$PROJECT_FILE"

echo "		dependencies = (" >> "$PROJECT_FILE"

echo "	);" >> "$PROJECT_FILE"

echo "		name = iPhoneInfo;" >> "$PROJECT_FILE"
echo "	productName = iPhoneInfo;" >> "$PROJECT_FILE"
echo "	productReference = A1000002 /* iPhoneInfo.app */;" >> "$PROJECT_FILE"
echo "	productType = "com.apple.product-type.application";" >> "$PROJECT_FILE"

echo "	};" >> "$PROJECT_FILE"

echo "/* End PBXNativeTarget section */" >> "$PROJECT_FILE"

# Begin PBXProject section
echo "/* Project object */" >> "$PROJECT_FILE"

echo "	isa = PBXProject;" >> "$PROJECT_FILE"
echo "	attributes = {" >> "$PROJECT_FILE"
echo "		BuildIndependentTargetsInParallel = 1;" >> "$PROJECT_FILE"
echo "		LastSwiftUpdateCheck = 1500;" >> "$PROJECT_FILE"
echo "		TargetAttributes = {" >> "$PROJECT_FILE"

echo "			};" >> "$PROJECT_FILE"

echo "	};" >> "$PROJECT_FILE"

echo "	buildConfigurationList = A1000032;" >> "$PROJECT_FILE"
echo "	compatibilityVersion = "Xcode 14.0";" >> "$PROJECT_FILE"
echo "	developmentRegion = en;" >> "$PROJECT_FILE"
echo "	hasScannedForEncodings = 0;" >> "$PROJECT_FILE"
echo "	knownRegions = (" >> "$PROJECT_FILE"

echo "			en," >> "$PROJECT_FILE"
echo "			Base," >> "$PROJECT_FILE"
echo "		);" >> "$PROJECT_FILE"

echo "	mainGroup = A1000023;" >> "$PROJECT_FILE"
echo "	productRefGroup = A1000028;" >> "$PROJECT_FILE"
echo "	projectDirPath = \"\";" >> "$PROJECT_FILE"
echo "	projectRoot = \"\";" >> "$PROJECT_FILE"
echo "	targets = (" >> "$PROJECT_FILE"

echo "				A1000028 /* iPhoneInfo */" >> "$PROJECT_FILE"
echo "			);" >> "$PROJECT_FILE"

echo "		);" >> "$PROJECT_FILE"

echo "	};" >> "$PROJECT_FILE"

# End PBXProject section
echo "};" >> "$PROJECT_FILE"

echo "✅ Project file generated: iPhoneInfo.xcodeproj"
echo ""
echo "To build and run:"
echo " open iPhoneInfo.xcodeproj"
echo ""
echo "Or:"
echo "  xcodebuild -project iPhoneInfo.xcodeproj -scheme iPhoneInfo -configuration Debug build"