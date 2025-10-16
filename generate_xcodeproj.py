#!/usr/bin/env python3
"""
Xcode Project Generator for RickyApp
Creates a complete .xcodeproj bundle with proper project.pbxproj structure
"""

import os
import uuid
import json

def generate_uuid():
    """Generate a unique 24-character hex string (Xcode style)"""
    return uuid.uuid4().hex[:24].upper()

class XcodeProject:
    def __init__(self, project_name, bundle_id, source_root):
        self.project_name = project_name
        self.bundle_id = bundle_id
        self.source_root = source_root

        # Generate UUIDs for main objects
        self.project_uuid = generate_uuid()
        self.main_group_uuid = generate_uuid()
        self.products_group_uuid = generate_uuid()
        self.target_uuid = generate_uuid()
        self.app_product_uuid = generate_uuid()
        self.sources_phase_uuid = generate_uuid()
        self.resources_phase_uuid = generate_uuid()
        self.frameworks_phase_uuid = generate_uuid()
        self.native_target_uuid = generate_uuid()
        self.config_list_project_uuid = generate_uuid()
        self.config_list_target_uuid = generate_uuid()
        self.debug_config_project_uuid = generate_uuid()
        self.release_config_project_uuid = generate_uuid()
        self.debug_config_target_uuid = generate_uuid()
        self.release_config_target_uuid = generate_uuid()

        # File and group references
        self.file_refs = {}
        self.build_files = {}
        self.groups = {}
        self.package_refs = {}
        self.package_products = {}

    def create_file_reference(self, path, file_type, name=None, source_tree="<group>"):
        """Create a PBXFileReference"""
        uuid = generate_uuid()
        if name is None:
            name = os.path.basename(path)

        self.file_refs[uuid] = {
            'isa': 'PBXFileReference',
            'fileEncoding': '4' if file_type == 'sourcecode.swift' else None,
            'lastKnownFileType': file_type,
            'name': name,
            'path': path,
            'sourceTree': source_tree
        }
        return uuid

    def create_build_file(self, file_ref_uuid, settings=None):
        """Create a PBXBuildFile"""
        uuid = generate_uuid()
        self.build_files[uuid] = {
            'isa': 'PBXBuildFile',
            'fileRef': file_ref_uuid,
            'settings': settings
        }
        return uuid

    def create_group(self, name, path=None, children=None, source_tree="<group>"):
        """Create a PBXGroup"""
        uuid = generate_uuid()
        self.groups[uuid] = {
            'isa': 'PBXGroup',
            'children': children or [],
            'name': name,
            'path': path,
            'sourceTree': source_tree
        }
        return uuid

    def create_package_reference(self, name, path):
        """Create XCLocalSwiftPackageReference"""
        uuid = generate_uuid()
        self.package_refs[uuid] = {
            'isa': 'XCLocalSwiftPackageReference',
            'relativePath': path
        }
        return uuid

    def create_package_product(self, package_ref_uuid, product_name):
        """Create XCSwiftPackageProductDependency"""
        uuid = generate_uuid()
        self.package_products[uuid] = {
            'isa': 'XCSwiftPackageProductDependency',
            'package': package_ref_uuid,
            'productName': product_name
        }
        return uuid

    def format_value(self, value, indent=0):
        """Format a value for pbxproj output"""
        tab = "\t" * indent

        if value is None:
            return None
        elif isinstance(value, bool):
            return "YES" if value else "NO"
        elif isinstance(value, (int, float)):
            return str(value)
        elif isinstance(value, str):
            # Check if needs quoting
            if any(c in value for c in [' ', '.', '/', '-', '@']) or value in ['Debug', 'Release']:
                return f'"{value}"'
            return value
        elif isinstance(value, list):
            if not value:
                return "()"
            items = ",\n".join(f"{tab}\t\t{self.format_value(v, indent)}" for v in value)
            return f"(\n{items},\n{tab}\t)"
        elif isinstance(value, dict):
            if not value:
                return "{}"
            items = []
            for k, v in value.items():
                formatted = self.format_value(v, indent + 1)
                if formatted is not None:
                    items.append(f"{tab}\t\t{k} = {formatted};")
            return "{\n" + "\n".join(items) + f"\n{tab}\t}}"
        return str(value)

    def generate_pbxproj(self):
        """Generate the complete project.pbxproj content"""

        # Create file references for Swift files
        app_file_uuid = self.create_file_reference('RickyAppApp.swift', 'sourcecode.swift')
        content_view_uuid = self.create_file_reference('ContentView.swift', 'sourcecode.swift')

        # VM files
        char_vm_uuid = self.create_file_reference('VM/CharacterListViewModel.swift', 'sourcecode.swift')
        loc_vm_uuid = self.create_file_reference('VM/LocationListViewModel.swift', 'sourcecode.swift')

        # View files
        char_list_view_uuid = self.create_file_reference('View/CharacterListView.swift', 'sourcecode.swift')
        char_detail_view_uuid = self.create_file_reference('View/CharacterDetailView.swift', 'sourcecode.swift')
        loc_list_view_uuid = self.create_file_reference('View/LocationListView.swift', 'sourcecode.swift')
        loc_detail_view_uuid = self.create_file_reference('View/LocationDetailView.swift', 'sourcecode.swift')

        # Resources
        assets_uuid = self.create_file_reference('Assets.xcassets', 'folder.assetcatalog')
        info_plist_uuid = self.create_file_reference('Info.plist', 'text.plist.xml')
        entitlements_uuid = self.create_file_reference('RickyApp.entitlements', 'text.plist.entitlements')

        # Create build files
        app_build_uuid = self.create_build_file(app_file_uuid)
        content_build_uuid = self.create_build_file(content_view_uuid)
        char_vm_build_uuid = self.create_build_file(char_vm_uuid)
        loc_vm_build_uuid = self.create_build_file(loc_vm_uuid)
        char_list_build_uuid = self.create_build_file(char_list_view_uuid)
        char_detail_build_uuid = self.create_build_file(char_detail_view_uuid)
        loc_list_build_uuid = self.create_build_file(loc_list_view_uuid)
        loc_detail_build_uuid = self.create_build_file(loc_detail_view_uuid)
        assets_build_uuid = self.create_build_file(assets_uuid)

        # Create groups
        vm_group_uuid = self.create_group('VM', 'VM', [char_vm_uuid, loc_vm_uuid])
        view_group_uuid = self.create_group('View', 'View', [
            char_list_view_uuid, char_detail_view_uuid,
            loc_list_view_uuid, loc_detail_view_uuid
        ])

        # Main group structure
        self.groups[self.main_group_uuid] = {
            'isa': 'PBXGroup',
            'children': [
                app_file_uuid,
                content_view_uuid,
                vm_group_uuid,
                view_group_uuid,
                assets_uuid,
                entitlements_uuid,
                info_plist_uuid,
                self.products_group_uuid
            ],
            'sourceTree': '<group>'
        }

        # Products group
        self.groups[self.products_group_uuid] = {
            'isa': 'PBXGroup',
            'children': [self.app_product_uuid],
            'name': 'Products',
            'sourceTree': '<group>'
        }

        # App product reference
        self.file_refs[self.app_product_uuid] = {
            'isa': 'PBXFileReference',
            'explicitFileType': 'wrapper.application',
            'includeInIndex': '0',
            'path': f'{self.project_name}.app',
            'sourceTree': 'BUILT_PRODUCTS_DIR'
        }

        # Create package references
        packages = [
            ('RickyDesignSystem', '../RickyDesignSystem'),
            ('RickyDomain', '../RickyDomain'),
            ('RickyData', '../RickyData'),
            ('RickyRouter', '../RickyRouter'),
            ('RickyDI', '../RickyDI'),
            ('RickyAppCore', '../RickyAppCore'),
            ('RickyConfiguration', '../RickyConfiguration')
        ]

        package_product_uuids = []
        package_ref_list = []

        for pkg_name, pkg_path in packages:
            pkg_ref = self.create_package_reference(pkg_name, pkg_path)
            pkg_prod = self.create_package_product(pkg_ref, pkg_name)
            package_ref_list.append(pkg_ref)
            package_product_uuids.append(pkg_prod)

        # Build phases
        sources_phase = {
            'isa': 'PBXSourcesBuildPhase',
            'buildActionMask': '2147483647',
            'files': [
                app_build_uuid, content_build_uuid,
                char_vm_build_uuid, loc_vm_build_uuid,
                char_list_build_uuid, char_detail_build_uuid,
                loc_list_build_uuid, loc_detail_build_uuid
            ],
            'runOnlyForDeploymentPostprocessing': '0'
        }

        resources_phase = {
            'isa': 'PBXResourcesBuildPhase',
            'buildActionMask': '2147483647',
            'files': [assets_build_uuid],
            'runOnlyForDeploymentPostprocessing': '0'
        }

        frameworks_phase = {
            'isa': 'PBXFrameworksBuildPhase',
            'buildActionMask': '2147483647',
            'files': [],
            'runOnlyForDeploymentPostprocessing': '0'
        }

        # Native target
        native_target = {
            'isa': 'PBXNativeTarget',
            'buildConfigurationList': self.config_list_target_uuid,
            'buildPhases': [
                self.sources_phase_uuid,
                self.frameworks_phase_uuid,
                self.resources_phase_uuid
            ],
            'buildRules': [],
            'dependencies': [],
            'name': self.project_name,
            'packageProductDependencies': package_product_uuids,
            'productName': self.project_name,
            'productReference': self.app_product_uuid,
            'productType': 'com.apple.product-type.application'
        }

        # Build configurations
        debug_config_target = {
            'isa': 'XCBuildConfiguration',
            'buildSettings': {
                'ASSETCATALOG_COMPILER_APPICON_NAME': 'AppIcon',
                'ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME': 'AccentColor',
                'CODE_SIGN_ENTITLEMENTS': 'RickyApp/RickyApp.entitlements',
                'CODE_SIGN_STYLE': 'Automatic',
                'CURRENT_PROJECT_VERSION': '1',
                'DEVELOPMENT_TEAM': '',
                'ENABLE_PREVIEWS': 'YES',
                'GENERATE_INFOPLIST_FILE': 'NO',
                'INFOPLIST_FILE': 'RickyApp/Info.plist',
                'INFOPLIST_KEY_UIApplicationSceneManifest_Generation': 'YES',
                'INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents': 'YES',
                'INFOPLIST_KEY_UILaunchScreen_Generation': 'YES',
                'INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad': '"UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight"',
                'INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone': '"UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight"',
                'IPHONEOS_DEPLOYMENT_TARGET': '15.0',
                'LD_RUNPATH_SEARCH_PATHS': '"$(inherited) @executable_path/Frameworks"',
                'MARKETING_VERSION': '1.0',
                'PRODUCT_BUNDLE_IDENTIFIER': self.bundle_id,
                'PRODUCT_NAME': '"$(TARGET_NAME)"',
                'SDKROOT': 'iphoneos',
                'SUPPORTED_PLATFORMS': '"iphoneos iphonesimulator"',
                'SUPPORTS_MACCATALYST': 'NO',
                'SWIFT_EMIT_LOC_STRINGS': 'YES',
                'SWIFT_VERSION': '6.0',
                'TARGETED_DEVICE_FAMILY': '"1,2"'
            },
            'name': 'Debug'
        }

        release_config_target = {
            'isa': 'XCBuildConfiguration',
            'buildSettings': {
                'ASSETCATALOG_COMPILER_APPICON_NAME': 'AppIcon',
                'ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME': 'AccentColor',
                'CODE_SIGN_ENTITLEMENTS': 'RickyApp/RickyApp.entitlements',
                'CODE_SIGN_STYLE': 'Automatic',
                'CURRENT_PROJECT_VERSION': '1',
                'DEVELOPMENT_TEAM': '',
                'ENABLE_PREVIEWS': 'YES',
                'GENERATE_INFOPLIST_FILE': 'NO',
                'INFOPLIST_FILE': 'RickyApp/Info.plist',
                'INFOPLIST_KEY_UIApplicationSceneManifest_Generation': 'YES',
                'INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents': 'YES',
                'INFOPLIST_KEY_UILaunchScreen_Generation': 'YES',
                'INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad': '"UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight"',
                'INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone': '"UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight"',
                'IPHONEOS_DEPLOYMENT_TARGET': '15.0',
                'LD_RUNPATH_SEARCH_PATHS': '"$(inherited) @executable_path/Frameworks"',
                'MARKETING_VERSION': '1.0',
                'PRODUCT_BUNDLE_IDENTIFIER': self.bundle_id,
                'PRODUCT_NAME': '"$(TARGET_NAME)"',
                'SDKROOT': 'iphoneos',
                'SUPPORTED_PLATFORMS': '"iphoneos iphonesimulator"',
                'SUPPORTS_MACCATALYST': 'NO',
                'SWIFT_EMIT_LOC_STRINGS': 'YES',
                'SWIFT_VERSION': '6.0',
                'TARGETED_DEVICE_FAMILY': '"1,2"',
                'VALIDATE_PRODUCT': 'YES'
            },
            'name': 'Release'
        }

        debug_config_project = {
            'isa': 'XCBuildConfiguration',
            'buildSettings': {
                'ALWAYS_SEARCH_USER_PATHS': 'NO',
                'ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS': 'YES',
                'CLANG_ANALYZER_NONNULL': 'YES',
                'CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION': 'YES_AGGRESSIVE',
                'CLANG_CXX_LANGUAGE_STANDARD': '"gnu++20"',
                'CLANG_ENABLE_MODULES': 'YES',
                'CLANG_ENABLE_OBJC_ARC': 'YES',
                'CLANG_ENABLE_OBJC_WEAK': 'YES',
                'CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING': 'YES',
                'CLANG_WARN_BOOL_CONVERSION': 'YES',
                'CLANG_WARN_COMMA': 'YES',
                'CLANG_WARN_CONSTANT_CONVERSION': 'YES',
                'CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS': 'YES',
                'CLANG_WARN_DIRECT_OBJC_ISA_USAGE': 'YES_ERROR',
                'CLANG_WARN_DOCUMENTATION_COMMENTS': 'YES',
                'CLANG_WARN_EMPTY_BODY': 'YES',
                'CLANG_WARN_ENUM_CONVERSION': 'YES',
                'CLANG_WARN_INFINITE_RECURSION': 'YES',
                'CLANG_WARN_INT_CONVERSION': 'YES',
                'CLANG_WARN_NON_LITERAL_NULL_CONVERSION': 'YES',
                'CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF': 'YES',
                'CLANG_WARN_OBJC_LITERAL_CONVERSION': 'YES',
                'CLANG_WARN_OBJC_ROOT_CLASS': 'YES_ERROR',
                'CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER': 'YES',
                'CLANG_WARN_RANGE_LOOP_ANALYSIS': 'YES',
                'CLANG_WARN_STRICT_PROTOTYPES': 'YES',
                'CLANG_WARN_SUSPICIOUS_MOVE': 'YES',
                'CLANG_WARN_UNGUARDED_AVAILABILITY': 'YES_AGGRESSIVE',
                'CLANG_WARN_UNREACHABLE_CODE': 'YES',
                'CLANG_WARN__DUPLICATE_METHOD_MATCH': 'YES',
                'COPY_PHASE_STRIP': 'NO',
                'DEBUG_INFORMATION_FORMAT': 'dwarf',
                'ENABLE_STRICT_OBJC_MSGSEND': 'YES',
                'ENABLE_TESTABILITY': 'YES',
                'ENABLE_USER_SCRIPT_SANDBOXING': 'YES',
                'GCC_C_LANGUAGE_STANDARD': 'gnu17',
                'GCC_DYNAMIC_NO_PIC': 'NO',
                'GCC_NO_COMMON_BLOCKS': 'YES',
                'GCC_OPTIMIZATION_LEVEL': '0',
                'GCC_PREPROCESSOR_DEFINITIONS': ['"DEBUG=1"', '"$(inherited)"'],
                'GCC_WARN_64_TO_32_BIT_CONVERSION': 'YES',
                'GCC_WARN_ABOUT_RETURN_TYPE': 'YES_ERROR',
                'GCC_WARN_UNDECLARED_SELECTOR': 'YES',
                'GCC_WARN_UNINITIALIZED_AUTOS': 'YES_AGGRESSIVE',
                'GCC_WARN_UNUSED_FUNCTION': 'YES',
                'GCC_WARN_UNUSED_VARIABLE': 'YES',
                'LOCALIZATION_PREFERS_STRING_CATALOGS': 'YES',
                'MTL_ENABLE_DEBUG_INFO': 'INCLUDE_SOURCE',
                'MTL_FAST_MATH': 'YES',
                'ONLY_ACTIVE_ARCH': 'YES',
                'SWIFT_ACTIVE_COMPILATION_CONDITIONS': '"DEBUG $(inherited)"',
                'SWIFT_OPTIMIZATION_LEVEL': '"-Onone"'
            },
            'name': 'Debug'
        }

        release_config_project = {
            'isa': 'XCBuildConfiguration',
            'buildSettings': {
                'ALWAYS_SEARCH_USER_PATHS': 'NO',
                'ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS': 'YES',
                'CLANG_ANALYZER_NONNULL': 'YES',
                'CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION': 'YES_AGGRESSIVE',
                'CLANG_CXX_LANGUAGE_STANDARD': '"gnu++20"',
                'CLANG_ENABLE_MODULES': 'YES',
                'CLANG_ENABLE_OBJC_ARC': 'YES',
                'CLANG_ENABLE_OBJC_WEAK': 'YES',
                'CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING': 'YES',
                'CLANG_WARN_BOOL_CONVERSION': 'YES',
                'CLANG_WARN_COMMA': 'YES',
                'CLANG_WARN_CONSTANT_CONVERSION': 'YES',
                'CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS': 'YES',
                'CLANG_WARN_DIRECT_OBJC_ISA_USAGE': 'YES_ERROR',
                'CLANG_WARN_DOCUMENTATION_COMMENTS': 'YES',
                'CLANG_WARN_EMPTY_BODY': 'YES',
                'CLANG_WARN_ENUM_CONVERSION': 'YES',
                'CLANG_WARN_INFINITE_RECURSION': 'YES',
                'CLANG_WARN_INT_CONVERSION': 'YES',
                'CLANG_WARN_NON_LITERAL_NULL_CONVERSION': 'YES',
                'CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF': 'YES',
                'CLANG_WARN_OBJC_LITERAL_CONVERSION': 'YES',
                'CLANG_WARN_OBJC_ROOT_CLASS': 'YES_ERROR',
                'CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER': 'YES',
                'CLANG_WARN_RANGE_LOOP_ANALYSIS': 'YES',
                'CLANG_WARN_STRICT_PROTOTYPES': 'YES',
                'CLANG_WARN_SUSPICIOUS_MOVE': 'YES',
                'CLANG_WARN_UNGUARDED_AVAILABILITY': 'YES_AGGRESSIVE',
                'CLANG_WARN_UNREACHABLE_CODE': 'YES',
                'CLANG_WARN__DUPLICATE_METHOD_MATCH': 'YES',
                'COPY_PHASE_STRIP': 'NO',
                'DEBUG_INFORMATION_FORMAT': '"dwarf-with-dsym"',
                'ENABLE_NS_ASSERTIONS': 'NO',
                'ENABLE_STRICT_OBJC_MSGSEND': 'YES',
                'ENABLE_USER_SCRIPT_SANDBOXING': 'YES',
                'GCC_C_LANGUAGE_STANDARD': 'gnu17',
                'GCC_NO_COMMON_BLOCKS': 'YES',
                'GCC_WARN_64_TO_32_BIT_CONVERSION': 'YES',
                'GCC_WARN_ABOUT_RETURN_TYPE': 'YES_ERROR',
                'GCC_WARN_UNDECLARED_SELECTOR': 'YES',
                'GCC_WARN_UNINITIALIZED_AUTOS': 'YES_AGGRESSIVE',
                'GCC_WARN_UNUSED_FUNCTION': 'YES',
                'GCC_WARN_UNUSED_VARIABLE': 'YES',
                'LOCALIZATION_PREFERS_STRING_CATALOGS': 'YES',
                'MTL_ENABLE_DEBUG_INFO': 'NO',
                'MTL_FAST_MATH': 'YES',
                'SWIFT_COMPILATION_MODE': 'wholemodule'
            },
            'name': 'Release'
        }

        # Configuration lists
        config_list_target = {
            'isa': 'XCConfigurationList',
            'buildConfigurations': [
                self.debug_config_target_uuid,
                self.release_config_target_uuid
            ],
            'defaultConfigurationIsVisible': '0',
            'defaultConfigurationName': 'Release'
        }

        config_list_project = {
            'isa': 'XCConfigurationList',
            'buildConfigurations': [
                self.debug_config_project_uuid,
                self.release_config_project_uuid
            ],
            'defaultConfigurationIsVisible': '0',
            'defaultConfigurationName': 'Release'
        }

        # Project object
        project = {
            'isa': 'PBXProject',
            'attributes': {
                'BuildIndependentTargetsInParallel': '1',
                'LastSwiftUpdateCheck': '1600',
                'LastUpgradeCheck': '1600'
            },
            'buildConfigurationList': self.config_list_project_uuid,
            'compatibilityVersion': '"Xcode 14.0"',
            'developmentRegion': 'en',
            'hasScannedForEncodings': '0',
            'knownRegions': ['en', 'Base'],
            'mainGroup': self.main_group_uuid,
            'packageReferences': package_ref_list,
            'productRefGroup': self.products_group_uuid,
            'projectDirPath': '""',
            'projectRoot': '""',
            'targets': [self.native_target_uuid]
        }

        # Assemble all objects
        objects = {}

        # Add all file references
        objects.update(self.file_refs)

        # Add all build files
        objects.update(self.build_files)

        # Add all groups
        objects.update(self.groups)

        # Add build phases
        objects[self.sources_phase_uuid] = sources_phase
        objects[self.resources_phase_uuid] = resources_phase
        objects[self.frameworks_phase_uuid] = frameworks_phase

        # Add target
        objects[self.native_target_uuid] = native_target

        # Add configurations
        objects[self.debug_config_target_uuid] = debug_config_target
        objects[self.release_config_target_uuid] = release_config_target
        objects[self.debug_config_project_uuid] = debug_config_project
        objects[self.release_config_project_uuid] = release_config_project

        # Add configuration lists
        objects[self.config_list_target_uuid] = config_list_target
        objects[self.config_list_project_uuid] = config_list_project

        # Add project
        objects[self.project_uuid] = project

        # Add package references
        objects.update(self.package_refs)
        objects.update(self.package_products)

        # Generate pbxproj content
        content = "// !$*UTF8*$!\n{\n"
        content += "\tarchiveVersion = 1;\n"
        content += "\tclasses = {\n\t};\n"
        content += "\tobjectVersion = 60;\n"
        content += "\tobjects = {\n\n"

        # Group objects by type
        obj_types = {}
        for uuid, obj in objects.items():
            isa = obj.get('isa', 'Unknown')
            if isa not in obj_types:
                obj_types[isa] = []
            obj_types[isa].append((uuid, obj))

        # Write objects grouped by type
        for isa in sorted(obj_types.keys()):
            content += f"/* Begin {isa} section */\n"
            for uuid, obj in sorted(obj_types[isa], key=lambda x: x[0]):
                content += f"\t\t{uuid} /* {obj.get('name', obj.get('path', 'Object'))} */ = {{\n"
                content += f"\t\t\tisa = {isa};\n"

                for key, value in sorted(obj.items()):
                    if key == 'isa':
                        continue
                    formatted = self.format_value(value, 2)
                    if formatted is not None:
                        content += f"\t\t\t{key} = {formatted};\n"

                content += "\t\t};\n"
            content += f"/* End {isa} section */\n\n"

        content += "\t};\n"
        content += f"\trootObject = {self.project_uuid} /* Project object */;\n"
        content += "}\n"

        return content


def main():
    """Main function to generate the Xcode project"""

    project_dir = "/Users/burakarslan/Documents/Ios-Development/Ricky"
    xcodeproj_path = os.path.join(project_dir, "RickyApp.xcodeproj")

    # Create .xcodeproj directory
    os.makedirs(xcodeproj_path, exist_ok=True)

    # Generate project
    project = XcodeProject(
        project_name="RickyApp",
        bundle_id="com.burakarslan.RickyApp",
        source_root="RickyApp/RickyApp"
    )

    pbxproj_content = project.generate_pbxproj()

    # Write project.pbxproj
    pbxproj_path = os.path.join(xcodeproj_path, "project.pbxproj")
    with open(pbxproj_path, 'w', encoding='utf-8') as f:
        f.write(pbxproj_content)

    print(f"Successfully created Xcode project at: {xcodeproj_path}")
    print(f"Project file: {pbxproj_path}")
    print(f"File size: {len(pbxproj_content)} bytes")

    # Create xcschememanagement.plist
    scheme_dir = os.path.join(xcodeproj_path, "xcshareddata", "xcschemes")
    os.makedirs(scheme_dir, exist_ok=True)

    scheme_content = """<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>SchemeUserState</key>
	<dict>
		<key>RickyApp.xcscheme_^#shared#^_</key>
		<dict>
			<key>orderHint</key>
			<integer>0</integer>
		</dict>
	</dict>
</dict>
</plist>
"""

    scheme_file = os.path.join(xcodeproj_path, "project.xcworkspace", "xcshareddata", "IDEWorkspaceChecks.plist")
    os.makedirs(os.path.dirname(scheme_file), exist_ok=True)

    workspace_checks = """<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>IDEDidComputeMac32BitWarning</key>
	<true/>
</dict>
</plist>
"""

    with open(scheme_file, 'w') as f:
        f.write(workspace_checks)

    print("Project structure created successfully!")
    return 0


if __name__ == "__main__":
    exit(main())
