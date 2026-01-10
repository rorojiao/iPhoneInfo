#!/bin/bash

# iPhone Info - Xcode Project Generator
# This script generates an Xcode project from the Swift source files

echo "📱 Generating iPhone Info Xcode Project..."

# Create directory structure
mkdir -p iPhoneInfo.xcodeproj

# Create project.pbxproj
cat > iPhoneInfo.xcodeproj/project.pbxproj << 'EOF'
// !$*UTF8*$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 56;
	objects = {

/* Begin PBXBuildFile section */
		A1000001 /* iPhoneInfoApp.swift in Sources */ = {isa = PBXBuildFile; fileRef = A1000002; };
		A1000003 /* ContentView.swift in Sources */ = {isa = PBXBuildFile; fileRef = A1000004; };
		A1000005 /* DeviceModels.swift in Sources */ = {isa = PBXBuildFile; fileRef = A1000006; };
		A1000007 /* DeviceInfoService.swift in Sources */ = {isa = PBXBuildFile; fileRef = A1000008; };
		A1000009 /* HomeView.swift in Sources */ = {isa = PBXBuildFile; fileRef = A1000010; };
		A1000011 /* BenchmarkView.swift in Sources */ = {isa = PBXBuildFile; fileRef = A1000012; };
		A1000013 /* MonitorView.swift in Sources */ = {isa = PBXBuildFile; fileRef = A1000014; };
		A1000015 /* CompareView.swift in Sources */ = {isa = PBXBuildFile; fileRef = A1000016; };
		A1000017 /* SettingsView.swift in Sources */ = {isa = PBXBuildFile; fileRef = A1000018; };
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
		A1000002 /* iPhoneInfoApp.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = iPhoneInfoApp.swift; sourceTree = "<group>"; };
		A1000004 /* ContentView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ContentView.swift; sourceTree = "<group>"; };
		A1000006 /* DeviceModels.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = DeviceModels.swift; sourceTree = "<group>"; };
		A1000008 /* DeviceInfoService.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = DeviceInfoService.swift; sourceTree = "<group>"; };
		A1000010 /* HomeView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = HomeView.swift; sourceTree = "<group>"; };
		A1000012 /* BenchmarkView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = BenchmarkView.swift; sourceTree = "<group>"; };
		A1000014 /* MonitorView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = MonitorView.swift; sourceTree = "<group>"; };
		A1000016 /* CompareView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = CompareView.swift; sourceTree = "<group>"; };
		A1000018 /* SettingsView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SettingsView.swift; sourceTree = "<group>"; };
		A1000020 /* iPhoneInfo.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = iPhoneInfo.app; sourceTree = BUILT_PRODUCTS_DIR; };
		A1000021 /* Info.plist */ = {isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = "<group>"; };
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
		A1000022 /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
		A1000023 = {
			isa = PBXGroup;
			children = (
				A1000024 /* iPhoneInfo */,
				A1000025 /* Products */,
			);
			sourceTree = "<group>";
		};
		A1000024 /* iPhoneInfo */ = {
			isa = PBXGroup;
			children = (
				A1000021 /* Info.plist */,
				A1000026 /* App */,
				A1000027 /* Models */,
				A1000028 /* Services */,
				A1000029 /* Views */,
			);
			path = iPhoneInfo;
			sourceTree = "<group>";
		};
		A1000025 /* Products */ = {
			isa = PBXGroup;
			children = (
				A1000020 /* iPhoneInfo.app */,
			);
			name = Products;
			sourceTree = "<group>";
		};
		A1000026 /* App */ = {
			isa = PBXGroup;
			children = (
				A1000002 /* iPhoneInfoApp.swift */,
				A1000004 /* ContentView.swift */,
			);
			path = App;
			sourceTree = "<group>";
		};
		A1000027 /* Models */ = {
			isa = PBXGroup;
			children = (
				A1000006 /* DeviceModels.swift */,
			);
			path = Models;
			sourceTree = "<group>";
		};
		A1000028 /* Services */ = {
			isa = PBXGroup;
			children = (
				A1000008 /* DeviceInfoService.swift */,
			);
			path = Services;
			sourceTree = "<group>";
		};
		A1000029 /* Views */ = {
			isa = PBXGroup;
			children = (
				A1000010 /* HomeView.swift */,
				A1000012 /* BenchmarkView.swift */,
				A1000014 /* MonitorView.swift */,
				A1000016 /* CompareView.swift */,
				A1000018 /* SettingsView.swift */,
			);
			path = Views;
			sourceTree = "<group>";
		};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		A1000030 /* iPhoneInfo */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = A1000031 /* Build configuration list for PBXNativeTarget "iPhoneInfo" */;
			buildPhases = (
				A1000032 /* Sources */,
				A1000022 /* Frameworks */,
				A1000033 /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = iPhoneInfo;
			productName = iPhoneInfo;
			productReference = A1000020 /* iPhoneInfo.app */;
			productType = "com.apple.product-type.application";
		};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		A1000034 /* Project object */ = {
			isa = PBXProject;
			attributes = {
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 1500;
				LastUpgradeCheck = 1500;
				TargetAttributes = {
					A1000030 = {
						CreatedOnToolsVersion = 15.0;
					};
				};
			};
			buildConfigurationList = A1000035 /* Build configuration list for PBXProject "iPhoneInfo" */;
			compatibilityVersion = "Xcode 14.0";
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				Base,
			);
			mainGroup = A1000023;
			productRefGroup = A1000025 /* Products */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				A1000030 /* iPhoneInfo */,
			);
		};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
		A1000033 /* Resources */ = {
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
		A1000032 /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				A1000001 /* iPhoneInfoApp.swift in Sources */,
				A1000003 /* ContentView.swift in Sources */,
				A1000005 /* DeviceModels.swift in Sources */,
				A1000007 /* DeviceInfoService.swift in Sources */,
				A1000009 /* HomeView.swift in Sources */,
				A1000011 /* BenchmarkView.swift in Sources */,
				A1000013 /* MonitorView.swift in Sources */,
				A1000015 /* CompareView.swift in Sources */,
				A1000017 /* SettingsView.swift in Sources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
		A1000036 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = dwarf;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_TESTABILITY = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = YES;
				GCC_C_LANGUAGE_STANDARD = gnu17;
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_PREPROCESSOR_DEFINITIONS = (
					"DEBUG=1",
					"$(inherited)",
				);
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 15.0;
				LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
				MTL_FAST_MATH = YES;
				ONLY_ACTIVE_ARCH = YES;
				SDKROOT = iphoneos;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = "DEBUG $(inherited)";
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
			};
			name = Debug;
		};
		A1000037 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				ENABLE_NS_ASSERTIONS = NO;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = YES;
				GCC_C_LANGUAGE_STANDARD = gnu17;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 15.0;
				LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
				MTL_ENABLE_DEBUG_INFO = NO;
				MTL_FAST_MATH = YES;
				SDKROOT = iphoneos;
				SWIFT_COMPILATION_MODE = wholemodule;
				VALIDATE_PRODUCT = YES;
			};
			name = Release;
		};
		A1000038 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = "";
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = iPhoneInfo/Info.plist;
				INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
				INFOPLIST_KEY_UILaunchStoryboardName = "";
				INFOPLIST_KEY_UISupportedInterfaceOrientations = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.iphoneinfo.benchmark;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			};
			name = Debug;
		};
		A1000039 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = "";
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = iPhoneInfo/Info.plist;
				INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
				INFOPLIST_KEY_UILaunchStoryboardName = "";
				INFOPLIST_KEY_UISupportedInterfaceOrientations = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.iphoneinfo.benchmark;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			};
			name = Release;
		};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		A1000031 /* Build configuration list for PBXNativeTarget "iPhoneInfo" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				A1000038 /* Debug */,
				A1000039 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
		A1000035 /* Build configuration list for PBXProject "iPhoneInfo" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				A1000036 /* Debug */,
				A1000037 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
/* End XCConfigurationList section */
	};
	rootObject = A1000034 /* Project object */;
}
EOF

echo "✅ Xcode project generated: iPhoneInfo.xcodeproj"
echo ""
echo "To build and run:"
echo "  open iPhoneInfo.xcodeproj"
echo "  # Or:"
echo "  xcodebuild -project iPhoneInfo.xcodeproj -scheme iPhoneInfo -configuration Debug build"
