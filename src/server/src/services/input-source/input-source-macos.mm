#include "services/input-source/input-source.hpp"
#include <optional>
#include <string>

#include <Carbon/Carbon.h>
#import <Foundation/Foundation.h>

namespace {

NSString *const LAUNCHER_SOURCE_KEY = @"launcherInputSourceID";

std::optional<std::string> s_previousSourceId;

std::optional<std::string> currentSourceId() {
  TISInputSourceRef source = TISCopyCurrentKeyboardInputSource();
  if (!source) return std::nullopt;

  std::optional<std::string> id;
  if (auto *value = static_cast<CFStringRef>(TISGetInputSourceProperty(source, kTISPropertyInputSourceID))) {
    id = std::string([(__bridge NSString *)value UTF8String]);
  }
  CFRelease(source);
  return id;
}

void selectSource(const std::string &id) {
  NSDictionary *filter = @{(__bridge NSString *)kTISPropertyInputSourceID : @(id.c_str())};
  CFArrayRef list = TISCreateInputSourceList((__bridge CFDictionaryRef)filter, false);
  if (!list) return;

  if (CFArrayGetCount(list) > 0) {
    auto source = static_cast<TISInputSourceRef>(const_cast<void *>(CFArrayGetValueAtIndex(list, 0)));
    TISSelectInputSource(source);
  }
  CFRelease(list);
}

} // namespace

namespace InputSource {

void launcherShown() {
  s_previousSourceId = currentSourceId();

  NSString *saved = [NSUserDefaults.standardUserDefaults stringForKey:LAUNCHER_SOURCE_KEY];
  if (!saved) return;

  std::string const launcherId = saved.UTF8String;
  if (launcherId != s_previousSourceId) { selectSource(launcherId); }
}

void launcherHidden() {
  auto const launcherId = currentSourceId();
  if (launcherId) {
    [NSUserDefaults.standardUserDefaults setObject:@(launcherId->c_str()) forKey:LAUNCHER_SOURCE_KEY];
  }

  if (s_previousSourceId && s_previousSourceId != launcherId) { selectSource(*s_previousSourceId); }
  s_previousSourceId.reset();
}

} // namespace InputSource
