# Project Rules

## Communication & Language

### Language Preferences

- **Conversation Language**: Always use Chinese (中文) for all interactions with the user
- **User-Facing Text**: Use Chinese for all UI strings, user messages, and documentation (与现有 UI 保持一致)
- **Code Comments**: Use English only for all code and script comments (英文注释)
- **Debug Logs**: English is allowed for debug logs (建议统一前缀如 `[DEBUG]`)

### Encoding Standards

To avoid encoding issues, follow these standards:

#### Script File Template

```bash
#!/usr/bin/env bash
set -euo pipefail
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# English comments only - write all comments in English
# This prevents encoding issues when running scripts on different systems

# Example of proper English comment:
# Check if device is connected before proceeding
if [ -z "$DEVICE_UDID" ]; then
    echo "Error: No device connected"
    exit 1
fi
```

#### Swift File Comments

```swift
// English comments only in Swift code
// Use Chinese only for user-facing strings (String literals in UI)

// BAD: 用户设备信息 - this is a Chinese comment in code
// GOOD: User device information - this is an English comment

// User-facing string (Chinese):
let errorMessage = "设备连接失败"

// Code comment (English):
// Handle device connection failure gracefully
```

### File Generation Standards

When generating or modifying files:

1. **Script files** (.sh, .swift scripts, etc.):
   - Always use UTF-8 encoding
   - Write all comments in English
   - Set locale variables: `export LANG=en_US.UTF-8` and `export LC_ALL=en_US.UTF-8`
   - Avoid outputting non-ASCII characters in script output

2. **Generated output files**:
   - Use UTF-8 encoding
   - If the content is user-facing, write in Chinese
   - If the content is code/data, use English for comments/keys

3. **Configuration files**:
   - Use English for all keys, values, and comments
   - This ensures portability and consistency

### Examples of Proper Usage

#### Correct (Script with English Comments)
```bash
#!/usr/bin/env bash
set -euo pipefail
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Build the Xcode project
xcodebuild -project iPhoneInfo.xcodeproj \
  -scheme iPhoneInfo \
  -configuration Debug \
  build

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "Build completed successfully"
else
    echo "Build failed with exit code: $?"
    exit 1
fi
```

#### Correct (Swift Code with English Comments)
```swift
import SwiftUI

struct DeviceInfoView: View {
    var deviceName: String

    var body: some View {
        VStack {
            Text("设备名称") // Chinese for user
            Text(deviceName)
        }
    }

    // Fetch device information from system
    private func loadDeviceInfo() {
        // Implementation details in English
    }
}
```

#### Incorrect (Chinese Comments in Script)
```bash
# BAD: Don't do this - Chinese comments in script
# 检查设备是否连接
if [ -z "$DEVICE_UDID" ]; then
    echo "设备未连接"
    exit 1
fi
```

#### Incorrect (Non-ASCII in Script Output)
```bash
# BAD: Don't output non-ASCII characters directly in scripts
echo "构建完成"  # This may cause encoding issues
echo "Build completed"  # Correct
```

### Enforcement

When working with this project:

1. **Always** write code comments in English
2. **Always** write user-facing strings in Chinese (for UI)
3. **Always** use UTF-8 encoding for all files
4. **Always** set locale variables in scripts to `en_US.UTF-8`
5. **Never** use Chinese comments in code files
6. **Never** output non-ASCII characters directly in scripts (use echo with ASCII or escape sequences)

### Quick Reference

| Context | Language | Example |
|---------|----------|---------|
| Conversation with user | 中文 | "你好，我帮你修复这个问题" |
| UI strings / user messages | 中文 | `"设备信息"` |
| Code comments | English | `// Fetch device data` |
| Script comments | English | `# Build the project` |
| Script output | English | `"Build successful"` |
| Debug logs | English | `[DEBUG] Device connected` |
| Configuration keys | English | `"deviceName"` |

### Summary

Remember the simple rule:
- **User-facing** = Chinese
- **Code & Developer-facing** = English
- **File encoding** = UTF-8
- **Scripts** = Set LANG=en_US.UTF-8
