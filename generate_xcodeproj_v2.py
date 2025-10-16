#!/usr/bin/env python3
"""
Xcode Project Generator for RickyApp - Version 2
Creates a complete .xcodeproj bundle with proper project.pbxproj structure
"""

import os
import uuid

def generate_uuid():
    """Generate a unique 24-character hex string (Xcode style)"""
    return uuid.uuid4().hex[:24].upper()


def quote_if_needed(s):
    """Quote string if it contains special characters"""
    if not s:
        return '""'
    if any(c in s for c in [' ', '.', '/', '-', '@', ':']):
        return f'"{s}"'
    if s in ['Debug', 'Release']:
        return s
    return s


def write_array(items, indent=3):
    """Write array format"""
    if not items:
        return "()"
    tabs = "\t" * indent
    result = "(\n"
    for item in items:
        result += f"{tabs}{item},\n"
    result += "\t" * (indent - 1) + ")"
    return result


def write_dict(d, indent=3):
    """Write dictionary format"""
    if not d:
        return "{}"
    tabs = "\t" * indent
    result = "{\n"
    for k, v in sorted(d.items()):
        result += f"{tabs}{k} = {v};\n"
    result += "\t" * (indent - 1) + "}"
    return result


def main():
    """Main function to generate the Xcode project"""

    project_dir = "/Users/burakarslan/Documents/Ios-Development/Ricky"
    xcodeproj_path = os.path.join(project_dir, "RickyApp.xcodeproj")

    # Create .xcodeproj directory
    os.makedirs(xcodeproj_path, exist_ok=True)

    # Generate UUIDs
    project_uuid = generate_uuid()
    main_group_uuid = generate_uuid()
    products_group_uuid = generate_uuid()
    vm_group_uuid = generate_uuid()
    view_group_uuid = generate_uuid()

    # File references
    app_file_uuid = generate_uuid()
    content_view_uuid = generate_uuid()
    char_vm_uuid = generate_uuid()
    loc_vm_uuid = generate_uuid()
    char_list_view_uuid = generate_uuid()
    char_detail_view_uuid = generate_uuid()
    loc_list_view_uuid = generate_uuid()
    loc_detail_view_uuid = generate_uuid()
    assets_uuid = generate_uuid()
    info_plist_uuid = generate_uuid()
    entitlements_uuid = generate_uuid()
    app_product_uuid = generate_uuid()

    # Build files
    app_build_uuid = generate_uuid()
    content_build_uuid = generate_uuid()
    char_vm_build_uuid = generate_uuid()
    loc_vm_build_uuid = generate_uuid()
    char_list_build_uuid = generate_uuid()
    char_detail_build_uuid = generate_uuid()
    loc_list_build_uuid = generate_uuid()
    loc_detail_build_uuid = generate_uuid()
    assets_build_uuid = generate_uuid()

    # Build phases
    sources_phase_uuid = generate_uuid()
    resources_phase_uuid = generate_uuid()
    frameworks_phase_uuid = generate_uuid()

    # Target
    native_target_uuid = generate_uuid()

    # Configurations
    config_list_project_uuid = generate_uuid()
    config_list_target_uuid = generate_uuid()
    debug_config_project_uuid = generate_uuid()
    release_config_project_uuid = generate_uuid()
    debug_config_target_uuid = generate_uuid()
    release_config_target_uuid = generate_uuid()

    # Package references
    packages = [
        ('RickyDesignSystem', 'RickyDesignSystem'),
        ('RickyDomain', 'RickyDomain'),
        ('RickyData', 'RickyData'),
        ('RickyRouter', 'RickyRouter'),
        ('RickyDI', 'RickyDI'),
        ('RickyAppCore', 'RickyAppCore'),
        ('RickyConfiguration', 'RickyConfiguration')
    ]

    package_refs = {}
    package_prods = {}
    for pkg_name, pkg_path in packages:
        package_refs[pkg_name] = generate_uuid()
        package_prods[pkg_name] = generate_uuid()

    # Start building the pbxproj content
    content = """// !$*UTF8*$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 60;
	objects = {

/* Begin PBXBuildFile section */
"""

    # Build files
    content += f"\t\t{app_build_uuid} /* RickyAppApp.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {app_file_uuid} /* RickyAppApp.swift */; }};\n"
    content += f"\t\t{content_build_uuid} /* ContentView.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {content_view_uuid} /* ContentView.swift */; }};\n"
    content += f"\t\t{char_vm_build_uuid} /* CharacterListViewModel.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {char_vm_uuid} /* CharacterListViewModel.swift */; }};\n"
    content += f"\t\t{loc_vm_build_uuid} /* LocationListViewModel.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {loc_vm_uuid} /* LocationListViewModel.swift */; }};\n"
    content += f"\t\t{char_list_build_uuid} /* CharacterListView.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {char_list_view_uuid} /* CharacterListView.swift */; }};\n"
    content += f"\t\t{char_detail_build_uuid} /* CharacterDetailView.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {char_detail_view_uuid} /* CharacterDetailView.swift */; }};\n"
    content += f"\t\t{loc_list_build_uuid} /* LocationListView.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {loc_list_view_uuid} /* LocationListView.swift */; }};\n"
    content += f"\t\t{loc_detail_build_uuid} /* LocationDetailView.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {loc_detail_view_uuid} /* LocationDetailView.swift */; }};\n"
    content += f"\t\t{assets_build_uuid} /* Assets.xcassets in Resources */ = {{isa = PBXBuildFile; fileRef = {assets_uuid} /* Assets.xcassets */; }};\n"

    # Package product dependencies
    for pkg_name in packages:
        content += f"\t\t{generate_uuid()} /* {pkg_name[0]} in Frameworks */ = {{isa = PBXBuildFile; productRef = {package_prods[pkg_name[0]]} /* {pkg_name[0]} */; }};\n"

    content += """/* End PBXBuildFile section */

/* Begin PBXFileReference section */
"""

    # File references
    content += f"\t\t{app_product_uuid} /* RickyApp.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = RickyApp.app; sourceTree = BUILT_PRODUCTS_DIR; }};\n"
    content += f"\t\t{app_file_uuid} /* RickyAppApp.swift */ = {{isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = sourcecode.swift; path = RickyAppApp.swift; sourceTree = \"<group>\"; }};\n"
    content += f"\t\t{content_view_uuid} /* ContentView.swift */ = {{isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = sourcecode.swift; path = ContentView.swift; sourceTree = \"<group>\"; }};\n"
    content += f"\t\t{char_vm_uuid} /* CharacterListViewModel.swift */ = {{isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = sourcecode.swift; path = CharacterListViewModel.swift; sourceTree = \"<group>\"; }};\n"
    content += f"\t\t{loc_vm_uuid} /* LocationListViewModel.swift */ = {{isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = sourcecode.swift; path = LocationListViewModel.swift; sourceTree = \"<group>\"; }};\n"
    content += f"\t\t{char_list_view_uuid} /* CharacterListView.swift */ = {{isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = sourcecode.swift; path = CharacterListView.swift; sourceTree = \"<group>\"; }};\n"
    content += f"\t\t{char_detail_view_uuid} /* CharacterDetailView.swift */ = {{isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = sourcecode.swift; path = CharacterDetailView.swift; sourceTree = \"<group>\"; }};\n"
    content += f"\t\t{loc_list_view_uuid} /* LocationListView.swift */ = {{isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = sourcecode.swift; path = LocationListView.swift; sourceTree = \"<group>\"; }};\n"
    content += f"\t\t{loc_detail_view_uuid} /* LocationDetailView.swift */ = {{isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = sourcecode.swift; path = LocationDetailView.swift; sourceTree = \"<group>\"; }};\n"
    content += f"\t\t{assets_uuid} /* Assets.xcassets */ = {{isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = \"<group>\"; }};\n"
    content += f"\t\t{info_plist_uuid} /* Info.plist */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = \"<group>\"; }};\n"
    content += f"\t\t{entitlements_uuid} /* RickyApp.entitlements */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.entitlements; path = RickyApp.entitlements; sourceTree = \"<group>\"; }};\n"

    content += """/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
"""
    content += f"\t\t{frameworks_phase_uuid} /* Frameworks */ = {{\n"
    content += "\t\t\tisa = PBXFrameworksBuildPhase;\n"
    content += "\t\t\tbuildActionMask = 2147483647;\n"
    content += "\t\t\tfiles = (\n"
    content += "\t\t\t);\n"
    content += "\t\t\trunOnlyForDeploymentPostprocessing = 0;\n"
    content += "\t\t};\n"

    content += """/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
"""

    # Main group
    content += f"\t\t{main_group_uuid} = {{\n"
    content += "\t\t\tisa = PBXGroup;\n"
    content += "\t\t\tchildren = (\n"
    content += f"\t\t\t\t{app_file_uuid} /* RickyAppApp.swift */,\n"
    content += f"\t\t\t\t{content_view_uuid} /* ContentView.swift */,\n"
    content += f"\t\t\t\t{vm_group_uuid} /* VM */,\n"
    content += f"\t\t\t\t{view_group_uuid} /* View */,\n"
    content += f"\t\t\t\t{assets_uuid} /* Assets.xcassets */,\n"
    content += f"\t\t\t\t{entitlements_uuid} /* RickyApp.entitlements */,\n"
    content += f"\t\t\t\t{info_plist_uuid} /* Info.plist */,\n"
    content += f"\t\t\t\t{products_group_uuid} /* Products */,\n"
    content += "\t\t\t);\n"
    content += "\t\t\tpath = RickyApp/RickyApp;\n"
    content += "\t\t\tsourceTree = \"<group>\";\n"
    content += "\t\t};\n"

    # Products group
    content += f"\t\t{products_group_uuid} /* Products */ = {{\n"
    content += "\t\t\tisa = PBXGroup;\n"
    content += "\t\t\tchildren = (\n"
    content += f"\t\t\t\t{app_product_uuid} /* RickyApp.app */,\n"
    content += "\t\t\t);\n"
    content += "\t\t\tname = Products;\n"
    content += "\t\t\tsourceTree = \"<group>\";\n"
    content += "\t\t};\n"

    # VM group
    content += f"\t\t{vm_group_uuid} /* VM */ = {{\n"
    content += "\t\t\tisa = PBXGroup;\n"
    content += "\t\t\tchildren = (\n"
    content += f"\t\t\t\t{char_vm_uuid} /* CharacterListViewModel.swift */,\n"
    content += f"\t\t\t\t{loc_vm_uuid} /* LocationListViewModel.swift */,\n"
    content += "\t\t\t);\n"
    content += "\t\t\tpath = VM;\n"
    content += "\t\t\tsourceTree = \"<group>\";\n"
    content += "\t\t};\n"

    # View group
    content += f"\t\t{view_group_uuid} /* View */ = {{\n"
    content += "\t\t\tisa = PBXGroup;\n"
    content += "\t\t\tchildren = (\n"
    content += f"\t\t\t\t{char_list_view_uuid} /* CharacterListView.swift */,\n"
    content += f"\t\t\t\t{char_detail_view_uuid} /* CharacterDetailView.swift */,\n"
    content += f"\t\t\t\t{loc_list_view_uuid} /* LocationListView.swift */,\n"
    content += f"\t\t\t\t{loc_detail_view_uuid} /* LocationDetailView.swift */,\n"
    content += "\t\t\t);\n"
    content += "\t\t\tpath = View;\n"
    content += "\t\t\tsourceTree = \"<group>\";\n"
    content += "\t\t};\n"

    content += """/* End PBXGroup section */

/* Begin PBXNativeTarget section */
"""

    content += f"\t\t{native_target_uuid} /* RickyApp */ = {{\n"
    content += "\t\t\tisa = PBXNativeTarget;\n"
    content += f"\t\t\tbuildConfigurationList = {config_list_target_uuid} /* Build configuration list for PBXNativeTarget \"RickyApp\" */;\n"
    content += "\t\t\tbuildPhases = (\n"
    content += f"\t\t\t\t{sources_phase_uuid} /* Sources */,\n"
    content += f"\t\t\t\t{frameworks_phase_uuid} /* Frameworks */,\n"
    content += f"\t\t\t\t{resources_phase_uuid} /* Resources */,\n"
    content += "\t\t\t);\n"
    content += "\t\t\tbuildRules = (\n"
    content += "\t\t\t);\n"
    content += "\t\t\tdependencies = (\n"
    content += "\t\t\t);\n"
    content += "\t\t\tname = RickyApp;\n"
    content += "\t\t\tpackageProductDependencies = (\n"
    for pkg_name in packages:
        content += f"\t\t\t\t{package_prods[pkg_name[0]]} /* {pkg_name[0]} */,\n"
    content += "\t\t\t);\n"
    content += "\t\t\tproductName = RickyApp;\n"
    content += f"\t\t\tproductReference = {app_product_uuid} /* RickyApp.app */;\n"
    content += "\t\t\tproductType = \"com.apple.product-type.application\";\n"
    content += "\t\t};\n"

    content += """/* End PBXNativeTarget section */

/* Begin PBXProject section */
"""

    content += f"\t\t{project_uuid} /* Project object */ = {{\n"
    content += "\t\t\tisa = PBXProject;\n"
    content += "\t\t\tattributes = {\n"
    content += "\t\t\t\tBuildIndependentTargetsInParallel = 1;\n"
    content += "\t\t\t\tLastSwiftUpdateCheck = 1600;\n"
    content += "\t\t\t\tLastUpgradeCheck = 1600;\n"
    content += "\t\t\t};\n"
    content += f"\t\t\tbuildConfigurationList = {config_list_project_uuid} /* Build configuration list for PBXProject \"RickyApp\" */;\n"
    content += "\t\t\tcompatibilityVersion = \"Xcode 14.0\";\n"
    content += "\t\t\tdevelopmentRegion = en;\n"
    content += "\t\t\thasScannedForEncodings = 0;\n"
    content += "\t\t\tknownRegions = (\n"
    content += "\t\t\t\ten,\n"
    content += "\t\t\t\tBase,\n"
    content += "\t\t\t);\n"
    content += f"\t\t\tmainGroup = {main_group_uuid};\n"
    content += "\t\t\tpackageReferences = (\n"
    for pkg_name in packages:
        content += f"\t\t\t\t{package_refs[pkg_name[0]]} /* XCLocalSwiftPackageReference \"{pkg_name[1]}\" */,\n"
    content += "\t\t\t);\n"
    content += f"\t\t\tproductRefGroup = {products_group_uuid} /* Products */;\n"
    content += "\t\t\tprojectDirPath = \"\";\n"
    content += "\t\t\tprojectRoot = \"\";\n"
    content += "\t\t\ttargets = (\n"
    content += f"\t\t\t\t{native_target_uuid} /* RickyApp */,\n"
    content += "\t\t\t);\n"
    content += "\t\t};\n"

    content += """/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
"""

    content += f"\t\t{resources_phase_uuid} /* Resources */ = {{\n"
    content += "\t\t\tisa = PBXResourcesBuildPhase;\n"
    content += "\t\t\tbuildActionMask = 2147483647;\n"
    content += "\t\t\tfiles = (\n"
    content += f"\t\t\t\t{assets_build_uuid} /* Assets.xcassets in Resources */,\n"
    content += "\t\t\t);\n"
    content += "\t\t\trunOnlyForDeploymentPostprocessing = 0;\n"
    content += "\t\t};\n"

    content += """/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
"""

    content += f"\t\t{sources_phase_uuid} /* Sources */ = {{\n"
    content += "\t\t\tisa = PBXSourcesBuildPhase;\n"
    content += "\t\t\tbuildActionMask = 2147483647;\n"
    content += "\t\t\tfiles = (\n"
    content += f"\t\t\t\t{app_build_uuid} /* RickyAppApp.swift in Sources */,\n"
    content += f"\t\t\t\t{content_build_uuid} /* ContentView.swift in Sources */,\n"
    content += f"\t\t\t\t{char_vm_build_uuid} /* CharacterListViewModel.swift in Sources */,\n"
    content += f"\t\t\t\t{loc_vm_build_uuid} /* LocationListViewModel.swift in Sources */,\n"
    content += f"\t\t\t\t{char_list_build_uuid} /* CharacterListView.swift in Sources */,\n"
    content += f"\t\t\t\t{char_detail_build_uuid} /* CharacterDetailView.swift in Sources */,\n"
    content += f"\t\t\t\t{loc_list_build_uuid} /* LocationListView.swift in Sources */,\n"
    content += f"\t\t\t\t{loc_detail_build_uuid} /* LocationDetailView.swift in Sources */,\n"
    content += "\t\t\t);\n"
    content += "\t\t\trunOnlyForDeploymentPostprocessing = 0;\n"
    content += "\t\t};\n"

    content += """/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
"""

    # Debug config - Project
    content += f"\t\t{debug_config_project_uuid} /* Debug */ = {{\n"
    content += "\t\t\tisa = XCBuildConfiguration;\n"
    content += "\t\t\tbuildSettings = {\n"
    content += "\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;\n"
    content += "\t\t\t\tASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;\n"
    content += "\t\t\t\tCLANG_ANALYZER_NONNULL = YES;\n"
    content += "\t\t\t\tCLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;\n"
    content += "\t\t\t\tCLANG_CXX_LANGUAGE_STANDARD = \"gnu++20\";\n"
    content += "\t\t\t\tCLANG_ENABLE_MODULES = YES;\n"
    content += "\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;\n"
    content += "\t\t\t\tCLANG_ENABLE_OBJC_WEAK = YES;\n"
    content += "\t\t\t\tCLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;\n"
    content += "\t\t\t\tCLANG_WARN_BOOL_CONVERSION = YES;\n"
    content += "\t\t\t\tCLANG_WARN_COMMA = YES;\n"
    content += "\t\t\t\tCLANG_WARN_CONSTANT_CONVERSION = YES;\n"
    content += "\t\t\t\tCLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;\n"
    content += "\t\t\t\tCLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;\n"
    content += "\t\t\t\tCLANG_WARN_DOCUMENTATION_COMMENTS = YES;\n"
    content += "\t\t\t\tCLANG_WARN_EMPTY_BODY = YES;\n"
    content += "\t\t\t\tCLANG_WARN_ENUM_CONVERSION = YES;\n"
    content += "\t\t\t\tCLANG_WARN_INFINITE_RECURSION = YES;\n"
    content += "\t\t\t\tCLANG_WARN_INT_CONVERSION = YES;\n"
    content += "\t\t\t\tCLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;\n"
    content += "\t\t\t\tCLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;\n"
    content += "\t\t\t\tCLANG_WARN_OBJC_LITERAL_CONVERSION = YES;\n"
    content += "\t\t\t\tCLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;\n"
    content += "\t\t\t\tCLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;\n"
    content += "\t\t\t\tCLANG_WARN_RANGE_LOOP_ANALYSIS = YES;\n"
    content += "\t\t\t\tCLANG_WARN_STRICT_PROTOTYPES = YES;\n"
    content += "\t\t\t\tCLANG_WARN_SUSPICIOUS_MOVE = YES;\n"
    content += "\t\t\t\tCLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;\n"
    content += "\t\t\t\tCLANG_WARN_UNREACHABLE_CODE = YES;\n"
    content += "\t\t\t\tCLANG_WARN__DUPLICATE_METHOD_MATCH = YES;\n"
    content += "\t\t\t\tCOPY_PHASE_STRIP = NO;\n"
    content += "\t\t\t\tDEBUG_INFORMATION_FORMAT = dwarf;\n"
    content += "\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;\n"
    content += "\t\t\t\tENABLE_TESTABILITY = YES;\n"
    content += "\t\t\t\tENABLE_USER_SCRIPT_SANDBOXING = YES;\n"
    content += "\t\t\t\tGCC_C_LANGUAGE_STANDARD = gnu17;\n"
    content += "\t\t\t\tGCC_DYNAMIC_NO_PIC = NO;\n"
    content += "\t\t\t\tGCC_NO_COMMON_BLOCKS = YES;\n"
    content += "\t\t\t\tGCC_OPTIMIZATION_LEVEL = 0;\n"
    content += "\t\t\t\tGCC_PREPROCESSOR_DEFINITIONS = (\n"
    content += "\t\t\t\t\t\"DEBUG=1\",\n"
    content += "\t\t\t\t\t\"$(inherited)\",\n"
    content += "\t\t\t\t);\n"
    content += "\t\t\t\tGCC_WARN_64_TO_32_BIT_CONVERSION = YES;\n"
    content += "\t\t\t\tGCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;\n"
    content += "\t\t\t\tGCC_WARN_UNDECLARED_SELECTOR = YES;\n"
    content += "\t\t\t\tGCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;\n"
    content += "\t\t\t\tGCC_WARN_UNUSED_FUNCTION = YES;\n"
    content += "\t\t\t\tGCC_WARN_UNUSED_VARIABLE = YES;\n"
    content += "\t\t\t\tLOCALIZATION_PREFERS_STRING_CATALOGS = YES;\n"
    content += "\t\t\t\tMTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;\n"
    content += "\t\t\t\tMTL_FAST_MATH = YES;\n"
    content += "\t\t\t\tONLY_ACTIVE_ARCH = YES;\n"
    content += "\t\t\t\tSWIFT_ACTIVE_COMPILATION_CONDITIONS = \"DEBUG $(inherited)\";\n"
    content += "\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = \"-Onone\";\n"
    content += "\t\t\t};\n"
    content += "\t\t\tname = Debug;\n"
    content += "\t\t};\n"

    # Release config - Project
    content += f"\t\t{release_config_project_uuid} /* Release */ = {{\n"
    content += "\t\t\tisa = XCBuildConfiguration;\n"
    content += "\t\t\tbuildSettings = {\n"
    content += "\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;\n"
    content += "\t\t\t\tASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;\n"
    content += "\t\t\t\tCLANG_ANALYZER_NONNULL = YES;\n"
    content += "\t\t\t\tCLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;\n"
    content += "\t\t\t\tCLANG_CXX_LANGUAGE_STANDARD = \"gnu++20\";\n"
    content += "\t\t\t\tCLANG_ENABLE_MODULES = YES;\n"
    content += "\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;\n"
    content += "\t\t\t\tCLANG_ENABLE_OBJC_WEAK = YES;\n"
    content += "\t\t\t\tCLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;\n"
    content += "\t\t\t\tCLANG_WARN_BOOL_CONVERSION = YES;\n"
    content += "\t\t\t\tCLANG_WARN_COMMA = YES;\n"
    content += "\t\t\t\tCLANG_WARN_CONSTANT_CONVERSION = YES;\n"
    content += "\t\t\t\tCLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;\n"
    content += "\t\t\t\tCLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;\n"
    content += "\t\t\t\tCLANG_WARN_DOCUMENTATION_COMMENTS = YES;\n"
    content += "\t\t\t\tCLANG_WARN_EMPTY_BODY = YES;\n"
    content += "\t\t\t\tCLANG_WARN_ENUM_CONVERSION = YES;\n"
    content += "\t\t\t\tCLANG_WARN_INFINITE_RECURSION = YES;\n"
    content += "\t\t\t\tCLANG_WARN_INT_CONVERSION = YES;\n"
    content += "\t\t\t\tCLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;\n"
    content += "\t\t\t\tCLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;\n"
    content += "\t\t\t\tCLANG_WARN_OBJC_LITERAL_CONVERSION = YES;\n"
    content += "\t\t\t\tCLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;\n"
    content += "\t\t\t\tCLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;\n"
    content += "\t\t\t\tCLANG_WARN_RANGE_LOOP_ANALYSIS = YES;\n"
    content += "\t\t\t\tCLANG_WARN_STRICT_PROTOTYPES = YES;\n"
    content += "\t\t\t\tCLANG_WARN_SUSPICIOUS_MOVE = YES;\n"
    content += "\t\t\t\tCLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;\n"
    content += "\t\t\t\tCLANG_WARN_UNREACHABLE_CODE = YES;\n"
    content += "\t\t\t\tCLANG_WARN__DUPLICATE_METHOD_MATCH = YES;\n"
    content += "\t\t\t\tCOPY_PHASE_STRIP = NO;\n"
    content += "\t\t\t\tDEBUG_INFORMATION_FORMAT = \"dwarf-with-dsym\";\n"
    content += "\t\t\t\tENABLE_NS_ASSERTIONS = NO;\n"
    content += "\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;\n"
    content += "\t\t\t\tENABLE_USER_SCRIPT_SANDBOXING = YES;\n"
    content += "\t\t\t\tGCC_C_LANGUAGE_STANDARD = gnu17;\n"
    content += "\t\t\t\tGCC_NO_COMMON_BLOCKS = YES;\n"
    content += "\t\t\t\tGCC_WARN_64_TO_32_BIT_CONVERSION = YES;\n"
    content += "\t\t\t\tGCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;\n"
    content += "\t\t\t\tGCC_WARN_UNDECLARED_SELECTOR = YES;\n"
    content += "\t\t\t\tGCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;\n"
    content += "\t\t\t\tGCC_WARN_UNUSED_FUNCTION = YES;\n"
    content += "\t\t\t\tGCC_WARN_UNUSED_VARIABLE = YES;\n"
    content += "\t\t\t\tLOCALIZATION_PREFERS_STRING_CATALOGS = YES;\n"
    content += "\t\t\t\tMTL_ENABLE_DEBUG_INFO = NO;\n"
    content += "\t\t\t\tMTL_FAST_MATH = YES;\n"
    content += "\t\t\t\tSWIFT_COMPILATION_MODE = wholemodule;\n"
    content += "\t\t\t};\n"
    content += "\t\t\tname = Release;\n"
    content += "\t\t};\n"

    # Debug config - Target
    content += f"\t\t{debug_config_target_uuid} /* Debug */ = {{\n"
    content += "\t\t\tisa = XCBuildConfiguration;\n"
    content += "\t\t\tbuildSettings = {\n"
    content += "\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;\n"
    content += "\t\t\t\tASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;\n"
    content += "\t\t\t\tCODE_SIGN_ENTITLEMENTS = RickyApp/RickyApp/RickyApp.entitlements;\n"
    content += "\t\t\t\tCODE_SIGN_STYLE = Automatic;\n"
    content += "\t\t\t\tCURRENT_PROJECT_VERSION = 1;\n"
    content += "\t\t\t\tDEVELOPMENT_TEAM = \"\";\n"
    content += "\t\t\t\tENABLE_PREVIEWS = YES;\n"
    content += "\t\t\t\tGENERATE_INFOPLIST_FILE = NO;\n"
    content += "\t\t\t\tINFOPLIST_FILE = RickyApp/RickyApp/Info.plist;\n"
    content += "\t\t\t\tINFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;\n"
    content += "\t\t\t\tINFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;\n"
    content += "\t\t\t\tINFOPLIST_KEY_UILaunchScreen_Generation = YES;\n"
    content += "\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = \"UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight\";\n"
    content += "\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = \"UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight\";\n"
    content += "\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 15.0;\n"
    content += "\t\t\t\tLD_RUNPATH_SEARCH_PATHS = \"$(inherited) @executable_path/Frameworks\";\n"
    content += "\t\t\t\tMARKETING_VERSION = 1.0;\n"
    content += "\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.burakarslan.RickyApp;\n"
    content += "\t\t\t\tPRODUCT_NAME = \"$(TARGET_NAME)\";\n"
    content += "\t\t\t\tSDKROOT = iphoneos;\n"
    content += "\t\t\t\tSUPPORTED_PLATFORMS = \"iphoneos iphonesimulator\";\n"
    content += "\t\t\t\tSUPPORTS_MACCATALYST = NO;\n"
    content += "\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;\n"
    content += "\t\t\t\tSWIFT_VERSION = 6.0;\n"
    content += "\t\t\t\tTARGETED_DEVICE_FAMILY = \"1,2\";\n"
    content += "\t\t\t};\n"
    content += "\t\t\tname = Debug;\n"
    content += "\t\t};\n"

    # Release config - Target
    content += f"\t\t{release_config_target_uuid} /* Release */ = {{\n"
    content += "\t\t\tisa = XCBuildConfiguration;\n"
    content += "\t\t\tbuildSettings = {\n"
    content += "\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;\n"
    content += "\t\t\t\tASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;\n"
    content += "\t\t\t\tCODE_SIGN_ENTITLEMENTS = RickyApp/RickyApp/RickyApp.entitlements;\n"
    content += "\t\t\t\tCODE_SIGN_STYLE = Automatic;\n"
    content += "\t\t\t\tCURRENT_PROJECT_VERSION = 1;\n"
    content += "\t\t\t\tDEVELOPMENT_TEAM = \"\";\n"
    content += "\t\t\t\tENABLE_PREVIEWS = YES;\n"
    content += "\t\t\t\tGENERATE_INFOPLIST_FILE = NO;\n"
    content += "\t\t\t\tINFOPLIST_FILE = RickyApp/RickyApp/Info.plist;\n"
    content += "\t\t\t\tINFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;\n"
    content += "\t\t\t\tINFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;\n"
    content += "\t\t\t\tINFOPLIST_KEY_UILaunchScreen_Generation = YES;\n"
    content += "\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = \"UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight\";\n"
    content += "\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = \"UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight\";\n"
    content += "\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 15.0;\n"
    content += "\t\t\t\tLD_RUNPATH_SEARCH_PATHS = \"$(inherited) @executable_path/Frameworks\";\n"
    content += "\t\t\t\tMARKETING_VERSION = 1.0;\n"
    content += "\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.burakarslan.RickyApp;\n"
    content += "\t\t\t\tPRODUCT_NAME = \"$(TARGET_NAME)\";\n"
    content += "\t\t\t\tSDKROOT = iphoneos;\n"
    content += "\t\t\t\tSUPPORTED_PLATFORMS = \"iphoneos iphonesimulator\";\n"
    content += "\t\t\t\tSUPPORTS_MACCATALYST = NO;\n"
    content += "\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;\n"
    content += "\t\t\t\tSWIFT_VERSION = 6.0;\n"
    content += "\t\t\t\tTARGETED_DEVICE_FAMILY = \"1,2\";\n"
    content += "\t\t\t\tVALIDATE_PRODUCT = YES;\n"
    content += "\t\t\t};\n"
    content += "\t\t\tname = Release;\n"
    content += "\t\t};\n"

    content += """/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
"""

    # Configuration list - Project
    content += f"\t\t{config_list_project_uuid} /* Build configuration list for PBXProject \"RickyApp\" */ = {{\n"
    content += "\t\t\tisa = XCConfigurationList;\n"
    content += "\t\t\tbuildConfigurations = (\n"
    content += f"\t\t\t\t{debug_config_project_uuid} /* Debug */,\n"
    content += f"\t\t\t\t{release_config_project_uuid} /* Release */,\n"
    content += "\t\t\t);\n"
    content += "\t\t\tdefaultConfigurationIsVisible = 0;\n"
    content += "\t\t\tdefaultConfigurationName = Release;\n"
    content += "\t\t};\n"

    # Configuration list - Target
    content += f"\t\t{config_list_target_uuid} /* Build configuration list for PBXNativeTarget \"RickyApp\" */ = {{\n"
    content += "\t\t\tisa = XCConfigurationList;\n"
    content += "\t\t\tbuildConfigurations = (\n"
    content += f"\t\t\t\t{debug_config_target_uuid} /* Debug */,\n"
    content += f"\t\t\t\t{release_config_target_uuid} /* Release */,\n"
    content += "\t\t\t);\n"
    content += "\t\t\tdefaultConfigurationIsVisible = 0;\n"
    content += "\t\t\tdefaultConfigurationName = Release;\n"
    content += "\t\t};\n"

    content += """/* End XCConfigurationList section */

/* Begin XCLocalSwiftPackageReference section */
"""

    for pkg_name, pkg_path in packages:
        content += f"\t\t{package_refs[pkg_name]} /* XCLocalSwiftPackageReference \"{pkg_path}\" */ = {{\n"
        content += "\t\t\tisa = XCLocalSwiftPackageReference;\n"
        content += f"\t\t\trelativePath = {pkg_path};\n"
        content += "\t\t};\n"

    content += """/* End XCLocalSwiftPackageReference section */

/* Begin XCSwiftPackageProductDependency section */
"""

    for pkg_name, _ in packages:
        content += f"\t\t{package_prods[pkg_name]} /* {pkg_name} */ = {{\n"
        content += "\t\t\tisa = XCSwiftPackageProductDependency;\n"
        content += f"\t\t\tpackage = {package_refs[pkg_name]} /* XCLocalSwiftPackageReference \"{_}\" */;\n"
        content += f"\t\t\tproductName = {pkg_name};\n"
        content += "\t\t};\n"

    content += """/* End XCSwiftPackageProductDependency section */
	};
"""

    content += f"\trootObject = {project_uuid} /* Project object */;\n"
    content += "}\n"

    # Write project.pbxproj
    pbxproj_path = os.path.join(xcodeproj_path, "project.pbxproj")
    with open(pbxproj_path, 'w', encoding='utf-8') as f:
        f.write(content)

    print(f"Successfully created Xcode project at: {xcodeproj_path}")
    print(f"Project file: {pbxproj_path}")
    print(f"File size: {len(content)} bytes")

    # Create workspace structure
    workspace_dir = os.path.join(xcodeproj_path, "project.xcworkspace")
    os.makedirs(workspace_dir, exist_ok=True)

    workspace_content = """<?xml version="1.0" encoding="UTF-8"?>
<Workspace
   version = "1.0">
   <FileRef
      location = "self:">
   </FileRef>
</Workspace>
"""

    with open(os.path.join(workspace_dir, "contents.xcworkspacedata"), 'w') as f:
        f.write(workspace_content)

    # Create workspace checks
    xcshared_dir = os.path.join(workspace_dir, "xcshareddata")
    os.makedirs(xcshared_dir, exist_ok=True)

    workspace_checks = """<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>IDEDidComputeMac32BitWarning</key>
	<true/>
</dict>
</plist>
"""

    with open(os.path.join(xcshared_dir, "IDEWorkspaceChecks.plist"), 'w') as f:
        f.write(workspace_checks)

    print("\nProject structure created successfully!")
    print("\nCreated files:")
    print(f"  - {pbxproj_path}")
    print(f"  - {os.path.join(workspace_dir, 'contents.xcworkspacedata')}")
    print(f"  - {os.path.join(xcshared_dir, 'IDEWorkspaceChecks.plist')}")

    return 0


if __name__ == "__main__":
    exit(main())
