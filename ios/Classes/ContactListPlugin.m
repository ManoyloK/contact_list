#import "ContactListPlugin.h"
#if __has_include(<contact_list/contact_list-Swift.h>)
#import <contact_list/contact_list-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "contact_list-Swift.h"
#endif

@implementation ContactListPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftContactListPlugin registerWithRegistrar:registrar];
}
@end
